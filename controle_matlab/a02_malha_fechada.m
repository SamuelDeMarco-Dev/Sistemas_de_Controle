%% a02 - Malha fechada T(s)
% =========================================================================
% EQUAÇÕES
%   T(s) = C(s)G(s) / (1 + C(s)G(s)H(s))
%   Com H = 1 e L = C*G = N/D:   T(s) = N / (D + N)
%   -> o numerador de L é SOMADO ao denominador
%   Ex.: P com G = 1/D  ->  T = k/(D + k)  (k só soma no termo independente)
% =========================================================================
clear; clc; close all
s = tf('s');
G = 1/((s+1)*(s+2.1)*(s+10.5));

%% 1) Numérico (k fixo)
k = 1;
T = feedback(k*G, 1)                % H = 1
pole(T)                             % -1.107 ; -1.980 ; -10.513

%% 2) Na mão com polinômios:  T = N/(D+N)
[N, D] = tfdata(k*G, 'v');
den_T  = D + N                      % tfdata já devolve vetores do mesmo tamanho
roots(den_T)

%% 3) Com controlador que tem 1/s (ex.: PI)
Cpi = 1*(s+0.1)/s;
Tpi = feedback(Cpi*G, 1)            % (s+0.1)/(s^4+13.6s^3+34.65s^2+23.05s+0.1)

%% 4) Simbólico: T(s) em função de K (precisa do Symbolic Math Toolbox)
% ATENÇÃO: usar outro nome (sv) para NÃO sobrescrever o s = tf('s')
syms sv K
Dsym = expand((sv+1)*(sv+2.1)*(sv+10.5));
T_K  = K / (Dsym + K);
disp('T(s) em funcao de K:'); disp(vpa(T_K, 6))

% PI simbólico: L = K(s+0.1)/(s*D)  ->  T = K(s+0.1)/(s*D + K(s+0.1))
T_PI_K = K*(sv+0.1) / expand(sv*Dsym + K*(sv+0.1));
disp('T(s) do PI em funcao de K:'); disp(vpa(T_PI_K, 6))
