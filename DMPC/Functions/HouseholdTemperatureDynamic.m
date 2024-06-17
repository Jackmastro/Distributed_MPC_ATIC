function dxdt = HouseholdTemperatureDynamic(x, u, params)
    
    % Constants
    rho_w   = household.rho_w;%%%%%%%%%%%%%%%%%%TODO cambiare da oggetto a lista parametri
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
    dT_F  = (m_F * cp_w * T_F_pred_I     - m_F * cp_w * T_F     - h_F * A_F * (T_F - household.T_amb))                                           / (rho_w * cp_w * V_F);
    dT_S1 = (m_U * cp_w * T_F            - m_U * cp_w * T_S1    - h_S1 * A_S1 * (T_S1 - household.T_amb))                                        / (rho_w * cp_w * V_S1);
    dT_S2 = (m_U * cp_w * T_S1           - m_U * cp_w * T_S2                                                - h_S2 * A_S2 * (T_S2 - T_b))        / (rho_w * cp_w * V_S2);
    dT_b  = (                                                   - h_b * A_b * (T_b - household.T_amb)       + h_S2 * A_S2 * (T_S2 - T_b))        / C_b;
    dT_S3 = (m_U * cp_w * T_S2           - m_U * cp_w * T_S3    - h_S3 * A_S3 * (T_S3 - household.T_amb))                                        / (rho_w * cp_w * V_S3);
    dT_R  = (m_U * cp_w * T_S3           - m_R * cp_w * T_R     - h_R * A_R * (T_R - household.T_amb)       + m_R_succ_I * cp_w * T_R_succ_I)    / (rho_w * cp_w * V_R);
    
    % Bypass
    if is_bypass_house
        T_B  = x(7);
        dT_B = (m_O * cp_w * T_F - h_B * A_B * (T_B - household.T_amb) - m_O * cp_w * T_R) / (rho_w * cp_w * V_B);
        dxdt = [dT_F; dT_S1; dT_S2; dT_b; dT_S3; dT_R; dT_B];
    else
        dxdt = [dT_F; dT_S1; dT_S2; dT_b; dT_S3; dT_R];
    end

end
