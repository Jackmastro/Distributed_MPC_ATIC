clc;
clear;
close all;

%% Change directory
% Get the full path of the currently running script
if isdeployed
    % If the code is deployed, use the built-in method
    scriptFullPath = mfilename('fullpath');
else
    % If running in the MATLAB environment, use the editor API
    scriptFullPath = matlab.desktop.editor.getActiveFilename;
end

% Extract the directory part of the path
[scriptDir, ~, ~] = fileparts(scriptFullPath);

% Change the current directory to the script's directory
cd(scriptDir);

% Display the current directory to confirm the change
disp(['Current directory changed to: ', scriptDir]);

%% Load
load("TemperatureSP_Dec.mat")

%% Set Network Objects

%Define the name coherently with Simulink
NAME_SIMULATION = 'Simulator_DecMPC';

ADRESS_HOUSE_A = strcat(NAME_SIMULATION, '/HouseA');
ADRESS_NMPC_A = 'NMPC_A';
NAME_BUS_NMPC_A = 'BusParamsA';

ADRESS_HOUSE_B = strcat(NAME_SIMULATION, '/HouseB');
ADRESS_NMPC_B = 'NMPC_B';
NAME_BUS_NMPC_B = 'BusParamsB';

ADRESS_HOUSE_C = strcat(NAME_SIMULATION, '/HouseC'); 
ADRESS_NMPC_C = 'NMPC_C';
NAME_BUS_NMPC_C = 'BusParamsC';

% open_system(NAME_SIMULATION);

% Controller hyperparameters 
Ts = 15*60;
K = 4;
SimHorizon = 10 * 3600;
t = [0:Ts:(SimHorizon+K*Ts+1)];

% Set temperatures
T_set                  = 273 + 18;
T_amb                  = 273 - 5;
% T_amb_average          = 273;
% T_amb_day_excursion_pp = 10; % peak to peak temperature excursion
% 
% T_amb_signal = T_amb_day_excursion_pp*sin(pi/86400*t)+T_amb_average;
% T_ref_signal = [(273+19)*ones(1,round(1*3600/Ts)) , (273+23)*ones(1, round(17*3600/Ts )), (273+19)*ones(1, round(6*3600/Ts)), (273+19)*ones(1, K+1) ] % we use as SetPoint a square wave from 19°c during eco phase (midnight -> 6am and 6pm->midnight) and 23 during comfort phase (6am ->6pm)

%Tuning values of HEAT_PRODUCED
T_NOMINAL_FEED      = 273 + 75;
T_NOMINAL_FEED_0    = 273 + 75;
T_FEED_MAX          = 273 + 80; 
T_FEED_MIN          = 273 + 30;
T_SP_RETURN         = 273 + 55;

m_dot_NOMINAL_FEED  = 15;
m_dot_FEED_MAX      = 15;
m_dot_NOMINAL_BYP   = 0.1 * m_dot_NOMINAL_FEED;
m_dot_NOMINAL_BYP_0 = m_dot_NOMINAL_BYP;

K_temp = 0.5; % TODO: TUNING PER K>0
K_m_dot = 5; 

%pause

%% Instiantating household objects

A = Household_DecMPC(T_set, T_amb, Ts, K,[NAME_SIMULATION '/' ADRESS_NMPC_A ], true);
A.T_b_0 = 273 + 15;
createParameterBus(A.nlobj, A.adressBusParams, NAME_BUS_NMPC_A, {A.params});
InitializeParamInSimulator_DecMPC(ADRESS_HOUSE_A, A); %N.B. set the parameters after having modified the params of A but before launching simulink

B = Household_DecMPC(T_set, T_amb, Ts, K, [NAME_SIMULATION '/' ADRESS_NMPC_B ], true);
B.T_b_0 = 273 + 16;
createParameterBus(B.nlobj, B.adressBusParams, NAME_BUS_NMPC_B, {B.params});
InitializeParamInSimulator_DecMPC(ADRESS_HOUSE_B, B)

C = Household_DecMPC(T_set, T_amb, Ts, K, [NAME_SIMULATION '/' ADRESS_NMPC_C ], true);
C.T_b_0 = 273 + 17;
createParameterBus(C.nlobj, C.adressBusParams, NAME_BUS_NMPC_C, {C.params});
InitializeParamInSimulator_DecMPC(ADRESS_HOUSE_C, C);      

%% Simulink Simulation

set_param(NAME_SIMULATION, 'StartTime', '0', 'StopTime', num2str(SimHorizon), 'Solver', 'ode45');

% Run the simulation
outSim = sim(NAME_SIMULATION);

%% Tracking Plot
trackingPlot = figure;
set(trackingPlot, 'Name', 'Tracking');

hold on
yline(T_set - 273, "k--", 'DisplayName', 'Tset')
plot(outSim.A.TemperaturesA.T_b.Time / 60, outSim.A.TemperaturesA.T_b.Data - 273, ".b-", 'DisplayName', strcat(A.names.x(4), '^A'))
plot(outSim.B.TemperaturesB.T_b.Time / 60, outSim.B.TemperaturesB.T_b.Data - 273, ".g-", 'DisplayName', strcat(B.names.x(4), '^B'))
plot(outSim.C.TemperaturesC.T_b.Time / 60, outSim.C.TemperaturesC.T_b.Data - 273, ".r-", 'DisplayName', strcat(C.names.x(4), '^C'))

xlabel('Time / min', 'Interpreter', 'latex');
ylabel('Temperature / $^\circ$C', 'Interpreter', 'latex');
ylim([-Inf, 19])
legend('Location', 'best');
clickableLegend
grid on;
box on;
hold off;

%% User mass flow rate plot
mUserPlot = figure;
set(mUserPlot, 'Name', 'User mass flow');

hold on
yline(A.nlobj.MV(1).Max, "k", 'DisplayName', 'm_U^{max}')
stairs(outSim.MassFlowUsers.m_U_A.Time / 60, outSim.MassFlowUsers.m_U_A.Data, ".b-", 'DisplayName', strcat(A.names.u(4), '^A'))
stairs(outSim.MassFlowUsers.m_U_B.Time / 60, outSim.MassFlowUsers.m_U_B.Data, ".g-", 'DisplayName', strcat(B.names.u(4), '^B'))
stairs(outSim.MassFlowUsers.m_U_C.Time / 60, outSim.MassFlowUsers.m_U_C.Data, ".r-", 'DisplayName', strcat(C.names.u(4), '^C'))

xlabel('Time / min', 'Interpreter', 'latex');
ylabel('Mass flow rate / kg/s', 'Interpreter', 'latex');
legend('Location', 'best');
clickableLegend
grid on;
box on;
hold off;

%% Power loss plot
time = outSim.HP.m_dot_O.Time;

QlossFeed = outSim.HP.m_dot_O.Data .* A.cp_w .* outSim.HP.T_O.Data ...
          - outSim.HP.m_dot_O.Data .* A.cp_w .* outSim.HP.T_R.Data;
Qloss = QlossFeed ...
      - A.h_S2 .* A.A_S2 .* (outSim.A.TemperaturesA.T_S2.Data - outSim.A.TemperaturesA.T_b.Data) ...
      - B.h_S2 .* B.A_S2 .* (outSim.B.TemperaturesB.T_S2.Data - outSim.B.TemperaturesB.T_b.Data) ...
      - C.h_S2 .* C.A_S2 .* (outSim.C.TemperaturesC.T_S2.Data - outSim.C.TemperaturesC.T_b.Data);

ElossFeed = trapz(time, QlossFeed);
Eloss     = trapz(time, Qloss);
Eloss / ElossFeed * 100

QlossPlot = figure;
set(QlossPlot, 'Name', 'Power loss');

hold on;
plot(time, Qloss, 'Marker', '.', 'DisplayName', 'DecMPC');
title('Power Loss', 'Interpreter', 'latex');
xlabel('Time / min', 'Interpreter', 'latex');
ylabel('Power / W', 'Interpreter', 'latex');
legend('Location', 'best');
grid on;
box on;
hold off;
clickableLegend

%% Save data
save_data = false;

if save_data
    save('DecMPC_results.mat');
end

%% Save plots
save_plot = false;

if save_plot
    saveTikzPlot('DecMPC_tracking_plot_Tset_fix2.tex', trackingPlot);
    saveTikzPlot('DecMPC_m_user_plot_Tset_fix2.tex', mUserPlot);
end

