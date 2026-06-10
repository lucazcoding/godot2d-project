# Dead Ember: Survival

Jogo 2D top-down desenvolvido em Godot 3.6 como projeto acadêmico da disciplina de Estrutura de Dados Avançado.

## Como rodar

1. Instale o [Godot Engine 3.6](https://godotengine.org/download)
2. Clone o repositório: `git clone https://github.com/lucazcoding/godot2d-project`
3. Abra o Godot e importe a pasta `repositorio-jogo/`
4. Execute a cena principal: `Scenes/Menu.tscn`

## Gênero

Top-down shooter com elementos de RPG. O jogador explora um mapa pós-apocalíptico, coleta itens, interage com NPCs e combate inimigos.

## Controles

| Tecla | Ação |
|-------|------|
| WASD | Movimentar |
| F | Atirar |
| E | Abrir/fechar inventário |
| Shift + Clique | Mover via A* pathfinding |
| T | Ativar/desativar rota TSP de coleta |
| Espaço | Interagir com NPC |

## Algoritmos Implementados

### 1. TSP — Travelling Salesman Problem
**Arquivo:** `Scripts/scriptPlayer.gd`

Calcula a rota ótima de coleta entre todos os itens visíveis no mapa. Ao pressionar `T`, o algoritmo determina a sequência de itens que minimiza a distância total percorrida a partir da posição atual do jogador.

- **n ≤ 15 itens:** Held-Karp (solução exata) — O(n² · 2ⁿ)
- **n > 15 itens:** Vizinho mais próximo (heurística gulosa) — O(n²)
- Matriz de distâncias construída via A* para respeitar obstáculos do mapa
- Visualização: linha dourada desenhada com `Line2D` seguindo o caminho A* até o próximo item
- A rota recalcula automaticamente ao coletar um item

### 2. A* Pathfinding
**Arquivo:** `Scripts/scriptPlayer.gd` e `Scripts/scriptEnemy.gd`

- **Player:** Shift + Clique move o jogador até o ponto clicado desviando de obstáculos
- **Enemy:** Inimigos recalculam o caminho até o jogador a cada 0.3s ao entrar no raio de detecção
- Estrutura: lista aberta como Array, heurística euclidiana, vizinhos 4-direcionais
- `tiles_navegaveis` armazenado como Dictionary para lookup O(1)

### 3. Hash Table no Inventário
**Arquivo:** `Scripts/Inventory.gd`

O inventário utiliza uma tabela hash com sondagem linear para distribuir itens nos slots. Cada item é posicionado via `_hash_id(item_id)` — soma dos bytes do ID módulo o total de slots. Colisões resolvidas por sondagem linear.

- Acesso, inserção e remoção em O(1) médio
- Inspirado em hash indexes de bancos de dados

### 4. Árvore de Diálogo com NPCs
**Arquivos:** `Scripts/scriptNPC.gd`, `Scripts/scriptNPC2.gd`, `Scripts/NPC3.gd`, `Scripts/NOGUEIRA_NPC.gd`

Cada NPC possui uma árvore de diálogo implementada como array de dicionários com ramificação por índice. O jogador navega pela árvore através de escolhas Sim/Não, alterando o fluxo da conversa.

- Travessia em O(h) onde h é a profundidade do nó
- Aplicação real: sistemas IVR e chatbots de suporte usam árvores de decisão similares

## Estrutura do Repositório

```
repositorio-jogo/
├── Scenes/          # Cenas principais (Menu, Fase1)
├── Scripts/         # Scripts GDScript
├── Instantiables/   # Prefabs (Player, Enemy, NPCs, itens)
├── Prefabs/         # Itens coletáveis e slots de inventário
├── Sprites/         # Assets visuais
├── Resources/       # Fontes e áudio
├── Tilemaps/        # Tileset do mapa
└── Docs/            # PRD do projeto
```

## Equipe

| Dev | Responsabilidade |
|-----|-----------------|
| Lucas (Dev 1) | Hash Table no Inventário |
| Nogueira (Dev 2) | A* Pathfinding |
| Shelda (Dev 3) | Árvore de Diálogo com NPCs |
| Geovane (Dev 4) | QuickSort no Inventário |
| Fabiano (Dev 5) | IA de Aproximação dos Inimigos |
| Vinicius (Dev 6) | TSP, PRD e GitHub Project Board |

## Issues e Organização

As issues do projeto seguem o padrão `[FEATURE] título` e estão organizadas no [GitHub Project Board](https://github.com/lucazcoding/godot2d-project/projects).
