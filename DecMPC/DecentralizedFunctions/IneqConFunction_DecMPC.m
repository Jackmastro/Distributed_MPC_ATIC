function cineq = IneqConFunction_DecMPC(~, u, ~, ~, household)
    
    m_U = u(:,1); % TODO: check dimensions 

    m_U_max = HouseholdPressureDrop_DecMPC(household);
  
    cineq = m_U_max - m_U;

end