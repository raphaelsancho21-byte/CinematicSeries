# CinematicSeries 🎬

Estúdio de minisséries de ação no Roblox Studio. Projeto iniciado com o TAKE 01 (abordagem policial R6) e mapa noturno para futura perseguição a pé.

## Estrutura Roblox Studio

| Pasta do GitHub | Destino no Studio |
| --- | --- |
| `scripts/ServerScriptService/` | ServerScriptService |
| `scripts/StarterPlayer/StarterPlayerScripts/` | StarterPlayer > StarterPlayerScripts |
| `scripts/ReplicatedStorage/` | ReplicatedStorage (futuro) |
| `scripts/ServerStorage/` | ServerStorage (futuro) |
| `command-bar/` | Rodar na **Command Bar** do Studio, fora do Play |

## Primeiro passo: criar cenário
1. Abra `command-bar/GenerateNightCity.lua`, copie todo o conteúdo e cole em **View > Command Bar** no modo edição.
2. O mapa surge em `Workspace > CinematicSeries_Set`; cada peça é editável diretamente no Explorer.
3. Configure `CONFIG` no topo do gerador e execute novamente para regenerar. A versao atual move automaticamente os rigs existentes `Bandido` e `Policial` para os marcadores e adiciona refletores de preenchimento. O script recria **somente** `CinematicSeries_Set`, preservando os seus rigs.
4. Coloque os rigs R6 `Bandido` e `Policial` no Workspace e mantenha as animações em `ServerStorage > RBX_ANIMSAVES`.
5. O sistema já existente usa `Take01Camera` (RemoteEvent) e `TakeStartTime` (Attribute). Os scripts versionados de take estão em `scripts/`.

### Importante
- O gerador **não altera sua iluminação global a menos que** `CONFIG.ApplyGlobalLighting = true`; nesse caso cria efeito Atmosphere e ColorCorrection e altera Lighting. Mantenha backups de lugares existentes.
- O mapa é um *set cinematográfico* composto de Parts e luzes. Não há IA de perseguição nesta etapa.
- Toda peça gerada possui nome útil, e está agrupada em pastas: Streets, Buildings, Props, StreetLights, Details e Markers.
- Scripts `.server.lua` / `.client.lua` são arquivos-fonte, não scripts executados pelo GitHub. Para sincronização automática no futuro, poderemos adicionar Rojo.
- As animações de usuários terceiros permanecem no seu Studio; não são copiadas/publicadas neste repositório.

## Correcao de iluminacao / atores
- Use a ultima versao de `command-bar/GenerateNightCity.lua` no modo **Edit**. O script nao altera `Bandido` ou `Policial` alem de posiciona-los; o sistema de take continua separado.
- `PositionActors=true` posiciona os dois modelos no asfalto. Os rigs precisam existir em `Workspace`, com os nomes exatos; caso nao existam, o Output mostra um aviso.
- `ExtraStreetFill=true`, `LightBrightness=5.5` e `LightRange=42` clareiam as cenas; ajuste `Lighting.ExposureCompensation` para seu gosto.
- **Aviso:** os scripts do GitHub nao substituem os scripts do Studio automaticamente; use Rojo ou copie os arquivos para os locais indicados.


## Spawns dos NPCs (V1.2)
1. Rode novamente `command-bar/GenerateNightCity.lua` em modo **Edit**, para criar `Bandido_Spawn` e `Policial_Spawn` dentro de `Workspace > CinematicSeries_Set > 06_Camera_And_Actor_Markers`.
2. Crie um **Script** em `ServerScriptService` com o conteúdo de `scripts/ServerScriptService/CinematicNPCSpawner.server.lua`.
3. Atualize `CinematicDirectorV4` com o conteúdo do arquivo homônimo no GitHub (ele espera o spawner terminar). Deixe apenas uma versão de cada Script habilitada.
4. Clique em Play e confira o Output: `[NPC SPAWNER] Spawn: Bandido`, `[NPC SPAWNER] Spawn: Policial`.

Se os rigs originais não existirem no Workspace, o spawner procura `ServerStorage > CinematicNPCs > Bandido/Policial`; se não houver modelos salvos, tenta criar rigs R6 padrão. Para preservar a aparência personalizada, mantenha seus modelos originais ou use templates nessa pasta.

Os SpawnLocations possuem `Enabled=false` e são apenas marcadores de NPC, não alteram os pontos de nascimento de jogadores. Arraste os marcadores pelo Explorer para mudar os locais de entrada. 

## TAKE 01 V5 — perseguição a pé (45 segundos)
Sem novos scripts de ação: os **três scripts existentes** foram atualizados:
- `scripts/ServerScriptService/CinematicDirectorV4.server.lua`: timeline de 45 segundos, caminhada, corrida, fuga, mudança brusca e poeira no quase tropeço; usa `Walk1` e `Run1` do `RBX_ANIMSAVES`.
- `scripts/StarterPlayer/StarterPlayerScripts/Take01Director.client.lua`: oito enquadramentos seguindo NPCs, sem fixar a câmera no chão.
- `scripts/StarterPlayer/StarterPlayerScripts/CinematicDialogue.client.lua`: novas falas até 43 segundos.
- O `CinematicNPCSpawner.server.lua` e o mapa **não precisam ser alterados** nesta etapa.

**Como instalar:** copie o conteúdo atualizado de cada um dos 3 arquivos para os scripts **já existentes** no Roblox Studio. Não crie cópias com outros nomes. Desative `R6AnimationController` e versões antigas para evitar disputa de animações.

**Plano do take**: 0–4 caminhada; 4–8 chegada do policial; 8–12 provocação; 12–30 fuga; 30–33 quase tropeço com poeira; 33–39 retomada da perseguição; 39–45 confronto.

**Limites:** esta cena é coreografada por `PivotTo`; não é navegação autônoma e não há armas físicas. Ajuste as posições no `bRoute`/`pRoute` dentro do diretor caso tenha carros ou obstáculos na rua. O roteiro foi escrito para o cenário do gerador padrão, mas ainda precisa de teste no Studio.
