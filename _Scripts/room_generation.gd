class_name RoomGeneration
extends Node

@export var map_size : int = 7
@export var rooms_to_generate : int = 12
@export var room_pos_offset : Vector2 = Vector2(640, 512) 

var room_count : int = 0
var map : Array[bool]
var rooms : Array[Room] # Stores the actual room instances

var room_scene : PackedScene = preload("res://Scenes/Rooms/room_template.tscn")

# Drag your Player node here in the Inspector!
@export var player : CharacterBody2D 

func _ready():
	_generate()

func _generate():
	# 1. Cleanup
	for r in rooms: r.queue_free()
	rooms.clear()
	map.clear()
	map.resize(map_size * map_size)
	map.fill(false)
	
	# 2. Logic Generation
	var start_x : int = map_size / 2
	var start_y : int = map_size / 2
	
	_check_room(start_x, start_y, Vector2.ZERO)
	_instantiate_rooms()
	
	# 3. NEW: Open Doors & Spawn Player
	_open_connecting_doors()
	_spawn_player_in_center(start_x, start_y)

func _check_room(x : int, y : int, incoming_direction : Vector2):
	# ... (Your existing check_room logic goes here, unchanged) ...
	if room_count >= rooms_to_generate: return
	if x < 0 or x >= map_size or y < 0 or y >= map_size: return
	if _get_map(x, y): return
	
	room_count += 1
	_set_map(x, y, true)
	
	var moves = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	moves.shuffle()
	
	for move in moves:
		var new_x = x + int(move.x)
		var new_y = y + int(move.y)
		var threshold = 0.8
		if incoming_direction == Vector2.ZERO or move == incoming_direction:
			threshold = 0.2
		if randf() > threshold:
			_check_room(new_x, new_y, move)

func _instantiate_rooms():
	for x in range(map_size):
		for y in range(map_size):
			if not _get_map(x, y):
				continue
			
			var room = room_scene.instantiate()
			call_deferred("add_child", room)
			rooms.append(room)
			
			# Store the grid coordinates ON the room so we can use them later
			# You can add "var grid_pos : Vector2" to room.gd if you want, 
			# but strictly speaking we can calculate positions without it.
			room.global_position = Vector2(x, y) * room_pos_offset
			
			# Give the room a name so we can find it easily if debugging
			room.name = "Room_%d_%d" % [x, y]

# --- NEW FUNCTIONS ---

func _open_connecting_doors():
	# Wait one frame for rooms to fully enter tree (optional but safer)
	await get_tree().process_frame
	
	# We loop through x/y again to find neighbors
	for x in range(map_size):
		for y in range(map_size):
			# If there is no room at this generic grid spot, skip
			if not _get_map(x, y):
				continue
				
			# Find the actual room instance at this location
			var current_room = _find_room_at(x, y)
			if current_room == null: continue
			
			# Check Neighbors. If a neighbor exists, open the door facing it.
			
			# North Neighbor? (y-1)
			if _get_map(x, y - 1):
				current_room.open_entrance(Vector2.UP)
			
			# South Neighbor? (y+1)
			if _get_map(x, y + 1):
				current_room.open_entrance(Vector2.DOWN)
				
			# West Neighbor? (x-1)
			if _get_map(x - 1, y):
				current_room.open_entrance(Vector2.LEFT)
				
			# East Neighbor? (x+1)
			if _get_map(x + 1, y):
				current_room.open_entrance(Vector2.RIGHT)

func _spawn_player_in_center(start_x, start_y):
	# Calculate the global position of the center room
	var center_pos = Vector2(start_x, start_y) * room_pos_offset
	
	# Move the player there
	if player:
		player.global_position = center_pos
	else:
		print("WARNING: Player node not assigned in RoomGeneration Inspector!")

# Helper to find the instantiated room node based on grid coordinates
func _find_room_at(x, y) -> Room:
	var target_pos = Vector2(x, y) * room_pos_offset
	# This is a bit slow (searching array), but fine for 12 rooms.
	# For huge maps, we would store rooms in a Dictionary {Vector2: Room}
	for r in rooms:
		# Use is_equal_approx to handle float point errors
		if r.global_position.is_equal_approx(target_pos):
			return r
	return null

func _get_map(x : int, y : int) -> bool:
	if x < 0 or x >= map_size or y < 0 or y >= map_size: return false
	return map[x + y * map_size]

func _set_map(x : int, y : int, value: bool):
	map[x + y * map_size] = value
