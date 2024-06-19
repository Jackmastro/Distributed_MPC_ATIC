clear
clc
close all

K = 10;

% Measured Disturbances
md_names = { ...
    'm_O_I_succ',     ...
    'm_R_succ_succ',  ...
    'T_F_I_succ',     ...
    'T_R_succ_succ',  ...
    'lambda_m_O_succ', ...
    'lambda_m_R_succ', ...
    'lambda_T_F_succ', ...
    'lambda_T_R_succ'  ...
};

% Create bus elements
Bus_md_seq_A = Simulink.BusElement.empty(length(md_names), 0);
for i = 1:length(md_names)
    Bus_md_seq_A(i) = Simulink.BusElement;
    Bus_md_seq_A(i).Name = md_names{i};
    Bus_md_seq_A(i).Dimensions = [K+1, 1];
    Bus_md_seq_A(i).DataType = 'double';
    Bus_md_seq_A(i).Complexity = 'real';
end

% Create the bus object
NMPC_A_output = Simulink.Bus;
NMPC_A_output.Elements = Bus_md_seq_A;

% Assign the bus object to a variable in the base workspace
assignin('base', 'NMPC_A_output', NMPC_A_output);

% Example usage in a Simulink model
% set_param('model/block', 'OutDataTypeStr', 'Bus: NMPC_A_output');
