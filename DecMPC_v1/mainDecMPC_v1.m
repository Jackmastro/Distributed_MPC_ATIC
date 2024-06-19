 clc;
clear; 
%close all;

%% Set Network Objects

%Define the name coherently with Simulink
NAME_SIMULATION = 'Simulator_DecMPC_v1';

ADRESS_HOUSE_A = strcat(NAME_SIMULATION, '/HouseA');
ADRESS_NMPC_A = 'NMPC_A';
NAME_BUS_NMPC_A = 'BusParamsA';

ADRESS_HOUSE_B = strcat(NAME_SIMULATION, '/HouseB');
ADRESS_NMPC_B = 'NMPC_B';
NAME_BUS_NMPC_B = 'BusParamsB';

ADRESS_HOUSE_C = strcat(NAME_SIMULATION, '/HouseC');
ADRESS_NMPC_C = 'NMPC_C';
NAME_BUS_NMPC_C = 'BusParamsC';


% Set temperatures
T_set = 300;
T_amb = 273;


%Tuning values of HEAT_PRODUCED
T_NOMINAL_FEED = 350;
T_FEED_MAX = 370;
T_FEED_MIN = 320;

T_SP_RETURN = 310;      
m_dot_NOMINAL_FEED = 10;
m_dot_NOMINAL_BYP = 0.1 * m_dot_NOMINAL_FEED;
m_dot_FEED_MAX = 20;

K_temp = 0; % TODO: TUNING PER K>0
K_m_dot = 0; 

% Params of the simulation
Sim_Horizon = '86400';

% Controller hyperparameters 
Ts = 60*60;
K = 4;
Q = 100;


% Instiantating household objects
%load("DecMPC/BusA.mat");
A = Household_DecMPC(T_set, T_amb, Ts, K, Q, [NAME_SIMULATION '/' ADRESS_NMPC_A ], true);
createParameterBus(A.nlobj, A.adressBusParams, NAME_BUS_NMPC_A, {A.params});
InitializeParamInSimulator_DecMPC(ADRESS_HOUSE_A, A); %N.B. set the parameters after having modified the params of A but before launching simulink

B = Household_DecMPC(T_set, T_amb, Ts, K, Q, [NAME_SIMULATION '/' ADRESS_NMPC_B ], true);
createParameterBus(B.nlobj, B.adressBusParams, NAME_BUS_NMPC_B, {B.params});
InitializeParamInSimulator_DecMPC(ADRESS_HOUSE_B, B)

C = Household_DecMPC(T_set, T_amb, Ts, K, Q, [NAME_SIMULATION '/' ADRESS_NMPC_C ], true);
createParameterBus(C.nlobj, C.adressBusParams, NAME_BUS_NMPC_C, {C.params});
InitializeParamInSimulator_DecMPC(ADRESS_HOUSE_C, C)






% %% Simulink Simulation
% % TO DO: Initial conditions 
% 
% % Open
open_system(NAME_SIMULATION);
% 
% % Set the parameters for the Step block
% % set_param();
% 
% % Set simulation parameters
set_param(NAME_SIMULATION, 'StartTime', '0', 'StopTime', Sim_Horizon, 'Solver', 'ode45');
% 
% % Run the simulation
simOut = sim(NAME_SIMULATION);
% 
% % Close (without saving changes)
% close_system(model, 0);
