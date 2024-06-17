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

        % Modeling 
        is_first_house
        is_bypass_house
        nx
        ny
        nu_mv
        nu_md

        % Controller Hyperparameters
        K
        Ts
        Q

        % NMPC object for block in Simulink
        nlobj
        
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
        alfa_m_R_alfa = 1;
        alfa_T_F_pred = 1;
        alfa_T_F_succ = 1;
        alfa_T_R_pred = 1;
        alfa_T_R_succ = 1;
    end
    
    methods

        function obj = Household(is_first_house, is_bypass_house, T_set, T_amb, Ts, K, Q) %%%%%%%%%%%%%%%%%% TODO aggiungere nmpcBusAddress
            
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

            % Create NMPC object
            obj.nlobj = obj.createNMPC();
        end

        function params = getParametersList(obj) %%%%%%%%%%%%%%%%%%%% TODO togliere anche address
            propList = properties(obj);
            constPropList = properties('Household');

            % Exclude nlobj property and calculate the total number of parameters
            numParams = numel(propList) + numel(constPropList) - 1; % excluding nlobj
            params = zeros(numParams, 1); % Initialize params array
            
            idx = 1;
            for i = 1:length(constPropList)
                params(idx) = Household.(constPropList{i});
                idx = idx + 1;
            end

            for i = 1:length(propList)
                if ~strcmp(propList{i}, 'nlobj')
                    params(idx) = obj.(propList{i});
                    idx = idx + 1;
                end
            end
        end
        
        function nlobj = createNMPC(obj)
            % Create NMPC object
            nlobj = nlmpc(obj.nx, obj.ny, 'MV', [1:obj.nu_mv], 'MD', [(obj.nu_mv+1):(obj.nu_mv+obj.nu_md)]);

            % NMPC parameters
            nlobj.PredictionHorizon = obj.K; 
            nlobj.Ts = obj.Ts;

            %% Model parameters

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TODO
parasTracking = {[truckDimensions.M1,truckDimensions.L1,truckDimensions.L2]'};
trackingObj.Model.NumberOfParameters = numel(parasTracking);

            parameters = getParametersList(obj);

            % Prediction model
            nlobj.Model.StateFcn = "HouseholdTemperatureDynamic";
            nlobj.Model.OutputFcn = @(x, u, params) HouseholdOutput(x, u, params); %%%%%%%%%%%%%%%%%% TODO cambiare nomi funzioni
            nlobj.Model.NumberOfParameters = 1;

            % CreateParametersBus
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TODO

            % Cost
            nlobj.Optimization.CustomCostFcn = @(x, u, e, data, params) CostFunction(x, u, e, data, params);

            % Constraints
            nlobj.Optimization.CustomEqConFcn = @(x, u, data, params) EqConFunction(x, u, data, params);

            % State & Manipulated Variable constraints
            for i = 1:obj.nx
                nlobj.States(i).Min = 0;
            end

            for i = 1:obj.nu_mv
                nlobj.ManipulatedVariables(i).Min = 0;
            end

            %%%%%%%%%%%%%% TODO spostare validation qui
            %% Validate
trackingOptions = nlmpcmoveopt;
trackingOptions.Parameters = parasTracking;
xTest = [-16 0 0 0]';
uTest = [0.22 -3]';
validateFcns(trackingObj,xTest,uTest,{},parasTracking)
        end
    end
end
