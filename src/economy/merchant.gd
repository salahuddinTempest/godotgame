class_name Merchant
extends Node3D
## Base class for Merchants in the game.
##
## Manages a specific inventory of items to sell, handles transactions,
## and applies the 50% sell-back rate from Constants.

# === Signals ===
signal trade_opened(merchant_node: Node)
signal transaction_completed(item_id: String, amount: int, is_buying: bool)

# === Exports ===
@export var merchant_name: String = "Merchant"
@export var inventory_stock: Array[String] = [] # List of item_ids this merchant sells

# === Public Variables ===
# Dictionary to hold dynamic stock quantities if needed
var stock_quantities: Dictionary = {} # item_id -> int

# === Lifecycle Methods ===

func _ready() -> void:
	_initialize_stock()

# === Public Methods ===

func interact(player: Player) -> void:
	if not is_instance_valid(player):
		return
	trade_opened.emit(self)
	EventBus.ui_screen_opened.emit("merchant_ui")
	# Normally we'd pass 'self' to a UI manager here

func buy_item_from_merchant(player: Player, item_id: String, quantity: int) -> bool:
	if not _has_stock(item_id, quantity):
		return false
		
	var price: int = ItemDatabase.get_item_price(item_id)
	var total_cost: int = price * quantity
	
	# Assuming player has a 'gold' variable or it's tracked in an EconomySystem
	# For this implementation, let's assume EventBus handles economy or player has gold property
	var player_gold: int = 0
	if "gold" in player:
		player_gold = player.gold
	else:
		# Just mock success for now if player doesn't have gold implemented
		player_gold = 9999
		
	if player_gold < total_cost:
		EventBus.notification_requested.emit("Not enough gold!", 2.0)
		return false
		
	# Deduct gold and add item
	if "gold" in player:
		player.gold -= total_cost
		
	if player.inventory:
		player.inventory.add_item(item_id, quantity)
		
	_reduce_stock(item_id, quantity)
	transaction_completed.emit(item_id, quantity, true)
	EventBus.gold_changed.emit(player.peer_id, player_gold - total_cost, -total_cost)
	
	GameLogger.info("Merchant", "Player bought %dx %s for %d gold" % [quantity, item_id, total_cost])
	return true

func sell_item_to_merchant(player: Player, item_id: String, quantity: int) -> bool:
	if not player.inventory or not player.inventory.has_item(item_id, quantity):
		return false
		
	var base_price: int = ItemDatabase.get_item_price(item_id)
	var sell_price: int = int(base_price * Constants.MERCHANT_BUY_RATE)
	var total_gain: int = sell_price * quantity
	
	# Remove item and add gold
	player.inventory.remove_item(item_id, quantity)
	
	if "gold" in player:
		player.gold += total_gain
		
	# Optionally add to merchant stock
	_add_stock(item_id, quantity)
	
	transaction_completed.emit(item_id, quantity, false)
	EventBus.gold_changed.emit(player.peer_id, player.gold if "gold" in player else 9999, total_gain)
	EventBus.merchant_trade_completed.emit(player.peer_id, item_id, total_gain)
	
	GameLogger.info("Merchant", "Player sold %dx %s for %d gold" % [quantity, item_id, total_gain])
	return true

# === Private Methods ===

func _initialize_stock() -> void:
	for item_id in inventory_stock:
		stock_quantities[item_id] = 10 # Default stock 10

func _has_stock(item_id: String, quantity: int) -> bool:
	return stock_quantities.has(item_id) and stock_quantities[item_id] >= quantity

func _reduce_stock(item_id: String, quantity: int) -> void:
	if stock_quantities.has(item_id):
		stock_quantities[item_id] -= quantity

func _add_stock(item_id: String, quantity: int) -> void:
	if stock_quantities.has(item_id):
		stock_quantities[item_id] += quantity
	else:
		stock_quantities[item_id] = quantity
