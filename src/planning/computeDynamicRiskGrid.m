function riskGrid = computeDynamicRiskGrid(predictedTrajectories, gridParams)
% computeDynamicRiskGrid - Computes risk grid from predicted trajectories
%
% Inputs:
%   predictedTrajectories - Struct array of agents with 'trajectory' (Tx2),
%                           'class' (string), and 'probability'
%   gridParams - Struct with 'width', 'height', 'resolution', 'origin'
%                e.g., width=100, height=100, resolution=0.5m
%
% Outputs:
%   riskGrid - Struct with 100x100 matrix 'map' (0-1), 'origin', 'resolution'

    if isfield(gridParams, 'width') && isfield(gridParams, 'height')
        nx = round(gridParams.width / gridParams.resolution);
        ny = round(gridParams.height / gridParams.resolution);
    elseif isfield(gridParams, 'size')
        nx = gridParams.size(1);
        ny = gridParams.size(2);
    else
        nx = 100;
        ny = 100;
    end
    gridMap = zeros(nx, ny);
    
    % Class weights for Indian heterogeneous traffic
    classWeights = containers.Map(...
        {'truck', 'bus', 'car', 'auto_rickshaw', 'motorcycle', 'bicycle', 'pedestrian', 'cow', 'pushcart', 'animal'}, ...
        [1.0, 0.9, 0.7, 0.6, 0.5, 0.4, 0.5, 0.9, 0.3, 0.8]);
        
    [X, Y] = meshgrid(1:ny, 1:nx);
    x_coords = gridParams.origin(1) + (X - 0.5) * gridParams.resolution;
    y_coords = gridParams.origin(2) + (Y - 0.5) * gridParams.resolution;
    
    for i = 1:length(predictedTrajectories)
        agent = predictedTrajectories(i);
        w_class = 0.5; % default
        if isKey(classWeights, agent.class)
            w_class = classWeights(agent.class);
        end
        
        if isfield(agent, 'probability')
            probs = agent.probability;
        elseif isfield(agent, 'probabilities')
            probs = agent.probabilities;
        else
            probs = 1.0;
        end

        if isfield(agent, 'trajectories')
            if iscell(agent.trajectories)
                trajs_list = agent.trajectories;
            else
                numH = size(agent.trajectories, 3);
                trajs_list = cell(1, numH);
                for h = 1:numH
                    trajs_list{h} = agent.trajectories(:, :, h);
                end
            end
        elseif isfield(agent, 'trajectory')
            if iscell(agent.trajectory)
                trajs_list = agent.trajectory;
            else
                trajs_list = {agent.trajectory};
            end
        else
            trajs_list = {};
        end

        for k = 1:length(trajs_list)
            traj = trajs_list{k};
            if k <= length(probs)
                prob = probs(k);
            else
                prob = 1.0 / max(length(trajs_list), 1);
            end
            T = size(traj, 1);
            
            for t = 1:T
                pos = traj(t, :);
                sigma = 0.5 + 0.1 * t;
                distSq = (x_coords - pos(1)).^2 + (y_coords - pos(2)).^2;
                riskContribution = w_class * prob * exp(-distSq / (2 * sigma^2));
                gridMap = gridMap + riskContribution;
            end
        end
    end
    
    % Normalize / Cap at 1.0
    gridMap(gridMap > 1.0) = 1.0;
    
    riskGrid.map = gridMap;
    riskGrid.origin = gridParams.origin;
    riskGrid.resolution = gridParams.resolution;
end
