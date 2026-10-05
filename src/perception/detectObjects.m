function detectedObjects = detectObjects(image, ptCloud, radarDets, options)
    % detectObjects Detects objects from multi-modal sensor data
    
    if nargin < 4
        options = struct();
    end
    
    indianClasses = {'car','truck','bus','auto_rickshaw','motorcycle',...
                     'bicycle','pedestrian','pushcart','cow','dog',...
                     'stray_animal','tractor','bullock_cart'};
                 
    detectedObjects = struct('id', {}, 'class', {}, 'bbox', {}, ...
        'position3D', {}, 'velocity', {}, 'confidence', {});
        
    % Fallback simple detector (ACF) if no YOLO
    detector = vehicleDetectorACF();
    
    % Detect using camera
    try
        [bboxes, scores] = detect(detector, image);
    catch
        bboxes = [];
        scores = [];
    end
    
    % Populate dummy 3D positions and classifications for the sake of the fallback
    for i = 1:size(bboxes,1)
        obj.id = i;
        % Randomly assign a class from indianClasses for demo purposes
        % In a real scenario, this would use a proper classifier
        idx = mod(i, length(indianClasses)) + 1;
        obj.class = indianClasses{idx};
        
        obj.bbox = bboxes(i, :);
        
        % Approximate 3D position based on bbox size and typical vehicle size (very rough fallback)
        width_pixels = obj.bbox(3);
        approx_dist = (800 * 2.0) / width_pixels; % focalLength * realWidth / pixelWidth
        obj.position3D = [approx_dist, 0, 0]; % [X Y Z]
        
        obj.velocity = [0 0 0];
        obj.confidence = scores(i);
        
        detectedObjects(end+1) = obj;
    end
end
