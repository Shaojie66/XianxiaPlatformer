extends Node
class_name ElementSystem

enum Element {
	METAL,
	WOOD,
	WATER,
	FIRE,
	EARTH,
	YIN,
	YANG,
	METAL_YANG,
	METAL_YIN,
	WOOD_YANG,
	WOOD_YIN,
	WATER_YANG,
	WATER_YIN,
	FIRE_YANG,
	FIRE_YIN,
	EARTH_YANG,
	EARTH_YIN
}

const _GENERATION_RELATIONS: Dictionary = {
	Element.METAL: Element.WATER,
	Element.WATER: Element.WOOD,
	Element.WOOD: Element.FIRE,
	Element.FIRE: Element.EARTH,
	Element.EARTH: Element.METAL,
}

const _CONTROL_RELATIONS: Dictionary = {
	Element.METAL: Element.WOOD,
	Element.WOOD: Element.EARTH,
	Element.EARTH: Element.WATER,
	Element.WATER: Element.FIRE,
	Element.FIRE: Element.METAL,
}

const _POLARITY_COUNTERS: Dictionary = {
	Element.YIN: Element.YANG,
	Element.YANG: Element.YIN,
}

const _COMPOSITE_TO_BASE: Dictionary = {
	Element.METAL_YANG: Element.METAL,
	Element.METAL_YIN: Element.METAL,
	Element.WOOD_YANG: Element.WOOD,
	Element.WOOD_YIN: Element.WOOD,
	Element.WATER_YANG: Element.WATER,
	Element.WATER_YIN: Element.WATER,
	Element.FIRE_YANG: Element.FIRE,
	Element.FIRE_YIN: Element.FIRE,
	Element.EARTH_YANG: Element.EARTH,
	Element.EARTH_YIN: Element.EARTH,
}

const _COMPOSITE_TO_POLARITY: Dictionary = {
	Element.METAL_YANG: Element.YANG,
	Element.METAL_YIN: Element.YIN,
	Element.WOOD_YANG: Element.YANG,
	Element.WOOD_YIN: Element.YIN,
	Element.WATER_YANG: Element.YANG,
	Element.WATER_YIN: Element.YIN,
	Element.FIRE_YANG: Element.YANG,
	Element.FIRE_YIN: Element.YIN,
	Element.EARTH_YANG: Element.YANG,
	Element.EARTH_YIN: Element.YIN,
}

const _BASE_AND_POLARITY_TO_COMPOSITE: Dictionary = {
	"0_6": Element.METAL_YANG,
	"0_5": Element.METAL_YIN,
	"1_6": Element.WOOD_YANG,
	"1_5": Element.WOOD_YIN,
	"2_6": Element.WATER_YANG,
	"2_5": Element.WATER_YIN,
	"3_6": Element.FIRE_YANG,
	"3_5": Element.FIRE_YIN,
	"4_6": Element.EARTH_YANG,
	"4_5": Element.EARTH_YIN,
}


func get_effectiveness(attack_element: Element, defense_element: Element) -> float:
	var advantage_score := 0
	var attack_base: Element = _get_base_element(attack_element)
	var defense_base: Element = _get_base_element(defense_element)
	var attack_polarity: int = _get_polarity(attack_element)
	var defense_polarity: int = _get_polarity(defense_element)

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


func get_counter_element(element: Element) -> Element:
	var base_element: Element = _get_base_element(element)
	var polarity: int = _get_polarity(element)

	if base_element == -1:
		return _POLARITY_COUNTERS.get(polarity, element)

	var counter_base: Element = _CONTROL_RELATIONS.get(base_element, base_element)
	if polarity == -1:
		return counter_base

	var counter_polarity: int = _POLARITY_COUNTERS.get(polarity, polarity)
	return _compose_element(counter_base, counter_polarity)


func get_generated_element(element: Element) -> Element:
	var base_element: Element = _get_base_element(element)
	var polarity: int = _get_polarity(element)

	if base_element == -1:
		return element

	var generated_base: Element = _GENERATION_RELATIONS.get(base_element, base_element)
	if polarity == -1:
		return generated_base

	return _compose_element(generated_base, polarity)


func _get_base_element(element: Element) -> Element:
	if element in _GENERATION_RELATIONS:
		return element
	return _COMPOSITE_TO_BASE.get(element, -1)


func _get_polarity(element: Element) -> int:
	if element == Element.YIN or element == Element.YANG:
		return element
	return _COMPOSITE_TO_POLARITY.get(element, -1)


func _compose_element(base_element: Element, polarity: int) -> Element:
	return _BASE_AND_POLARITY_TO_COMPOSITE.get("%d_%d" % [base_element, polarity], base_element)
