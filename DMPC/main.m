clc;
clear; 
close all;

%% Set Network Objects
% Set temperatures
T_set = 350;
T_amb = 273;

% Controller hyperparameters 
Ts = 1;
K = 10;
Q = 1;

A = Household(true, false, T_set, T_amb, Ts, K, Q);
B = Household(false, false, T_set, T_amb, Ts, K, Q);
C = Household(false, true, T_set, T_amb, Ts, K, Q);

%% Settings validation
% Define a random initial state and input
x0 = ones(A.nx, 1);  % Example initial states
u0 = ones(A.nu_mv + A.nu_md, 1); 

params = {A};

% Validate functions
validateFcns(A.nlobj, x0, u0(1:7)', u0(8:15)', params);

%% Load and open Simulink
clear 
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
open_system(simulation_name);
