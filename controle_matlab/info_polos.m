function r = info_polos(T)
% INFO_POLOS  zeta, wn, %OS, Tp e Ts pelo par de polos DOMINANTE de T(s).
%
%   r = info_polos(T)      T = malha fechada (tf/zpk)
%
%   EQUAÇÕES (2ª ordem, Nise cap. 4), polo s = -sigma +/- j*wd:
%     wn    = |s|                    zeta = sigma/wn = cos(theta)
%     %OS   = 100*exp(-zeta*pi/sqrt(1-zeta^2))
%     Tp    = pi/wd                  Ts (2%) = 4/sigma
%
%   É uma APROXIMAÇÃO: só bate com stepinfo se os outros polos estiverem
%   bem mais à esquerda (>5x) e não houver zeros/polos lentos por perto.
%
%   EXEMPLO:
%     s = tf('s'); G = 1/((s+1)*(s+2.1)*(s+10.5));
%     info_polos(feedback(100*G, 1))

p    = pole(T);
cplx = p(abs(imag(p)) > 1e-9);

if isempty(cplx)
    [~, i] = min(abs(real(p)));
    pd = real(p(i));
    r.polo = pd; r.sigma = -pd; r.wd = 0; r.wn = abs(pd); r.zeta = 1;
    r.OS = 0; r.Tp = Inf; r.Ts = 4/abs(pd);
    fprintf('\nSo polos reais: dominante = %.4f (sem overshoot)\n', pd);
    fprintf('Ts (2%%) ~ 4/|p| = %.4f s\n\n', r.Ts);
else
    [~, i] = min(abs(real(cplx)));
    pd     = real(cplx(i)) + 1j*abs(imag(cplx(i)));
    sigma  = -real(pd);
    wd     = imag(pd);
    wn     = abs(pd);
    zeta   = sigma/wn;

    r.polo = pd; r.sigma = sigma; r.wd = wd; r.wn = wn; r.zeta = zeta;
    r.OS   = 100*exp(-zeta*pi/sqrt(1-zeta^2));
    r.Tp   = pi/wd;
    r.Ts   = 4/sigma;

    fprintf('\nPolo dominante : %.4f +/- j%.4f\n', -sigma, wd);
    fprintf('wn   = %.4f rad/s     zeta = %.4f\n', wn, zeta);
    fprintf('%%OS  = %.2f %%\n', r.OS);
    fprintf('Tp   = pi/wd   = %.4f s\n', r.Tp);
    fprintf('Ts   = 4/sigma = %.4f s  (criterio 2%%)\n', r.Ts);

    lentos = p(abs(imag(p)) < 1e-9 & abs(real(p)) < sigma);
    if ~isempty(lentos)
        fprintf('*** Aviso: polo real mais lento que o par (%.4f).\n', lentos(1));
        fprintf('    Ts real sera MAIOR que 4/sigma -> confira com stepinfo.\n');
    end
    fprintf('\n');
end
if nargout == 0, clear r; end
end
