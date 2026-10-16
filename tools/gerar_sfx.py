"""Gera os efeitos sonoros do Fatorial Dungeon (arquivos .wav em trabalho/sfx).

Os sons são sintetizados por código (ondas senoidais, triangulares e quadradas
com envelopes), então não dependem de nenhum banco de áudio externo.

Uso:  python3 tools/gerar_sfx.py
"""
import os
import wave
import numpy as np

SR = 44100
SAIDA = os.path.join(os.path.dirname(__file__), "..", "trabalho", "sfx")


def t_(dur):
    return np.linspace(0, dur, int(SR * dur), endpoint=False)


def seno(f, dur):
    return np.sin(2 * np.pi * f * t_(dur))


def triangulo(f, dur):
    return 2 / np.pi * np.arcsin(np.sin(2 * np.pi * f * t_(dur)))


def quadrada(f, dur):
    return np.sign(np.sin(2 * np.pi * f * t_(dur)))


def varredura(f0, f1, dur, forma=np.sin):
    """Frequência que desliza de f0 até f1."""
    t = t_(dur)
    fase = 2 * np.pi * (f0 * t + (f1 - f0) * t ** 2 / (2 * dur))
    return forma(fase)


def env(n, ataque=0.005, queda=6.0):
    """Ataque curto + decaimento exponencial."""
    t = np.linspace(0, 1, n)
    a = np.minimum(1, t / max(ataque * 10, 1e-6))
    return a * np.exp(-queda * t)


def nota(freq, dur, forma=seno, queda=6.0, harm=0.0):
    s = forma(freq, dur)
    if harm:
        s = s + harm * seno(freq * 2, dur)
    return s * env(len(s), queda=queda)


def sequencia(notas, passo, dur_nota, **kw):
    total = int(SR * (passo * (len(notas) - 1) + dur_nota)) + 1
    saida = np.zeros(total)
    for i, f in enumerate(notas):
        s = nota(f, dur_nota, **kw)
        ini = int(SR * passo * i)
        saida[ini:ini + len(s)] += s
    return saida


def salvar(nome, onda, pico=0.8):
    onda = onda / (np.max(np.abs(onda)) + 1e-9) * pico
    fade = int(SR * 0.004)  # 4 ms para não estalar no começo/fim
    onda[:fade] *= np.linspace(0, 1, fade)
    onda[-fade:] *= np.linspace(1, 0, fade)
    dados = (onda * 32767).astype("<i2")
    os.makedirs(SAIDA, exist_ok=True)
    with wave.open(os.path.join(SAIDA, nome + ".wav"), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(dados.tobytes())
    print(f"{nome}.wav  {len(onda) / SR:.2f}s")


# Notas (Hz)
C5, E5, G5, C6, E6 = 523.25, 659.25, 783.99, 1046.5, 1318.5
A4, F4, D4 = 440.0, 349.23, 293.66

# Resposta certa: arpejo ascendente brilhante
salvar("acerto", sequencia([C5, E5, G5, C6], 0.07, 0.30, forma=triangulo, queda=5, harm=0.3))

# Resposta errada: dois tons graves descendentes, "buzz" suave
erro = np.concatenate([nota(196, 0.14, quadrada, queda=3), nota(147, 0.22, quadrada, queda=4)])
salvar("erro", erro, pico=0.55)

# Portal abrindo: varredura ascendente com brilho e tremolo
dur = 0.9
t = t_(dur)
base = varredura(250, 1400, dur) * 0.7 + varredura(500, 2800, dur) * 0.25
trem = 0.75 + 0.25 * np.sin(2 * np.pi * 14 * t)
portal = base * trem * np.minimum(1, t / 0.05) * np.exp(-1.8 * t / dur)
salvar("portal", portal)

# Entrar no portal: varredura descendente (whoosh)
dur = 0.55
t = t_(dur)
rng = np.random.default_rng(7)
ruido = np.convolve(rng.standard_normal(len(t)), np.ones(40) / 40, mode="same")
entrar = varredura(1500, 180, dur) * 0.7 + ruido * 0.9
entrar *= np.sin(np.pi * t / dur) ** 0.6
salvar("entrar_portal", entrar, pico=0.75)

# Interface
salvar("clique", nota(1200, 0.06, quadrada, queda=9) * 0.6 + nota(1800, 0.06, seno, queda=10) * 0.4, pico=0.6)
salvar("hover", nota(880, 0.04, seno, queda=8), pico=0.35)
salvar("painel_abrir", sequencia([E5, A4 * 2], 0.06, 0.14, forma=triangulo, queda=6), pico=0.6)
salvar("painel_fechar", sequencia([A4 * 2, E5 * 0.75], 0.06, 0.14, forma=triangulo, queda=6), pico=0.5)

# Passo: sopro curtíssimo e grave
t = t_(0.05)
passo = np.convolve(rng.standard_normal(len(t)), np.ones(25) / 25, mode="same") * env(len(t), queda=9)
salvar("passo", passo, pico=0.5)

# Vitória: fanfarra com acorde final
fan = sequencia([C5, C5, C5, G5, E5, G5, C6], 0.13, 0.35, forma=triangulo, queda=3, harm=0.35)
acorde = (nota(C5, 0.9, triangulo, 3) + nota(E5, 0.9, triangulo, 3) + nota(G5, 0.9, triangulo, 3) + nota(C6, 0.9, triangulo, 3)) / 2
saida = np.zeros(int(SR * 2.0))
saida[:len(fan)] += fan * 0.7
ini = int(SR * 0.95)
saida[ini:ini + len(acorde)] += acorde
salvar("vitoria", saida)

# Game over: quatro notas descendentes em tom menor
salvar("game_over", sequencia([G5, E5 * 0.9, C5 * 0.9, 261.6 * 0.75], 0.22, 0.55, forma=triangulo, queda=3.5, harm=0.2), pico=0.7)
