%% a09 - Controladores com amplificador operacional
% =========================================================================
% EQUAÇÕES  (inversor)  Vs/Ve = -Z2/Z1
%   Resistor: Z = R      Capacitor: Z = 1/(sC)
%   Série: Z = Za + Zb   Paralelo: Z = Za*Zb/(Za + Zb)
%
%   P :  Z1 = R1, Z2 = R2              ->  -R2/R1          (ganho = R2/R1)
%   PI:  Z1 = R1, Z2 = R2 + 1/(sC)     ->  -(R2/R1)(s + 1/(R2 C))/s
%        k = R2/R1     zi = 1/(R2 C)   ->  R2 = 1/(zi C),  R1 = R2/k
%   PID: Z1 = R1 || C1, Z2 = R2 + 1/(sC2)
%        K1 = R2/R1 + C1/C2   K2 = 1/(R1 C2)   K3 = R2 C1
%   Sinal negativo -> inversor de ganho -1 em série
% =========================================================================
clear; clc; close all
s = tf('s');

%% 1) P
R1 = 10e3; R2 = 1e6;
Gp = -R2/R1                              % -100

%% 2) PI: dimensionar para k = 100, zi = 0.1, C = 10 uF
[R1, R2] = ampop_pi(100, 0.1, 10e-6);    % 10 kOhm ; 1 MOhm
C   = 10e-6;
Z1  = R1;
Z2  = R2 + 1/(s*C);
Gpi = -Z2/Z1;
zpk(Gpi)                                 % -100 (s+0.1)/s

%% 3) PID: dimensionar para K1 = 301.5, K2 = 30, K3 = 15, C2 = 10 uF
sol = ampop_pid(301.5, 30, 15, 10e-6);
q   = sol(1);
Z1  = 1/(1/q.R1 + s*q.C1);               % R1 || C1
Z2  = q.R2 + 1/(s*q.C2);                 % R2 + C2
Gpid = minreal(-Z2/Z1);
zpk(Gpid)                                % -15 (s+20)(s+0.1)/s
