% Once values are loaded in the workspace, the simulink files should run,
% becuase they depend on the workspace

% Exercise 1 
% Done on paper

% Exercise 2
% Done on paper

% General values for the following exercises (extracted from the state
% space formulation 

A = [0 1 0 0;
    -0.3 0 0.2 0;
     0 0 0 1;
     0.4 0 -0.6 -0.002];

B = [0; 0.1; 0; 0];

% Exercise3
% Under the file step_response

% Exercise 4
% variables

p = [-2 -1.5 -1 -0.5];

init = [0.2; 0; 0.5; 0];

% gain to be aplied on the input X = -Ku
K = place(A,B,p);

%ts = out.pole_placement_vars;

%item 4 plot 
% figure
% plot(ts.Time, ts.Data(:,2),'LineWidth',2)
% hold on
% plot(ts.Time, ts.Data(:,4),'LineWidth',2)
% grid on
% xlabel('Time (s)')
% ylabel('Position (m)')
% legend('x2','x4')
% title('Pole Placement Response for velocities')

%item 5 variables
Q = eye(4);
R = 1;

%item 6 variables

%Q = 100*eye(4); %faster but more effort to control
R = 100; %slower, but with lower effort

%LQR for exercise 5 and 6
[K_lqr,S,e] = lqr(A,B,Q,R);

ts = out.lqr_vars;

%Plot
figure
plot(ts.Time, ts.Data(:,2),'LineWidth',2)
hold on
plot(ts.Time, ts.Data(:,4),'LineWidth',2)
grid on
xlabel('Time (s)')
ylabel('Position (m)')
legend('x2','x4')
title('LQR Response for velocities for Q = I and R = 100')

% Explanation for exercise 6:

% When the Q > R the weight into the "cost function" penalizes higher
% states so the minimization problem will aim at converging faster no
% matter what the input is. This can cause the effort to control to be
% higher. On the other side, when R > Q, we penalize high efforts under
% uRu, which means we'll take more time to achieve stability but the effort
% will be significantly lower.
