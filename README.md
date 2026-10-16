# Fatorial Dungeon

Jogo de exploração 2D em estilo dungeon, feito para praticar **Análise Combinatória** (permutações e anagramas) de forma divertida. Em cada fase, o jogador precisa resolver um problema de matemática para abrir o portal que leva à fase seguinte.

Projeto desenvolvido na disciplina de Matemática Discreta (UNIFOR, 2026.1).

<!-- Coloque aqui um GIF ou print do jogo, por exemplo: -->
<!-- ![Gameplay](prints/gameplay.gif) -->

## Como jogar

1. No menu principal, escolha **Jogar** (ou **Tutorial**, para aprender os controles).
2. Explore a fase movendo o personagem pelo mapa.
3. Aperte **R** para abrir o painel com o problema da fase.
4. Digite a resposta e aperte **Enter**.
5. Se acertar, uma mensagem de parabéns aparece e o **portal é liberado**. Entre nele para ir à próxima fase.
6. Se errar, o campo é limpo e você pode tentar de novo.

O jogo tem Tutorial, 3 fases e uma tela final.

### Controles

| Ação | Tecla |
| --- | --- |
| Mover | Setas ou WASD |
| Abrir/fechar o problema | R |
| Enviar resposta | Enter |
| Fechar o problema (1º toque) e voltar ao menu (2º toque) | Esc |

## Funcionalidades

- **Sistema de perguntas e respostas por fase:** o painel pausa o jogo enquanto o problema está aberto, e a resposta digitada é verificada automaticamente (sem diferenciar maiúsculas de minúsculas e ignorando espaços nas pontas).
- **Portal bloqueado até acertar:** o portal só aparece e só funciona depois da resposta correta.
- **Tela para o professor editar as questões:** no menu, a tela de edição permite trocar a pergunta e a resposta de cada fase (Tutorial, Fase 1, Fase 2 e Fase 3) sem mexer no código.
- **Movimento em grade:** o personagem anda tile a tile, com animação nas quatro direções e detecção de colisão com paredes por RayCast.
- **Menu principal:** Jogar, Tutorial, Opções, edição de questões e Sair.
- **Opções:** controle de volume e **modo com timer** opcional. Quando o tempo acaba, o jogador vai para a tela de Game Over.
- **Trilha sonora** em 8-bit nas fases.
- **Efeitos sonoros:** acerto, erro, abertura do portal, entrada no portal, passos, abrir/fechar o painel, cliques e hover nos botões, vitória e game over.
- **Feedback visual:** o painel balança e o campo fica vermelho quando a resposta está errada; a mensagem de acerto "pula" na tela.
- **Portal animado:** ao acertar, o portal surge com animação, solta faíscas e "respira" enquanto está aberto.
- **Transições com fade** entre todas as telas e título animado no início de cada fase.
- **Dica na tela** que indica o que fazer (abrir o desafio ou procurar o portal).
- **Menu animado:** botões que aparecem em sequência e crescem ao passar o mouse.
- **Tela final com confete.**

## Como editar as questões

1. No menu principal, abra a tela de edição de questões.
2. Escolha a fase (Tutorial, Fase 1, Fase 2 ou Fase 3).
3. Escreva a nova pergunta e a resposta esperada.
4. Clique em **Salvar**.

> As alterações valem enquanto o jogo estiver aberto. Ao fechar, as questões voltam para as originais.

As questões originais ficam em `trabalho/Scripts/ConfigGlobais.gd`, nos dicionários `perguntas_personalizadas` e `respostas_personalizadas`.

## Como rodar

1. Instale o [Godot Engine 4.7.2](https://godotengine.org/download) (versão padrão, não precisa da .NET).
2. Clone este repositório:
   ```bash
   git clone https://github.com/Matheus-D-C/Fatorial-Dungeon.git
   ```
3. No Godot, clique em **Importar** e selecione o arquivo `trabalho/project.godot`.
4. Aperte **F5** para rodar.

## Tecnologias

- Godot Engine 4.7.2 (renderizador GL Compatibility)
- GDScript

## Estrutura do projeto

```
trabalho/
├── Scripts/    # Lógica do jogo (jogador, portal, interface de perguntas, menus)
├── cenas/      # Cenas do Godot (Tutorial, Fase1-3, menus, Game Over, Tela Final)
├── Assets/     # Sprites do jogador e tilesets
├── musicas/    # Trilhas sonoras
├── sfx/        # Efeitos sonoros (.wav gerados por código)
├── fonte/      # Fonte do jogo
└── project.godot
tools/
└── gerar_sfx.py   # Script em Python que gera os efeitos sonoros
```

## Créditos

- Efeitos sonoros: sintetizados por código com o script `tools/gerar_sfx.py` (Python + NumPy), sem bancos de áudio externos.
- Músicas: David Fesliyan ([FesliyanStudios.com](https://www.fesliyanstudios.com)).
- Fonte: Minecraft.ttf.
- Tilesets e sprites: *(informe aqui a origem e a licença dos assets que não são seus)*.

## Autor

**Matheus Dias Crisostomo**
Estudante de Ciência da Computação na UNIFOR
[LinkedIn](https://www.linkedin.com/in/matheus-dias-1b8923431) • [GitHub](https://github.com/Matheus-D-C)
