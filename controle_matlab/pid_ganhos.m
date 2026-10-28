function [K1, K2, K3] = pid_ganhos(k, zi, zd)
% PID_GANHOS  Converte PID da forma k(s+zi)(s+zd)/s para K1 + K2/s + K3*s.
%
%   EQUAÇÕES:   G_PID = (K3 s^2 + K1 s + K2)/s = k(s+zi)(s+zd)/s
%               K1 = k(zi+zd)     K2 = k*zi*zd     K3 = k
%
%   EXEMPLO:  [K1,K2,K3] = pid_ganhos(15, 0.1, 20)   % 301.5 ; 30 ; 15
K1 = k*(zi + zd);
K2 = k*zi*zd;
K3 = k;
fprintf('PID: K1 = %.4g   K2 = %.4g   K3 = %.4g\n', K1, K2, K3);
fprintf('     zeros em s = %.4g e s = %.4g ; polo em s = 0\n', -zi, -zd);
end
