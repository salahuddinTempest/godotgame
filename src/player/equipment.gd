class_name Equipment
extends Resource
## Sistem Equipment untuk Player.
##
## Menangani slot equipment, equip/unequip in-combat delay,
## dan bonus stat dari equipment.

# === Signals ===
signal equipment_changed(slot: Constants.EquipmentSlot, item_id: String)
signal equipment_stats_updated()
signal equip_started(slot: Constants.EquipmentSlot, item_id: String, duration: float)
signal equip_finished(slot: Constants.EquipmentSlot, item_id: String)

# === Classes ===
class EquipmentSlotData:
	var item_id: String = ""
	
	func is_empty() -> bool:
		return item_id == ""
		
	func clear() -> void:
		item_id = ""

# === Public Variables ===
var slots: Dictionary = {} # Constants.EquipmentSlot -> EquipmentSlotData
var is_in_combat: bool = false
var equip_delay_combat: float = 5.0 # seconds

# Bonus stats (recalculated whenever equipment changes)
var total_health_bonus: float = 0.0
var total_attack_bonus: float = 0.0
var total_defense_bonus: float = 0.0
var total_speed_bonus: float = 0.0
var legendary_equipped_count: int = 0

# === Private Variables ===
var _equip_timers: Dictionary = {} # slot -> SceneTreeTimer

# === Lifecycle Methods ===

func _init() -> void:
	for slot in Constants.EquipmentSlot.values():
		slots[slot] = EquipmentSlotData.new()

# === Public Methods ===

func equip_item(slot: Constants.EquipmentSlot, item_id: String, tree: SceneTree) -> bool:
	if not slots.has(slot):
		return false
		
	# Check legendary limit
	if _is_item_legendary(item_id) and legendary_equipped_count >= Constants.MAX_LEGENDARY_EQUIPPED:
		# Need to unequip a legendary first
		var current_item: String = slots[slot].item_id
		if current_item != "" and not _is_item_legendary(current_item):
			GameLogger.warn("Equipment", "Cannot equip more than %d legendary items." % Constants.MAX_LEGENDARY_EQUIPPED)
			return false
	
	if is_in_combat:
		_start_equip_timer(slot, item_id, tree)
	else:
		_apply_equipment(slot, item_id)
		
	return true

func unequip_item(slot: Constants.EquipmentSlot, tree: SceneTree) -> String:
	if not slots.has(slot) or slots[slot].is_empty():
		return ""
		
	var item_id: String = slots[slot].item_id
	
	if is_in_combat:
		_start_equip_timer(slot, "", tree)
		return item_id # Optimistically returning what WILL be unequipped, though technically it's delayed
	else:
		_apply_equipment(slot, "")
		return item_id

func get_equipped_item(slot: Constants.EquipmentSlot) -> String:
	if slots.has(slot):
		return slots[slot].item_id
	return ""

func set_combat_state(in_combat: bool) -> void:
	is_in_combat = in_combat
	if not is_in_combat:
		# If we leave combat, finish all pending equips immediately
		for slot: Constants.EquipmentSlot in _equip_timers.keys():
			var timer: SceneTreeTimer = _equip_timers[slot]["timer"]
			var pending_item: String = _equip_timers[slot]["item"]
			if is_instance_valid(timer):
				timer.time_left = 0.0 # Force timeout
			_apply_equipment(slot, pending_item)
		_equip_timers.clear()

# === Private Methods ===

func _start_equip_timer(slot: Constants.EquipmentSlot, item_id: String, tree: SceneTree) -> void:
	if _equip_timers.has(slot):
		# Cancel existing timer
		pass
		
	equip_started.emit(slot, item_id, equip_delay_combat)
	var timer: SceneTreeTimer = tree.create_timer(equip_delay_combat)
	_equip_timers[slot] = {"timer": timer, "item": item_id}
	
	timer.timeout.connect(func() -> void:
		if _equip_timers.has(slot) and _equip_timers[slot]["timer"] == timer:
			_apply_equipment(slot, item_id)
			_equip_timers.erase(slot)
	)

func _apply_equipment(slot: Constants.EquipmentSlot, item_id: String) -> void:
	var old_item: String = slots[slot].item_id
	slots[slot].item_id = item_id
	
	_recalculate_stats()
	
	equip_finished.emit(slot, item_id)
	equipment_changed.emit(slot, item_id)
	
	GameLogger.info("Equipment", "Equipped %s to slot %s" % [item_id if item_id != "" else "Nothing", Constants.EquipmentSlot.keys()[slot]])

func _recalculate_stats() -> void:
	total_health_bonus = 0.0
	total_attack_bonus = 0.0
	total_defense_bonus = 0.0
	total_speed_bonus = 0.0
	legendary_equipped_count = 0
	
	for slot: Constants.EquipmentSlot in slots:
		var item_id: String = slots[slot].item_id
		if item_id == "":
			continue
			
		# TODO: Pull actual stats from ItemDatabase
		# Mock logic for now based on CLAUDE.md requirements
		if _is_item_legendary(item_id):
			legendary_equipped_count += 1
			
		total_attack_bonus += 5.0 # Mock value
		total_defense_bonus += 2.0 # Mock value
		
	equipment_stats_updated.emit()

func _is_item_legendary(_item_id: String) -> bool:
	# TODO: Connect to ItemDatabase
	return false
