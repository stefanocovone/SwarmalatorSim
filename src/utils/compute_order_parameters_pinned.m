function [R, Zeta, Xi, Ts] = compute_order_parameters_pinned(theta, omega, T, dt)
    % Computes the order parameter S and the magnitude R for forced model
    %
    % Inputs:
    %   x - N x 2 x T array, positions of swarmalators
    %   theta - N x T array, phases of swarmalators
    %   omega - natural frequency of the pacemaker
    %
    % Outputs:
    %   R - Magnitude of the order parameter Z
    %   Zeta - Asymptotic frequency displacement
    %   Xi - Asymptotic phase displacement
    %   Ts - Settling time

    % Use the last time step for asymptotic values
    final_theta = theta(:, end);
    final_ref = (omega * T);
    % Remap angles to be within [-pi, pi]
    final_ref = mod(final_ref + pi, 2*pi) - pi;

    % Compute the magnitude R
    Z = mean(exp(1i * final_theta));
    R = abs(Z);

    % Compute theta dot
    theta_dot = diff(theta, 1, 2);
    disc_idx = find((theta_dot > -6.3) & (theta_dot < -6.2));
    theta_dot(disc_idx) = theta_dot(disc_idx - 1);
    theta_dot = theta_dot / dt;

    % Compute Zeta and Xi
    Zeta = abs(theta_dot(end) - omega);
    Xi = mean(abs(final_theta - final_ref));

    % Compute settling time
    Zeta_time = abs(theta_dot - omega);
    R_time = abs(mean(exp(1i * theta), 1));

    Ts = 50; % Initialize Ts as NaN in case the conditions are never met
    for t = 1:length(Zeta_time)
        if Zeta_time(1,t) < 0.01 && R_time(t) > 0.99
            Ts = t * dt; % Calculate Ts as time
            break;
        end
    end
end
