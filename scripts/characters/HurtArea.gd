extends Area2D

class_name HurtArea

@export var damage: int = 10
@export var knockback_force: float = 200.0
@export var cooldown: float = 0.5

var _last_damage_time: float = 0.0
var _parent_node: Node = null


func _ready() -> void:
	_parent_node = get_parent()
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	_last_damage_time = maxf(_last_damage_time - delta, 0.0)


func _on_area_entered(area: Area2D) -> void:
	if _last_damage_time > 0.0:
		return

	if area is HurtArea:
		return

	if area.has_method("take_damage"):
		var attacker_stats = _parent_node.get("stats") if _parent_node else null
		var atk: int = damage
		if attacker_stats != null and attacker_stats.get("attack"):
			atk = attacker_stats.attack

		area.take_damage(atk)
		_last_damage_time = cooldown

		_apply_knockback(area)


func _apply_knockback(area: Area2D) -> void:
	if not area is Node2D:
		return

	if knockback_force <= 0.0:
		return

	var parent_pos: Vector2 = global_position
	if _parent_node != null and _parent_node is Node2D:
		parent_pos = _parent_node.global_position
	var dir: Vector2 = (area.global_position - parent_pos).normalized()
	var knockback: Vector2 = dir * knockback_force

	# Apply knockback using duck typing via Node to avoid Area2D->CharacterBody2D cast issue
	var target_node: Node = area
	if target_node is CharacterBody2D:
		target_node.set("velocity", knockback)
		target_node.call("move_and_slide")
