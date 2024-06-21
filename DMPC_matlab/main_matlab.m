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

B = Household_matlab(false, false, T_set, T_amb, Ts, K, Q, validation);

C = Household_matlab(false, true, T_set, T_amb, Ts, K, Q, validation);

%% Initial conditions
%% Initial conditions + T_ref (+ T_amb)

x0_A = ones(A.nx);
x_A = x0_A;

mv_0 = ones(A.nu);
lastmv_A = mv_0;

% INITIALIZE md_A,B,C

%% For loop of simulated day
for t = 1:T

    % While loop - ADMM

    options_A = nlmpcmoveopt;
    options_A.Parameters = {A.params};

    while true
        
        % A solves
        [mv,opt,info] = nlmpcmove(A.nlobj, x_A, lastmv_A, ref_A(t:A.K), md_A, options_A); 

         X_A = info.Xopt;
         MV_A = info.MVopt;
         T_b_A = info.Yopt;

         % A sends to B 
         md_B = [X_A(:,1), MV_A(:,2), MV_A(:,5), MV_A(:,6)];
         
         % B solves
         [mv,opt,info] = nlmpcmove(B.nlobj, x_B, lastmv_B, ref_B(t:B.K), md_B, options_B); 

% While loop - ADMM
         X_B = info.Xopt;
         MV_B = info.MVopt;
         T_b_B = info.Yopt;

         % B sends to A and C 
         md_A = [X_B(:,6), MV_B(:,1), MV_B(:,3), MV_B(:,7)];
         md_C = [X_B(:,1), MV_B(:,2), MV_B(:,5), MV_B(:,6)];

         % C solves 
         [mv,opt,info] = nlmpcmove(C.nlobj, x_C, lastmv_C, ref_C(t:C.K), md_C, options_C); 

         X_C = info.Xopt;
         MV_C = info.MVopt;
         T_b_C = info.Yopt;

         % C sends to B
         md_B = [X_C(:,6), MV_C(:,1), MV_C(:,3), MV_C(:,7)];

         % Update and Check !!! check indexing !!!

    end

end
% Live plot

%% Save data
