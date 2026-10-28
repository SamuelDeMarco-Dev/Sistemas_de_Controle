%% a05 - Resposta transitória: zeta, wn, %OS, Tp, Ts (Nise cap. 4)
% =========================================================================
% EQUAÇÕES (2ª ordem):   T(s) = wn^2/(s^2 + 2*zeta*wn*s + wn^2)
%   Polos:  s = -zeta*wn +/- j*wn*sqrt(1-zeta^2) = -sigma +/- j*wd
%   wn = |polo|        zeta = sigma/wn = cos(theta)
%   %OS = 100*exp(-zeta*pi/sqrt(1-zeta^2))
%   zeta = -ln(%OS/100)/sqrt(pi^2 + ln^2(%OS/100))
%   Tp = pi/wd         Ts (2%) = 4/sigma = 4/(zeta*wn)
%   Tr ~ (1.768 zeta^3 - 0.417 zeta^2 + 1.039 zeta + 1)/wn
%
%   stepinfo: SettlingTime usa 2% por padrão, RiseTime usa 10%-90%
% =========================================================================
clear; clc; close all
s = tf('s');
G = 1/((s+1)*(s+2.1)*(s+10.5));

%% 1) Medição exata por simulação
T    = feedback(100*G, 1);
info = stepinfo(T)
fprintf('Tp = %.4f s   Ts = %.4f s   %%OS = %.2f %%\n', ...
        info.PeakTime, info.SettlingTime, info.Overshoot);

%% 2) Aproximação de 2ª ordem pelo polo dominante
r = info_polos(T);

%% 3) zeta a partir de %OS (e vice-versa)
OS   = 20;                                        % %OS desejado
zeta = -log(OS/100)/sqrt(pi^2 + log(OS/100)^2)    % 0.456
OS_v = 100*exp(-zeta*pi/sqrt(1-zeta^2))           % volta 20

%% 4) Polos desejados a partir de Ts e %OS
Ts_des = 2;
sigma  = 4/Ts_des;
wn     = sigma/zeta;
wd     = wn*sqrt(1-zeta^2);
polo_desejado = -sigma + 1j*wd

%% 5) Gráfico
figure; step(T); grid on; title('Degrau - P com k = 100')
