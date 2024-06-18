clc;
clear;
close all;

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

%% Set Network Objects
% Set temperatures
T_set = 350;
T_amb = 273;

% Controller hyperparameters 
Ts = 1;
K = 10;
Q = 1;

houses_address_path = 'Simulation/Controller/While';
nmpc_path_A = strcat(houses_address_path, '/A/A_NMPC');
A = Household(true, false, T_set, T_amb, Ts, K, Q, nmpc_path_A, true);

nmpc_path_B = strcat(houses_address_path, '/B/B_NMPC');
B = Household(false, false, T_set, T_amb, Ts, K, Q, nmpc_path_B, true);

nmpc_path_C = strcat(houses_address_path, '/C/C_NMPC');
C = Household(false, true, T_set, T_amb, Ts, K, Q, nmpc_path_C, true);

%% Load and open Simulink

% Define the folder containing .mat files
bus_folder_name = 'LoadBus';

% Get a list of all .mat files in the folder
mat_files = dir(fullfile(bus_folder_name, '*.mat'));

% Load each .mat file
for k = 1:length(mat_files)
    mat_file = fullfile(bus_folder_name, mat_files(k).name);
    load(mat_file);
end

% Define and load the simulation model
simulation_name = 'Simulation';
% load_system(simulation_name);
% open_system(simulation_name);
