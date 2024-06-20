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
validation = false;

A = Household(true, false, T_set, T_amb, Ts, K, Q, ADDRESS_NMPC_A);
if validation
      x0 = ones(A.nx, 1);  % Example initial states
      u0 = ones(A.nu_mv + A.nu_md, 1);
      validateFcns(A.nlobj, x0, u0(1:7)', u0(8:15)', {A.params});
end

B = Household(false, false, T_set, T_amb, Ts, K, Q, ADDRESS_NMPC_B);
if validation
      x0 = ones(B.nx, 1);  % Example initial states
      u0 = ones(B.nu_mv + B.nu_md, 1);
      validateFcns(B.nlobj, x0, u0(1:7)', u0(8:23)', {B.params});
end

C = Household(false, true, T_set, T_amb, Ts, K, Q, ADDRESS_NMPC_C);
if validation
      x0 = ones(C.nx, 1);  % Example initial states
      u0 = ones(C.nu_mv + C.nu_md, 1);
      validateFcns(C.nlobj, x0, u0(1:7)', u0(8:15)', {C.params});
end

%% Initial conditions

%% For loop of simulated day

% While loop - ADMM

% Live plot

%% Save data
