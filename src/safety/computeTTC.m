function ttc = computeTTC(egoState, obstacleState)
    % COMPUTETTC Time-to-Collision computation
    %
    % Inputs:
    %   egoState - [x, y, vx, vy]
    %   obstacleState - [x, y, vx, vy, length, width]
    %
    % Outputs:
    %   ttc - Time to collision in seconds, Inf if no collision
    
    ttc = inf;
    
    % Relative position
    relX = obstacleState(1) - egoState(1);
    relY = obstacleState(2) - egoState(2);
    
    % Relative velocity
    relVx = egoState(3) - obstacleState(3);
    relVy = egoState(4) - obstacleState(4);
    
    dist = norm([relX, relY]);
    closingSpeed = (relX*relVx + relY*relVy) / dist; % Projection of velocity on distance vector
    
    if closingSpeed > 0
        % They are closing in on each other
        % Center-to-center distance minus some buffer
        buffer = max(obstacleState(5), obstacleState(6)) / 2 + 2.0;
        if dist > buffer
            ttc = (dist - buffer) / closingSpeed;
        else
            ttc = 0;
        end
    end
end
