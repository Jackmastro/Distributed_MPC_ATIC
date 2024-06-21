function cineq = IneqConFunction_matlab(~, u, ~, ~, params)

    m_U = u(1:end-1, 4);

    m_U_max = HouseholdPressureDrop_matlab(params) * ones(size(m_U));
  
    cineq = m_U - m_U_max;
end