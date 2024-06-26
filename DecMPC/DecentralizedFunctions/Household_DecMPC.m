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
        h_BYP
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
        T_BYP_0  
        m_dot_U_0 

        % Building set and ambient temperature
        T_set 
        T_amb

        % Controller Hyperparameters
        K
        Ts

        names

        % Modeling 
        nx
        ny
        nu_mv
        nu_md

        Q_disc 
        Q_S1
        Q_S3
        R_U

        % Parameters struct and NMPC object for block in Simulink
        nlobj
        adressBusParams
        validation
        params

    end

    
    methods
        function obj = Household_DecMPC(T_set, T_amb, Ts, K, adressBusParams, validation)
 
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
            obj.D_S2 = 0.07;
            obj.L_S3 = 5;
            obj.D_S3 = 0.1;
      
            obj.h_S1  = 1.5;
            obj.h_S2  = 100;
            obj.h_S3  = 1.5;
            obj.h_b = 10;
              
            obj.h_F = 1.5;
            obj.h_R = 1.5;
            obj.h_BYP = 1;
      
            obj.A_b = 200;
            obj.C_b = 5*1e7;
	      
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
            obj.DeltaP_S1_max = 4*1e5; % 4 bar
            obj.DeltaP_S2_max = 4*1e5;
            obj.DeltaP_S3_max = 4*1e5;

            obj.T_F_0   = 273 + 50;
            obj.T_S1_0  = 273 + 50;
            obj.T_S2_0  = 273 + 50;
            obj.T_S3_0  = 273 + 50;
            obj.T_b_0   = 273 + 17;
            obj.T_R_0   = 273 + 50;
            obj.T_BYP_0 = 273 + 50;
            obj.m_dot_U_0 = 5;

            % Set names of variables for plots
            obj = obj.setVarNames();
                 
            % Set temperature values
            obj.T_amb = T_amb;
            obj.T_set = T_set;
            
            % Set controller hyperparameters
            obj.K = K;
            obj.Ts = Ts;

            obj.Q_disc = 11;
            obj.Q_S1 = 0.0015;
            obj.Q_S3 = 0.0015;
            obj.R_U  = 0.03;
            
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
                          obj.T_set; %25
                          obj.T_amb;
                          obj.K;
                          obj.Ts;
                          obj.Q_disc;
                          obj.nx; %30
                          obj.ny;
                          obj.nu_mv;
                          obj.nu_md;
                          obj.Q_S1;
                          obj.Q_S3; %35
                          obj.R_U];


            % Create NMPC object
            obj.adressBusParams = adressBusParams;
            obj.validation = validation;
            obj.nlobj = obj.createNMPC(); 

        end

%%%%%%%%% Helper functions

        function obj = setVarNames(obj)
            % if obj.is_bypass_house
            obj.names.x = ["T_F", "T_{S1}", "T_{S2}", "T_b", "T_{S3}", "T_R", "T_B"];
            % else
            %     obj.names.x = ["T_F", "T_{S1}", "T_{S2}", "T_b", "T_{S3}", "T_R"];
            % end

            obj.names.u = ["T_F^{pred,I}", "T_R^{succ,I}", "m_F=m_{out}^{pred,I}", "m_U", "m_{out}^{I,I}", "m_R^{succ,I}", "m_R^{I,I}"];
        end


        function nlobj = createNMPC(obj)
            % Create NMPC object
            nlobj = nlmpc(obj.nx, obj.ny, 'MV', [1:obj.nu_mv], 'MD', [(1+obj.nu_mv):(1+obj.nu_md)]);

            % NMPC parameters
            nlobj.PredictionHorizon = obj.K; 
            nlobj.ControlHorizon = obj.K;
            nlobj.Ts = obj.Ts;
            nlobj.Model.NumberOfParameters = numel({obj.params});

            % Prediction model
            nlobj.Model.IsContinuousTime = true;
            nlobj.Model.StateFcn = "HouseholdTemperatureDynamic_DecMPC";

            % Output
            nlobj.Model.OutputFcn = "HouseholdOutput_DecMPC";

            % Cost
            nlobj.Optimization.ReplaceStandardCost = true;
            nlobj.Optimization.CustomCostFcn = "CostFunction_DecMPC";
            % nlobj.Optimization.ReplaceStandardCost = false;
            % nlobj.Weights.ManipulatedVariables = 
            % nlobj.Weights.ManipulatedVariablesRate = 
            % nlobj.Weights.ECR = ;
            % nlobj.Weights.OutputVariables = obj.Q;

            % Constraints
            nlobj.Optimization.CustomIneqConFcn = "IneqConFunction_DecMPC";

            % State & Manipulated Variable constraints
            for i = 1:obj.nx
                nlobj.States(i).Min = 0;
            end

            nlobj.MV(1).Max = HouseholdPressureDrop_DecMPC(obj.params);
            nlobj.MV(1).Min = 0;
        end
    end
end
