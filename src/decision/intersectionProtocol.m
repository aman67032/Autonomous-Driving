function [approachSpeed, canProceed, yieldDirection] = intersectionProtocol(egoState, intersectionVehicles, intersectionGeometry)
    % INTERSECTIONPROTOCOL Handles unmarked intersection approach
    %
    % Inputs:
    %   egoState - Struct with current ego state (x, y, heading, speed)
    %   intersectionVehicles - Array of vehicles at intersection (x, y, speed, heading)
    %   intersectionGeometry - Struct with intersection boundaries and center
    %
    % Outputs:
    %   approachSpeed - Target speed for approach (m/s)
    %   canProceed - Boolean, whether ego can proceed through intersection
    %   yieldDirection - 'LEFT', 'RIGHT', 'AHEAD', or 'NONE'
    
    % Slow approach speed (15 km/h approx 4.16 m/s)
    slowApproachSpeed = 4.16;
    creepSpeed = 1.0;
    
    approachSpeed = slowApproachSpeed;
    canProceed = true;
    yieldDirection = 'NONE';
    
    distToIntersection = norm([egoState.x - intersectionGeometry.centerX, egoState.y - intersectionGeometry.centerY]);
    
    if distToIntersection > 30
        % Not near intersection yet
        return;
    end
    
    % Creep-and-peek if close to intersection and visibility might be obscured
    if distToIntersection < 10
        approachSpeed = creepSpeed;
    end
    
    % Yield-to-right rule and gap acceptance
    for i = 1:length(intersectionVehicles)
        veh = intersectionVehicles(i);
        
        % Determine relative bearing to vehicle
        dx = veh.x - egoState.x;
        dy = veh.y - egoState.y;
        bearing = atan2(dy, dx) - egoState.heading;
        % Normalize bearing
        bearing = mod(bearing + pi, 2*pi) - pi;
        
        % Very simple time to intersection estimate
        distEgo = distToIntersection;
        distVeh = norm([veh.x - intersectionGeometry.centerX, veh.y - intersectionGeometry.centerY]);
        
        ttiEgo = distEgo / max(egoState.speed, 0.1);
        ttiVeh = distVeh / max(veh.speed, 0.1);
        
        % If conflict is likely
        if abs(ttiEgo - ttiVeh) < 3.0
            if bearing > 0.1 && bearing < pi/2
                % Vehicle is on the right
                canProceed = false;
                yieldDirection = 'RIGHT';
                approachSpeed = 0;
                break;
            elseif distVeh < distEgo
                % Vehicle is closer
                canProceed = false;
                if bearing < -0.1
                    yieldDirection = 'LEFT';
                else
                    yieldDirection = 'AHEAD';
                end
                approachSpeed = 0;
                break;
            end
        end
    end
end
