function plot_maxmin_radii_vs_J(J_values, max_radius_results, min_radius_results, options)
% Define the function arguments with default values and validation
arguments
    J_values (:,1) double
    max_radius_results (:,1) double
    min_radius_results (:,1) double
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
epsFileName = fullfile(savePath, 'radius_vs_J_K_0.eps');
jpgFileName = fullfile(savePath, 'radius_vs_J_K_0.jpg');

% Plot the maximum and minimum radius as a function of J
figure;

% Adjust figure properties to reduce white space
set(gcf, 'PaperPositionMode', 'auto');
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1), pos(2), pos(3)*0.8, pos(4)]); % Adjust width to reduce white space

hold on;
colors = lines(1); % Use a color for the line
% Plot maximum radius
plot(J_values, max_radius_results, '-o', ...
    'LineWidth', 2, 'MarkerFaceColor', colors(1, :), ...
    'DisplayName', 'Max Radius');
% Plot minimum radius
plot(J_values, min_radius_results, '--o', ...
    'LineWidth', 2, 'MarkerFaceColor', colors(1, :), ...
    'DisplayName', 'Min Radius');
hold off;
xlabel('$J$', 'Interpreter', 'latex');
ylabel('Radius', 'Interpreter', 'latex');
% title('Radius of Swarmalators as a Function of $J$ (K = 0)', 'Interpreter', 'latex');
legend('show', 'Location', 'best', 'Interpreter', 'latex');
grid on;
set(gca, 'TickLabelInterpreter', 'latex');

% Save the final frame if saveImage is true
if saveImage
    print(gcf, epsFileName, '-depsc', '-tiff', '-r300'); % Save as EPS file with better formatting
    print(gcf, jpgFileName, '-djpeg', '-r300'); % Save as JPG file with better formatting
end
end
