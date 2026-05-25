class_name HUD
extends Control
## Heads-up Display script.
##
## Listens to EventBus for HP, Mana, Stamina, Hunger, Thirst, Fatigue changes.

# === Onready ===
@onready var hp_bar: ProgressBar = $VBox/HPBar if has_node("VBox/HPBar") else null
@onready var mana_bar: ProgressBar = $VBox/ManaBar if has_node("VBox/ManaBar") else null
@onready var stamina_bar: ProgressBar = $VBox/StaminaBar if has_node("VBox/StaminaBar") else null
@onready var action_text: Label = $ActionText if has_node("ActionText") else null

# === Lifecycle Methods ===

func _ready() -> void:
	EventBus.hud_visibility_changed.connect(_on_visibility_changed)
	EventBus.notification_requested.connect(_on_notification)
	
	# Need a way to connect to local player's specific stats
	# We'll assume the Player node emits these globally via EventBus, or HUD finds local player

# === Private Methods ===

func update_stats(hp_pct: float, mana_pct: float, stam_pct: float) -> void:
	if hp_bar: hp_bar.value = hp_pct * 100
	if mana_bar: mana_bar.value = mana_pct * 100
	if stamina_bar: stamina_bar.value = stam_pct * 100

func _on_visibility_changed(is_vis: bool) -> void:
	visible = is_vis

func _on_notification(msg: String, duration: float) -> void:
	if action_text:
		action_text.text = msg
		action_text.visible = true
		
		var t = get_tree().create_timer(duration)
		t.timeout.connect(func():
			if action_text.text == msg:
				action_text.visible = false
		)
