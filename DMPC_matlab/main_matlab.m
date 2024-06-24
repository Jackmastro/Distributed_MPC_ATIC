clc;
clear;
close all;

%% Change directory
% Get the full path of the currently running script
if isdeployed
    % If the code is deployed, use the built-in method
    scriptFullPath = mfilename('fullpath');
else
    % If running in the MATLAB environment, use the editor API
    scriptFullPath = matlab.desktop.editor.getActiveFilename;
end

% Extract the directory part of the path
[scriptDir, ~, ~] = fileparts(scriptFullPath);

% Change the current directory to the script's directory
cd(scriptDir);

% Display the current directory to confirm the change
disp(['Current directory changed to: ', scriptDir]);

%% Construct objects
% Controller hyperparameters
Ts = 15*60;
K = 4;
Q = 1;

% Set temperatures
T_set = 273 + 22; % PLACE HOLDER
T_amb = 273; % PLACE HOLDER

Tset_obj = Tset_matlab(Ts, K);

T_mean = 273 - 5;
T_var_pp = 10;
Tamb_obj = Tamb_matlab(Ts, K, T_mean, T_var_pp);

% Validate NMPC
validation = true;

% Construct houses
A = Household_matlab(true, false, T_set, T_amb, Ts, K, Q, validation);
options_A = nlmpcmoveopt;
options_A.Parameters = A.paramsCell;

B = Household_matlab(false, false, T_set, T_amb, Ts, K, Q, validation);
options_B = nlmpcmoveopt;
options_B.Parameters = B.paramsCell;

C = Household_matlab(false, true, T_set, T_amb, Ts, K, Q, validation);
options_C = nlmpcmoveopt;
options_C.Parameters = C.paramsCell;

%% Initialization

hours_sim = 4 * 3600;
T = hours_sim / Ts;
% T = 2;
max_iter = 20;

% Initial conditions
x_A = [A.T_F_0, A.T_S1_0, A.T_S2_0, A.T_b_0, A.T_S3_0, A.T_R_0];
x_B = [B.T_F_0, B.T_S1_0, B.T_S2_0, B.T_b_0, B.T_S3_0, B.T_R_0]; 
x_C = [C.T_F_0, C.T_S1_0, C.T_S2_0, C.T_b_0, C.T_S3_0, C.T_R_0, C.T_BYP_0]; 

% Manipulated Variables
mv_0 = [A.T_F_0, A.T_R_0, 5, 2, 3, 3, 5]; % T_feed_I, T_succ_I, m_F, m_U, m_O, m_succ_I, m_R
lastmv_A = mv_0;
lastmv_B = mv_0;
lastmv_C = mv_0;

% Measured Disturbances
md_A = zeros(A.K+1, A.nu_md);
md_B = zeros(B.K+1, B.nu_md);
md_C = zeros(C.K+1, C.nu_md);
% T_set
md_A(:, 10) = Tset_obj.getTsetTrajectory(0);
md_B(:, 18) = Tset_obj.getTsetTrajectory(0);
md_C(:, 10) = Tset_obj.getTsetTrajectory(0);
% T_amb
md_A(:, 9)  = Tamb_obj.getTambTrajectory(0);
md_B(:, 17) = Tamb_obj.getTambTrajectory(0);
md_C(:, 9)  = Tamb_obj.getTambTrajectory(0);

% For Plots
save_plot = false;
rows_plots = T+1;

x = struct();
x.A = zeros(rows_plots, A.nx);
x.B = zeros(rows_plots, B.nx);
x.C = zeros(rows_plots, C.nx);

x.A(1,:) = x_A;
x.B(1,:) = x_B;
x.C(1,:) = x_C;

u = struct();
u.A = zeros(rows_plots, A.nu_mv);
u.B = zeros(rows_plots, B.nu_mv);
u.C = zeros(rows_plots, C.nu_mv);

u.A(1,:) = lastmv_A; %TODO: check first row
u.B(1,:) = lastmv_B;
u.C(1,:) = lastmv_C;

%% Simulation
tic
for t = 1:T

    % Plotting 
    figToPlot = figure;
    set(figToPlot, 'Name', ['Step: ', num2str(t)]);

    h_m = plot(NaN, NaN, 'b', 'DisplayName', 'Mass flow');
    hold on;
    h_T = plot(NaN, NaN, 'r', 'DisplayName', 'Temperature');
    legend show;

    xlabel('Iterations', 'Interpreter', 'latex');
    ylabel('$||\Delta T||, ||\Delta m||$', 'Interpreter', 'latex');
    grid on;
    hold on;

    % While loop - ADMM
    max_iter_reached = false;
    error_m = zeros(1, max_iter);
    error_T = zeros(1, max_iter);
    is_converged = false;
    iteration = 0;

    while ~is_converged && ~max_iter_reached

        fprintf('------- Time: %.2f Iteration: %d -------\n', t, iteration);

        iteration = iteration + 1;
        if iteration >= max_iter
        max_iter_reached = true;
        end
        
        % A solves
        [mv_A,~,info] = nlmpcmove(A.nlobj, x_A, lastmv_A, [], md_A, options_A); 
        
        lastmv_A = mv_A;
        X_A = info.Xopt;
        MV_A = info.MVopt;
        T_b_A = info.Yopt;
        
        % A sends to B
        %              m_O_A_A,    m_R_B_A,  T_F_A_A,  T_R_B_A
        md_B(:,1:4) = [MV_A(:,5), MV_A(:,6), X_A(:,1), MV_A(:,2)];
        
        % B solves
        [mv_B,~,info] = nlmpcmove(B.nlobj, x_B, lastmv_B, [], md_B, options_B);
        
        lastmv_B = mv_B;
        X_B = info.Xopt;
        MV_B = info.MVopt;
        T_b_B = info.Yopt;
        
        % B sends to A and C
        %              m_O_A_B,    m_R_B_B,  T_F_A_B,  T_R_B_B
        md_A(:,1:4) = [MV_B(:,3), MV_B(:,7), MV_B(:,1), X_B(:,6)];
        %              m_O_B_B,    m_R_C_B,  T_F_B_B,  T_R_C_B
        md_C(:,1:4) = [MV_B(:,5), MV_B(:,6), X_B(:,1), MV_B(:,2)];
        
        % C solves
        [mv_C,~,info] = nlmpcmove(C.nlobj, x_C, lastmv_C, [], md_C, options_C); 
        
        lastmv_C = mv_C;
        X_C = info.Xopt;
        MV_C = info.MVopt;
        T_b_C = info.Yopt;
        
        % C sends to B
        %              m_O_B_C,    m_R_C_C,  T_F_B_C,  T_R_C_C
        md_B(:,5:8) = [MV_C(:,3), MV_C(:,7), MV_C(:,1), X_C(:,6)];
        
        % Update and Check
        [lambda_AB, lambda_BC, difference_m, difference_T, is_converged] = UpdateMultipliers(X_A, MV_A, X_B, MV_B, X_C, MV_C, md_A, md_C);
        
        md_A(:,5:8) = lambda_AB;
        md_B(:,9:16) = [lambda_AB, lambda_BC];
        md_C(:,5:8) = lambda_BC;
        
        % Plotting
        error_m(iteration) = difference_m;
        error_T(iteration) = difference_T;
        
        set(h_m, 'XData', 1:iteration, 'YData', error_m(1:iteration));
        set(h_T, 'XData', 1:iteration, 'YData', error_T(1:iteration));
        drawnow;

    end

    % Update states
    x_A = X_A(2, :);
    x_B = X_B(2, :);
    x_C = X_C(2, :);

    % Update T_set
    current_time = t * Ts;
    md_A(:, 10) = Tset_obj.getTsetTrajectory(current_time);
    md_B(:, 18) = Tset_obj.getTsetTrajectory(current_time);
    md_C(:, 10) = Tset_obj.getTsetTrajectory(current_time);

    % Update T_amb
    md_A(:, 9)  = Tamb_obj.getTambTrajectory(current_time);
    md_B(:, 17) = Tamb_obj.getTambTrajectory(current_time);
    md_C(:, 9)  = Tamb_obj.getTambTrajectory(current_time);

    % Save trajectories
    idx = t+1;
    x.A(idx, :) = X_A(2, :);
    x.B(idx, :) = X_B(2, :);
    x.C(idx, :) = X_C(2, :);

    u.A(idx, :) = MV_A(1, :);
    u.B(idx, :) = MV_B(1, :);
    u.C(idx, :) = MV_C(1, :);

    close;
end
toc
%% Buildings Plot
time = linspace(0, T, T+1) * Ts / 60; %min
time_temp = [time(1), time(1:end-1)]; %min

xlimits = [0, time(end)];

temperaturePlot = figure;

plot(time, Tamb_obj.sinusoidal_Tamb(time_temp*60) - 273, "m--", 'DisplayName', 'Tamb')
hold on
plot(time, Tset_obj.interpolator_Tset(time_temp*60) - 273, "k--", 'DisplayName', 'Tset')
plot(time, x.A(:, 4) - 273, ".b-", 'DisplayName', strcat(A.names.x(4), '^A'))
plot(time, x.B(:, 4) - 273, ".g-", 'DisplayName', strcat(B.names.x(4), '^B'))
plot(time, x.C(:, 4) - 273, ".r-", 'DisplayName', strcat(C.names.x(4), '^C'))

xlabel('Time / min', 'Interpreter', 'latex');
ylabel('Temperature / $^\circ$C', 'Interpreter', 'latex');
xlim(xlimits);
legend show;
grid on;
box on;
hold off;

clickableLegend

%% All temperatures and mass flow rates Plot
% Create a figure
subPlot = figure;

% Define the number of subplots
numSubplots = 6;

% Define houses and data names
houses = {'A', 'B', 'C'};
xDataNames = {'x'};
uDataNames = {'u'};

for i = 1:3
    subplot(2, 3, i);
    hold on;
    houseName = houses{i};
    xData = x.(houseName);
    for j = 1:length(A.names.x)
        plot(time, xData(:, j) - 273, 'DisplayName', A.names.x(j));
    end
    uData = u.(houseName);
    for j = 1:2
        plot(time, uData(:, j) - 273, 'DisplayName', A.names.u(j));
    end
    xlim(xlimits);
    ylim([-Inf; Inf]);
    title(['$T_', houseName, '$'], 'Interpreter', 'latex');
    xlabel('Time / min', 'Interpreter', 'latex');
    ylabel('Temperature / $^\circ$C', 'Interpreter', 'latex');
    legend;
    grid on;
    box on;
    hold off;
    clickableLegend
end

for i = 1:3
    subplot(2, 3, i+3);
    hold on;
    houseName = houses{i};
    uData = u.(houseName);
    for j = 3:length(A.names.u)
        plot(time, uData(:, j), 'DisplayName', A.names.u(j));
    end
    plot(time, uData(:, j), 'DisplayName', A.names.u(j));
    xlim(xlimits);
    ylim([0; Inf]);
    title(['$\dot{m}_', houseName, '$'], 'Interpreter', 'latex');
    xlabel('Time / min', 'Interpreter', 'latex');
    ylabel('Mass flow rate / kg/s', 'Interpreter', 'latex');
    legend;
    grid on;
    box on;
    hold off;
    clickableLegend
end

%% Save plots

if save_plot
    saveTikzPlot('convergence_plot.tex', temperaturePlot, 'height', '\figureheight', 'width', '\figurewidth');
end