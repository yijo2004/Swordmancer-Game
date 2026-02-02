extends CharacterBody2D

# --- CONFIGURATION ---
@export_category("Movement Stats")
@export var speed: float = 150.0
@export var acceleration: float = 1000.0
@export var friction: float = 1000.0

@export_category("Dash Stats")
@export var dash_speed: float = 500
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.8

# --- COMPONENT REFERENCES ---
@onready var weapon_socket: Marker2D = $WeaponSocket 
@onready var sprite: Sprite2D = $Sprite2D 
@onready var stats: Stats = $Stats
@onready var hud: CanvasLayer = $HUD

# --- STATE MACHINE ---
enum State { MOVE, DASH, ATTACK }
var current_state: State = State.MOVE

# --- RUNTIME VARIABLES ---
var current_weapon: Node2D = null
var dash_timer: float = 0.0
var can_dash: bool = true
var walk_bob_timer: float = 0.0

func _ready() -> void:
	# Signals to update HUD
	stats.health_changed.connect(hud.update_health)
	stats.stamina_changed.connect(hud.update_stamina)
	stats.mana_changed.connect(hud.update_mana)
	# Initialize HUD
	hud.update_health(stats.health, stats.max_health)
	hud.update_stamina(stats.stamina, stats.max_stamina)
	hud.update_mana(stats.mana, stats.max_mana)
	
	# In the future, this is where we load from a Save File or Inventory.
	equip_weapon(preload("res://Scenes/Weapons/sword.tscn"))

func _physics_process(delta: float) -> void:
	match current_state:
		State.MOVE:
			state_move(delta)
		State.DASH:
			state_dash(delta)
		State.ATTACK:
			state_attack(delta)
	
	move_and_slide()

# --- STATE: MOVE ---
func state_move(delta: float) -> void:
	# 1. Aiming
	# We rotate the SOCKET, so the weapon follows the mouse
	weapon_socket.look_at(get_global_mouse_position())
	
	# Flip both player sprite and weapon sprite depending on mouse position relative to screen
	if get_global_mouse_position().x < global_position.x:
		weapon_socket.scale.y = -1
		sprite.scale.x = -1
	else: 
		weapon_socket.scale.y = 1
		sprite.scale.x = 1
	
	# 2. Movement Input
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	# 3. Transitions
	if Input.is_action_just_pressed("dash") and can_dash and direction != Vector2.ZERO:
		start_dash()
		
	if Input.is_action_just_pressed("attack") and current_weapon != null:
		start_attack()

# --- STATE: DASH ---
func start_dash() -> void:
	if not stats.spend_stamina(1.0):
		return
	current_state = State.DASH
	dash_timer = dash_duration
	can_dash = false
		
	# Cooldown reset
	get_tree().create_timer(dash_cooldown).timeout.connect(func(): can_dash = true)

func state_dash(delta: float) -> void:
	# Move fast in current direction
	velocity = velocity.normalized() * dash_speed
	dash_timer -= delta

	if dash_timer <= 0:
		current_state = State.MOVE
		velocity = Vector2.ZERO

# --- STATE: ATTACK ---
func start_attack() -> void:
	current_state = State.ATTACK
	
	# Visual: Slight lunging stop
	velocity = velocity * 0.2 
	
	# Tell the Weapon to do its thing
	if current_weapon.has_method("attack"):
		current_weapon.attack()

func state_attack(delta: float) -> void:
	# 1. Allow Aiming (Optional: Remove this line if you want the swing direction to 'lock' on start)
	weapon_socket.look_at(get_global_mouse_position())
	
	# 2. Allow Movement
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if direction != Vector2.ZERO:
		# MOVEMENT PENALTY:
		# Usually, attacking slows you down slightly. 
		# "speed * 0.75" means you move at 75% speed while swinging.
		# Change 0.75 to 1.0 if you want full speed.
		var attack_speed = speed * 0.75 
		
		velocity = velocity.move_toward(direction * attack_speed, acceleration * delta)
	else:
		# If no keys pressed, slide to a stop as usual
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
	# Note: We do NOT call move_and_slide() here because it is called 
	# at the end of _physics_process() anyway.

# --- WEAPON SYSTEM ---
func equip_weapon(weapon_scene: PackedScene) -> void:
	# 1. Clean up old weapon
	if current_weapon:
		current_weapon.queue_free()
	
	# 2. Spawn new weapon
	var new_weapon = weapon_scene.instantiate()
	weapon_socket.add_child(new_weapon)
	current_weapon = new_weapon
	current_weapon.wielder = self
	
	# 3. Connect signals (Observer Pattern)
	# This listens for the "attack_finished" signal we created in weapon.gd
	if new_weapon.has_signal("attack_finished"):
		new_weapon.attack_finished.connect(_on_weapon_finished)

func _on_weapon_finished() -> void:
	current_state = State.MOVE
