extends Node
class_name CombatSystem

const ElementSystemScript = preload("res://scripts/systems/ElementSystem.gd")

signal damage_dealt(amount: int, is_critical: bool)
signal damage_taken(amount: int)

var _element_system: ElementSystem


func _ready() -> void:
	_element_system = ElementSystem.new()


static func calculate_damage(
	attack: int,
	defense: int,
	attack_element: ElementSystemScript.Element,
	defense_element: ElementSystemScript.Element
) -> int:
	var base_damage: int = max(1, attack - defense)
	var elemental_multiplier: float = get_element_effectiveness(attack_element, defense_element)
	return max(1, int(round(base_damage * elemental_multiplier)))


static func is_element_advantage(
	attack_elem: ElementSystemScript.Element,
	defense_elem: ElementSystemScript.Element
) -> bool:
	return get_element_effectiveness(attack_elem, defense_elem) > 1.0


static func is_element_disadvantage(
	attack_elem: ElementSystemScript.Element,
	defense_elem: ElementSystemScript.Element
) -> bool:
	return get_element_effectiveness(attack_elem, defense_elem) < 1.0


static func get_element_effectiveness(attack_elem: ElementSystemScript.Element, defense_elem: ElementSystemScript.Element) -> float:
	var advantage_score := 0
	var attack_base: int = _get_base_element_index(attack_elem)
	var defense_base: int = _get_base_element_index(defense_elem)
	var attack_polarity: int = _get_polarity_index(attack_elem)
	var defense_polarity: int = _get_polarity_index(defense_elem)

	const _CONTROL_RELATIONS: Dictionary = {
		0: 1,
		1: 4,
		4: 2,
		2: 3,
		3: 0,
	}

	const _POLARITY_COUNTERS: Dictionary = {
		5: 6,
		6: 5,
	}

	if attack_base != -1 and defense_base != -1:
		if _CONTROL_RELATIONS.get(attack_base, -1) == defense_base:
			advantage_score += 1
		elif _CONTROL_RELATIONS.get(defense_base, -1) == attack_base:
			advantage_score -= 1

	if attack_polarity != -1 and defense_polarity != -1:
		if _POLARITY_COUNTERS.get(attack_polarity, -1) == defense_polarity:
			advantage_score += 1
		elif _POLARITY_COUNTERS.get(defense_polarity, -1) == attack_polarity:
			advantage_score -= 1

	if advantage_score > 0:
		return 1.5
	if advantage_score < 0:
		return 0.5
	return 1.0


static func _get_base_element_index(elem: ElementSystemScript.Element) -> int:
	match elem:
		ElementSystemScript.Element.METAL: return 0
		ElementSystemScript.Element.WOOD: return 1
		ElementSystemScript.Element.WATER: return 2
		ElementSystemScript.Element.FIRE: return 3
		ElementSystemScript.Element.EARTH: return 4
		ElementSystemScript.Element.METAL_YANG: return 0
		ElementSystemScript.Element.METAL_YIN: return 0
		ElementSystemScript.Element.WOOD_YANG: return 1
		ElementSystemScript.Element.WOOD_YIN: return 1
		ElementSystemScript.Element.WATER_YANG: return 2
		ElementSystemScript.Element.WATER_YIN: return 2
		ElementSystemScript.Element.FIRE_YANG: return 3
		ElementSystemScript.Element.FIRE_YIN: return 3
		ElementSystemScript.Element.EARTH_YANG: return 4
		ElementSystemScript.Element.EARTH_YIN: return 4
	return -1


static func _get_polarity_index(elem: ElementSystemScript.Element) -> int:
	match elem:
		ElementSystemScript.Element.YIN: return 5
		ElementSystemScript.Element.YANG: return 6
		ElementSystemScript.Element.METAL_YANG: return 6
		ElementSystemScript.Element.METAL_YIN: return 5
		ElementSystemScript.Element.WOOD_YANG: return 6
		ElementSystemScript.Element.WOOD_YIN: return 5
		ElementSystemScript.Element.WATER_YANG: return 6
		ElementSystemScript.Element.WATER_YIN: return 5
		ElementSystemScript.Element.FIRE_YANG: return 6
		ElementSystemScript.Element.FIRE_YIN: return 5
		ElementSystemScript.Element.EARTH_YANG: return 6
		ElementSystemScript.Element.EARTH_YIN: return 5
	return -1
