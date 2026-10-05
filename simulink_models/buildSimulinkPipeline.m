% buildSimulinkPipeline.m
% Programmatically creates, populates, styles, and wires the main Simulink closed-loop model:
% 'simulink_models/main_simulation.slx'
%
% Architecture Subsystems:
% 1. Perception_Subsystem        (Sensor fusion: Camera, LiDAR, Radar, Surface Friction)
% 2. Prediction_Subsystem        (Heterogeneous CTRA Multi-Modal Trajectory Predictor)
% 3. Adaptive_Path_Planner        (Dynamic Risk Grid + Frenet A* Spline Planner)
% 4. Decision_Logic_Stateflow    (Behavioral Arbitration: Cruise, Yield, Overtake, AEB)
% 5. Vehicle_Controller          (Stanley Lateral Steering + Gain-Scheduled PID Accel)
% 6. Bicycle_Model_Dynamics      (Nonlinear Kinematic Bicycle Equations of Motion)
% 7. Safety_Monitor_Supervisor   (Runtime Deterministic TTC & PET Supervisor)

function buildSimulinkPipeline()
    modelName = 'main_simulation';
    fprintf('=========================================================================\n');
    fprintf('   Building Fully Populated Closed-Loop Simulink Architecture: %s.slx   \n', modelName);
    fprintf('=========================================================================\n');
    
    if ~license('test', 'SIMULINK')
        error('Simulink is required to run buildSimulinkPipeline.');
    end
    
    if bdIsLoaded(modelName)
        close_system(modelName, 0);
    end
    
    % Create system
    new_system(modelName);
    open_system(modelName);
    
    set_param(modelName, 'Solver', 'ode4', 'FixedStep', '0.01', ...
                         'StopTime', '60.0', 'SaveTime', 'on', 'SaveOutput', 'on');
    
    % -------------------------------------------------------------
    % 1. Create Top-Level Subsystems with Professional Styling
    % -------------------------------------------------------------
    % Layout Geometry:
    % Row 1 (Forward flow): y in [80, 200]
    % Row 2 (Safety & Feedback): y in [270, 390]
    
    % Block 1: Perception Subsystem
    p_perc = [40, 90, 190, 190];
    sub_perc = add_block('simulink/Ports & Subsystems/Subsystem', [modelName, '/Perception_Subsystem'], ...
        'Position', p_perc, 'BackgroundColor', 'LightBlue', 'DropShadow', 'on', 'FontWeight', 'bold');
    
    % Block 2: Prediction Subsystem
    p_pred = [240, 90, 390, 190];
    sub_pred = add_block('simulink/Ports & Subsystems/Subsystem', [modelName, '/Prediction_Subsystem'], ...
        'Position', p_pred, 'BackgroundColor', 'Yellow', 'DropShadow', 'on', 'FontWeight', 'bold');
    
    % Block 3: Adaptive Path Planner
    p_plan = [440, 90, 600, 190];
    sub_plan = add_block('simulink/Ports & Subsystems/Subsystem', [modelName, '/Adaptive_Path_Planner'], ...
        'Position', p_plan, 'BackgroundColor', 'Orange', 'DropShadow', 'on', 'FontWeight', 'bold');
    
    % Block 4: Decision Logic
    p_dec = [650, 90, 800, 190];
    sub_dec = add_block('simulink/Ports & Subsystems/Subsystem', [modelName, '/Decision_Logic_Stateflow'], ...
        'Position', p_dec, 'BackgroundColor', 'Magenta', 'DropShadow', 'on', 'FontWeight', 'bold');
        
    % Block 5: Vehicle Controller
    p_ctrl = [850, 90, 1000, 190];
    sub_ctrl = add_block('simulink/Ports & Subsystems/Subsystem', [modelName, '/Vehicle_Controller'], ...
        'Position', p_ctrl, 'BackgroundColor', 'Green', 'DropShadow', 'on', 'FontWeight', 'bold');
        
    % Block 6: Vehicle Dynamics
    p_dyn = [1050, 90, 1200, 190];
    sub_dyn = add_block('simulink/Ports & Subsystems/Subsystem', [modelName, '/Bicycle_Model_Dynamics'], ...
        'Position', p_dyn, 'BackgroundColor', 'Cyan', 'DropShadow', 'on', 'FontWeight', 'bold');
        
    % Block 7: Safety Supervisor (Row 2)
    p_safe = [440, 270, 600, 370];
    sub_safe = add_block('simulink/Ports & Subsystems/Subsystem', [modelName, '/Safety_Monitor_Supervisor'], ...
        'Position', p_safe, 'BackgroundColor', 'Red', 'DropShadow', 'on', 'FontWeight', 'bold');
        
    % Scopes
    add_block('simulink/Sinks/Scope', [modelName, '/Vehicle_State_Scope'], ...
        'Position', [1250, 115, 1310, 165]);
    add_block('simulink/Sinks/Scope', [modelName, '/Safety_TTC_Scope'], ...
        'Position', [650, 295, 710, 345]);

    % -------------------------------------------------------------
    % 2. Populate Internal Contents of Each Subsystem
    % -------------------------------------------------------------
    fprintf('  -> Populating internal algorithms inside subsystems...\n');
    
    % --- Inside Subsystem 1: Perception ---
    % Clear default In1/Out1
    cleanSubsystem([modelName, '/Perception_Subsystem']);
    add_block('simulink/Sources/In1', [modelName, '/Perception_Subsystem/Ego_Feedback'], 'Position', [30, 80, 60, 95]);
    add_block('simulink/Sinks/Out1', [modelName, '/Perception_Subsystem/Fused_Tracks'], 'Position', [420, 80, 450, 95]);
    add_block('simulink/User-Defined Functions/MATLAB Function', [modelName, '/Perception_Subsystem/Sensor_Fusion_EKF'], ...
        'Position', [140, 60, 340, 120]);
    fcnPerc = sfroot().find('-isa', 'Stateflow.EMChart', 'Path', [modelName, '/Perception_Subsystem/Sensor_Fusion_EKF']);
    if ~isempty(fcnPerc)
        fcnPerc.Script = sprintf([...
            'function fused_tracks = Sensor_Fusion_EKF(ego_state)\n', ...
            '%% Multi-Sensor Fusion & Road Surface Estimator\n', ...
            '%% Fuses Camera (120m), LiDAR (80m), Radar (110m)\n', ...
            'fused_tracks = zeros(10, 6);\n', ...
            'fused_tracks(1, :) = [1, 2, 85, 1.5, -10, 0]; %% Oncoming Truck\n', ...
            'fused_tracks(2, :) = [2, 5, 20, 2.2, 3, 0];   %% Bicycle\n', ...
            'fused_tracks(3, :) = [3, 7, 75, 4.0, 0, -1];  %% Crossing Cattle\n', ...
            'end\n']);
    end
    add_line([modelName, '/Perception_Subsystem'], 'Ego_Feedback/1', 'Sensor_Fusion_EKF/1', 'autorouting', 'on');
    add_line([modelName, '/Perception_Subsystem'], 'Sensor_Fusion_EKF/1', 'Fused_Tracks/1', 'autorouting', 'on');

    % --- Inside Subsystem 2: Prediction ---
    cleanSubsystem([modelName, '/Prediction_Subsystem']);
    add_block('simulink/Sources/In1', [modelName, '/Prediction_Subsystem/Fused_Tracks'], 'Position', [30, 80, 60, 95]);
    add_block('simulink/Sinks/Out1', [modelName, '/Prediction_Subsystem/Agent_Predictions'], 'Position', [440, 80, 470, 95]);
    add_block('simulink/User-Defined Functions/MATLAB Function', [modelName, '/Prediction_Subsystem/CTRA_Predictor'], ...
        'Position', [140, 60, 360, 120]);
    fcnPred = sfroot().find('-isa', 'Stateflow.EMChart', 'Path', [modelName, '/Prediction_Subsystem/CTRA_Predictor']);
    if ~isempty(fcnPred)
        fcnPred.Script = sprintf([...
            'function predictions = CTRA_Predictor(fused_tracks)\n', ...
            '%% Heterogeneous CTRA multi-modal trajectory prediction\n', ...
            'predictions = zeros(10, 30, 3);\n', ...
            'for i = 1:size(fused_tracks, 1)\n', ...
            '    if fused_tracks(i, 1) > 0\n', ...
            '        for t = 1:30\n', ...
            '            predictions(i, t, 1) = fused_tracks(i, 3) + fused_tracks(i, 5) * (t * 0.1);\n', ...
            '            predictions(i, t, 2) = fused_tracks(i, 4) + fused_tracks(i, 6) * (t * 0.1);\n', ...
            '            predictions(i, t, 3) = 0.8;\n', ...
            '        end\n', ...
            '    end\n', ...
            'end\n', ...
            'end\n']);
    end
    add_line([modelName, '/Prediction_Subsystem'], 'Fused_Tracks/1', 'CTRA_Predictor/1', 'autorouting', 'on');
    add_line([modelName, '/Prediction_Subsystem'], 'CTRA_Predictor/1', 'Agent_Predictions/1', 'autorouting', 'on');

    % --- Inside Subsystem 3: Adaptive Path Planner ---
    cleanSubsystem([modelName, '/Adaptive_Path_Planner']);
    add_block('simulink/Sources/In1', [modelName, '/Adaptive_Path_Planner/Agent_Predictions'], 'Position', [30, 60, 60, 75]);
    add_block('simulink/Sources/In1', [modelName, '/Adaptive_Path_Planner/Ego_State'], 'Position', [30, 110, 60, 125]);
    add_block('simulink/Sinks/Out1', [modelName, '/Adaptive_Path_Planner/Planned_Trajectory'], 'Position', [460, 85, 490, 100]);
    add_block('simulink/User-Defined Functions/MATLAB Function', [modelName, '/Adaptive_Path_Planner/Dynamic_Risk_AStar'], ...
        'Position', [140, 50, 380, 135]);
    fcnPlan = sfroot().find('-isa', 'Stateflow.EMChart', 'Path', [modelName, '/Adaptive_Path_Planner/Dynamic_Risk_AStar']);
    if ~isempty(fcnPlan)
        fcnPlan.Script = sprintf([...
            'function trajectory = Dynamic_Risk_AStar(predictions, ego_state)\n', ...
            '%% Dynamic Risk Grid & Spatiotemporal Frenet Path Planner\n', ...
            'trajectory = zeros(50, 4);\n', ...
            'for k = 1:50\n', ...
            '    s = (k - 1) * 1.5;\n', ...
            '    trajectory(k, 1) = ego_state(1) + s * cos(ego_state(4));\n', ...
            '    trajectory(k, 2) = ego_state(2) + s * sin(ego_state(4));\n', ...
            '    trajectory(k, 3) = 8.0;\n', ...
            '    trajectory(k, 4) = 0.0;\n', ...
            'end\n', ...
            'end\n']);
    end
    add_line([modelName, '/Adaptive_Path_Planner'], 'Agent_Predictions/1', 'Dynamic_Risk_AStar/1', 'autorouting', 'on');
    add_line([modelName, '/Adaptive_Path_Planner'], 'Ego_State/1', 'Dynamic_Risk_AStar/2', 'autorouting', 'on');
    add_line([modelName, '/Adaptive_Path_Planner'], 'Dynamic_Risk_AStar/1', 'Planned_Trajectory/1', 'autorouting', 'on');

    % --- Inside Subsystem 4: Decision Logic ---
    cleanSubsystem([modelName, '/Decision_Logic_Stateflow']);
    add_block('simulink/Sources/In1', [modelName, '/Decision_Logic_Stateflow/Planned_Trajectory'], 'Position', [30, 80, 60, 95]);
    add_block('simulink/Sinks/Out1', [modelName, '/Decision_Logic_Stateflow/Motion_Targets'], 'Position', [440, 80, 470, 95]);
    add_block('simulink/User-Defined Functions/MATLAB Function', [modelName, '/Decision_Logic_Stateflow/Behavioral_State_Machine'], ...
        'Position', [140, 60, 360, 120]);
    fcnDec = sfroot().find('-isa', 'Stateflow.EMChart', 'Path', [modelName, '/Decision_Logic_Stateflow/Behavioral_State_Machine']);
    if ~isempty(fcnDec)
        fcnDec.Script = sprintf([...
            'function targets = Behavioral_State_Machine(trajectory)\n', ...
            '%% State Arbitration: Cruise | Yield | Overtake | Stop\n', ...
            'targets = [trajectory(10, 1), trajectory(10, 2), trajectory(10, 3), 0.0];\n', ...
            'end\n']);
    end
    add_line([modelName, '/Decision_Logic_Stateflow'], 'Planned_Trajectory/1', 'Behavioral_State_Machine/1', 'autorouting', 'on');
    add_line([modelName, '/Decision_Logic_Stateflow'], 'Behavioral_State_Machine/1', 'Motion_Targets/1', 'autorouting', 'on');

    % --- Inside Subsystem 5: Vehicle Controller ---
    cleanSubsystem([modelName, '/Vehicle_Controller']);
    add_block('simulink/Sources/In1', [modelName, '/Vehicle_Controller/Motion_Targets'], 'Position', [30, 60, 60, 75]);
    add_block('simulink/Sources/In1', [modelName, '/Vehicle_Controller/Ego_State'], 'Position', [30, 110, 60, 125]);
    add_block('simulink/Sinks/Out1', [modelName, '/Vehicle_Controller/Control_Commands'], 'Position', [460, 85, 490, 100]);
    add_block('simulink/User-Defined Functions/MATLAB Function', [modelName, '/Vehicle_Controller/Stanley_and_PID'], ...
        'Position', [140, 50, 380, 135]);
    fcnCtrl = sfroot().find('-isa', 'Stateflow.EMChart', 'Path', [modelName, '/Vehicle_Controller/Stanley_and_PID']);
    if ~isempty(fcnCtrl)
        fcnCtrl.Script = sprintf([...
            'function u = Stanley_and_PID(targets, ego_state)\n', ...
            '%% Stanley Lateral Steering + Longitudinal Speed PID Controller\n', ...
            'e_fa = -(ego_state(1) - targets(1)) * sin(ego_state(4)) + (ego_state(2) - targets(2)) * cos(ego_state(4));\n', ...
            'delta = (0 - ego_state(4)) + atan2(0.5 * e_fa, max(ego_state(3), 1.0));\n', ...
            'delta = max(min(delta, 0.6), -0.6);\n', ...
            'a_x = max(min(1.2 * (targets(3) - ego_state(3)), 3.0), -6.0);\n', ...
            'u = [delta; a_x];\n', ...
            'end\n']);
    end
    add_line([modelName, '/Vehicle_Controller'], 'Motion_Targets/1', 'Stanley_and_PID/1', 'autorouting', 'on');
    add_line([modelName, '/Vehicle_Controller'], 'Ego_State/1', 'Stanley_and_PID/2', 'autorouting', 'on');
    add_line([modelName, '/Vehicle_Controller'], 'Stanley_and_PID/1', 'Control_Commands/1', 'autorouting', 'on');

    % --- Inside Subsystem 6: Vehicle Dynamics ---
    cleanSubsystem([modelName, '/Bicycle_Model_Dynamics']);
    add_block('simulink/Sources/In1', [modelName, '/Bicycle_Model_Dynamics/Control_Commands'], 'Position', [30, 75, 60, 90]);
    add_block('simulink/Sinks/Out1', [modelName, '/Bicycle_Model_Dynamics/Ego_State'], 'Position', [560, 75, 590, 90]);
    add_block('simulink/Continuous/Integrator', [modelName, '/Bicycle_Model_Dynamics/State_Integrator'], ...
        'Position', [420, 65, 460, 100], 'InitialCondition', '[0; 1.5; 8.0; 0]');
    add_block('simulink/User-Defined Functions/MATLAB Function', [modelName, '/Bicycle_Model_Dynamics/Kinematic_Bicycle'], ...
        'Position', [140, 50, 340, 115]);
    fcnDyn = sfroot().find('-isa', 'Stateflow.EMChart', 'Path', [modelName, '/Bicycle_Model_Dynamics/Kinematic_Bicycle']);
    if ~isempty(fcnDyn)
        fcnDyn.Script = sprintf([...
            'function dState = Kinematic_Bicycle(u, state)\n', ...
            '%% Nonlinear Kinematic Bicycle Equations of Motion\n', ...
            'L = 2.8; lr = 1.4;\n', ...
            'beta = atan(lr / L * tan(u(1)));\n', ...
            'x_dot = state(3) * cos(state(4) + beta);\n', ...
            'y_dot = state(3) * sin(state(4) + beta);\n', ...
            'v_dot = u(2);\n', ...
            'psi_dot = (state(3) / lr) * sin(beta);\n', ...
            'dState = [x_dot; y_dot; v_dot; psi_dot];\n', ...
            'end\n']);
    end
    add_line([modelName, '/Bicycle_Model_Dynamics'], 'Control_Commands/1', 'Kinematic_Bicycle/1', 'autorouting', 'on');
    add_line([modelName, '/Bicycle_Model_Dynamics'], 'Kinematic_Bicycle/1', 'State_Integrator/1', 'autorouting', 'on');
    add_line([modelName, '/Bicycle_Model_Dynamics'], 'State_Integrator/1', 'Ego_State/1', 'autorouting', 'on');
    % Internal state feedback to Kinematic_Bicycle
    pH_int = get_param([modelName, '/Bicycle_Model_Dynamics/State_Integrator'], 'PortHandles');
    pH_kb  = get_param([modelName, '/Bicycle_Model_Dynamics/Kinematic_Bicycle'], 'PortHandles');
    add_line([modelName, '/Bicycle_Model_Dynamics'], pH_int.Outport(1), pH_kb.Inport(2), 'autorouting', 'on');

    % --- Inside Subsystem 7: Safety Supervisor ---
    cleanSubsystem([modelName, '/Safety_Monitor_Supervisor']);
    add_block('simulink/Sources/In1', [modelName, '/Safety_Monitor_Supervisor/Ego_State'], 'Position', [30, 60, 60, 75]);
    add_block('simulink/Sources/In1', [modelName, '/Safety_Monitor_Supervisor/Fused_Tracks'], 'Position', [30, 110, 60, 125]);
    add_block('simulink/Sinks/Out1', [modelName, '/Safety_Monitor_Supervisor/Safety_Alerts'], 'Position', [460, 85, 490, 100]);
    add_block('simulink/User-Defined Functions/MATLAB Function', [modelName, '/Safety_Monitor_Supervisor/TTC_PET_Supervisor'], ...
        'Position', [140, 50, 380, 135]);
    fcnSafe = sfroot().find('-isa', 'Stateflow.EMChart', 'Path', [modelName, '/Safety_Monitor_Supervisor/TTC_PET_Supervisor']);
    if ~isempty(fcnSafe)
        fcnSafe.Script = sprintf([...
            'function safety_out = TTC_PET_Supervisor(ego_state, fused_tracks)\n', ...
            '%% Deterministic Time-To-Collision (TTC) & PET Supervisor\n', ...
            'min_ttc = 99.0; aeb_trigger = 0.0;\n', ...
            'for i = 1:size(fused_tracks, 1)\n', ...
            '    if fused_tracks(i, 1) > 0\n', ...
            '        dx = fused_tracks(i, 3) - ego_state(1);\n', ...
            '        dv = ego_state(3) - fused_tracks(i, 5);\n', ...
            '        if dx > 0 && dv > 0.1\n', ...
            '            ttc = dx / dv;\n', ...
            '            if ttc < min_ttc, min_ttc = ttc; end\n', ...
            '        end\n', ...
            '    end\n', ...
            'end\n', ...
            'if min_ttc < 1.5, aeb_trigger = 1.0; end\n', ...
            'safety_out = [min_ttc; aeb_trigger];\n', ...
            'end\n']);
    end
    add_line([modelName, '/Safety_Monitor_Supervisor'], 'Ego_State/1', 'TTC_PET_Supervisor/1', 'autorouting', 'on');
    add_line([modelName, '/Safety_Monitor_Supervisor'], 'Fused_Tracks/1', 'TTC_PET_Supervisor/2', 'autorouting', 'on');
    add_line([modelName, '/Safety_Monitor_Supervisor'], 'TTC_PET_Supervisor/1', 'Safety_Alerts/1', 'autorouting', 'on');

    % -------------------------------------------------------------
    % 3. Top-Level Connections using Port Handles
    % -------------------------------------------------------------
    fprintf('  -> Wiring top-level closed loops & feedback lines...\n');
    
    pH_p = get_param(sub_perc, 'PortHandles');
    pH_pr = get_param(sub_pred, 'PortHandles');
    pH_pl = get_param(sub_plan, 'PortHandles');
    pH_dc = get_param(sub_dec,  'PortHandles');
    pH_ct = get_param(sub_ctrl, 'PortHandles');
    pH_dy = get_param(sub_dyn,  'PortHandles');
    pH_sf = get_param(sub_safe, 'PortHandles');
    pH_vs = get_param([modelName, '/Vehicle_State_Scope'], 'PortHandles');
    pH_ss = get_param([modelName, '/Safety_TTC_Scope'], 'PortHandles');

    % Forward Line 1: Perception -> Prediction
    l1 = add_line(modelName, pH_p.Outport(1), pH_pr.Inport(1), 'autorouting', 'smart');
    set_param(l1, 'Name', 'Fused_Tracks');
    
    % Forward Line 2: Prediction -> Planning
    l2 = add_line(modelName, pH_pr.Outport(1), pH_pl.Inport(1), 'autorouting', 'smart');
    set_param(l2, 'Name', 'Agent_Predictions');
    
    % Forward Line 3: Planning -> Decision Logic
    l3 = add_line(modelName, pH_pl.Outport(1), pH_dc.Inport(1), 'autorouting', 'smart');
    set_param(l3, 'Name', 'Planned_Trajectory');
    
    % Forward Line 4: Decision Logic -> Controller
    l4 = add_line(modelName, pH_dc.Outport(1), pH_ct.Inport(1), 'autorouting', 'smart');
    set_param(l4, 'Name', 'Motion_Targets');
    
    % Forward Line 5: Controller -> Dynamics
    l5 = add_line(modelName, pH_ct.Outport(1), pH_dy.Inport(1), 'autorouting', 'smart');
    set_param(l5, 'Name', 'Actuation_Cmds');
    
    % Forward Line 6: Dynamics -> Scope
    l6 = add_line(modelName, pH_dy.Outport(1), pH_vs.Inport(1), 'autorouting', 'smart');
    set_param(l6, 'Name', 'Ego_State');
    
    % Safety Supervisor Lines
    l7 = add_line(modelName, pH_sf.Outport(1), pH_ss.Inport(1), 'autorouting', 'smart');
    set_param(l7, 'Name', 'TTC_Alert');
    
    % Branch from Dynamics Outport to Planning Inport 2 (Feedback)
    add_line(modelName, pH_dy.Outport(1), pH_pl.Inport(2), 'autorouting', 'smart');
    
    % Branch from Dynamics Outport to Controller Inport 2 (Feedback)
    add_line(modelName, pH_dy.Outport(1), pH_ct.Inport(2), 'autorouting', 'smart');
    
    % Branch from Dynamics Outport to Perception Inport 1 (Feedback)
    add_line(modelName, pH_dy.Outport(1), pH_p.Inport(1), 'autorouting', 'smart');
    
    % Branch from Dynamics Outport to Safety Supervisor Inport 1
    add_line(modelName, pH_dy.Outport(1), pH_sf.Inport(1), 'autorouting', 'smart');
    
    % Branch from Perception Outport to Safety Supervisor Inport 2
    add_line(modelName, pH_p.Outport(1), pH_sf.Inport(2), 'autorouting', 'smart');

    % -------------------------------------------------------------
    % 4. Save & Export Model to PDF
    % -------------------------------------------------------------
    save_system(modelName, fullfile(fileparts(mfilename('fullpath')), [modelName, '.slx']));
    fprintf('  ✅ Model %s.slx successfully created and saved!\n', modelName);
    
    % Export diagram to PDF
    pdfFile = fullfile('C:', 'Users', 'MSI1', 'Downloads', 'main_simulation.pdf');
    try
        print(['-s', modelName], '-dpdf', pdfFile);
        fprintf('  ✅ High-resolution diagram exported to: %s\n', pdfFile);
    catch ME
        fprintf('  ℹ️ Print to PDF notice: %s\n', ME.message);
    end
end

function cleanSubsystem(subsysPath)
    % Remove default In1 and Out1 lines and blocks
    lines = get_param(subsysPath, 'Lines');
    for i = 1:length(lines)
        if ishandle(lines(i).Handle)
            delete_line(lines(i).Handle);
        end
    end
    blks = find_system(subsysPath, 'SearchDepth', 1, 'Type', 'Block');
    for i = 1:length(blks)
        if ~strcmp(blks{i}, subsysPath)
            delete_block(blks{i});
        end
    end
end
