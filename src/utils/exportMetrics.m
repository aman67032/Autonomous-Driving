function exportMetrics(metrics, scenarioName)
    % EXPORTMETRICS Exports metrics to CSV in results/metrics/ and prints summary
    
    outDir = fullfile(pwd, 'results', 'metrics');
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    
    outFile = fullfile(outDir, 'simulation_metrics.csv');
    
    % Add scenario name to the struct
    metrics.Scenario = scenarioName;
    
    % Ensure specific field order for CSV
    t = struct2table(metrics);
    
    % Append or write new
    if exist(outFile, 'file')
        writetable(t, outFile, 'WriteMode', 'append');
    else
        writetable(t, outFile);
    end
    
    % Print summary to console
    fprintf('\n--- Metrics Summary for %s ---\n', scenarioName);
    fprintf('Collision Count: %d\n', metrics.collisionCount);
    fprintf('Min TTC: %.2f s\n', metrics.minTTC);
    fprintf('Avg Speed: %.2f m/s\n', metrics.avgSpeed);
    fprintf('Completion Rate: %.1f%%\n', metrics.completionRate);
    fprintf('--------------------------------------\n\n');
end
