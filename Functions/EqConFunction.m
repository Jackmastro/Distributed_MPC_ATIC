function ceq = EqConFunction(~, u, ~, ~)
    
    % Inputs
%     T_F_pred_I = u(1);
%     T_R_succ_I = u(2);
    m_F  = u(3);
    m_U  = u(4);
    m_O  = u(5);
    m_R_succ_I = u(6);
    m_R  = u(7);

    ceq = [m_F - (m_U + m_O) ; m_R - (m_U + m_R_succ_I)]; 

end