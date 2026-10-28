function sol = ampop_pid(K1, K2, K3, C2)
% AMPOP_PID  Dimensiona o PID com amp. op. (Nise, tabela 9.10).
%
%   CIRCUITO:  Z1 = R1 em PARALELO com C1 ;  Z2 = R2 em SÉRIE com C2
%   EQUAÇÕES:  G = -[ (R2/R1 + C1/C2) + R2*C1*s + 1/(R1*C2*s) ]
%              K1 = R2/R1 + C1/C2     K3 = R2*C1     K2 = 1/(R1*C2)
%   ORDEM (escolhendo C2):
%     R1 = 1/(K2*C2)
%     C1^2 - K1*C2*C1 + K2*K3*C2^2 = 0   (2 soluções)
%     R2 = K3/C1
%
%   EXEMPLO:  sol = ampop_pid(301.5, 30, 15, 10e-6)
%     -> R1 = 3.33 kOhm ; (C1 = 15 uF, R2 = 1 MOhm) ou (C1 = 3 mF, R2 = 5 kOhm)
R1   = 1/(K2*C2);
disc = (K1*C2)^2 - 4*K2*K3*C2^2;
if disc < 0
    error('Sem solucao real (K1^2 < 4*K2*K3).');
end
C1 = [(K1*C2 - sqrt(disc))/2, (K1*C2 + sqrt(disc))/2];
R2 = K3 ./ C1;
for i = 1:2
    sol(i).R1 = R1; sol(i).C1 = C1(i); sol(i).R2 = R2(i); sol(i).C2 = C2; %#ok<AGROW>
    fprintf('Solucao %d: R1 = %.4g Ohm  C1 = %.4g F  R2 = %.4g Ohm  C2 = %.4g F\n', ...
            i, R1, C1(i), R2(i), C2);
end
fprintf('(escolha a com valores comerciais mais razoaveis)\n');
end
