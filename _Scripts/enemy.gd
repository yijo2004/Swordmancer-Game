extends CharacterBody2D

@export var health = 5
@export var stop_distance = 10
@export var contact_damage = 1
@export var invincibility_duration: float = 0.3
@export var knockback_strength: float = 200.0

@onready var sprite: Sprite2D = $Sprite2D

var speed = 25
var chasePlayer = false
var player = null
var is_invincible: bool = false
var is_knocked_back: bool = false

func _physics_process(delta: float) -> void:
	if is_knocked_back:
		velocity = velocity.move_toward(Vector2.ZERO, 400.0 * delta)
		move_and_slide()
		return
	
	if chasePlayer and player:
		var direction = (player.global_position - global_position).normalized()
		
		if global_position.distance_to(player.global_position) > stop_distance:
			velocity = direction * speed
			sprite.flip_h = direction.x < 0
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

	
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		chasePlayer = true


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		chasePlayer = false
		
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(contact_damage, global_position)
	
func take_damage(damage: int) -> void:
	if is_invincible:
		return
	
	health -= damage
	if health <= 0:
		queue_free()
		return
	
	is_invincible = true
	is_knocked_back = true
	
	# Knockback away from the player
	if player:
		var knockback_dir = (global_position - player.global_position).normalized()
		velocity = knockback_dir * knockback_strength
	
	get_tree().create_timer(0.2).timeout.connect(func(): is_knocked_back = false)
	
	# Flash tween
	var tween = create_tween()
	for i in range(3):
		tween.tween_property(sprite, "modulate:a", 0.3, 0.05)
		tween.tween_property(sprite, "modulate:a", 1.0, 0.05)
	
	get_tree().create_timer(invincibility_duration).timeout.connect(func(): is_invincible = false)
