classdef Household_DecMPC
    
    % Public household properties 
    properties
        rho_w 
        cp_w  
        L_F 
        D_F 
        L_R 
        D_R 
        L_BYP
        D_BYP  
        L_S1 
        D_S1 
        L_S2 
        D_S2 
        L_S3 
        D_S3 
        h_S1 
        h_S2 
        h_S3 
        h_b 
        h_F 
        h_R 
        A_b 
        C_b 
        V_S1
        A_S1 
        V_S2 
        A_S2 
        V_S3 
        A_S3 
        V_R 
        A_R 
        V_F 
        A_F 
        f_Darcy 
        DeltaP_S1_max 
        DeltaP_S2_max 
        DeltaP_S3_max  
        T_F_0
        T_S1_0
        T_S2_0
        T_S3_0
        T_b_0
        T_R_0

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
            obj.nu_md = 2;

            % Set default parameters
            obj.rho_w = 971;
            obj.cp_w  = 4179;
              
            obj.L_F = 40;
            obj.D_F = 0.4;
            obj.L_R = 40;
            obj.D_R = 0.4;
            obj.L_BYP = 3;
            obj.D_BYP = 0.1;
              
            obj.L_S1 = 5;
            obj.D_S1 = 0.1;
            obj.L_S2 = 50;
            obj.D_S2 = 0.05;
            obj.L_S3 = 5;
            obj.D_S3 = 0.1;
      
            obj.h_S1  = 1.5;
            obj.h_S2  = 1.5;
            obj.h_S3  = 1.5;
            obj.h_b = 1.5;
              
            obj.h_F = 1.5;
            obj.h_R = 1.5;
      
      
            obj.A_b = 500;
            obj.C_b = 3*1000000;
	      
            obj.V_S1  = pi/4*obj.D_S1^2*obj.L_S1;
            obj.A_S1  = pi*obj.D_S1*obj.L_S1;
            obj.V_S2  = pi/4*obj.D_S2^2*obj.L_S2;
            obj.A_S2  = pi*obj.D_S2*obj.L_S2;
            obj.V_S3  = pi/4*obj.D_S3^2*obj.L_S3;
            obj.A_S3  = pi*obj.D_S3*obj.L_S3;
      
            obj.V_R  = pi/4*obj.D_R^2*obj.L_R;
            obj.A_R  = pi*obj.D_R*obj.L_R;
            obj.V_F  = pi/4*obj.D_F^2*obj.L_F;
            obj.A_F  = pi*obj.D_F*obj.L_F;
      
            obj.f_Darcy = 0.025;
            obj.DeltaP_S1_max = 10*100000;
            obj.DeltaP_S2_max = 10*100000;
            obj.DeltaP_S3_max = 10*100000;

            obj.T_F_0 = 283;
            obj.T_S1_0 = 283;
            obj.T_S2_0 = 283;
            obj.T_S3_0 = 283;
            obj.T_b_0 = 286;
            obj.T_R_0 = 283;
                 
            % Set temperature values
            obj.T_amb = T_amb;
            obj.T_set = T_set;
            
            % Set controller hyperparameters
            obj.K = K;
            obj.Ts = Ts;
            obj.Q = Q;
            
            % Add here all the parameters (public and private) used by mpc
            obj.params = [obj.rho_w; %1
                          obj.cp_w;
                          obj.V_S1 ;
                          obj.h_S1 ;
                          obj.A_S1 ; %5
                          obj.L_S1 ;
                          obj.D_S1 ;
                          obj.V_S2 ;
                          obj.h_S2 ;
                          obj.A_S2 ; %10
                          obj.L_S2 ;
                          obj.D_S2 ;
                          obj.h_b  ;
                          obj.A_b  ;
                          obj.C_b  ;%15
                          obj.V_S3 ;
                          obj.h_S3 ;
                          obj.A_S3 ;
                          obj.L_S3 ;
                          obj.D_S3 ;%20
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
