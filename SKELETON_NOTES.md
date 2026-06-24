# Girl Adventure — Skeleton Notes

## What's built

| System | File | Status |
|---|---|---|
| Player movement (walk/run/crouch/jump) | `scripts/player/player.gd` | ✅ Skeleton |
| Player combat (light/heavy/block/roll) | `scripts/player/player.gd` | ✅ Skeleton |
| Lock-on targeting | `scripts/player/player.gd` | ✅ Skeleton |
| Player stats resource | `scripts/player/player_stats.gd` | ✅ |
| Enemy AI (patrol/chase/attack) | `scripts/enemies/enemy_base.gd` | ✅ Skeleton |
| Inventory system | `scripts/systems/inventory.gd` | ✅ Skeleton |
| Game manager / signals | `scripts/systems/game_manager.gd` | ✅ |
| Collectibles (coins/health/items) | `scripts/systems/collectible.gd` | ✅ |
| HUD (health/stamina/coins) | `scripts/ui/hud.gd` + `hud.tscn` | ✅ |
| Player scene | `scenes/player/player.tscn` | ✅ |
| Enemy scene | `scenes/enemies/enemy_base.tscn` | ✅ |
| Level 01 (test world) | `scenes/world/level_01.tscn` | ✅ |

## What to fill in when story is ready

- **Character model** → drop your girl's 3D model into `assets/` and attach to `scenes/player/player.tscn > Mesh > MeshInstance3D`
- **Animations** → populate `AnimationPlayer` with: `idle`, `walk`, `run`, `crouch`, `jump`, `fall`, `roll`, `attack_light`, `attack_heavy`, `block`, `hurt`, `death`
- **Dialogue system** → add a `DialogueManager` autoload (recommend the community "Dialogue Manager" plugin)
- **Story chapters** → each chapter = one level scene under `scenes/world/`
- **Enemy variants** → extend `EnemyBase` with `class_name EnemyXxx` and override `_do_attack()` / stats
- **Weapons** → create a `Weapon` resource; equip via `Inventory`
- **Cutscenes** → use Godot's `AnimationPlayer` or `Tween` on a `Cutscene` node in each level

## Controls (keyboard)

| Action | Key |
|---|---|
| Move | WASD |
| Run | Shift |
| Jump | Space |
| Roll/Dodge | Q |
| Crouch | C |
| Light Attack | Left Click |
| Heavy Attack | Right Click |
| Block | F |
| Lock-on | T |
| Interact | E |
| Inventory | I |

## First steps to open in Godot

1. Open Godot 4.3+
2. **Import Project** → point to this folder
3. Hit **Play** — you'll see the test level with the ground, 2 enemies, and HUD
4. Add your character mesh, bake the NavigationRegion3D, and you're ready to prototype
