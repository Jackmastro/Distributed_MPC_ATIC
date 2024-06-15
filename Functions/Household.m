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
        nu

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

    methods (Static)
        function bus = createBus()

            % Define bus elements for params
            elems(1) = Simulink.BusElement;
            elems(1).Name = 'mv';
            elems(1).Description = 'T_F_pred_I = u(1); T_R_succ_I = u(2); m_F  = u(3); m_U  = u(4); m_O  = u(5); m_R_succ_I = u(6); m_R  = u(7);';

            elems(2) = Simulink.BusElement;
            elems(2).Name = 'x_seq';
            elems(2).Description = 'T_F = x(1); T_S1 = x(2); T_S2 = x(3); T_b = x(4); T_S3 = x(5); T_R = x(6);';

            elems(3) = Simulink.BusElement;
            elems(3).Name = 'mv_seq';
            elems(3).Description = 'T_F_pred_I = u(1); T_R_succ_I = u(2); m_F  = u(3); m_U  = u(4); m_O  = u(5); m_R_succ_I = u(6); m_R  = u(7);';

            elems(4) = Simulink.BusElement;
            elems(4).Name = 'ref';

            elems(5) = Simulink.BusElement;
            elems(5).Name = 'last_mv';

            elems(6) = Simulink.BusElement;
            elems(6).Name = 'alfa';
        
            elems(7) = Simulink.BusElement;
            elems(7).Name = 'params';

            bus = Simulink.Bus;
            bus.Elements = elems;
        end
    end
    
    methods

        function obj = Household(is_first_house, is_bypass_house, T_set, T_amb, Ts, K, Q, params, nmpcBlockPathName, nmpcBusName, storageBusName)
            
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
           
            % Set temperature values
            obj.T_amb = T_amb;
            obj.T_set = T_set;
            
            % Set controller hyperparameters
            obj.K = K;
            obj.Ts = Ts;
            obj.Q = Q;

            % Set structure parameters for NMPC block in Simulink
            % Dual Variable 
            obj.params.lambda_m_O_pred = params.lambda_m_O_pred;
            obj.params.lambda_m_O_succ = params.lambda_m_O_succ;
            obj.params.lambda_m_R_pred = params.lambda_m_R_pred;
            obj.params.lambda_m_R_succ = params.lambda_m_R_succ;

            obj.params.lambda_T_F_pred = params.lambda_T_F_pred;
            obj.params.lambda_T_F_succ = params.lambda_T_F_succ;
            obj.params.lambda_T_R_pred = params.lambda_T_R_pred;
            obj.params.lambda_T_R_succ = params.lambda_T_R_succ;
            
            % Damping Weights 
            obj.params.delta_m_O_pred = 0;
            obj.params.delta_m_O_succ = 0;
            obj.params.delta_m_R_pred = 0;
            obj.params.delta_m_R_succ = 0;

            obj.params.delta_T_F_pred = 0;
            obj.params.delta_T_F_succ = 0;
            obj.params.delta_T_R_pred = 0;
            obj.params.delta_T_R_succ = 0;

            % Sharing informations 
            obj.params.m_O_pred_pred = params.m_O_pred_pred;
            obj.params.m_O_I_succ = params.m_O_I_succ;
            obj.params.m_R_succ_succ = params.m_R_succ_succ;
            obj.params.m_R_I_pred = params.m_R_I_pred;

            obj.params.T_F_pred_pred = params.T_F_pred_pred;
            obj.params.T_F_I_succ = params.T_F_I_succ;
            obj.params.T_R_succ_succ = params.T_R_succ_succ;
            obj.params.T_R_I_pred = params.T_R_I_pred;

            % Simulink names
            obj.nmpcBlockPathName = nmpcBlockPathName;
            obj.nmpcBusName = nmpcBusName;
            obj.storageBusName = storageBusName;

            % Create NMPC object
            obj.nlobj = obj.createNMPC();

            % Create Bus object
            obj.Bus = obj.createBus();
        end
        
        function nlobj = createNMPC(obj)
            % Create NMPC object
            nlobj = nlmpc(obj.nx, obj.ny, obj.nu);

            % NMPC parameters
            nlobj.PredictionHorizon = obj.K; 
            nlobj.Ts = obj.Ts;

            % Prediction model
            nlobj.Model.StateFcn = @(x, u, params) HouseholdTemperatureDynamic(x, u, obj);
            nlobj.Model.OutputFcn = @(x, u, params) HouseholdOutput(x, u, obj);
            

            % NMPC parameter Bus
            nlobj.Model.NumberOfParameters = 1;
            createParameterBus(nlobj, obj.nmpcBlockPathName, obj.nmpcBusName, {obj.params});

            % Cost
            nlobj.Optimization.CustomCostFcn = @(x, u, e, data, params) CostFunction(x, u, e, data, obj);

            % Constraints
            nlobj.Optimization.CustomEqConFcn = @(x, u, data, params) EqConFunction(x, u, data, obj);

            % State & Manipulated Variable constraints
            for i = 1:obj.nx
                nlobj.States(i).Min = 0;
            end

            for i = 1:obj.nu
                nlobj.ManipulatedVariables(i).Min = 0;
            end
        end
    end
end
