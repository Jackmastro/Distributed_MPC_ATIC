function dxdt = HouseholdTemperatureDynamic(x, u, household)
    
    % Constants
    rho_w   = household.rho_w;
    cp_w    = household.cp_w;
    V_S1    = household.V_S1;
    h_S1    = household.h_S1;
    A_S1    = household.A_S1;
    V_S2    = household.V_S2;
    h_S2    = household.h_S2;
    A_S2    = household.A_S2;
    V_S3    = household.V_S3;
    h_S3    = household.h_S3;
    A_S3    = household.A_S3;
    C_b     = household.C_b;
    h_b     = household.h_b;
    A_b     = household.A_b;

    % States
    T_S1 = x(1);
    T_S2 = x(2);
    T_b  = x(3);
    T_S3 = x(4);
    
    % Inputs
    m_U  = u(1);
    T_F = u(2);

    % System of equations 
    dT_S1 = (m_U * cp_w * T_F            - m_U * cp_w * T_S1    - h_S1 * A_S1 * (T_S1 - household.T_amb))                                        / (rho_w * cp_w * V_S1);
    dT_S2 = (m_U * cp_w * T_S1           - m_U * cp_w * T_S2                                                - h_S2 * A_S2 * (T_S2 - T_b))        / (rho_w * cp_w * V_S2);
    dT_b  = (                                                   - h_b * A_b * (T_b - household.T_amb)       + h_S2 * A_S2 * (T_S2 - T_b))        / C_b;
    dT_S3 = (m_U * cp_w * T_S2           - m_U * cp_w * T_S3    - h_S3 * A_S3 * (T_S3 - household.T_amb))                                        / (rho_w * cp_w * V_S3);

    dxdt = [dT_S1; dT_S2; dT_b; dT_S3];

end
