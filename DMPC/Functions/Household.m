classdef Household
    
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

        % Step sizes - Lagrange Multipliers Update 
        alfa_m_O_pred = 1; 
        alfa_m_O_succ = 1;
        alfa_m_R_pred = 1;
        alfa_m_R_succ = 1;
        alfa_T_F_pred = 1;
        alfa_T_F_succ = 1;
        alfa_T_R_pred = 1;
        alfa_T_R_succ = 1;

        % NMPC object and adress for Simulink
        nlobj
        adressBusParams
        params
    end
    
    methods

        function obj = Household(is_first_house, is_bypass_house, T_set, T_amb, Ts, K, Q, adressBusParams) 
            
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
                          obj.delta_T_R_succ;]; %58


            % Assign Buses for storage
            assignBuses(obj);

            % Create NMPC object
            obj.adressBusParams = adressBusParams;
            obj.nlobj = obj.createNMPC();
        end

%%%%%%%%% Helper functions

        function nlobj = createNMPC(obj)

            % Create NMPC object
            nlobj = nlmpc(obj.nx, obj.ny, 'MV', [1:obj.nu_mv], 'MD', [(obj.nu_mv+1):(obj.nu_mv+obj.nu_md)]);

            % NMPC parameters
            nlobj.PredictionHorizon = obj.K; 
            nlobj.Ts = obj.Ts;

            params = obj.getParametersCell();

            % Prediction model
            nlobj.Model.NumberOfParameters = numel(params);
            nlobj.Model.StateFcn = "ContHouseholdTemperatureDynamic";
            nlobj.Model.IsContinuousTime = false;
            nlobj.Model.OutputFcn = "HouseholdOutput";

            % Cost
            nlobj.Optimization.CustomCostFcn = "CostFunction";

            % Constraints
            nlobj.Optimization.CustomEqConFcn = "EqConFunction";


            % State & Manipulated Variable constraints
            for i = 1:obj.nx
                nlobj.States(i).Min = 0;
            end

            for i = 1:obj.nu_mv
                nlobj.ManipulatedVariables(i).Min = 0;
            end
        end

        function params = getParametersCell(obj)
            propList = properties(obj);
            
            numParams = numel(propList) - 2; % excluding nlobj and adressBusParams
            params = zeros(numParams, 1); 

            for i = 1:numParams
                if strcmp(propList{i}, 'nlobj') || strcmp(propList{i}, 'adressBusParams') % Exclude nlobj and adress properties
                    continue
                end

                params(i) = obj.(propList{i});
            end

            params = {params};
        end

        function assignBuses(obj)
            function busElements = createBusElements(names, dimensions, data_type)
                busElements = Simulink.BusElement.empty(length(names), 0);
                for i = 1:length(names)
                    busElements(i) = Simulink.BusElement;
                    busElements(i).Name = names{i};
                    busElements(i).Dimensions = dimensions;
                    if data_type == false
                        busElements(i).DataType = ['Bus: ', names{i}];
                    else
                        busElements(i).DataType = data_type;
                    end
                    busElements(i).Complexity = 'real';
                end
            end
        
            K_plus_1 = obj.K + 1;
        
            if obj.is_first_house
                % Measured Disturbances (sequence)
                md_names = { ...
                    'm_O_A_B',     ...
                    'm_R_B_B',     ...
                    'T_F_A_B',     ...
                    'T_R_B_B',     ...
                    'lambda_m_O_B_A', ...
                    'lambda_m_R_B_A', ...
                    'lambda_T_F_B_A', ...
                    'lambda_T_R_B_A'  ...
                };
                Bus_md_seq_A = Simulink.Bus;
                Bus_md_seq_A.Elements = createBusElements(md_names, [K_plus_1, 1], 'double');
        
                % Manipulated Variables (sequence and not)
                mv_names = { ...
                    'T_F_HP_A',  ...
                    'T_R_B_A',   ...
                    'm_F_A_A',   ...
                    'm_U_A_A',   ...
                    'm_O_A_A',   ...
                    'm_R_B_A',   ...
                    'm_R_A_A'    ...
                };
                Bus_mv_A = Simulink.Bus;
                Bus_mv_A.Elements = createBusElements(mv_names, [1], 'double');
                
                Bus_mv_seq_A = Simulink.Bus;
                Bus_mv_seq_A.Elements = createBusElements(mv_names, [K_plus_1, 1], 'double');
        
                % States (sequence)
                x_seq_names = { ...
                    'T_F_A_A', ...
                    'T_S1_A',  ...
                    'T_S2_A',  ...
                    'T_b_A',   ...
                    'T_S3_A',  ...
                    'T_R_A_A', ...
                };
                Bus_x_seq_A = Simulink.Bus;
                Bus_x_seq_A.Elements = createBusElements(x_seq_names, [K_plus_1, 1], 'double');
        
                % Create the bus object
                bus_names = { ...
                    'Bus_mv_A',      ...
                    'Bus_mv_seq_A',  ...
                    'Bus_x_seq_A',   ...
                    'Bus_md_seq_A'
                };
                NMPC_A_output = Simulink.Bus;
                NMPC_A_output.Elements = createBusElements(bus_names, [1], false);
        
                % Assign the bus objects to variables in the base workspace
                assignin('base', 'Bus_mv_A', Bus_mv_A);
                assignin('base', 'Bus_mv_seq_A', Bus_mv_seq_A);
                assignin('base', 'Bus_x_seq_A', Bus_x_seq_A);
                assignin('base', 'Bus_md_seq_A', Bus_md_seq_A);
                assignin('base', 'NMPC_A_output', NMPC_A_output);
        
            elseif obj.is_bypass_house
                % Measured Disturbances (sequence)
                md_names = { ...
                    'm_O_B_B',        ...
                    'm_R_C_B',        ...
                    'T_F_B_B',        ...
                    'T_R_C_B',        ...
                    'lambda_m_O_B_C', ...
                    'lambda_m_R_B_C', ...
                    'lambda_T_F_B_C', ...
                    'lambda_T_R_B_C'  ...
                };
                Bus_md_seq_C = Simulink.Bus;
                Bus_md_seq_C.Elements = createBusElements(md_names, [K_plus_1, 1], 'double');
        
                % Manipulated Variables (sequence and not)
                mv_names = { ...
                    'T_F_B_C',     ...
                    'T_R_succ_C',  ...
                    'm_F_C_C',     ...
                    'm_U_C_C',     ...
                    'm_O_C_C',     ...
                    'm_R_succ_C',  ...
                    'm_R_C_C'      ...
                };
                Bus_mv_C = Simulink.Bus;
                Bus_mv_C.Elements = createBusElements(mv_names, [1], 'double');
                
                Bus_mv_seq_C = Simulink.Bus;
                Bus_mv_seq_C.Elements = createBusElements(mv_names, [K_plus_1, 1], 'double');
        
                % States (sequence)
                x_seq_names = { ...
                    'T_F_C',   ...
                    'T_S1_C',  ...
                    'T_S2_C',  ...
                    'T_b_C',   ...
                    'T_S3_C',  ...
                    'T_R_C_C', ...
                    'T_B_C'    ...
                };
                Bus_x_seq_C = Simulink.Bus;
                Bus_x_seq_C.Elements = createBusElements(x_seq_names, [K_plus_1, 1], 'double');
        
                % Create the bus object
                bus_names = { ...
                    'Bus_mv_C',      ...
                    'Bus_mv_seq_C',  ...
                    'Bus_x_seq_C',   ...
                    'Bus_md_seq_C'
                };
                NMPC_C_output = Simulink.Bus;
                NMPC_C_output.Elements = createBusElements(bus_names, [1], false);
        
                % Assign the bus objects to variables in the base workspace
                assignin('base', 'Bus_mv_C', Bus_mv_C);
                assignin('base', 'Bus_mv_seq_C', Bus_mv_seq_C);
                assignin('base', 'Bus_x_seq_C', Bus_x_seq_C);
                assignin('base', 'Bus_md_seq_C', Bus_md_seq_C);
                assignin('base', 'NMPC_C_output', NMPC_C_output);
        
            else
                % Measured Disturbances (sequence)
                md_names = { ...
                    'm_O_A_A',        ...
                    'm_O_B_C',        ...
                    'm_R_C_C',        ...
                    'm_R_B_A',        ...
                    'T_F_A_A',        ...
                    'T_F_B_C',        ...
                    'T_R_C_C',        ...
                    'T_R_B_A',        ...
                    'lambda_m_O_A_B', ...
                    'lambda_m_O_C_B', ...
                    'lambda_m_R_A_B', ...
                    'lambda_m_R_C_B', ...
                    'lambda_T_F_A_B', ...
                    'lambda_T_F_C_B', ...
                    'lambda_T_R_A_B', ...
                    'lambda_T_R_C_B'  ...
                };
                Bus_md_seq_B = Simulink.Bus;
                Bus_md_seq_B.Elements = createBusElements(md_names, [K_plus_1, 1], 'double');
        
                % Manipulated Variables (sequence and not)
                mv_names = { ...
                    'T_F_A_B',  ...
                    'T_R_C_B',  ...
                    'm_F_B_B',  ...
                    'm_U_B_B',  ...
                    'm_O_B_B',  ...
                    'm_R_C_B',  ...
                    'm_R_B_B'   ...
                };
                Bus_mv_B = Simulink.Bus;
                Bus_mv_B.Elements = createBusElements(mv_names, [1], 'double');
                
                Bus_mv_seq_B = Simulink.Bus;
                Bus_mv_seq_B.Elements = createBusElements(mv_names, [K_plus_1, 1], 'double');
        
                % States (sequence)
                x_seq_names = { ...
                    'T_F_B_B',   ...
                    'T_S1_B',    ...
                    'T_S2_B',    ...
                    'T_b_B',     ...
                    'T_S3_B',    ...
                    'T_R_B_B'    ...
                };
                Bus_x_seq_B = Simulink.Bus;
                Bus_x_seq_B.Elements = createBusElements(x_seq_names, [K_plus_1, 1], 'double');
        
                % Create the bus object
                bus_names = { ...
                    'Bus_mv_B',      ...
                    'Bus_mv_seq_B',  ...
                    'Bus_x_seq_B',   ...
                    'Bus_md_seq_B'
                };
                NMPC_B_output = Simulink.Bus;
                NMPC_B_output.Elements = createBusElements(bus_names, [1], false);
        
                % Assign the bus objects to variables in the base workspace
                assignin('base', 'Bus_mv_B', Bus_mv_B);
                assignin('base', 'Bus_mv_seq_B', Bus_mv_seq_B);
                assignin('base', 'Bus_x_seq_B', Bus_x_seq_B);
                assignin('base', 'Bus_md_seq_B', Bus_md_seq_B);
                assignin('base', 'NMPC_B_output', NMPC_B_output);
            end
        
            % Example usage in a Simulink model
            % set_param('model/block', 'OutDataTypeStr', 'Bus: NMPC_A_output');
        end
    end
end
