import utils.*



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


x0=[0.479; 0.0872; -0.8726; 0 ; 0 ; 0];

% Exercise 21 - item 1

Q = diag([100 1 10 0 0 2]);
R = diag([10 10]);


K_item1 = lqr(A, B, Q, R);

Acl1 = A - B*K_item1;
sys = ss(Acl1, [], eye(size(Acl1)), []);
t = 0:0.01:20;

[y,t,x] = initial(sys, x0, t);
plot_states(t, x, 'Exercise 21 - item 1: Result for LQR with Q=diag([100 1 10 0 0 2]) and R=diag([10 10])');
analyze_value(y,t,Q);

% Exercise 21 - item 2

Q = diag([100 1 10 0 0 2]);
R = diag([0.25 0.25]);

K_item2 = lqr(A, B, Q, R);

Acl2 = A - B*K_item2;
sys = ss(Acl2, [], eye(size(Acl2)), []);
t = 0:0.01:20;

[y,t,x] = initial(sys, x0, t);
plot_states(t, x, 'Exercise 21 - item 2: Result for LQR with Q=diag([100 1 10 0 0 2]) and R=diag([0.25 0.25])');
analyze_value(y,t,Q);
