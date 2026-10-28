function [K1, K2] = pi_ganhos(k, zi)
% PI_GANHOS  Converte PI da forma k(s+zi)/s para K1 + K2/s.
%
%   EQUAÇÕES:   G_PI = K1 + K2/s = K1*(s + K2/K1)/s
%               K1 = k        K2 = k*zi        zi = K2/K1
%   Projeto típico: zi = 0.1*|polo da planta mais próximo da origem|
%
%   EXEMPLO:  [K1, K2] = pi_ganhos(100, 0.1)   % K1 = 100 ; K2 = 10
K1 = k;
K2 = k*zi;
fprintf('PI: K1 = %.4g   K2 = %.4g   (zero em s = %.4g)\n', K1, K2, -zi);
end
