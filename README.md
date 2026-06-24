# Girl Adventure

A third-person action-adventure game built in **Godot 4.6**, about a girl on an adventure. Story in progress.

Mechanics are modeled on a classic 3rd-person action template: melee combat (light/heavy attack, block, dodge roll), lock-on targeting, stamina, inventory, collectibles, and enemy AI.

## Getting started

1. Install **[Godot 4.6+](https://godotengine.org/download)** (standard build, not .NET — the project is pure GDScript).
2. Clone this repo:
   ```bash
   git clone <repo-url>
   ```
3. Open Godot → **Import** → select the `project.godot` file in the cloned folder.
4. Press **F5** to play.

## Controls

| Action | Keyboard | Gamepad |
|---|---|---|
| Move | WASD | Left stick |
| Look / Camera | Mouse | Right stick |
| Run | Shift | L3 |
| Jump | Space | A |
| Roll / Dodge | Q | B |
| Crouch | C | RB |
| Light attack | Left click | RT |
| Heavy attack | Right click | LT |
| Block | F | LB |
| Lock-on | T | R3 |
| Interact | E | X |
| Inventory | I | Back |

## Project structure

```
scenes/
  player/      player.tscn
  enemies/     enemy_base.tscn
  ui/          hud.tscn
  world/       level_01.tscn   (main scene)
scripts/
  player/      player.gd, player_stats.gd
  enemies/     enemy_base.gd
  systems/     game_manager.gd, inventory.gd, collectible.gd, input_setup.gd
  ui/          hud.gd
assets/        textures, audio (add models/anims here)
```

- **Autoloads** (`Project Settings > Globals`): `GameManager`, `Inventory`, `InputSetup`.
- Input bindings are registered in code via `scripts/systems/input_setup.gd` (not in `project.godot`).
- See [`SKELETON_NOTES.md`](SKELETON_NOTES.md) for what's built and what's left to fill in.

## Contributing

This is an early skeleton. To avoid merge conflicts on scenes/scripts:
- Create a branch per feature: `git checkout -b feature/<name>`
- Open a Pull Request for review before merging to `main`.
- Godot `.tscn`/`.tres` files are text and diffable, but coordinate before editing the same scene.
