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

% External forcing parameters
force_values = [0, 1, 2, 5];
Omega_ext = 3*pi/2;

% Simulation states
states = [
    struct('J', 0.1, 'K', 1, 'id', 'StaticSync')
    struct('J', 0.1, 'K', -1, 'id', 'StaticAsync')
    struct('J', 1, 'K', 0, 'id', 'StaticPhaseWave')
    struct('J', 1, 'K', -0.1, 'id', 'SplinteredPhaseWave')
    struct('J', 1, 'K', -0.75, 'id', 'ActivePhaseWave')
];

solver = "Euler";
saveOutputs = true;

% Set Seed for Initial Conditions
rng(123); % Set the seed for reproducibility
x0 = rand(N, 2) - 0.5; % Initial positions
theta0 = rand(N, 1) * 2 * pi - pi; % Initial phases
omega = zeros(N, 1); % Frequencies

for i = 1:length(states)
    for F_ext = force_values
        simulation_id = sprintf('%s_Force%d', states(i).id, F_ext);
        
        % Create unique folder for the simulation
        simulation_folder = fullfile('Simulations', ['Simulation' simulation_id]);
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
            J = states(i).J;
            K = states(i).K;
            [x, theta] = Simulator(A, J, B, K, N, dt, T, solver, x0, theta0, omega, ...
                'forced', true, 'F', F_ext, 'Omega', Omega_ext, 'x0_ext', [0 0]);

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

        % Call plot functions
        % xy_plot(x, theta, dt, T, ...
        %     'generateLastFrameOnly', false, ...
        %     'savePath', figures_folder, ...
        %     'saveVideo', saveOutputs, ...
        %     'saveImage', saveOutputs, ...
        %     'showColorbar', false);
        % 
        % phi_theta_plot(x, theta, dt, T, ...
        %     'generateLastFrameOnly', false, ...
        %     'savePath', figures_folder, ...
        %     'saveVideo', saveOutputs, ...
        %     'saveImage', saveOutputs);

        xy_plot(x, theta, dt, T, ...
            'generateLastFrameOnly', false, ...
            'savePath', figures_folder, ...
            'saveVideo', saveOutputs, ...
            'saveImage', saveOutputs, ...
            'showColorbar', false, ...
            'hideElements', true);
    end
end
