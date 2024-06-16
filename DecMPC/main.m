clc;
clear; 
close all;

%%
sim_name = 'Simulation';
% open_system(sim_name)
controller_name = 'Controller';
while_name = 'While';

%% Set Network Objects
% Set temperatures
T_set = 350;
T_amb = 273;

% Controller hyperparameters 
Ts = 1;
K = 10;
Q = 1;

nmpcBlockPathName = strcat(sim_name, '/', controller_name, '/', while_name, '/A', '/A_NMPC');
nmpcBusName = 'nlmpcAparams';
storageBusName = 'storageA';
A = Household(true, false, T_set, T_amb, Ts, K, Q, nmpcBlockPathName, nmpcBusName, storageBusName);

%% Settings validation
% Define a random initial state and input
x0 = [1; 0; 0; 0; 0; 0]; 
mv0 = [0; 0; 0; 0; 0; 0; 0];

PROVA = A.params;

% Validation
paramList = {A.params};
validateFcns(A.nlobj, x0, mv0, [], paramList);