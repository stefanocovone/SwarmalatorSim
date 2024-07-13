clear
close all
clc

% Add src folder and its subfolders to path
addpath(genpath('src'));

% Parameters
A = 1; % Parameter A
B = 1; % Parameter B
N = 1000; % Number of swarmalators
dt = 0.1; % Time step
T = 50; % Total time

K = 0; % Parameter K
J_values = 0:0.1:1; % Values of parameter J

% Set Seed for Initial Conditions
rng(123); % Set the seed for reproducibility

% Initialize results array
max_radius_results = zeros(length(J_values), 1);
min_radius_results = zeros(length(J_values), 1);

% Loop over J values
for j_idx = 1:length(J_values)
    J = J_values(j_idx);

    % Simulation ID
    simulation_id = sprintf("K_%g_J_%g", K, J);

    solver = "Euler";

    % Initial conditions
    x0 = rand(N,2) - 0.5; % Initial positions
    theta0 = rand(N,1) * 2 * pi - pi; % Initial phases
    omega = zeros(N,1); % Frequencies

    % Create unique folder for the simulation
    simulation_folder = fullfile('Simulations/Max_Radius', 'Simulation_' + simulation_id);
    figures_folder = fullfile(simulation_folder, 'Figures');
    data_file = fullfile(simulation_folder, 'simulation_data.mat');

    if ~exist(simulation_folder, 'dir')
        mkdir(simulation_folder);
    end
    if ~exist(figures_folder, 'dir')
        mkdir(figures_folder);
    end

    % Check if simulation data already exists
    if exist(data_file, 'file')
        % Load simulation data
        load(data_file, 'A', 'J', 'B', 'K', 'N', 'dt', 'T', ...
            'solver', 'x0', 'theta0', 'omega', 'x', 'theta', 'S', 'gamma');
    else
        % Run the simulation
        [x, theta] = Simulator(A, J, B, K, N, dt, T, solver, x0, theta0, omega);

        % Compute order parameters
        transient_period = 0;
        [S, gamma] = compute_order_parameters(x, theta);

        % Save simulation data
        save(data_file, 'A', 'J', 'B', 'K', 'N', 'dt', 'T', ...
            'solver', 'x0', 'theta0', 'omega', ...
            'x', 'theta', 'S', 'gamma');
    end

    % Measure maximum and minimum radius at steady-state
    radii = sqrt(sum(x(:,:,end).^2, 2));
    max_radius = max(radii);
    min_radius = min(radii);
    max_radius_results(j_idx) = max_radius;
    min_radius_results(j_idx) = min_radius;
end

% Save results
results_file = fullfile('Simulations/Max_Radius', 'radius_results_K_0.mat');
save(results_file, 'J_values', 'max_radius_results', 'min_radius_results');

% Plot the maximum and minimum radius as a function of J
plot_maxmin_radii_vs_J(J_values, max_radius_results, min_radius_results, ...
    'savePath', 'Simulations/Max_Radius', ...
    'saveImage', true);
