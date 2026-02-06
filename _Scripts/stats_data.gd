class_name Stats
extends Node

@export_group("Health (Hearts)")
@export var max_health: int = 3
@export var start_health: int = 3

@export_group("Stamina")
@export var max_stamina: float = 3.0
@export var stamina_regen_rate: float = 1.0

@export_group("Mana")
@export var max_mana: float = 10.0
@export var start_mana: float = 0.0 # Use later if we want mana to regen, or for testing

signal health_changed(new_value: int, max_value: int)
signal stamina_changed(new_value: float, max_value: float)
signal mana_changed(new_value: float, max_value: float)
signal died

#	clampi and clampf forces values to be within the min/max: clampi/f(value, min, max)
var health: int:
	set(value):
		health = clampi(value, 0, max_health)
		health_changed.emit(health, max_health)
		if health == 0:
			died.emit()

var stamina: float:
	set(value):
		stamina = clampf(value, 0, max_stamina)
		stamina_changed.emit(stamina, max_stamina)

var mana: float:
	set(value):
		mana = clampf(value, 0, max_mana)
		mana_changed.emit(mana, max_mana)
		
func _ready() -> void:
	health = start_health
	stamina = max_stamina
	mana = start_mana

func _process(delta: float) -> void:
	if stamina < max_stamina:
		stamina += stamina_regen_rate * delta
		
#	Public funcions that other scripts/nodes will call

func take_damage(amount: int) -> void:
	health -= amount

func spend_stamina(amount: float) -> bool:
	if stamina >= amount:
		stamina -= amount
		return true
	return false

func spend_mana(amount: float) -> bool:
	if mana >= amount:
		mana -= amount
		return true
	return false

func gain_mana(amount: float) -> void:
	mana += amount
