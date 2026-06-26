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

## Original assets (extracted from "Adventures of Julia")

Extracted into `assets/` as editable Godot resources:

- **Character** → `assets/models/character/` (CC_Base_Body + clothing, hair, shoes, eyes) +
  `assets/textures/character/`. Assembled in `scenes/player/character_model.tscn` and wired
  into the player. Models came in **Z-up**, so the model root carries a -90 deg X rotation to
  stand upright; tweak there if needed.
- **Weapons** → `assets/models/weapons/` (swords, katana, shield, axe).
- **Map kit** → `assets/models/environment/` (floors, fences, walls, roofs, lamps, plants,
  trees, doors, props) + `assets/textures/environment/` diffuse maps. A sample set is placed
  under `Level01 > Props`.
- **Sprites / UI** → `assets/sprites/` (control icons, coin, logos, HUD bits).

> Note: meshes were exported as static OBJ (bind pose) - no armature/skinning. To animate the
> character you'll need to re-rig it in Blender, or swap in a rigged model.

## What to fill in when story is ready

- **Character model** → already wired (`character_model.tscn`); swap meshes/textures or re-rig as needed
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
