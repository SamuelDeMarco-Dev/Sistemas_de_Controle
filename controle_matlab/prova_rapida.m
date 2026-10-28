%% prova_rapida - TROQUE SÓ O BLOCO "ENTRADAS" E RODE (F5)
% Faz tudo de uma vez: T(s), polos, zeros, Routh, erro, transitório, gráficos
clear; clc; close all
s = tf('s');

%% ===================== ENTRADAS =====================
G = 1/((s+1)*(s+2.1)*(s+10.5));     % planta
H = 1;                              % realimentação

% Escolha UM controlador (descomente):
C = 100;                            % P
% C = 100*(s+0.1)/s;                % PI   k(s+zi)/s
% C = 15*(s+0.1)*(s+20)/s;          % PID  k(s+zi)(s+zd)/s
% C = 301.5 + 30/s + 15*s;          % PID  K1 + K2/s + K3 s
%% ====================================================

L = C*G*H;
T = feedback(C*G, H);

fprintf('==================== MALHA ABERTA ====================\n');
zpk(L)
fprintf('Polos L : %s\n', num2str(pole(L).', '%.4f '));
fprintf('Zeros L : %s\n', num2str(zero(L).', '%.4f '));

fprintf('\n==================== MALHA FECHADA ===================\n');
T
zpk(T)
fprintf('Polos T : %s\n', num2str(pole(T).', '%.4f '));
fprintf('Zeros T : %s\n', num2str(zero(T).', '%.4f '));

fprintf('\n==================== ESTABILIDADE ====================\n');
[~, den] = tfdata(T, 'v');
routh(den);
[Gm, ~, Wcg] = margin(L);
fprintf('Ganho pode ser multiplicado por ate %.4g (w = %.4g rad/s)\n', Gm, Wcg);

if isstable(T)
    fprintf('\n==================== REGIME ==========================\n');
    erro_regime(L);
    fprintf('dcgain(T) = c(inf) = %.4f\n', dcgain(T));

    fprintf('\n==================== TRANSITÓRIO =====================\n');
    info = stepinfo(T);
    fprintf('tp = %.4f s  ts(2%%) = %.4f s  tr = %.4f s  %%OS = %.2f %%\n', ...
            info.PeakTime, info.SettlingTime, info.RiseTime, info.Overshoot);
    info_polos(T);

    figure; step(T); grid on; title('Resposta ao degrau')
else
    fprintf('\n*** SISTEMA INSTAVEL: erro em regime e stepinfo NAO valem ***\n');
end
figure; pzmap(T); grid on; title('Polos e zeros de T(s)')
figure; rlocus(L/ganho_controlador(C)); grid on; title('Lugar das raizes (ganho do controlador normalizado)')

function g = ganho_controlador(C)
% ganho "k" do controlador para normalizar o rlocus
[~, ~, g] = zpkdata(zpk(C), 'v');
if g == 0, g = 1; end
end
