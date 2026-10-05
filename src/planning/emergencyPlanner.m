function [steeringCmd, accelCmd] = emergencyPlanner(egoState, obstacles, goalPos)
% emergencyPlanner - Artificial Potential Field (APF) based emergency reactive planner
% 
% Inputs:
%   egoState  - [x, y, heading, speed]
%   obstacles - Mx2 matrix of obstacle positions [x, y] within 15m
%   goalPos   - [x, y] Target position for attractive force
%
% Outputs:
%   steeringCmd - Emergency steering angle command (radians)
%   accelCmd    - Deceleration command (m/s^2)
%
% Note: Runs at 50Hz for instant reaction.

    % APF Parameters
    k_att = 1.0; % Attractive force gain
    eta = 50.0;  % Repulsive force gain
    d0 = 10.0;   % Obstacle influence distance (m)
    
    egoPos = egoState(1:2);
    egoHeading = egoState(3);
    
    % Attractive force
    distGoal = norm(goalPos - egoPos);
    if distGoal > 0
        F_att = k_att * (goalPos - egoPos) / distGoal;
    else
        F_att = [0, 0];
    end
    
    % Repulsive forces
    F_rep = [0, 0];
    for i = 1:size(obstacles, 1)
        obsPos = obstacles(i, 1:2);
        dist = norm(obsPos - egoPos);
        
        if dist < d0 && dist > 0.1 % Avoid singularity
            direction = (egoPos - obsPos) / dist;
            mag = eta * (1/dist - 1/d0)^2;
            F_rep = F_rep + mag * direction;
        end
    end
    
    % Total force
    F_total = F_att + F_rep;
    
    % Desired heading from total force vector
    desiredHeading = atan2(F_total(2), F_total(1));
    
    % Heading error
    headingError = angdiff(egoHeading, desiredHeading);
    
    % Proportional control for steering
    kp_steer = 0.5;
    steeringCmd = kp_steer * headingError;
    
    % Cap steering
    maxSteer = deg2rad(35);
    steeringCmd = max(-maxSteer, min(maxSteer, steeringCmd));
    
    % Longitudinal control (Deceleration)
    % Decelerate based on repulsive force magnitude
    mag_rep = norm(F_rep);
    if mag_rep > 10.0
        accelCmd = -5.0; % hard brake
    elseif mag_rep > 2.0
        accelCmd = -2.0; % mild brake
    else
        accelCmd = 0.0;  % maintain speed
    end
end

function d = angdiff(th1, th2)
    d = th2 - th1;
    while d > pi, d = d - 2*pi; end
    while d < -pi, d = d + 2*pi; end
end
