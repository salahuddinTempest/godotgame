extends Node
## Global event system untuk Royal Era: Kingdom Chronicles.
##
## Autoloaded singleton. Semua sistem berkomunikasi via signals di sini.
## Prinsip: "Signal up, call down" — child emit, parent connect.
## JANGAN tambahkan logika game di sini, hanya signal definitions.

# === Player Signals ===

signal player_spawned(player_id: int, player_node: Node)
signal player_died(player_id: int)
signal player_respawned(player_id: int, position: Vector3)
signal player_level_up(player_id: int, new_level: int)
signal player_class_changed(player_id: int, new_class: Constants.CharacterClass)
signal player_joined_party(player_id: int)
signal player_left_party(player_id: int)
signal call_for_help_sent(player_id: int, position: Vector3)

# === Combat Signals ===

signal damage_dealt(
	attacker_id: int,
	target_id: int,
	amount: float,
	damage_type: Constants.DamageType,
	is_critical: bool
)
signal entity_killed(killer_id: int, target_id: int, target_node: Node)
signal skill_activated(player_id: int, skill_slot: int, skill_name: String)
signal skill_cooldown_started(player_id: int, skill_slot: int, duration: float)
signal skill_cooldown_finished(player_id: int, skill_slot: int)
signal status_effect_applied(target_id: int, effect_name: String, effect_type: Constants.StatusEffectType)
signal status_effect_removed(target_id: int, effect_name: String)
signal combat_started(player_id: int)
signal combat_ended(player_id: int)

# === Inventory & Economy Signals ===

signal inventory_item_added(player_id: int, item_id: String, quantity: int)
signal inventory_item_removed(player_id: int, item_id: String, quantity: int)
signal inventory_item_used(player_id: int, item_id: String)
signal equipment_changed(player_id: int, slot: Constants.EquipmentSlot, item_id: String)
signal gold_changed(player_id: int, new_amount: int, delta: int)
signal merchant_trade_completed(player_id: int, sold_item_id: String, gold_received: int)
signal loot_dropped(position: Vector3, items: Array)

# === Quest Signals ===

signal quest_accepted(player_id: int, quest_id: String)
signal quest_objective_updated(player_id: int, quest_id: String, objective_index: int, progress: int)
signal quest_completed(player_id: int, quest_id: String, xp_reward: int, gold_reward: int)
signal quest_failed(player_id: int, quest_id: String)
signal xp_gained(player_id: int, amount: int)

# === Survival Signals ===

signal hunger_changed(player_id: int, new_value: float)
signal thirst_changed(player_id: int, new_value: float)
signal fatigue_changed(player_id: int, new_value: float)
signal hunger_critical(player_id: int)
signal thirst_critical(player_id: int)
signal fatigue_critical(player_id: int)
signal survival_penalty_applied(player_id: int, penalty_type: String)
signal survival_penalty_removed(player_id: int, penalty_type: String)

# === World / Level Signals ===

signal level_load_started(level_name: String)
signal level_load_finished(level_name: String)
signal level_unloaded(level_name: String)
signal checkpoint_reached(player_id: int, checkpoint_id: String)
signal checkpoint_saved(slot_index: int)
signal dungeon_cleared(dungeon_id: String)

# === UI Signals ===

signal ui_screen_opened(screen_name: String)
signal ui_screen_closed(screen_name: String)
signal dialogue_started(npc_id: String)
signal dialogue_ended(npc_id: String)
signal notification_requested(message: String, duration: float)
signal hud_visibility_changed(is_visible: bool)

# === Network / Co-op Signals ===

signal server_created(port: int)
signal client_connected(peer_id: int)
signal client_disconnected(peer_id: int, reason: String)
signal lobby_updated(player_count: int)
signal host_migrated(new_host_id: int)
signal reconnect_window_opened(player_id: int)
signal reconnect_window_closed(player_id: int)

# === Game State Signals ===

signal game_state_changed(old_state: Constants.GameState, new_state: Constants.GameState)
signal game_paused()
signal game_resumed()
signal game_over(winning_players: Array[int])
signal save_completed(slot: int)
signal load_completed(slot: int)
signal new_game_plus_started()
