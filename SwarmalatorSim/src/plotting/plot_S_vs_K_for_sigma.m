function plot_S_vs_K_for_sigma(dataFolder, sigma_values, savePath, varargin)
    % plot_S_vs_K_for_sigma Plot the mean S values vs. K for different sigma values.
    % 
    % Inputs:
    %   dataFolder - Folder containing the simulation results
    %   sigma_values - Array of sigma values
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

    figure;
    hold on;

    % Loop over each sigma value
    for sigma = sigma_values
        % Load simulation results
        fileName = sprintf('simulation_results_sigma_%.2f.mat', sigma);
        load(fullfile(dataFolder, fileName), 'results');

        % Extract unique K values
        K_values = [results.K];

        % Preallocate arrays for mean S values
        meanS = zeros(length(K_values), 1);

        % Compute mean values for each K
        for idx = 1:length(results)
            meanS(idx) = mean(results(idx).S);
        end

        % Convert K values to positive for the x-axis
        K_values_positive = -K_values;

        % Smooth the curves
        smoothK = linspace(min(K_values_positive), max(K_values_positive), 100);
        smoothS = interp1(K_values_positive, meanS, smoothK, 'spline');

        % Plot smoothed mean S values
        plot(smoothK, smoothS, 'LineWidth', 1, 'DisplayName', sprintf('$\\sigma = %.2f$', sigma));
    end

    % Set plot properties
    xlabel('$-K$', 'Interpreter', 'latex');
    ylabel('Order Parameter $S$', 'Interpreter', 'latex');
    legend('Interpreter', 'latex', 'Location', 'best');
    grid on;
    set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex');
    xlim([0 max(smoothK)]);
    ylim([0 1])

    % Save the figure
    if saveImage
        saveas(gcf, fullfile(savePath, 'Order_Parameters_S_vs_K_for_sigma.png'));
    end
    
    if saveEPS
        saveas(gcf, fullfile(savePath, 'Order_Parameters_S_vs_K_for_sigma.eps'));
    end
end
