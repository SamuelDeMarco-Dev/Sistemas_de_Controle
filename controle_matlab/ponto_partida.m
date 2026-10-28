function [sb, Kb] = ponto_partida(G)
% PONTO_PARTIDA  Pontos de saída/chegada no eixo real do lugar das raízes.
%
%   [sb, Kb] = ponto_partida(G)
%     G  : malha aberta SEM o ganho K (K*G)
%     sb : pontos de partida/chegada (reais)
%     Kb : ganho K em cada ponto
%
%   EQUAÇÕES:
%     K = -D(s)/N(s)   e   dK/ds = 0   =>   N'(s)D(s) - N(s)D'(s) = 0
%
%   EXEMPLO:
%     s = tf('s'); G = 1/((s+1)*(s+2.1)*(s+10.5));
%     [sb, Kb] = ponto_partida(G)    % sb ~ -1.533 ; Kb ~ 2.71

[N, D] = tfdata(G, 'v');
N = N(find(N, 1):end);
D = D(find(D, 1):end);

a = conv(polyder(N), D);
b = conv(N, polyder(D));
L = max(numel(a), numel(b));
q = [zeros(1, L-numel(a)) a] - [zeros(1, L-numel(b)) b];

cand = roots(q);
cand = real(cand(abs(imag(cand)) < 1e-6));
Kc   = -polyval(D, cand) ./ polyval(N, cand);

ok = Kc > 0;              % só pontos que pertencem ao lugar com K > 0
sb = cand(ok);
Kb = Kc(ok);

fprintf('\nPontos de partida/chegada:\n');
for i = 1:numel(sb)
    fprintf('  s = %.4f   ->   K = %.4f\n', sb(i), Kb(i));
end
fprintf('\n');
end
