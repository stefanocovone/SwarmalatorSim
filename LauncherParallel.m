% Check the number of available computational threads
maxThreads = maxNumCompThreads;

% Initialize parallel pool with the maximum number of available threads
if isempty(gcp('nocreate'))
    parpool(4);
end

% Your simulation code here
clear
close all
clc

% Add src folder and its subfolders to path
addpath(genpath('src'));

% Parameters
A = 1; % Parameter A
B = 1; % Parameter B
N = 100; % Number of swarmalators
dt = 0.5; % Time step
T = 1000; % Total time
solver = "Euler";

% Varying parameters
J_values = 0:0.05:1; % Parameter J
K_values = -1:0.05:0; % Parameter K
num_simulations = 2; % Number of simulations for each configuration

% Preallocate results storage
results = struct();

% Generate initial conditions for all simulations
initial_conditions = cell(num_simulations, 1);
initial_seed = 12345; % Initial seed for reproducibility
rng(initial_seed); % Set the random seed
for sim = 1:num_simulations
    initial_conditions{sim}.x0 = rand(N, 2) - 0.5; % Initial positions
    initial_conditions{sim}.theta0 = rand(N, 1) * 2 * pi - pi; % Initial phases
end

% Loop over configurations of J and K
parfor idx = 1:length(J_values)*length(K_values)
    [J_idx, K_idx] = ind2sub([length(J_values), length(K_values)], idx);
    J = J_values(J_idx);
    K = K_values(K_idx);
    fprintf('Running simulations for J=%.1f, K=%.1f\n', J, K);
    
    % Preallocate storage for each configuration in the parfor loop
    local_results = struct('J', [], 'K', [], 'S', [], 'gamma', []);
    local_results.J = J;
    local_results.K = K;
    local_results.S = zeros(1, num_simulations);
    local_results.gamma = zeros(1, num_simulations);
    
    % Run multiple simulations for each configuration
    for sim = 1:num_simulations
        % Retrieve initial conditions for this simulation
        x0 = initial_conditions{sim}.x0;
        theta0 = initial_conditions{sim}.theta0;
        omega = zeros(N, 1); % Frequencies
        
        % Run the simulation
        [x, theta] = Simulator(A, J, B, K, N, dt, T, solver, x0, theta0, omega);
        
        % Compute order parameters
        transient_period = 0; % Adjust if you have a specific transient period to discard
        [S, gamma] = compute_order_parameters(x, theta);
        
        % Store results
        local_results.S(sim) = S;
        local_results.gamma(sim) = gamma;
    end
    
    % Store local results in the overall results structure
    results(idx).J = local_results.J;
    results(idx).K = local_results.K;
    results(idx).S = local_results.S;
    results(idx).gamma = local_results.gamma;
end

% Save results
save('simulation_resultsN100.mat', 'results');

% Optional: Plotting results or further analysis