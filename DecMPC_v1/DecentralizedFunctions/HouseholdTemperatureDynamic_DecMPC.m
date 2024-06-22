function dxdt = HouseholdTemperatureDynamic_DecMPC(x, u, params)

    % disp(x)
    
    % Constants
    rho_w   = params(1);
    cp_w    = params(2);
    V_S1    = params(3);
    h_S1    = params(4);
    A_S1    = params(5);
    V_S2    = params(8);
    h_S2    = params(9);
    A_S2    = params(10);
    h_b     = params(13);
    A_b     = params(14);
    C_b     = params(15);
    V_S3    = params(16);
    h_S3    = params(17);
    A_S3    = params(18);
    T_amb   = params(26);

    % States
    T_S1 = x(1);
    T_S2 = x(2);
    T_b  = x(3);
    T_S3 = x(4);
    
    % Inputs
    m_U  = u(1);
    T_F = u(2);
    % m_F  = u(3);


    % System of equations 
    dT_S1 = (m_U * cp_w * T_F - m_U * cp_w * T_S1 - h_S1 * A_S1 * (T_S1 - T_amb))   / (rho_w * cp_w * V_S1);
    dT_S2 = (m_U * cp_w * T_S1 - m_U * cp_w * T_S2 - h_S2 * A_S2 * (T_S2 - T_b))     / (rho_w * cp_w * V_S2);
    dT_b  = (- h_b * A_b * (T_b - T_amb) + h_S2 * A_S2 * (T_S2 - T_b))              / C_b;
    dT_S3 = (m_U * cp_w * T_S2 - m_U * cp_w * T_S3 - h_S3 * A_S3 * (T_S3 - T_amb))  / (rho_w * cp_w * V_S3);

    dxdt = [dT_S1; dT_S2; dT_b; dT_S3];

end
