%% a03 - Estabilidade: Routh-Hurwitz e faixa de K
% =========================================================================
% EQUAÇÕES
%   Estável  <=>  todos os polos de T(s) com parte real < 0
%   Routh: nº de trocas de sinal na 1ª coluna = nº de polos no SPD
%   Elemento:  b1 = (a1*a2 - a0*a3)/a1   ("determinante cruzado")
%   K crítico: linha s^1 = 0 -> polos sobre o eixo jw
%   Freq. de oscilação: linha s^2 -> A s^2 + B = 0 -> w = sqrt(B/A)
%   Atalho 3ª ordem  s^3 + a2 s^2 + a1 s + a0:  estável se a2*a1 > a0 (e todos > 0)
% =========================================================================
clear; clc; close all
s = tf('s');
G = 1/((s+1)*(s+2.1)*(s+10.5));

%% 1) Routh numérico (k = 1)
T = feedback(1*G, 1);
[~, den] = tfdata(T, 'v');
[tab, n_spd] = routh(den);
isstable(T)

%% 2) Faixa de K por Routh simbólico
syms K
D    = [1 13.6 34.65 22.05];             % den de G
tabK = routh([D(1:end-1), D(end) + K]);  % den de T = D + K
col1 = tabK(:,1)

K_crit = double(solve(col1(end-1) == 0, K))   % linha s^1 = 0  -> 449.19
K_min  = double(solve(col1(end)   == 0, K))   % linha s^0 = 0  -> -22.05
fprintf('Estavel para %.4g < K < %.4g\n', K_min, K_crit);

%% 3) Frequência de oscilação no K crítico (linha s^2)
A = double(subs(tabK(end-2,1), K, K_crit));
B = double(subs(tabK(end-2,2), K, K_crit));
w_crit = sqrt(B/A)                        % 5.886 rad/s

%% 4) Conferir: margem de ganho = K crítico (G com ganho 1)
[Gm, ~, Wcg] = margin(G)                  % Gm ~ 449.19 ; Wcg ~ 5.886
figure; rlocus(G); grid on; title('Lugar das raizes de G(s)')

%% 5) Exemplo instável: PID com k = 100
Tinst = feedback(100*(s+0.1)*(s+20)/s*G, 1);
[~, d2] = tfdata(Tinst, 'v');
routh(d2);                                % 2 trocas -> 2 polos no SPD
