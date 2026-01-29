extends Camera2D

# Assign the Player node in the Inspector
@export var target: Node2D

@export_category("Smoothing")
# Lower = Smoother/Slower, Higher = Snappier
@export var smooth_speed: float = 10.0
# How far the camera peeks towards the mouse (0.0 to 1.0)
@export var mouse_lead: float = 0.2

func _process(delta: float) -> void:
	if not target:
		return
		
	# 1. Calculate the desired position
	# Start with the player's center
	var desired_position = target.global_position
	
	# 2. Add Mouse Peeking (The "Swordmancer" Mechanic)
	# We calculate the vector from player to mouse
	var mouse_offset = get_global_mouse_position() - target.global_position
	# We add a fraction of that distance to the camera target
	desired_position += mouse_offset * mouse_lead
	
	# 3. Smoothly interpolate (Lerp) to that position
	# Using 'global_position' in _process ensures 144Hz+ smoothness
	global_position = global_position.lerp(desired_position, smooth_speed * delta)

# Test Comment
