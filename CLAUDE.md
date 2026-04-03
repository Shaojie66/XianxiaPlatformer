# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**修仙纪 (Xianxia Chronicle)** — A Chinese cultivation-themed 2D platformer built with Godot 4.6.

- Main scene: `res://scenes/levels/Level1_Lianqi.tscn`
- Resolution: 1280x720, canvas_items stretch mode
- No external dependencies beyond Godot itself

## Running the Project

Open the project in Godot 4.6 Editor:
```bash
godot --editor /Users/chenshaojie/GodotProjects/XianxiaPlatformer
```

Or run the project directly:
```bash
godot /Users/chenshaojie/GodotProjects/XianxiaPlatformer
```

## Architecture

### Core Systems (scripts/systems/)

- **PlayerStats** (Resource) — Player health, attack, defense, element, cultivation realm. Signals: `health_changed`, `died`
- **CombatSystem** — Static damage calculation with elemental multipliers. Call `calculate_damage()` not instances
- **ElementSystem** — 5-base-element (METAL/WOOD/WATER/FIRE/EARTH) + Yin/Yang + composite variants. Controls/generation relations affect damage multipliers (1.5x advantage, 0.5x disadvantage)
- **MedicineSystem** — Inventory, buffs (attack/defense/teleport/puzzle-unlock), cooldowns. Buffs are duration-based and auto-expire
- **SummonSystem** — 9 summon types unlocked by cultivation realm. Manages summon lifetime, cooldowns, factory creation

### Character Systems (scripts/characters/)

- **Player** — State machine (IDLE/RUNNING/JUMPING/FALLING/DASHING/FLYING). Movement: WASD/Arrow keys, Jump: Space/W/Up, Dash: Shift. Abilities gated by `can_double_jump`, `can_dash`, `can_fly` exports
- **SummonBase** — Orbiting companion that applies effects to enemies/allies. Nested classes for each summon type (SwordSpirit, SpiritGrass, IcePhoenix, FireCrow, StoneGolem, ShadowDemon, SunGod, YinYangBeast, ImmortalBeast)

### UI (scripts/ui/)

- **HUD** — Health bar, realm indicator, buff display, medicine hotbar. Connects to PlayerStats and MedicineSystem signals

### Scene Organization

```
scenes/
├── levels/      # 10 cultivation realm stages (Lianqi → Feisheng)
├── bosses/      # 6 boss scenes
├── characters/  # Player.tscn
└── ui/          # HUD.tscn
```

### Cultivation Progression

Realms (in order): 炼气 → 筑基 → 金丹 → 元婴 → 化神 → 炼虚 → 合体 → 大乘 → 渡劫 → 飞升

Summons unlock per realm via `SummonSystem.unlock_summons_for_realm()`.

### Input Actions (auto-registered on Player._ready)

- `move_left` / `move_right`: A/D or Arrow keys
- `jump`: W/Up/Space
- `dash`: Shift

### Key Patterns

- Systems use `preload()` for script references (not `load()`) for efficiency
- Summon factories are lambdas in `SUMMON_FACTORIES` dictionary
- Elemental effectiveness: base elements use control relations, polarities use Yin/Yang counters
- MedicineSystem tracks player via `_find_player()` searching for `Player` script global name

## User Preferences

- **Language**: 用户要求使用中文回答问题
