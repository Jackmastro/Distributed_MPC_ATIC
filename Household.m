classdef Household
    
    % Private household properties 
    properties (Constant)
        rho_w = 1;
        cp_w  = 1;
        V_F   = 1;
        h_F   = 1;
        A_F   = 1;
        V_S1  = 1;
        h_S1  = 1;
        A_S1  = 1;
        V_S2  = 1;
        h_S2  = 1;
        A_S2  = 1;
        h_b   = 1;
        A_b   = 1;
        C_b   = 1;
        V_S3  = 1;
        h_S3  = 1;
        A_S3  = 1;
        V_R   = 1;
        h_R   = 1;
        A_R   = 1;
        V_B   = 1;
        h_B   = 1;
        A_B   = 1;
    end
    
    % Public household properties 
    properties 
        % Building set and ambient temperature
        T_set
        T_amb

        % Modeling 
        is_first_house
        is_bypass_house
        nx
        ny
        nu
        
        % Damping weights - Lagrange multipliers 
        delta_m_O_pred
        delta_m_O_succ
        delta_m_R_pred
        delta_m_R_succ

        delta_T_F_pred
        delta_T_F_succ
        delta_T_R_pred
        delta_T_R_succ

        % Step sizes - Lagrange multipliers 
        alfa_m_O_pred
        alfa_m_O_succ
        alfa_m_R_pred
        alfa_m_R_alfa
        alfa_T_F_pred
        alfa_T_F_succ
        alfa_T_R_pred
        alfa_T_R_succ
    end
    
    % Parameters struct for NMPC block in Simulink
    properties
        params
    end
    
    methods

        function obj = Household(is_first_house, is_bypass_house, T_set, T_amb, params)
            
            % Set the first_house and bypass_house properties
            obj.is_first_house = is_first_house;
            obj.is_bypass_house = is_bypass_house;

            % Set modeling dimensions properties 
            if is_bypass_house
                obj.nx = 7;
            else
                obj.nx = 6;
            end

            obj.ny = 1;
            obj.nu = 7;
            
            % Damping weights - Lagrange Multipliers
            obj.delta_m_O_pred = 0;
            obj.delta_m_O_succ = 0;
            obj.delta_m_R_pred = 0;
            obj.delta_m_R_succ = 0;

            obj.delta_T_F_pred = 0;
            obj.delta_T_F_succ = 0;
            obj.delta_T_R_pred = 0;
            obj.delta_T_R_succ = 0;

            % Set temperature values
            obj.T_amb = T_amb;
            obj.T_set = T_set;
            
            % Set structure NMPC parameters
            obj.params.lambda_m_O_pred = params.lambda_m_O_pred;
            obj.params.lambda_m_O_succ = params.lambda_m_O_succ;
            obj.params.lambda_m_R_pred = params.lambda_m_R_pred;
            obj.params.lambda_m_R_succ = params.lambda_m_R_succ;

            obj.params.lambda_T_F_pred = params.lambda_T_F_pred;
            obj.params.lambda_T_F_succ = params.lambda_T_F_succ;
            obj.params.lambda_T_R_pred = params.lambda_T_R_pred;
            obj.params.lambda_T_R_succ = params.lambda_T_R_succ;

            obj.params.m_O_pred_pred = params.m_O_pred_pred;
            obj.params.m_O_I_succ = params.m_O_I_succ;
            obj.params.m_R_succ_succ = params.m_R_succ_succ;
            obj.params.m_R_I_pred = params.m_R_I_pred;

            obj.params.T_F_pred_pred = params.T_F_pred_pred;
            obj.params.T_F_I_succ = params.T_F_I_succ;
            obj.params.T_R_succ_succ = params.T_R_succ_succ;
            obj.params.T_R_I_pred = params.T_R_I_pred;
        end
    end
end
