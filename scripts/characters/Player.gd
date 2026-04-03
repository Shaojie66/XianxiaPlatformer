extends CharacterBody2D

class_name Player

signal jumped
signal double_jumped
signal dashed
signal state_changed(new_state: int)

enum FacingDirection {
	LEFT = -1,
	RIGHT = 1,
}

enum State {
	IDLE,
	RUNNING,
	JUMPING,
	FALLING,
	DASHING,
	FLYING,
	ATTACKING,
}

@export var move_speed: float = 300.0
@export var acceleration: float = 1800.0
@export var deceleration: float = 2200.0
@export var jump_velocity: float = -450.0
@export var gravity: float = 980.0
@export var flight_speed: float = 400.0
@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 0.5
@export var sprite_path: NodePath = ^"Sprite2D"

@export var can_double_jump: bool = false
@export var can_dash: bool = false
@export var can_fly: bool = false

@export var stats: PlayerStats

@export var death_zone_path: NodePath = ^"../DeathZone"
@export var spawn_point_path: NodePath = ^"../SpawnPoint"

@export var attack_cooldown: float = 0.3
@export var attack_range: float = 60.0

var _attack_pressed: bool = false
var _attack_time_left: float = 0.0

var facing_direction: FacingDirection = FacingDirection.RIGHT
var current_state: State = State.IDLE

var _jump_pressed: bool = false
var _jump_held: bool = false
var _dash_pressed: bool = false
var _has_used_double_jump: bool = false
var _is_dashing: bool = false
var _dash_time_left: float = 0.0
var _dash_cooldown_left: float = 0.0

@onready var _sprite: Node2D = get_node_or_null(sprite_path)
@onready var _death_zone: Area2D = get_node_or_null(death_zone_path)
@onready var _spawn_point: Marker2D = get_node_or_null(spawn_point_path)


func _ready() -> void:
	if stats == null:
		stats = PlayerStats.new()
	add_to_group("player")
	_ensure_input_actions()
	_update_sprite_facing()
	_set_state(State.IDLE)

	if _death_zone != null:
		_death_zone.body_entered.connect(_on_death_zone_body_entered)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		_jump_pressed = true
		_jump_held = true

	if event.is_action_released("jump"):
		_jump_held = false

	if event.is_action_pressed("dash"):
		_dash_pressed = true

	if event.is_action_pressed("attack"):
		_attack_pressed = true


func _physics_process(delta: float) -> void:
	_update_facing_direction()
	_update_dash_timers(delta)
	_update_attack_timer(delta)

	if _is_dashing:
		velocity.x = dash_speed * float(facing_direction)
		velocity.y = 0.0
	else:
		_apply_gravity(delta)
		_handle_jump_and_flight()
		_handle_horizontal_movement(delta)
		_try_start_dash()
		_try_start_attack()

	move_and_slide()

	if is_on_floor():
		_has_used_double_jump = false

	_update_sprite_facing()
	_update_state()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		if can_fly and _jump_held:
			velocity.y = -flight_speed
		else:
			velocity.y += gravity * delta
	elif velocity.y > 0.0:
		velocity.y = 0.0


func _handle_horizontal_movement(delta: float) -> void:
	var input_axis: float = Input.get_axis("move_left", "move_right")
	var target_speed: float = input_axis * move_speed
	var rate: float = acceleration if not is_zero_approx(input_axis) else deceleration
	velocity.x = move_toward(velocity.x, target_speed, rate * delta)


func _handle_jump_and_flight() -> void:
	if not _jump_pressed:
		return

	_jump_pressed = false

	if is_on_floor():
		velocity.y = jump_velocity
		jumped.emit()
		return

	if can_double_jump and not _has_used_double_jump:
		velocity.y = jump_velocity
		_has_used_double_jump = true
		double_jumped.emit()


func _try_start_dash() -> void:
	if not _dash_pressed:
		return

	_dash_pressed = false

	if not can_dash:
		return

	if _is_dashing or _dash_cooldown_left > 0.0:
		return

	_is_dashing = true
	_dash_time_left = dash_duration
	_dash_cooldown_left = dash_cooldown
	velocity.x = dash_speed * float(facing_direction)
	velocity.y = 0.0
	dashed.emit()
	_set_state(State.DASHING)


func _update_dash_timers(delta: float) -> void:
	if _dash_cooldown_left > 0.0:
		_dash_cooldown_left = maxf(_dash_cooldown_left - delta, 0.0)

	if not _is_dashing:
		return

	_dash_time_left = maxf(_dash_time_left - delta, 0.0)
	if _dash_time_left <= 0.0:
		_is_dashing = false


func _update_attack_timer(delta: float) -> void:
	if _attack_time_left > 0.0:
		_attack_time_left = maxf(_attack_time_left - delta, 0.0)

	if _attack_time_left <= 0.0 and current_state == State.ATTACKING:
		_set_state(State.IDLE)


func _try_start_attack() -> void:
	if not _attack_pressed:
		return

	_attack_pressed = false

	if _attack_time_left > 0.0:
		return

	_attack_time_left = attack_cooldown
	_set_state(State.ATTACKING)
	_perform_attack()


func _perform_attack() -> void:
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := CapsuleShape2D.new()
	shape.height = 48.0
	shape.radius = attack_range * 0.5
	query.shape = shape

	var attack_offset := Vector2(float(facing_direction) * attack_range * 0.5, -24.0)
	query.transform = Transform2D(0.0, global_position + attack_offset)

	var space_state := get_world_2d().direct_space_state
	var results := space_state.intersect_shape(query, 10)

	for result in results:
		var collider = result.collider
		if collider != null and (collider is Enemy or collider is Boss):
			var damage := stats.attack if stats != null else 10
			collider.take_damage(damage)


func take_damage(amount: int) -> void:
	if stats != null:
		stats.take_damage(amount)


func _on_death_zone_body_entered(body: Node) -> void:
	if body == self:
		_respawn()


func _respawn() -> void:
	global_position = _spawn_point.global_position if _spawn_point else Vector2(160, 520)
	velocity = Vector2.ZERO
	if stats != null:
		stats.current_health = stats.max_health


func _update_facing_direction() -> void:
	var input_axis: float = Input.get_axis("move_left", "move_right")
	if input_axis < 0.0:
		facing_direction = FacingDirection.LEFT
	elif input_axis > 0.0:
		facing_direction = FacingDirection.RIGHT


func _update_sprite_facing() -> void:
	if _sprite == null:
		return

	if _sprite is Sprite2D:
		(_sprite as Sprite2D).flip_h = facing_direction == FacingDirection.LEFT
	else:
		var new_scale := _sprite.scale
		new_scale.x = absf(new_scale.x) * float(facing_direction)
		_sprite.scale = new_scale


func _update_state() -> void:
	if _is_dashing:
		_set_state(State.DASHING)
		return

	if current_state == State.ATTACKING:
		return

	if not is_on_floor():
		if can_fly and _jump_held:
			_set_state(State.FLYING)
		elif velocity.y < 0.0:
			_set_state(State.JUMPING)
		else:
			_set_state(State.FALLING)
		return

	if absf(velocity.x) > 1.0:
		_set_state(State.RUNNING)
	else:
		_set_state(State.IDLE)


func _set_state(new_state: State) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	state_changed.emit(current_state)


func _ensure_input_actions() -> void:
	_add_input_action_if_missing("move_left", [KEY_A, KEY_LEFT])
	_add_input_action_if_missing("move_right", [KEY_D, KEY_RIGHT])
	_add_input_action_if_missing("jump", [KEY_W, KEY_UP, KEY_SPACE])
	_add_input_action_if_missing("dash", [KEY_SHIFT])
	_add_input_action_if_missing("attack", [KEY_J])


func _add_input_action_if_missing(action_name: StringName, keys: Array[int]) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	var existing_events: Array[InputEvent] = InputMap.action_get_events(action_name)
	for keycode in keys:
		var already_present := false
		for existing_event in existing_events:
			if existing_event is InputEventKey and existing_event.physical_keycode == keycode:
				already_present = true
				break

		if already_present:
			continue

		var new_event := InputEventKey.new()
		new_event.physical_keycode = keycode
		InputMap.action_add_event(action_name, new_event)
