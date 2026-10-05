function [shouldMerge, targetGapPosition, recommendedSpeed] = gapNegotiation(egoState, nearbyVehicles, gapInfo)
    % GAPNEGOTIATION Indian-style gap negotiation for merging/intersections
    %
    % Inputs:
    %   egoState - Struct with current ego state (x, y, heading, speed)
    %   nearbyVehicles - Array of struct of nearby vehicles
    %   gapInfo - Struct describing the available gap (startX, startY, endX, endY, length, leadSpeed, trailSpeed)
    %
    % Outputs:
    %   shouldMerge - Boolean indicating if safe to merge
    %   targetGapPosition - [x, y] coordinates of target merge point
    %   recommendedSpeed - Recommended speed in m/s
    
    if nargin < 3 || isempty(gapInfo)
        gapInfo.startX = 0; gapInfo.startY = 0;
        gapInfo.endX = 0; gapInfo.endY = 0;
        gapInfo.length = 0;
        gapInfo.leadSpeed = 0; gapInfo.trailSpeed = 0;
    end
    
    % Defaults
    shouldMerge = false;
    targetGapPosition = [gapInfo.startX, gapInfo.startY];
    recommendedSpeed = 0;
    
    egoLength = 4.5; % meters
    safetyMargin = 2.0; % meters
    minRequiredGap = egoLength + 2 * safetyMargin;
    
    % Evaluate gap safety (is it big enough?)
    if gapInfo.length < minRequiredGap
        % Gap too small, wait
        shouldMerge = false;
        recommendedSpeed = 0;
        return;
    end
    
    % Check if gap is growing or shrinking
    leadSpeed = gapInfo.leadSpeed;
    trailSpeed = gapInfo.trailSpeed;
    
    if (leadSpeed - trailSpeed) < -0.5
        % Gap is shrinking rapidly
        shouldMerge = false;
        recommendedSpeed = 0.5; % Inch forward strategy to signal intent
        return;
    end
    
    % Inch-forward strategy or full merge
    if gapInfo.length >= minRequiredGap * 1.5
        % Plenty of space
        shouldMerge = true;
        recommendedSpeed = min(leadSpeed, 5.0); % Merge smoothly
        targetGapPosition = [(gapInfo.startX + gapInfo.endX)/2, (gapInfo.startY + gapInfo.endY)/2];
    else
        % Tight space, inch forward
        shouldMerge = false;
        recommendedSpeed = 1.0; % Inch forward slowly
    end
end
