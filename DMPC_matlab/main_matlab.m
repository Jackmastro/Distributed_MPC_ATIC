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
T_var_pp = 0;
Tamb_obj = Tamb_matlab(Ts, K, T_mean, T_var_pp);

% Validate NMPC
validation = true;

% Construct houses
A = Household_matlab(true, false, T_set, T_amb, Ts, K, Q, validation);
A = CustomizedParamsA(A);
options_A = nlmpcmoveopt;
options_A.Parameters = A.paramsCell;

B = Household_matlab(false, false, T_set, T_amb, Ts, K, Q, validation);
options_B = nlmpcmoveopt;
options_B.Parameters = B.paramsCell;

C = Household_matlab(false, true, T_set, T_amb, Ts, K, Q, validation);
C = CustomizedParamsC(C);
options_C = nlmpcmoveopt;
options_C.Parameters = C.paramsCell;

%% Initialization

hours_sim = 10 * 3600;
T = hours_sim / Ts;
% T = 2;
max_iter = 100;

% Initial conditions
x_A = [A.T_F_0, A.T_S1_0, A.T_S2_0, A.T_b_0, A.T_S3_0, A.T_R_0];
x_B = [B.T_F_0, B.T_S1_0, B.T_S2_0, B.T_b_0, B.T_S3_0, B.T_R_0]; 
x_C = [C.T_F_0, C.T_S1_0, C.T_S2_0, C.T_b_0, C.T_S3_0, C.T_R_0, C.T_BYP_0]; 

% Manipulated Variables
mv_A_0 = [A.T_F_0, A.T_R_0, 3, 1, 2, 2, 3]; % T_feed_I, T_succ_I, m_F, m_U, m_O, m_succ_I, m_R
mv_B_0 = [B.T_F_0, B.T_R_0, 2, 1, 1, 1, 2];
mv_C_0 = [C.T_F_0, C.T_R_0, 1, 1, 0, 0, 1];


lastmv_A = mv_A_0;
lastmv_B = mv_B_0;
lastmv_C = mv_C_0;

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
rows_plots_x = T + 1;

x = struct();
x.A = zeros(rows_plots_x, A.nx);
x.B = zeros(rows_plots_x, B.nx);
x.C = zeros(rows_plots_x, C.nx);

x.A(1,:) = x_A;
x.B(1,:) = x_B;
x.C(1,:) = x_C;

rows_plots_u = rows_plots_x;

u = struct();
u.A = zeros(rows_plots_u, A.nu_mv);
u.B = zeros(rows_plots_u, B.nu_mv);
u.C = zeros(rows_plots_u, C.nu_mv);

%% Simulation
tic
for t = 1:T

    % Plotting 
    figToPlot = figure;
    set(figToPlot, 'Name', ['Step: ', num2str(t)]);

    h_m = plot(NaN, NaN, '.b-', 'DisplayName', 'Mass flow');
    hold on;
    h_T = plot(NaN, NaN, '.r-', 'DisplayName', 'Temperature');
    legend show;

    xlabel('Iterations', 'Interpreter', 'latex');
    ylabel('$||\Delta T||, ||\Delta m||$', 'Interpreter', 'latex');
    title('Cumulative error of shared variable along all steps and all controllers ')
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

        X_A_shifted = shiftAndRepeatLastRow(X_A);
        
        % A sends to B
        %              m_O_A_A,    m_R_B_A,     T_F_A_A,       T_R_B_A
        md_B(:,1:4) = [MV_A(:,5), MV_A(:,6), X_A_shifted(:,1), MV_A(:,2)];
        
        % B solves
        [mv_B,~,info] = nlmpcmove(B.nlobj, x_B, lastmv_B, [], md_B, options_B);
        
        lastmv_B = mv_B;
        X_B = info.Xopt;
        MV_B = info.MVopt;

        X_B_shifted = shiftAndRepeatLastRow(X_B);
        
        % B sends to A and C
        %              m_O_A_B,   m_R_B_B,   T_F_A_B,   T_R_B_B
        md_A(:,1:4) = [MV_B(:,3), MV_B(:,7), MV_B(:,1), X_B_shifted(:,6)];
        %              m_O_B_B,   m_R_C_B,   T_F_B_B,          T_R_C_B
        md_C(:,1:4) = [MV_B(:,5), MV_B(:,6), X_B_shifted(:,1), MV_B(:,2)];
        
        % C solves
        [mv_C,~,info] = nlmpcmove(C.nlobj, x_C, lastmv_C, [], md_C, options_C); 
        
        lastmv_C = mv_C;
        X_C = info.Xopt;
        MV_C = info.MVopt;

        X_C_shifted = shiftAndRepeatLastRow(X_C);
        
        % C sends to B
        %              m_O_B_C,   m_R_C_C,   T_F_B_C,   T_R_C_C
        md_B(:,5:8) = [MV_C(:,3), MV_C(:,7), MV_C(:,1), X_C_shifted(:,6)];
        
        % Update and Check
        [lambda_AB, lambda_BC, difference_m, difference_T, is_converged] = UpdateMultipliers(X_A_shifted, MV_A, X_B_shifted, MV_B, X_C_shifted, MV_C, md_A, md_C);
        
        md_A(:, 5:8)  = lambda_AB;
        md_B(:, 9:16) = [lambda_AB, lambda_BC];
        md_C(:, 5:8)  = lambda_BC;
        
        % Plotting
        error_m(iteration) = difference_m;
        error_T(iteration) = difference_T;
        
        set(h_m, 'XData', 1:iteration, 'YData', error_m(1:iteration));
        set(h_T, 'XData', 1:iteration, 'YData', error_T(1:iteration));
        drawnow;

    end

    % Heating plant max rate constraints
    md_A(:, 11) = [MV_A(:, 3)];
    md_A(:, 12) = [MV_A(:, 1)];

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
    idx_x = t + 1;
    x.A(idx_x, :) = X_A(2, :);
    x.B(idx_x, :) = X_B(2, :);
    x.C(idx_x, :) = X_C(2, :);

    idx_u = t;
    u.A(idx_u, :) = MV_A(1, :);
    u.B(idx_u, :) = MV_B(1, :);
    u.C(idx_u, :) = MV_C(1, :);

    close;
end
toc

%% Copy last input
u.A(end, :) = u.A(end-1, :);
u.B(end, :) = u.B(end-1, :);
u.C(end, :) = u.C(end-1, :);

%% Tracking Plot
time = linspace(0, T, T+1) * Ts / 60; %min
time_temp = [time(1), time(1:end-1)]; %min

Tamb_vec = Tamb_obj.sinusoidal_Tamb(time_temp*60);

xlimits = [0, time(end)];

temperaturePlot = figure;
set(temperaturePlot, 'Name', 'Tracking');

plot(time, Tamb_vec - 273, ".k-", 'DisplayName', 'Tamb')
hold on
plot(time, Tset_obj.interpolator_Tset(time_temp*60) - 273, "k--", 'DisplayName', 'Tset')
plot(time, x.A(:, 4) - 273, ".b-", 'DisplayName', strcat(A.names.x(4), '^A'))
plot(time, x.B(:, 4) - 273, ".g-", 'DisplayName', strcat(B.names.x(4), '^B'))
plot(time, x.C(:, 4) - 273, ".r-", 'DisplayName', strcat(C.names.x(4), '^C'))

xlabel('Time / min', 'Interpreter', 'latex');
ylabel('Temperature / $^\circ$C', 'Interpreter', 'latex');
xlim(xlimits);
legend('Location', 'best');
clickableLegend
grid on;
box on;
hold off;

%% All temperatures and mass flow rates Plot
% Create a figure
subPlot = figure;
set(subPlot, 'Name', 'All values');

% Define houses and data names
houses = {'A', 'B', 'C'};
housesObj = {A, B, C};

for i = 1:length(houses)
    subplot(2, 3, i);
    hold on;
    houseName = houses{i};
    xData = x.(houseName);
    for j = 1:housesObj{i}.nx
        plot(time, xData(:, j) - 273, 'Marker', '.', 'DisplayName', housesObj{i}.names.x(j));
    end
    uData = u.(houseName);
    for j = 1:2
        plot(time, uData(:, j) - 273, 'Marker', '.', 'DisplayName', housesObj{i}.names.u(j));
    end

    xlim(xlimits);
    ylim([-Inf; Inf]);
    title(['$T_', houseName, '$'], 'Interpreter', 'latex');
    xlabel('Time / min', 'Interpreter', 'latex');
    ylabel('Temperature / $^\circ$C', 'Interpreter', 'latex');
    legend('Location', 'best');
    grid on;
    box on;
    hold off;
    clickableLegend
end

for i = 1:length(houses)
    subplot(2, 3, i+3);
    hold on;
    houseName = houses{i};
    uData = u.(houseName);
    for j = 3:housesObj{i}.nu_mv
        stairs(time, uData(:, j), 'DisplayName', housesObj{i}.names.u(j));
    end

    xlim(xlimits);
    ylim([0; Inf]);
    title(['$\dot{m}_', houseName, '$'], 'Interpreter', 'latex');
    xlabel('Time / min', 'Interpreter', 'latex');
    ylabel('Mass flow rate / kg/s', 'Interpreter', 'latex');
    legend('Location', 'best');
    grid on;
    box on;
    hold off;
    clickableLegend
end

%% Convergence plot
convergencePlot = figure;
set(convergencePlot, 'Name', 'Convergence');

agents = {'{HP}', 'A', 'B', 'C', '{byp}'};

% Feed temperature
subplot(2, 2, 1);
for i = 1:length(houses)
    hold on;
    houseName = houses{i};
    predName = agents{i};
    % Feed
    xData = x.(houseName);
    plot(time, xData(:, 1) - 273, 'Marker', '.', 'DisplayName', strcat(housesObj{i}.names.x(1), "^", houseName));
    % Feed pred,I
    uData = u.(houseName);
    modName = strrep(housesObj{i}.names.u(1), 'pred,I', strcat(predName, ",", houseName));
    plot(time, uData(:, 1) - 273, 'Marker', '.', 'DisplayName', modName);

    xlim(xlimits);
    ylim([-Inf; Inf]);
    title('$T_F$ convergence', 'Interpreter', 'latex');
    xlabel('Time / min', 'Interpreter', 'latex');
    ylabel('Temperature / $^\circ$C', 'Interpreter', 'latex');
    legend('Location', 'best');
    grid on;
    box on;
    hold off;
    clickableLegend
end

% Feed mass flow
subplot(2, 2, 2);
for i = 1:length(houses)
    hold on;
    houseName = houses{i};
    predName = agents{i};
    uData = u.(houseName);
    % Feed = Out pred,I
    modName = strrep(housesObj{i}.names.u(3), 'pred,I', strcat(predName, ",", houseName));
    modName = strrep(modName, '=', strcat("^", houseName, "="));
    stairs(time, uData(:, 3), 'DisplayName', modName);
    % Out I,I
    modName = strrep(housesObj{i}.names.u(5), 'I,I', strcat(houseName, ",", houseName));
    stairs(time, uData(:, 5), 'DisplayName', modName);

    xlim(xlimits);
    ylim([-Inf; Inf]);
    title('$m_F$ convergence', 'Interpreter', 'latex');
    xlabel('Time / min', 'Interpreter', 'latex');
    ylabel('Mass flow rate / kg/s', 'Interpreter', 'latex');
    legend('Location', 'best');
    grid on;
    box on;
    hold off;
    clickableLegend
end

% Return temperature
subplot(2, 2, 3);
for i = 1:length(houses)
    hold on;
    houseName = houses{i};
    succName = agents{i+2};
    % Return I,I
    xData = x.(houseName);
    plot(time, xData(:, 6) - 273, 'Marker', '.', 'DisplayName', strcat(housesObj{i}.names.x(6), "^", houseName));
    % Return succ,I
    uData = u.(houseName);
    modName = strrep(housesObj{i}.names.u(2), 'succ,I', strcat(succName, ",", houseName));
    plot(time, uData(:, 2) - 273, 'Marker', '.', 'DisplayName', modName);

    xlim(xlimits);
    ylim([-Inf; Inf]);
    title('$T_R$ convergence', 'Interpreter', 'latex');
    xlabel('Time / min', 'Interpreter', 'latex');
    ylabel('Temperature / $^\circ$C', 'Interpreter', 'latex');
    legend('Location', 'best');
    grid on;
    box on;
    hold off;
    clickableLegend
end

% Return mass flow
subplot(2, 2, 4);
for i = 1:length(houses)
    hold on;
    houseName = houses{i};
    succName = agents{i+2};
    uData = u.(houseName);
    % Return succ,I
    modName = strrep(housesObj{i}.names.u(6), 'succ,I', strcat(succName, ",", houseName));
    stairs(time, uData(:, 6), 'DisplayName', modName);
    % Return I,I
    modName = strrep(housesObj{i}.names.u(7), 'I,I', strcat(houseName, ",", houseName));
    stairs(time, uData(:, 7), 'DisplayName', modName);

    xlim(xlimits);
    ylim([-Inf; Inf]);
    title('$m_R$ convergence', 'Interpreter', 'latex');
    xlabel('Time / min', 'Interpreter', 'latex');
    ylabel('Mass flow rate / kg/s', 'Interpreter', 'latex');
    legend('Location', 'best');
    grid on;
    box on;
    hold off;
    clickableLegend
end

%% Balance plot
balancePlot = figure;
set(balancePlot, 'Name', 'Balance');

for i = 1:length(houses)
    subplot(1, 3, i);
    hold on;
    predName = agents{i};
    houseName = houses{i};
    succName = agents{i+2};
    uData = u.(houseName);
    % Feed = Out pred,I
    modName = strrep(housesObj{i}.names.u(3), 'pred,I', strcat(predName, ",", houseName));
    modName = strrep(modName, '=', strcat("^", houseName, "="));
    stairs(time, uData(:, 3), 'DisplayName', modName);
    % Sum: Out I,I + U
    modName = strrep(housesObj{i}.names.u(5), 'I,I', strcat(houseName, ",", houseName));
    modName = strcat(modName, '+', housesObj{i}.names.u(4), '^', houseName);
    stairs(time, uData(:, 5)+uData(:, 4), 'DisplayName', modName);

    % Return I,I
    modName = strrep(housesObj{i}.names.u(7), 'I,I', strcat(houseName, ",", houseName));
    stairs(time, uData(:, 7), 'DisplayName', modName);
    % Sum: Return succ,I + U
    modName = strrep(housesObj{i}.names.u(6), 'succ,I', strcat(succName, ",", houseName));
    modName = strcat(modName, '+', housesObj{i}.names.u(4), '^', houseName);
    stairs(time, uData(:, 6)+uData(:, 4), 'DisplayName', modName);
    
    xlim(xlimits);
    ylim([0; Inf]);
    title(['$\dot{m}_', houseName, '$ balance'], 'Interpreter', 'latex');
    xlabel('Time / min', 'Interpreter', 'latex');
    ylabel('Mass flow rate / kg/s', 'Interpreter', 'latex');
    legend('Location', 'best');
    grid on;
    box on;
    hold off;
    clickableLegend
end

%% Power loss plot
QlossFeed = u.A(:,3) .* A.cp_w .* u.A(:,1) ...
          - u.A(:,7) .* A.cp_w .* x.A(:,6);
Qloss = QlossFeed ...
      - A.h_S2 .* A.A_S2 .* (x.A(:,3) - x.A(:,4)) ...
      - B.h_S2 .* B.A_S2 .* (x.B(:,3) - x.B(:,4)) ...
      - C.h_S2 .* C.A_S2 .* (x.C(:,3) - x.C(:,4));

ElossFeed = trapz(time*60, QlossFeed);
Eloss     = trapz(time*60, Qloss);
Eloss / ElossFeed * 100

QlossPlot = figure;
set(QlossPlot, 'Name', 'Power loss');

hold on;
plot(time, Qloss, 'Marker', '.', 'DisplayName', 'DMPC');

xlim(xlimits);
%ylim([0; Inf]);
title('Power Loss', 'Interpreter', 'latex');
xlabel('Time / min', 'Interpreter', 'latex');
ylabel('Power / W', 'Interpreter', 'latex');
legend('Location', 'best');
grid on;
box on;
hold off;
clickableLegend

%% User mass flow rate plot
mUserPlot = figure;
set(mUserPlot, 'Name', 'User mass flow');

hold on;
for i = 1:length(houses)
    houseName = houses{i};
    uData = u.(houseName);
    modName = strcat(housesObj{i}.names.u(4), '^', houseName);
    stairs(time, uData(:, 4), 'DisplayName', modName);
end

xlim(xlimits);
ylim([0; Inf]);
title(['$\dot{m}_', houseName, '$ balance'], 'Interpreter', 'latex');
xlabel('Time / min', 'Interpreter', 'latex');
ylabel('Mass flow rate / kg/s', 'Interpreter', 'latex');
legend('Location', 'best');
grid on;
box on;
hold off;
clickableLegend

%% Save data
save('DMPC_results.mat');

%% Save plots
save_plot = false;

if save_plot
    saveTikzPlot('sbagliato_plot.tex', temperaturePlot);
end

%% Functions
function X_shifted = shiftAndRepeatLastRow(X)
    % This function shifts the rows of X_A down by one position
    % and repeats the last row at the bottom.

    % Shift rows down by 1
    X_shifted = circshift(X, -1, 1);

    % Repeat the last row
    X_shifted(end, :) = X(end, :);
end