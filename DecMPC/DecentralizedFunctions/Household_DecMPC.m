classdef Household_DecMPC
    
    % Private household properties 
    properties (Constant)
        
        rho_w = 1; % 1
        cp_w  = 1;
        V_S1  = 1;
        h_S1  = 1;
        A_S1  = 1;
        L_S1  = 1;
        D_S1  = 1;
        V_S2  = 1;
        h_S2  = 1;
        A_S2  = 1; % 10 
        L_S2  = 1;
        D_S2  = 1;
        h_b   = 1;
        A_b   = 1;
        C_b   = 1;
        V_S3  = 1;
        h_S3  = 1;
        A_S3  = 1;
        L_S3  = 1; 
        D_S3  = 1; % 20
        f_Darcy = 0.025;
        DeltaP_S1_max = 4;
        DeltaP_S2_max = 4;
        DeltaP_S3_max = 4; % 24
        
    end
    
    % Public household properties 
    properties 
        % Building set and ambient temperature
        T_set % 25
        T_amb % 26

        % Controller Hyperparameters
        K
        Ts
        Q % 29

        % Modeling 
        nx
        ny
        nu_mv
        nu_md

        % Parameters struct and NMPC object for block in Simulink
        nlobj
        adressBusParams
        validation
        params
    end

    
    methods
        function obj = Household_DecMPC(T_set, T_amb, Ts, K, Q, adressBusParams, validation)
 
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
            
            % Add here all the parameters (public and private) used by mpc
            obj.params = [obj.rho_w;
                          obj.cp_w;
                          obj.V_S1 ;
                          obj.h_S1 ;
                          obj.A_S1 ;
                          obj.L_S1 ;
                          obj.D_S1 ;
                          obj.V_S2 ;
                          obj.h_S2 ;
                          obj.A_S2 ;
                          obj.L_S2 ;
                          obj.D_S2 ;
                          obj.h_b  ;
                          obj.A_b  ;
                          obj.C_b  ;
                          obj.V_S3 ;
                          obj.h_S3 ;
                          obj.A_S3 ;
                          obj.L_S3 ;
                          obj.D_S3 ;
                          obj.f_Darcy;
                          obj.DeltaP_S1_max;
                          obj.DeltaP_S2_max;
                          obj.DeltaP_S3_max;
                          obj.T_set;
                          obj.T_amb;
                          obj.K;
                          obj.Ts;
                          obj.Q;
                          obj.nx;
                          obj.ny;
                          obj.nu_mv;
                          obj.nu_md ];


            % Create NMPC object
            obj.adressBusParams = adressBusParams;
            obj.validation = validation;
            obj.nlobj = obj.createNMPC(); 

        end

        function nlobj = createNMPC(obj)
            % Create NMPC object
            nlobj = nlmpc(obj.nx, obj.ny, 'MV', [1:obj.nu_mv], 'MD', [(1+obj.nu_mv):(1+obj.nu_md)]);

            % NMPC parameters
            nlobj.PredictionHorizon = obj.K; 
            nlobj.Ts = obj.Ts;

            % Prediction model
            nlobj.Model.NumberOfParameters = numel({obj.params});
            nlobj.Model.StateFcn = "HouseholdTemperatureDynamic_DecMPC";
            nlobj.Model.OutputFcn = "HouseholdOutput_DecMPC";

            % Cost
            nlobj.Optimization.CustomCostFcn = "CostFunction_DecMPC";

            % Constraints
            nlobj.Optimization.CustomIneqConFcn = "IneqConFunction_DecMPC";

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
