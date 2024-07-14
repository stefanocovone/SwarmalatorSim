function plot_heatmap_Xi(dataFolder, fileName, savePath)
    % plot_heatmap_Xi Plots the heatmap of Xi over K and F_ext (representing sigma).
    %
    % Inputs:
    %   dataFolder - Folder containing the simulation results
    %   fileName - Name of the .mat file with simulation results
    %   savePath - Path to save the heatmap figure

    % Load simulation results
    load(fullfile(dataFolder, fileName), 'results');

    % Extract unique values for K and F_ext (sigma)
    K_values = unique([results(:).K]);
    F_ext_values = unique([results(:).F_ext]); % F_ext represents sigma

    % Filter out sigma values less than 3
    F_ext_values = F_ext_values(F_ext_values >= 3);

    % Preallocate array for Xi values
    Xi_values = nan(length(F_ext_values), length(K_values));

    % Populate Xi values from results
    for K_idx = 1:length(K_values)
        for F_ext_idx = 1:length(F_ext_values)
            % Find the index in the results structure
            result_idx = find([results.K] == K_values(K_idx) & [results.F_ext] == F_ext_values(F_ext_idx));
            if ~isempty(result_idx)
                Xi_values(F_ext_idx, K_idx) = results(result_idx).Xi;
            end
        end
    end

    % Plot the heatmap
    figure;
    imagesc(K_values, F_ext_values, Xi_values);
    set(gca, 'YDir', 'normal');
    xlabel('$K$', 'Interpreter', 'latex');
    ylabel('$\sigma$', 'Interpreter', 'latex'); % Representing F_ext as sigma
    colorbarHandle = colorbar;
    ylabel(colorbarHandle, '$\xi$', 'Interpreter', 'latex');
    set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex');
    % title('$\xi$ Heatmap', 'Interpreter', 'latex');

    % Save the heatmap figure
    saveas(gcf, fullfile(savePath, 'Heatmap_Xi.png'));
    saveas(gcf, fullfile(savePath, 'Heatmap_Xi.eps'), 'epsc');
end
