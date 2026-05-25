class_name InventoryUI
extends Control
## Inventory and Equipment UI.
##
## Maps Inventory slots and Equipment slots to UI grids.

# === Exports ===
@export var player_inventory: Inventory
@export var player_equipment: Equipment

# === Onready ===
@onready var grid: GridContainer = $GridContainer if has_node("GridContainer") else null
@onready var weight_label: Label = $WeightLabel if has_node("WeightLabel") else null

# === Lifecycle Methods ===

func _ready() -> void:
	if not player_inventory:
		return
		
	player_inventory.slot_updated.connect(_on_slot_updated)
	player_inventory.weight_changed.connect(_on_weight_changed)
	
	# Initial populate
	_populate_grid()

# === Private Methods ===

func _populate_grid() -> void:
	if not grid: return
	
	for i in range(player_inventory.slots.size()):
		var slot = player_inventory.slots[i]
		# Assuming we have child nodes for each slot in the grid
		if i < grid.get_child_count():
			var ui_slot = grid.get_child(i)
			if ui_slot.has_method("update_visuals"):
				ui_slot.update_visuals(slot.item_id, slot.quantity)

func _on_slot_updated(index: int, item_id: String, quantity: int) -> void:
	if grid and index < grid.get_child_count():
		var ui_slot = grid.get_child(index)
		if ui_slot.has_method("update_visuals"):
			ui_slot.update_visuals(item_id, quantity)

func _on_weight_changed(current: float, maximum: float) -> void:
	if weight_label:
		weight_label.text = "Weight: %.1f / %.1f" % [current, maximum]
		if current > maximum:
			weight_label.modulate = Color.RED
		else:
			weight_label.modulate = Color.WHITE
