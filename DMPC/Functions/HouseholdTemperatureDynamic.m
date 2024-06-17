function dxdt = HouseholdTemperatureDynamic(x, u, params)
    
    % Constants
    rho_w   = params(1);
    cp_w    = params(2);
    V_F     = params(3);
    h_F     = params(4);
    A_F     = params(5);
    V_S1    = params(6);
    h_S1    = params(7);
    A_S1    = params(8);
    V_S2    = params(9);
    h_S2    = params(10);
    A_S2    = params(11);
    h_b     = params(12);
    A_b     = params(13);
    C_b     = params(14);
    V_S3    = params(15);
    h_S3    = params(16);
    A_S3    = params(17);
    V_R     = params(18);
    h_R     = params(19);
    A_R     = params(20);
    V_B     = params(21);
    h_B     = params(22);
    A_B     = params(23);

    T_amb = params(25);

    is_bypass_house = params(27);

    % States
    T_F  = x(1);
    T_S1 = x(2);
    T_S2 = x(3);
    T_b  = x(4);
    T_S3 = x(5);
    T_R  = x(6);
    
    % Inputs
    T_F_pred_I = u(1);
    T_R_succ_I = u(2);
    m_F  = u(3);
    m_U  = u(4);
    m_O  = u(5);
    m_R_succ_I = u(6);
    m_R  = u(7);

    % System of equations 
    dT_F  = (m_F * cp_w * T_F_pred_I     - m_F * cp_w * T_F     - h_F * A_F * (T_F - T_amb))                                           / (rho_w * cp_w * V_F);
    dT_S1 = (m_U * cp_w * T_F            - m_U * cp_w * T_S1    - h_S1 * A_S1 * (T_S1 - T_amb))                                        / (rho_w * cp_w * V_S1);
    dT_S2 = (m_U * cp_w * T_S1           - m_U * cp_w * T_S2                                       - h_S2 * A_S2 * (T_S2 - T_b))       / (rho_w * cp_w * V_S2);
    dT_b  = (                                                   - h_b * A_b * (T_b - T_amb)        + h_S2 * A_S2 * (T_S2 - T_b))       / C_b;
    dT_S3 = (m_U * cp_w * T_S2           - m_U * cp_w * T_S3    - h_S3 * A_S3 * (T_S3 - T_amb))                                        / (rho_w * cp_w * V_S3);
    dT_R  = (m_U * cp_w * T_S3           - m_R * cp_w * T_R     - h_R * A_R * (T_R - T_amb)        + m_R_succ_I * cp_w * T_R_succ_I)   / (rho_w * cp_w * V_R);
    
    % Bypass
    if is_bypass_house
        T_B  = x(7);
        dT_B = (m_O * cp_w * T_F - h_B * A_B * (T_B - T_amb) - m_O * cp_w * T_R) / (rho_w * cp_w * V_B);
        dxdt = [dT_F; dT_S1; dT_S2; dT_b; dT_S3; dT_R; dT_B];
    else
        dxdt = [dT_F; dT_S1; dT_S2; dT_b; dT_S3; dT_R];
    end

end
