function xy_plot(x, theta, dt, T, options)
% Define the function arguments with default values and validation
arguments
    x (:,2,:) double
    theta (:,:) double
    dt (1,1) double {mustBePositive}
    T (1,1) double {mustBePositive}
    options.savePath string = ""
    options.generateLastFrameOnly logical = false
    options.saveVideo logical = false
    options.saveImage logical = false
    options.showColorbar logical = false
    options.frameRate (1,1) double {mustBePositive} = 10
    options.hideElements logical = false
    options.numSquares (1,1) double {mustBeNonnegative, mustBeInteger} = 0
end

% Extract options
savePath = fullfile(pwd, options.savePath);
generateLastFrameOnly = options.generateLastFrameOnly;
saveVideo = options.saveVideo;
saveImage = options.saveImage;
showColorbar = options.showColorbar;
frameRate = options.frameRate;
hideElements = options.hideElements;
numSquares = options.numSquares;

% Use current folder if savePath is empty
if isempty(savePath)
    savePath = pwd;
end

% Create the folder if it doesn't exist
if ~exist(savePath, 'dir')
    mkdir(savePath);
end

% Set fixed filenames
videoFileName = fullfile(savePath, 'swarmalator_animation_xy.avi');

if hideElements
    epsFileName = fullfile(savePath, 'swarmalator_image_xy_noax.eps');
    jpgFileName = fullfile(savePath, 'swarmalator_image_xy_noax.jpg');
else
    epsFileName = fullfile(savePath, 'swarmalator_image_xy.eps');
    jpgFileName = fullfile(savePath, 'swarmalator_image_xy.jpg');
end

% Initialize the figure
figure;

% Adjust figure properties to reduce white space
set(gcf, 'PaperPositionMode', 'auto');
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1), pos(2), pos(3)*0.8, pos(4)]); % Adjust width to reduce white space

set(gcf, 'Color', 'w'); % Set the figure background color to white
colormap(hsv); % Use the hsv colormap
h1 = scatter(x(:,1,1), x(:,2,1), 20, theta(:,1), 'filled');
if numSquares > 0
    hold on;
    h2 = scatter(x(1:numSquares,1,1), x(1:numSquares,2,1), 50, theta(1:numSquares,1), 'd', 'filled');
    hold off;
end
axis('equal');
axis([-1.5 1.5 -1.5 1.5]);
axis([-2 2 -2 2])
% axis([-3 3 -3 3])
if showColorbar
    colorbar;
end
clim([-pi, pi]); % Set color axis to match the range of theta
grid on; % Add grid
xlabel('$x$', 'Interpreter', 'latex');
ylabel('$y$', 'Interpreter', 'latex');
set(gca, 'TickLabelInterpreter', 'latex');

% Video writer setup
if saveVideo
    v = VideoWriter(videoFileName);
    v.FrameRate = frameRate; % Set the frame rate
    open(v);
end

% Update loop
if ~generateLastFrameOnly
    for t = round(1/dt):round(1/dt):round(T/dt)
        tic
        % Update (x, y) plot
        set(h1, 'XData', x(:,1,t), 'YData', x(:,2,t), 'CData', theta(:,t));
        if numSquares > 0
            set(h2, 'XData', x(1:numSquares,1,t), 'YData', x(1:numSquares,2,t), 'CData', theta(1:numSquares,t));
        end
        title(['Time = ' num2str(t*dt)], 'Interpreter', 'latex');
        drawnow;

        if saveVideo
            frame = getframe(gcf);
            writeVideo(v, frame);
        end

        elapsed_time = toc;
        pause(max(0, 0.1 - elapsed_time)); % Adjust the pause to ensure real-time plotting
    end
end

% Generate the last frame
t = round(T/dt);
set(h1, 'XData', x(:,1,t), 'YData', x(:,2,t), 'CData', theta(:,t));
if numSquares > 0
    set(h2, 'XData', x(1:numSquares,1,t), 'YData', x(1:numSquares,2,t), 'CData', theta(1:numSquares,t));
end
title('');
drawnow;

% Hide elements if hideElements is true
if hideElements
    grid off;
    colorbar off;
    xlabel('');
    ylabel('');
    set(gca, 'xtick', []);
    set(gca, 'ytick', []);
    set(gca, 'TickLabelInterpreter', 'none');
    axis off
end

% Capture the final frame as an image
set(gcf, 'Color', 'w'); % Ensure the figure background is white
% final_frame = getframe(gcf);
% final_image = final_frame.cdata;

% Save the final frame if saveImage is true
if saveImage
    print(gcf, epsFileName, '-depsc', '-tiff', '-r300'); % Save as EPS file with better formatting
    print(gcf, jpgFileName, '-djpeg', '-r300'); % Save as JPG file with better formatting
end

% Close video writer
if saveVideo
    frame = getframe(gcf);
    writeVideo(v, frame);
    close(v);
end
end
