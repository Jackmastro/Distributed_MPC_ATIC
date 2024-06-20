clc;
clear;
close all;

%% Names
%Define the name coherently with Simulink
NAME_SIMULATION = 'Simulation';

% Controllers
ADDRESS_CONTROLLERS = strcat(NAME_SIMULATION, '/Controller');

NAME_NMPC_A = 'NMPC_A';
NAME_BUS_NMPC_A = 'BusParamsA';
ADDRESS_NMPC_A = strcat(ADDRESS_CONTROLLERS, '/A/', NAME_NMPC_A);
ADRESS_HOUSE_A = strcat(NAME_SIMULATION, '/Plant/HouseA');

NAME_NMPC_B = 'NMPC_B';
NAME_BUS_NMPC_B = 'BusParamsB';
ADDRESS_NMPC_B = strcat(ADDRESS_CONTROLLERS, '/B/', NAME_NMPC_B);
ADRESS_HOUSE_B = strcat(NAME_SIMULATION, '/Plant/HouseB');

NAME_NMPC_C = 'NMPC_C';
NAME_BUS_NMPC_C = 'BusParamsC';
ADDRESS_NMPC_C = strcat(ADDRESS_CONTROLLERS, '/C/', NAME_NMPC_C);
ADRESS_HOUSE_C = strcat(NAME_SIMULATION, '/Plant/HouseC');

%% Set Network Objects
% Set temperatures
T_set = 350;
T_amb = 273;

% Params of the simulation
Sim_Horizon = '8640';

% Controller hyperparameters 
Ts = 15*60;
K = 4;
Q = 1;
validation = false;


A = Household(true, false, T_set, T_amb, Ts, K, Q, ADDRESS_NMPC_A);
createParameterBus(A.nlobj, A.adressBusParams, NAME_BUS_NMPC_A, {A.params});
InitializeParamInSimulator(ADRESS_HOUSE_A, A); %N.B. set the parameters after having modified the params of A but before launching simulink
if validation
      x0 = ones(A.nx, 1);  % Example initial states
      u0 = ones(A.nu_mv + A.nu_md, 1);
      validateFcns(A.nlobj, x0, u0(1:7)', u0(8:15)', {A.params});
end

B = Household(false, false, T_set, T_amb, Ts, K, Q, ADDRESS_NMPC_B);
createParameterBus(B.nlobj, B.adressBusParams, NAME_BUS_NMPC_B, {B.params});
InitializeParamInSimulator(ADRESS_HOUSE_B, B)
if validation
      x0 = ones(B.nx, 1);  % Example initial states
      u0 = ones(B.nu_mv + B.nu_md, 1);
      validateFcns(B.nlobj, x0, u0(1:7)', u0(8:23)', {B.params});
end

C = Household(false, true, T_set, T_amb, Ts, K, Q, ADDRESS_NMPC_C);
createParameterBus(C.nlobj, C.adressBusParams, NAME_BUS_NMPC_C, {C.params});
InitializeParamInSimulator(ADRESS_HOUSE_C, C)
if validation
      x0 = ones(C.nx, 1);  % Example initial states
      u0 = ones(C.nu_mv + C.nu_md, 1);
      validateFcns(C.nlobj, x0, u0(1:7)', u0(8:15)', {C.params});
end

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
