clc;
clear; 
%close all;

%% Set Network Objects

%Define the name coherently with Simulink
NAME_SIMULATOR = 'Simulator_DecMPC_v0';

ADRESS_HOUSE_A = 'HouseA';
ADRESS_NMPC_A = 'NMPC_A';
NAME_BUS_NMPC_A = 'BusParamsA';

ADRESS_HOUSE_B = 'HouseB';
ADRESS_NMPC_B = 'NMPC_B';
NAME_BUS_NMPC_B = 'BusParamsB';

ADRESS_HOUSE_C = 'HouseC';
ADRESS_NMPC_C = 'NMPC_C';
NAME_BUS_NMPC_C = 'BusParamsC';


% Set temperatures
T_set = 300;
T_amb = 273;

% Params of the simulation
Sim_Horizon = '50000';

% Controller hyperparameters 
Ts = 15*60;
K = 4;
Q = 1;


% Instiantating household objects
%load("DecMPC/BusA.mat");
A = Household_DecMPC(T_set, T_amb, Ts, K, Q, [NAME_SIMULATOR '/' ADRESS_NMPC_A ], true);
createParameterBus(A.nlobj, A.adressBusParams, NAME_BUS_NMPC_A, {A.params});
InitializeParamInSimulator(NAME_SIMULATOR, ADRESS_HOUSE_A, A); %N.B. set the parameters after having modified the params of A but before launching simulink


B = Household_DecMPC(T_set, T_amb, Ts, K, Q, [NAME_SIMULATOR '/' ADRESS_NMPC_B ], true);
createParameterBus(A.nlobj, A.adressBusParams, NAME_BUS_NMPC_B, {A.params});
InitializeParamInSimulator(NAME_SIMULATOR, ADRESS_HOUSE_B, B)

C = Household_DecMPC(T_set, T_amb, Ts, K, Q, [NAME_SIMULATOR '/' ADRESS_NMPC_C ], true);
createParameterBus(A.nlobj, A.adressBusParams, NAME_BUS_NMPC_C, {A.params});
InitializeParamInSimulator(NAME_SIMULATOR, ADRESS_HOUSE_C, C)






% %% Simulink Simulation
% % TO DO: Initial conditions 
% 
% % Open
open_system(NAME_SIMULATOR);
% 
% % Set the parameters for the Step block
% % set_param();
% 
% % Set simulation parameters
set_param(NAME_SIMULATOR, 'StartTime', '0', 'StopTime', Sim_Horizon, 'Solver', 'ode45');
% 
% % Run the simulation
simOut = sim(NAME_SIMULATOR);
% 
% % Close (without saving changes)
% close_system(model, 0);
