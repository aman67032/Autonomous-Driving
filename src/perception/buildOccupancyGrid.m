function occGrid = buildOccupancyGrid(tracks, egoPose)
    % buildOccupancyGrid Builds a semantic occupancy grid from fused tracks
    
    gridSize = [100, 100];
    resolution = 0.5; % meters per cell
    
    % Initialize grid
    occGrid = struct();
    occGrid.probability = zeros(gridSize);
    occGrid.semanticClass = zeros(gridSize); % 0 = unknown/free, other numbers = object class IDs
    occGrid.velocity_x = zeros(gridSize);
    occGrid.velocity_y = zeros(gridSize);
    
    % Ego vehicle position in world coordinates
    if nargin < 2
        egoX = 0; egoY = 0; egoTheta = 0;
    else
        egoX = egoPose(1); egoY = egoPose(2); egoTheta = egoPose(3);
    end
    
    for i = 1:length(tracks)
        track = tracks(i);
        
        % Get position (assuming track state is [x; y; z; vx; vy; vz])
        objX = track.State(1);
        objY = track.State(2);
        objVx = track.State(4);
        objVy = track.State(5);
        
        % Transform to ego-centric coordinates (relative to ego pose)
        relX = objX - egoX;
        relY = objY - egoY;
        
        % Convert to grid indices (center of grid is ego vehicle)
        gridX = round((relX / resolution) + (gridSize(1) / 2));
        gridY = round((relY / resolution) + (gridSize(2) / 2));
        
        if gridX > 0 && gridX <= gridSize(1) && gridY > 0 && gridY <= gridSize(2)
            occGrid.probability(gridX, gridY) = 1.0;
            % For semantic class, would map track class to an ID. Using 1 as generic object for now.
            occGrid.semanticClass(gridX, gridY) = 1; 
            occGrid.velocity_x(gridX, gridY) = objVx;
            occGrid.velocity_y(gridX, gridY) = objVy;
        end
    end
end
