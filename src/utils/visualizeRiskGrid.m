function visualizeRiskGrid(riskGrid, egoPos, obsPos)
    % VISUALIZERISKGRID Creates and saves a static heatmap figure of the risk grid
    
    fig = figure('Visible', 'off');
    ax = axes('Parent', fig);
    
    % Plot heatmap
    imagesc(ax, riskGrid);
    colormap(ax, jet);
    colorbar(ax);
    hold(ax, 'on');
    
    % Normalize positions relative to grid for overlay (assuming 100x100 grid centered at 50,50)
    plot(ax, 50, 50, 'bp', 'MarkerSize', 12, 'MarkerFaceColor', 'b');
    
    % Overlay Obstacles
    if ~isempty(obsPos)
        % Relative obs pos mapping (mocked for visual)
        relX = obsPos(:,1) - egoPos(1) + 50;
        relY = obsPos(:,2) - egoPos(2) + 50;
        plot(ax, relX, relY, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
    end
    
    title(ax, 'Risk Grid Heatmap');
    
    % Ensure output directory exists
    outDir = fullfile(pwd, 'results', 'plots', 'risk_grid_heatmaps');
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    
    % Save image
    timestamp = datestr(now, 'yyyymmdd_HHMMSS_FFF');
    filename = fullfile(outDir, sprintf('risk_grid_%s.png', timestamp));
    saveas(fig, filename);
    close(fig);
end
