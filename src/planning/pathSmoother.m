function [smoothPath, curvature, heading] = pathSmoother(waypoints, vehParams, p_smooth)
% pathSmoother - Smooths a raw path using cubic spline interpolation
%
% Inputs:
%   waypoints - Nx2 matrix of [x, y] coordinates
%   vehParams - Struct containing vehicle constraints like 'minTurningRadius'
%   p_smooth  - (optional) Smoothing parameter [0, 1] (default: 0.5)
%
% Outputs:
%   smoothPath - Mx2 matrix of smoothed fine-resolution waypoints
%   curvature  - Mx1 vector of curvature at each point
%   heading    - Mx1 vector of heading angles at each point

    if nargin < 3 || isempty(p_smooth)
        p_smooth = 0.5; % 0 = linear, 1 = natural cubic spline
    end

    if size(waypoints, 1) < 3
        smoothPath = waypoints;
        curvature = zeros(size(waypoints,1), 1);
        heading = zeros(size(waypoints,1), 1);
        return;
    end

    % Cumulative distance as parameter
    dp = sqrt(sum(diff(waypoints).^2, 2));
    p = [0; cumsum(dp)];
    
    % Finer resolution for output
    p_fine = linspace(0, p(end), length(p)*10);
    
    % Fit cubic splines using built-in base MATLAB spline
    x_fine = spline(p, waypoints(:,1), p_fine);
    y_fine = spline(p, waypoints(:,2), p_fine);
    smoothPath = [x_fine(:), y_fine(:)];
    
    % Compute numerical derivatives for curvature and heading
    dp_step = p_fine(2) - p_fine(1);
    dx = gradient(x_fine, dp_step);
    dy = gradient(y_fine, dp_step);
    ddx = gradient(dx, dp_step);
    ddy = gradient(dy, dp_step);
    
    % Heading
    heading = atan2(dy(:), dx(:));
    
    % Curvature: k = |dx*ddy - dy*ddx| / (dx^2 + dy^2)^(3/2)
    curvature = abs(dx(:) .* ddy(:) - dy(:) .* ddx(:)) ./ ((dx(:).^2 + dy(:).^2).^(3/2) + eps);
    
    % Check maximum curvature constraint
    if nargin > 1 && isfield(vehParams, 'minTurningRadius')
        maxCurvature = 1 / vehParams.minTurningRadius;
        if any(curvature > maxCurvature)
            warning('Smoothed path violates maximum curvature constraints.');
        end
    end
end
