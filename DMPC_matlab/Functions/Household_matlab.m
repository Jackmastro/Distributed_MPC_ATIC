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
        Q % 34
        
        % Damping Weights - Lagrange Multipliers Cost Function
        delta_m_O_pred = 1;
        delta_m_O_succ = 1;
        delta_m_R_pred = 1;
        delta_m_R_succ = 1;
        delta_T_F_pred = 1;
        delta_T_F_succ = 1;
        delta_T_R_pred = 1;
        delta_T_R_succ = 1;

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
                obj.nu_md = 8;
            elseif is_first_house
                obj.nu_md = 8;
            else
                obj.nu_md = 16;
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
            obj.D_S2 = 0.05;
            obj.L_S3 = 5;
            obj.D_S3 = 0.1;
      
            obj.h_S1  = 1.5;
            obj.h_S2  = 1.5;
            obj.h_S3  = 1.5;
            obj.h_b = 1.5;
            obj.h_F = 1.5;
            obj.h_R = 1.5;
            obj.h_BYP = 1.5;
      
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
            obj.V_BYP  = pi/4*obj.D_BYP^2*obj.L_BYP;
            obj.A_BYP  = pi*obj.D_BYP*obj.L_BYP;
      
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
            obj.T_BYP_0 = 283;
                 
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
                          obj.T_set; %40
                          obj.T_amb;
                          obj.K;
                          obj.Ts;
                          obj.Q;
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
                          obj.delta_T_R_succ %58
                ];

            obj.paramsCell = {obj.params};

            obj.nlobj = obj.createNMPC();

            obj.validation = validation;
            if obj.validation
                obj.validateNMPC()
            end
        end

%%%%%%%%% Helper functions

        function nlobj = createNMPC(obj)

            % Create NMPC object (https://ch.mathworks.com/help/mpc/ref/nlmpc.html#mw_e9ec0499-492f-4b58-a718-c05de56a7666)
            nlobj = nlmpc(obj.nx, obj.ny, 'MV', [1:obj.nu_mv], 'MD', [(obj.nu_mv+1):(obj.nu_mv+obj.nu_md)]);

            % NMPC parameters
            nlobj.PredictionHorizon = obj.K; 
            nlobj.ControlHorizon = obj.K;
            nlobj.Ts = obj.Ts;

            % Prediction model
            nlobj.Model.StateFcn = @(x,u,params) StateDynamics_matlab(x,u,params);
            nlobj.Model.IsContinuousTime = true;
            nlobj.Model.OutputFcn = @(x,u,params) OutputFunction_matlab(x,u,params);
            nlobj.Model.NumberOfParameters = numel(obj.paramsCell);

            % Cost (https://ch.mathworks.com/help/mpc/ug/specify-cost-function-for-nonlinear-mpc.html)
            nlobj.Optimization.CustomCostFcn = @(x,u,e,data,params) CostFunction_matlab(x,u,e,data,params);
            nlobj.Optimization.ReplaceStandardCost = true;

            % Constraints (https://ch.mathworks.com/help/mpc/ug/specify-constraints-for-nonlinear-mpc.html)
            nlobj.Optimization.CustomEqConFcn = @(x,u,data,params) EqConFunction_matlab(x,u,data,params);
            nlobj.Optimization.CustomIneqConFcn = @(x,u,e,data,params) IneqConFunction_matlab(x,u,e,data,params);

            % State & Manipulated Variable constraints
            for i = 1:obj.nx
                nlobj.States(i).Min = 0;
            end

            for i = 1:obj.nu_mv
                nlobj.ManipulatedVariables(i).Min = 0;
            end

            % Jacobians (https://ch.mathworks.com/help/mpc/ug/specify-prediction-model-for-nonlinear-mpc.html)
            nlobj.Jacobian.StateFcn = @(x,u,params) JacobianState_matlab(x,u,params);
            nlobj.Jacobian.OutputFcn = @(x,u,params) JacobianOutput_matlab(x,u,params);
            % nlobj.Jacobian.CustomCostFcn = @(x,u,params) (x,u,params);
            % nlobj.Jacobian.CustomEqConFcn = @(x,u,e,data,params) (x,u,e,data,params);
            % nlobj.Jacobian.CustomIneqConFcn = @(x,u,e,data,params) (x,u,e,data,params);
        end


        function validateNMPC(obj)
            % https://ch.mathworks.com/help/mpc/ref/nlmpc.validatefcns.html
            x0 = 300 * ones(obj.nx, 1);
            mv0 = 10 * ones(obj.nu_mv, 1);
            md0 = ones(1, obj.nu_md);
            validateFcns(obj.nlobj, x0, mv0, md0, obj.paramsCell);
        end
    end
end