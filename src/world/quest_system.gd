class_name QuestSystem
extends Node
## Quest management system.
##
## Tracks active, completed, and failed quests. Validates objectives
## and calculates XP rewards based on CLAUDE.md formulas.

# === Classes ===
class QuestData:
	var id: String
	var title: String
	var type: Constants.QuestType
	var difficulty: Constants.QuestDifficulty
	var state: String = "inactive" # inactive, active, completed, failed
	var objectives: Array[Dictionary] = [] # {description, current, required}
	var recommended_level: int = 1
	var base_xp_reward: int = 100
	var base_gold_reward: int = 50

# === Public Variables ===
var quests: Dictionary = {} # quest_id -> QuestData

# === Lifecycle Methods ===

func _ready() -> void:
	EventBus.entity_killed.connect(_on_entity_killed)
	EventBus.inventory_item_added.connect(_on_item_added)
	
	# Load some mock quests based on game-alur.md
	_register_mock_quests()

# === Public Methods ===

func accept_quest(quest_id: String, player_id: int) -> void:
	if not quests.has(quest_id):
		return
	var q: QuestData = quests[quest_id]
	if q.state != "inactive":
		return
		
	q.state = "active"
	EventBus.quest_accepted.emit(player_id, quest_id)
	GameLogger.info("QuestSystem", "Quest accepted: %s" % q.title)

func update_objective(quest_id: String, objective_idx: int, amount: int, player_id: int) -> void:
	if not quests.has(quest_id):
		return
	var q: QuestData = quests[quest_id]
	if q.state != "active":
		return
		
	if objective_idx < 0 or objective_idx >= q.objectives.size():
		return
		
	var obj: Dictionary = q.objectives[objective_idx]
	obj["current"] = min(obj["required"], obj["current"] + amount)
	
	EventBus.quest_objective_updated.emit(player_id, quest_id, objective_idx, obj["current"])
	
	_check_quest_completion(quest_id, player_id)

func get_active_quests() -> Array[QuestData]:
	var active: Array[QuestData] = []
	for q in quests.values():
		if q.state == "active":
			active.append(q)
	return active

# === Private Methods ===

func _check_quest_completion(quest_id: String, player_id: int) -> void:
	var q: QuestData = quests[quest_id]
	var all_done: bool = true
	
	for obj in q.objectives:
		if obj["current"] < obj["required"]:
			all_done = false
			break
			
	if all_done:
		q.state = "completed"
		# Calculate dynamic XP based on CLAUDE.md
		var difficulty_mult: float = 1.0 + (q.difficulty * 0.25)
		var quest_bonus: float = Constants.XP_QUEST_COMPLETION_MULTIPLIER
		var final_xp: int = int((q.base_xp_reward / max(1, GameManager.get_party_size())) * difficulty_mult * quest_bonus)
		
		EventBus.quest_completed.emit(player_id, quest_id, final_xp, q.base_gold_reward)
		GameLogger.info("QuestSystem", "Quest completed: %s. XP: %d, Gold: %d" % [q.title, final_xp, q.base_gold_reward])

func _on_entity_killed(_killer_id: int, _target_id: int, target_node: Node) -> void:
	# Check if target satisfies any hunt objectives
	pass

func _on_item_added(_player_id: int, _item_id: String, _quantity: int) -> void:
	# Check if item satisfies collection objectives
	pass

func _register_mock_quests() -> void:
	# Arc 1 Quest
	var q1: QuestData = QuestData.new()
	q1.id = "q_arc1_rats"
	q1.title = "Clear Rats in Village Storage"
	q1.type = Constants.QuestType.HUNTING
	q1.difficulty = Constants.QuestDifficulty.EASY
	q1.objectives = [{"description": "Kill giant rats", "current": 0, "required": 5}]
	q1.base_xp_reward = 500
	q1.base_gold_reward = 200
	quests[q1.id] = q1
