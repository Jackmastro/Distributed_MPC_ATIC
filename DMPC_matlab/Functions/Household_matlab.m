classdef Household_matlab
    
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
        V_BYP
        V_R 
        A_R 
        V_F 
        A_F 
        A_BYP
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

        % Heat producer constraint
        T_F_HP_min
        T_F_HP_max
        m_dot_F_HP_max
        m_dot_F_HP_MaxRate
        m_dot_F_HP_MinRate
        T_F_HP_MaxRate
        T_F_HP_MinRate

        % Building set and ambient temperature
        T_set % 24
        T_amb

        % Modeling 
        is_first_house
        is_bypass_house % 27
        nx
        ny
        nu_mv
        nu_md

        % Controller Hyperparameters
        K
        Ts
        Q_disc % 34
        Q_F 
        Q_S1
        Q_S3
        Q_R 
        R_BYP
        R_U

        names
        
        % Damping Weights - Lagrange Multipliers Cost Function
        delta_m_O_pred
        delta_m_O_succ
        delta_m_R_pred
        delta_m_R_succ
        delta_T_F_pred
        delta_T_F_succ
        delta_T_R_pred
        delta_T_R_succ

        % NMPC object
        params
        paramsCell
        validation
        nlobj
    end
    
    methods

        function obj = Household_matlab(is_first_house, is_bypass_house, T_set, T_amb, Ts, K, Q, validation)
            
            % Set the first_house and bypass_house properties
            obj.is_first_house = is_first_house;
            obj.is_bypass_house = is_bypass_house;

            % Set modeling dimensions
            if is_bypass_house
                obj.nx = 7;
            else
                obj.nx = 6;
            end

            obj.ny = 1;
            obj.nu_mv = 7;

            if is_bypass_house
                obj.nu_md = 10;
            elseif is_first_house
                obj.nu_md = 12;
            else
                obj.nu_md = 18;
            end

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
            obj.C_b = 10*1e5;
	      
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
            obj.V_BYP  = pi/4*obj.D_BYP^2*obj.L_BYP;
            obj.A_BYP  = pi*obj.D_BYP*obj.L_BYP;
      
            obj.f_Darcy = 0.025;
            obj.DeltaP_S1_max = 10*100000;
            obj.DeltaP_S2_max = 10*100000;
            obj.DeltaP_S3_max = 10*100000;

            obj.T_F_0   = 273 + 50;
            obj.T_S1_0  = 273 + 50;
            obj.T_S2_0  = 273 + 50;
            obj.T_S3_0  = 273 + 50;
            obj.T_b_0   = 273 + 17;
            obj.T_R_0   = 273 + 30;
            obj.T_BYP_0 = 273 + 50;

            obj.T_F_HP_min = 273 + 50;
            obj.T_F_HP_max = 273 + 110;
            obj.T_F_HP_MaxRate =   0.1;
            obj.T_F_HP_MinRate = - 0.1;
            
            obj.m_dot_F_HP_max = 30;
            obj.m_dot_F_HP_MaxRate =  0.25;
            obj.m_dot_F_HP_MinRate = -0.25;

                 
            % Set temperature values
            obj.T_amb = T_amb; % PLACE HOLDER
            obj.T_set = T_set; % PLACE HOLDER
            
            % Set controller hyperparameters
            obj.K = K;
            obj.Ts = Ts;
            obj.Q_disc = 5*1e4; 
            obj.Q_F    = 0.01;
            obj.Q_S1   = 0.01;
            obj.Q_S3   = 0.1;
            obj.Q_R    = 0.1;
            obj.R_BYP  = 0.1;
            obj.R_U    = 0.1;

            % ADMM
            delta_m = 5*1e4;
            delta_T = 3.5*1e4;

            obj.delta_m_O_pred = delta_m;
            obj.delta_m_O_succ = delta_m;
            obj.delta_m_R_pred = delta_m;
            obj.delta_m_R_succ = delta_m;
            obj.delta_T_F_pred = delta_T;
            obj.delta_T_F_succ = delta_T;
            obj.delta_T_R_pred = delta_T;
            obj.delta_T_R_succ = delta_T;

            % Set names of variables for plots
            obj = obj.setVarNames();

            % Parameters for MPC
            obj.params = [obj.rho_w; %1
                          obj.cp_w;
                          obj.V_F ;
                          obj.h_F ;
                          obj.A_F ; %5
                          obj.L_F ;
                          obj.D_F ;                          
                          obj.V_S1 ;
                          obj.h_S1 ;
                          obj.A_S1 ; %10
                          obj.L_S1 ;
                          obj.D_S1 ;
                          obj.V_S2 ;
                          obj.h_S2 ;
                          obj.A_S2 ; %15
                          obj.L_S2 ;
                          obj.D_S2 ;
                          obj.h_b  ;
                          obj.A_b  ;
                          obj.C_b  ; %20
                          obj.V_S3 ;
                          obj.h_S3 ;
                          obj.A_S3 ;
                          obj.L_S3 ;
                          obj.D_S3 ; %25
                          obj.V_R ;
                          obj.h_R ;
                          obj.A_R ;
                          obj.L_R ;
                          obj.D_R ; %30
                          obj.V_BYP ;
                          obj.h_BYP ;
                          obj.A_BYP ;
                          obj.L_BYP ;
                          obj.D_BYP ; %35                          
                          obj.f_Darcy;
                          obj.DeltaP_S1_max;
                          obj.DeltaP_S2_max;
                          obj.DeltaP_S3_max;
                          obj.T_set; %40 SPACE HOLDER
                          obj.T_amb; % SPACE HOLDER
                          obj.K;
                          obj.Ts;
                          obj.Q_disc;
                          obj.nx; %45
                          obj.ny;
                          obj.nu_mv;
                          obj.nu_md;
                          obj.is_bypass_house;
                          obj.is_first_house; %50
                          obj.delta_m_O_pred;
                          obj.delta_m_O_succ;
                          obj.delta_m_R_pred;
                          obj.delta_m_R_succ;
                          obj.delta_T_F_pred; %55
                          obj.delta_T_F_succ;
                          obj.delta_T_R_pred;
                          obj.delta_T_R_succ; %58
                          obj.Q_F;   
                          obj.Q_S1; % 60 
                          obj.Q_S3;  
                          obj.Q_R;  % 62 
                          obj.R_BYP;
                          obj.R_U
                          obj.T_F_HP_min; % 65
                          obj.T_F_HP_max;
                          obj.m_dot_F_HP_max;
                          obj.m_dot_F_HP_MaxRate; %68
                          obj.m_dot_F_HP_MinRate;
                          obj.T_F_HP_MaxRate; %70
                          obj.T_F_HP_MinRate];

            obj.paramsCell = {obj.params};

            obj.nlobj = obj.createNMPC();

            obj.validation = validation;
            if obj.validation
                obj.validateNMPC()
            end
        end

%%%%%%%%% Helper functions

        function obj = setVarNames(obj)
            if obj.is_bypass_house
                obj.names.x = ["T_F", "T_{S1}", "T_{S2}", "T_b", "T_{S3}", "T_R", "T_B"];
            else
                obj.names.x = ["T_F", "T_{S1}", "T_{S2}", "T_b", "T_{S3}", "T_R"];
            end

            obj.names.u = ["T_F^{pred,I}", "T_R^{succ,I}", "m_F=m_{out}^{pred,I}", "m_U", "m_{out}^{I,I}", "m_R^{succ,I}", "m_R^{I,I}"];
        end


        function nlobj = createNMPC(obj)

            % Create NMPC object (https://ch.mathworks.com/help/mpc/ref/nlmpc.html#mw_e9ec0499-492f-4b58-a718-c05de56a7666)
            nlobj = nlmpc(obj.nx, obj.ny, 'MV', [1:obj.nu_mv], 'MD', [(obj.nu_mv+1):(obj.nu_mv+obj.nu_md)]);

            % NMPC parameters
            nlobj.PredictionHorizon = obj.K; 
            nlobj.ControlHorizon = obj.K;
            nlobj.Ts = obj.Ts;

            % Prediction model (https://ch.mathworks.com/help/mpc/ug/specify-prediction-model-for-nonlinear-mpc.html)
            nlobj.Model.IsContinuousTime = true;
            nlobj.Model.NumberOfParameters = numel(obj.paramsCell);

            nlobj.Model.StateFcn = @(x,u,params) StateFunction_matlab(x,u,params);
            nlobj.Jacobian.StateFcn = @(x,u,params) JacobianState_matlab(x,u,params);

            nlobj.Model.OutputFcn = @(x,u,params) OutputFunction_matlab(x,u,params);
            nlobj.Jacobian.OutputFcn = @(x,u,params) JacobianOutput_matlab(x,u,params);

            % Cost (https://ch.mathworks.com/help/mpc/ug/specify-cost-function-for-nonlinear-mpc.html)
            nlobj.Optimization.ReplaceStandardCost = true;
            nlobj.Optimization.CustomCostFcn = @(x,u,e,data,params) CostFunction_matlab(x,u,e,data,params);
            % nlobj.Jacobian.CustomCostFcn = @(x,u,params) (x,u,params);

            % Constraints (https://ch.mathworks.com/help/mpc/ug/specify-constraints-for-nonlinear-mpc.html)
            nlobj.Optimization.CustomEqConFcn = @(x,u,data,params) EqConFunction_matlab(x,u,data,params);
            % nlobj.Jacobian.CustomEqConFcn = @(x,u,data,params)
            % JacobianEqCon_matlab(x,u,data,params); TODO STILL NEED DEBUG

            % nlobj.Optimization.CustomIneqConFcn = @(x,u,e,data,params) IneqConFunction_matlab(x,u,e,data,params);
            % nlobj.Jacobian.CustomIneqConFcn = @(x,u,e,data,params) (x,u,e,data,params);

            % State & Manipulated Variable constraints
            for i = 1:obj.nx
                nlobj.States(i).Min = 0;
            end

            for i = 1:obj.nu_mv
                nlobj.ManipulatedVariables(i).Min = 0;
            end
            if obj.is_first_house
                nlobj.ManipulatedVariables(1).RateMax = obj.T_F_HP_MaxRate; % Max rate of variation of the feed temperature from heat producer (T_feed(k) - T_feed(k-1) < RateMax)
                nlobj.ManipulatedVariables(1).RateMin = obj.T_F_HP_MinRate; % Min rate of variation of the feed temperature from heat producer (T_feed(k) - T_feed(k-1) > RateMin)
                nlobj.ManipulatedVariables(1).Max = obj.T_F_HP_max; % Max temperature from Heat Producer
                nlobj.ManipulatedVariables(1).Min = obj.T_F_HP_min; % Min temp from Heat Producer
                nlobj.ManipulatedVariables(3).Max = obj.m_dot_F_HP_max; %Max m_dot from Heat Producer
                % nlobj.ManipulatedVariables(3).RateMax = obj.m_dot_F_HP_MaxRate; % Max rate of variation of the mass_flow from heat producer 
                % nlobj.ManipulatedVariables(3).RateMin = obj.m_dot_F_HP_MinRate;

            end
            nlobj.ManipulatedVariables(4).Max = HouseholdPressureDrop_matlab(obj.params);
        end


        function validateNMPC(obj) % (https://ch.mathworks.com/help/mpc/ref/nlmpc.validatefcns.html)
            x0 = linspace(obj.T_F_0, obj.T_F_0+5, obj.nx)';
            mv0 = 3 * ones(obj.nu_mv, 1);
            md0 = ones(1, obj.nu_md);
            validateFcns(obj.nlobj, x0, mv0, md0, obj.paramsCell);
        end
    end
end
