classdef Household
    
    % Private household properties 
    properties (Constant)
        rho_w = 1; % 1
        cp_w  = 1;
        V_F   = 1;
        h_F   = 1;
        A_F   = 1;
        V_S1  = 1;
        h_S1  = 1;
        A_S1  = 1;
        V_S2  = 1;
        h_S2  = 1; % 10
        A_S2  = 1;
        h_b   = 1;
        A_b   = 1;
        C_b   = 1;
        V_S3  = 1;
        h_S3  = 1;
        A_S3  = 1;
        V_R   = 1;
        h_R   = 1;
        A_R   = 1; % 20
        V_B   = 1;
        h_B   = 1;
        A_B   = 1; % 23
    end
    
    % Public household properties 
    properties 
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
        validation
    end
    
    methods

        function obj = Household(is_first_house, is_bypass_house, T_set, T_amb, Ts, K, Q, adressBusParams, validation) 
            
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

            % Set temperature values
            obj.T_amb = T_amb;
            obj.T_set = T_set;
            
            % Set controller hyperparameters
            obj.K = K;
            obj.Ts = Ts;
            obj.Q = Q;

            % Assign Buses for storage
            assignBuses(obj);

            % Create NMPC object
            obj.adressBusParams = adressBusParams;
            obj.validation = validation;
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
            nlobj.Model.StateFcn = "HouseholdTemperatureDynamicStateFcn";
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

            if obj.validation
                obj.validateNMPC(obj)
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

        function validateNMPC(obj)
            % % TO CHECK
            % trackingOptions = nlmpcmoveopt;
            % trackingOptions.Parameters = params;

            % Define a random initial state and input
            x0 = ones(obj.nx, 1);  % Example initial states
            u0 = ones(obj.nu_mv + obj.nu_md, 1);

            % Validate functions
            validateFcns(obj.nlobj, x0, u0(1:7)', u0(8:15)', obj.params);
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
