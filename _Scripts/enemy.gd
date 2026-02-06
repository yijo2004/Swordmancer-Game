extends CharacterBody2D

@export var health = 5
@export var speed = 25
var chasePlayer = false
var player = null

func _physics_process(_delta: float) -> void:
	if chasePlayer and player:
		var direction = (player.global_position - global_position).normalized()
		
		if global_position.distance_to(player.global_position) > 10:
			velocity = direction * speed
		else:
			velocity = Vector2.ZERO
			
		$Sprite2D.flip_h = direction.x < 0
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

	
func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	chasePlayer = true
	
func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		chasePlayer = false
	
	
	
func take_damage(damage: int) -> void:
	print("taken damage")
	health -= damage
	if health <= 0:
		queue_free()
