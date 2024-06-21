function m_U_max = HouseholdPressureDrop_matlab(params)
    
    % Constants
    rho_w           = params(1);
    L_S1            = params(11);
    D_S1            = params(12);
    L_S2            = params(16);
    D_S2            = params(17);
    L_S3            = params(24);
    D_S3            = params(25);
    f_Darcy         = params(36);
    DeltaP_S1_max   = params(37);
    DeltaP_S2_max   = params(38);
    DeltaP_S3_max   = params(39);

    m_S1_max = sqrt(DeltaP_S1_max * rho_w * pi^2 * D_S1^5) / (8 * f_Darcy * L_S1);
    m_S2_max = sqrt(DeltaP_S2_max * rho_w * pi^2 * D_S2^5) / (8 * f_Darcy * L_S2); 
    m_S3_max = sqrt(DeltaP_S3_max * rho_w * pi^2 * D_S3^5) / (8 * f_Darcy * L_S3); 
   
    m_U_max = min([m_S1_max, m_S2_max, m_S3_max]);

end