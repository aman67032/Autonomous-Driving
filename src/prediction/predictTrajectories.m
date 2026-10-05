function predictions = predictTrajectories(trackedObjects, horizon, dt)
% predictTrajectories Predicts future trajectories for tracked objects.
%
% Inputs:
%   trackedObjects - struct array with id, class, positionHistory, velocity, heading
%   horizon - prediction horizon in seconds (default 3.0s)
%   dt - timestep in seconds (default 0.1s)
%
% Outputs:
%   predictions - struct array with predicted trajectories for each agent

if nargin < 2
    horizon = 3.0;
end
if nargin < 3
    dt = 0.1;
end

numSteps = round(horizon / dt);
numAgents = length(trackedObjects);
predictions = struct('agentId', {}, 'trajectories', {}, 'probabilities', {}, 'predictedClass', {});

for i = 1:numAgents
    agent = trackedObjects(i);
    
    % Prepare state for predictors
    % State format for CTRA: [x, y, vx, vy, heading, yaw_rate, acceleration]
    x = agent.positionHistory(end, 1);
    y = agent.positionHistory(end, 2);
    vx = agent.velocity(1);
    vy = agent.velocity(2);
    heading = agent.heading;
    
    yaw_rate = 0; 
    acceleration = 0;
    
    state = [x, y, vx, vy, heading, yaw_rate, acceleration];
    
    if strcmpi(agent.class, 'pedestrian') || strcmpi(agent.class, 'animal') || strcmpi(agent.class, 'cow')
        % Use simple linear predictor for pedestrians/animals
        [trajectories, probs] = linearPredictor(state, numSteps, dt);
    else
        % Use CTRA for vehicles
        [trajectories, probs] = ctraPredictor(state, numSteps, dt);
    end
    
    predictions(i).agentId = agent.id;
    predictions(i).trajectories = trajectories;
    predictions(i).probabilities = probs;
    predictions(i).predictedClass = agent.class;
end

end

function [trajectories, probs] = linearPredictor(state, numSteps, dt)
    % Simple linear predictor
    % Generates K=5 trajectories with small heading noise
    K = 5;
    trajectories = cell(1, K);
    probs = ones(1, K) / K;
    
    x = state(1);
    y = state(2);
    v = norm([state(3), state(4)]);
    heading = state(5);
    
    heading_noise = [-0.2, -0.1, 0, 0.1, 0.2];
    
    for k = 1:K
        curr_x = x;
        curr_y = y;
        curr_heading = heading + heading_noise(k);
        traj_k = zeros(numSteps, 2);
        for t = 1:numSteps
            curr_x = curr_x + v * cos(curr_heading) * dt;
            curr_y = curr_y + v * sin(curr_heading) * dt;
            traj_k(t, 1) = curr_x;
            traj_k(t, 2) = curr_y;
        end
        trajectories{k} = traj_k;
    end
end
