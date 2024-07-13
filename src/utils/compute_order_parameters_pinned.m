function [S, R] = compute_order_parameters_pinned(x, theta, omega)
    % Computes the order parameter S and the magnitude R for forced model
    %
    % Inputs:
    %   x - N x 2 x T array, positions of swarmalators
    %   theta - N x T array, phases of swarmalators
    %   omega - natural frequency of the pacemaker
    %
    % Outputs:
    %   S - Asymptotic order parameter S (max of S+ and S-)
    %   R - Magnitude of the order parameter Z

    % Use the last time step for asymptotic values
    final_theta = theta(:, end);
    final_phi = mod(atan2(x(:,2,end), x(:,1,end)), 2*pi); % Remap phi to [0, 2*pi]

    final_ref = (omega*50);
    % Remap angles to be within [-pi, pi]
    final_ref = mod(final_ref + pi, 2*pi) - pi;

    % Compute the asymptotic value of S
    psi_plus = final_phi + final_theta;
    psi_minus = final_phi - final_theta;
    S_plus = abs(mean(exp(1i * psi_plus)));
    S_minus = abs(mean(exp(1i * psi_minus)));
    % Compute S as the max between S+ and S-
    S = max(S_plus, S_minus);

    % Compute the magnitude R
    final_diff = -final_ref + final_theta;
    R = norm(final_diff);
end
