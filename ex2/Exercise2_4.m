import utils.*

x0=[0.479; 0.0872; -0.8726; 0 ; 0 ; 0];

Q = diag([100 1 10 0 0 2]);

Acl_max = A - B*K_max_vol;
sys = ss(Acl_max, [], eye(size(Acl_max)), []);
t = 0:0.01:50;

[y,t,x] = initial(sys, x0, t);
plot_states(t, x, 'Exercise 24 - Result for maximal volume recovery region');
analyze_value(y,t,Q);
