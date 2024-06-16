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


A = Household_DecMPC(T_set, T_amb, Ts, K, Q);

%% Settings validation
% Define a random initial state and input
x0 = [1; 1; 1; 1];
u0 = [2,1];

params = {A};

% Validate functions
validateFcns(A.nlobj, x0, u0(1), u0(2), params);