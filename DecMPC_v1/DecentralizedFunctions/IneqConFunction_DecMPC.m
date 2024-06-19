function cineq = IneqConFunction_DecMPC(~, u, ~, ~, params)

    m_U = u(:,1); 
    m_F = u(:,3);

    m_U_max =  HouseholdPressureDrop_DecMPC(params); % da trasformare in vettore
  
    cineq = [m_U - m_U_max; m_U - m_F];  


end