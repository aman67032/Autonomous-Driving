function pet = computePET(egoTrajectory, obstacleTrajectory)
    % COMPUTEPET Post-Encroachment Time
    %
    % Inputs:
    %   egoTrajectory - Tx4 array with [x, y, heading, timestamp]
    %   obstacleTrajectory - Tx4 array with [x, y, heading, timestamp]
    %
    % Outputs:
    %   pet - Post-Encroachment Time in seconds
    
    pet = inf;
    conflictThreshold = 2.5; % meters distance to be considered same location
    
    % Find intersection points of trajectories
    for i = 1:size(egoTrajectory, 1)
        for j = 1:size(obstacleTrajectory, 1)
            dist = norm(egoTrajectory(i, 1:2) - obstacleTrajectory(j, 1:2));
            if dist < conflictThreshold
                % Found a conflict point
                t_ego = egoTrajectory(i, 4);
                t_obs = obstacleTrajectory(j, 4);
                
                currentPET = abs(t_ego - t_obs);
                if currentPET < pet
                    pet = currentPET;
                end
            end
        end
    end
end
