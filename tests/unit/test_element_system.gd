extends GutTest

const ElementSystemScript = preload("res://scripts/systems/ElementSystem.gd")


func test_metal_beats_wood():
	var effectiveness := ElementSystem.get_element_effectiveness(
		ElementSystemScript.Element.METAL,
		ElementSystemScript.Element.WOOD
	)
	assert_eq(effectiveness, 1.5)


func test_wood_beats_earth():
	var effectiveness := ElementSystem.get_element_effectiveness(
		ElementSystemScript.Element.WOOD,
		ElementSystemScript.Element.EARTH
	)
	assert_eq(effectiveness, 1.5)


func test_earth_beats_water():
	var effectiveness := ElementSystem.get_element_effectiveness(
		ElementSystemScript.Element.EARTH,
		ElementSystemScript.Element.WATER
	)
	assert_eq(effectiveness, 1.5)


func test_water_beats_fire():
	var effectiveness := ElementSystem.get_element_effectiveness(
		ElementSystemScript.Element.WATER,
		ElementSystemScript.Element.FIRE
	)
	assert_eq(effectiveness, 1.5)


func test_fire_beats_metal():
	var effectiveness := ElementSystem.get_element_effectiveness(
		ElementSystemScript.Element.FIRE,
		ElementSystemScript.Element.METAL
	)
	assert_eq(effectiveness, 1.5)


func test_yin_counters_yang():
	var effectiveness := ElementSystem.get_element_effectiveness(
		ElementSystemScript.Element.YIN,
		ElementSystemScript.Element.YANG
	)
	assert_eq(effectiveness, 1.5)


func test_same_element_neutral():
	var effectiveness := ElementSystem.get_element_effectiveness(
		ElementSystemScript.Element.METAL,
		ElementSystemScript.Element.METAL
	)
	assert_eq(effectiveness, 1.0)
