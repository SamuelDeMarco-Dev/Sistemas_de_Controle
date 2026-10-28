%% a10 - Derivada e integral discretas do erro
% =========================================================================
% EQUAÇÕES
%   Derivada (diferença para trás):
%       de/dt |t=ta  ~  (e(ta) - e(ta-1)) / (ta - ta-1) = (e_a - e_a-1)/T
%   Laplace:  L{de/dt} = s E(s) - e(0)  ->  s E(s)  (cond. iniciais nulas)
%   Discreto: s ~ (1 - z^-1)/T = (z - 1)/(T z)
%
%   Integral (soma retangular):
%       I_a = I_a-1 + T*e_a       Laplace: E(s)/s      Discreto: T z/(z - 1)
%
%   PID discreto:  u_a = K1 e_a + K2 I_a + K3 (e_a - e_a-1)/T
% =========================================================================
clear; clc; close all

%% 1) Comparar derivada aproximada com a exata
T  = 0.05;
t  = 0:T:5;
e  = exp(-t).*cos(2*t);
de_exata = -exp(-t).*cos(2*t) - 2*exp(-t).*sin(2*t);
de_aprox = diff(e)/T;                    % (e_a - e_a-1)/T

figure; plot(t, de_exata, t(2:end), de_aprox, '--'); grid on
legend('exata', '(e_a - e_{a-1})/T'); title('Derivada do erro')

%% 2) Integral aproximada
I = cumsum(e)*T;                         % I_a = I_a-1 + T e_a
figure; plot(t, I); grid on; title('Integral do erro (soma)')

%% 3) Equivalentes em z
K3 = 15;
D_z = tf(K3*[1 -1], [T 0], T)            % K3 (z-1)/(T z)
I_z = tf([T 0], [1 -1], T)               % T z/(z-1)

%% 4) Laço do PID discreto (como seria no microcontrolador)
K1 = 301.5; K2 = 30;
I_ac = 0; e_ant = 0; u = zeros(size(e));
for a = 1:numel(e)
    I_ac  = I_ac + T*e(a);
    D     = (e(a) - e_ant)/T;
    u(a)  = K1*e(a) + K2*I_ac + K3*D;
    e_ant = e(a);
end
figure; plot(t, u); grid on; title('Sinal de controle u(t) do PID discreto')
