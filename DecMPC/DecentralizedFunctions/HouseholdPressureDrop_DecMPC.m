function m_U_max = HouseholdPressureDrop_DecMPC(household)
      
    m_S1_max = sqrt(household.DeltaP_S1_max * household.rho_w * pi^2 * household.D_S1^5) / (8 * household.f_Darcy * household.L_S1);
    m_S2_max = sqrt(household.DeltaP_S2_max * household.rho_w * pi^2 * household.D_S2^5) / (8 * household.f_Darcy * household.L_S2); 
    m_S3_max = sqrt(household.DeltaP_S2_max * household.rho_w * pi^2 * household.D_S3^5) / (8 * household.f_Darcy * household.L_S3); 
   
    m_U_max = m_S1_max+m_S2_max+m_S3_max;

end