class_name DialogueBox
extends Control
## Dialogue UI system.
##
## Reads from a dialogue database or simple strings and displays text
## with a typewriter effect.

# === Exports ===
@export var type_speed: float = 0.05

# === Onready ===
@onready var text_label: Label = $TextLabel if has_node("TextLabel") else null
@onready var name_label: Label = $NameLabel if has_node("NameLabel") else null
@onready var next_indicator: Control = $NextIndicator if has_node("NextIndicator") else null

# === Private Variables ===
var _current_text: String = ""
var _is_typing: bool = false
var _char_index: int = 0
var _timer: float = 0.0

# === Lifecycle Methods ===

func _ready() -> void:
	EventBus.dialogue_started.connect(_on_dialogue_started)
	EventBus.dialogue_ended.connect(_on_dialogue_ended)
	visible = false

func _process(delta: float) -> void:
	if _is_typing:
		_timer += delta
		if _timer >= type_speed:
			_timer = 0.0
			_char_index += 1
			if _char_index <= _current_text.length():
				text_label.text = _current_text.substr(0, _char_index)
			else:
				_is_typing = false
				if next_indicator:
					next_indicator.visible = true

func _input(event: InputEvent) -> void:
	if not visible:
		return
		
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		if _is_typing:
			# Skip typing
			_is_typing = false
			text_label.text = _current_text
			if next_indicator:
				next_indicator.visible = true
		else:
			# Next line or close
			_advance_dialogue()
			
		get_viewport().set_input_as_handled()

# === Public Methods ===

func show_dialogue(npc_name: String, text: String) -> void:
	visible = true
	if name_label: name_label.text = npc_name
	_current_text = text
	_char_index = 0
	_is_typing = true
	if next_indicator: next_indicator.visible = false
	text_label.text = ""
	
	# Freeze player movement or game state if desired
	# e.g., GameManager.change_state(Constants.GameState.CUTSCENE)

# === Private Methods ===

func _advance_dialogue() -> void:
	# Check if there are more lines
	# If no more lines:
	visible = false
	EventBus.dialogue_ended.emit(name_label.text if name_label else "")

func _on_dialogue_started(npc_id: String) -> void:
	# Fetch actual text from a database or dialogue tree
	show_dialogue(npc_id, "Greetings, traveler! (Placeholder Dialogue)")

func _on_dialogue_ended(_npc_id: String) -> void:
	pass
