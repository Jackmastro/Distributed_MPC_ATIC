function [tol_condition_satisfied, B_diff] = fcn

global A_storage
global B_storage
global C_storage

persistent difference
if isempty(difference)
    difference = struct();
end

%% A-B Lagrange Multiplier Update  

A_storage.md_seq.m_O_B_A = A_storage.md_seq.m_O_B_A + 


%% B-C Lagrange Multiplier Update




%% Condition check 
if sum(difference.B.m_out_pred_I) <= TOL
    tol_condition_satisfied = true;
else
    tol_condition_satisfied = false;
end