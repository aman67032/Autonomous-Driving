function bestTrajectory = localTrajectoryPlanner(egoState, refPath, riskGrid, vehParams)
% localTrajectoryPlanner - MPC-like local trajectory planner
%
% Inputs:
%   egoState  - [x, y, heading, speed]
%   refPath   - Nx2 matrix of reference waypoints
%   riskGrid  - Dynamic risk grid structure (map, resolution, origin)
%   vehParams - Struct containing maxSpeed, maxAcceleration, maxSteering, etc.
%
% Outputs:
%   bestTrajectory - Tx4 matrix [x, y, heading, speed] for next planningHorizon

    planningHorizon = 3.0; % seconds
    dt = 0.1;
    T = floor(planningHorizon / dt);
    
    lateralOffsets = -2.0 : 0.5 : 2.0; % meters
    speedTargets = linspace(0, vehParams.maxSpeed, 5);
    
    w_length = 0.1;
    w_risk = 100.0;
    w_smooth = 1.0;
    w_comfort = 1.0;
    w_surface = 0.5; % For Indian roads context
    
    minCost = inf;
    bestTrajectory = [];
    
    for latOff = lateralOffsets
        for vTarget = speedTargets
            % Generate candidate trajectory using simple kinematic bicycle model
            traj = zeros(T, 4);
            traj(1, :) = egoState;
            cost = 0;
            valid = true;
            
            for t = 2:T
                % Current state
                curr_x = traj(t-1, 1);
                curr_y = traj(t-1, 2);
                curr_h = traj(t-1, 3);
                curr_v = traj(t-1, 4);
                
                % Reference tracking with lateral offset
                % Find closest point on refPath
                [~, refIdx] = min(sum((refPath - [curr_x, curr_y]).^2, 2));
                refPoint = refPath(refIdx, :);
                if refIdx < size(refPath, 1)
                    pathVector = refPath(refIdx+1, :) - refPath(refIdx, :);
                else
                    pathVector = [cos(curr_h), sin(curr_h)];
                end
                pathAngle = atan2(pathVector(2), pathVector(1));
                
                target_x = refPoint(1) - latOff * sin(pathAngle);
                target_y = refPoint(2) + latOff * cos(pathAngle);
                
                % Pure pursuit like steering
                lookahead = max(2.0, curr_v * 1.0);
                alpha = atan2(target_y - curr_y, target_x - curr_x) - curr_h;
                steerAngle = atan2(2 * vehParams.wheelbase * sin(alpha), lookahead);
                steerAngle = max(-vehParams.maxSteer, min(vehParams.maxSteer, steerAngle));
                
                % Longitudinal acceleration
                accel = (vTarget - curr_v) / 1.0; % simplistic speed control
                accel = max(-vehParams.maxBrake, min(vehParams.maxAccel, accel));
                
                % Update state
                next_x = curr_x + curr_v * cos(curr_h) * dt;
                next_y = curr_y + curr_v * sin(curr_h) * dt;
                next_h = curr_h + curr_v * tan(steerAngle) / vehParams.wheelbase * dt;
                next_v = curr_v + accel * dt;
                
                traj(t, :) = [next_x, next_y, next_h, next_v];
                
                % Calculate Costs
                % Risk cost from grid
                gridX = round((next_x - riskGrid.origin(1)) / riskGrid.resolution) + 1;
                gridY = round((next_y - riskGrid.origin(2)) / riskGrid.resolution) + 1;
                if gridX >= 1 && gridX <= size(riskGrid.map, 1) && gridY >= 1 && gridY <= size(riskGrid.map, 2)
                    riskCost = riskGrid.map(gridX, gridY);
                else
                    riskCost = 1.0; % High risk outside grid
                end
                
                % Kinematic constraint check (simplified)
                if riskCost > 0.8 || next_v < 0
                    valid = false;
                    break;
                end
                
                smoothnessCost = steerAngle^2 + accel^2;
                comfortCost = (accel)^2; % jerk in real impl
                
                cost = cost + w_risk*riskCost + w_smooth*smoothnessCost + w_comfort*comfortCost;
            end
            
            if valid
                cost = cost + w_length * sum(sqrt(sum(diff(traj(:,1:2)).^2, 2)));
                if cost < minCost
                    minCost = cost;
                    bestTrajectory = traj;
                end
            end
        end
    end
    
    if isempty(bestTrajectory)
        % Emergency stop trajectory
        bestTrajectory = repmat(egoState, T, 1);
        bestTrajectory(:, 4) = max(0, egoState(4) - (1:T)' * dt * vehParams.maxBrake);
    end
end
