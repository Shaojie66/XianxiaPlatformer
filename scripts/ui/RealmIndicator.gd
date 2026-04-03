extends Label

@export var realm_names: Array[String] = [
	"炼气",
	"筑基",
	"金丹",
	"元婴",
	"化神",
	"炼虚",
	"合体",
	"大乘",
	"渡劫"
]
@export var current_realm_index: int = 0
@export var accent_color: Color = Color(0.96, 0.87, 0.63, 1.0)
@export var panel_color: Color = Color(0.13, 0.10, 0.07, 0.88)
@export var border_color: Color = Color(0.73, 0.61, 0.33, 1.0)


func _ready() -> void:
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	clip_text = true
	_update_text()


func set_realm(realm_name: String) -> void:
	var matched_index: int = realm_names.find(realm_name)
	if matched_index == -1:
		realm_names.append(realm_name)
		matched_index = realm_names.size() - 1

	current_realm_index = matched_index
	_update_text()
	queue_redraw()


func get_realm_index() -> int:
	return current_realm_index


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return

	var style_box := StyleBoxFlat.new()
	style_box.bg_color = panel_color
	style_box.border_color = border_color
	style_box.border_width_left = 2
	style_box.border_width_top = 2
	style_box.border_width_right = 2
	style_box.border_width_bottom = 2
	style_box.corner_radius_top_left = 12
	style_box.corner_radius_top_right = 12
	style_box.corner_radius_bottom_left = 12
	style_box.corner_radius_bottom_right = 12
	style_box.shadow_color = Color(0.0, 0.0, 0.0, 0.22)
	style_box.shadow_size = 5
	style_box.draw(get_canvas_item(), rect)

	var ornament_y: float = rect.size.y * 0.5
	draw_line(Vector2(12.0, ornament_y), Vector2(32.0, ornament_y), accent_color, 2.0)
	draw_line(Vector2(rect.size.x - 12.0, ornament_y), Vector2(rect.size.x - 32.0, ornament_y), accent_color, 2.0)


func _update_text() -> void:
	current_realm_index = clampi(current_realm_index, 0, max(realm_names.size() - 1, 0))
	var realm_name: String = ""
	if not realm_names.is_empty():
		realm_name = realm_names[current_realm_index]

	text = "境界  " + realm_name
	add_theme_color_override("font_color", accent_color)
