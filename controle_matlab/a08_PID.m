%% a08 - Controlador PID
% =========================================================================
% EQUAÇÕES
%   G_PID = K1 + K2/s + K3 s = (K3 s^2 + K1 s + K2)/s = k(s+zi)(s+zd)/s
%   K1 = k(zi + zd)      K2 = k*zi*zd      K3 = k
%   1 polo (s = 0) e 2 zeros (-zi, -zd)  -> impróprio (2 zeros > 1 polo)
%   Na prática: D filtrado  K3 s/(tau s + 1)
%   Inverso: zi, zd = -raízes de K3 s^2 + K1 s + K2 = 0
% =========================================================================
clear; clc; close all
s = tf('s');
G = 1/((s+1)*(s+2.1)*(s+10.5));

%% 1) Ganhos
k = 15; zi = 0.1; zd = 20;
[K1, K2, K3] = pid_ganhos(k, zi, zd);   % 301.5 ; 30 ; 15

%% 2) As duas formas (devem dar igual)
Gpid_a = K1 + K2/s + K3*s;
Gpid_b = k*(s+zi)*(s+zd)/s;
zpk(Gpid_a), zpk(Gpid_b)
pole(Gpid_b), zero(Gpid_b)

%% 3) Caminho inverso
pid_para_zeros(K1, K2, K3);

%% 4) Malha fechada
Tpid = feedback(Gpid_b*G, 1)
pole(Tpid)
stepinfo(Tpid)
fprintf('c(inf) = %.4f   e(inf) = %.4f\n', dcgain(Tpid), 1-dcgain(Tpid));

%% 5) Por que não k = 100? -> instável
T100 = feedback(100*(s+zi)*(s+zd)/s*G, 1);
pole(T100)                              % par com parte real > 0
isstable(T100)                          % 0

%% 6) PID realizável (derivada filtrada)
tau     = 0.01;
Gpid_f  = K1 + K2/s + K3*s/(tau*s + 1);
Tpid_f  = feedback(Gpid_f*G, 1);
figure; step(Tpid, Tpid_f, 15); grid on
legend('PID ideal', 'PID com filtro'); title('PID')

%% 7) Bloco pronto do MATLAB (mesma parametrização K1 + K2/s + K3 s)
C = pid(K1, K2, K3)                     % pid(Kp, Ki, Kd)
