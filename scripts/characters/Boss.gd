extends CharacterBody2D

class_name Boss

signal phase_changed(new_phase: int)
signal died

enum State {
	IDLE,
	CHASING,
	TELEGRAPHING,
	ATTACKING,
	RECOVERING,
	DEAD,
}

enum Phase {
	PHASE_1,
	PHASE_2,
	PHASE_3,
}

@export var max_health: int = 500
@export var current_health: int = 500
@export var attack: int = 25
@export var defense: int = 10
@export var move_speed: float = 80.0
@export var detection_range: float = 500.0
@export var attack_range: float = 100.0

@export var health_bar_path: NodePath = ^"HealthBar"

@onready var _health_bar: ProgressBar = get_node_or_null(health_bar_path)

var current_phase: Phase = Phase.PHASE_1
var current_state: State = State.IDLE
var _player_ref: Node2D = null
var _state_timer: float = 0.0
var _attack_cooldown: float = 0.0
var _phase_transitioned: bool = false


func _ready() -> void:
	current_health = max_health
	add_to_group("enemy")
	add_to_group("boss")
	_set_state(State.IDLE)
	_sync_health_bar()


func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return

	_update_timers(delta)
	_find_player()

	match current_state:
		State.IDLE:
			_ai_idle(delta)
		State.CHASING:
			_ai_chase(delta)
		State.TELEGRAPHING:
			_ai_telegraph(delta)
		State.ATTACKING:
			_ai_attack(delta)
		State.RECOVERING:
			_ai_recover(delta)

	_check_phase_transition()


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


func _update_timers(delta: float) -> void:
	if _attack_cooldown > 0.0:
		_attack_cooldown = maxf(_attack_cooldown - delta, 0.0)

	if _state_timer > 0.0:
		_state_timer = maxf(_state_timer - delta, 0.0)


func _check_phase_transition() -> void:
	if _phase_transitioned:
		return

	var health_ratio := float(current_health) / float(max_health)

	if health_ratio <= 0.3 and current_phase == Phase.PHASE_2:
		_transition_to_phase(Phase.PHASE_3)
	elif health_ratio <= 0.6 and current_phase == Phase.PHASE_1:
		_transition_to_phase(Phase.PHASE_2)


func _transition_to_phase(new_phase: Phase) -> void:
	current_phase = new_phase
	_phase_transitioned = true
	phase_changed.emit(new_phase)

	match new_phase:
		Phase.PHASE_2:
			move_speed *= 1.3
			attack = int(float(attack) * 1.2)
		Phase.PHASE_3:
			move_speed *= 1.5
			attack = int(float(attack) * 1.5)


func _ai_idle(_delta: float) -> void:
	if _player_ref == null:
		return

	var dist := global_position.distance_to(_player_ref.global_position)
	if dist <= detection_range:
		_set_state(State.TELEGRAPHING)
		_state_timer = 0.8


func _ai_telegraph(_delta: float) -> void:
	if _state_timer <= 0.0:
		_set_state(State.ATTACKING)
		_perform_attack()


func _ai_attack(_delta: float) -> void:
	_set_state(State.RECOVERING)
	_state_timer = 1.0


func _ai_recover(_delta: float) -> void:
	if _state_timer <= 0.0:
		if _player_ref != null:
			var dist := global_position.distance_to(_player_ref.global_position)
			if dist > attack_range and _attack_cooldown <= 0.0:
				_set_state(State.CHASING)
			elif _attack_cooldown <= 0.0:
				_set_state(State.TELEGRAPHING)
				_state_timer = 0.5
			else:
				_set_state(State.IDLE)
		else:
			_set_state(State.IDLE)


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
	velocity.y = 0.0
	move_and_slide()


func _perform_attack() -> void:
	if _player_ref == null:
		return

	_attack_cooldown = 2.0 - (0.3 if current_phase >= Phase.PHASE_2 else 0.0)

	var player_defense := 0
	if _player_ref.stats != null:
		player_defense = _player_ref.stats.defense

	var damage := CombatSystem.calculate_damage(
		attack,
		player_defense,
		ElementSystem.Element.METAL,
		ElementSystem.Element.METAL
	)

	if _player_ref.has_method("take_damage"):
		_player_ref.take_damage(damage)


func take_damage(amount: int) -> void:
	if current_state == State.DEAD:
		return

	var final_damage: int = maxi(1, amount - defense)
	current_health = clampi(current_health - final_damage, 0, max_health)
	_sync_health_bar()

	if current_health <= 0:
		die()
	else:
		_phase_transitioned = false


func _sync_health_bar() -> void:
	if _health_bar != null:
		_health_bar.max_value = max_health
		_health_bar.value = current_health


func die() -> void:
	_set_state(State.DEAD)
	died.emit()
	queue_free()


func _set_state(new_state: State) -> void:
	if current_state == new_state:
		return
	current_state = new_state
