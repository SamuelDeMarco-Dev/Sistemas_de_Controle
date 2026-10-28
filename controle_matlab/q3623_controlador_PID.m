%% Questão 3.6.2.3 - Parte 3: controlador PID (lugar das raízes, regime, transitório)
% =========================================================================
% PROBLEMA
%   Mesma planta G(s) = 1/((s+1)(s+2.1)(s+10.5)), agora com um PID:
%   G_PID(s) = K1 + K2/s + K3 s = k(s + zi)(s + zd)/s
%
% EQUAÇÕES USADAS
%   l) zi = 0.1*|polo da planta mais próximo da origem| = 0.1 ;  zd = 20
%   K1 = k(zi+zd)    K2 = k*zi*zd    K3 = k
%   L(s) = k(s+0.1)(s+20) / [s(s+1)(s+2.1)(s+10.5)]        -> tipo 1
%   T(s) = k(s^2 + 20.1 s + 2) /
%          (s^4 + 13.6 s^3 + (34.65+k) s^2 + (22.05+20.1k) s + 2k)
%   c(inf) = T(0) = 2k/2k = 1  ->  e(inf) = 0  (se estável)
%   Estável para 0 < k < ~66.3  -> k = 100, 400, 500 são INSTÁVEIS
%   tp: só existe se houver overshoot (resposta subamortecida)
% =========================================================================

clear; clc; close all
s  = tf('s');                              % s como função de transferência
G  = 1/((s+1)*(s+2.1)*(s+10.5));           % planta

% Ganhos pedidos + 21.8, que é o ganho escolhido no gabarito.
ks = [1 2.65 20 21.8 100 400 500];

%% l) Zeros do PID
% zi: mesmo critério do PI (10% do polo da planta mais perto da origem).
% Esse zero, junto com o polo em s = 0, forma a parte "PI" do PID:
% zera o erro em regime quase sem mexer no transitório.
p  = pole(G);
zi = 0.1*min(abs(p(abs(p) > 1e-9)));       % 0.1

% zd: zero da parte "PD". Fica mais à esquerda e "puxa" o lugar das
% raízes, deixando a resposta mais rápida. Valor dado no gabarito.
zd = 20;
fprintf('l) zi = %.4g   zd = %.4g\n', zi, zd);

% Função auxiliar do kit: converte k, zi, zd -> K1, K2, K3.
% Para k = 21.8: K1 = 21.8*(0.1+20) = 438.18 ; K2 = 21.8*0.1*20 = 43.6 ; K3 = 21.8
pid_ganhos(21.8, zi, zd);

% PID com k = 1, já multiplicado pela planta (malha aberta).
% O k fica de fora para ser o ganho variado no rlocus e nos laços.
Lpid1 = (s+zi)*(s+zd)/s * G;

%% m) Lugar das raízes com o PID
% Malha aberta: 4 polos (0, -1, -2.1, -10.5) e 2 zeros (-0.1, -20).
figure; rlocus(Lpid1); grid on; title('m) Lugar das raizes com PID')
hold on

% Marca com um quadrado vermelho onde ficam os polos para k = 21.8
% (o "local das raízes para o ganho 21.8" do gabarito).
pp = pole(feedback(21.8*Lpid1, 1));
plot(real(pp), imag(pp), 'rs', 'MarkerFaceColor', 'r', 'DisplayName', 'k = 21.8');
legend show

% Margem de ganho = K crítico do PID (~66.3). Bem menor que no P e no PI:
% o PID deixa o sistema rápido, mas estável só numa faixa estreita de k.
[Gm, ~, Wcg] = margin(Lpid1);
fprintf('K critico com PID = %.2f (w = %.3f rad/s)\n\n', Gm, Wcg);

%% n) Polos e T(s)
% Sem ";" o MATLAB mostra T(s) na forma polinomial. Deve bater com o gabarito:
% (21.8 s^2 + 438.2 s + 43.6) / (s^4 + 13.6 s^3 + 56.45 s^2 + 460.2 s + 43.6)
Tpid = feedback(21.8*Lpid1, 1)

fprintf('n) Polos de T(s):\n');
for k = ks
    T  = feedback(k*Lpid1, 1);             % fecha a malha para esse k
    pp = pole(T);                          % polos de malha fechada
    fprintf('k = %-6g: %s', k, num2str(pp.', '%.4f  '));
    if isstable(T), fprintf('  (estavel)\n'); else, fprintf('  *** INSTAVEL ***\n'); end
end
% A partir de k = 100 aparece um par complexo com parte real POSITIVA
% -> polos no semiplano direito -> resposta diverge.

%% o) tp e ts para cada k (PID x PI com o mesmo k)
% Malha aberta do PI (k = 1), para comparar com o mesmo ganho.
Lpi1 = (s+zi)/s * G;

fprintf('\no) Transitorio (ts com 2%%):\n');
% Cabeçalho da tabela. %7s, %8s = largura das colunas (só para alinhar).
fprintf('%7s | %8s %8s %8s %7s | %8s %8s %8s %7s\n', 'k', 'PID tp', 'PID ts', '%OS', 'c(inf)', ...
        'PI tp', 'PI ts', '%OS', 'c(inf)');
for k = ks
    Tq = feedback(k*Lpid1, 1);             % T(s) com PID
    Tp = feedback(k*Lpi1,  1);             % T(s) com PI
    % "linha" é uma função local (definida no fim do arquivo) que mede
    % tp, ts, %OS e c(inf) e devolve tudo formatado como texto.
    fprintf('%7g | %s | %s\n', k, linha(Tq), linha(Tp));
end

%% o) Comparação nos ganhos do gabarito: P (100), PI (100), PID (21.8)
fprintf('\nComparacao final:\n');

% Cell arrays { } guardam itens de tipos/tamanhos diferentes:
% nomes = textos ; Ts = as três funções de transferência de malha fechada.
nomes = {'P   k=100', 'PI  k=100 zi=0.1', 'PID k=21.8 zi=0.1 zd=20'};
Ts    = {feedback(100*G, 1), feedback(100*Lpi1, 1), feedback(21.8*Lpid1, 1)};

fprintf('%-26s %8s %8s %8s %8s %8s\n', '', 'tp (s)', 'ts (s)', '%OS', 'c(inf)', 'e(inf)');
figure; hold on; grid on
for i = 1:3
    info = stepinfo(Ts{i});                % mede tp, ts, %OS na resposta ao degrau
    c    = dcgain(Ts{i});                  % c(inf) = T(0)
    fprintf('%-26s %8.3f %8.2f %8.2f %8.4f %8.4f\n', nomes{i}, info.PeakTime, ...
            info.SettlingTime, info.Overshoot, c, 1 - c);
    [y, t] = step(Ts{i}, 30);              % simula 30 s de degrau
    plot(t, y, 'DisplayName', nomes{i});
end

% Linha horizontal pontilhada em c = 1 (a referência), sem entrar na legenda.
yline(1, ':', 'HandleVisibility', 'off');
legend show; title('Degrau unitario: P x PI x PID'); xlabel('t (s)'); ylabel('c(t)')
% No gráfico: o P estaciona em ~0.82 (tem erro); o PI chega a 1 devagar;
% o PID chega a 1 mais rápido, mas com overshoot alto (~57%).

%% Função local: formata tp, ts, %OS, c(inf) de um T(s)
% Funções locais precisam ficar no FIM do script (MATLAB R2016b ou mais novo).
function str = linha(T)
% Se o sistema é instável, não faz sentido medir nada: devolve traços.
if ~isstable(T)
    str = sprintf('%8s %8s %8s %7s', 'instav.', '-', '-', '-');
    return
end

info = stepinfo(T);

% Só existe tempo de pico se a resposta passa do valor final (overshoot).
% Se não passa, o stepinfo devolve o instante do máximo da simulação,
% que não tem significado físico -> mostramos "sem OS".
if info.Overshoot > 0.01
    tp = sprintf('%8.3f', info.PeakTime);
else
    tp = sprintf('%8s', 'sem OS');
end

% Junta tudo em um texto: tp, ts, %OS e c(inf).
str = sprintf('%s %8.2f %8.2f %7.3f', tp, info.SettlingTime, info.Overshoot, dcgain(T));
end
