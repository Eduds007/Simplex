
A=[ 0  0  0  1      0      0;
      0  0  0  0      1      0;
      0  0  0  0      0      1;
      0  0  0  0      0      0;
      0  0  0  0      0      0;
      0 -1.2304 0  0  0      0];

B = [ 0       0;
      0       0;
      0       0;
      0.0858  0.0858;
      0.5810 -0.5810;
      0       0];

base = zeros(6,1);

%2.3) Recovery region with maximal volume

Q_max = sdpvar(6, 6);
Z_max = sdpvar(2, 6, 'full'); % 2 inputs, 6 states

% Objective: Maximize volume of ellipsoid = Minimize -logdet(Q)
Obj_max = -logdet(Q_max);

% 1. Lyapunov Stability Constraint: Q*A' + A*Q + Z'*B' + B*Z < 0
Constraints = [ Q_max * A' + A * Q_max + Z_max' * B' + B * Z_max <= -0.0001*eye(6), ...
              Q_max >=0.0001*eye(6) ]; % Ensure Q is positive definite with a small margin

% 2. State Constraints: alpha_k^T * Q * alpha_k <= 1
alpha_1 = base; alpha_1(1) = 1/0.5233;   % |x1| <= 0.5233
alpha_2 = base; alpha_2(1) = -1/0.5233;  % |x1| <= 0.5233
alpha_3 = base; alpha_3(2) = 1/0.174;     % |x2| <= 0.174
alpha_4 = base; alpha_4(2) = -1/0.174;    % |x2| <= 0.174
alpha_5 = base; alpha_5(3) = 1/3.14;     % |x3| <= 3.14
alpha_6 = base; alpha_6(3) = -1/3.14;    % |x3| <= 3.14
alpha_7 = base; alpha_7(5) = 1/0.174;     % |x5| <= 0.174
alpha_8 = base; alpha_8(5) = -1/0.174;    % |x5| <= 0.174

Constraints = [Constraints, alpha_1'*Q_max*alpha_1 <= 1];
Constraints = [Constraints, alpha_2'*Q_max*alpha_2 <= 1];
Constraints = [Constraints, alpha_3'*Q_max*alpha_3 <= 1];
Constraints = [Constraints, alpha_4'*Q_max*alpha_4 <= 1];
Constraints = [Constraints, alpha_5'*Q_max*alpha_5 <= 1];
Constraints = [Constraints, alpha_6'*Q_max*alpha_6 <= 1];
Constraints = [Constraints, alpha_7'*Q_max*alpha_7 <= 1];
Constraints = [Constraints, alpha_8'*Q_max*alpha_8 <= 1];


% 3. Input Constraints: [I, b_j^T * Z; Z^T * b_j, Q] >= 0

b_u1 = [1/24; 0]; 
b_u2 = [-1/24; 0]; 
b_u3 = [0; 1/24];
b_u4 = [0; -1/24];

Constraints = [Constraints, [1, b_u1' * Z_max; Z_max' * b_u1, Q_max] >= 0];
Constraints = [Constraints, [1, b_u2' * Z_max; Z_max' * b_u2, Q_max] >= 0];
Constraints = [Constraints, [1, b_u3' * Z_max; Z_max' * b_u3, Q_max] >= 0];
Constraints = [Constraints, [1, b_u4' * Z_max; Z_max' * b_u4, Q_max] >= 0];

% Solve the optimization problem using sdpt3 as recommended
opts_max = sdpsettings('solver','sdpt3','verbose',1,'debug',1);
sol_max = optimize(Constraints, Obj_max, opts_max);


if sol_max.problem == 0
    Q_opt_max = value(Q_max);
    Z_opt = value(Z_max);
    
    % Recover the optimal control gain: K = -Z * Q^-1,
    P= inv(Q_opt_max);
    K_max_vol = -Z_opt *P; 
    
    
    disp('Maximal Volume OK! Optimal solution found.');
    disp('Optimal Control Gain K_max_vol ='); 
    disp(K_max_vol);
else
    disp('Maximal Volume Failed! Something went wrong.');
    disp(sol_max.info);
    disp(yalmiperror(sol_max.problem));
end


%Plot the recovery regions for the optimal P* matrix

planes = [1 4; 2 5; 3 6];
colors = {'b','r'};
labels = {'Controller 1','Controller 2'};

th = linspace(0,2*pi,360);
Ucircle = [cos(th); sin(th)];

for k = 1:size(planes,1)

    idx = planes(k,:);
    figure('Name', sprintf('Recovery region: x%d-x%d', idx(1), idx(2)));
    hold on; grid on; axis equal;

    xlabel(sprintf('x%d', idx(1)));
    ylabel(sprintf('x%d', idx(2)));

    title(sprintf('Recovery region — x%d vs x%d', idx(1), idx(2)));

    % ----- Controller 1 -----
    P11 = P(idx, idx);
    [R,~] = chol(P11);
    Z = R \ Ucircle;
    plot(Z(1,:), Z(2,:), 'Color', colors{1}, 'LineWidth', 1.5);

    legend(labels);

    hold off;

    area1 = pi / sqrt(det(P11))
end