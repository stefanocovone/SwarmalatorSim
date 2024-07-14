% Euler Method
function [t, y] = euler_method(odefun, tspan, y0, h, params)
    t0 = tspan(1);
    tf = tspan(2);
    t = t0:h:tf;
    y = zeros(length(y0), length(t));
    y(:,1) = y0;
    
    for i = 1:length(t)-1
        dydt = odefun(t(i), y(:,i), params{:});
        y(:,i+1) = y(:,i) + h * dydt;
    end
end
