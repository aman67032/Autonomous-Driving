% checkToolboxes.m
% Script to check for required and optional toolboxes for the SIH 2026 project.

clc;
disp('==================================================');
disp('   SIH 2026 - Toolbox Dependency Check');
disp('==================================================');
disp(' ');

installed_toolboxes = ver;
installed_names = {installed_toolboxes.Name};

% Define Required Toolboxes
required = {
    'Automated Driving Toolbox',
    'Computer Vision Toolbox',
    'Deep Learning Toolbox',
    'Navigation Toolbox',
    'Simulink',
    'Stateflow',
    'Signal Processing Toolbox'
};

% Define Optional Toolboxes
optional = {
    'Vehicle Dynamics Blockset',
    'Simulink Design Verifier',
    'Parallel Computing Toolbox',
    'GPU Coder'
};

disp('--- Required Toolboxes ---');
all_required_met = true;
for i = 1:length(required)
    tb = required{i};
    idx = find(strcmp(installed_names, tb));
    if ~isempty(idx)
        fprintf('✅ %-30s (v%s)\n', tb, installed_toolboxes(idx).Version);
    else
        fprintf('❌ %-30s (NOT FOUND)\n', tb);
        all_required_met = false;
    end
end

disp(' ');
disp('--- Optional/Recommended Toolboxes ---');
for i = 1:length(optional)
    tb = optional{i};
    idx = find(strcmp(installed_names, tb));
    if ~isempty(idx)
        fprintf('✅ %-30s (v%s)\n', tb, installed_toolboxes(idx).Version);
    else
        fprintf('❌ %-30s (NOT FOUND)\n', tb);
    end
end

disp(' ');
if all_required_met
    disp('SUCCESS: All required toolboxes are installed.');
else
    disp('WARNING: One or more required toolboxes are missing. Simulation may fail.');
end
disp('==================================================');
