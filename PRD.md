# PRD — Dead Ember: Survival

**Versão:** 1.0  
**Data:** 2026-06-03  
**Engine:** Godot 3.6  
**Plataforma:** Desktop (Windows)  
**Status do projeto:** Protótipo (~75% implementado)  
**Repositório:** [github.com/lucazcoding/godot2d-project](https://github.com/lucazcoding/godot2d-project)  
**Branch principal:** `prototipo-jogo`

---

## 1. História do Produto

### Contexto

Em um mundo onde a civilização entrou em colapso e cidades foram tomadas por zumbis, sobreviventes precisam lutar a cada dia para não serem consumidos pelo caos. O jogador entra nesse universo como **Ash**, um sobrevivente que se encontra sozinho em meio a ruínas urbanas, armado apenas com uma pistola de plasma improvisada.

### Problema

Jogadores que buscam jogos de sobrevivência top-down frequentemente encontram experiências rasas, sem narrativa ou decisões significativas. Dead Ember: Survival propõe um loop de gameplay onde **exploração, combate e escolhas narrativas coexistem**, tornando cada partida mais do que apenas "matar inimigos".

### Proposta de Valor

> *"Como sobrevivente em uma cidade pós-apocalíptica, quero eliminar zumbis, coletar recursos e interagir com outros sobreviventes para entender o que aconteceu com o mundo e aumentar minhas chances de continuar vivo."*

### Usuário-alvo

Estudantes e entusiastas de jogos indie que apreciam mecânicas de ação combinadas com elementos de RPG leve (diálogos, inventário, escolhas morais). O projeto também atende ao contexto **acadêmico** da disciplina, exigindo demonstração de cinco algoritmos clássicos em um ambiente funcional e jogável.

### Motivação acadêmica

O projeto é desenvolvido por uma equipe de 7 estudantes e exige implementação demonstrável de:
A\*, BFS, QuickSort, percurso em árvore de diálogo e sistema de empilhamento de itens — todos com análise de complexidade documentada.

---

## 2. Objetivos

| Objetivo | Descrição |
|----------|-----------|
| Jogabilidade funcional | Ciclo completo de jogar → morrer → reiniciar |
| Algoritmos obrigatórios | Implementar e demonstrar os 5 algoritmos exigidos |
| NPC e narrativa | Diálogos ramificados com pelo menos 5 personagens distintos |
| Inventário | Sistema de coleta, empilhamento e reordenação de itens |
| Performance | Manter 30 FPS com 30 zumbis simultâneos em tela |

---

## 3. Escopo

### 3.1 Dentro do escopo

- Menu principal com opções Jogar e Sair
- Fase 1 jogável com mapa de tiles, spawners e inimigos
- Movimentação WASD e pathfinding por clique (Shift + Click)
- Sistema de tiro com projéteis (tecla F)
- IA de perseguição de inimigos com BFS
- Sistema de itens no chão e inventário com drag-and-drop (tecla E)
- 5 NPCs com árvores de diálogo individuais (4–6 nós cada)
- Tela de Game Over com opções de reiniciar ou sair
- HUD com barra de vida do jogador e dos inimigos
- Sistema de spawn por área (ativa ao entrar na zona do spawner)

### 3.2 Fora do escopo (backlog / opcional)

- Sistema de pontuação e placar
- Inimigo boss
- Seleção de dificuldade
- Fase 2 e tela de vitória
- Animações completas de personagens
- HUD detalhado (minimapa, contador de inimigos)

---

## 4. Requisitos Funcionais

| ID | Requisito | Prioridade |
|----|-----------|-----------|
| RF01 | O jogo deve exibir um menu principal com os botões **Jogar** e **Sair** | Alta |
| RF02 | O jogador deve se mover usando as teclas **WASD** | Alta |
| RF03 | O jogador deve poder se mover por pathfinding com **Shift + Clique esquerdo**, calculado via A\* | Alta |
| RF04 | O jogador deve atirar projéteis com a tecla **F** na direção do cursor | Alta |
| RF05 | Projéteis devem causar **2 HP** de dano ao atingir um inimigo e ser destruídos ao colidir com paredes | Alta |
| RF06 | Inimigos devem detectar o jogador ao entrar em sua `Area2D` e persegui-lo via **BFS** | Alta |
| RF07 | Inimigos devem causar **5 HP** de dano ao tocar o jogador | Alta |
| RF08 | Inimigos devem morrer ao atingir **0 HP** e exibir barra de vida individual | Alta |
| RF09 | Spawners devem gerar inimigos ao detectar o jogador na área, com no máximo **10 por spawner** | Alta |
| RF10 | Itens no chão devem ser coletados automaticamente por sobreposição com o jogador | Alta |
| RF11 | O inventário deve ser aberto/fechado com a tecla **E** | Alta |
| RF12 | O inventário deve suportar **drag-and-drop** entre slots, empilhamento e troca de itens | Alta |
| RF13 | O inventário deve se ordenar por **categoria e nome** (QuickSort) ao ser exibido | Média |
| RF14 | O jogador deve poder interagir com **5 NPCs** via tecla Espaço, navegando em árvores de diálogo com Sim/Não | Alta |
| RF15 | A tela de **Game Over** deve aparecer quando o HP do jogador chega a 0, com opções de reiniciar ou sair | Alta |
| RF16 | O jogo deve ter trilha sonora de fundo e efeito sonoro para inimigos | Baixa |

---

## 5. Requisitos Não-Funcionais

| ID | Requisito | Critério de Medição |
|----|-----------|---------------------|
| RNF01 | **Performance** — O jogo deve rodar a no mínimo 30 FPS | Medido com monitor de FPS do Godot com 30 inimigos simultâneos em tela |
| RNF02 | **Compatibilidade** — O executável deve rodar em Windows 10/11 sem dependências externas | Testado em máquina limpa sem Godot instalado |
| RNF03 | **Estabilidade** — Nenhum crash ou loop infinito deve ocorrer durante o ciclo jogar → morrer → reiniciar | 10 partidas completas sem interrupção |
| RNF04 | **Usabilidade** — Controles devem ser aprendidos sem tutorial, apenas com as mecânicas visíveis na tela | Teste com usuário não familiarizado em menos de 2 minutos |
| RNF05 | **Manutenibilidade** — Scripts devem seguir nomenclatura em português, separados por responsabilidade (1 script por cena) | Revisão de código pela equipe |
| RNF06 | **Rastreabilidade acadêmica** — Cada algoritmo obrigatório deve estar isolável e identificável no código-fonte | Comentário de cabeçalho em cada função de algoritmo |
| RNF07 | **Tamanho do build** — O executável exportado não deve ultrapassar **150 MB** | Verificado após export no Godot |

---

## 6. Mecânicas do Jogo

### 6.1 Jogador (Ash)

| Atributo | Valor |
|----------|-------|
| Vida | 10 HP |
| Velocidade | 200 px/s |
| Dano do projétil | 2 HP por acerto |

**Controles:**

| Ação | Entrada |
|------|---------|
| Mover | WASD |
| Mover com pathfinding | Shift + Clique esquerdo |
| Atirar | F |
| Abrir / fechar inventário | E |
| Interagir com NPC | Espaço (dentro da área de detecção) |

### 6.2 Inimigos (Zumbis)

| Atributo | Valor |
|----------|-------|
| Vida | 5 HP |
| Velocidade | 250 px/s |
| Dano por contato | 5 HP |
| Recálculo de rota | a cada 0,3 s |

- Detectam o jogador via `Area2D`
- Perseguem usando BFS sobre o tilemap
- Emitem som de zumbi ao perseguir
- Exibem barra de HP individual

### 6.3 Sistema de Spawn

- Spawners ativados por proximidade do jogador
- Máximo de 10 inimigos por spawner com offset aleatório de 20 px
- Spawn por intervalo de timer configurável

### 6.4 Itens e Inventário

**Itens disponíveis:**

| Item | ID | Categoria | Empilhamento máx. |
|------|----|-----------|-------------------|
| Poção de Vida | `pocao_vida` | Cura | 2 |
| Esmeralda | `esmeralda` | Moeda | 64 |
| Granada | `granada` | Recurso | 64 |

**Comportamento do inventário:**
- Slots com drag-and-drop completo
- Empilhamento automático ao soltar item sobre slot do mesmo tipo
- Troca de posição entre slots diferentes
- Ordenação por categoria e depois por nome (QuickSort via `sort_custom()`)
- Coleta automática por sobreposição de `Area2D` ("ItemChao" group)

### 6.5 NPCs e Diálogos

| NPC | Papel | Missão / Tema |
|-----|-------|---------------|
| NPC genérico | Primeiro contato | Orientação básica |
| Guardião | Aviso de perigo | Matar 10 inimigos |
| Misterioso | Escolha moral | Poder vs. Conhecimento |
| Vinicius | Sobrevivente | Dicas táticas e localização de suprimentos |
| Nogueira | Fazendeiro | Filha desaparecida; matar 10 zumbis |

- Ativação por proximidade + tecla Espaço
- Árvores de diálogo com botões Sim / Não
- Auto-fechamento após 2 segundos na resposta final

---

## 7. Algoritmos Obrigatórios

| # | Algoritmo | Onde é usado | Complexidade |
|---|-----------|--------------|-------------|
| 1 | **A\*** | Pathfinding do jogador (Shift+Click) — `scriptPlayer.gd` | O(V log V + E) |
| 2 | **BFS** | Perseguição dos inimigos — `scriptEnemy.gd` | O(V + E) |
| 3 | **QuickSort** | Ordenação do inventário — `Inventory.gd` | O(n log n) médio |
| 4 | **Percurso em árvore** | Navegação nos diálogos dos NPCs — `scriptNPC*.gd` | O(h) |
| 5 | **Empilhamento de itens** | Lógica de stack nos slots — `scriptSlot.gd` | O(1) por operação |

---

## 8. Fluxo de Telas

```
Menu Principal
    └─► Fase 1 (gameplay)
            ├─► Inventário (overlay, tecla E)
            ├─► Diálogo NPC (overlay, tecla Espaço)
            └─► Cena de Derrota
                    ├─► Reiniciar (recarrega Fase 1)
                    └─► Aceitar a Paz (encerra o jogo)
```

---

## 9. Assets

### Sprites
- Título, botões de menu, botão de respawn
- Fundo do menu e do inventário, slots do inventário
- Sprites dos itens (poção, esmeralda, granada)
- Efeitos de projétil e explosão
- Tiny RPG Character Asset Pack v1.03 (personagens e projéteis)

### Áudio

| Arquivo | Uso |
|---------|-----|
| emmraan-in-the-night | Menu ou gameplay |
| sacred-garden (2 versões) | Gameplay / ambientação |
| piano-violin | Ambientação |
| zombie-sound | SFX dos inimigos |

### Fontes
- `Games.ttf` — fonte principal da UI

---

## 10. Arquitetura Técnica

| Componente | Solução |
|-----------|---------|
| Engine | Godot 3.6 |
| Linguagem | GDScript |
| Banco de itens | AutoLoad `BancoDeItens.gd` (singleton) |
| Tilemap | `Tilemaps/Tilemap.tscn` com camadas de navegação e obstáculos |
| Resolução | Stretch 2D com aspecto keep |
| Cenas instanciáveis | Prefabs em `Instantiables/` e `Prefabs/` |

---

## 11. Critérios de Aceite

| Funcionalidade | Critério |
|----------------|---------|
| Menu | Botões Jogar e Sair funcionam corretamente |
| Movimentação | WASD e Shift+Click navegam sem travar em obstáculos |
| Combate | Projétil acerta inimigo, reduz HP; inimigo morre ao chegar a 0 |
| Zumbi | Persegue o jogador ao entrar na área de detecção |
| Game Over | Tela aparece quando HP do jogador chega a 0 |
| Itens | Coleta, empilha e organiza corretamente no inventário |
| NPCs | Todos os 5 NPCs apresentam diálogos ramificados completos |
| Performance | 30 FPS estável com 30 inimigos em tela |

---

## 12. Time

| Papel | Responsável |
|-------|-------------|
| Game Design | Equipe (7 membros) |
| Programação | Equipe (7 membros) |
| Arte | Assets externos + criações da equipe |
| Documentação | Equipe (7 membros) |
