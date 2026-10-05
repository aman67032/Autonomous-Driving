function [brakeCommand, waitFlag, estimatedClearTime] = animalCrossingProtocol(egoState, detectedAnimals)
    % ANIMALCROSSINGPROTOCOL Handles animal detection and response
    %
    % Inputs:
    %   egoState - Struct with current ego state (x, y, heading, speed)
    %   detectedAnimals - Array of struct with detected animals (x, y, speed, type)
    %
    % Outputs:
    %   brakeCommand - Value 0 to 1
    %   waitFlag - Boolean, true if waiting for animal to clear
    %   estimatedClearTime - Estimated time in seconds until path is clear
    
    brakeCommand = 0;
    waitFlag = false;
    estimatedClearTime = 0;
    
    brakeDistance = 40; % meters
    
    if isstruct(egoState)
        egoX = egoState.x; egoY = egoState.y; egoSpeed = egoState.speed;
    else
        egoX = egoState(1); egoY = egoState(2);
        if length(egoState) >= 4, egoSpeed = egoState(4); else, egoSpeed = 0; end
    end
    
    for i = 1:length(detectedAnimals)
        animal = detectedAnimals(i);
        
        dist = norm([animal.x - egoX, animal.y - egoY]);
        
        if dist < brakeDistance
            % Compute relative velocity
            relV = egoSpeed - animal.speed;
            if relV > 0
                ttc = dist / relV;
            else
                ttc = inf;
            end
            
            % Check if stationary on road
            if animal.speed < 0.5 && dist < 15
                % Stationary on road
                waitFlag = true;
                brakeCommand = 1.0;
                estimatedClearTime = inf; % Unknown clear time for stationary animals
                return;
            end
            
            if ttc < 1.5
                brakeCommand = 1.0;
                waitFlag = true;
                estimatedClearTime = 3.0;
            elseif ttc < 3.0
                brakeCommand = max(brakeCommand, 0.5);
                waitFlag = true;
                estimatedClearTime = 2.0;
            end
        end
    end
end
