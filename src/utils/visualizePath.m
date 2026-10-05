function visualizePath(plannedPath, egoPos, trackedObjects, riskGrid)
    % VISUALIZEPATH Visualizes road layout, ego, obstacles, path, and risk grid
    
    persistent figHandle axHandle egoHandle objHandles pathHandle gridHandle
    
    if isempty(figHandle) || ~isvalid(figHandle)
        figHandle = figure('Name', 'Live Path and Risk Visualization', 'NumberTitle', 'off');
        axHandle = axes('Parent', figHandle);
        hold(axHandle, 'on');
        grid(axHandle, 'on');
        axis(axHandle, 'equal');
        xlabel(axHandle, 'X (m)');
        ylabel(axHandle, 'Y (m)');
        
        % Initialize risk grid image (heatmap)
        gridHandle = imagesc(axHandle, 'XData', [-50 50], 'YData', [-50 50], 'CData', zeros(100,100), 'AlphaData', 0.4);
        colormap(axHandle, jet);
        
        % Initialize ego vehicle
        egoHandle = rectangle(axHandle, 'Position', [0, 0, 4.7, 1.8], 'FaceColor', 'b', 'EdgeColor', 'k');
        
        % Initialize planned path
        pathHandle = plot(axHandle, 0, 0, 'g-', 'LineWidth', 2.5);
        objHandles = [];
    end
    
    % Update Ego
    egoHandle.Position = [egoPos(1)-2.35, egoPos(2)-0.9, 4.7, 1.8];
    
    % Update Planned Path
    if ~isempty(plannedPath)
        pathHandle.XData = plannedPath(:,1);
        pathHandle.YData = plannedPath(:,2);
    end
    
    % Update Risk Grid overlay
    if ~isempty(riskGrid)
        gridHandle.CData = riskGrid;
        gridHandle.XData = [egoPos(1)-50, egoPos(1)+50];
        gridHandle.YData = [egoPos(2)-50, egoPos(2)+50];
    end
    
    % Update Tracked Objects
    delete(objHandles);
    objHandles = [];
    for i = 1:size(trackedObjects, 1)
        objPos = trackedObjects(i,:);
        h = rectangle(axHandle, 'Position', [objPos(1)-1, objPos(2)-1, 2, 2], 'FaceColor', 'r', 'Curvature', 0.2);
        objHandles = [objHandles, h]; %#ok<AGROW>
    end
    
    % Follow ego with camera
    xlim(axHandle, [egoPos(1)-40, egoPos(1)+80]);
    ylim(axHandle, [egoPos(2)-40, egoPos(2)+40]);
    
    drawnow limitrate;
end
