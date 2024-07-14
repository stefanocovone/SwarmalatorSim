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
T = 10; % Total time
solver = "Euler";

% Fixed J value
J = 0.5; % Parameter J
% Varying K and F_ext parameters
K_values = [-1, 0, 1]; % Parameter K
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

% Loop over configurations of K and F_ext
for K_idx = 1:length(K_values)
    K = K_values(K_idx);
    for F_ext_idx = 1:length(F_ext_values)
        F_ext = F_ext_values(F_ext_idx);
        fprintf('Running simulations for K=%.1f, F_ext=%.1f\n', K, F_ext);

        % Retrieve initial conditions for this simulation
        x0 = initial_conditions{1}.x0;
        theta0 = initial_conditions{1}.theta0;
        omega = zeros(N, 1); % Frequencies

        % Run the simulation
        [x, theta] = Simulator(A, J, B, K, N, dt, T, solver, x0, theta0, omega, ...
            'forced', true, 'pinned', true, 'F', F_ext, 'Omega', Omega_ext, 'x0_ext', [0 0]);

        % Compute order parameters
        transient_period = 0; % Adjust if you have a specific transient period to discard
        [R, Zeta, Xi, Ts] = compute_order_parameters_pinned(theta, Omega_ext, T, dt);

        % Store results
        results(K_idx, F_ext_idx).J = J;
        results(K_idx, F_ext_idx).K = K;
        results(K_idx, F_ext_idx).F_ext = F_ext;
        results(K_idx, F_ext_idx).R = R;
        results(K_idx, F_ext_idx).Zeta = Zeta;
        results(K_idx, F_ext_idx).Xi = Xi;
        results(K_idx, F_ext_idx).Ts = Ts;
    end
end

% Save results
save('Ts_results.mat', 'results');
