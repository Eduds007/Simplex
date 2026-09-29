

Q = sdpvar(4, 4, 'symmetric');
Z = sdpvar(1, 4, 'full'); % 1 inputs, 4 states

Obj = -logdet(Q);

% 1. Lyapunov Stability Constraint: Q*A' + A*Q + Z'*B' + B*Z < 0

constraint = [ Q * A' + A * Q + Z' * B' + B * Z <= -1e-8 * eye(4), ...
              Q >= 1e-8 * eye(4) ];

% 2. State Constraints: alpha_k^T * Q * alpha_k <= 1
base = zeros(4,1);
alpha_1 = base; alpha_1(1) = 1/2.2;   % |x1| <= 2.2
alpha_2 = base; alpha_2(1) = -1/2.2;  % |x1| <= 2.2
alpha_3 = base; alpha_3(2) = 1/5;     % |x2| <= 5
alpha_4 = base; alpha_4(2) = -1/5;    % |x2| <= 5
alpha_5 = base; alpha_5(3) = 6/pi;     % |x3| <= pi/6
alpha_6 = base; alpha_6(3) = -6/pi;    % |x3| <= pi/6


alphas_state = {alpha_1, alpha_2, alpha_3, alpha_4, alpha_5, alpha_6};
for k = 1:length(alphas_state)
    constraint = [constraint, alphas_state{k}' * Q * alphas_state{k} <= 1];
end

% 3. Input Constraints: [I, b_j^T * Z; Z^T * b_j, Q] >= 0   
b_u1 = [1/30];     % |u1| <= 30
b_u1_ = [-1/30];     % |u1| <= 30

constraint = [constraint, [1, b_u1' * Z; Z' * b_u1, Q] >= 0];
constraint = [constraint, [1, b_u1_' * Z; Z' * b_u1_, Q] >= 0];

opts = sdpsettings('solver','sdpt3','verbose',1,'debug',1);
sol = optimize(constraint, Obj, opts);

if sol.problem == 0
    Q_opt_max = value(Q);
    Z_opt = value(Z);
    
    % Recover the optimal control gain: K = -Z * Q^-1
    P = inv(Q_opt_max)
    K = -Z_opt * P
    

    else
    disp('Maximal Volume Failed! Something went wrong.');
    disp(sol.info);
    disp(yalmiperror(sol.problem));
end
