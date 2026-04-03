extends Control

@export var current_value: int = 100
@export var max_value: int = 100
@export var smooth_transition: bool = true
@export var transition_speed: float = 3.0
@export var background_color: Color = Color(0.09, 0.06, 0.08, 0.9)
@export var fill_color: Color = Color(0.82, 0.19, 0.22, 1.0)
@export var damage_color: Color = Color(1.0, 0.82, 0.36, 0.9)
@export var border_color: Color = Color(0.96, 0.87, 0.63, 0.95)
@export var corner_radius: float = 10.0

var _displayed_value: float = 100.0
var _target_value: float = 100.0


func _ready() -> void:
	custom_minimum_size = Vector2(320.0, 28.0)
	_sync_values()


func set_health(current: int, max_val: int) -> void:
	max_value = maxi(1, max_val)
	current_value = clampi(current, 0, max_value)
	_target_value = float(current_value)

	if not smooth_transition:
		_displayed_value = _target_value

	queue_redraw()


func _process(delta: float) -> void:
	if not smooth_transition:
		return

	if is_equal_approx(_displayed_value, _target_value):
		return

	var step: float = maxf(transition_speed * float(max_value) * delta, 1.0)
	_displayed_value = move_toward(_displayed_value, _target_value, step)
	queue_redraw()


func _draw() -> void:
	var draw_rect := Rect2(Vector2.ZERO, size)
	if draw_rect.size.x <= 0.0 or draw_rect.size.y <= 0.0:
		return

	draw_round_rect(draw_rect, background_color, corner_radius)

	var target_ratio: float = clampf(float(current_value) / float(max_value), 0.0, 1.0)
	var displayed_ratio: float = clampf(_displayed_value / float(max_value), 0.0, 1.0)

	if target_ratio < displayed_ratio:
		var damage_rect := draw_rect
		damage_rect.size.x *= displayed_ratio
		draw_round_rect(damage_rect, damage_color, corner_radius)

	var fill_rect := draw_rect
	fill_rect.size.x *= target_ratio if not smooth_transition else displayed_ratio
	if fill_rect.size.x > 0.0:
		draw_round_rect(fill_rect, fill_color, corner_radius)

	draw_round_rect(draw_rect.grow(-1.0), Color.TRANSPARENT, corner_radius, false, 2.0, border_color)


func _sync_values() -> void:
	max_value = maxi(1, max_value)
	current_value = clampi(current_value, 0, max_value)
	_target_value = float(current_value)
	_displayed_value = _target_value
	queue_redraw()


func draw_round_rect(
	rect: Rect2,
	color: Color,
	radius: float,
	filled: bool = true,
	width: float = -1.0,
	outline_color: Color = Color.WHITE
) -> void:
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = color
	style_box.corner_radius_top_left = int(radius)
	style_box.corner_radius_top_right = int(radius)
	style_box.corner_radius_bottom_right = int(radius)
	style_box.corner_radius_bottom_left = int(radius)
	style_box.draw_center = filled
	if not filled:
		style_box.border_width_left = int(width)
		style_box.border_width_top = int(width)
		style_box.border_width_right = int(width)
		style_box.border_width_bottom = int(width)
		style_box.border_color = outline_color

	style_box.draw(get_canvas_item(), rect)
