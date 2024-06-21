clc;
clear; 
%close all;

load("TemperatureSP_Dec.mat")
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

% Controller hyperparameters 
Ts = 60*60;
K = 10;
Q = 1000;
SimHorizon = 86400;
t = [0:Ts:(SimHorizon+K*Ts+1)];

% Set temperatures
T_set = 300;
T_amb = 273;
T_amb_average = 273;
T_amb_day_excursion_pp = 10; %peak to peak temperature excursion

T_amb_signal = T_amb_day_excursion_pp*sin(pi/86400*t)+T_amb_average
% T_ref_signal = [(273+19)*ones(1,round(1*3600/Ts)) , (273+23)*ones(1, round(17*3600/Ts )), (273+19)*ones(1, round(6*3600/Ts)), (273+19)*ones(1, K+1) ] % we use as SetPoint a square wave from 19°c during eco phase (midnight -> 6am and 6pm->midnight) and 23 during comfort phase (6am ->6pm)

%Tuning values of HEAT_PRODUCED
T_NOMINAL_FEED = 350;
T_FEED_MAX =  370;
T_FEED_MIN = 320;

T_SP_RETURN = 310;      
m_dot_NOMINAL_FEED = 30;
m_dot_NOMINAL_BYP = 0.1 *  m_dot_NOMINAL_FEED;
m_dot_FEED_MAX = 20;

K_temp = 0; % TODO: TUNING PER K>0
K_m_dot = 0; 


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
set_param(NAME_SIMULATION, 'StartTime', '0', 'StopTime', num2str(SimHorizon), 'Solver', 'ode45');
% 
% % Run the simulation
simOut = sim(NAME_SIMULATION);
% 
% % Close (without saving changes)
% close_system(model, 0);
