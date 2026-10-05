function [brakeCommand, decelValue, stoppingDistance] = emergencyBrake(egoState, safetyThresholds)
    % EMERGENCYBRAKE Emergency braking function
    %
    % Inputs:
    %   egoState - [x, y, vx, vy] or similar containing speed
    %   safetyThresholds - Struct containing aebDecel (max deceleration)
    %
    % Outputs:
    %   brakeCommand - Normalized brake command [0, 1]
    %   decelValue - Expected deceleration in m/s^2
    %   stoppingDistance - Estimated distance to stop
    
    % Get speed
    if length(egoState) >= 4
        if length(egoState) == 4 && all(size(egoState) == [1, 4])
            speed = norm(egoState(3:4)); % Assuming vx, vy for TTC compatibility
        else
            speed = egoState(4); % Assuming x, y, heading, speed
        end
    else
        speed = 0;
    end
    
    if isfield(safetyThresholds, 'aebDecel')
        aebDecel = abs(safetyThresholds.aebDecel);
    else
        aebDecel = 6.0; % Default to 6 m/s^2
    end
    
    brakeCommand = 1.0;
    decelValue = -aebDecel; % Signed deceleration (negative m/s^2)
    
    if aebDecel > 0
        stoppingDistance = (speed^2) / (2 * aebDecel);
    else
        stoppingDistance = inf;
    end
end
