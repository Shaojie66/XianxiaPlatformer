extends Area2D
class_name LevelTransition

## 关卡切换系统
## 触发条件：玩家进入终点区域 或 所有敌人被击败

signal level_completed

@export var next_level_path: String = "res://scenes/levels/Level2_Zhuji.tscn"
@export var enemy_group_name: String = "enemy"
@export var require_all_enemies_dead: bool = true

var _player_inside: bool = false
var _all_enemies_dead: bool = false
var _transition_triggered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# 监听所有敌人死亡信号
	var tree := get_tree()
	if tree != null:
		tree.node_added.connect(_on_node_added)
		_update_enemy_death_listeners()


func _on_node_added(node: Node) -> void:
	if node.is_in_group(enemy_group_name):
		if node.has_signal("died"):
			node.died.connect(_on_enemy_died.bind(node))


func _update_enemy_death_listeners() -> void:
	var tree := get_tree()
	if tree == null:
		return

	for enemy in tree.get_nodes_in_group(enemy_group_name):
		if enemy.has_signal("died") and not enemy.died.is_connected(_on_enemy_died):
			enemy.died.connect(_on_enemy_died.bind(enemy))


func _on_body_entered(body: Node) -> void:
	if _transition_triggered:
		return

	if body.is_in_group("player"):
		_player_inside = true
		_check_transition_conditions()


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_inside = false


func _on_enemy_died(enemy: Node) -> void:
	if _transition_triggered:
		return

	# 延迟一帧检查，确保 enemy 已被移除
	await get_tree().process_frame
	_check_all_enemies_dead()


func _check_all_enemies_dead() -> void:
	var tree := get_tree()
	if tree == null:
		return

	# 获取所有在 "enemy" 组中的有效节点
	# 死后的敌人会被 queue_free()，所以 is_instance_valid 检查足够了
	var enemies: Array[Node] = tree.get_nodes_in_group(enemy_group_name)
	var alive_enemies := enemies.filter(func(e): return is_instance_valid(e))

	_all_enemies_dead = alive_enemies.is_empty()
	_check_transition_conditions()


func _check_transition_conditions() -> void:
	if _transition_triggered:
		return

	var can_transition := false

	# 条件1：玩家进入终点区域
	if _player_inside:
		can_transition = true

	# 条件2：所有敌人死亡（如果启用）
	if require_all_enemies_dead and _all_enemies_dead:
		can_transition = true

	if can_transition:
		_trigger_level_transition()


func _trigger_level_transition() -> void:
	if _transition_triggered:
		return

	_transition_triggered = true
	level_completed.emit()

	print("关卡完成！切换到: ", next_level_path)

	# 切换到下一关
	get_tree().change_scene_to_file(next_level_path)
