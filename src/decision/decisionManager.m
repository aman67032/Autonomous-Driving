function [targetSpeed, steeringMode, activeManeuver] = decisionManager(egoState, fusedTracks, riskGrid, currentMode)
    % DECISIONMANAGER Main decision coordinator for autonomous driving
    %
    % Inputs:
    %   egoState - Struct with current ego state (x, y, heading, speed)
    %   fusedTracks - Array of struct containing tracked objects
    %   riskGrid - 2D array representing risk values ahead
    %   currentMode - String indicating current driving mode
    %
    % Outputs:
    %   targetSpeed - Target speed in m/s
    %   steeringMode - String indicating steering mode ('LANE_KEEP', 'YIELD', 'AVOID')
    %   activeManeuver - Current state machine state
    
    % Default outputs
    targetSpeed = egoState.speed;
    steeringMode = 'LANE_KEEP';
    activeManeuver = currentMode;
    
    % Parameters
    maxSpeed = 15; % m/s (approx 54 km/h)
    crawlSpeed = 3; % m/s
    slowSpeed = 8; % m/s
    proximityThreshold = 30; % meters
    riskThresholdHigh = 0.8;
    riskThresholdMed = 0.5;
    
    % Traffic density (tracks within 30m)
    nearbyTracksCount = 0;
    minTTC = inf;
    for i = 1:length(fusedTracks)
        track = fusedTracks(i);
        dist = norm([track.x - egoState.x, track.y - egoState.y]);
        if dist < proximityThreshold
            nearbyTracksCount = nearbyTracksCount + 1;
        end
        
        % Simple TTC estimate based on distance and relative speed along heading
        relV = egoState.speed - track.speed;
        if relV > 0
            ttc = dist / relV;
            if ttc < minTTC
                minTTC = ttc;
            end
        end
    end
    
    if isstruct(riskGrid)
        gridData = riskGrid.map;
    else
        gridData = riskGrid;
    end
    if ~isempty(gridData)
        maxRiskAhead = max(gridData(:));
    else
        maxRiskAhead = 0;
    end
    
    % State Machine Transitions
    if minTTC < 1.5 || maxRiskAhead > 0.9
        activeManeuver = 'EMERGENCY_BRAKE';
    elseif minTTC < 3.0 || (nearbyTracksCount > 10 && egoState.speed > crawlSpeed)
        activeManeuver = 'FULL_STOP';
    elseif minTTC < 5.0 || maxRiskAhead > riskThresholdHigh
        activeManeuver = 'CRAWL_MODE';
    elseif maxRiskAhead > riskThresholdMed || nearbyTracksCount > 5
        activeManeuver = 'SLOW_APPROACH';
    elseif nearbyTracksCount > 3 && strcmp(currentMode, 'GAP_NEGOTIATION')
        activeManeuver = 'GAP_NEGOTIATION';
    else
        activeManeuver = 'NORMAL_DRIVING';
    end
    
    % State Actions
    switch activeManeuver
        case 'NORMAL_DRIVING'
            targetSpeed = maxSpeed;
            steeringMode = 'LANE_KEEP';
        case 'SLOW_APPROACH'
            targetSpeed = slowSpeed;
            steeringMode = 'LANE_KEEP';
        case 'CRAWL_MODE'
            targetSpeed = crawlSpeed;
            steeringMode = 'YIELD';
        case 'FULL_STOP'
            targetSpeed = 0;
            steeringMode = 'LANE_KEEP';
        case 'EMERGENCY_BRAKE'
            targetSpeed = 0;
            steeringMode = 'LANE_KEEP';
        case 'GAP_NEGOTIATION'
            targetSpeed = crawlSpeed;
            steeringMode = 'YIELD';
        case 'LANE_CHANGE'
            targetSpeed = slowSpeed;
            steeringMode = 'AVOID';
        otherwise
            targetSpeed = 0;
            steeringMode = 'LANE_KEEP';
    end
end
