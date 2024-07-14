function [x, theta] = Simulator(A, J, B, K, N, dt, T, solver, x0, theta0, omega, varargin)
    % Parse optional input arguments
    p = inputParser;
    addParameter(p, 'F', 5, @(x) isnumeric(x) && isscalar(x));
    addParameter(p, 'Omega', 3*pi/2, @(x) isnumeric(x) && isscalar(x));
    addParameter(p, 'x0_ext', [0, 0], @(x) isnumeric(x) && numel(x) == 2);
    addParameter(p, 'forced', false, @(x) islogical(x) && isscalar(x));
    addParameter(p, 'pinned', false, @(x) islogical(x) && isscalar(x));
    parse(p, varargin{:});
    
    F = p.Results.F;
    Omega = p.Results.Omega;
    x0_forced = p.Results.x0_ext;
    forced = p.Results.forced;
    pinned = p.Results.pinned;

    % Combine initial conditions into a single column vector
    y0 = [x0(:); theta0];

    % Time span
    tspan = [0 T];

    if pinned
        odefun = @swarmalator_pinned_ode;
        ode_params = {A, J, B, K, F, Omega, N, omega, x0_forced};
    elseif forced
        odefun = @swarmalator_forced_ode;
        ode_params = {A, J, B, K, F, Omega, N, omega, x0_forced};
    else
        odefun = @swarmalator_ode;
        ode_params = {A, J, B, K, N, omega};
    end

    if solver == "Heun"
        % Solve the system using Heun method
        [t, y] = heun_method(odefun, tspan, y0, dt, ode_params);
    else
        % Solve the system using Euler method
        [t, y] = euler_method(odefun, tspan, y0, dt, ode_params);
    end

    % Extract positions and phases from solution
    x = reshape(y(1:2*N, :), [N, 2, length(t)]);
    theta = y(2*N+1:3*N, :);

    % Remap angles to be within [-pi, pi]
    theta = mod(theta + pi, 2*pi) - pi;
end
