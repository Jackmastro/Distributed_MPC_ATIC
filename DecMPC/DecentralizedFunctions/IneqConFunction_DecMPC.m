function cineq = IneqConFunction_DecMPC(~, u, ~, ~, ~)

    m_U = u(1:end-1, 1);
    m_F = u(1:end-1, 3);

    cineq = m_U - m_F;
    
end