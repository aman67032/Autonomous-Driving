% test_trajectoryPrediction.m
% Unit test for trajectory prediction module (CTRA, linear, interaction weights)
function test_trajectoryPrediction()
    fprintf('Running test_trajectoryPrediction...\n');
    
    % Test 1: CTRA vehicle prediction
    state = [10, 5, 8.0, 0.0, deg2rad(5), deg2rad(2), 0.5]; % [x, y, vx, vy, heading, yaw_rate, a]
    numSteps = 30;
    dt = 0.1;
    [trajs, probs] = ctraPredictor(state, numSteps, dt);
    
    assert(length(trajs) == 5, 'CTRA must produce K=5 prediction hypotheses');
    assert(abs(sum(probs) - 1.0) < 1e-4, 'Hypothesis probabilities must sum to 1.0');
    assert(size(trajs{1}, 1) == numSteps, 'Trajectory length must match prediction horizon steps');
    fprintf('  [PASS] Test 1: CTRA multi-modal prediction generated\n');
    
    % Test 2: Full prediction dispatch with heterogeneous agents
    agents(1).id = 1;
    agents(1).class = 'auto_rickshaw';
    agents(1).positionHistory = [0, 0; 2, 0; 4, 0];
    agents(1).velocity = [5.0, 0.0];
    agents(1).heading = 0.0;
    
    agents(2).id = 2;
    agents(2).class = 'cow';
    agents(2).positionHistory = [20, 10; 20, 9.5; 20, 9.0];
    agents(2).velocity = [0.0, -1.0];
    agents(2).heading = -pi/2;
    
    predictions = predictTrajectories(agents, 3.0, 0.1);
    assert(length(predictions) == 2, 'Predictions must be returned for all agents');
    assert(length(predictions(1).trajectories) == 5, 'Vehicle gets 5 hypotheses');
    fprintf('  [PASS] Test 2: Heterogeneous agent trajectory prediction\n');
    
    % Test 3: Interaction weight computation
    egoState = [0, 0, 10, 0, 0]; % [x, y, vx, vy, heading]
    weights = computeInteractionWeights(egoState, predictions);
    assert(length(weights) == 2, 'Weights length must equal number of agents');
    assert(abs(sum(weights) - 1.0) < 1e-3, 'Interaction weights must sum to 1.0');
    fprintf('  [PASS] Test 3: Interaction weights computed and normalized\n');
    
    fprintf('All trajectory prediction unit tests PASSED successfully.\n\n');
end
