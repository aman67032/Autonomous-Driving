function agents = loadRealTrajectoryData(csvFilePath)
% loadRealTrajectoryData
% Ingests real-world recorded trajectory datasets (e.g., TraPHic, IDD, or GPS logs)
% and formats them for MATLAB drivingScenario actor population.
%
% Supported CSV format:
% Header: timestamp, agent_id, class_id, x, y, vx, vy, length, width, height
%
% Outputs:
%   agents: Struct array with fields:
%     .id           - Unique agent integer ID
%     .classID      - Automated Driving Toolbox Class ID
%     .waypoints    - [N x 3] matrix of [x, y, z] spatial coordinates
%     .speed        - [N x 1] velocity profile along trajectory
%     .time         - [N x 1] timestamps corresponding to waypoints
%     .dimensions   - [length, width, height] in meters
%     .className    - Human readable class label

    if nargin < 1 || isempty(csvFilePath)
        % Default to TraPHic Delhi Arterial dataset
        baseDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
        csvFilePath = fullfile(baseDir, 'data', 'real_traces', 'traphic_delhi_arterial.csv');
    end

    if ~exist(csvFilePath, 'file')
        error('Real trajectory data file not found: %s', csvFilePath);
    end

    fprintf('  [DataLoader] Reading real-world trajectory dataset: %s\n', csvFilePath);
    
    % Read table
    opts = detectImportOptions(csvFilePath);
    T = readtable(csvFilePath, opts);
    
    % Ensure numeric columns
    timestamps = double(T.timestamp);
    agentIDs   = double(T.agent_id);
    classIDs   = double(T.class_id);
    posX       = double(T.x);
    posY       = double(T.y);
    velX       = double(T.vx);
    velY       = double(T.vy);
    lengths    = double(T.length);
    widths     = double(T.width);
    heights    = double(T.height);

    uniqueAgents = unique(agentIDs);
    numAgents = length(uniqueAgents);
    
    classNames = containers.Map(...
        {1, 2, 3, 4, 5, 6, 7, 8, 9}, ...
        {'Car', 'Truck', 'AutoRickshaw', 'Motorcycle', 'Bicycle', 'Pedestrian', 'Cattle', 'Pushcart', 'Hazard'} ...
    );

    agents = repmat(struct(...
        'id', 0, ...
        'classID', 1, ...
        'className', '', ...
        'waypoints', [], ...
        'speed', [], ...
        'time', [], ...
        'dimensions', [4.7, 1.8, 1.4] ...
    ), numAgents, 1);

    for i = 1:numAgents
        agID = uniqueAgents(i);
        mask = (agentIDs == agID);
        
        t_sub = timestamps(mask);
        x_sub = posX(mask);
        y_sub = posY(mask);
        vx_sub = velX(mask);
        vy_sub = velY(mask);
        
        % Sort by timestamp
        [t_sorted, sortIdx] = sort(t_sub);
        x_sorted = x_sub(sortIdx);
        y_sorted = y_sub(sortIdx);
        vx_sorted = vx_sub(sortIdx);
        vy_sorted = vy_sub(sortIdx);
        
        % Extract metadata from first record
        cid = classIDs(find(mask, 1));
        len = lengths(find(mask, 1));
        wid = widths(find(mask, 1));
        hgt = heights(find(mask, 1));
        
        % Filter out duplicate spatial points that cause trajectory errors
        distDiff = [1; sqrt(diff(x_sorted).^2 + diff(y_sorted).^2)];
        validPts = (distDiff > 0.05) | (1:length(distDiff) == 1)' | (1:length(distDiff) == length(distDiff))';
        
        wp_x = x_sorted(validPts);
        wp_y = y_sorted(validPts);
        wp_t = t_sorted(validPts);
        wp_vx = vx_sorted(validPts);
        wp_vy = vy_sorted(validPts);
        
        % Ensure at least 2 distinct waypoints
        if length(wp_x) < 2
            % Duplicate with tiny offset if stationary
            wp_x = [wp_x; wp_x + 0.01];
            wp_y = [wp_y; wp_y];
            wp_t = [wp_t; wp_t + 0.1];
            wp_vx = [wp_vx; 0];
            wp_vy = [wp_vy; 0];
        end

        speeds = sqrt(wp_vx.^2 + wp_vy.^2);
        speeds = max(speeds, 0.01); % Avoid exact zero speed in trajectory
        
        agents(i).id = agID;
        agents(i).classID = cid;
        if isKey(classNames, cid)
            agents(i).className = classNames(cid);
        else
            agents(i).className = 'Obstacle';
        end
        agents(i).waypoints = [wp_x, wp_y, zeros(length(wp_x), 1)];
        agents(i).speed = speeds;
        agents(i).time = wp_t;
        agents(i).dimensions = [len, wid, hgt];
    end
    
    fprintf('  [DataLoader] Successfully parsed %d real heterogeneous road agents.\n', numAgents);
end
