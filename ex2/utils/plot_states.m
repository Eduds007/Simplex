
function plot_states(T, X, name)
% Plota x1,x2,x3 em subplots separados
% T: vetor tempo, X: matriz estados (linhas = amostras), name: título da figura

figure('Name', name);
tiledlayout(3,1);
for i = 1:3
    nexttile
    plot(T, X(:,i), 'LineWidth', 1.2);
    grid on
    ylabel(sprintf('x%d (rad)', i));
    legend(sprintf('x%d', i), 'Location', 'best');
    if i==1, title(name); end
    if i==3, xlabel('Tempo (s)'); end
end

