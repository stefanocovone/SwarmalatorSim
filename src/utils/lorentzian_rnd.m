function r = lorentzian_rnd(sigma, n)
    % Generates n random numbers from a Lorentzian distribution
    % with scale parameter sigma.
    %
    % Input:
    %   sigma - Scale parameter
    %   n     - Number of random numbers to generate
    %
    % Output:
    %   r     - Random numbers from the Lorentzian distribution

    % Generate uniform random numbers between 0 and 1
    u = rand(n, 1);
    
    % Apply the inverse CDF (quantile function) of the Lorentzian distribution
    r = sigma * tan(pi * (u - 0.5));
end
