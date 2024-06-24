function cineq = IneqConFunction_matlab(~, u, ~, ~, params)
    
    is_first_house  = params(50);
    m_dot_F_HP_MaxRate = params(68);
    m_dot_F_HP_MinRate = params(69);
    T_F_HP_MaxRate = params(70);
    T_F_HP_MinRate = params(71);
    

    if is_first_house
        % Manipulated Variables
        m_F = u(1, 3);
        T_F_pred_I = u(1, 1);
        % Measured Distrubances
        m_F_past = u(1, 18);
        T_F_past = u(1, 19);
        
        cineq = [m_F - m_F_past - m_dot_F_HP_MaxRate; - m_F + m_F_past + m_dot_F_HP_MinRate; T_F_pred_I - T_F_past - T_F_HP_MaxRate; - T_F_pred_I + T_F_past + T_F_HP_MinRate];
    else
        cineq = [0];
    end
    
end