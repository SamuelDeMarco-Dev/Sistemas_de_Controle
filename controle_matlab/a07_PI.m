%% a07 - Controlador PI
% =========================================================================
% EQUAÇÕES
%   G_PI = K1 + K2/s = (K1 s + K2)/s = K1 (s + K2/K1)/s = k (s + zi)/s
%   k = K1        zi = K2/K1        K2 = k*zi
%   Polo em s = 0 (integrador)  ->  tipo +1  ->  e_degrau = 0
%   Zero em s = -zi
%   Projeto: zi = 0.1 * |polo da planta mais próximo da origem|
%            (zero perto do polo em 0 -> quase cancelam -> transitório mantido)
% =========================================================================
clear; clc; close all
s = tf('s');
G = 1/((s+1)*(s+2.1)*(s+10.5));

%% 1) Escolher zi (10% do polo mais próximo da origem)
p  = pole(G);
zi = 0.1*min(abs(p(abs(p) > 1e-9)))     % 0.1

%% 2) Ganhos e as duas formas
k = 100;
[K1, K2] = pi_ganhos(k, zi);            % 100 ; 10
Gpi_a = K1 + K2/s;
Gpi_b = k*(s + zi)/s;
zpk(Gpi_a), zpk(Gpi_b)                  % iguais
pole(Gpi_b), zero(Gpi_b)                % 0 ; -0.1

%% 3) Malha fechada e valores finais
Tp  = feedback(k*G, 1);
Tpi = feedback(Gpi_b*G, 1)
fprintf('P : c(inf) = %.4f  e(inf) = %.4f\n', dcgain(Tp),  1-dcgain(Tp));
fprintf('PI: c(inf) = %.4f  e(inf) = %.4f\n', dcgain(Tpi), 1-dcgain(Tpi));
erro_regime(Gpi_b*G);

%% 4) Comparação gráfica
figure; step(Tp, Tpi, 40); grid on
legend('P', 'PI'); title('P x PI (k = 100)')
figure; pzmap(Gpi_b*G); grid on; title('Malha aberta com PI')

%% 5) Caminho inverso (dados K1, K2)
pid_para_zeros(100, 10, 0);             % k = 100 ; zi = 0.1
