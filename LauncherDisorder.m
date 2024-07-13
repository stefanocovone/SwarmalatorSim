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
N = 500; % Number of swarmalators
dt = 0.5; % Time step
T = 1000; % Total time
solver = "Euler";
J = 0.5; % Parameter J

% Values for sigma
sigma_values = [0, 0.01, 0.02, 0.03];

% Varying parameter K
K_values = 0:-0.01:-0.7; % Parameter K
num_simulations = 5; % Number of simulations for each configuration

% Generate common initial conditions for all simulations
initial_seed = 12345; % Initial seed for reproducibility
rng(initial_seed); % Set the random seed
x0 = rand(N, 2) - 0.5; % Initial positions
theta0 = rand(N, 1) * 2 * pi - pi; % Initial phases

% Loop over configurations of sigma and K
for sigma = sigma_values
    % Generate common frequencies for the given sigma value
    omega = lorentzian_rnd(sigma, N);

    % Preallocate results storage
    results = struct();

    % Loop over configurations of K
    parfor idx = 1:length(K_values)
        K = K_values(idx);
        fprintf('Running simulations for J=%.1f, K=%.2f, sigma=%.2f\n', J, K, sigma);

        % Preallocate storage for each configuration in the parfor loop
        local_results = struct('J', [], 'K', [], 'sigma', [], 'S', [], 'gamma', []);
        local_results.J = J;
        local_results.K = K;
        local_results.sigma = sigma;
        local_results.S = zeros(1, num_simulations);
        local_results.gamma = zeros(1, num_simulations);

        % Run multiple simulations for each configuration
        for sim = 1:num_simulations
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
        results(idx).sigma = local_results.sigma;
        results(idx).S = local_results.S;
        results(idx).gamma = local_results.gamma;
    end

    % Save results
    save(sprintf('simulation_results_sigma_%.2f.mat', sigma), 'results');
end

% Optional: Plotting results or further analysis
