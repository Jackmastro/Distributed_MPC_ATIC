function ceq = EqConFunction_matlab(x, u, ~, params)

    is_bypass_house = params(49);
    
    % States
    T_B  = x(7);

    % Inputs
    T_F_pred_I = u(1);
    m_F  = u(3);
    m_U  = u(4);
    m_O  = u(5);
    m_R_succ_I = u(6);
    m_R  = u(7);

    if is_bypass_house
        ceq = [m_F - (m_U + m_O) ; m_R - (m_U + m_R_succ_I); m_R_succ_I - m_O; T_F_pred_I - T_B]; 
    else
        ceq = [m_F - (m_U + m_O) ; m_R - (m_U + m_R_succ_I)]; 
    end

end