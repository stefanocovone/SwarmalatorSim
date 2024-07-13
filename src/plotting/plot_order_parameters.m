function plot_order_parameters(dataFolder, fileName, savePath, varargin)
    % plot_order_parameters Plot the mean S and gamma values vs. K.
    % 
    % Inputs:
    %   dataFolder - Folder containing the simulation results
    %   fileName - Name of the .mat file with simulation results
    %   savePath - Path to save the figures
    %   varargin - Name-value pairs for optional parameters
    %       'saveImage' - Save the figure as an image (default: true)
    %       'saveEPS' - Save the figure as an EPS file (default: true)

    % Parse input arguments
    p = inputParser;
    addParameter(p, 'saveImage', true, @(x) islogical(x) || isnumeric(x));
    addParameter(p, 'saveEPS', true, @(x) islogical(x) || isnumeric(x));
    parse(p, varargin{:});
    
    saveImage = p.Results.saveImage;
    saveEPS = p.Results.saveEPS;

    % Load simulation results
    load(fullfile(dataFolder, fileName), 'results');

    % Extract unique K values
    K_values = [results.K];

    % Preallocate arrays for mean S and gamma values
    meanS = zeros(length(K_values), 1);
    meanGamma = zeros(length(K_values), 1);

    % Compute mean values for each K
    for idx = 1:length(results)
        meanS(idx) = mean(results(idx).S);
        meanGamma(idx) = mean(results(idx).gamma);
    end

    % Convert K values to positive for the x-axis
    K_values_positive = -K_values;

    % Smooth the curves
    smoothK = linspace(min(K_values_positive), max(K_values_positive), 100);
    smoothS = interp1(K_values_positive, meanS, smoothK, 'spline');
    smoothGamma = interp1(K_values_positive, meanGamma, smoothK, 'spline');

    % Find bifurcation points
    K_bifurcation_S = K_values_positive(find(meanS < 0.01, 1, 'first'));
    K_bifurcation_gamma = K_values_positive(find(meanGamma > 0.03, 1, 'first'));

    % Plot the results
    figure;

    % Plot smoothed mean S and gamma values on the same plot
    plot(smoothK, smoothS, 'b-', 'LineWidth', 2);
    hold on;
    plot(smoothK, smoothGamma, 'r-', 'LineWidth', 2);
    xlabel('$-K$', 'Interpreter', 'latex');
    ylabel('Order Parameters', 'Interpreter', 'latex');
    legend({'$S$', '$\gamma$'}, 'Interpreter', 'latex', 'Location', 'best');
    % title('Mean Order Parameters vs K', 'Interpreter', 'latex');
    grid on;
    set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex');
    xlim([0 max(smoothK)]);
    ylim([0 1])

    % Add vertical lines for bifurcations
    yLimits = ylim;
    line_S = line([K_bifurcation_S K_bifurcation_S], yLimits, 'Color', 'k', 'LineStyle', '--', 'LineWidth', 2);
    line_gamma = line([K_bifurcation_gamma K_bifurcation_gamma], yLimits, 'Color', 'k', 'LineStyle', '--', 'LineWidth', 2);
    line_zero = line([0 0], yLimits, 'Color', 'k', 'LineWidth', 2);

    % Exclude vertical lines from legend
    set(get(get(line_S, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
    set(get(get(line_gamma, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
    set(get(get(line_zero, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');

    % Add text annotations
    text(0.06, 0.7 * yLimits(2), {'Splintered', 'Phase', 'Wave'}, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 12, 'Color', 'k', 'FontWeight', 'bold', 'Interpreter', 'latex');
    text(0.3, 0.5 * yLimits(2), {'Active', 'Phase Wave'}, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 12, 'Color', 'k', 'FontWeight', 'bold', 'Interpreter', 'latex');
    text(0.6, 0.2 * yLimits(2), {'Static', 'Async'}, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 12, 'Color', 'k', 'FontWeight', 'bold', 'Interpreter', 'latex');
    text(0.03, 0.2 * yLimits(2), {'Static', 'Phase', 'Wave'}, ...
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontSize', 12, 'Color', 'k', 'FontWeight', 'bold', 'Interpreter', 'latex');

    % Add an arrow annotation below "Static Phase Wave"
    annotation('textarrow', [0.25, 0.13], [0.27, 0.27], 'String', '', 'Color', 'k', 'LineWidth', 1.5);

    % Save the figure
    if saveImage
        saveas(gcf, fullfile(savePath, 'Order_Parameters_vs_K.png'));
    end
    
    if saveEPS
        saveas(gcf, fullfile(savePath, 'Order_Parameters_vs_K.eps'));
    end
end
