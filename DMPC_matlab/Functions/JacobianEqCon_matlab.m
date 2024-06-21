function [J_eq_x, J_eq_u] = JacobianEqCon_matlab(x, u, ~, data, params)

    % Constants
    is_bypass_house = params(49);

    K = data.PredictionHorizon;
    nx = data.NumOfStates;
    nu_mv = length(data.MVIndex);

    if is_bypass_house
        num_of_constraints = 4;
    else
        num_of_constraints = 2;
    end
    nc = num_of_constraints * K;

    % Inputs
    T_F_pred_I  = u(1);
    T_R_succ_I  = u(2);
    m_F         = u(3);
    m_U         = u(4);
    m_O         = u(5);
    m_R_succ_I  = u(6);
    m_R         = u(7);

    % State Jacobian
    J_eq_x = zeros(K, nx, nc);

    % Input Jacobian
    J_eq_u = zeros(K, nu_mv, nc);

    % Bypass
    if is_bypass_house
        T_B  = x(7);

        J_eq_x(7,1) = m_O / (rho_w * V_B);
        J_eq_x(7,7) = (- m_R_succ_I * cp_w - h_B * A_B) / (rho_w * cp_w * V_B);

        J_eq_u(7,5) = T_F / (rho_w * V_B);
        J_eq_u(7,6) = - T_B / (rho_w * V_B);
    end

end
