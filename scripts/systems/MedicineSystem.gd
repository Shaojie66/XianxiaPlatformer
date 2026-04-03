extends Node
class_name MedicineSystem

signal item_used(item_id: String, success: bool)
signal item_added(item_id: String, quantity: int)
signal item_removed(item_id: String)
signal buff_applied(buff_type: String, duration: float)
signal buff_expired(buff_type: String)

const TELEPORT_DISTANCE: float = 160.0
const DEFAULT_MAX_QUANTITY: int = 99

@export var max_slots: int = 10
@export var global_cooldown: float = 0.5

var inventory: Dictionary = {}

var _global_cooldown_remaining: float = 0.0
var _active_buffs: Dictionary = {}


func _ready() -> void:
	set_process(true)
	add_to_group("medicine_system")


func _process(delta: float) -> void:
	if _global_cooldown_remaining > 0.0:
		_global_cooldown_remaining = maxf(_global_cooldown_remaining - delta, 0.0)

	for item_id in inventory.keys():
		var item: MedicineItem = inventory[item_id]
		if item != null:
			item.process_cooldown(delta)

	_process_buffs(delta)


func add_item(item_id: String, quantity: int = 1) -> void:
	if quantity <= 0:
		return

	var item := get_item(item_id)
	if item == null:
		if inventory.size() >= max_slots:
			push_warning("MedicineSystem inventory is full. Could not add item: %s" % item_id)
			return

		item = _create_default_item(item_id)
		if item == null:
			push_warning("MedicineSystem does not recognize item id: %s" % item_id)
			return

		inventory[item_id] = item

	var previous_quantity: int = item.quantity
	item.quantity = mini(item.quantity + quantity, item.max_quantity)

	var added_quantity: int = item.quantity - previous_quantity
	if added_quantity > 0:
		item_added.emit(item_id, added_quantity)


func remove_item(item_id: String, quantity: int = 1) -> void:
	if quantity <= 0:
		return

	var item := get_item(item_id)
	if item == null:
		return

	item.quantity = maxi(item.quantity - quantity, 0)
	if item.quantity <= 0:
		inventory.erase(item_id)
		item_removed.emit(item_id)


func use_item(item_id: String) -> bool:
	var item := get_item(item_id)
	if item == null:
		item_used.emit(item_id, false)
		return false

	if _global_cooldown_remaining > 0.0 or not item.can_use():
		item_used.emit(item_id, false)
		return false

	if not item.use():
		item_used.emit(item_id, false)
		return false

	_global_cooldown_remaining = maxf(global_cooldown, item.cooldown)

	var success: bool = _apply_item_effect(item_id, item)

	if item.quantity <= 0:
		inventory.erase(item_id)
		item_removed.emit(item_id)

	item_used.emit(item_id, success)
	return success


func get_item(item_id: String) -> MedicineItem:
	return inventory.get(item_id)


func has_item(item_id: String) -> bool:
	var item := get_item(item_id)
	return item != null and item.quantity > 0


func is_buff_active(buff_type: String) -> bool:
	return _active_buffs.has(buff_type)


func set_player_stats(stats: PlayerStats) -> void:
	if stats == null:
		return

	if is_instance_valid(stats):
		set_meta("player_stats_ref", stats)


func _apply_item_effect(item_id: String, item: MedicineItem) -> bool:
	match item.effect_type:
		MedicineItem.EffectType.HEAL:
			return _apply_heal(item)
		MedicineItem.EffectType.BUFF_ATTACK:
			return _apply_stat_buff("attack_buff", "attack", item.effect_value, item.duration)
		MedicineItem.EffectType.BUFF_DEFENSE:
			return _apply_stat_buff("defense_buff", "defense", item.effect_value, item.duration)
		MedicineItem.EffectType.TELEPORT:
			return _apply_teleport()
		MedicineItem.EffectType.UNLOCK_PUZZLE:
			var unlock_duration: float = item.duration if item.duration > 0.0 else 5.0
			return _apply_puzzle_unlock(unlock_duration)
		_:
			push_warning("MedicineSystem has no handler for item: %s" % item_id)
			return false


func _apply_heal(item: MedicineItem) -> bool:
	var stats := _resolve_player_stats()
	if stats == null:
		return false

	var heal_ratio: float = float(item.effect_value) / 100.0
	var heal_amount: int = maxi(1, int(round(float(stats.max_health) * heal_ratio)))
	stats.heal(heal_amount)
	return true


func _apply_stat_buff(buff_type: String, stat_name: String, percent_bonus: int, duration: float) -> bool:
	var stats := _resolve_player_stats()
	if stats == null:
		return false

	if is_buff_active(buff_type):
		_clear_buff(buff_type, false)

	var current_value: int = int(stats.get(stat_name))
	var bonus_amount: int = maxi(1, int(round(float(current_value) * (float(percent_bonus) / 100.0))))
	stats.set(stat_name, current_value + bonus_amount)

	_active_buffs[buff_type] = {
		"remaining": maxf(duration, 0.0),
		"stat_name": stat_name,
		"bonus_amount": bonus_amount,
	}

	buff_applied.emit(buff_type, duration)
	return true


func _apply_teleport() -> bool:
	var player := _find_player()
	if player == null:
		return false

	var direction: float = 1.0
	if "facing_direction" in player:
		var facing_value: float = float(player.get("facing_direction"))
		if facing_value < 0.0:
			direction = -1.0
		elif facing_value > 0.0:
			direction = 1.0

	player.global_position.x += TELEPORT_DISTANCE * direction
	return true


func _apply_puzzle_unlock(duration: float) -> bool:
	if is_buff_active("unlock_puzzle"):
		_clear_buff("unlock_puzzle", false)

	_set_puzzle_unlock_state(true)
	_active_buffs["unlock_puzzle"] = {
		"remaining": maxf(duration, 0.0),
	}

	buff_applied.emit("unlock_puzzle", duration)
	return true


func _process_buffs(delta: float) -> void:
	var expired_buffs: Array[String] = []

	for buff_type in _active_buffs.keys():
		var buff_data: Dictionary = _active_buffs[buff_type]
		var remaining: float = float(buff_data.get("remaining", 0.0))
		remaining = maxf(remaining - delta, 0.0)
		buff_data["remaining"] = remaining
		_active_buffs[buff_type] = buff_data

		if remaining <= 0.0:
			expired_buffs.append(buff_type)

	for buff_type in expired_buffs:
		_clear_buff(buff_type, true)


func _clear_buff(buff_type: String, notify_expired: bool = true) -> void:
	if not _active_buffs.has(buff_type):
		return

	var buff_data: Dictionary = _active_buffs[buff_type]

	if buff_data.has("stat_name"):
		var stats := _resolve_player_stats()
		if stats != null:
			var stat_name: String = String(buff_data.get("stat_name", ""))
			var bonus_amount: int = int(buff_data.get("bonus_amount", 0))
			if not stat_name.is_empty():
				var current_value: int = int(stats.get(stat_name))
				stats.set(stat_name, maxi(current_value - bonus_amount, 0))

	if buff_type == "unlock_puzzle":
		_set_puzzle_unlock_state(false)

	_active_buffs.erase(buff_type)

	if notify_expired:
		buff_expired.emit(buff_type)


func _set_puzzle_unlock_state(enabled: bool) -> void:
	var tree := get_tree()
	if tree == null:
		return

	var current_scene := tree.current_scene
	if current_scene != null:
		current_scene.set_meta("puzzle_unlock_active", enabled)

	for node in tree.get_nodes_in_group("puzzle"):
		node.set_meta("puzzle_unlock_active", enabled)

		if node.has_method("set_temporary_unlock"):
			node.call("set_temporary_unlock", enabled)
		elif node.has_method("unlock_temporarily"):
			node.call("unlock_temporarily", enabled)


func _resolve_player_stats() -> PlayerStats:
	if has_meta("player_stats_ref"):
		var stats_ref: Variant = get_meta("player_stats_ref")
		if stats_ref is PlayerStats and is_instance_valid(stats_ref):
			return stats_ref

	var player := _find_player()
	if player == null:
		return null

	if "stats" in player:
		var stats_variant: Variant = player.get("stats")
		if stats_variant is PlayerStats and is_instance_valid(stats_variant):
			set_meta("player_stats_ref", stats_variant)
			return stats_variant

	return null


func _find_player() -> Node2D:
	var tree := get_tree()
	if tree == null:
		return null

	var players: Array[Node] = tree.get_nodes_in_group("player")
	for node in players:
		if node is Node2D and is_instance_valid(node):
			return node as Node2D

	if tree.current_scene == null:
		return null

	return _find_first_player_node(tree.current_scene)


func _find_first_player_node(node: Node) -> Node2D:
	if node is Node2D:
		var script: Script = node.get_script()
		if script != null and script.get_global_name() == &"Player":
			return node as Node2D

	for child in node.get_children():
		var result := _find_first_player_node(child)
		if result != null:
			return result

	return null


func _create_default_item(item_id: String) -> MedicineItem:
	var item := MedicineItem.new()
	item.max_quantity = DEFAULT_MAX_QUANTITY
	item.quantity = 0

	match item_id:
		"health_pill":
			item.item_name = "回血丹"
			item.description = "恢复最大生命值的 30%。"
			item.effect_type = MedicineItem.EffectType.HEAL
			item.effect_value = 30
			item.duration = 0.0
			item.cooldown = 0.5
			item.icon_path = "res://assets/ui/items/health_pill.png"
		"attack_buff":
			item.item_name = "攻击丹"
			item.description = "10 秒内攻击提升 50%。"
			item.effect_type = MedicineItem.EffectType.BUFF_ATTACK
			item.effect_value = 50
			item.duration = 10.0
			item.cooldown = 0.5
			item.icon_path = "res://assets/ui/items/attack_buff.png"
		"defense_buff":
			item.item_name = "防御丹"
			item.description = "10 秒内防御提升 50%。"
			item.effect_type = MedicineItem.EffectType.BUFF_DEFENSE
			item.effect_value = 50
			item.duration = 10.0
			item.cooldown = 0.5
			item.icon_path = "res://assets/ui/items/defense_buff.png"
		"teleport_pill":
			item.item_name = "瞬移丹"
			item.description = "朝当前朝向短距离瞬移。"
			item.effect_type = MedicineItem.EffectType.TELEPORT
			item.effect_value = 0
			item.duration = 0.0
			item.cooldown = 0.5
			item.icon_path = "res://assets/ui/items/teleport_pill.png"
		"puzzle_unlock":
			item.item_name = "解谜丹"
			item.description = "5 秒内临时解锁谜题机关。"
			item.effect_type = MedicineItem.EffectType.UNLOCK_PUZZLE
			item.effect_value = 0
			item.duration = 5.0
			item.cooldown = 0.5
			item.icon_path = "res://assets/ui/items/puzzle_unlock.png"
		_:
			return null

	return item
