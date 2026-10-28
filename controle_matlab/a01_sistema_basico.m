%% a01 - Definir o sistema, polos, zeros e forma polinomial
% =========================================================================
% EQUAÇÕES
%   G(s) = N(s)/D(s)
%   Polos = raízes de D(s) = 0        Zeros = raízes de N(s) = 0
%   Expandir (s+a)(s+b)(s+c) -> conv() ou poly([-a -b -c])
%   Conferência: soma dos polos = -(coef. de s^(n-1))
%                produto dos |polos| = termo independente (se monico)
% =========================================================================
clear; clc; close all

s = tf('s');       % SEMPRE tf (não syms) para usar feedback/step/dcgain

%% 1) Definir a planta na forma fatorada
G = 1/((s+1)*(s+2.1)*(s+10.5))

%% 2) Ver nas duas formas
zpk(G)                              % fatorada: polos e zeros visíveis
[num, den] = tfdata(G, 'v')         % den = [1 13.6 34.65 22.05]

%% 3) Polos e zeros
p = pole(G)
z = zero(G)
figure; pzmap(G); grid on; title('Polos e zeros de G(s)')

%% 4) Expandir o polinômio (conferir conta feita à mão)
den_conv = conv(conv([1 1], [1 2.1]), [1 10.5])   % (s+1)(s+2.1)(s+10.5)
den_poly = poly([-1 -2.1 -10.5])                   % mesma coisa pelos polos

%% 5) Polo mais próximo da origem (usado no projeto do PI)
p_nz = p(abs(p) > 1e-9);            % ignora polos em s = 0
[~, i] = min(abs(p_nz));
polo_mais_proximo = p_nz(i)         % -1
