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
dt = 0.1; % Time step
T = 50; % Total time
solver = "Euler";

% Varying parameters
J_values = 0:0.1:1; % Parameter J
K_values = -1:0.1:1; % Parameter K
F_ext_values = 0:0.1:10; % External force values
Omega_ext = 0.5*pi/2; % External frequency

% Preallocate results storage
results = struct();

% Generate initial conditions for all simulations
initial_conditions = cell(1, 1);
initial_seed = 12345; % Initial seed for reproducibility
rng(initial_seed); % Set the random seed
initial_conditions{1}.x0 = rand(N, 2) - 0.5; % Initial positions
initial_conditions{1}.theta0 = rand(N, 1) * 2 * pi - pi; % Initial phases

% Loop over configurations of J and K
parfor idx = 1:length(J_values)*length(K_values)
    [J_idx, K_idx] = ind2sub([length(J_values), length(K_values)], idx);
    J = J_values(J_idx);
    K = K_values(K_idx);
    fprintf('Running simulations for J=%.1f, K=%.1f\n', J, K);

    % Initialize local variables to store the minimal force
    min_F_ext = NaN;
    sync_achieved = false;

    % Run the simulation for each force value until synchronization is achieved
    for F_ext = F_ext_values
        % Retrieve initial conditions for this simulation
        x0 = initial_conditions{1}.x0;
        theta0 = initial_conditions{1}.theta0;
        omega = zeros(N, 1); % Frequencies

        % Run the simulation
        [x, theta] = Simulator(A, J, B, K, N, dt, T, solver, x0, theta0, omega, ...
            'forced', true, 'pinned', true, 'F', F_ext, 'Omega', Omega_ext, 'x0_ext', [0 0]);

        % Compute order parameters
        transient_period = 0; % Adjust if you have a specific transient period to discard
        [R, Zeta, Xi] = compute_order_parameters_pinned(theta, Omega_ext, T, dt);

        % Check if synchronization is achieved (R approximately 1)
        if (R > 0.99) && (Zeta < 0.01) 
            if (Xi < 11111.1)
                min_F_ext = F_ext;
                sync_achieved = true;
                break;
            end
        end
    end

    % Store results
    results(idx).J = J;
    results(idx).K = K;
    results(idx).min_F_ext = min_F_ext;
end

% Save results
save('minimal_forcing_results.mat', 'results');

% Optional: Plotting results or further analysis
