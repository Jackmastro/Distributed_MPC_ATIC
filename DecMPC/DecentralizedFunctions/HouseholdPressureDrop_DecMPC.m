function DeltaP_U = HouseholdPressureDrop_DecMPC(u, household)

    m_U = u(1);
      
    DeltaP_S1= 8 * household.f_Darcy * household.L_S1 * m_U^2 / (household.rho_w * pi^2 * household.D_S1^5);
    DeltaP_S2= 8 * household.f_Darcy * household.L_S2 * m_U^2 / (household.rho_w * pi^2 * household.D_S2^5); 
    DeltaP_S3= 8 * household.f_Darcy * household.L_S3 * m_U^2 / (household.rho_w * pi^2 * household.D_S3^5); 
   
    DeltaP_U = DeltaP_S1+DeltaP_S2+DeltaP_S3;

end