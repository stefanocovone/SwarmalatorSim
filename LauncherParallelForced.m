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
dt = 0.01; % Time step
T = 100; % Total time
solver = "Euler";

% Varying parameters
F_values = -7:0.1:7; % Amplitude F
Omega_values = [0, pi/2, pi, 3*pi/2]; % Frequency Omega
num_simulations = 1; % Number of simulations for each configuration

% Define states
states = struct('id', {'StaticSync', 'StaticAsync', 'StaticPhaseWave', 'SplinteredPhaseWave', 'ActivePhaseWave'}, ...
                'J', {0.1, 0.1, 1, 1, 1}, ...
                'K', {1, -1, 0, -0.1, -0.75});

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

% Loop over states
for state_idx = 1:length(states)
    state = states(state_idx);

    % Loop over configurations of F and Omega
    parfor idx = 1:length(F_values)*length(Omega_values)
        [F_idx, Omega_idx] = ind2sub([length(F_values), length(Omega_values)], idx);
        F = F_values(F_idx);
        Omega = Omega_values(Omega_idx);
        fprintf('Running simulations for state=%s, F=%.1f, Omega=%.2f\n', state.id, F, Omega);

        % Preallocate storage for each configuration in the parfor loop
        local_results = struct('state', state.id, 'F', F, 'Omega', Omega, 'S', [], 'R', []);
        local_results.S = zeros(1, num_simulations);
        local_results.R = zeros(1, num_simulations);

        % Run multiple simulations for each configuration
        for sim = 1:num_simulations
            % Retrieve initial conditions for this simulation
            x0 = initial_conditions{sim}.x0;
            theta0 = initial_conditions{sim}.theta0;
            omega = zeros(N, 1); % Frequencies

            % Run the simulation
            [x, theta] = Simulator(A, state.J, B, state.K, N, dt, T, solver, x0, theta0, omega, ...
                                   'forced', true, 'F', F, 'Omega', Omega, 'x0_ext', [0, 0]);

            % Compute order parameters
            [S, R] = compute_order_parameters_forced(x, theta);

            % Store results
            local_results.S(sim) = S;
            local_results.R(sim) = R;
        end

        % Store local results in the overall results structure
        results(state_idx, idx).state = local_results.state;
        results(state_idx, idx).F = local_results.F;
        results(state_idx, idx).Omega = local_results.Omega;
        results(state_idx, idx).S = local_results.S;
        results(state_idx, idx).R = local_results.R;
    end
end

% Save results
save('simulation_results_forced.mat', 'results');
