function final_image = phi_theta_plot(x, theta, dt, T, options)
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
    options.frameRate (1,1) double {mustBePositive} = 10
    options.omega (1,1) double = 0
    options.plotOmegaLine logical = false
end

% Extract options
savePath = options.savePath;
generateLastFrameOnly = options.generateLastFrameOnly;
saveVideo = options.saveVideo;
saveImage = options.saveImage;
frameRate = options.frameRate;
omega = options.omega;
plotOmegaLine = options.plotOmegaLine;

% Use current folder if savePath is empty
if isempty(savePath)
    savePath = pwd;
end

% Create the folder if it doesn't exist
if ~exist(savePath, 'dir')
    mkdir(savePath);
end

% Set fixed filenames
epsFileName = fullfile(savePath, 'swarmalator_image_pt.eps');
jpgFileName = fullfile(savePath, 'swarmalator_image_pt.jpg');
videoFileName = fullfile(savePath, 'swarmalator_animation_pt.avi');

% Initialize the figure
figure;

% Adjust figure properties to reduce white space
set(gcf, 'PaperPositionMode', 'auto');
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1), pos(2), pos(3)*0.8, pos(4)]); % Adjust width to reduce white space

set(gcf, 'Color', 'w'); % Set the figure background color to white
phi = mod(atan2(x(:,2,1), x(:,1,1)), 2*pi); % Remap phi to [0, 2*pi]
theta_remapped = mod(theta(:,1), 2*pi); % Remap theta to [0, 2*pi]
h2 = scatter(phi, theta_remapped, 20, 'filled');
hold on;
if plotOmegaLine
    omega_line = plot([0 2*pi], [omega*0 omega*0], 'k--', 'LineWidth', 1.5);
end
axis('equal');
axis([0 2*pi 0 2*pi]);
xticks([0 pi/2 pi 3*pi/2 2*pi]);
yticks([0 pi/2 pi 3*pi/2 2*pi]);
set(gca, 'TickLabelInterpreter', 'latex', ...
    'XTickLabel', {'$0$', '$\frac{\pi}{2}$', '$\pi$', '$\frac{3\pi}{2}$', '$2\pi$'}, ...
    'YTickLabel', {'$0$', '$\frac{\pi}{2}$', '$\pi$', '$\frac{3\pi}{2}$', '$2\pi$'});
xlabel('$\phi$', 'Interpreter', 'latex');
ylabel('$\theta$', 'Interpreter', 'latex');
grid on; % Add grid

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
        % Update (phi, theta) plot
        phi = mod(atan2(x(:,2,t), x(:,1,t)), 2*pi); % Remap phi to [0, 2*pi]
        theta_remapped = mod(theta(:,t), 2*pi); % Remap theta to [0, 2*pi]
        set(h2, 'XData', phi, 'YData', theta_remapped);
        if plotOmegaLine
            set(omega_line, 'YData', mod([omega*t*dt omega*t*dt], 2*pi));
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
phi = mod(atan2(x(:,2,t), x(:,1,t)), 2*pi); % Remap phi to [0, 2*pi]
theta_remapped = mod(theta(:,t), 2*pi); % Remap theta to [0, 2*pi]
set(h2, 'XData', phi, 'YData', theta_remapped);
if plotOmegaLine
    set(omega_line, 'YData', mod([omega*t*dt omega*t*dt], 2*pi));
end
title('');
drawnow;

% Capture the final frame as an image
set(gcf, 'Color', 'w'); % Ensure the figure background is white
final_frame = getframe(gcf);
final_image = final_frame.cdata;

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
