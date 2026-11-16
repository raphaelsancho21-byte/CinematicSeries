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
3. Configure `CONFIG` no topo do gerador e execute novamente para regenerar. O script recria **somente** `CinematicSeries_Set`, preservando os seus rigs.
4. Coloque os rigs R6 `Bandido` e `Policial` no Workspace e mantenha as animações em `ServerStorage > RBX_ANIMSAVES`.
5. O sistema já existente usa `Take01Camera` (RemoteEvent) e `TakeStartTime` (Attribute). Os scripts versionados de take estão em `scripts/`.

### Importante
- O gerador **não altera sua iluminação global a menos que** `CONFIG.ApplyGlobalLighting = true`; nesse caso cria efeito Atmosphere e ColorCorrection e altera Lighting. Mantenha backups de lugares existentes.
- O mapa é um *set cinematográfico* composto de Parts e luzes. Não há IA de perseguição nesta etapa.
- Toda peça gerada possui nome útil, e está agrupada em pastas: Streets, Buildings, Props, StreetLights, Details e Markers.
- Scripts `.server.lua` / `.client.lua` são arquivos-fonte, não scripts executados pelo GitHub. Para sincronização automática no futuro, poderemos adicionar Rojo.
- As animações de usuários terceiros permanecem no seu Studio; não são copiadas/publicadas neste repositório.
