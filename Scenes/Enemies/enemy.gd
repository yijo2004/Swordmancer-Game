extends CharacterBody2D

var speed = 25
var chasePlayer = false
var player = null

func _physics_process(delta: float) -> void:
	if chasePlayer:
		if position.distance_to(player.position) > 10:
				position+=(player.position-position)/speed
				
				if (player.position.x-position.x)<0:
					$Sprite2D.flip_h = true
				else:
					$Sprite2D.flip_h = false
	
	move_and_collide(Vector2(0,0))
	
	
	
func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	chasePlayer = true
	


func _on_detection_area_body_exited(body: Node2D) -> void:
	player = null
	chasePlayer = false
