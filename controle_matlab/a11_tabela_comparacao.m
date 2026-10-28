%% a11 - Tabela de comparação P x PI x PID
% =========================================================================
% Para cada controlador C(s):
%   T = feedback(C*G, 1)
%   polos = pole(T)   zeros = zero(T)   c(inf) = dcgain(T)   e(inf) = 1 - c(inf)
%   tp e ts -> stepinfo(T)  (ts com critério de 2%)
% =========================================================================
clear; clc; close all
s = tf('s');
G = 1/((s+1)*(s+2.1)*(s+10.5));

nomes = {'P (k=100)', 'PI (k=100, zi=0.1)', 'PID (k=15, zi=0.1, zd=20)'};
C     = {100, 100*(s+0.1)/s, 15*(s+0.1)*(s+20)/s};

figure; hold on; grid on
for i = 1:numel(C)
    T    = feedback(C{i}*G, 1);
    info = stepinfo(T);
    cinf = dcgain(T);

    fprintf('\n===== %s =====\n', nomes{i});
    fprintf('Polos : '); fprintf('%s  ', num2str(pole(T).', '%.4f ')); fprintf('\n');
    z = zero(T);
    if isempty(z), fprintf('Zeros : -\n');
    else, fprintf('Zeros : %s\n', num2str(z.', '%.4f ')); end
    fprintf('c(inf) = %.4f   e(inf) = %.4f\n', cinf, 1-cinf);
    fprintf('tp = %.4f s   ts = %.4f s   %%OS = %.2f %%\n', ...
            info.PeakTime, info.SettlingTime, info.Overshoot);
    fprintf('Estavel: %d\n', isstable(T));

    [y, t] = step(T, 40);
    plot(t, y, 'DisplayName', nomes{i});
end
legend show; title('Comparacao P x PI x PID'); xlabel('t (s)'); ylabel('c(t)')
