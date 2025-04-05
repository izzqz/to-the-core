extends CharacterBody2D

@export var gravity: float = 500    # Adjust based on desired fall speed
@export var move_speed: float = 200   # Horizontal movement speed
@export var MAX_FALL_SPEED: float = 600  # Maximum falling speed
@export var direction_change_speed: float = 10.0  # How quickly direction changes (higher = faster)

@export var MAX_CHANGE_SPEED: float = 1800 # Maximum speed after direction change
@export var MIN_CHANGE_SPEED: float = 200   # Minimum speed right after direction change

@export var speed_accel_rate: float = 1.5   # How quickly speed increases over time
@export var time_to_max_speed: float = 0.5  # Time in seconds to reach max speed

var target_direction: int = 1        # Target direction (1 for right, -1 for left)
var current_direction: float = 1.0   # Current interpolated direction
var current_speed: float = move_speed  # Current movement speed
var direction_timer: float = 0.0     # Timer for tracking how long we've moved in same direction
var death_time: float = 0.0          # Timer to track death animation progress
var screen_center_x: float = 0.0     # Horizontal center of the screen

@onready var colision_shape: CollisionShape2D = $CollisionShape2D
@onready var is_alive = true
@onready var viewport_rect = get_viewport_rect()
@onready var death_fx_scene = preload('res://scenes/stool_fx.tscn')

func _ready() -> void:
	$Alive_Animation.show()
	$Dead_Sprite.hide()
	$_.hide()
	screen_center_x = viewport_rect.size.x / 2

func _physics_process(delta: float) -> void:
	if not is_alive:
		# Handle dead player movement
		handle_death_movement(delta)
		return
		
	# Apply gravity to vertical velocity with MAX_FALL_SPEED limit
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, MAX_FALL_SPEED)
	
	# Smoothly interpolate direction
	var prev_direction = current_direction
	current_direction = lerp(current_direction, float(target_direction), direction_change_speed * delta)
	
	# Detect direction change (when sign flips)
	if sign(prev_direction) != sign(current_direction):
		# Reset timer and reduce speed when direction changes
		direction_timer = 0.0
		current_speed = MIN_CHANGE_SPEED
	else:
		# Increase timer when moving in same direction
		direction_timer += delta
		
		# Gradually increase speed over time until reaching maximum
		if direction_timer < time_to_max_speed:
			var t = direction_timer / time_to_max_speed  # Normalized time (0 to 1)
			current_speed = lerp(MIN_CHANGE_SPEED, MAX_CHANGE_SPEED, t)
		else:
			current_speed = MAX_CHANGE_SPEED
	
	# Set horizontal velocity based on interpolated direction and current speed
	velocity.x = current_direction * current_speed
	
	# Move the character and handle collisions
	move_and_slide()
	
	# Rotate sprite based on interpolated direction
	$Alive_Animation.rotation_degrees = current_direction * -20
	Global.add_score(1.1)
	
	# Check if player is off screen
	check_boundaries()

func handle_death_movement(delta: float) -> void:
	# Increment death timer
	death_time += delta
	
	# Vertical movement (float upward)
	position.y += -1.5
	
	# Calculate distance to horizontal center
	var distance_to_center = screen_center_x - position.x
	
	# Curvy movement to center (fast then slow)
	# Using ease_out function: starts fast, then slows down
	var t = min(death_time * 0.7, 1.0)  # Scale time for animation speed
	var ease_factor = 1.0 - (1.0 - t) * (1.0 - t)  # Quadratic ease out
	
	# Move horizontally toward center
	position.x += distance_to_center * ease_factor * delta * 2.0
	
	# Ensure death sprite is visible
	if not $Dead_Sprite.visible:
		$Dead_Sprite.show()
		$Alive_Animation.hide()

func check_boundaries() -> void:
	if is_alive:
		var screen_margin = 5
		
		# Check if player is too far off screen
		if (position.x > viewport_rect.size.x + screen_margin or  
			position.x < -screen_margin):
			game_over()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("flap"):
		target_direction *= -1
		direction_timer = 0.0
		current_speed = MIN_CHANGE_SPEED
		if not is_alive:
			restart()

func restart() -> void:
	current_speed = 0
	current_direction = 1
	is_alive = true
	death_time = 0.0
	Global.reset_score()
	Global.cleanup()
	$Alive_Animation.show()
	$Dead_Sprite.hide()
	$AnimationPlayer.play("RESET")
	$Alive_Animation.play("default")

func game_over() -> void:
	is_alive = false
	death_time = 0.0
	velocity = Vector2(0, 0)
	play_dead()
	var death_fx = death_fx_scene.instantiate()
	add_sibling(death_fx)
	death_fx.global_position = global_position
	Global.junk_put(death_fx)
	Global.flash_fx.emit()
	print("Game Over!")

func _on_colision_detector_area_entered(area: Area2D) -> void:
	print(area)
	if area.is_in_group("obstacle"):
		game_over()

func play_dead() -> void:
	$Alive_Animation.hide()
	$Dead_Sprite.show()
	$Alive_Animation.stop()
	$Alive_Animation.play("death")
	
