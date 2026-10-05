function surfaceInfo = classifyRoadSurface(image)
    % classifyRoadSurface Classifies road conditions using simple image analysis
    
    grayImg = rgb2gray(image);
    
    % Calculate edge density
    edges = edge(grayImg, 'canny');
    edgeDensity = sum(edges(:)) / numel(edges);
    
    % Dummy heuristic logic for baseline
    if edgeDensity > 0.15
        surfaceType = 'gravel';
        confidence = 0.7;
    elseif edgeDensity > 0.08
        surfaceType = 'damaged';
        confidence = 0.6;
    else
        surfaceType = 'normal';
        confidence = 0.9;
    end
    
    % Return struct
    surfaceInfo = struct();
    surfaceInfo.surfaceType = surfaceType;
    surfaceInfo.confidence = confidence;
    % Assuming whole lower half of image is the road being classified
    [h, w, ~] = size(image);
    surfaceInfo.location = [1, round(h/2), w, round(h/2)]; % [x y w h]
end
