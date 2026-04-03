extends CanvasLayer

@export var player: Node
@export var stats: Resource
@export var show_interaction: bool = false
@export var interaction_text: String = ""

var _medicine_system: Node
var _buff_nodes: Dictionary = {}
var _medicine_slots: Array[Control] = []

@onready var _health_bar: Control = $MarginContainer/RootVBox/StatsPanel/StatsVBox/HealthBar
@onready var _realm_label: Label = $MarginContainer/RootVBox/StatsPanel/StatsVBox/RealmLabel
@onready var _buff_list: HBoxContainer = $MarginContainer/RootVBox/BuffList
@onready var _medicine_hotbar: GridContainer = $MarginContainer/RootVBox/MedicinePanel/MedicineVBox/MedicineHotbar
@onready var _interaction_prompt: Label = $InteractionPrompt


func _ready() -> void:
	_cache_medicine_slots()
	_resolve_player_and_stats()
	_resolve_medicine_system()
	_connect_stats_signals()
	_connect_medicine_signals()
	_refresh_all()


func _process(_delta: float) -> void:
	if stats != null and is_instance_valid(stats):
		update_health(stats.current_health, stats.max_health)
		update_realm(stats.current_realm)

	_interaction_prompt.visible = show_interaction
	_interaction_prompt.text = interaction_text


func update_health(current: int, max: int) -> void:
	if _health_bar != null and _health_bar.has_method("set_health"):
		_health_bar.call("set_health", current, max)


func update_realm(realm_name: String) -> void:
	if _realm_label != null and _realm_label.has_method("set_realm"):
		_realm_label.call("set_realm", realm_name)
	else:
		_realm_label.text = "境界  " + realm_name


func show_buff(buff_type: String, duration: float) -> void:
	var buff_label: Label = _buff_nodes.get(buff_type)
	if buff_label == null:
		buff_label = Label.new()
		buff_label.name = buff_type
		buff_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		buff_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		buff_label.custom_minimum_size = Vector2(120.0, 32.0)
		buff_label.add_theme_font_size_override("font_size", 14)
		buff_label.add_theme_color_override("font_color", Color(0.98, 0.95, 0.80, 1.0))
		_buff_list.add_child(buff_label)
		_buff_nodes[buff_type] = buff_label

	buff_label.text = "%s  %.1fs" % [_format_buff_name(buff_type), maxf(duration, 0.0)]
	buff_label.tooltip_text = buff_type
	buff_label.visible = true


func hide_buff(buff_type: String) -> void:
	var buff_label: Label = _buff_nodes.get(buff_type)
	if buff_label == null:
		return

	buff_label.queue_free()
	_buff_nodes.erase(buff_type)


func show_interaction_prompt(text: String) -> void:
	show_interaction = true
	interaction_text = text
	_interaction_prompt.visible = true
	_interaction_prompt.text = text


func hide_interaction_prompt() -> void:
	show_interaction = false
	interaction_text = ""
	_interaction_prompt.visible = false


func update_medicine_slot(index: int, item_id: String, quantity: int) -> void:
	if index < 0 or index >= _medicine_slots.size():
		return

	var slot: Control = _medicine_slots[index]
	var name_label := slot.get_node("SlotVBox/ItemName") as Label
	var qty_label := slot.get_node("SlotVBox/Quantity") as Label

	if item_id.is_empty() or quantity <= 0:
		name_label.text = "空位"
		qty_label.text = "x0"
		slot.tooltip_text = "未装配丹药"
		return

	name_label.text = _format_item_name(item_id)
	qty_label.text = "x%d" % quantity
	slot.tooltip_text = item_id


func _on_health_changed(new_health: int) -> void:
	if stats == null:
		return

	update_health(new_health, stats.max_health)


func _on_player_died() -> void:
	update_health(0, stats.max_health if stats != null else 1)
	show_interaction_prompt("元神受创，按 R 重整气息")


func _on_item_used(item_id: String, success: bool) -> void:
	if not success:
		return

	_refresh_medicine_hotbar()

	var item_name: String = _format_item_name(item_id)
	show_interaction_prompt("已服用 %s" % item_name)


func _cache_medicine_slots() -> void:
	_medicine_slots.clear()
	for child in _medicine_hotbar.get_children():
		if child is Control:
			_medicine_slots.append(child)


func _resolve_player_and_stats() -> void:
	if player == null or not is_instance_valid(player):
		player = _find_player()

	if (stats == null or not is_instance_valid(stats)) and player != null and "stats" in player:
		var stats_variant: Resource = player.get("stats")
		if stats_variant != null:
			stats = stats_variant


func _resolve_medicine_system() -> void:
	if _medicine_system != null and is_instance_valid(_medicine_system):
		return

	var tree := get_tree()
	var root: Node = null
	if tree != null:
		root = tree.current_scene if tree.current_scene != null else tree.root

	_medicine_system = _find_medicine_system(root)
	if _medicine_system != null and stats != null:
		_medicine_system.set_player_stats(stats)


func _connect_stats_signals() -> void:
	if stats == null or not is_instance_valid(stats):
		return

	if not stats.health_changed.is_connected(_on_health_changed):
		stats.health_changed.connect(_on_health_changed)

	if not stats.died.is_connected(_on_player_died):
		stats.died.connect(_on_player_died)


func _connect_medicine_signals() -> void:
	if _medicine_system == null or not is_instance_valid(_medicine_system):
		return

	if not _medicine_system.buff_applied.is_connected(show_buff):
		_medicine_system.buff_applied.connect(show_buff)

	if not _medicine_system.buff_expired.is_connected(hide_buff):
		_medicine_system.buff_expired.connect(hide_buff)

	if not _medicine_system.item_used.is_connected(_on_item_used):
		_medicine_system.item_used.connect(_on_item_used)


func _refresh_all() -> void:
	if stats != null and is_instance_valid(stats):
		update_health(stats.current_health, stats.max_health)
		update_realm(stats.current_realm)

	if show_interaction:
		show_interaction_prompt(interaction_text)
	else:
		hide_interaction_prompt()

	_refresh_medicine_hotbar()


func _refresh_medicine_hotbar() -> void:
	for slot_index in _medicine_slots.size():
		update_medicine_slot(slot_index, "", 0)

	if _medicine_system == null or not is_instance_valid(_medicine_system):
		return

	var item_ids: Array = []
	for key in _medicine_system.inventory.keys():
		item_ids.append(key)
	item_ids.sort()
	item_ids.sort()

	var max_slots_to_fill: int = mini(5, item_ids.size())
	for index in max_slots_to_fill:
		var item_id: String = item_ids[index]
		var item = _medicine_system.get_item(item_id)
		var quantity: int = item.quantity if item != null else 0
		update_medicine_slot(index, item_id, quantity)


func _find_player() -> Node:
	var tree := get_tree()
	if tree == null:
		return null

	var players: Array[Node] = tree.get_nodes_in_group("player")
	for candidate in players:
		if is_instance_valid(candidate):
			return candidate

	return _find_node_by_script_name(tree.current_scene, "Player")


func _find_medicine_system(node: Node) -> Node:
	if node == null:
		return null

	var script: Script = node.get_script()
	if script != null and script.get_global_name() == &"MedicineSystem":
		return node

	for child in node.get_children():
		var result: Node = _find_medicine_system(child)
		if result != null:
			return result

	return null


func _find_node_by_script_name(node: Node, script_name: String) -> Node:
	if node == null:
		return null

	var script: Script = node.get_script()
	if script != null and String(script.get_global_name()) == script_name:
		return node

	for child in node.get_children():
		var result: Node = _find_node_by_script_name(child, script_name)
		if result != null:
			return result

	return null


func _format_item_name(item_id: String) -> String:
	var parts: PackedStringArray = item_id.split("_")
	var readable_parts: Array[String] = []
	for part in parts:
		readable_parts.append(part.capitalize())
	return " ".join(readable_parts)


func _format_buff_name(buff_type: String) -> String:
	return _format_item_name(buff_type)
