function plot_phase_transitions(dataFolder, fileName, savePath, parameter)
% plot_phase_transitions Plot the steady states of the order parameters.
%
% Inputs:
%   dataFolder - Folder containing the simulation results
%   fileName - Name of the .mat file with simulation results
%   savePath - Path to save the figures
%   parameter - 'S' or 'R' to specify which parameter to plot

% Load simulation results
load(fullfile(dataFolder, fileName), 'results');

results = reshape(results, [], 1);

% Extract unique values for F and Omega
F_values = unique([results.F]);
Omega_values = unique([results.Omega]);
state_names = unique({results.state});

% Colors for different Omega values
colors = lines(length(Omega_values));

% Define LaTeX strings for Omega values
Omega_labels = {'0', '\pi/2', '\pi', '3\pi/2'};

for state_idx = 1:length(state_names)
    state_name = state_names{state_idx};

    % Preallocate arrays for order parameter values
    order_params = nan(length(F_values), length(Omega_values));

    % Extract order parameter values for the current state
    for idx = 1:length(results)
        if strcmp(results(idx).state, state_name)
            F_idx = find(F_values == results(idx).F);
            Omega_idx = find(Omega_values == results(idx).Omega);
            if ~isempty(F_idx) && ~isempty(Omega_idx)
                if strcmp(parameter, 'S')
                    order_params(F_idx, Omega_idx) = mean(results(idx).S); % Averaging if there are multiple simulations per configuration
                elseif strcmp(parameter, 'R')
                    order_params(F_idx, Omega_idx) = mean(results(idx).R); % Averaging if there are multiple simulations per configuration
                end
            end
        end
    end

    % Plot the results for the current state
    figure;
    hold on;
    for Omega_idx = 1:length(Omega_values)
        plot(F_values, order_params(:, Omega_idx), '-o', 'LineWidth', 0.5,'MarkerSize', 3, 'MarkerFaceColor', colors(Omega_idx, :), 'Color', colors(Omega_idx, :), 'DisplayName', ['$\Omega = ', Omega_labels{Omega_idx}, '$']);
    end
    hold off;
    xlabel('$F$', 'Interpreter', 'latex');
    if strcmp(parameter, 'S')
        ylabel('$S$', 'Interpreter', 'latex');
    elseif strcmp(parameter, 'R')
        ylabel('$R$', 'Interpreter', 'latex');
    end
    % title(sprintf('Phase transitions for %s state', state_name), 'Interpreter', 'latex');
    legend('show', 'Interpreter', 'latex', 'Location', 'best');
    grid on;
    set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex');
    axis([-7 7 0 1])

    % Save the figure
    saveas(gcf, fullfile(savePath, sprintf('PhaseTransitions_%s_%s.png', state_name, parameter)));
    saveas(gcf, fullfile(savePath, sprintf('PhaseTransitions_%s_%s.eps', state_name, parameter)), 'epsc');
end
end
