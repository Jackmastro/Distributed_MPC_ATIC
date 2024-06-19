clc;
clear;
close all;

%% Names
%Define the name coherently with Simulink
NAME_SIMULATION = 'Simulation';

% Controllers
ADDRESS_CONTROLLERS = strcat(NAME_SIMULATION, '/Controller/While');

NAME_NMPC_A = 'NMPC_A';
NAME_BUS_NMPC_A = 'BusParamsA';
ADDRESS_NMPC_A = strcat(ADDRESS_CONTROLLERS, '/A/', NAME_NMPC_A);

NAME_NMPC_B = 'NMPC_B';
NAME_BUS_NMPC_B = 'BusParamsB';
ADDRESS_NMPC_B = strcat(ADDRESS_CONTROLLERS, '/B/', NAME_NMPC_B);

NAME_NMPC_C = 'NMPC_C';
NAME_BUS_NMPC_C = 'BusParamsC';
ADDRESS_NMPC_C = strcat(ADDRESS_CONTROLLERS, '/C/', NAME_NMPC_C);

%% Set Network Objects
% Set temperatures
T_set = 350;
T_amb = 273;

% Controller hyperparameters 
Ts = 1;
K = 10;
Q = 1;

A = Household(true, false, T_set, T_amb, Ts, K, Q, ADDRESS_NMPC_A, true);
createParameterBus(A.nlobj, A.adressBusParams, NAME_BUS_NMPC_A, {A.params});

B = Household(false, false, T_set, T_amb, Ts, K, Q, ADDRESS_NMPC_B, true);
% createParameterBus(A.nlobj, A.adressBusParams, NAME_BUS_NMPC_A, {A.params});

C = Household(false, true, T_set, T_amb, Ts, K, Q, ADDRESS_NMPC_C, true);
% createParameterBus(A.nlobj, A.adressBusParams, NAME_BUS_NMPC_A, {A.params});

%% Load and open Simulink
% Get the full path of the currently running script
% if isdeployed
%     % If the code is deployed, use the built-in method
%     scriptFullPath = mfilename('fullpath');
% else
%     % If running in the MATLAB environment, use the editor API
%     scriptFullPath = matlab.desktop.editor.getActiveFilename;
% end
% 
% % Extract the directory part of the path
% [scriptDir, ~, ~] = fileparts(scriptFullPath);
% 
% % Change the current directory to the script's directory
% cd(scriptDir);
% 
% % Display the current directory to confirm the change
% disp(['Current directory changed to: ', scriptDir]);

% % Define the folder containing .mat files
% bus_folder_name = 'LoadBus';
% 
% % Get a list of all .mat files in the folder
% mat_files = dir(fullfile(bus_folder_name, '*.mat'));
% 
% % Load each .mat file
% for k = 1:length(mat_files)
%     mat_file = fullfile(bus_folder_name, mat_files(k).name);
%     load(mat_file);
% end
% 
% % Define and load the simulation model
% simulation_name = 'Simulation';
% % load_system(simulation_name);
% % open_system(simulation_name);
