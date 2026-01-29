class_name RoomEntrance
extends Node2D

# Assign this in the Inspector for each instance! 
# e.g., for Entrance_North, set x=0, y=-1
@export var direction : Vector2 

@onready var barrier = $Barrier

func _ready():
	# By default, all doors are closed (barrier is active)
	close()

func open():
	barrier.process_mode = Node.PROCESS_MODE_DISABLED # Disables collision
	barrier.hide() # Hides the visual

func close():
	barrier.process_mode = Node.PROCESS_MODE_INHERIT # Enables collision
	barrier.show()
