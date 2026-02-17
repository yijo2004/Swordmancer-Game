extends CharacterBody2D

@export var health = 5
@export var stop_distance = 10
var speed = 25
var chasePlayer = false
var player = null

func _physics_process(_delta: float) -> void:
	if chasePlayer and player:
		var direction = (player.global_position - global_position).normalized()
		
		if global_position.distance_to(player.global_position) > stop_distance:
			velocity = direction * speed
			$Sprite2D.flip_h = direction.x < 0
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
	
	
	
func take_damage(damage: int) -> void:
	health -= damage
	if health <= 0:
		queue_free()
