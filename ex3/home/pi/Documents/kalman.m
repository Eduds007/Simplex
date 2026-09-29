
data = load('measurement.txt'); 

t = data(:, 2); % Column 1: Time
y = data(:, 1); % Column 2: Voltage measurements

N = length(y);

%% 2. Define System Parameters (1D System)
Ad = 1;     
H  = 1;     
R  = thermalnoise_est(y,50) % Measurement noise covariance estimated from data
Q  = 1e-8;   % Process noise covariance
expected_voltage = 1.658; 

%% 3. Initialization
x_hat = y(1);  % Initialize with the very first measurement
P_k = 1;       % Initial error covariance
x_est = zeros(N, 1);

%% 4. Kalman Filter Loop
for k = 1:N
    % --- Step 1 & 2: Time Update ("Predict") ---
    x_pred = Ad * x_hat;               
    P_pred = Ad * P_k * Ad' + Q;       
    
    % Check if data is finite AND within physical voltage bounds
    if isfinite(y(k)) && y(k) > 0.5 && y(k) < 3.0
        
        % --- Step 3, 4, & 5: Measurement Update ("Correct") ---
        K_k = (P_pred * H') / (H * P_pred * H' + R); 
        x_hat = x_pred + K_k * (y(k) - H * x_pred); 
        P_k = (1 - K_k * H) * P_pred; 
        
    else
    
        x_hat = x_pred;
        P_k = P_pred;
    end
    
    x_est(k) = x_hat;
end

%% 5. Plotting 
figure('Color', 'w', 'Position', [100, 100, 1000, 600]);
hold on; grid on;
scatter(t, y, 5, 'g', 'filled', 'MarkerFaceAlpha', 0.4);
plot(t, x_est, 'b--', 'LineWidth', 1.5);
yline(expected_voltage, 'r--', 'LineWidth', 2);
title('Measurement Data with and without Kalman Filter', 'FontSize', 14);
xlabel('Time', 'FontSize', 12); 
ylabel('Measurement (V)', 'FontSize', 12);
legend('Raw data', 'Estimation', 'Expectation', 'Location', 'southeast', 'FontSize', 11);
hold off;

%% 6. Frequency Distribution Histograms (Before vs After Filtering)
valid_raw = isfinite(y);
raw_data = y(valid_raw);
filtered_data = x_est(isfinite(x_est));
all_data = [raw_data; filtered_data];
n_bins = round(sqrt(numel(raw_data)));
bin_edges = linspace(min(all_data), max(all_data), n_bins + 1);

figure('Color', 'w', 'Position', [150, 150, 1100, 450]);
tiledlayout(1, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

nexttile;
histogram(raw_data, bin_edges, 'FaceColor', [0.2, 0.7, 0.2], 'EdgeColor', 'k');
grid on;
title('Before Filtering (Raw Measurements)', 'FontSize', 12);
xlabel('Voltage (V)', 'FontSize', 11);
ylabel('Frequency', 'FontSize', 11);

nexttile;
histogram(filtered_data, bin_edges, 'FaceColor', [0.2, 0.4, 0.9], 'EdgeColor', 'k');
grid on;
title('After Filtering (Kalman Estimate)', 'FontSize', 12);
xlabel('Voltage (V)', 'FontSize', 11);
ylabel('Frequency', 'FontSize', 11);