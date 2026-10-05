function [path, pathCost] = globalPathPlanner(startPos, goalPos, roadNetwork)
% globalPathPlanner - A* path planner on a road graph.
%
% Inputs:
%   startPos    - [x, y] Starting position
%   goalPos     - [x, y] Goal position
%   roadNetwork - Struct with 'nodes' (Nx2 matrix) and 'edges' (Mx2 matrix of node indices)
%
% Outputs:
%   path        - Nx2 matrix of waypoints, or empty if no path found
%   pathCost    - Total distance of the path

    if isempty(roadNetwork)
        roadNetwork = createSampleNetwork();
    end

    nodes = roadNetwork.nodes;
    edges = roadNetwork.edges;
    numNodes = size(nodes, 1);

    % Find closest nodes to start and goal
    [~, startNodeIdx] = min(sum((nodes - startPos).^2, 2));
    [~, goalNodeIdx]  = min(sum((nodes - goalPos).^2, 2));

    % Adjacency list
    adjList = cell(numNodes, 1);
    for i = 1:size(edges, 1)
        u = edges(i, 1);
        v = edges(i, 2);
        dist = norm(nodes(u,:) - nodes(v,:));
        adjList{u} = [adjList{u}; v, dist];
        adjList{v} = [adjList{v}; u, dist]; % undirected
    end

    % A* search
    openSet = startNodeIdx;
    cameFrom = zeros(numNodes, 1);
    
    gScore = inf(numNodes, 1);
    gScore(startNodeIdx) = 0;
    
    fScore = inf(numNodes, 1);
    fScore(startNodeIdx) = heuristic(nodes(startNodeIdx, :), nodes(goalNodeIdx, :));

    closedSet = false(numNodes, 1);

    while ~isempty(openSet)
        % Find node in openSet with lowest fScore
        [~, minIdx] = min(fScore(openSet));
        current = openSet(minIdx);
        
        if current == goalNodeIdx
            % Reconstruct path
            pathIdx = reconstructPath(cameFrom, current);
            path = [startPos; nodes(pathIdx, :); goalPos];
            pathCost = gScore(goalNodeIdx) + norm(startPos - nodes(startNodeIdx,:)) + norm(goalPos - nodes(goalNodeIdx,:));
            return;
        end
        
        openSet(minIdx) = []; % Remove from openSet
        closedSet(current) = true;
        
        % Neighbors
        neighbors = adjList{current};
        if isempty(neighbors), continue; end
        
        for i = 1:size(neighbors, 1)
            neighbor = neighbors(i, 1);
            weight = neighbors(i, 2);
            
            if closedSet(neighbor)
                continue;
            end
            
            tentative_gScore = gScore(current) + weight;
            
            if tentative_gScore < gScore(neighbor)
                cameFrom(neighbor) = current;
                gScore(neighbor) = tentative_gScore;
                fScore(neighbor) = gScore(neighbor) + heuristic(nodes(neighbor, :), nodes(goalNodeIdx, :));
                
                if ~ismember(neighbor, openSet)
                    openSet = [openSet; neighbor];
                end
            end
        end
    end

    % No path found
    path = [];
    pathCost = inf;
    warning('No path found from start to goal.');
end

function h = heuristic(pos1, pos2)
    % Euclidean distance heuristic
    h = norm(pos1 - pos2);
end

function path = reconstructPath(cameFrom, current)
    path = current;
    while cameFrom(current) ~= 0
        current = cameFrom(current);
        path = [current; path];
    end
end

function roadNetwork = createSampleNetwork()
    % Create a simple 3x3 grid road network for testing
    [X, Y] = meshgrid(0:50:100, 0:50:100);
    nodes = [X(:), Y(:)];
    edges = [];
    for i = 1:size(nodes,1)
        for j = i+1:size(nodes,1)
            if norm(nodes(i,:) - nodes(j,:)) <= 50.1
                edges = [edges; i, j];
            end
        end
    end
    roadNetwork.nodes = nodes;
    roadNetwork.edges = edges;
end
