function plot_heatmaps_with_regression(dataFolder, fileName, savePath, varargin)
    % plot_heatmaps_with_regression Plot heatmaps for S and gamma with bifurcation lines.
    % 
    % Inputs:
    %   dataFolder - Folder containing the simulation results
    %   fileName - Name of the .mat file with simulation results
    %   savePath - Path to save the figures
    %   varargin - Name-value pairs for optional parameters
    %       'saveImage' - Save the figures as images (default: true)
    %       'saveEPS' - Save the figures as EPS files (default: true)

    % Parse input arguments
    p = inputParser;
    addParameter(p, 'saveImage', true, @(x) islogical(x) || isnumeric(x));
    addParameter(p, 'saveEPS', true, @(x) islogical(x) || isnumeric(x));
    parse(p, varargin{:});
    
    saveImage = p.Results.saveImage;
    saveEPS = p.Results.saveEPS;

    % Load simulation results
    load(fullfile(dataFolder, fileName), 'results');

    % Extract unique J and K values
    J_values = unique([results.J]);
    K_values = unique([results.K]);

    % Preallocate arrays for mean S and gamma values
    meanS = zeros(length(J_values), length(K_values));
    meanGamma = zeros(length(J_values), length(K_values));

    % Compute mean values for each J and K
    for idx = 1:length(results)
        J_idx = find(J_values == results(idx).J);
        K_idx = find(K_values == results(idx).K);
        meanS(J_idx, K_idx) = mean(results(idx).S);
        meanGamma(J_idx, K_idx) = mean(results(idx).gamma);
    end

    % Interpolation grid
    fineJ = linspace(min(J_values), max(J_values), 100);
    fineK = linspace(min(K_values), max(K_values), 100);
    [fineK_grid, fineJ_grid] = meshgrid(fineK, fineJ);

    % Interpolate mean S and gamma values
    fineMeanS = interp2(K_values, J_values, meanS, fineK_grid, fineJ_grid, 'linear');
    fineMeanGamma = interp2(K_values, J_values, meanGamma, fineK_grid, fineJ_grid, 'linear');

    % Thresholds
    threshold_S = 0.05;
    threshold_gamma = 0.1;

    % Bifurcation points
    bifurcationJ_S = NaN(1, length(K_values));
    bifurcationJ_gamma_lower = NaN(1, length(K_values));
    bifurcationJ_gamma_upper = NaN(1, length(K_values));

    for kIndex = 1:length(K_values)
        % Find bifurcation points for S
        J_index = find(meanS(:, kIndex) > threshold_S, 1, 'first');
        if ~isempty(J_index)
            bifurcationJ_S(kIndex) = J_values(J_index);
        end
        
        % Find lower bifurcation points for gamma
        J_index = find(meanGamma(:, kIndex) > threshold_gamma, 1, 'first');
        if ~isempty(J_index)
            bifurcationJ_gamma_lower(kIndex) = J_values(J_index);
        end
        
        % Find upper bifurcation points for gamma
        J_index = find(meanGamma(:, kIndex) > threshold_gamma, 1, 'last');
        if ~isempty(J_index)
            bifurcationJ_gamma_upper(kIndex) = J_values(J_index);
        end
    end

    % Filter out values of K and bifurcation points that are >= 1
    validIndices_lower = K_values < 1 & bifurcationJ_S < 1;
    validIndices_upper = K_values < 1 & bifurcationJ_gamma_upper < 1;

    validK_lower = K_values(validIndices_lower);
    valid_bifurcationJ_gamma_lower = bifurcationJ_S(validIndices_lower);

    validK_upper = K_values(validIndices_upper);
    valid_bifurcationJ_gamma_upper = bifurcationJ_gamma_upper(validIndices_upper);

    % Perform linear regression on the filtered points
    p_lower = polyfit(validK_lower, valid_bifurcationJ_gamma_lower, 1);
    p_upper = polyfit(validK_upper, valid_bifurcationJ_gamma_upper, 1);

    % Generate regression lines
    reg_line_lower = polyval(p_lower, fineK);
    reg_line_upper = polyval(p_upper, fineK);

    % Plot the heatmap for S
    figure;
    imagesc(fineK, fineJ, fineMeanS);
    set(gca, 'YDir', 'normal');
    xlabel('K', 'Interpreter', 'latex');
    ylabel('J', 'Interpreter', 'latex');
    % title('Heatmap of Mean S Values (N=100)', 'Interpreter', 'latex');
    colorbar;
    set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex');
    hold on;
    plot(fineK, reg_line_lower, 'k--', 'LineWidth', 2);
    plot(fineK, reg_line_upper, 'r--', 'LineWidth', 2);
    text(-0.5, 0.2, {'Static', 'Async'}, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 12, 'Color', 'w', 'FontWeight', 'bold');
    text(-0.15, 0.8, {'Splintered', 'Phase Wave'}, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 12, 'Color', 'w', 'FontWeight', 'bold');
    text(-0.5, 0.7, {'Active', 'Phase Wave'}, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 12, 'Color', 'w', 'FontWeight', 'bold');

    % Save the heatmap figure for S
    if saveImage
        saveas(gcf, fullfile(savePath, 'Heatmap_S_vs_K_J.png'));
    end
    if saveEPS
        saveas(gcf, fullfile(savePath, 'Heatmap_S_vs_K_J.eps'));
    end

    % Plot the heatmap for gamma
    figure;
    imagesc(fineK, fineJ, fineMeanGamma);
    set(gca, 'YDir', 'normal');
    xlabel('K', 'Interpreter', 'latex');
    ylabel('J', 'Interpreter', 'latex');
    % title('Heatmap of Mean Gamma Values (N=100)', 'Interpreter', 'latex');
    colorbar;
    set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex');
    hold on;
    plot(fineK, reg_line_lower, 'k--', 'LineWidth', 2);
    plot(fineK, reg_line_upper, 'r--', 'LineWidth', 2);
    text(-0.5, 0.2, {'Static', 'Async'}, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 12, 'Color', 'w', 'FontWeight', 'bold');
    text(-0.15, 0.8, {'Splintered', 'Phase Wave'}, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 12, 'Color', 'w', 'FontWeight', 'bold');
    text(-0.5, 0.7, {'Active', 'Phase Wave'}, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 12, 'Color', 'w', 'FontWeight', 'bold');

    % Save the heatmap figure for gamma
    if saveImage
        saveas(gcf, fullfile(savePath, 'Heatmap_Gamma_vs_K_J.png'));
    end
    if saveEPS
        saveas(gcf, fullfile(savePath, 'Heatmap_Gamma_vs_K_J.eps'));
    end
end
