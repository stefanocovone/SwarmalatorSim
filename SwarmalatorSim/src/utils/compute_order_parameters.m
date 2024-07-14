function [S, gamma] = compute_order_parameters(x, theta)
% Computes the order parameter S and the fraction gamma
%
% Inputs:
%   x - N x 2 x T array, positions of swarmalators
%   theta - N x T array, phases of swarmalators
%
% Outputs:
%   S - Asymptotic order parameter S (max of S+ and S-)
%   gamma - Fraction of swarmalators that have executed at least one
%   full cycle at steady state

% Get number of swarmalators and time steps
[N, ~, T] = size(x);

transient_period = round(T / 2);

% Preallocate
theta_cycles = zeros(N, 1); % To track the number of cycles for each swarmalator's phase
phi_cycles = zeros(N, 1); % To track the number of cycles for each swarmalator's position

phi = mod(atan2(x(:,2,:), x(:,1,:)), 2*pi); % Remap phi to [0, 2*pi]
theta = mod(theta, 2*pi); % Remap theta to [0, 2*pi]

% Compute the asymptotic value of S
psi_plus = phi(:,end) + theta(:,end);
psi_minus = phi(:,end) - theta(:,end);
S_plus = abs(mean(exp(1i * psi_plus)));
S_minus = abs(mean(exp(1i * psi_minus)));
% Compute S as the max between S+ and S-
S = max(S_plus, S_minus);

% Initialize prev_phi with the value at the end of the transient period

% Track the phase and position over time to compute gamma
for t = transient_period+2:T
    % Detect full cycles in phase
    theta_diff = theta(:,t) - theta(:,t-1);
    theta_cycles = theta_cycles + (theta_diff < -pi) - (theta_diff > pi);

    % Detect full cycles in position
    phi_diff = phi(:,t) - phi(:,t-1);
    phi_cycles = phi_cycles + (phi_diff < -pi) - (phi_diff > pi);

    % Store current phi for next iteration comparison
    prev_phi = phi;
end

% Compute gamma: fraction of swarmalators with at least one full cycle in both phase and position
full_cycles = (abs(theta_cycles) > 0) & (abs(phi_cycles) > 0);
gamma = sum(full_cycles) / N;
end
