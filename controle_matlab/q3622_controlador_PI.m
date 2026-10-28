%% Questão 3.6.2.2 - Parte 2: controlador PI (lugar das raízes, regime, transitório)
% =========================================================================
% PROBLEMA
%   Mesma planta G(s) = 1/((s+1)(s+2.1)(s+10.5)), mas agora o ganho k é
%   trocado por um PI:  G_PI(s) = K1 + K2/s = k(s + zi)/s
%
% EQUAÇÕES USADAS
%   f) zi = 0.1 * |polo da planta mais próximo da origem| = 0.1*1 = 0.1
%   L(s) = k(s+0.1) / [s(s+1)(s+2.1)(s+10.5)]   -> o 1/s torna o sistema tipo 1
%   T(s) = k(s+0.1) / (s^4 + 13.6 s^3 + 34.65 s^2 + (22.05+k) s + 0.1k)
%   E(s) = R(s)[1 - T(s)] ,  R = 1/s
%   c(inf) = T(0) = 0.1k/0.1k = 1   ->   e(inf) = 0   (se estável)
%   Estável para 0 < k < ~431.6 -> k = 500 é INSTÁVEL
% =========================================================================

clear; clc; close all
s  = tf('s');                              % s como função de transferência
G  = 1/((s+1)*(s+2.1)*(s+10.5));           % planta
ks = [1 2.65 20 100 400 500];              % ganhos pedidos

%% f) Projeto do zero zi
% Pega todos os polos da planta.
p = pole(G);

% Descarta polos em s = 0 (aqui não há, mas deixa o código genérico).
% O critério dos 10% usa só os polos da PLANTA.
p_planta = p(abs(p) > 1e-9);

% min(abs(...)) = módulo do polo mais próximo da origem (|-1| = 1).
% zi = 10% desse valor. A ideia: colocar o zero do PI bem perto do polo
% do integrador (s = 0) para que os dois quase se cancelem e o
% transitório quase não mude em relação ao controlador P.
zi = 0.1*min(abs(p_planta));

fprintf('f) Polo da planta mais proximo da origem: %.4f\n', p_planta(abs(p_planta)==min(abs(p_planta))));
fprintf('   zi = 0.1 x %.4f = %.4f  ->  G_PI(s) = k(s + %.4g)/s\n\n', min(abs(p_planta)), zi, zi);

% Montamos o PI com k = 1. O ganho k fica de fora porque:
%  - no rlocus, é exatamente o k que o gráfico varia de 0 a infinito;
%  - nos laços, basta multiplicar k*L1 para cada valor.
Gpi1 = (s + zi)/s;                         % (s + 0.1)/s
L1   = Gpi1*G;                             % malha aberta controlador*planta

%% g) Lugar das raízes com o PI
% Agora o lugar tem 4 polos de malha aberta (0, -1, -2.1, -10.5)
% e 1 zero (-0.1).
figure; rlocus(L1); grid on; title('g) Lugar das raizes com PI: (s+0.1)/[s(s+1)(s+2.1)(s+10.5)]')
hold on
cores = lines(numel(ks));
for i = 1:numel(ks)
    % Marca no gráfico onde ficam os polos de malha fechada para cada k.
    pp = pole(feedback(ks(i)*L1, 1));
    plot(real(pp), imag(pp), 'o', 'Color', cores(i,:), 'MarkerFaceColor', cores(i,:), ...
         'DisplayName', sprintf('k = %g', ks(i)));
end
legend show

% K crítico com o PI (margem de ganho). Fica um pouco menor que o do P,
% porque o polo do integrador "empurra" o lugar para a direita.
[Gm, ~, Wcg] = margin(L1);
fprintf('K critico com PI = %.2f (w = %.3f rad/s)  [com P era 449.19]\n', Gm, Wcg);

% Segundo gráfico com zoom na origem. axis([xmin xmax ymin ymax]) limita
% a área mostrada. Dá para ver o polo em 0 indo em direção ao zero em -0.1:
% esse ramo curto é o "polo lento" que aparece na malha fechada.
figure; rlocus(L1); grid on; axis([-0.3 0.1 -0.2 0.2]); title('Zoom: polo em 0 e zero em -0.1')

%% h) Polos de malha fechada
fprintf('\nh) Polos de T(s):\n');
for k = ks
    T  = feedback(k*L1, 1);                % T = k*L1/(1 + k*L1), H = 1
    pp = pole(T);
    fprintf('k = %-6g: %s', k, num2str(pp.', '%.4f  '));
    if isstable(T), fprintf('  (estavel)\n'); else, fprintf('  *** INSTAVEL ***\n'); end
end
% Note que sempre aparece um polo real pequeno (entre -0.004 e -0.1):
% é o polo que saiu de s = 0 e está indo para o zero em -0.1.

%% i) e j) c(inf) e e(inf) - numérico
% Mesmo raciocínio da parte 1: c(inf) = T(0) = dcgain(T); e(inf) = 1 - c(inf).
% Com o integrador, T(0) = 0.1k/0.1k = 1 para qualquer k.
fprintf('\ni) e j) Regime permanente (degrau unitario):\n');
fprintf('%8s %10s %10s %10s\n', 'k', 'c(inf)', 'e(inf)', 'estavel');
for k = ks
    T    = feedback(k*L1, 1);
    cinf = dcgain(T);
    fprintf('%8g %10.4f %10.4f %10d\n', k, cinf, 1 - cinf, isstable(T));
end
fprintf('k = 500: T(0) = 1, mas NAO vale (sistema instavel).\n');

% Função auxiliar do kit: mostra tipo do sistema e as constantes.
% Esperado: tipo 1, Kp = inf -> e_degrau = 0.
erro_regime(100*L1);

%% j) Pelo enunciado: E(s) = R(s)[1 - T(s)], e(inf) = lim s->0 s*E(s)
% Versão simbólica, igual ao que se faz à mão.
% sv no lugar de s para não sobrescrever o s = tf('s').
syms sv K
Gs  = 1/((sv+1)*(sv+2.1)*(sv+10.5));       % planta simbólica
Ls  = K*(sv + 0.1)/sv*Gs;                  % malha aberta com PI
Ts  = simplify(Ls/(1 + Ls));               % T(s) = L/(1 + L)
R   = 1/sv;                                % degrau
E   = R*(1 - Ts);                          % E(s) = R(s)[1 - T(s)]

% Teorema do Valor Final. Sem ";" no fim, o MATLAB mostra o resultado.
c_inf = simplify(limit(sv*Ts*R, sv, 0))    % deve dar 1
e_inf = simplify(limit(sv*E,    sv, 0))    % deve dar 0

% numden separa numerador e denominador de T(s); expand multiplica tudo;
% vpa(...,6) mostra em decimal. Serve para conferir o T(s) do gabarito.
[nT, dT] = numden(Ts);
fprintf('T(s) = %s / %s\n', char(vpa(expand(nT),6)), char(vpa(expand(dT),6)));

%% Resposta transitória (stepinfo) e comparação com o P
% stepinfo(T) simula o degrau e mede:
%   Overshoot    -> %OS (sobressinal percentual)
%   PeakTime     -> tp (instante do pico)
%   SettlingTime -> ts (critério de 2% por padrão)
% Fazemos para o PI e para o P com o mesmo k, lado a lado.
fprintf('\nResposta transitoria (ts com criterio de 2%%):\n');
fprintf('%8s %10s %10s %10s %12s\n', 'k', '%OS', 'tp (s)', 'ts (s)', 'ts com P (s)');
for k = ks(1:end-1)                        % sem o 500 (instável)
    ipi = stepinfo(feedback(k*L1, 1));     % PI
    ip  = stepinfo(feedback(k*G,  1));     % P
    fprintf('%8g %10.2f %10.3f %10.2f %12.2f\n', k, ipi.Overshoot, ipi.PeakTime, ...
            ipi.SettlingTime, ip.SettlingTime);
end
% Se %OS = 0, a resposta não tem pico, e o tp mostrado não tem significado
% (é só o instante do valor máximo da simulação).

% Gráfico: PI com três ganhos e o P com k = 100 tracejado, para comparar.
figure; hold on; grid on
for k = [20 100 400]
    [y, t] = step(feedback(k*L1, 1), 60);
    plot(t, y, 'DisplayName', sprintf('PI k = %g', k));
end
[y, t] = step(feedback(100*G, 1), 60);
plot(t, y, '--', 'DisplayName', 'P k = 100');
legend show; title('Resposta ao degrau com PI'); xlabel('t (s)'); ylabel('c(t)')
% Repare: as curvas do PI chegam a 1 (erro zero), mas a última parte da
% subida é bem lenta (o polo lento perto de -0.1).
