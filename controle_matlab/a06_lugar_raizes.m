%% a06 - Lugar das raízes: ponto de partida, K para zeta, K crítico
% =========================================================================
% EQUAÇÕES
%   1 + K*G(s) = 0      condição de ângulo: angle(G) = 180°
%                       condição de módulo: K = 1/|G(s)|
%   Ponto de partida:   dK/ds = 0  ->  N'D - ND' = 0
%   Reta de zeta:       theta = acos(zeta) medido a partir do eixo real negativo
%   K crítico:          cruzamento com eixo jw (Routh ou margin)
%   Assíntotas:  sigma_a = (soma polos - soma zeros)/(np - nz)
%                theta_a = (2m+1)*180/(np - nz)
% =========================================================================
clear; clc; close all
s = tf('s');
G = 1/((s+1)*(s+2.1)*(s+10.5));

%% 1) Desenhar
figure; rlocus(G); grid on; title('Lugar das raizes')
sgrid(0.5, [])                          % reta de zeta = 0.5

%% 2) Ponto de partida (polos reais viram complexos)
[sb, Kb] = ponto_partida(G);            % s ~ -1.533 ; K ~ 2.71

%% 3) K para um zeta (ou %OS) desejado
[K05, p05] = k_para_zeta(G, 0.5);       % K ~ 49.69
OS   = 20;
zeta = -log(OS/100)/sqrt(pi^2 + log(OS/100)^2);
[K20, p20] = k_para_zeta(G, zeta);      % K ~ 58.87

%% 4) K crítico
[Gm, ~, Wcg] = margin(G);
fprintf('K critico = %.4f   w = %.4f rad/s\n', Gm, Wcg);

%% 5) Assíntotas
p  = pole(G); z = zero(G);
na = numel(p) - numel(z);
sigma_a = (sum(p) - sum(z))/na
theta_a = (2*(0:na-1)+1)*180/na

%% 6) Conferir: polos com o K encontrado
pole(feedback(K05*G, 1))

%% 7) Clicar no gráfico para ler K (opcional)
% figure; rlocus(G); [Kc, polos] = rlocfind(G)
