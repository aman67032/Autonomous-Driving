function [safeCommand, overrideFlag, violationType] = safetyMonitor(plannedTrajectory, egoState, trackedObjects, thresholds, currentCommand)
    % SAFETYMONITOR Runtime safety monitor
    %
    % Inputs:
    %   plannedTrajectory - Nx2 array of planned path points
    %   egoState - [x, y, heading, speed, accel]
    %   trackedObjects - Array of tracked object structs
    %   thresholds - Struct with safety limits (minTTC, maxLatAccel, maxJerk)
    %   currentCommand - Current proposed command struct (throttle, brake, steer)
    %
    % Outputs:
    %   safeCommand - Modified command if overridden
    %   overrideFlag - Boolean true if override happened
    %   violationType - String indicating reason
    
    safeCommand = currentCommand;
    overrideFlag = false;
    violationType = 'NONE';
    
    speed = egoState(4);
    
    % Check TTC for all objects
    for i = 1:length(trackedObjects)
        obj = trackedObjects(i);
        obsState = [obj.x, obj.y, obj.vx, obj.vy, obj.length, obj.width];
        % Convert ego struct to format needed
        egoV = [egoState(1), egoState(2), speed*cos(egoState(3)), speed*sin(egoState(3))];
        
        ttc = computeTTC(egoV, obsState);
        
        if ttc < thresholds.minTTC
            overrideFlag = true;
            violationType = 'TTC_VIOLATION';
            [brake, ~, ~] = emergencyBrake(egoV, thresholds);
            safeCommand.brake = brake;
            safeCommand.throttle = 0;
            return;
        end
    end
    
    % Lateral acceleration check (v^2 * curvature)
    if size(plannedTrajectory, 1) >= 3
        % Simple curvature estimate from 3 points
        p1 = plannedTrajectory(1, :);
        p2 = plannedTrajectory(2, :);
        p3 = plannedTrajectory(3, :);
        
        % Area of triangle formed by 3 points
        area = 0.5 * abs(p1(1)*(p2(2)-p3(2)) + p2(1)*(p3(2)-p1(2)) + p3(1)*(p1(2)-p2(2)));
        d1 = norm(p1-p2);
        d2 = norm(p2-p3);
        d3 = norm(p3-p1);
        
        if d1*d2*d3 > 0
            curvature = 4*area / (d1*d2*d3);
            latAccel = speed^2 * curvature;
            
            if latAccel > thresholds.maxLatAccel
                overrideFlag = true;
                violationType = 'LAT_ACCEL_VIOLATION';
                safeCommand.throttle = 0;
                safeCommand.brake = 0.5; % Slow down
                return;
            end
        end
    end
end
