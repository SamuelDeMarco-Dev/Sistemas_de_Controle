function [k, zi, zd] = pid_para_zeros(K1, K2, K3)
% PID_PARA_ZEROS  Caminho inverso: K1, K2, K3 -> k, zi, zd.
%
%   EQUAÇÕES:  k = K3 ;  zi e zd = -raízes de  K3 s^2 + K1 s + K2 = 0
%              (zi = o menor, perto da origem; zd = o maior)
%   Se K3 = 0 (PI):  k = K1 ; zi = K2/K1 ; zd = []
%
%   EXEMPLO:  [k, zi, zd] = pid_para_zeros(301.5, 30, 15)   % 15 ; 0.1 ; 20
if K3 == 0
    k = K1; zi = K2/K1; zd = [];
    fprintf('PI: k = %.4g   zi = %.4g\n', k, zi);
    return
end
k  = K3;
z  = sort(-roots([K3 K1 K2]));
zi = z(1);
zd = z(2);
fprintf('PID: k = %.4g   zi = %.4g   zd = %.4g\n', k, zi, zd);
if ~isreal(z)
    fprintf('*** Zeros complexos (K1^2 < 4*K2*K3).\n');
end
end
