function [R1, R2] = ampop_pi(k, zi, C)
% AMPOP_PI  Dimensiona o PI com amp. op. inversor (Z2 = R2 em série com C).
%
%   EQUAÇÕES:  Vs/Ve = -Z2/Z1 ,  Z1 = R1 ,  Z2 = R2 + 1/(sC)
%              G = -(R2/R1)*(s + 1/(R2*C))/s
%              k = R2/R1        zi = 1/(R2*C)
%   ORDEM:     R2 = 1/(zi*C)   (primeiro, pelo zero)
%              R1 = R2/k       (depois, pelo ganho)
%
%   EXEMPLO:  [R1, R2] = ampop_pi(100, 0.1, 10e-6)   % 10 kOhm ; 1 MOhm
R2 = 1/(zi*C);
R1 = R2/k;
fprintf('PI amp-op: R1 = %.4g Ohm   R2 = %.4g Ohm   C = %.4g F\n', R1, R2, C);
fprintf('(sai com sinal negativo: usar um inversor de ganho -1 em série)\n');
end
