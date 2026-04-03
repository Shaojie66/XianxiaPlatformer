extends CharacterBody2D

class_name Enemy

signal died
signal health_changed(new_health: int)

enum State {
	IDLE,
	CHASING,
	ATTACKING,
	DEAD,
}

@export var max_health: int = 50
@export var attack: int = 10
@export var defense: int = 3
@export var move_speed: float = 100.0
@export var detection_range: float = 300.0
@export var attack_range: float = 50.0
@export var attack_cooldown: float = 1.0

@export var current_health: int = 50

var current_state: State = State.IDLE
var _attack_timer: float = 0.0
var _player_ref: Node2D = null


func _ready() -> void:
	current_health = max_health
	add_to_group("enemy")
	_set_state(State.IDLE)


func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return

	_update_attack_timer(delta)
	_find_player()

	match current_state:
		State.IDLE:
			_ai_idle(delta)
		State.CHASING:
			_ai_chase(delta)
		State.ATTACKING:
			_ai_attack(delta)


func _find_player() -> void:
	var tree := get_tree()
	if tree == null:
		return

	var players: Array[Node] = tree.get_nodes_in_group("player")
	for node in players:
		if node is Node2D and is_instance_valid(node):
			_player_ref = node
			return

	_player_ref = null


func _update_attack_timer(delta: float) -> void:
	if _attack_timer > 0.0:
		_attack_timer = maxf(_attack_timer - delta, 0.0)


func _ai_idle(_delta: float) -> void:
	if _player_ref == null:
		return

	var dist := global_position.distance_to(_player_ref.global_position)
	if dist <= detection_range:
		_set_state(State.CHASING)


func _ai_chase(_delta: float) -> void:
	if _player_ref == null:
		_set_state(State.IDLE)
		return

	var dist := global_position.distance_to(_player_ref.global_position)

	if dist > detection_range * 1.5:
		_set_state(State.IDLE)
		return

	if dist <= attack_range:
		_set_state(State.ATTACKING)
		return

	var dir := (_player_ref.global_position - global_position).normalized()
	velocity.x = dir.x * move_speed
	velocity.y += 400.0 * _delta
	move_and_slide()


func _ai_attack(_delta: float) -> void:
	if _player_ref == null:
		_set_state(State.IDLE)
		return

	var dist := global_position.distance_to(_player_ref.global_position)
	if dist > attack_range:
		_set_state(State.CHASING)
		return

	velocity.x = 0.0
	move_and_slide()

	if _attack_timer <= 0.0:
		_try_attack_player()


func _try_attack_player() -> void:
	if _player_ref == null:
		return

	if not _player_ref.has_method("take_damage"):
		return

	var player_defense := 0
	if _player_ref.stats != null:
		player_defense = _player_ref.stats.defense

	var damage := CombatSystem.calculate_damage(
		attack,
		player_defense,
		ElementSystem.Element.METAL,
		ElementSystem.Element.METAL
	)

	_player_ref.take_damage(damage)
	_attack_timer = attack_cooldown


func take_damage(amount: int) -> void:
	if current_state == State.DEAD:
		return

	var final_damage: int = maxi(1, amount - defense)
	current_health = clampi(current_health - final_damage, 0, max_health)
	health_changed.emit(current_health)

	if current_health <= 0:
		die()


func die() -> void:
	_set_state(State.DEAD)
	died.emit()
	queue_free()


func _set_state(new_state: State) -> void:
	if current_state == new_state:
		return

	current_state = new_state


var player_ref: Node2D:
	get:
		return _player_ref
