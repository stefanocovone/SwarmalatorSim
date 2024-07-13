function plot_radii_vs_J(J_values, K_values, max_radius_results, options)
% Define the function arguments with default values and validation
arguments
    J_values (:,1) double
    K_values (:,1) double
    max_radius_results (:,:) double
    options.savePath string = ""
    options.saveImage logical = false
end

% Extract options
savePath = options.savePath;
saveImage = options.saveImage;

% Use current folder if savePath is empty
if isempty(savePath)
    savePath = pwd;
end

% Create the folder if it doesn't exist
if ~exist(savePath, 'dir')
    mkdir(savePath);
end

% Set fixed filenames
epsFileName = fullfile(savePath, 'max_radius_vs_J.eps');
jpgFileName = fullfile(savePath, 'max_radius_vs_J.jpg');

% Define legend labels
legend_labels = {'Static Sync', 'Static Async'};

% Plot the maximum radius as a function of J for both K values
figure;

% Adjust figure properties to reduce white space
set(gcf, 'PaperPositionMode', 'auto');
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1), pos(2), pos(3)*0.8, pos(4)]); % Adjust width to reduce white space

hold on;
colors = lines(length(K_values)); % Use different colors for each line
for k_idx = 1:length(K_values)
    plot(J_values, max_radius_results(:, k_idx), '-o', ...
        'LineWidth', 2, 'MarkerFaceColor', colors(k_idx, :), ...
        'DisplayName', sprintf('%s', legend_labels{k_idx}));
end
hold off;
xlabel('$J$', 'Interpreter', 'latex');
ylabel('Maximum Radius', 'Interpreter', 'latex');
% title('Maximum Radius of Swarmalators as a Function of $J$', 'Interpreter', 'latex');
legend('show', 'Location', 'best', 'Interpreter', 'latex');
grid on;
set(gca, 'TickLabelInterpreter', 'latex');

% Save the final frame if saveImage is true
if saveImage
    print(gcf, epsFileName, '-depsc', '-tiff', '-r300'); % Save as EPS file with better formatting
    print(gcf, jpgFileName, '-djpeg', '-r300'); % Save as JPG file with better formatting
end
end
