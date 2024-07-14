function [t, y] = heun_method(odefun, tspan, y0, h, params)
    t0 = tspan(1);
    tf = tspan(2);
    t = t0:h:tf;
    y = zeros(length(y0), length(t));
    y(:,1) = y0;
    
    for i = 1:length(t)-1
        k1 = odefun(t(i), y(:,i), params{:});
        y_pred = y(:,i) + h * k1;
        k2 = odefun(t(i) + h, y_pred, params{:});
        y(:,i+1) = y(:,i) + (h/2) * (k1 + k2);
    end
end
