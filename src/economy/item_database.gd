class_name ItemDatabase
extends Node
## Global Database for all items in the game.
##
## Autoloaded Singleton providing item lookups.

# === Public Variables ===
static var items: Dictionary = {}

# === Lifecycle Methods ===

func _ready() -> void:
	_load_database()

# === Public Methods ===

static func get_item(item_id: String) -> Dictionary:
	return items.get(item_id, {})

static func get_item_price(item_id: String) -> int:
	var item: Dictionary = get_item(item_id)
	return item.get("base_price", 0)

static func get_item_weight(item_id: String) -> float:
	var item: Dictionary = get_item(item_id)
	return item.get("weight", 0.0)

# === Private Methods ===

func _load_database() -> void:
	items = {
		"health_potion": {
			"name": "Health Potion",
			"type": Constants.ItemType.CONSUMABLE,
			"rarity": Constants.ItemRarity.COMMON,
			"base_price": 50,
			"weight": 0.5,
			"heal_amount": 50.0
		},
		"iron_sword": {
			"name": "Iron Sword",
			"type": Constants.ItemType.WEAPON,
			"rarity": Constants.ItemRarity.COMMON,
			"base_price": 150,
			"weight": 5.0,
			"attack_bonus": 10.0
		},
		"apple": {
			"name": "Apple",
			"type": Constants.ItemType.CONSUMABLE,
			"rarity": Constants.ItemRarity.COMMON,
			"base_price": 10,
			"weight": 0.2,
			"hunger_restore": 10.0
		}
	}
	GameLogger.info("ItemDatabase", "Loaded %d items." % items.size())
