classdef Household_DecMPC
    
    % Private household properties 
    properties (Constant)
        
        rho_w = 1;
        cp_w  = 1;
        V_S1  = 1;
        h_S1  = 1;
        A_S1  = 1;
        L_S1  = 1;
        D_S1  = 1;
        V_S2  = 1;
        h_S2  = 1;
        A_S2  = 1;
        L_S2  = 1;
        D_S2  = 1;
        h_b   = 1;
        A_b   = 1;
        C_b   = 1;
        V_S3  = 1;
        h_S3  = 1;
        A_S3  = 1;
        L_S3  = 1; 
        D_S3  = 1;
        f_Darcy = 0.025;
        DeltaP_S1_max = 4;
        DeltaP_S2_max = 4;
        DeltaP_S3_max = 4;
        
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
        nx
        ny
        nu_mv
        nu_md

        % Parameters struct and NMPC object for block in Simulink
        nlobj
    end

    
    methods
        function obj = Household_DecMPC(T_set, T_amb, Ts, K, Q)
 
            % Set modeling dimensions properties 
            obj.nx = 4;
            obj.ny = 1;
            obj.nu_mv = 1;
            obj.nu_md = 1;
           
            % Set temperature values
            obj.T_amb = T_amb;
            obj.T_set = T_set;
            
            % Set controller hyperparameters
            obj.K = K;
            obj.Ts = Ts;
            obj.Q = Q;

            % Create NMPC object
            obj.nlobj = obj.createNMPC();
        end
        
        function nlobj = createNMPC(obj)
            % Create NMPC object
            nlobj = nlmpc(obj.nx, obj.ny, 'MV', [1:obj.nu_mv], 'MD', [(1+obj.nu_mv):(1+obj.nu_md)]);

            % NMPC parameters
            nlobj.PredictionHorizon = obj.K; 
            nlobj.Ts = obj.Ts;

            % Prediction model
            nlobj.Model.StateFcn = @(x, u, params) HouseholdTemperatureDynamic_DecMPC(x, u, params);
            nlobj.Model.OutputFcn = @(x, u, params) HouseholdOutput_DecMPC(x, u, params);
            nlobj.Model.NumberOfParameters = 33;
            
            % Cost
            nlobj.Optimization.CustomCostFcn = @(x, u, e, data, params) CostFunction_DecMPC(x, u, e, data, params);

            % Constraints
            nlobj.Optimization.CustomIneqConFcn = @(x, u, data, e, params) IneqConFunction_DecMPC(x, u, e, data, params);

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
