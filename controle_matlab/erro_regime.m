function r = erro_regime(L)
% ERRO_REGIME  Tipo do sistema, constantes de erro e e(inf).
%
%   r = erro_regime(L)
%     L : função de MALHA ABERTA com realimentação unitária, L = C(s)*G(s)
%         (objeto tf ou zpk)
%
%   EQUAÇÕES (Nise cap. 7):
%     Tipo = nº de polos em s = 0 de L(s)
%     Kp = lim s->0  L(s)        e_degrau   = 1/(1+Kp)
%     Kv = lim s->0  s*L(s)      e_rampa    = 1/Kv
%     Ka = lim s->0  s^2*L(s)    e_parabola = 1/Ka
%
%   ATENÇÃO: só vale se a MALHA FECHADA for estável (o script avisa).
%
%   EXEMPLO:
%     s = tf('s'); G = 1/((s+1)*(s+2.1)*(s+10.5));
%     erro_regime(2.65*G)            % P  -> tipo 0
%     erro_regime(100*(s+0.1)/s*G)   % PI -> tipo 1

[z, p, k] = zpkdata(L, 'v');

tipo = sum(abs(p) < 1e-9);
pnz  = p(abs(p) >= 1e-9);
znz  = z(abs(z) >= 1e-9);

% lim s->0 de s^tipo * L(s)  (constante "finita" do sistema)
K0 = real(k * prod(-znz) / prod(-pnz));

switch tipo
    case 0, Kp = K0;  Kv = 0;   Ka = 0;
    case 1, Kp = Inf; Kv = K0;  Ka = 0;
    case 2, Kp = Inf; Kv = Inf; Ka = K0;
    otherwise, Kp = Inf; Kv = Inf; Ka = Inf;
end

r.tipo       = tipo;
r.Kp         = Kp;
r.Kv         = Kv;
r.Ka         = Ka;
r.e_degrau   = 1/(1+Kp);
r.e_rampa    = 1/Kv;
r.e_parabola = 1/Ka;
r.c_inf      = 1 - r.e_degrau;          % só para degrau unitário
r.estavel    = isstable(feedback(L, 1));

fprintf('\n--- Erro em regime permanente ---\n');
fprintf('Tipo do sistema : %d\n', tipo);
fprintf('Kp = %-10.4g   e_degrau   = %.4g\n', Kp, r.e_degrau);
fprintf('Kv = %-10.4g   e_rampa    = %.4g\n', Kv, r.e_rampa);
fprintf('Ka = %-10.4g   e_parabola = %.4g\n', Ka, r.e_parabola);
fprintf('c(inf) degrau   = %.4g\n', r.c_inf);
if ~r.estavel
    fprintf('*** ATENCAO: malha fechada INSTAVEL -> esses erros NAO valem! ***\n');
end
fprintf('\n');
if nargout == 0, clear r; end
end
