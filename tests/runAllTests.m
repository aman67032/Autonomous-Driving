% runAllTests.m
% Master test runner for the entire SIH 2026 Autonomous Driving Pipeline
function runAllTests()
    clc;
    fprintf('========================================================\n');
    fprintf('  SIH 2026: Autonomous Driving Test Suite Runner        \n');
    fprintf('  Problem: 26037 - Unstructured Indian Road Navigation  \n');
    fprintf('========================================================\n\n');
    
    % Add necessary paths
    baseDir = fileparts(mfilename('fullpath'));
    projectRoot = fileparts(baseDir);
    
    addpath(fullfile(projectRoot, 'config'));
    addpath(fullfile(projectRoot, 'src', 'perception'));
    addpath(fullfile(projectRoot, 'src', 'prediction'));
    addpath(fullfile(projectRoot, 'src', 'planning'));
    addpath(fullfile(projectRoot, 'src', 'decision'));
    addpath(fullfile(projectRoot, 'src', 'control'));
    addpath(fullfile(projectRoot, 'src', 'safety'));
    addpath(fullfile(projectRoot, 'src', 'utils'));
    addpath(fullfile(projectRoot, 'src', 'data_loader'));
    addpath(fullfile(projectRoot, 'scenarios'));
    addpath(fullfile(projectRoot, 'tests'));
    
    testFunctions = {
        @test_vehicleDynamics,
        @test_trajectoryPrediction,
        @test_pathPlanner,
        @test_safetyMonitor,
        @test_allScenarios
    };
    
    totalTests = length(testFunctions);
    passCount = 0;
    startTime = tic;
    
    for i = 1:totalTests
        fn = testFunctions{i};
        fnName = func2str(fn);
        fprintf('[%d/%d] Executing %s...\n', i, totalTests, fnName);
        try
            fn();
            passCount = passCount + 1;
        catch ME
            fprintf('  ❌ FAILED: %s\n', fnName);
            fprintf('     Error message: %s\n', ME.message);
            fprintf('     Location: line %d in %s\n\n', ME.stack(1).line, ME.stack(1).file);
        end
    end
    
    elapsed = toc(startTime);
    fprintf('========================================================\n');
    fprintf('  SUMMARY: %d / %d Tests Passed (%.1f%%) in %.2f seconds\n', ...
        passCount, totalTests, (passCount / totalTests) * 100, elapsed);
    fprintf('========================================================\n');
    
    if passCount == totalTests
        fprintf('  STATUS: ALL TESTS PASSED! Ready for full scenario runs.\n\n');
    else
        fprintf('  STATUS: SOME TESTS FAILED. Please review error logs.\n\n');
    end
end
