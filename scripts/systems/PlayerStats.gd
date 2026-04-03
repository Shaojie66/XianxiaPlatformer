extends Resource
class_name PlayerStats

const ElementSystemScript = preload("res://scripts/systems/ElementSystem.gd")

signal health_changed(new_health: int)
signal died

@export var max_health: int = 100
@export var current_health: int = 100
@export var attack: int = 10
@export var defense: int = 5
@export var element: ElementSystemScript.Element = ElementSystemScript.Element.METAL
@export var current_realm: String = "炼气"
@export var unlocked_abilities: Array[String] = []


func _init() -> void:
	max_health = max(1, max_health)
	current_health = clampi(current_health, 0, max_health)
	if current_health == 0:
		current_health = max_health


func take_damage(amount: int) -> void:
	var incoming_damage: int = max(0, amount)
	var previous_health: int = current_health

	current_health = clampi(current_health - incoming_damage, 0, max_health)
	if current_health != previous_health:
		health_changed.emit(current_health)

	if current_health <= 0:
		died.emit()


func heal(amount: int) -> void:
	if amount <= 0:
		return

	var previous_health: int = current_health
	current_health = clampi(current_health + amount, 0, max_health)
	if current_health != previous_health:
		health_changed.emit(current_health)


func unlock_ability(ability_name: String) -> void:
	if ability_name.is_empty():
		return
	if ability_name in unlocked_abilities:
		return

	unlocked_abilities.append(ability_name)
