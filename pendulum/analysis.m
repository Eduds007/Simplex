t = states.Time;
y = states.Data(:,1);
theta_bar = states.Data(:,3);
reference = setpoint.Data(:,1);

if ~exist('flag', 'var')
    error('The variable "flag" was not found in the workspace.');
end

flag = flag(:);

tol = 0.02;  % 2% tolerance band
ref_change_tol = max(1e-9, 1e-6 * max(abs(reference)));
idx_changes = find(abs(diff(reference)) > ref_change_tol) + 1;

if isempty(idx_changes)
    warning('No reference change was found.');
    settling_table = table([], [], [], 'VariableNames', ...
        {'step_time', 'reference', 'settling_time'});
    disp(settling_table)
    return
end

step_times = t(idx_changes);
step_refs = reference(idx_changes);
settling_times = NaN(numel(idx_changes),1);

for i = 1:numel(idx_changes)
    start_idx = idx_changes(i);
    r_ref = step_refs(i);
    band = tol * max(abs(r_ref), 1e-6);

    if i < numel(idx_changes)
        end_idx = idx_changes(i+1) - 1;
    else
        end_idx = numel(reference);
    end

    within_band = abs(y(start_idx:end_idx) - r_ref) <= band;

    % Marks points from which the response no longer leaves the band.
    stays_in_band = false(size(within_band));
    stays_in_band(end) = within_band(end);

    for k = numel(within_band)-1:-1:1
        stays_in_band(k) = within_band(k) && stays_in_band(k+1);
    end

    first_settled = find(stays_in_band, 1, 'first');

    if ~isempty(first_settled)
        settling_idx = start_idx + first_settled - 1;
        settling_times(i) = t(settling_idx) - t(start_idx);
    end
end

settling_table = table(step_times, step_refs, settling_times, 'VariableNames', ...
    {'step_time', 'reference', 'settling_time'});

disp(settling_table)

% HPC acceptance rate using flag:
% acceptance_rate = (number of flag values equal to 2 / total flag values) * 100
num_flags = numel(flag);

if num_flags == 0
    hpc_acceptance_rate = NaN;
    warning('No valid samples available to compute HPC acceptance rate.');
else
    accepted_count = sum(flag == 2);
    hpc_acceptance_rate = 100 * accepted_count / num_flags;
    fprintf('HPC acceptance rate (flag == 2): %.2f%% (%d/%d)\n', ...
        hpc_acceptance_rate, accepted_count, num_flags);
end

% Output and setpoint plot with tolerance band and settling points.
figure('Name', 'Stabilization relative to setpoint', 'Color', 'w');
h_out = plot(t, y, 'b', 'LineWidth', 1.5);
hold on
h_ref = plot(t, reference, 'k--', 'LineWidth', 1.4);

h_band = plot(NaN, NaN, 'r:', 'LineWidth', 1.0);
h_settle = plot(NaN, NaN, 'go', 'MarkerFaceColor', 'g', 'MarkerSize', 6);

for i = 1:numel(idx_changes)
    r_ref = step_refs(i);
    band = tol * max(abs(r_ref), 1e-6);

    if i < numel(idx_changes)
        end_idx = idx_changes(i+1) - 1;
    else
        end_idx = numel(reference);
    end

    ti = t(idx_changes(i):end_idx);
    upper = (r_ref + band) * ones(size(ti));
    lower = (r_ref - band) * ones(size(ti));

    plot(ti, upper, 'r:', 'LineWidth', 1.0)
    plot(ti, lower, 'r:', 'LineWidth', 1.0)

    if ~isnan(settling_times(i))
        t_settle = step_times(i) + settling_times(i);
        y_settle = interp1(t, y, t_settle, 'linear', 'extrap');
        plot(t_settle, y_settle, 'go', 'MarkerFaceColor', 'g', 'MarkerSize', 6)
    end
end

grid on
xlabel('Time (s)')
ylabel('Output')
title('Output stabilization relative to setpoint')
legend([h_out, h_ref, h_band, h_settle], ...
    {'Output', 'Setpoint', '2% band', 'Settling point'}, ...
    'Location', 'best')
hold off

% Flag plot.
if numel(flag) == numel(t)
    t_flag = t;
else
    t_flag = linspace(t(1), t(end), numel(flag)).';
    warning('flag and time vectors have different sizes. A rescaled time axis was used for flag plot.');
end

figure('Name', 'HPC Flag', 'Color', 'w');
stairs(t_flag, flag, 'm', 'LineWidth', 1.4)
grid on
xlabel('Time (s)')
ylabel('Flag')
title('HPC Flag over time')

% Inverted pendulum bar angle plot.
figure('Name', 'Inverted Error Pendulum Bar Angle', 'Color', 'w');
plot(t, theta_bar, 'c', 'LineWidth', 1.5)
grid on
xlabel('Time (s)')
ylabel('Bar angle (rad)')
title('Inverted pendulum bar angle error over time')

