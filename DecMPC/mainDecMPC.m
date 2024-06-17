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

% Instiantating household objects 
A = Household_DecMPC(T_set, T_amb, Ts, K, Q, ADRESS, true);
B = Household_DecMPC(T_set, T_amb, Ts, K, Q, ADRESS, true);
C = Household_DecMPC(T_set, T_amb, Ts, K, Q, ADRESS, true);



% %% Simulink Simulation
% % TO DO: Initial conditions 
% 
% % Open
% model = 'Simulator';
% open_system(model);
% 
% % Set the parameters for the Step block
% % set_param();
% 
% % Set simulation parameters
% set_param(model, 'StartTime', '86400', 'StopTime', '', 'Solver', 'ode45');
% 
% % Run the simulation
% simOut = sim(model);
% 
% % Close (without saving changes)
% close_system(model, 0);
