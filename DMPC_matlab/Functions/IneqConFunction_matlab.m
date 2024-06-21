function cineq = IneqConFunction_matlab(~, u, ~, data, params)

    K = data.PredictionHorizon;
    m_U = u(1:K,1);

    m_U_max = HouseholdPressureDrop_matlab(params) * ones(K,1);
  
    cineq = m_U - m_U_max;
end