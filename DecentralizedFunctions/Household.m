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

        % Controller Hyperparameters
        K
        Ts
        Q

        % Modeling 
        is_first_house
        is_bypass_house
        nx
        ny
        nu_mv

        % Step sizes - Lagrange multipliers 
        alfa_m_O_pred
        alfa_m_O_succ
        alfa_m_R_pred
        alfa_m_R_alfa
        alfa_T_F_pred
        alfa_T_F_succ
        alfa_T_R_pred
        alfa_T_R_succ

        % Simulink names 
        nmpcBlockPathName
        nmpcBusName
        storageBusName

        % Parameters struct and NMPC object for block in Simulink
        params
        nlobj
        Bus
    end

    
    methods
        function obj = Household(is_first_house, is_bypass_house, T_set, T_amb, Ts, K, Q, nmpcBlockPathName, nmpcBusName, storageBusName)
            
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
            obj.nu_mv = 7; 
           
            % Set temperature values
            obj.T_amb = T_amb;
            obj.T_set = T_set;
            
            % Set controller hyperparameters
            obj.K = K;
            obj.Ts = Ts;
            obj.Q = Q;

            % Simulink names
            obj.nmpcBlockPathName = nmpcBlockPathName;
            obj.nmpcBusName = nmpcBusName;
            obj.storageBusName = storageBusName;

            % Create Bus object
            % obj.Bus = obj.createBus();

            % Create NMPC object
            obj.nlobj = obj.createNMPC();
        end
        
        function nlobj = createNMPC(obj)
            % Create NMPC object
            nlobj = nlmpc(obj.nx, obj.ny, 'MV', [1:obj.nu_mv]);

            % NMPC parameters
            nlobj.PredictionHorizon = obj.K; 
            nlobj.Ts = obj.Ts;

            % Prediction model
            nlobj.Model.StateFcn = @(x, u, params) HouseholdTemperatureDynamic(x, u, obj);
            nlobj.Model.OutputFcn = @(x, u, params) HouseholdOutput(x, u, obj);
            
            % Cost
            nlobj.Optimization.CustomCostFcn = @(x, u, e, data, params) CostFunction(x, u, e, data, obj);

            % Constraints
            nlobj.Optimization.CustomEqConFcn = @(x, u, data, params) EqConFunction(x, u, data, obj);

            % State & Manipulated Variable constraints
            for i = 1:obj.nx
                nlobj.States(i).Min = 0;
            end

            for i = 1:obj.nu_mv
                nlobj.ManipulatedVariables(i).Min = 0;
            end
        end
    end
end
