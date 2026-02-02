class_name Weapon
extends Node2D

@export var damage: int = 10
@export var cooldown: float = 0.5
@export var knockback: float = 300.0
@export var mana_gain_on_hit: float = 1.0;

@onready var anim_player = $AnimationPlayer
@onready var hitbox = $Hitbox
@onready var vfx = $VFX

signal attack_finished

var is_attacking: bool = false

var wielder: CharacterBody2D

func _ready() -> void:
	if vfx.is_visible_in_tree():
		vfx.visible = false
	
func attack() -> void:
	if is_attacking:
		return
	
	if anim_player.has_animation("attack"):
		is_attacking = true
		anim_player.play("attack")
	else:
		printerr("ERROR: Animation 'attack' not found on ", name)
		# Force finish so the player doesn't get stuck
		_on_animation_player_animation_finished("none")
	

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	is_attacking = false
	attack_finished.emit()
	
	if wielder.has_node("Stats"):
		wielder.get_node("Stats").gain_mana(mana_gain_on_hit)
