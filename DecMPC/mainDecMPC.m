clc;
clear; 
%close all;

%% Set Network Objects
% Set temperatures
T_set = 350;
T_amb = 273;

% Controller hyperparameters 
Ts = 1;
K = 10;
Q = 1;


% Instiantating household objects
%load("DecMPC/BusA.mat");
A = Household_DecMPC(T_set, T_amb, Ts, K, Q, 'Simulator_DecMPC_v0/NMPC_A', true);
createParameterBus(A.nlobj, A.adressBusParams, 'BusParamsA', {[1.0,2.0,3.0]'})

% B = Household_DecMPC(T_set, T_amb, Ts, K, Q, ADRESS, true);
% C = Household_DecMPC(T_set, T_amb, Ts, K, Q, ADRESS, true);



% %% Simulink Simulation
% % TO DO: Initial conditions 
% 
% % Open
model = 'Simulator_DecMPC_v0';
open_system(model);
% 
% % Set the parameters for the Step block
% % set_param();
% 
% % Set simulation parameters
set_param(model, 'StartTime', '0', 'StopTime', '86400', 'Solver', 'ode45');
% 
% % Run the simulation
simOut = sim(model);
% 
% % Close (without saving changes)
% close_system(model, 0);
