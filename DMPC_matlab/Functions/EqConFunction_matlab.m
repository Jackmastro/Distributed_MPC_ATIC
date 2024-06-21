function ceq = EqConFunction_matlab(x, u, ~, params)
    % disp("equality")
    % size(x)
    % size(u)

    is_bypass_house = params(49);

    % Inputs
    % T_F_pred_I = u(1:end-1, 1);
    T_R_succ_I = u(1:end-1, 2);
    m_F        = u(1:end-1, 3);
    m_U        = u(1:end-1, 4);
    m_O        = u(1:end-1, 5);
    m_R_succ_I = u(1:end-1, 6);
    m_R        = u(1:end-1, 7);

    % Constraints
    ceq = [
        m_F - (m_U + m_O);
        m_R - (m_U + m_R_succ_I)
    ];
    
    if is_bypass_house
        % States
        T_B  = x(2:end, 7);

        ceq = [
            ceq;
            m_R_succ_I - m_O;
            T_R_succ_I - T_B
        ];
    end

end