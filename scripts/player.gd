extends CharacterBody2D
# 500
@export var gravity: float = 2500    # Adjust based on desired fall speed
@export var move_speed: float = 200   # Horizontal movement speed
@export var MAX_FALL_SPEED: float = 2600  # Maximum falling speed
@export var direction_change_speed: float = 10.0  # How quickly direction changes (higher = faster)

@export var MAX_VELOCITY: float = 1800 # Maximum velocity in either direction
@export var MIN_VELOCITY: float = 200   # Minimum velocity after direction change

@export var velocity_increase_rate: float = 5.0   # How quickly velocity increases when moving in that direction
@export var velocity_decrease_rate: float = 2.0   # How quickly velocity decreases for the opposite direction

var target_direction: int = 1        # Target direction (1 for right, -1 for left)
var current_direction: float = 1.0   # Current interpolated direction
var current_left_velocity: float = 0.0  # Velocity when moving left
var current_right_velocity: float = MIN_VELOCITY  # Velocity when moving right
var death_time: float = 0.0          # Timer to track death animation progress
var screen_center_x: float = 0.0     # Horizontal center of the screen

@onready var colision_shape: CollisionShape2D = $CollisionShape2D
@onready var is_alive = true
@onready var is_frozen = true
@onready var viewport_rect = get_viewport_rect()
@onready var death_fx_scene = preload('res://scenes/stool_fx.tscn')
@onready var start_position = self.position

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
	
	if is_frozen: return
	
	# Apply gravity to vertical velocity with MAX_FALL_SPEED limit
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, MAX_FALL_SPEED)
	
	# Smoothly interpolate direction
	var prev_direction = current_direction
	current_direction = lerp(current_direction, float(target_direction), direction_change_speed * delta)
	
	# Update velocities based on current direction
	if target_direction > 0:  # Moving right
		# Increase right velocity
		current_right_velocity = min(current_right_velocity + velocity_increase_rate * delta * MAX_VELOCITY, MAX_VELOCITY)
		# Decrease left velocity
		current_left_velocity = max(current_left_velocity - velocity_decrease_rate * delta * MAX_VELOCITY, 0)
	else:  # Moving left
		# Increase left velocity
		current_left_velocity = min(current_left_velocity + velocity_increase_rate * delta * MAX_VELOCITY, MAX_VELOCITY)
		# Decrease right velocity
		current_right_velocity = max(current_right_velocity - velocity_decrease_rate * delta * MAX_VELOCITY, 0)
	
	# Detect direction change (when sign flips)
	if sign(prev_direction) != sign(current_direction):
		# Reset velocities when direction changes
		if target_direction > 0:  # Changed to right
			current_right_velocity = MIN_VELOCITY
		else:  # Changed to left
			current_left_velocity = MIN_VELOCITY
	
	# Set horizontal velocity based on direction and corresponding velocity
	if current_direction > 0:
		velocity.x = current_right_velocity * current_direction
	else:
		velocity.x = current_left_velocity * current_direction
	
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
		var screen_margin = 100
		
		# Check if player is too far off screen
		if (position.x > viewport_rect.size.x + screen_margin or  
			position.x < -screen_margin):
			game_over()

func _input(event: InputEvent) -> void:
	if Global.state == Global.GameState.DEATH_SCREEN:
		return

	if event.is_action_pressed("flap"):
		target_direction *= -1
		if target_direction > 0:
			current_right_velocity = MIN_VELOCITY
		else:
			current_left_velocity = MIN_VELOCITY
		if not is_alive:
			restart()
		if is_frozen:
			is_frozen = false

func restart() -> void:
	current_direction = 1
	target_direction = -1
	current_left_velocity = 0
	current_right_velocity = 0
	is_alive = true
	is_frozen = true
	death_time = 0.0
	self.position = start_position
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
	Global.game_over.emit()

func _on_colision_detector_area_entered(area: Area2D) -> void:
	if Global.state == Global.GameState.DEATH_SCREEN:
		return

	#if area.is_in_group("obstacle"):
		#game_over()

func play_dead() -> void:
	$Alive_Animation.hide()
	$Dead_Sprite.show()
	$Alive_Animation.stop()
	$Alive_Animation.play("death")
	
