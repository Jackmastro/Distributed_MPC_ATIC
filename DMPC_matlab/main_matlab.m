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
% Set temperatures
T_set = 273 + 22;
T_amb = 273;

% Controller hyperparameters
Ts = 15*60;
K = 4;
Q = 1;

validation = true;

A = Household_matlab(true, false, T_set, T_amb, Ts, K, Q, validation);
options_A = nlmpcmoveopt;
options_A.Parameters = A.paramsCell;

B = Household_matlab(false, false, T_set, T_amb, Ts, K, Q, validation);
options_B = nlmpcmoveopt;
options_B.Parameters = B.paramsCell;

C = Household_matlab(false, true, T_set, T_amb, Ts, K, Q, validation);
options_C = nlmpcmoveopt;
options_C.Parameters = C.paramsCell;

%% Initializations

T = 2;
max_iter = 20;

% Initial conditions
x_A = [A.T_F_0, A.T_S1_0, A.T_S2_0, A.T_b_0, A.T_S3_0, A.T_R_0];
x_B = [B.T_F_0, B.T_S1_0, B.T_S2_0, B.T_b_0, B.T_S3_0, B.T_R_0]; 
x_C = [C.T_F_0, C.T_S1_0, C.T_S2_0, C.T_b_0, C.T_S3_0, C.T_R_0, C.T_BYP_0]; 

% Manipulated Variables
mv_0 = [273+70, 273+30, 2, 1, 1, 1, 2];
lastmv_A = mv_0;
lastmv_B = mv_0;
lastmv_C = mv_0;

% Measured Disturbances
md_A = zeros(A.K+1, A.nu_md);
md_B = zeros(B.K+1, B.nu_md);
md_C = zeros(C.K+1, C.nu_md);

% For Plots
save_plot = false;

x = struct(); % TODO ADD NAMES OF THE COLUMNS (DIRECTLY IN HOUSEHOLD)
x.A = zeros(T*K+1, A.nx);
x.B = zeros(T*K+1, B.nx);
x.C = zeros(T*K+1, C.nx);

x.A(1,:) = x_A;
x.B(1,:) = x_B;
x.C(1,:) = x_C;

u = struct();
u.A = zeros(T*K+1, A.nu_mv);
u.B = zeros(T*K+1, B.nu_mv);
u.C = zeros(T*K+1, C.nu_mv);

u.A(1,:) = lastmv_A;
u.B(1,:) = lastmv_B;
u.C(1,:) = lastmv_C;

%% Simulation
for t = 1:T

    % Plotting 
    fprintf('Simulation time step: %.2f\n', t);

    figToPlot = figure;

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
        fprintf('m error: %.2f\n', difference_m);
        fprintf('T error: %.2f\n', difference_T);
        
        error_m(iteration) = difference_m;
        error_T(iteration) = difference_T;
        
        set(h_m, 'XData', 1:iteration, 'YData', error_m(1:iteration));
        set(h_T, 'XData', 1:iteration, 'YData', error_T(1:iteration));
        drawnow;

    end

    % Update states
    x_A = X_A(end, :);
    x_B = X_B(end, :);
    x_C = X_C(end, :);

    % Save trajectories
    idx = (t-1)*K+2;
    x.A(idx:idx+(K-1), :) = X_A(2:end, :);
    x.B(idx:idx+(K-1), :) = X_B(2:end, :);
    x.C(idx:idx+(K-1), :) = X_C(2:end, :);

    u.A(idx:idx+(K-1), :) = MV_A(1:end-1, :);
    u.B(idx:idx+(K-1), :) = MV_B(1:end-1, :);
    u.C(idx:idx+(K-1), :) = MV_C(1:end-1, :);

end

%% Plot
time = linspace(1, T*K+1, T*K+1) * Ts / 60; %min

temperaturePlot = figure;

% TODO LEGEND FROM NAMES
% CLICKABLE LEGEND FROM BA
plot(time, x.A(:, 4))
xlabel('Time / s', 'Interpreter', 'latex');
ylabel('$T$', 'Interpreter', 'latex');
grid on;
hold on;

%% Save plots

if save_plot
    saveTikzPlot('convergence_plot.tex', temperaturePlot, 'height', '\figureheight', 'width', '\figurewidth');
end