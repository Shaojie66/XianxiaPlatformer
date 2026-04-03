extends Resource
class_name MedicineItem

enum EffectType {
	HEAL,
	BUFF_ATTACK,
	BUFF_DEFENSE,
	TELEPORT,
	UNLOCK_PUZZLE,
}

@export var item_name: String = ""
@export_multiline var description: String = ""
@export var effect_type: EffectType = EffectType.HEAL
@export var effect_value: int = 0
@export var duration: float = 0.0
@export var cooldown: float = 0.5
@export var icon_path: String = ""
@export var quantity: int = 0
@export var max_quantity: int = 99

var _cooldown_remaining: float = 0.0


func use() -> bool:
	if not can_use():
		return false

	quantity -= 1
	_cooldown_remaining = maxf(cooldown, 0.0)
	return true


func can_use() -> bool:
	return quantity > 0 and _cooldown_remaining <= 0.0


func process_cooldown(delta: float) -> void:
	if _cooldown_remaining <= 0.0:
		return

	_cooldown_remaining = maxf(_cooldown_remaining - delta, 0.0)


func get_cooldown_remaining() -> float:
	return _cooldown_remaining
