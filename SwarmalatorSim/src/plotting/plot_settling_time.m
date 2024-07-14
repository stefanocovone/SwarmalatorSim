function plot_settling_time(dataFolder, fileName, savePath)
% plot_settling_time Plots the settling time Ts over F_ext.
%
% Inputs:
%   dataFolder - Folder containing the simulation results
%   fileName - Name of the .mat file with simulation results
%   savePath - Path to save the figure

% Load simulation results
load(fullfile(dataFolder, fileName), 'results');

% Extract unique values for F_ext
F_ext_values = unique([results(:).F_ext]);
K_values = unique([results(:).K]);

% Preallocate array for Ts values
Ts_values = nan(length(K_values), length(F_ext_values));

% Populate Ts values from results
for K_idx = 1:length(K_values)
    for F_ext_idx = 1:length(F_ext_values)
        Ts_values(K_idx, F_ext_idx) = results(K_idx, F_ext_idx).Ts;
    end
end

colors = lines(length(K_values));

% Plot the settling time for each K
figure;
hold on;
for K_idx = 1:length(K_values)
    plot(F_ext_values, Ts_values(K_idx, :), '-o', 'MarkerSize', 3, 'MarkerFaceColor', colors(K_idx,:), 'DisplayName', sprintf('$K = %.1f$', K_values(K_idx)));
end
hold off;
xlabel('$\sigma$', 'Interpreter', 'latex');
ylabel('$T_s$', 'Interpreter', 'latex');
legend('show', 'Interpreter', 'latex', 'Location', 'best');
grid on;
ylim([0 10])
set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex');
% title('Settling Time $T_s$ over $F_{\text{ext}}$', 'Interpreter', 'latex');

% Save the figure
saveas(gcf, fullfile(savePath, 'SettlingTime_vs_F_ext.png'));
saveas(gcf, fullfile(savePath, 'SettlingTime_vs_F_ext.eps'), 'epsc');
end
