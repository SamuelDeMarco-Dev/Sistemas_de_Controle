%% a04 - Erro em regime permanente e tipo do sistema (Nise cap. 7)
% =========================================================================
% EQUAÇÕES (realimentação unitária)
%   E(s) = R(s)/(1 + L(s))            e(inf) = lim s->0  s*E(s)
%   c(inf) = lim s->0  s*T(s)*R(s) = T(0)  (degrau unitário)
%   e(inf) = 1 - c(inf)               (degrau unitário, H = 1)
%
%   Tipo = nº de integradores (polos em s=0) em L(s) = C(s)G(s)
%   Kp = lim L(s)     Kv = lim s*L(s)     Ka = lim s^2*L(s)
%
%              Degrau      Rampa     Parábola
%   Tipo 0    1/(1+Kp)      inf        inf
%   Tipo 1       0         1/Kv        inf
%   Tipo 2       0          0          1/Ka
%
%   Forma direta (tipo 0, L = N/D):  e_degrau = D(0)/(D(0)+N(0))
%   !! Teorema do Valor Final só vale se T(s) for ESTÁVEL !!
% =========================================================================
clear; clc; close all
s = tf('s');
G = 1/((s+1)*(s+2.1)*(s+10.5));

%% 1) Controlador P (tipo 0)
for k = [1 2.65 100]
    T    = feedback(k*G, 1);
    cinf = dcgain(T);
    fprintf('P  k = %-6g  c(inf) = %.4f   e(inf) = %.4f\n', k, cinf, 1-cinf);
end

%% 2) Função pronta: tipo, Kp, Kv, Ka e erros
erro_regime(2.65*G)                 % tipo 0
erro_regime(100*(s+0.1)/s*G)        % PI -> tipo 1, e_degrau = 0

%% 3) Erro à rampa (simulação) para o PI
L   = 100*(s+0.1)/s*G;
T   = feedback(L, 1);
t   = 0:0.01:100;
y   = lsim(T, t, t);                % entrada rampa r(t) = t
fprintf('Erro final a rampa (simulado) = %.4f\n', t(end) - y(end));
figure; plot(t, t, '--', t, y); grid on
legend('r(t) = t', 'c(t)'); title('Resposta a rampa - PI')

%% 4) Teorema do Valor Final simbólico (mostra a fórmula em função de K)
syms sv K
Gs    = 1/((sv+1)*(sv+2.1)*(sv+10.5));
Ts    = K*Gs/(1 + K*Gs);
c_inf = simplify(limit(sv*Ts*(1/sv), sv, 0))      % K/(K + 22.05)
e_inf = simplify(1 - c_inf)
double(subs(c_inf, K, [1 2.65]))
