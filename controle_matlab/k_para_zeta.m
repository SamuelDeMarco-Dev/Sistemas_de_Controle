function [K, polo] = k_para_zeta(G, zeta, rmax)
% K_PARA_ZETA  Ganho K onde o lugar das raízes cruza a reta de zeta.
%
%   [K, polo] = k_para_zeta(G, zeta)
%   [K, polo] = k_para_zeta(G, zeta, rmax)   (rmax = raio máx. da busca, padrão 50)
%     G    : malha aberta SEM o ganho
%     K    : ganho(s) encontrados (o 1º é o do par dominante)
%     polo : polo(s) de malha fechada correspondente(s)
%
%   EQUAÇÕES:
%     Reta de zeta:  s = r*(-zeta + j*sqrt(1-zeta^2)),  theta = acos(zeta)
%     Condição de ângulo: angle(G(s)) = 180°  -> G(s) real negativo
%     Condição de módulo: K = 1/|G(s)|
%     (zeta a partir de %OS:  zeta = -ln(OS/100)/sqrt(pi^2 + ln^2(OS/100)))
%
%   EXEMPLO:
%     s = tf('s'); G = 1/((s+1)*(s+2.1)*(s+10.5));
%     [K, p] = k_para_zeta(G, 0.5)    % K ~ 49.69 ; p ~ -1.274 + j2.206

if nargin < 3, rmax = 50; end

[num, den] = tfdata(G, 'v');
d   = -zeta + 1j*sqrt(1 - zeta^2);
Gs  = @(x) polyval(num, x*d) ./ polyval(den, x*d);

r   = linspace(1e-4, rmax, 2e5);
f   = imag(Gs(r));
idx = find(f(1:end-1) .* f(2:end) <= 0);

K = []; polo = [];
for i = idx
    ri = fzero(@(x) imag(Gs(x)), [r(i) r(i+1)]);
    g  = Gs(ri);
    if real(g) < 0
        K(end+1)    = -1/real(g);   %#ok<AGROW>
        polo(end+1) = ri*d;         %#ok<AGROW>
    end
end

if isempty(K)
    fprintf('Nenhum cruzamento com zeta = %.3f ate |s| = %g.\n', zeta, rmax);
else
    fprintf('\nCruzamentos com a reta zeta = %.4f:\n', zeta);
    for i = 1:numel(K)
        fprintf('  K = %.4f   polo = %.4f +/- j%.4f\n', K(i), real(polo(i)), imag(polo(i)));
    end
    fprintf('\n');
end
end
