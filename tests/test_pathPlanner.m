% test_pathPlanner.m
% Unit test for global A* planning, dynamic risk grids, and path smoothing
function test_pathPlanner()
    fprintf('Running test_pathPlanner...\n');
    
    % Test 1: Global A* path planning on sample network
    startPos = [0, 0];
    goalPos  = [100, 100];
    [waypoints, cost] = globalPathPlanner(startPos, goalPos, []);
    assert(~isempty(waypoints), 'A* path should not be empty');
    assert(cost > 0, 'Path cost must be positive');
    assert(size(waypoints, 2) == 2, 'Waypoints must be Nx2 matrix');
    fprintf('  [PASS] Test 1: Global A* planner generates viable route\n');
    
    % Test 2: Dynamic Risk Grid computation
    gridParams.size = [100, 100];
    gridParams.resolution = 0.5;
    gridParams.origin = [-25, -25];
    
    % Dummy prediction struct
    pred(1).agentId = 101;
    pred(1).class = 'cow';
    pred(1).trajectories = cell(1, 1);
    pred(1).trajectories{1} = [linspace(0, 5, 20)', linspace(2, 2, 20)']; % Moving along y=2
    pred(1).probabilities = [1.0];
    
    riskGrid = computeDynamicRiskGrid(pred, gridParams);
    if isstruct(riskGrid)
        rmap = riskGrid.map;
    else
        rmap = riskGrid;
    end
    assert(size(rmap, 1) == 100 && size(rmap, 2) == 100, 'Risk grid must be 100x100');
    assert(max(rmap(:)) > 0, 'Risk grid must contain non-zero risk near agent trajectory');
    assert(min(rmap(:)) >= 0, 'Risk grid values must be non-negative');
    fprintf('  [PASS] Test 2: Dynamic Risk Grid computation from agent trajectories\n');
    
    % Test 3: Path Smoother
    rawWaypoints = [0, 0; 20, 1; 40, -1; 60, 0; 80, 2; 100, 0];
    vp = vehicleParams();
    [smoothPath, curvature] = pathSmoother(rawWaypoints, vp, 0.5);
    assert(size(smoothPath, 1) > size(rawWaypoints, 1), 'Smoother should generate interpolated points');
    assert(all(~isnan(curvature)), 'Curvature profile should not contain NaNs');
    fprintf('  [PASS] Test 3: Path smoother generates continuous trajectory & curvature\n');
    
    fprintf('All path planning unit tests PASSED successfully.\n\n');
end
