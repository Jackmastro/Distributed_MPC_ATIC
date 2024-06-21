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
T_set = 350;
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

% Initial conditions
x_A = [A.T_F_0, A.T_S1_0, A.T_S2_0, A.T_S3_0, A.T_b_0, A.T_R_0];
x_B = [B.T_F_0, B.T_S1_0, B.T_S2_0, B.T_S3_0, B.T_b_0, B.T_R_0, B.T_BYP_0]; 
x_C = [C.T_F_0, C.T_S1_0, C.T_S2_0, C.T_S3_0, C.T_b_0, C.T_R_0]; 

% Manipulated Variables
mv_0 = [300, 300, 2, 1, 1, 1, 2];
lastmv_A = mv_0;
lastmv_B = mv_0;
lastmv_C = mv_0;

% Measured Disturbances
md_A = zeros(A.K+1, A.nu_md);
md_B = zeros(B.K+1, B.nu_md);
md_C = zeros(C.K+1, C.nu_md);

%% Simulation

T = 86400;
x = zeros(T, A.nx+B.nx+C.nx);
u = zeros(T, 5);

for t = 1:T
    
    % While loop - ADMM
    is_converged = false;

    while ~is_converged
        
        % A solves
        [mv_A,~,info] = nlmpcmove(A.nlobj, x_A, lastmv_A, [], md_A, options_A); 
        
        lastmv_A = mv_A;
         X_A = info.Xopt;
         MV_A = info.MVopt;
         T_b_A = info.Yopt;

         % A sends to B 
         md_B(:,1:4) = [MV_A(:,5), MV_A(:,6), X_A(:,1), MV_A(:,2)];
         
         % B solves
         [mv_B,~,info] = nlmpcmove(B.nlobj, x_B, lastmv_B, [], md_B, options_B); 
         
         lastmv_B = mv_B;
         X_B = info.Xopt;
         MV_B = info.MVopt;
         T_b_B = info.Yopt;

         % B sends to A and C 
         md_A(:,1:4) = [MV_B(:,3), MV_B(:,7), X_B(:,6), MV_B(:,1)];
         md_C(:,1:4) = [MV_B(:,5), MV_B(:,6), X_B(:,1), MV_B(:,2)];

         % C solves 
         [mv_C,~,info] = nlmpcmove(C.nlobj, x_C, lastmv_C, [], md_C, options_C); 
         
         lastmv_C = mv_C;
         X_C = info.Xopt;
         MV_C = info.MVopt;
         T_b_C = info.Yopt;

         % C sends to B
         md_B(:,5:8) = [MV_C(:,3), MV_C(:,7), X_C(:,6), MV_C(:,1)];

         % Update and Check
         [lambda_AB, lambda_BC, is_converged] = UpdateMultipliers(X_A, MV_A, X_B, MV_B, X_C, MV_C, md_A, md_C);
         
         md_A(5:8) = lambda_AB;
         md_B(9:16) = [lambda_AB, lambda_BC];
         md_C(5:8) = lambda_BC;

    end
    
    x = [x_A(2,:), x_B(2,:), x_C(2,:)];
    u = [MV_A(1,1), MV_A(1,3), MV_A(1,4), MV_B(1,4), MV_C(1,4)];

end
% Live plot

%% Save data
