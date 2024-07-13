function dydt = swarmalator_pinned_ode(t, y, A, J, B, K, F_ext, Omega_ext, N, omega, x0_ext)
    % Extract positions and phases
    x = reshape(y(1:2*N), [N, 2]);
    theta = y(2*N+1:3*N);
    
    % Compute distances and unit vectors
    diff_x = reshape(x, [1, N, 2]) - reshape(x, [N, 1, 2]);
    distances = sqrt(sum(diff_x.^2, 3));
    inv_distances = 1 ./ distances;
    inv_distances(1:N+1:end) = 0; % Avoid division by zero for self-distances
    unit_vectors = diff_x .* inv_distances;
    
    % Compute cosines and sines of phase differences
    diff_theta = theta' - theta;
    cos_diff_theta = cos(diff_theta);
    sin_diff_theta = sin(diff_theta);
    
    % Compute interaction terms
    A_J_cos = A + J * cos_diff_theta;
    A_J_cos(1:N+1:end) = 0; % Ignore self-interactions
    B_term = -B * inv_distances;
    B_term(1:N+1:end) = 0; % Ignore self-interactions
    
    % Compute interaction term for positions
    force_term = A_J_cos + B_term;
    interaction_x = sum(unit_vectors .* reshape(force_term, [N, N, 1]), 2) / N;
    interaction_x = squeeze(interaction_x);
    
    % Compute interaction term for phases
    interaction_theta = sum(sin_diff_theta .* inv_distances, 2) * (K / N);
    
    % Pinning control term
    diff_x0 = x0_ext - x;
    distances_x0 = sqrt(sum(diff_x0.^2, 2));
    pinned = ones(N, 1);
    % pinned(1:10) = 1;
    forcing_term = F_ext .* pinned .* sin(Omega_ext * t - theta) + 0*F_ext .* sum(diff_theta, 2);
    
    % Combine derivatives
    dxdt = interaction_x;
    dthetadt = omega + interaction_theta + forcing_term;
    
    % Combine dxdt and dthetadt into a single column vector
    dydt = [dxdt(:); dthetadt];
end
