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

%% For loop of simulated day

% While loop - ADMM

% Live plot

%% Save data
