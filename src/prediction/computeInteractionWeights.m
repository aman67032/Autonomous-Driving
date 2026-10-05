function weights = computeInteractionWeights(egoState, agentPredictions)
% computeInteractionWeights Computes interaction weights for surrounding agents.
%
% Inputs:
%   egoState - struct with x, y, velocity, heading
%   agentPredictions - struct array of predicted trajectories for each agent
%
% Outputs:
%   weights - normalized weight vector summing to 1

numAgents = length(agentPredictions);
if numAgents == 0
    weights = [];
    return;
end

rawWeights = zeros(1, numAgents);

% Class threat mapping
classThreat = containers.Map(...
    {'truck', 'bus', 'car', 'motorcycle', 'autorickshaw', 'auto_rickshaw', 'bicycle', 'pedestrian', 'animal', 'cow', 'pushcart'}, ...
    [1.0, 1.0, 0.8, 0.6, 0.7, 0.7, 0.5, 0.4, 0.4, 0.4, 0.3]);

if isstruct(egoState)
    egoPos = [egoState.x, egoState.y];
    egoHeading = egoState.heading;
else
    egoPos = egoState(1:2);
    if length(egoState) >= 5
        egoHeading = egoState(5);
    elseif length(egoState) >= 3
        egoHeading = egoState(3);
    else
        egoHeading = 0;
    end
end

for i = 1:numAgents
    agent = agentPredictions(i);
    
    % Use first predicted position or current position for distance
    if iscell(agent.trajectories) && ~isempty(agent.trajectories)
        agentPos = agent.trajectories{1}(1, :);
    elseif isnumeric(agent.trajectories) && ~isempty(agent.trajectories)
        agentPos = mean(agent.trajectories(1, :, :), 3); 
    else
        agentPos = egoPos; % Fallback
    end
    
    % Distance weight
    dist = norm(agentPos - egoPos);
    w_dist = exp(-dist / 10);
    
    % Heading weight (collision course)
    rel_pos = agentPos - egoPos;
    rel_pos_dir = atan2(rel_pos(2), rel_pos(1));
    w_heading = max(0, cos(egoHeading - rel_pos_dir));
    
    % Class weight
    if isfield(agent, 'predictedClass')
        agentClass = lower(agent.predictedClass);
    elseif isfield(agent, 'class')
        agentClass = lower(agent.class);
    else
        agentClass = 'car';
    end
    if isKey(classThreat, agentClass)
        w_class = classThreat(agentClass);
    else
        w_class = 0.5; % Default
    end
    
    rawWeights(i) = w_dist * w_heading * w_class;
end

% Normalize
sumWeights = sum(rawWeights);
if sumWeights > 0
    weights = rawWeights / sumWeights;
else
    weights = ones(1, numAgents) / numAgents;
end

end
