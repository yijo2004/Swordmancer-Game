class_name Room
extends Node2D

# We store references to our entrances so we can open them easily
var entrances : Dictionary = {}

func _ready():
	# Look for children that are RoomEntrances and map them by direction
	for child in get_children():
		if child is RoomEntrance:
			entrances[child.direction] = child

func open_entrance(direction : Vector2):
	if entrances.has(direction):
		entrances[direction].open()
