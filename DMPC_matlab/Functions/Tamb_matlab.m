classdef Tamb_matlab
    
    % Public properties 
    properties
        Ts
        K
        T_mean
        T_var_pp

    end
    
    methods
        % Constructor
        function obj = Tamb_matlab(Ts, K, T_mean, T_var_pp)
            
            obj.Ts = Ts;
            obj.K = K;
            obj.T_mean = T_mean;
            obj.T_var_pp = T_var_pp; % peak-to-peak amplitude variation

        end

        % Function to get interpolated data given current time
        function T_amb_trajectory = getTambTrajectory(obj, current_time)
            % input: time in seconds
            % output: column vector of the next K time steps (included
            % time_input) (length K+1)
            final_time = current_time + obj.K * obj.Ts;
            time_query_points = linspace(current_time, final_time, obj.K+1);

            T_amb_trajectory = obj.sinusoidal_Tamb(time_query_points)';
        end

        function Tamb_vec = sinusoidal_Tamb(obj, time_vec)
            frequency = 0.5 / (24 * 3600); % frequency of the sinusoidal wave (1 cycle every 2 days)
            
            Tamb_vec = obj.T_mean + obj.T_var_pp * sin(2 * pi * frequency * time_vec);
        end

    end
end
