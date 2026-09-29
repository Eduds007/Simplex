yalmip('clear');  % clean YALMIP environment

x1 = sdpvar(1,1);
x2 = sdpvar(1,1);

Constraints = [0 <= x1 <= 1, 0 <= x2 <= 2, 2*x1 + x2 <= 2];

Objective = -(x1 + x2);

opts = sdpsettings('solver','sedumi','verbose',1);

sol = optimize(Constraints,Objective,opts);

if sol.problem == 0
 solutionx1 = value(x1)
 solutionx2 = value(x2)
else
 display('Hmm, something went wrong!');
 sol.info
 yalmiperror(sol.problem)
end
