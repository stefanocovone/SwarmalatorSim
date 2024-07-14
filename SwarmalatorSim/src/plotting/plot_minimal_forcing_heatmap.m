function plot_minimal_forcing_heatmap(dataFolder, fileName, savePath)
    % plot_minimal_forcing_heatmap Plot heatmaps for minimal forcing values.
    %
    % Inputs:
    %   dataFolder - Folder containing the simulation results
    %   fileName - Name of the .mat file with simulation results
    %   savePath - Path to save the figures

    % Load simulation results
    load(fullfile(dataFolder, fileName), 'results');

    % Extract unique J and K values
    J_values = unique([results.J]);
    K_values = unique([results.K]);

    % Preallocate array for minimal forcing values
    min_F_ext = NaN(length(J_values), length(K_values));

    % Fill in the minimal forcing values
    for idx = 1:length(results)
        J_idx = find(J_values == results(idx).J);
        K_idx = find(K_values == results(idx).K);
        min_F_ext(J_idx, K_idx) = results(idx).min_F_ext;
    end

    % Interpolation grid
    fineJ = linspace(min(J_values), max(J_values), 100);
    fineK = linspace(min(K_values), max(K_values), 100);
    [fineK_grid, fineJ_grid] = meshgrid(fineK, fineJ);

    % Interpolate minimal forcing values
    fineMinF = interp2(K_values, J_values, min_F_ext, fineK_grid, fineJ_grid, 'linear');

    % Plot the heatmap for minimal forcing values
    figure;
    imagesc(fineK, fineJ, fineMinF);
    set(gca, 'YDir', 'normal');
    xlabel('K', 'Interpreter', 'latex');
    ylabel('J', 'Interpreter', 'latex');
    % clim([0 5])
    % title('Heatmap of Minimal Forcing Values for Synchronization', 'Interpreter', 'latex');
    colorbar;
    set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex');

    % Save the heatmap figure
    saveas(gcf, fullfile(savePath, 'Heatmap_Minimal_Forcing.png'));
    saveas(gcf, fullfile(savePath, 'Heatmap_Minimal_Forcing.eps'), 'epsc');
end
