% Define the Lorentzian distribution function
lorentzian = @(omega, sigma, mu) (sigma / pi) ./ ((omega - mu).^2 + sigma^2);

% Define the range of omega
omega = linspace(-10, 10, 1000);

% Define different values of sigma
sigma_values = [0.2, 0.5, 1];

% Define the mean value mu
mu = 0;

% Create a figure
figure;
hold on;

% Plot the Lorentzian distribution for each sigma value
for sigma = sigma_values
    g = lorentzian(omega, sigma, mu);
    plot(omega, g, 'DisplayName', ['$\sigma$ = ', num2str(sigma)], 'LineWidth', 2);
end

% Add labels and title
xlabel('$\omega$', 'Interpreter', 'latex');
ylabel('$g(\omega)$', 'Interpreter', 'latex');
% title('Lorentzian Distribution for Different Values of $\sigma$', 'Interpreter', 'latex');

% Add a legend
legend('Interpreter', 'latex', 'Location', 'northeast');

% Add grid
grid on;

% Set font size for axes
set(gca, 'FontSize', 12);

% Save the figure
saveas(gcf, 'lorentzian_distribution.png');
saveas(gcf, 'lorentzian_distribution.eps', 'epsc');

hold off;
