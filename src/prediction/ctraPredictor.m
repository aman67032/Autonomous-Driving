function [trajectories, probs] = ctraPredictor(state, numSteps, dt)
% ctraPredictor Constant Turn Rate and Acceleration model predictor.
%
% Inputs:
%   state - [x, y, vx, vy, heading, yaw_rate, acceleration]
%   numSteps - number of prediction steps
%   dt - timestep in seconds
%
% Outputs:
%   trajectories - Tx2xK matrix of predicted positions
%   probs - 1xK array of probabilities

K = 5;
trajectories = cell(1, K);
probs = ones(1, K) / K;

x0 = state(1);
y0 = state(2);
vx0 = state(3);
vy0 = state(4);
v0 = norm([vx0, vy0]);
heading0 = state(5);
yaw_rate0 = state(6);
accel0 = state(7);

% Noise multipliers
yaw_noise = [0.9, 0.95, 1.0, 1.05, 1.1]; % +/- 10%
accel_noise = [0.8, 0.9, 1.0, 1.1, 1.2]; % +/- 20%

for k = 1:K
    curr_x = x0;
    curr_y = y0;
    curr_v = v0;
    curr_heading = heading0;
    traj_k = zeros(numSteps, 2);
    
    % Apply noise
    curr_yaw_rate = yaw_rate0 * yaw_noise(k);
    if curr_yaw_rate == 0
        curr_yaw_rate = (k-3) * 0.05; 
    end
    
    curr_accel = accel0 * accel_noise(k);
    
    for t = 1:numSteps
        if abs(curr_yaw_rate) < 1e-4
            % Straight line approximation
            curr_x = curr_x + curr_v * cos(curr_heading) * dt;
            curr_y = curr_y + curr_v * sin(curr_heading) * dt;
        else
            % CTRA equations
            curr_x = curr_x + (curr_v / curr_yaw_rate) * (sin(curr_heading + curr_yaw_rate * dt) - sin(curr_heading));
            curr_y = curr_y + (curr_v / curr_yaw_rate) * (-cos(curr_heading + curr_yaw_rate * dt) + cos(curr_heading));
        end
        
        curr_heading = curr_heading + curr_yaw_rate * dt;
        curr_v = curr_v + curr_accel * dt;
        
        traj_k(t, 1) = curr_x;
        traj_k(t, 2) = curr_y;
    end
    trajectories{k} = traj_k;
end

end
