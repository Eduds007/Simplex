yalmip('clear'); clc;

function result = recovery_region(K, Acl)

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


% exercise 2 - item 2


% : |x1|≤ 0.5233, |x2|≤ 0.174, |x3|≤ 3.14, |x5|≤ 0.174, |u1|≤ 24, |u2|≤ 24.
base = zeros(6,1);

alpha_1 = base; alpha_1(1) = 1/0.5233;   % |x1| <= 0.5233
alpha_2 = base; alpha_2(1) = -1/0.5233;  % |x1| <= 0.5233
alpha_3 = base; alpha_3(2) = 1/0.174;     % |x2| <= 0.174
alpha_4 = base; alpha_4(2) = -1/0.174;    % |x2| <= 0.174
alpha_5 = base; alpha_5(3) = 1/3.14;     % |x3| <= 3.14
alpha_6 = base; alpha_6(3) = -1/3.14;    % |x3| <= 3.14
alpha_7 = base; alpha_7(5) = 1/0.174;     % |x5| <= 0.174
alpha_8 = base; alpha_8(5) = -1/0.174;    % |x5| <= 0.174
alpha_9  = -K'*[1/24;0];     % |u1| <= 24
alpha_10 = -K'*[-1/24;0];    % |u1| <= 24
alpha_11  = -K'*[0;1/24];     % |u2| <= 24 
alpha_12  = -K'*[0;-1/24];    % |u2| <= 24


n=6;
Q = sdpvar(n,n,'symmetric');
Objective = -logdet(Q);
eps_num = 1e-8;
Constraints = [
    Q*Acl' + Acl*Q  <= 0,  
    Q >= eps_num*eye(n),
    alpha_1'*Q*alpha_1 <= 1,
    alpha_2'*Q*alpha_2 <= 1,
    alpha_3'*Q*alpha_3 <= 1,
    alpha_4'*Q*alpha_4 <= 1,
    alpha_5'*Q*alpha_5 <= 1,
    alpha_6'*Q*alpha_6 <= 1,
    alpha_7'*Q*alpha_7 <= 1,
    alpha_8'*Q*alpha_8 <= 1,
    alpha_9'*Q*alpha_9 <= 1,
    alpha_10'*Q*alpha_10 <= 1,
    alpha_11'*Q*alpha_11 <= 1,
    alpha_12'*Q*alpha_12 <= 1
]

opts = sdpsettings('solver','sdpt3','verbose',1,'debug',1);
sol = optimize(Constraints, Objective, opts);


if sol.problem == 0
    Qopt = value(Q);
    Popt = inv(Qopt);
    result = Popt;


else
    disp('Hmm, algo deu errado!');
    disp(sol.info);
    disp(yalmiperror(sol.problem));
end

        
end


P1 = recovery_region(K_item1, Acl1);
P2 = recovery_region(K_item2, Acl2);

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
    P11 = P1(idx, idx);
    [R,~] = chol(P11);
    Z = R \ Ucircle;
    plot(Z(1,:), Z(2,:), 'Color', colors{1}, 'LineWidth', 1.5);

    % ----- Controller 2 -----
    P22 = P2(idx, idx);
    [R,~] = chol(P22);
    Z = R \ Ucircle;
    plot(Z(1,:), Z(2,:), 'Color', colors{2}, 'LineWidth', 1.5);

    legend(labels);

    hold off;

    area1 = pi / sqrt(det(P11))
    area2 = pi / sqrt(det(P22))
end