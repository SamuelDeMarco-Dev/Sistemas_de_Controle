%% Questão 3.6.2.1 - Parte 1: lugar das raízes, erro em regime, tipo, controlador P
% =========================================================================
% PROBLEMA
%   G(s) = 1/((s+1)(s+2.1)(s+10.5)), realimentação unitária (H = 1),
%   controlador P (um ganho k em série com a planta), entrada degrau unitário.
%
% EQUAÇÕES USADAS
%   T(s) = kG/(1+kG) = k / (s^3 + 13.6 s^2 + 34.65 s + 22.05 + k)
%          (o k só soma no termo independente do denominador)
%   E(s) = R(s)[1 - T(s)] ,  R(s) = 1/s   (degrau unitário)
%   e(inf) = lim s->0 s*E(s) = 1 - T(0) = 22.05/(22.05 + k)
%   c(inf) = T(0) = k/(22.05 + k)
%   Estável para 0 < k < 449.19 (Routh) -> k = 500 é INSTÁVEL
% =========================================================================

% Limpa variáveis antigas, a tela do Command Window e fecha gráficos abertos.
% Evita que um valor de uma execução anterior "contamine" esta.
clear; clc; close all

% Cria a variável s como FUNÇÃO DE TRANSFERÊNCIA (não simbólica).
% Com isso, qualquer expressão com s vira um objeto tf, e funções como
% feedback, pole, step e dcgain funcionam.
s = tf('s');

% Planta escrita direto na forma fatorada. O MATLAB expande sozinho.
G = 1/((s+1)*(s+2.1)*(s+10.5));

% Vetor com todos os ganhos pedidos no enunciado. Os laços "for" abaixo
% percorrem esse vetor, um valor de k por vez.
ks = [1 2.65 20 100 400 500];

%% a) Polos de malha aberta
% pole(G) devolve as raízes do denominador de G(s): -1, -2.1 e -10.5.
fprintf('a) Polos de G(s):\n'); disp(pole(G))

% O tipo do sistema é o número de polos em s = 0 (integradores).
% abs(pole(G)) < 1e-9 testa quais polos são "zero" (tolerância numérica);
% sum conta quantos são. Aqui o resultado é 0 -> sistema tipo 0.
fprintf('   Tipo do sistema: %d (nenhum polo em s = 0)\n\n', sum(abs(pole(G)) < 1e-9));

%% b) Lugar das raízes
% rlocus(G) desenha onde ficam os polos de malha fechada de k*G/(1+k*G)
% quando k vai de 0 a infinito. Os "x" são os polos de malha aberta
% (onde o lugar começa, k = 0).
figure; rlocus(G); grid on; title('b) Lugar das raizes de G(s)')

% "hold on" mantém o gráfico para desenharmos por cima dele.
hold on

% lines(n) gera n cores diferentes, uma para cada k.
cores = lines(numel(ks));

% Para cada k: calcula os polos de malha fechada e marca no lugar das
% raízes com um círculo preenchido. Assim dá para ver "onde" cada ganho
% coloca os polos sobre as curvas.
for i = 1:numel(ks)
    p = pole(feedback(ks(i)*G, 1));        % polos de T(s) para esse k
    plot(real(p), imag(p), 'o', 'Color', cores(i,:), 'MarkerFaceColor', cores(i,:), ...
         'DisplayName', sprintf('k = %g', ks(i)));
end
legend show                                % mostra a legenda com os k

% margin(G) calcula a margem de ganho Gm: quanto o ganho pode ser
% multiplicado antes de o sistema ficar instável. Como G tem ganho 1,
% Gm é o próprio K crítico (~449.19). Wcg é a frequência em que o lugar
% cruza o eixo imaginário (~5.886 rad/s).
[Gm, ~, Wcg] = margin(G);
fprintf('K critico = %.2f (cruza o eixo jw em w = %.3f rad/s)\n', Gm, Wcg);

% Função auxiliar do kit: acha o ponto do eixo real onde os dois polos
% se encontram e "saem" do eixo (s ~ -1.533, com k ~ 2.71).
% Abaixo desse k os polos são reais (sem oscilação); acima, complexos.
ponto_partida(G);

%% c) Polos de malha fechada para cada k
fprintf('c) Polos de T(s):\n');
for k = ks                                 % k assume cada valor do vetor ks
    % feedback(k*G, 1) fecha a malha com H = 1: T = kG/(1+kG)
    T = feedback(k*G, 1);
    p = pole(T);                           % polos de T(s)

    % num2str(p.', '%.4f  ') transforma o vetor de polos em texto
    % (o .' transpõe sem conjugar, para imprimir em uma linha só).
    fprintf('k = %-6g: %s', k, num2str(p.', '%.4f  '));

    % isstable devolve 1 se todos os polos têm parte real negativa.
    if isstable(T), fprintf('   (estavel)\n'); else, fprintf('   *** INSTAVEL ***\n'); end
end

%% d) e e) c(inf) e e(inf) - numérico
% dcgain(T) é T(s) avaliado em s = 0, ou seja, T(0).
% Pelo Teorema do Valor Final com degrau: c(inf) = lim s*T(s)*(1/s) = T(0).
% Com H = 1, o erro é referência menos saída: e(inf) = 1 - c(inf).
fprintf('\nd) e e) Regime permanente (degrau unitario):\n');
fprintf('%8s %10s %10s %10s\n', 'k', 'c(inf)', 'e(inf)', 'estavel');
for k = ks
    T    = feedback(k*G, 1);
    cinf = dcgain(T);
    fprintf('%8g %10.4f %10.4f %10d\n', k, cinf, 1 - cinf, isstable(T));
end
% O Teorema do Valor Final só vale se o sistema for estável.
% Para k = 500 a conta devolve um número, mas a saída real diverge.
fprintf('k = 500: a formula da um numero, mas NAO vale (sistema instavel).\n');

%% e) Pelo enunciado: E(s) = R(s)[1 - T(s)], e(inf) = lim s->0 s*E(s)
% Aqui refazemos o item e) exatamente como o enunciado pede, com cálculo
% SIMBÓLICO (precisa do Symbolic Math Toolbox).
% Usamos "sv" no lugar de "s" para NÃO apagar o s = tf('s') criado acima.
% K fica como símbolo para obter a fórmula geral em função do ganho.
syms sv K

Gs = 1/((sv+1)*(sv+2.1)*(sv+10.5));        % G(s) simbólica
Ts = K*Gs/(1 + K*Gs);                      % T(s) = KG/(1+KG)
R  = 1/sv;                                 % degrau unitário em Laplace
E  = R*(1 - Ts);                           % E(s) = R(s)[1 - T(s)]

% limit(expr, sv, 0) calcula o limite com s -> 0 (Teorema do Valor Final).
% simplify deixa a fração mais limpa.
c_inf = simplify(limit(sv*Ts*R, sv, 0));   % K/(K + 441/20) = K/(K + 22.05)
e_inf = simplify(limit(sv*E,    sv, 0));   % 22.05/(22.05 + K)

% vpa(...,5) converte as frações exatas (441/20) em decimal com 5 dígitos.
fprintf('\nFormulas: c(inf) = %s ;  e(inf) = %s\n', char(vpa(c_inf,5)), char(vpa(e_inf,5)));

% subs(c_inf, K, ks) substitui K por cada valor do vetor ks;
% double converte de simbólico para número; table monta uma tabela.
disp(table(ks.', double(subs(c_inf, K, ks)).', double(subs(e_inf, K, ks)).', ...
     'VariableNames', {'k', 'c_inf', 'e_inf'}))

%% Extra: respostas ao degrau (k = 500 fica de fora porque diverge)
figure; hold on; grid on
for k = ks(1:end-1)                        % ks(1:end-1) = todos menos o último (500)
    % step(T, 15) simula a resposta ao degrau até t = 15 s e devolve
    % a saída y e o vetor de tempo t (sem desenhar, porque pedimos saídas).
    [y, t] = step(feedback(k*G, 1), 15);
    plot(t, y, 'DisplayName', sprintf('k = %g', k));
end
legend show; title('Resposta ao degrau para cada k'); xlabel('t (s)'); ylabel('c(t)')
% Repare: quanto maior o k, mais perto de 1 a saída chega (erro menor),
% mas mais ela oscila. Nunca chega exatamente a 1 (sistema tipo 0).
