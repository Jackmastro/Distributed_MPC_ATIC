function [J_x_x, J_x_u] = JacobianState_matlab(x, u, params)
    
    % Constants
    rho_w   = params(1);
    cp_w    = params(2);
    V_F     = params(3);
    h_F     = params(4);
    A_F     = params(5);
    V_S1    = params(8);
    h_S1    = params(9);
    A_S1    = params(10);
    V_S2    = params(13);
    h_S2    = params(14);
    A_S2    = params(15);
    h_b     = params(18);
    A_b     = params(19);
    C_b     = params(20);
    V_S3    = params(21);
    h_S3    = params(22);
    A_S3    = params(23);
    V_R     = params(26);
    h_R     = params(27);
    A_R     = params(28);
    V_B     = params(31);
    h_B     = params(32);
    A_B     = params(33);

    nx     = params(45);
    nu_mv  = params(47);

    is_bypass_house = params(49);

    % States
    T_F  = x(1);
    T_S1 = x(2);
    T_S2 = x(3);
    % T_b  = x(4);
    T_S3 = x(5);
    T_R  = x(6);
    
    % Inputs
    T_F_pred_I  = u(1);
    T_R_succ_I  = u(2);
    m_F         = u(3);
    m_U         = u(4);
    m_O         = u(5);
    m_R_succ_I  = u(6);
    m_R         = u(7);

    % State Jacobian
    J_x_x = zeros(nx, nx);
    J_x_x(1,1) = (- m_F * cp_w - h_F * A_F) / (rho_w * cp_w * V_F);
    J_x_x(2,1) = m_U / (rho_w * V_S1);
    J_x_x(2,2) = (- m_U * cp_w - h_S1 * A_S1) / (rho_w * cp_w * V_S1);
    J_x_x(3,2) = m_U / (rho_w * V_S2);
    J_x_x(3,3) = (- m_U * cp_w - h_S2 * A_S2) / (rho_w * cp_w * V_S2);
    J_x_x(3,4) = (h_S2 * A_S2) / (rho_w * cp_w * V_S2);
    J_x_x(4,3) = (h_S2 * A_S2) / C_b;
    J_x_x(4,4) = (- h_b * A_b - h_S2 * A_S2) / C_b;
    J_x_x(5,3) = m_U / (rho_w * V_S3);
    J_x_x(5,5) = (- m_U * cp_w - h_S3 * A_S3) / (rho_w * cp_w * V_S3);
    J_x_x(6,5) = m_U / (rho_w * V_R);
    J_x_x(6,6) = (- m_R * cp_w - h_R * A_R) / (rho_w * cp_w * V_R);

    % Input Jacobian
    J_x_u = zeros(nx, nu_mv);
    J_x_u(1,1) = m_F / (rho_w * V_F);
    J_x_u(1,3) = (T_F_pred_I - T_F) / (rho_w * V_F);
    J_x_u(2,4) = (T_F - T_S1) / (rho_w * V_S1);
    J_x_u(3,4) = (T_S1 - T_S2) / (rho_w * V_S2);
    J_x_u(5,4) = (T_S2 - T_S3) / (rho_w * V_S3);
    J_x_u(6,2) = m_R_succ_I / (rho_w * V_R);
    J_x_u(6,4) = T_S3 / (rho_w * V_R);
    J_x_u(6,6) = T_R_succ_I / (rho_w * V_R);
    J_x_u(6,7) = - T_R / (rho_w * V_R);

    % Bypass
    if is_bypass_house
        T_B  = x(7);

        J_x_x(7,1) = m_O / (rho_w * V_B);
        J_x_x(7,7) = (- m_R_succ_I * cp_w - h_B * A_B) / (rho_w * cp_w * V_B);

        J_x_u(7,5) = T_F / (rho_w * V_B);
        J_x_u(7,6) = - T_B / (rho_w * V_B);
    end
end
