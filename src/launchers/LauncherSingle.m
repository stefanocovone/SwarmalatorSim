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
T = 200; % Total time

J = .1; % Parameter J
K = 1; % Parameter K

% external forcing
forced = true;
F_ext = 10;
x0_ext = [0 0];
Omega_ext = pi/4;
% Omega_ext = 1;

% pinning control
pinned = true;

simulation_id = "gnagna";
saveOutputs = false;

solver = "Euler";

% Set Seed for Initial Conditions
rng(123); % Set the seed for reproducibility

% Initial conditions
x0 = rand(N,2) - 0.5; % Initial positions
theta0 = rand(N,1) * 2 * pi - pi; % Initial phases
% theta0 = rand(N,1)*0;
omega = zeros(N,1); % Frequencies
% omega = lorentzian_rnd(0.05, N);

% Create unique folder for the simulation
simulation_folder = fullfile('Simulations', 'Simulation' + simulation_id);
figures_folder = fullfile(simulation_folder, 'Figures');
data_file = fullfile(simulation_folder, 'simulation_data.mat');

if ~exist(simulation_folder, 'dir') && (saveOutputs == true)
    mkdir(simulation_folder);
end
if ~exist(figures_folder, 'dir') && (saveOutputs == true)
    mkdir(figures_folder);
end

% Check if simulation data already exists
if exist(data_file, 'file')
    % Load simulation data
    load(data_file, 'A', 'J', 'B', 'K', 'N', 'dt', 'T', ...
        'solver', 'x0', 'theta0', 'omega', 'x', 'theta', 'S', 'gamma');
else
    % Run the simulation
    [x, theta] = Simulator(A, J, B, K, N, dt, T, solver, x0, theta0, omega, ...
        'forced', true, 'pinned', pinned, 'F', F_ext, 'Omega', Omega_ext, 'x0_ext', x0_ext);

    % Compute order parameters
    transient_period = 0;
    [S, gamma] = compute_order_parameters(x, theta);

    % Save simulation data
    if saveOutputs == true
        save(data_file, 'A', 'J', 'B', 'K', 'N', 'dt', 'T', ...
            'solver', 'x0', 'theta0', 'omega', ...
            'x', 'theta', 'S', 'gamma');
    end
end

[R, Zeta, Xi, Ts] = compute_order_parameters_pinned(theta, Omega_ext, T, dt)

% Call plot functions
xy_plot(x, theta, dt, T, ...
    'generateLastFrameOnly', false, ...
    'savePath', figures_folder, ...
    'saveVideo', saveOutputs, ...
    'saveImage', saveOutputs, ...
    'showColorbar', false, ...
    'numSquares', 0);

phi_theta_plot(x, theta, dt, T, ...
    'generateLastFrameOnly', false, ...
    'savePath', figures_folder, ...
    'saveVideo', saveOutputs, ...
    'saveImage', saveOutputs, ...
    'plotOmegaLine', true, ...
    'omega', Omega_ext);

% xy_plot(x, theta, dt, T, ...
%     'generateLastFrameOnly', true, ...
%     'savePath', figures_folder, ...
%     'saveVideo', saveOutputs, ...
%     'saveImage', saveOutputs, ...
%     'showColorbar', false, ...
%     'hideElements',true);
