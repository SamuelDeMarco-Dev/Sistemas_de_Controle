# Sistemas de Controle — kit MATLAB

Coloque todos os arquivos na **mesma pasta** e abra essa pasta como *Current Folder* no MATLAB. As funções auxiliares só são encontradas se estiverem na pasta atual ou no path (`addpath('caminho/da/pasta')`).

## Arquivos

| Arquivo | O que faz |
|---|---|
| `prova_rapida.m` | Tudo de uma vez: T(s), polos, zeros, Routh, erro, transitório, gráficos |
| `a01_sistema_basico.m` | Definir G(s), polos, zeros, expandir polinômio |
| `a02_malha_fechada.m` | T(s) numérico e simbólico (em função de K) |
| `a03_estabilidade_routh.m` | Routh numérico, faixa de K, K crítico, ω de oscilação |
| `a04_erro_regime.m` | Tipo, Kp/Kv/Ka, c(∞), e(∞), TVF simbólico |
| `a05_transitorio.m` | ζ, ωn, %OS, Tp, Ts, polos desejados |
| `a06_lugar_raizes.m` | Ponto de partida, K para ζ/%OS, K crítico, assíntotas |
| `a07_PI.m` | Projeto do PI (zᵢ = 10% do polo), K1/K2, P × PI |
| `a08_PID.m` | K1/K2/K3, inverso, estabilidade com k = 100 |
| `a09_ampop.m` | P, PI e PID com amplificador operacional |
| `a10_derivada_discreta.m` | Derivada/integral discreta, equivalentes em z |
| `a11_tabela_comparacao.m` | Tabela P × PI × PID (questão 10) |

| Função | Uso |
|---|---|
| `routh(p)` | Tabela de Routh (numérica ou com `syms K`) |
| `erro_regime(L)` | Tipo, constantes e erros de uma malha aberta L = C·G |
| `info_polos(T)` | ζ, ωn, %OS, Tp, Ts pelo polo dominante |
| `ponto_partida(G)` | Pontos de saída/chegada do lugar das raízes |
| `k_para_zeta(G, zeta)` | K que coloca os polos dominantes num dado ζ |
| `pi_ganhos(k, zi)` | k, zᵢ → K1, K2 |
| `pid_ganhos(k, zi, zd)` | k, zᵢ, z_d → K1, K2, K3 |
| `pid_para_zeros(K1, K2, K3)` | K1, K2, K3 → k, zᵢ, z_d |
| `ampop_pi(k, zi, C)` | R1, R2 do PI com amp. op. |
| `ampop_pid(K1, K2, K3, C2)` | R1, C1, R2 do PID com amp. op. |

## Escopo de equações

### 1. Malha fechada

| Equação | MATLAB |
|---|---|
| T = CG / (1 + CGH) | `T = feedback(C*G, H)` |
| H = 1, L = N/D → T = N / (D + N) | `[N,D] = tfdata(L,'v'); D + N` |
| Polos / zeros | `pole(T)`, `zero(T)`, `pzmap(T)` |
| Expandir (s+a)(s+b) | `conv([1 a],[1 b])` ou `poly([-a -b])` |

### 2. Estabilidade

| Equação | MATLAB |
|---|---|
| Estável ⇔ Re(polos) < 0 | `isstable(T)` |
| Trocas de sinal na 1ª coluna = polos no SPD | `routh(den)` |
| K crítico: linha s¹ = 0 | `solve(tab(end-1,1)==0, K)` |
| ω crítico: A s² + B = 0 → ω = √(B/A) | linha s² da tabela |
| 3ª ordem s³+a₂s²+a₁s+a₀: estável se a₂a₁ > a₀ | — |
| K crítico pela margem de ganho | `[Gm,~,Wcg] = margin(G)` |

### 3. Erro em regime (Nise cap. 7)

| Equação | MATLAB |
|---|---|
| e(∞) = lim s→0 s·E(s), E = R/(1+L) | `limit(sv*E, sv, 0)` (simbólico) |
| c(∞) = T(0) (degrau unitário) | `dcgain(T)` |
| e(∞) = 1 − c(∞) (degrau, H = 1) | `1 - dcgain(T)` |
| Tipo = nº de polos em s = 0 de L | `erro_regime(L)` |
| Kp = lim L, Kv = lim sL, Ka = lim s²L | `erro_regime(L)` |

| | Degrau | Rampa | Parábola |
|---|---|---|---|
| Tipo 0 | 1/(1+Kp) | ∞ | ∞ |
| Tipo 1 | 0 | 1/Kv | ∞ |
| Tipo 2 | 0 | 0 | 1/Ka |

Só vale com malha fechada **estável**.

### 4. Transitório (Nise cap. 4)

| Equação | MATLAB |
|---|---|
| s = −σ ± jω_d, ωn = \|s\|, ζ = σ/ωn | `info_polos(T)` |
| %OS = 100·e^(−ζπ/√(1−ζ²)) | `100*exp(-z*pi/sqrt(1-z^2))` |
| ζ = −ln(OS/100) / √(π² + ln²(OS/100)) | `-log(OS/100)/sqrt(pi^2+log(OS/100)^2)` |
| Tp = π/ω_d | `info.PeakTime` |
| Ts (2%) = 4/σ | `info.SettlingTime` |
| Medição exata | `stepinfo(T)` |

### 5. Lugar das raízes

| Equação | MATLAB |
|---|---|
| 1 + KG = 0, ∠G = 180°, K = 1/\|G\| | `rlocus(G)`, `rlocfind(G)` |
| Ponto de partida: N′D − ND′ = 0 | `ponto_partida(G)` |
| K para ζ | `k_para_zeta(G, zeta)` |
| σ_a = (Σp − Σz)/(np − nz), θ_a = (2m+1)180°/(np − nz) | `a06_lugar_raizes.m` |

### 6. Controladores

| Equação | MATLAB |
|---|---|
| PI: K1 + K2/s = k(s+zᵢ)/s, K1 = k, K2 = k·zᵢ | `pi_ganhos(k, zi)` |
| zᵢ = 0,1·\|polo da planta mais próximo da origem\| | `a07_PI.m` |
| PID: K1 + K2/s + K3s = k(s+zᵢ)(s+z_d)/s | `pid_ganhos(k, zi, zd)` |
| K1 = k(zᵢ+z_d), K2 = k·zᵢ·z_d, K3 = k | `pid_para_zeros(K1,K2,K3)` |
| Objeto pronto | `pid(K1, K2, K3)` |

### 7. Amplificador operacional (Vs/Ve = −Z2/Z1)

| Circuito | Resultado |
|---|---|
| P: Z1 = R1, Z2 = R2 | −R2/R1 |
| PI: Z2 = R2 + 1/(sC) | k = R2/R1, zᵢ = 1/(R2C) → R2 = 1/(zᵢC), R1 = R2/k |
| PID: Z1 = R1 ∥ C1, Z2 = R2 + 1/(sC2) | K1 = R2/R1 + C1/C2, K2 = 1/(R1C2), K3 = R2C1 |

### 8. Discreto

| Equação | MATLAB |
|---|---|
| de/dt ≈ (e_a − e_{a−1})/T ↔ sE(s) | `diff(e)/T` |
| s ≈ (1 − z⁻¹)/T | `tf([1 -1],[T 0],T)` |
| ∫e dt ≈ Σ T·e_a ↔ E(s)/s | `cumsum(e)*T` |

## Armadilhas

1. **`syms s` × `tf('s')`.** `feedback`, `step`, `dcgain` e `pole` só funcionam com `tf`. Para cálculo simbólico, use **outro nome** (`syms sv K`) para não sobrescrever o `s`.
2. **Teorema do Valor Final** só vale se T(s) for estável. Rode `isstable(T)` antes.
3. **`stepinfo`** usa 2% para o tempo de acomodação, e RiseTime usa 10–90%.
4. **Ts = 4/σ é aproximação** de 2ª ordem. Se houver polo real lento (caso do PI, com polo em ≈ −0,084), o Ts real é bem maior. `info_polos` avisa quando isso acontece.
5. **Polo do PI em s = 0** não conta como "polo mais próximo da origem" ao calcular zᵢ. O critério usa os polos da planta.
6. **Amp. op. inverte o sinal.** Coloque um inversor de ganho −1 em série.
7. Funções auxiliares precisam estar na **pasta atual** do MATLAB.

## Resultados de referência (G = 1/[(s+1)(s+2,1)(s+10,5)])

| Controlador | Polos de T | c(∞) | e(∞) | tp (s) | ts (s) |
|---|---|---|---|---|---|
| P (k = 100) | −11,51; −1,045 ± j3,084 | 0,819 | 0,181 | 1,11 | 3,51 |
| PI (k = 100, zᵢ = 0,1) | −11,50; −1,006 ± j3,058; −0,084 | 1 | 0 | 1,13 | 25,2 |
| PID (k = 15, zᵢ = 0,1, z_d = 20) | −11,70; −0,902 ± j5,143; −0,094 | 1 | 0 | 0,65 | 11,7 |

K crítico (P) = 449,19 (ω = 5,886 rad/s) · Ponto de partida s ≈ −1,533 (K ≈ 2,71) · K para ζ = 0,5 ≈ 49,69
