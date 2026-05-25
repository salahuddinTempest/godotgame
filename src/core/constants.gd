extends Node
## Global constants dan enums untuk Royal Era: Kingdom Chronicles.
##
## Autoloaded sebagai singleton. Semua nilai harus di-define di sini,
## tidak boleh ada magic numbers di script lain.

# === Enums ===

enum GameState {
	MAIN_MENU,
	LOADING,
	IN_GAME,
	PAUSED,
	GAME_OVER,
	CUTSCENE,
}

enum ItemType {
	WEAPON,
	ARMOR,
	CONSUMABLE,
	QUEST_ITEM,
	CRAFTING_MATERIAL,
	ACCESSORY,
	JUNK,
}

enum ItemRarity {
	COMMON,    # white  — base stats
	UNCOMMON,  # green  — +10% bonus
	RARE,      # blue   — +25% bonus
	EPIC,      # purple — +50% + 1 special effect
	LEGENDARY, # orange — +75% + 2 special effects
}

enum DamageType {
	PHYSICAL,
	FIRE,
	ICE,
	LIGHTNING,
	DARK,
	HOLY,
	POISON,
	TRUE_DAMAGE, # ignores defense
}

enum EquipmentSlot {
	HEAD,
	CHEST,
	LEGS,
	FEET,
	HANDS,
	WEAPON,
	OFFHAND,
	ACCESSORY_1,
	ACCESSORY_2,
}

enum MonsterTier {
	TIER_1_MINION,    # Level 1-10,  5-50 HP
	TIER_2_ELITE,     # Level 10-20, 50-150 HP
	TIER_3_RARE,      # Level 20-30, 150-300 HP
	TIER_4_LEGENDARY, # Level 30-40, 300-500 HP
	TIER_5_ANCIENT,   # Level 40-50, 500-1000 HP
	BOSS,             # Level varies, 1000+ HP
}

enum EnemyState {
	IDLE,
	PATROL,
	PURSUIT,
	COMBAT,
	RETREAT,
	DEAD,
}

enum QuestType {
	DUNGEON_RAID,
	KINGDOM_SIEGE,
	HUNTING,
	ESCORT,
	COLLECTION,
	BOUNTY,
	STORY,
}

enum QuestDifficulty {
	EASY,    # 1-2 stars
	NORMAL,  # 2-3 stars
	HARD,    # 3-4 stars
	IMPOSSIBLE, # 5 stars
}

enum StatusEffectType {
	BUFF,
	DEBUFF,
	DOT,       # Damage over time
	HOT,       # Heal over time
	CROWD_CONTROL,
}

enum NetworkRole {
	HOST,
	CLIENT,
	NONE,
}

enum CharacterClass {
	ADVENTURER,  # Default (Level 1-4)
	WARRIOR,     # Unlocks Level 5
	MAGE,        # Unlocks Level 5
	RANGER,      # Unlocks Level 5
	ROGUE,       # Unlocks Level 5
	PALADIN,     # Unlocks Level 15
	ARCHMAGE,    # Unlocks Level 15
	ASSASSIN,    # Unlocks Level 15
	BERSERKER,   # Unlocks Level 30
	NECROMANCER, # Unlocks Level 30
}

# === Game Constants ===

const MAX_PARTY_SIZE: int = 5
const MIN_PARTY_SIZE: int = 1
const MAX_PLAYER_LEVEL: int = 50
const MAX_INVENTORY_BASE: int = 20
const MAX_INVENTORY_EXPANDED: int = 40
const MAX_ITEM_STACK: int = 99
const MAX_CARRY_WEIGHT: float = 50.0
const MAX_ACTIVE_STATUS_EFFECTS: int = 20
const MAX_SKILL_HOTKEYS: int = 6
const MAX_CHECKPOINTS: int = 3
const MAX_LEGENDARY_EQUIPPED: int = 3

# === Combat Constants ===

const BASE_CRIT_CHANCE: float = 0.15
const DAMAGE_VARIANCE_MIN: float = 0.85
const DAMAGE_VARIANCE_MAX: float = 1.15
const BASE_MANA_REGEN: float = 10.0  # per second
const INPUT_BUFFER_TIME: float = 0.2  # seconds for combat input buffer
const INPUT_LAG_MAX_MS: int = 50
const SKILL_COOLDOWN_MIN: float = 1.0
const SKILL_COOLDOWN_MAX: float = 30.0

# === Survival Constants ===

const HUNGER_MAX: float = 100.0
const HUNGER_DRAIN_NORMAL: float = 0.5      # per second
const HUNGER_DRAIN_COMBAT: float = 1.5      # per second during combat/sprint
const HUNGER_CRITICAL_THRESHOLD: float = 0.0
const HUNGER_CRITICAL_SPEED_PENALTY: float = 0.5   # -50% speed
const HUNGER_CRITICAL_DAMAGE_PENALTY: float = 0.3  # -30% damage

const THIRST_MAX: float = 100.0
const THIRST_DRAIN_NORMAL: float = 0.4
const THIRST_DRAIN_COMBAT: float = 1.2
const THIRST_CRITICAL_STAMINA_PENALTY: float = 0.5 # -50% stamina regen

const FATIGUE_MAX: float = 100.0
const FATIGUE_DRAIN_NORMAL: float = 0.3
const FATIGUE_LOW_THRESHOLD: float = 25.0
const FATIGUE_REACTION_PENALTY: float = 1.0  # +1 second reaction time
const FATIGUE_HIT_CHANCE_PENALTY: float = 0.2 # -20% hit chance

# === Economy Constants ===

const MERCHANT_BUY_RATE: float = 0.5  # 50% of sell price

# === Network Constants ===

const DEFAULT_SERVER_PORT: int = 29418
const MAX_RECONNECT_WINDOW_SECONDS: int = 30
const DISCONNECT_TIMEOUT_SECONDS: float = 5.0
const POSITION_SYNC_INTERVAL: float = 0.1  # 100ms
const AUTO_SAVE_INTERVAL: float = 300.0    # 5 minutes
const CHECKPOINT_AUTO_INTERVAL: float = 300.0

# === Player Movement Constants ===

const PLAYER_GRAVITY: float = 9.8
const PLAYER_ACCELERATION: float = 10.0
const PLAYER_FRICTION: float = 8.0

# === Camera Constants ===

const THIRD_PERSON_OFFSET: Vector3 = Vector3(0, 3, 4)
const FIRST_PERSON_OFFSET: Vector3 = Vector3(0, 1.6, 0)
const CAMERA_YAW_LIMIT: float = deg_to_rad(70)
const CAMERA_PITCH_LIMIT: float = deg_to_rad(70)

# === XP Formula Constants ===

const XP_BASE_PER_LEVEL: int = 50
const XP_QUEST_COMPLETION_MULTIPLIER: float = 1.5

# === Monster Scaling ===

const MONSTER_HEALTH_PER_LEVEL: int = 50
const MONSTER_DAMAGE_PER_LEVEL: int = 2
const MONSTER_XP_PER_LEVEL: int = 50

# === Item Rarity Drop Chances ===

const DROP_CHANCE_COMMON: float = 1.0
const DROP_CHANCE_UNCOMMON: float = 0.4
const DROP_CHANCE_RARE: float = 0.15
const DROP_CHANCE_EPIC: float = 0.05
const DROP_CHANCE_LEGENDARY: float = 0.01

# === Rarity Stat Bonuses ===

const RARITY_BONUS: Dictionary = {
	ItemRarity.COMMON: 0.0,
	ItemRarity.UNCOMMON: 0.10,
	ItemRarity.RARE: 0.25,
	ItemRarity.EPIC: 0.50,
	ItemRarity.LEGENDARY: 0.75,
}
