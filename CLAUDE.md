# CLAUDE.md — Royal Era: Kingdom Chronicles

> **Game Type**: Fantasy RPG Co-op Adventure
> **Platform**: PC (Windows/macOS/Linux), Steam
> **Engine**: Godot 4.x
> **Development Status**: Early Development (v0.1.0)

---

## 1. Project Overview

- **Name**: Royal Era: Kingdom Chronicles
- **Description**: Fantasy RPG co-op adventure game set in medieval kingdom era. Players team up (max 5) to explore dungeons, hunt monsters, raid enemy kingdoms, and complete epic quests.
- **Goal**: Create engaging co-op RPG experience with rich progression system, challenging combat, and immersive fantasy setting
- **Target Users**: 
  - Ages 13+
  - Casual to hardcore RPG players
  - Co-op gaming enthusiasts
  - Fans of medieval fantasy settings
- **Version**: v0.1.0
- **Status**: Early development

---

## 2. Tech Stack

- **Engine**: Godot 4.x (GDScript)
- **Language**: GDScript (primary), C# (optional, for performance-critical systems)
- **Networking**: Godot Networking (custom server) or Steamworks (Steam integration)
- **Rendering**: Godot 4.x built-in 3D
- **UI Framework**: Godot UI (Control nodes)
- **Database**: SQLite (local save) + custom backend (cloud save)
- **Audio**: Godot Audio Engine + FMOD (optional for advanced audio)
- **State Management**: Godot Autoload (Singletons)
- **Version Control**: Git
- **Asset Management**: Godot AssetLib, custom asset pipeline
- **Package Manager**: GodotEnv (optional), manual dependency management
- **Deployment**: Godot Export Templates, itch.io, Steam

---

## 3. Commands

```bash
# Development
godot --editor                    # Buka Godot editor
godot --path . --debug-server     # Jalankan dengan debug server
godot --path . --play-main        # Jalankan main scene untuk testing

# Build & Export
godot --export-debug "Windows Desktop" build/windows_debug.exe
godot --export-release "Windows Desktop" build/windows_release.exe
godot --export-release "Linux/X11" build/linux_release
godot --export-release "macOS" build/macos_release

# Project Management
scons platform=windows            # Build C++ modules (jika ada)
python3 build_scripts/version.py  # Update version info

# Testing & Profiling
godot --path . --debug-server     # Network debugging
godot --profile-time              # Profiling tool

# Asset Processing
python3 build_scripts/process_assets.py  # Process sprites, models, audio
python3 build_scripts/pack_assets.py     # Pack assets untuk release

# **Aturan Package Manager**
NEVER use npm, yarn, atau package manager JavaScript untuk project ini.
Godot memiliki dependency management tersendiri.
Jika perlu external dependency, gunakan GodotEnv atau manual management.
```

---

## 4. Project Structure

**Architecture**: Domain-Driven Design with MVC pattern for UI

```
royal-era-kingdom-chronicles/
│
├── src/
│   ├── core/                    # Core game systems
│   │   ├── game_manager.gd      # Main game orchestrator
│   │   ├── event_bus.gd         # Global event system
│   │   ├── state_machine.gd     # Game state management
│   │   └── constants.gd         # Game constants & enums
│   │
│   ├── player/                  # Player & character system
│   │   ├── player.gd            # Player main script
│   │   ├── character_stats.gd   # Stats calculation engine
│   │   ├── inventory.gd         # Inventory management
│   │   ├── equipment.gd         # Gear system
│   │   └── abilities/           # Skills & abilities
│   │       ├── skill_manager.gd
│   │       ├── active_skills.gd
│   │       └── passive_skills.gd
│   │
│   ├── combat/                  # Combat system
│   │   ├── combat_engine.gd     # Core combat logic
│   │   ├── damage_calculator.gd # Damage calculation
│   │   ├── status_effects.gd    # Buffs/debuffs
│   │   └── knockback.gd         # Physics-based knockback
│   │
│   ├── survival/                # Survival mechanics
│   │   ├── hunger_system.gd     # Hunger/food
│   │   ├── thirst_system.gd     # Thirst/drink
│   │   ├── fatigue_system.gd    # Sleep/energy
│   │   └── needs_manager.gd     # Unified needs system
│   │
│   ├── world/                   # World & level management
│   │   ├── level_manager.gd     # Level loading/unloading
│   │   ├── dungeon_generator.gd # Procedural dungeon (optional)
│   │   ├── npc_manager.gd       # NPC spawning & AI
│   │   └── quest_system.gd      # Quest management
│   │
│   ├── enemies/                 # Enemy system
│   │   ├── enemy_base.gd        # Base enemy class
│   │   ├── enemy_ai.gd          # AI behavior tree
│   │   ├── monster_tiers.gd     # Monster rarity/difficulty
│   │   └── boss_ai.gd           # Boss special behavior
│   │
│   ├── multiplayer/             # Co-op networking
│   │   ├── network_manager.gd   # Network orchestration
│   │   ├── player_sync.gd       # Player state sync
│   │   ├── combat_sync.gd       # Combat state sync
│   │   └── lobby_manager.gd     # Lobby & session management
│   │
│   ├── save_system/             # Save & checkpoint system
│   │   ├── save_manager.gd      # Save file handling
│   │   ├── checkpoint.gd        # Checkpoint system
│   │   └── cloud_sync.gd        # Cloud save (optional)
│   │
│   ├── economy/                 # Trading & commerce
│   │   ├── merchant.gd          # NPC merchants
│   │   ├── item_database.gd     # Item definitions
│   │   └── currency_manager.gd  # Gold/currency system
│   │
│   ├── ui/                      # User interface
│   │   ├── main_menu.gd
│   │   ├── hud/
│   │   │   ├── health_bar.gd
│   │   │   ├── status_bar.gd    # Hunger, thirst, fatigue display
│   │   │   ├── skill_bar.gd
│   │   │   └── minimap.gd
│   │   ├── screens/
│   │   │   ├── inventory_screen.gd
│   │   │   ├── character_screen.gd
│   │   │   ├── quest_log.gd
│   │   │   ├── map_screen.gd
│   │   │   └── pause_menu.gd
│   │   └── popups/
│   │       ├── item_popup.gd
│   │       ├── dialogue_popup.gd
│   │       └── loot_popup.gd
│   │
│   └── utils/                   # Utilities
│       ├── logger.gd            # Logging system
│       ├── performance.gd       # Performance monitoring
│       └── helpers.gd           # Helper functions
│
├── assets/
│   ├── models/                  # 3D models
│   │   ├── characters/
│   │   ├── enemies/
│   │   ├── environment/
│   │   └── effects/
│   ├── textures/                # Textures & materials
│   │   ├── characters/
│   │   ├── ui/
│   │   └── environment/
│   ├── sounds/                  # Audio files
│   │   ├── sfx/
│   │   ├── music/
│   │   └── voice/
│   ├── fonts/                   # Custom fonts
│   └── animations/              # Animation files
│
├── scenes/                      # Godot scene files
│   ├── levels/
│   │   ├── kingdom_hub.tscn
│   │   ├── dungeon_01.tscn
│   │   ├── forest_hunting_ground.tscn
│   │   └── enemy_kingdom.tscn
│   ├── ui/
│   │   ├── main_menu.tscn
│   │   ├── hud.tscn
│   │   └── inventory_ui.tscn
│   └── entities/
│       ├── player.tscn
│       ├── enemy.tscn
│       └── boss.tscn
│
├── build_scripts/               # Build & utility scripts
│   ├── process_assets.py
│   ├── pack_assets.py
│   ├── version.py
│   └── changelog.py
│
├── docs/
│   ├── game_design.md          # Game design document
│   ├── combat_balance.md       # Balance spreadsheet
│   ├── quest_design.md         # Quest specifications
│   └── networking_protocol.md  # Network specs
│
├── .godot/                      # Godot generated files (gitignore)
├── build/                       # Export builds (gitignore)
├── .gitignore
├── project.godot                # Godot project config
├── README.md
└── LICENSE

```

**File Placement Rules**:
- **Semua scripts baru** harus di folder `src/` sesuai category-nya
- **Scenes baru** harus di folder `scenes/` dengan struktur yang jelas
- **Assets baru** harus di folder `assets/` berdasarkan tipe asset
- **Jangan pernah** membuat folder baru di root tanpa konfirmasi
- **Jangan pindahkan** file yang sudah ada tanpa konfirmasi

---

## 5. Naming Conventions

```
# File dan Folder
- Script files           : snake_case.gd          contoh: player_stats.gd
- Scene files          : snake_case.tscn        contoh: main_menu.tscn
- Folder              : snake_case             contoh: player/, combat/
- Autoload singleton  : PascalCase.gd          contoh: EventBus.gd, GameManager.gd
- Resource files      : snake_case.tres        contoh: player_stats.tres

# Dalam Kode GDScript
- Variables           : snake_case            contoh: player_health, is_moving
- Constants           : UPPER_SNAKE_CASE      contoh: MAX_PARTY_SIZE, DAMAGE_MODIFIER
- Functions           : snake_case            contoh: take_damage(), calculate_xp()
- Signals             : snake_case            contoh: health_changed, quest_completed
- Enums               : PascalCase            contoh: ItemType, DamageType
- Classes             : PascalCase            contoh: Player, Enemy, CombatEngine
- Private functions   : _snake_case           contoh: _init_skills(), _sync_state()
- Public properties   : snake_case            contoh: var health
- Property getter      : get_snake_case       contoh: func get_max_health()

# Asset Naming
- Character model     : char_[name]_[variant].fbx  contoh: char_knight_male.fbx
- Texture             : tex_[asset]_[type].png    contoh: tex_armor_diffuse.png
- Audio              : sfx_[action]_[variant].ogg contoh: sfx_attack_slash_1.ogg
- Music              : mus_[area].ogg             contoh: mus_kingdom_hub.ogg
- Particle effect    : part_[effect].tres         contoh: part_blood_splash.tres

# Git Branches
- Fitur baru    : feat/[nama-fitur]         contoh: feat/inventory-system
- Bug fix       : fix/[nama-bug]            contoh: fix/combat-damage-sync
- Hotfix        : hotfix/[nama]             contoh: hotfix/crash-on-load
- Refactor      : refactor/[nama]           contoh: refactor/enemy-ai-tree
- Balance       : balance/[sistem]          contoh: balance/monster-difficulty
```

---

## 6. Code Conventions

```
# GDScript Standards
- Gunakan strict typing (type hints untuk semua variables)
- Terapkan prinsip DRY (Don't Repeat Yourself)
- Tulis fungsi yang focused dan single-responsibility
- Avoid deeply nested code, gunakan early returns
- Maksimal 100 baris per fungsi

# Type Hints (WAJIB)
❌ Salah:
func calculate_damage(attacker, defender, skill):
    return attacker_damage * modifier

✅ Benar:
func calculate_damage(attacker: Character, defender: Character, skill: Skill) -> float:
    var base_damage: float = attacker.stats.attack_power
    var modifier: float = defender.calculate_defense()
    return base_damage * modifier

# Signal Definitions
- Definisikan di atas class properties
- Setiap signal harus descriptive
- Emit signal SETELAH state berubah, bukan sebelumnya

signal health_changed(new_health: float, max_health: float)
signal skill_activated(skill_name: String)
signal inventory_updated(item: Item)

# Export Variables
- Gunakan @export untuk variabel yang bisa di-tune di editor
- Group related exports dengan @export_group
- Berikan default values

@export_group("Combat")
@export var attack_power: float = 10.0
@export var attack_speed: float = 1.0

# Error Handling
- Gunakan prinsip "fail fast"
- Validasi input di awal fungsi
- Return nilai default atau null jika operasi gagal
- Jangan silent fail, tulis pesan error yang jelas

func load_item(item_id: String) -> Item:
    if item_id.is_empty():
        push_error("Item ID cannot be empty")
        return null
    
    var item = item_database.get_item(item_id)
    if not item:
        push_error("Item not found: " + item_id)
        return null
    
    return item

# Urutan Deklarasi dalam Satu Script
1. Class name dan documentation
2. Signal definitions
3. Enum definitions  
4. Constants (@export_group dan @export)
5. Properties (var, @onready)
6. Lifecycle methods (_ready, _process, _physics_process)
7. Signal handlers (on_*, _on_*)
8. Public methods
9. Private methods (_method_name)
10. Helper functions

# Networking Considerations (untuk co-op)
- Sinkronisasi state TIDAK harus real-time, bisa tick-based
- Setiap player action harus bisa di-rollback
- Gunakan authority-based system (host decides)
- Cache critical data untuk error recovery
```

---

## 7. Input & Control System

```
# Input Management Architecture

# Keyboard Movement
MOVEMENT (WASD Standard)
- W / UP_ARROW          : Move forward
- A / LEFT_ARROW        : Move left (strafe)
- S / DOWN_ARROW        : Move backward
- D / RIGHT_ARROW       : Move right (strafe)
- SPACE                 : Jump / Dodge Roll (contextual)
- SHIFT                 : Sprint / Run (drain stamina)
- CTRL                  : Crouch / Stealth (reduce visibility)

# Combat & Skills
ACTIVE SKILLS (6 Hotkey Slots)
- 1 / Q                 : Skill slot 1 (highest priority)
- 2 / W                 : Skill slot 2
- 3 / E                 : Skill slot 3
- 4 / R                 : Skill slot 4
- 5 / F                 : Skill slot 5
- 6 / G                 : Skill slot 6 (utility/heal)

ATTACK & INTERACT
- Left Mouse Click      : Basic attack (auto-target nearest enemy)
- Right Mouse Click    : Interact / Loot / Talk to NPC
- Middle Mouse Click   : Lock-on target (toggle)
- Mouse Wheel Up/Down  : Cycle targets

SPECIAL ACTIONS
- SHIFT + Click        : Advanced action (context-dependent)
- CTRL + Click         : Drop/Discard item
- T                    : Toggle auto-attack
- H                    : Call for help (co-op signal)

# Menu & UI
INVENTORY & CHARACTER
- I                    : Toggle Inventory screen
- C                    : Toggle Character sheet (stats, skills)
- E (long-press)       : Equipment management
- A                    : Manage abilities / Skill tree

NAVIGATION & INFO
- L                    : Quest log / Objectives
- M                    : Map (world map, mini-map toggle)
- N                    : NPC interaction menu
- V                    : Voice chat (co-op)

SYSTEM
- P                    : Pause menu / Settings
- ESC                  : Close current menu
- TAB                  : Toggle HUD visibility
- F11                  : Fullscreen toggle
- PrintScreen / F12    : Screenshot

# Input Priority (Execution Order)
1. System inputs (pause, menu)       - Highest priority
2. Combat inputs (skills, attacks)   - High priority
3. UI interactions                   - Medium priority
4. Movement inputs                   - Lower priority (can be queued)
5. Camera inputs                     - Lowest priority

Jika player press multiple keys sekaligus, execute berdasarkan priority order.

# Input Buffering
- Combat inputs: Buffer 0.2 seconds (allow pre-input untuk next attack)
- Movement: Queue up to 3 movement commands
- Skills: Only 1 skill can be "in-flight" at a time

# Camera Controls
Mouse Movement
- Move mouse to rotate camera
- Horizontal (X-axis): Rotate around character (yaw)
- Vertical (Y-axis): Look up/down (pitch)
- Sensitivity adjustable (1-100 scale)

Camera Lock
- Middle Mouse: Lock camera pada target
- Ctrl + Middle Mouse: Free camera rotation
- Scroll While Locked: Zoom in/out

# Gamepad Support (Optional, Full Implementation)
GAMEPAD MAPPING (Xbox/PlayStation Standard Layout)

MOVEMENT (Left Stick)
- Stick Left/Right     : Move strafe
- Stick Up/Down        : Move forward/back
- Press (L3)           : Toggle sprint

CAMERA (Right Stick)
- Stick Left/Right     : Rotate camera
- Stick Up/Down        : Look up/down
- Press (R3)           : Lock-on / Focus target

COMBAT (Face Buttons)
- Y/Triangle           : Skill slot 1
- X/Square             : Skill slot 2
- B/Circle             : Skill slot 3
- A/Cross              : Jump / Dodge

SHOULDERS (Bumpers & Triggers)
- LB / L1              : Skill slot 4
- RB / R1              : Skill slot 5
- LT / L2              : Skill slot 6 (special/heal)
- RT / R2              : Basic attack

MENU (D-Pad & Others)
- D-Pad Up             : Quick heal
- D-Pad Down           : Quick item
- D-Pad Left           : Previous target
- D-Pad Right          : Next target
- Start                : Pause menu
- Back / Select        : Quest log

# Input Handling Best Practices

GDScript Implementation:
func _process(delta):
    # Get input actions (mapped in project settings)
    var input_vector = Input.get_vector("move_left", "move_right", 
                                        "move_forward", "move_backward")
    var is_sprint = Input.is_action_pressed("sprint")
    
    # Process movement
    if input_vector != Vector3.ZERO:
        _handle_movement(input_vector, is_sprint, delta)
    
    # Process skills
    for i in range(1, 7):
        if Input.is_action_just_pressed("skill_slot_%d" % i):
            _activate_skill(i)
    
    # Process interactions
    if Input.is_action_just_pressed("interact"):
        _handle_interaction()

IMPORTANT PRACTICES:
✅ Define semua input actions di project.godot (NOT hardcoded)
✅ Use Input.get_vector() untuk analog input
✅ Use Input.is_action_pressed() untuk continuous input
✅ Use Input.is_action_just_pressed() untuk one-time input
✗ NEVER hardcode KEY_W atau keycode langsung dalam script
✗ NEVER assume mouse is available (support gamepad/alternative)

# Control Remapping

Players dapat remap semua controls di settings menu.

Settings > Controls > Remap Buttons
- Show current binding untuk setiap action
- Click untuk rebind ke key yang berbeda
- Auto-detect input (await player input, bind action)
- Reset to defaults button
- Save profile (allow multiple control profiles)
- Conflict detection (warn jika binding sudah digunakan)
- Accessibility profiles (single-handed, etc)

# Input Responsiveness Requirements

- Input lag: < 50ms (CRITICAL untuk combat accuracy)
- Input buffering: 0.2 second (allow skill combos dan smooth transitions)
- Latency compensation: Untuk co-op (predict movement, interpolate)
- Visual feedback: IMMEDIATE UI response untuk setiap input
- Audio feedback: Key press sounds (optional, dapat di-disable)

# Input-Related Performance

- Input handling: Frame-independent, jangan pakai _process(_delta) untuk input check
- Use _input() untuk event-based inputs (one-time presses)
- Use is_action_pressed() untuk continuous inputs (held keys)
- Limit raycast queries per frame (untuk targeting/interaction checks)
- Cache input states untuk network sync (reduced bandwidth)
- Avoid Input() calls dalam loops, cache hasilnya

# Accessibility Options

ALTERNATIVE INPUTS
- Single-handed mode (semua actions accessible dengan satu tangan)
- Eye-tracking support (optional untuk future)
- Voice commands (optional untuk common actions)
- Custom input profiles untuk special needs

VISUAL FEEDBACK
- Large cursor size option (scale: 0.5x - 3x)
- High contrast mode (untuk visibility)
- Text-to-speech untuk dialogue (optional)
- Colorblind mode (red/green safe palette)
- Subtitle size adjustment (small, medium, large, huge)
- Button label text di-on untuk clarity

MOTOR ACCESSIBILITY
- Adjustable input sensitivity (range: 0.1 - 5.0)
- Hold-to-press mode (tidak perlu rapid clicking)
- Remappable controls (ANY key dapat untuk ANY action)
- Stick/button dead zone customization
- Double-tap prevention (configurable debounce time)
- Input repeat delay adjustment
- Analog stick curve customization

COGNITIVE ACCESSIBILITY
- Simplified HUD option
- Reduced animation clutter
- Clearer quest objectives
- Simplified control schemes
- Option to disable time pressure (quests, mechanics)
```

---

## 8. Co-op Networking System

```
# Party System
- Maximum party size: 5 players
- Minimum party size: 1 player (single-player mode)
- Host decides all rule sets (difficulty, quest selection)
- Drop-in/drop-out support (can join/leave mid-dungeon)

# Authority Model
- Server authority untuk combat calculations
- Client-side prediction untuk movement (smooth gameplay)
- Combat results verified by server before applying
- Inventory changes replicated to all clients

# Synchronization Points
- Player position & rotation: Every 0.1 seconds (100ms)
- Health/status changes: Immediate
- Inventory changes: Immediate
- Skill activations: Immediate (with server validation)
- Enemy AI: Server authority (clients receive movement updates)

# Connection Handling
- Detect disconnection: 5 second timeout
- Auto-save to local before disconnect
- Rejoin support: 30 second window to rejoin
- Notify other players of disconnect with grace period

# Anti-Cheat Measures
- Server validates damage calculations
- Server prevents speed hacking (position validation)
- Server prevents skill spam (cooldown enforcement)
- Server logs suspicious activities for review
```

---

## 9. Combat System Rules

```
# Damage Calculation Formula
damage = (attacker.base_attack + skill.bonus_damage + equipment.bonus) 
         * status_multipliers 
         * (1.0 - defender.defense_reduction)
         * random_variance (0.85 - 1.15)

# Skill System
Active Skills:
  - Max 6 hotkey slots (bound to 1-6 keys)
  - Each has: name, icon, cooldown, mana cost, damage type, effects
  - Cooldown enforced on server
  - Mana cost deducted on skill cast

Passive Skills:
  - Always active, no hotkey needed
  - Can be toggled on/off (but cannot cast while toggled off)
  - Provide stat bonuses and modifiers
  - Cannot be removed mid-combat

# Status Effects
- Can stack, max 20 effects per character
- Each has: name, duration, type (buff/debuff), icon
- Damage-over-time (DoT) effects tick every 0.5 seconds
- Crowd control effects have diminishing returns

# Hit Registration
- Melee attacks: Raycast from weapon to target
- Ranged attacks: Projectile collision
- Area-of-effect: Sphere/cylinder overlap check
- Critical strike: Random 15% chance + bonuses from crit rate stat

# Balance Parameters (see combat_balance.md for details)
- Base damage: Scales with player level and equipment
- Enemy health: Scales with monster tier
- Cooldowns: Range 1-30 seconds
- Mana regeneration: 10 per second by default
```

---

## 10. Survival System Rules

```
# Hunger System
- Decreases 0.5 per second in normal state
- Decreases 1.5 per second during combat or sprinting
- Food item restores: varies by rarity (1-50 hunger points)
- Critical (0 hunger): Movement speed -50%, attack damage -30%
- Max hunger: 100 points

# Thirst System
- Decreases 0.4 per second in normal state
- Decreases 1.2 per second during combat or sprint
- Drink item restores: varies by rarity (1-40 thirst points)
- Critical (0 thirst): Stamina regeneration -50%
- Max thirst: 100 points

# Fatigue System (Sleep)
- Decreases 0.3 per second (only during active gameplay)
- Sleep restores to 100: takes 2-8 minutes depending on location
- Can only sleep at checkpoints or special locations
- Low fatigue (< 25): Reaction time -1 second, hit chance -20%
- Max fatigue: 100 points

# Checkpoint System
- Auto-checkpoint every 5 minutes (can be disabled by host)
- Manual checkpoint at specific locations (beds, camps)
- Checkpoint saves: player position, inventory, quest progress
- Load checkpoint: Full party resets to checkpoint position
- Can carry max 3 checkpoints in memory

# Death & Respawn
- Death at dungeon: Respawn at last checkpoint
- Death at overworld: Respawn at nearest settlement
- Drop items on death: Can recover within 5 minutes
- Death penalty: -10% XP gain for 10 minutes
```

---

## 11. Inventory & Item System

```
# Inventory Rules
- Base slots: 20 items
- Expandable with perks: max 40 slots
- Items can be stacked (max 99 per stack)
- Weight system: carries max 50 kg
- Excess weight: Movement speed -30%, jump height -50%

# Item Categories
1. Weapons     - Damage, attack speed, special effects
2. Armor       - Defense, resistances, bonuses
3. Consumables - Food, drink, potions (use once)
4. Quest Items - Special, cannot be dropped
5. Crafting    - Materials for crafting
6. Accessories - Rings, amulets (passive bonuses)
7. Junk        - Vendor trash, low value

# Item Rarity Tiers
- Common (white)     : Base stats, 100% drop chance
- Uncommon (green)   : +10% bonus, 40% drop chance
- Rare (blue)        : +25% bonus, 15% drop chance
- Epic (purple)      : +50% bonus + 1 special effect, 5% drop chance
- Legendary (orange) : +75% bonus + 2 special effects, 1% drop chance

# Commerce System
- Merchant buys items at 50% of sell price
- Player can sell multiple items at once
- Price scales with item rarity and player level
- Quest items cannot be sold
- Junk items worth base value only

# Equipment System
- Slot-based: Head, Chest, Legs, Feet, Hands, Weapon, Offhand, Accessory (x2)
- Can equip/unequip in-combat (5 second animation)
- Stat bonuses apply immediately when equipped
- Can have max 3 unique legendary items equipped
```

---

## 12. Quest & Progression System

```
# Quest Types
1. Dungeon Raids   - Explore dungeon, defeat boss, return
2. Kingdom Siege   - Assault enemy territory, collect objectives
3. Hunting        - Hunt specific monster types, gather materials
4. Escort         - Protect NPC from point A to B
5. Collection     - Gather specific items
6. Bounty         - Hunt specific named enemies
7. Story          - Main storyline progression

# Quest Difficulty
- Easy: 1-2 stars, recommended level -5 or lower
- Normal: 2-3 stars, recommended level
- Hard: 3-4 stars, recommended level +3
- Impossible: 5 stars, recommended level +10

# Progression System
- Main level: 1-50 (XP-based)
- Character class: Unlocks at level 5, 15, 30
- Skill unlock: Every 5 levels
- New equipment tier: Every 10 levels
- Prestige system: After level 50 (optional)

# XP Calculation
base_xp = enemy_level * 50
party_xp = base_xp / party_size
difficulty_multiplier = 1.0 + (difficulty_level * 0.25)
quest_bonus = 1.5x for quest completion
total_xp = party_xp * difficulty_multiplier * quest_bonus
```

---

## 13. Enemy & Monster System

```
# Monster Tiers (Difficulty Levels)
Tier 1: Common Minions         Level 1-10, 5-50 HP
Tier 2: Elite Monsters         Level 10-20, 50-150 HP
Tier 3: Rare Creatures         Level 20-30, 150-300 HP
Tier 4: Legendary Beasts       Level 30-40, 300-500 HP
Tier 5: Ancient Legends        Level 40-50, 500-1000 HP
Boss:   Unique Boss Encounters Level varies, 1000+ HP

# Monster Variants
- Each tier has 5-10 different monster types
- Variants: normal, enhanced, cursed (increased difficulty)
- Boss monsters: Unique AI patterns, special abilities
- Legendary monsters: Named encounters, story-specific

# Enemy AI Behavior
- Patrol: Walk set path until detecting player
- Pursuit: Chase player within line-of-sight
- Combat: Attack, use abilities, group tactics
- Retreat: Flee when health < 20% (optional)
- Boss AI: Complex patterns, phase transitions

# Loot Tables
- Chance to drop item: 40-80% depending on tier
- Rare loot: 15% extra chance for rare items
- Boss loot: Guaranteed 1 epic or legendary item
- Material drops: 100% chance for crafting materials

# Monster Balance
- Health scales: level * 50 + tier_bonus
- Damage scales: level * 2 + equipment_bonus
- Experience reward: level * 50 * tier_multiplier
- Adjusted per difficulty setting
```

---

## 14. Performance & Optimization

```
# Target Performance
- Target FPS: 60 FPS (minimum 30 FPS on low-end hardware)
- Max active enemies per scene: 20
- Max active players in co-op: 5
- Load time: < 5 seconds for new area
- Memory footprint: < 2GB on 64-bit systems

# Optimization Strategies
- Use LOD (Level of Detail) for distant objects
- Occlusion culling for indoor areas
- Lazy load quest markers and POIs
- Batch render static geometry
- Pool object instances for effects & particles
- Limit draw calls per frame

# Network Optimization
- Use fixed tick rate (60 Hz) for network updates
- Compress position data (quantization)
- Only sync significant state changes
- Prioritize local client prediction
- Implement network jitter smoothing

# Memory Management
- Unload scenes when not needed
- Clear unused asset references
- Implement object pooling for bullets/effects
- Monitor memory with profiler
- Profile heap usage in debug builds
```

---

## 15. Save System

```
# Save File Structure
saves/
  ├── save_slot_1.gdsave
  ├── save_slot_2.gdsave
  └── save_slot_3.gdsave

# Save Data Contents
- Player stats (level, XP, class, skills)
- Equipment and inventory
- World state (quests, checkpoints, cleared dungeons)
- Party composition and member stats
- Play time and session data
- Game settings (difficulty, audio, graphics)

# Save Encryption
- All save files encrypted with AES-256
- Prevent tampering and cheating
- Cloud saves signed with timestamp
- Backup local copy before overwriting

# Checkpoint System
- Auto-save every 5 minutes
- Manual saves at safe locations only
- Keep 3 rotating save slots per character
- Quick load from last checkpoint (Ctrl+L)
- Checkpoint persist through session

# Cloud Save (Optional)
- Sync with cloud every 15 minutes
- Manual upload available
- Conflict resolution: latest timestamp wins
- Works offline, syncs when reconnected
- Delete cloud save: local copy retained
```

---

## 16. Do Not

Instruksi ABSOLUT yang tidak boleh dilanggar:

```
# Struktur & File
✗ Jangan buat folder baru tanpa jelas struktur fungsinya
✗ Jangan pindahkan script tanpa update referensi di scene
✗ Jangan hapus script tanpa backup terlebih dahulu
✗ Jangan ubah project.godot tanpa testing build

# Code
✗ Jangan gunakan magic numbers, selalu define sebagai constant
✗ Jangan hardcode file path, gunakan relative path
✗ Jangan commit file credentials atau secret apapun
✗ Jangan gunakan deprecated Godot functions
✗ Jangan write code tanpa type hints
✗ Jangan silent fail (error harus push_error atau signal)

# Assets
✗ Jangan import asset yang belum di-optimize
✗ Jangan gunakan high-poly model tanpa LOD
✗ Jangan gunakan compressed audio format di-stream (use WAV atau OGG)
✗ Jangan hardcode asset paths dalam script
✗ Jangan buat custom asset tanpa update asset manifest

# Networking
✗ Jangan bypass server authority untuk combat validation
✗ Jangan send unencrypted sensitive data
✗ Jangan hardcode server IP, gunakan config file
✗ Jangan duplicate networking code, centralize di NetworkManager

# Multiplayer-Specific
✗ Jangan assume host connection adalah permanent
✗ Jangan sync non-critical data every frame
✗ Jangan force all 5 players untuk continue (allow drop-out)
✗ Jangan save other player's inventory

# Database
✗ Jangan query database di _process loop
✗ Jangan keep database connections open permanently
✗ Jangan expose database queries to client
✗ Jangan delete production save files without confirmation

# Security
✗ Jangan expose player position untuk other players without consent
✗ Jangan log password atau secret keys
✗ Jangan trust client-side input directly
✗ Jangan allow arbitrarily large inventory expansion
```

---

## 17. Environment Variables & Config

```
# Config Files
config/
  ├── game_settings.cfg      # Game balance and constants
  ├── network_config.cfg     # Server, port, protocol settings
  ├── monster_stats.csv      # Monster tier data
  ├── item_database.json     # Item definitions
  └── skill_database.json    # Skill definitions

# Example: game_settings.cfg
[Network]
server_host = "game.kingdomchronicles.com"
server_port = 29418
max_players = 5
tick_rate = 60

[Game]
max_party_size = 5
difficulty_easy_multiplier = 0.8
difficulty_normal_multiplier = 1.0
difficulty_hard_multiplier = 1.3

[Combat]
max_active_effects = 20
base_respawn_time = 10
critical_strike_chance = 0.15

[Survival]
hunger_tick_rate = 0.5
thirst_tick_rate = 0.4
fatigue_tick_rate = 0.3

# Runtime Configuration (NOT in repo)
Disimpan di user:// path Godot
- Player settings (graphics, audio, controls)
- Cloud credentials (for cloud save)
- Last played server info
- Performance profile data
```

---

## 18. Testing Strategy

```
# Testing Types
- Unit Tests: GDScript function logic (using GUT framework)
- Integration Tests: Systems interaction (combat, inventory, etc)
- Network Tests: Multiplayer sync and lag handling
- Load Tests: Performance under max players/enemies

# Critical Systems to Test
✓ Damage calculation accuracy
✓ Status effect application and removal
✓ Inventory add/remove/stack operations
✓ Skill cooldown enforcement
✓ Network state synchronization
✓ Save/load functionality
✓ Quest progression tracking
✓ Monster tier balance

# Test Framework
- GUT (Godot Unit Test) untuk unit tests
- Manual integration testing untuk multiplayer
- Godot profiler untuk performance tests
- Scene-based tests untuk UI functionality

# Coverage Target
- Minimum 70% code coverage for critical systems
- 100% coverage untuk math/calculation functions
- 80% coverage untuk state management
- Network code tested with simulated lag (100-500ms)
```

---

## 19. Features Checklist

### Core Systems (v0.1)
- [x] Single-player character creation
- [x] Basic combat system (attack, defense, HP)
- [x] Inventory management
- [x] Save system with multiple slots
- [ ] Co-op networking (in progress)
- [ ] Skill system (active + passive)
- [ ] Monster tier system (in progress)

### Gameplay Systems (v0.2)
- [ ] Survival systems (hunger, thirst, fatigue)
- [ ] Checkpoint system
- [ ] Quest system with markers
- [ ] NPC dialogue and interactions
- [ ] Merchant/trading system
- [ ] Equipment and armor system

### Content (v0.3)
- [ ] Kingdom hub area
- [ ] Starter dungeon
- [ ] Forest hunting grounds
- [ ] Enemy kingdom territory
- [ ] Boss encounters (3 unique bosses)
- [ ] 20+ unique monsters across tiers

### Polish (v0.4)
- [ ] Particle effects and visual feedback
- [ ] Sound effects and music
- [ ] UI/UX refinements
- [ ] Balance adjustments
- [ ] Performance optimization
- [ ] Tutorial/onboarding

### Post-Launch
- [ ] Cloud save integration
- [ ] Prestige/New Game+ system
- [ ] Seasonal content
- [ ] PvP arena mode
- [ ] Crafting system
- [ ] Pet/companion system
```

---

## 20. Git Workflow

Setiap kali selesai membuat fitur atau perbaikan:

```bash
# 1. Commit ke branch feature
git add src/path/file.gd scenes/path/scene.tscn
git commit -m "feat: implement inventory drag-and-drop UI"

# 2. Push ke remote
git push origin feat/inventory-system

# 3. Create Pull Request untuk review
# (GitHub/GitLab UI or CLI: gh pr create)

# Commit Message Format
feat(system): description              # Fitur baru
fix(system): description               # Bug fix
refactor(system): description          # Refactor tanpa fitur baru
perf(system): description              # Performance improvement
docs(area): description                # Documentation update
test(system): description              # Tambah/update test

Contoh:
feat(combat): add critical strike system with 15% base chance
fix(networking): resolve player position desync on high ping
refactor(inventory): extract item stack logic into separate class
perf(rendering): implement LOD for monster models
```

---

## 21. Deployment Checklist

Sebelum release:

```
Pre-Release (1 week sebelumnya)
- [ ] Semua features di-test end-to-end
- [ ] Performance profiling done (target 60 FPS)
- [ ] Network stability tested dengan 5 players
- [ ] All critical bugs fixed

Release Day
- [ ] Version number updated
- [ ] Changelog written and committed
- [ ] Build exported untuk semua platform
- [ ] Binaries signed dan notarized (macOS)
- [ ] Upload ke itch.io / Steam
- [ ] Announce di Discord/Twitter
- [ ] Monitor error logs untuk crash reports

Post-Release (24 jam)
- [ ] Patch hotfixes jika ada critical bugs
- [ ] Respond ke player feedback
- [ ] Update documentation
- [ ] Communicate roadmap next steps
```

---

_Dokumen ini adalah source of truth untuk development Royal Era: Kingdom Chronicles. Update berkala seiring project berkembang. Last updated: [auto-update dengan setiap komit mayor]_

