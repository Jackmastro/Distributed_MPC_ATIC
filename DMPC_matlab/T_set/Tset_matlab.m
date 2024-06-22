classdef Tset_matlab
    
    % Public properties 
    properties
        dataset
        Ts
        K

        time
        data
        interpolated_time
        interpolated_data

    end
    
    methods
        % Constructor
        function obj = Tset_matlab(Ts, K)
            obj = obj.load_data();
            obj.Ts = Ts;
            obj.K = K;

            obj = obj.interpolate();

        end

        % Function to get interpolated data given current time
        function T_set_trajectory = getTsetTrajectory(obj, current_time)
            % input: time_input in seconds
            % output: vector of the next K time steps (excluded time_input)
            final_time = current_time + obj.K * obj.Ts;
            time_query_points = linspace(current_time, final_time, obj.K+1);

            T_set_trajectory = interp1(obj.interpolated_time, obj.interpolated_data, time_query_points, 'linear', 'extrap');
            T_set_trajectory = T_set_trajectory(2:end);
        end

%%%%%%%%% Helper functions

        function obj = load_data(obj)
            % Get the full path of the currently running script
            if isdeployed
                % If the code is deployed, use the built-in method
                scriptFullPath = mfilename('fullpath');
            else
                % If running in the MATLAB environment, use the editor API
                scriptFullPath = matlab.desktop.editor.getActiveFilename;
            end
            
            % Extract the directory part of the path
            [scriptDir, ~, ~] = fileparts(scriptFullPath);
            
            obj.dataset = load([scriptDir, '/T_set/T_set_trajectory.mat']).Trajectory;

            % Extract the timeseries object from the dataset
            timeseries = obj.dataset.get('T_set');
            
            % Get the time and data values from the timeseries object
            obj.time = timeseries.Time;
            obj.data = timeseries.Data;
        end


        % Interpolation function
        function obj = interpolate(obj)
            % Create the time vector with the specified sample time
            t_min = min(obj.time);
            t_max = max(obj.time);
            dt = 1;
            obj.interpolated_time = t_min:dt:t_max;
            
            % Interpolate the data based on the new time vector
            obj.interpolated_data = interp1(obj.time, obj.data, obj.interpolated_time, 'linear', 'extrap');
        end

    end
end
