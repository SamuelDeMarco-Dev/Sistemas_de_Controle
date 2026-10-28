function [tab, n_spd] = routh(p)
% ROUTH  Monta a tabela de Routh-Hurwitz.
%
%   [tab, n_spd] = routh(p)
%     p     : coeficientes do denominador de T(s), [a_n ... a_1 a_0]
%             (numérico OU simbólico, ex.: com syms K)
%     tab   : tabela de Routh (linha 1 = s^n, última linha = s^0)
%     n_spd : nº de trocas de sinal na 1ª coluna
%             = nº de polos no semiplano direito (só no caso numérico)
%
%   REGRA DE CADA ELEMENTO (linhas i-2 e i-1 já conhecidas):
%     b_j = ( a(i-1,1)*a(i-2,j+1) - a(i-2,1)*a(i-1,j+1) ) / a(i-1,1)
%
%   CASOS ESPECIAIS (só numérico):
%     - zero na 1ª coluna  -> troca por epsilon pequeno
%     - linha inteira zero -> usa a derivada do polinômio auxiliar
%
%   EXEMPLOS:
%     routh([1 13.6 34.65 23.05])            % k = 1 -> estável
%     syms K
%     tab = routh([1 13.6 34.65 22.05+K]);   % 1ª coluna em função de K
%     solve(tab(end-1,1) == 0, K)            % K crítico (linha s^1 = 0)

p    = p(:).';
n    = numel(p);              % nº de linhas (ordem + 1)
nc   = ceil(n/2);             % nº de colunas
simb = isa(p, 'sym');

if simb
    tab = sym(zeros(n, nc));
else
    tab = zeros(n, nc);
end

lin1 = p(1:2:end);
lin2 = p(2:2:end);
tab(1, 1:numel(lin1)) = lin1;
tab(2, 1:numel(lin2)) = lin2;

epsv = 1e-6;

for i = 3:n
    if ~simb
        % linha anterior toda nula -> polinômio auxiliar (linha i-2)
        if all(abs(tab(i-1,:)) < 1e-12)
            q = n - (i-2);                    % potência da linha i-2
            pot = q - 2*(0:nc-1);
            pot(pot < 0) = 0;
            tab(i-1,:) = tab(i-2,:) .* pot;   % derivada do aux.
            fprintf('Linha s^%d nula: usada a derivada do polinomio auxiliar.\n', q-1);
        end
        % zero só na 1ª coluna -> epsilon
        if abs(tab(i-1,1)) < 1e-12
            tab(i-1,1) = epsv;
            fprintf('Zero na 1a coluna (linha s^%d): trocado por epsilon.\n', n-(i-1));
        end
    end

    for j = 1:nc-1
        tab(i,j) = (tab(i-1,1)*tab(i-2,j+1) - tab(i-2,1)*tab(i-1,j+1)) / tab(i-1,1);
    end
    if simb
        tab(i,:) = simplify(tab(i,:));
    end
end

% ----- contagem de trocas de sinal -----
if simb
    n_spd = NaN;
else
    sg    = sign(tab(:,1));
    n_spd = sum(sg(1:end-1) .* sg(2:end) < 0);
end

% ----- exibição -----
fprintf('\nTabela de Routh:\n');
for i = 1:n
    if simb
        fprintf('  s^%d :  ', n-i);
        disp(vpa(tab(i,:), 6));
    else
        fprintf('  s^%-2d:', n-i);
        fprintf('%12.4f', tab(i,:));
        fprintf('\n');
    end
end
if ~simb
    fprintf('Trocas de sinal na 1a coluna: %d', n_spd);
    if n_spd == 0
        fprintf('  -> ESTAVEL (nenhum polo no SPD)\n\n');
    else
        fprintf('  -> INSTAVEL (%d polo(s) no SPD)\n\n', n_spd);
    end
end
end
