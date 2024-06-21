function cineq = IneqConFunction_DecMPC(~, u, ~, ~, params)
    p = params(27); % prediction horizon
    m_U = u(1:p-1,1);
    m_F = u(1:p-1,3);

    m_U_max = HouseholdPressureDrop_DecMPC(params) * ones(p-1,1); 
  
    cineq = [m_U - m_U_max; m_U - m_F];
end