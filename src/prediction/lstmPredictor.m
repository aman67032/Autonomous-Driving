function [trajectories, probs] = lstmPredictor(agentHistory, numSteps, dt)
% lstmPredictor LSTM-based trajectory predictor.
%
% Inputs:
%   agentHistory - last 8 timesteps of [x, y, vx, vy] (8x4 matrix)
%   numSteps - number of prediction steps
%   dt - timestep in seconds
%
% Outputs:
%   trajectories - Tx2xK matrix of predicted positions
%   probs - 1xK array of probabilities

modelPath = fullfile('..', '..', 'models', 'prediction', 'trajectory_predictor.mat');
K = 5;
probs = ones(1, K) / K;

if exist(modelPath, 'file')
    data = load(modelPath);
    net = data.net;
    
    % Prepare input sequence
    X = agentHistory'; 
    
    % Predict
    Y_pred = predict(net, X); 
    
    trajectories = reshape(Y_pred, [numSteps, 2, K]);
else
    warning('LSTM model not found at %s. Falling back to ctraPredictor.', modelPath);
    % Estimate state from history for CTRA fallback
    curr_state = agentHistory(end, :);
    x = curr_state(1);
    y = curr_state(2);
    vx = curr_state(3);
    vy = curr_state(4);
    
    heading = atan2(vy, vx);
    
    state = [x, y, vx, vy, heading, 0, 0];
    [trajectories, probs] = ctraPredictor(state, numSteps, dt);
end

end

function net = createLSTMNetwork(numSteps, K)
    % Helper function to create the LSTM architecture
    numFeatures = 4; % x, y, vx, vy
    outputSize = K * numSteps * 2;
    
    layers = [
        sequenceInputLayer(numFeatures, 'Name', 'input')
        lstmLayer(128, 'OutputMode', 'last', 'Name', 'lstm_1')
        lstmLayer(64, 'OutputMode', 'last', 'Name', 'lstm_2')
        fullyConnectedLayer(outputSize, 'Name', 'fc')
        regressionLayer('Name', 'output')
    ];
    
    net = dlnetwork(layers);
end
