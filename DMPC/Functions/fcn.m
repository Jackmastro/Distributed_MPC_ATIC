function [tol_condition_satisfied] = fcn

global A_storage
global B_storage
global C_storage

persistent difference
if isempty(difference)
    difference = struct();
end

%%
tol_condition = 1;

%% A-B Lagrange Multiplier Update  

% lambda_AB_m_O
A_storage.md_seq.lambda_m_O_B_A = A_storage.md_seq.lambda_m_O_B_A + A.alfa_m_O_succ * (A_storage.mv_seq.m_O_A_A - A_storage.md_seq.m_O_A_B);
B_storage.md_seq.lambda_m_O_A_B = B_storage.md_seq.lambda_m_O_A_B + B.alfa_m_O_pred * (B_storage.md_seq.m_O_A_A - B_storage.mv_seq.m_F_B_B);
% lambda_storage.lambda_AB_m_O = lambda_storage.lambda_AB_m_O + A/B/..alfa.m_O * (A_storage.mv_seq.m_O_A_A - A_storage.mv_seq.m_O_B_B)

if any(A_storage.md_seq.lambda_m_O_B_A ~= B_storage.md_seq.lambda_m_O_A_B)
    error('The updated lambdas are not equal.');
end

difference.m_O_AB = norm((A_storage.mv_seq.m_O_A_A - A_storage.md_seq.m_O_A_B));

% lambda_AB_T_F
A_storage.md_seq.lambda_T_F_B_A = A_storage.md_seq.lambda_T_F_B_A + A.alfa_T_F_succ * (A_storage.mv_seq.T_F_A_A - A_storage.md_seq.T_F_A_B);
B_storage.md_seq.lambda_T_F_A_B = B_storage.md_seq.lambda_T_F_A_B + B.alfa_T_F_pred * (B_storage.md_seq.T_F_A_A - B_storage.mv_seq.T_F_A_B);

if any(A_storage.md_seq.lambda_T_F_B_A ~= B_storage.md_seq.lambda_T_F_A_B)
    error('The updated lambdas are not equal.');
end

difference.T_F_AB = norm((A_storage.mv_seq.T_F_A_A - A_storage.md_seq.T_F_A_B));

% lambda_AB_m_R
A_storage.md_seq.lambda_m_R_B_A = A_storage.md_seq.lambda_m_R_B_A + A.alfa_m_R_succ * (A_storage.mv_seq.m_R_B_A - A_storage.md_seq.m_R_B_B);
B_storage.md_seq.lambda_m_R_A_B = B_storage.md_seq.lambda_m_R_A_B + B.alfa_m_R_pred * (B_storage.md_seq.m_R_B_A - B_storage.mv_seq.m_R_B_B);

if any(A_storage.md_seq.lambda_m_R_B_A  ~= B_storage.md_seq.lambda_m_R_A_B)
    error('The updated lambdas are not equal.');
end

difference.m_R_AB = norm((A_storage.mv_seq.m_R_B_A - A_storage.md_seq.m_R_B_B));

% lambda_AB_T_R
A_storage.md_seq.lambda_T_R_B_A = A_storage.md_seq.lambda_T_R_B_A + A.alfa_T_R_succ * (A_storage.mv_seq.T_R_B_A - A_storage.md_seq.T_R_B_B);
B_storage.md_seq.lambda_T_R_A_B = B_storage.md_seq.lambda_T_R_A_B + B.alfa_T_R_pred * (B_storage.md_seq.T_R_B_A - B_storage.mv_seq.T_R_B_B);

if any(A_storage.md_seq.lambda_T_R_B_A  ~= B_storage.md_seq.lambda_T_R_A_B)
    error('The updated lambdas are not equal.');
end

difference.T_R_AB = norm((A_storage.mv_seq.T_R_B_A - A_storage.md_seq.T_R_B_B));

%% B-C Lagrange Multiplier Update

% lambda_BC_m_O
B_storage.md_seq.lambda_m_O_C_B = A_storage.md_seq.lambda_m_O_C_B + B.alfa_m_O_succ * (B_storage.mv_seq.m_O_B_B - B_storage.md_seq.m_O_B_C);
C_storage.md_seq.lambda_m_O_B_C = B_storage.md_seq.lambda_m_O_B_C + C.alfa_m_O_pred * (C_storage.md_seq.m_O_B_B - C_storage.mv_seq.m_F_C_C);
% lambda_storage.lambda_AB_m_O = lambda_storage.lambda_AB_m_O + A/B/..alfa.m_O * (A_storage.mv_seq.m_O_A_A - A_storage.mv_seq.m_O_B_B)

if any(B_storage.md_seq.lambda_m_O_C_B  ~= C_storage.md_seq.lambda_m_O_B_C)
    error('The updated lambdas are not equal.');
end

difference.m_F_BC = norm((B_storage.mv_seq.m_O_B_B - B_storage.md_seq.m_O_B_C));

% lambda_CB_T_F
B_storage.md_seq.lambda_T_F_C_B = B_storage.md_seq.lambda_T_F_C_B + B.alfa_T_F_succ * (B_storage.mv_seq.T_F_B_B - B_storage.md_seq.T_F_B_C);
C_storage.md_seq.lambda_T_F_B_C = C_storage.md_seq.lambda_T_F_B_C + C.alfa_T_F_pred * (C_storage.md_seq.T_F_B_B - C_storage.mv_seq.T_F_B_C);

if any(B_storage.md_seq.lambda_T_F_C_B  ~= C_storage.md_seq.lambda_T_F_B_C)
    error('The updated lambdas are not equal.');
end

difference.T_F_BC = norm((B_storage.mv_seq.T_F_B_B - B_storage.md_seq.T_F_B_C));

% lambda_CB_m_R
B_storage.md_seq.lambda_m_R_C_B = B_storage.md_seq.lambda_m_R_C_B + B.alfa_m_R_succ * (B_storage.mv_seq.m_R_C_B - B_storage.md_seq.m_R_C_C);
C_storage.md_seq.lambda_m_R_B_C = C_storage.md_seq.lambda_m_R_B_C + C.alfa_m_R_pred * (C_storage.md_seq.m_R_C_B - C_storage.mv_seq.m_R_C_C);

if any(B_storage.md_seq.lambda_m_R_C_B  ~= C_storage.md_seq.lambda_m_R_B_C)
    error('The updated lambdas are not equal.');
end

difference.m_R_BC = norm((B_storage.mv_seq.m_R_C_B - B_storage.md_seq.m_R_C_C));

% lambda_CB_T_R
B_storage.md_seq.lambda_T_R_C_B = B_storage.md_seq.lambda_T_R_C_B + B.alfa_T_R_succ * (B_storage.mv_seq.T_R_C_B - B_storage.md_seq.T_R_C_C);
C_storage.md_seq.lambda_T_R_B_C = C_storage.md_seq.lambda_T_R_B_C + C.alfa_T_R_pred * (C_storage.md_seq.T_R_C_B - C_storage.mv_seq.T_R_C_C);

if any(B_storage.md_seq.lambda_T_R_C_B  ~= C_storage.md_seq.lambda_T_R_B_C)
    error('The updated lambdas are not equal.');
end

difference.m_R_BC = norm((B_storage.mv_seq.T_R_C_B - B_storage.md_seq.T_R_C_C));

%% Condition check 

norm_sum = 0;
fields = fieldnames(difference);
for i = 1:numel(fields)
    norm_sum = norm_sum + difference.(fields{i});
end

if norm_sum <= tol_condition
    tol_condition_satisfied = true;
else
    tol_condition_satisfied = false;
end