function analyze_value(X,T,Q)
    % X: states matrix (rows = time samples), T: time vector, Q: weight matrix

    % maximal deviation, overshoot, settling time for x1,x2,x3
    for i=1:3
        xi = X(:,i);
        x0_i = xi(1);
        xfinal = xi(end);
        max_dev = max(abs(xi - xfinal));                % maximal deviation (rad)
        overshoot = compute_overshoot_mat(xi, xfinal);   % overshoot above final (rad)
        tol = 0.05 * max(abs(x0_i - xfinal), eps);      % 5% tolerance
        ts = settling_time(T, xi - xfinal, tol);        % settling time (s)
        if isnan(ts), ts_str = 'not settled'; else ts_str = sprintf('%.3f s', ts); end

        fprintf('x%d: max_dev=%.5f rad, overshoot=%.5f rad, settling=%s\n', i, max_dev, overshoot, ts_str);
    end

    % quadratic error e_Q(t) = x' Q x and its settling time
    eQ = zeros(length(T),1);
    for k=1:length(T)
        xt = X(k,:)';
        eQ(k) = xt' * Q * xt;
    end
    tol_e = 0.05 * max(eQ(1), eps);
    ts_eQ = settling_time(T, eQ - eQ(end), tol_e);
    if isnan(ts_eQ), ts_eQ_str = 'not settled'; else ts_eQ_str = sprintf('%.3f s', ts_eQ); end
    fprintf('Quadratic error: settling=%s (tol=%.3e)\n', ts_eQ_str, tol_e);
end


function ts = settling_time(T, y, tol)
    % returns first time T(k) such that |y(j)|<=tol for all j>=k
    ts = NaN;
    N = length(y);
    for k=1:N
        if all(abs(y(k:end)) <= tol)
            ts = T(k);
            return;
        end
    end
end

function Os = compute_overshoot_mat(X, xs)
    % X: NxM (trajectórias), xs: referência escalar
    [~,m] = size(X);
    Os = zeros(1,m);
    for i = 1:m
        traj = X(:,i);
        x0 = traj(1);
        if x0 < xs
            max_val = max(traj);
            Os(i) = max(0, max_val - xs);      % overshoot acima de xs
        elseif x0 > xs
            min_val = min(traj);
            Os(i) = max(0, xs - min_val);      % undershoot convertido em overshoot
        else
            Os(i) = max(abs(traj - xs));       % se iniciou em xs, pico absoluto
        end
    end
end

