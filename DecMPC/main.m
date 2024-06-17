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
A = Household_DecMPC(T_set, T_amb, Ts, K, Q);
B = Household_DecMPC(T_set, T_amb, Ts, K, Q);
C = Household_DecMPC(T_set, T_amb, Ts, K, Q);

mc = metaclass(A);

%% Initialize an array to hold the values of params of A
paramsA = [];


% Loop through each property and check if it is constant
for i = 1:length(mc.Properties)
    prop = mc.Properties{i};
    disp(prop)
    if strcmp(prop.GetAccess, 'public') && prop.Constant
        % Access the constant property value using the class name
        value = A.(prop.Name);
        % Append the value to the params array
        paramsA = [paramsA, value];
    end
    if not(strcmp(prop.Name, 'nlobj'))
      prop = mc.Properties{i};
      value = A.(prop.Name);
      % Append the value to the paramsA array
      paramsA = [paramsA, value]; 
    end
end
paramsA = {paramsA(1:length(paramsA))};

nameControllerA = ['Simulator_DecMPC_v0/NMPC_A'];
createParameterBus(A.nlobj,nameControllerA,'parasMPC_A',paramsA);


% % Display the params array
% disp('Constant properties values:');
% disp(params);

% %% Settings validation
ValidationFunction_DecMPC(A, true)
% ValidationFunction_DecMPC(B, false)
% ValidationFunction_DecMPC(C, false)

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
