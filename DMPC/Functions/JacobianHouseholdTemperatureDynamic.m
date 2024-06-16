function [J_x_x, J_x_u] = JacobianHouseholdTemperatureDynamic(x, u, household)
    
    % Constants
    rho_w   = household.rho_w;
    cp_w    = household.cp_w;
    V_F     = household.V_F;
    h_F     = household.h_F;
    A_F     = household.A_F;
    V_S1    = household.V_S1;
    h_S1    = household.h_S1;
    A_S1    = household.A_S1;
    V_S2    = household.V_S2;
    h_S2    = household.h_S2;
    A_S2    = household.A_S2;
    V_S3    = household.V_S3;
    h_S3    = household.h_S3;
    A_S3    = household.A_S3;
    V_R     = household.V_R;
    h_R     = household.h_R;
    A_R     = household.A_R;
    V_B     = household.V_B;
    h_B     = household.h_B;
    A_B     = household.A_B;
    C_b     = household.C_b;
    h_b     = household.h_b;
    A_b     = household.A_b;
    is_bypass_house = household.is_bypass_house;
    nx      = household.nx;
    nu      = household.nu;

    % States
    T_F  = x(1);
    T_S1 = x(2);
    T_S2 = x(3);
    T_b  = x(4);
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
    J_x_u = zeros(nx, nu);
    J_x_u(1,1) = m_F / (rho_w * V_F);
    J_x_u(1,3) = (T_F_pred_I - T_F) / (rho_w * V_F);
    J_x_u(2,5) = (T_F - T_S1) / (rho_w * V_S1);
    J_x_u(3,5) = (T_S1 - T_S2) / (rho_w * V_S2);
    J_x_u(5,5) = (T_S2 - T_S3) / (rho_w * V_S3);
    J_x_u(6,2) = m_R_succ_I / (rho_w * V_R);
    J_x_u(6,5) = T_S3 / (rho_w * V_R);
    J_x_u(6,6) = T_R_succ_I / (rho_w * V_R);
    J_x_u(6,7) = - T_R / (rho_w * V_R);

    % Bypass
    if is_bypass_house
        T_B  = x(7);

        J_x_x(7,1) = m_O / (rho_w * V_B);
        J_x_x(7,7) = (- m_R_succ_I * cp_w - h_B * A_B) / (rho_w * cp_w * V_B);

        J_x_u(7,4) = T_F / (rho_w * V_B);
        J_x_u(7,7) = T_S3 / (rho_w * V_B);
    end

end
