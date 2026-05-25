class_name Inventory
extends Resource
## Sistem Inventory untuk Player.
##
## Mengatur slot inventory, stack item, batas berat (weight),
## dan sinkronisasi dengan EventBus.

# === Signals ===
signal item_added(item_id: String, quantity: int)
signal item_removed(item_id: String, quantity: int)
signal slot_updated(index: int, item_id: String, quantity: int)
signal inventory_full()
signal weight_changed(current: float, maximum: float)

# === Classes ===
class InventorySlot:
	var item_id: String = ""
	var quantity: int = 0
	
	func is_empty() -> bool:
		return item_id == "" or quantity <= 0
		
	func clear() -> void:
		item_id = ""
		quantity = 0

# === Public Variables ===
var slots: Array[InventorySlot] = []
var max_slots: int = Constants.MAX_INVENTORY_BASE
var current_weight: float = 0.0
var max_weight: float = Constants.MAX_CARRY_WEIGHT

# === Lifecycle Methods ===

func _init() -> void:
	_initialize_slots(max_slots)

# === Public Methods ===

func add_item(item_id: String, quantity: int = 1) -> int:
	if quantity <= 0:
		return 0
		
	var item_weight: float = _get_item_weight(item_id)
	var total_added: int = 0
	var remaining: int = quantity
	
	# Try to add to existing stacks first
	for i in range(slots.size()):
		if remaining <= 0:
			break
		var slot: InventorySlot = slots[i]
		if slot.item_id == item_id and slot.quantity < Constants.MAX_ITEM_STACK:
			var space_left: int = Constants.MAX_ITEM_STACK - slot.quantity
			var to_add: int = min(remaining, space_left)
			
			# Check weight capacity
			if current_weight + (item_weight * to_add) > max_weight:
				var weight_space: float = max_weight - current_weight
				to_add = min(to_add, int(weight_space / item_weight))
				if to_add <= 0:
					inventory_full.emit()
					break
			
			slot.quantity += to_add
			remaining -= to_add
			total_added += to_add
			current_weight += item_weight * to_add
			slot_updated.emit(i, slot.item_id, slot.quantity)
	
	# Find empty slots for the rest
	if remaining > 0:
		for i in range(slots.size()):
			if remaining <= 0:
				break
			var slot: InventorySlot = slots[i]
			if slot.is_empty():
				var to_add: int = min(remaining, Constants.MAX_ITEM_STACK)
				
				# Check weight capacity
				if current_weight + (item_weight * to_add) > max_weight:
					var weight_space: float = max_weight - current_weight
					to_add = min(to_add, int(weight_space / item_weight))
					if to_add <= 0:
						inventory_full.emit()
						break
				
				slot.item_id = item_id
				slot.quantity = to_add
				remaining -= to_add
				total_added += to_add
				current_weight += item_weight * to_add
				slot_updated.emit(i, slot.item_id, slot.quantity)
				
	if total_added > 0:
		item_added.emit(item_id, total_added)
		weight_changed.emit(current_weight, max_weight)
		
	if remaining > 0 and current_weight + item_weight <= max_weight:
		inventory_full.emit()
		
	return total_added

func remove_item(item_id: String, quantity: int = 1) -> int:
	if quantity <= 0:
		return 0
		
	var item_weight: float = _get_item_weight(item_id)
	var total_removed: int = 0
	var remaining: int = quantity
	
	for i in range(slots.size() - 1, -1, -1):
		if remaining <= 0:
			break
		var slot: InventorySlot = slots[i]
		if slot.item_id == item_id:
			var to_remove: int = min(remaining, slot.quantity)
			slot.quantity -= to_remove
			remaining -= to_remove
			total_removed += to_remove
			current_weight -= item_weight * to_remove
			
			if slot.quantity <= 0:
				slot.clear()
				
			slot_updated.emit(i, slot.item_id, slot.quantity)
			
	if total_removed > 0:
		item_removed.emit(item_id, total_removed)
		weight_changed.emit(current_weight, max_weight)
		
	return total_removed

func has_item(item_id: String, quantity: int = 1) -> bool:
	return get_item_count(item_id) >= quantity

func get_item_count(item_id: String) -> int:
	var count: int = 0
	for slot: InventorySlot in slots:
		if slot.item_id == item_id:
			count += slot.quantity
	return count

func expand_inventory(additional_slots: int) -> void:
	max_slots = min(Constants.MAX_INVENTORY_EXPANDED, max_slots + additional_slots)
	while slots.size() < max_slots:
		slots.append(InventorySlot.new())

func is_overweight() -> bool:
	return current_weight > max_weight

# === Private Methods ===

func _initialize_slots(count: int) -> void:
	slots.clear()
	for i in range(count):
		slots.append(InventorySlot.new())

func _get_item_weight(_item_id: String) -> float:
	# TODO: Connect to item database
	return 1.0
