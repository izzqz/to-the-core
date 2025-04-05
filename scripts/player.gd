extends CharacterBody2D

@export var gravity: float = 200    # Adjust based on desired fall speed
@export var move_speed: float = 200   # Horizontal movement speed
@export var MAX_FALL_SPEED: float = 200  # Maximum falling speed
@export var direction_change_speed: float = 10.0  # How quickly direction changes (higher = faster)

@export var MAX_CHANGE_SPEED: float = 1800 # Maximum speed after direction change
@export var MIN_CHANGE_SPEED: float = 200   # Minimum speed right after direction change

@export var speed_accel_rate: float = 1.5   # How quickly speed increases over time
@export var time_to_max_speed: float = 0.5  # Time in seconds to reach max speed

var target_direction: int = 1        # Target direction (1 for right, -1 for left)
var current_direction: float = 1.0   # Current interpolated direction
var current_speed: float = move_speed  # Current movement speed
var direction_timer: float = 0.0     # Timer for tracking how long we've moved in same direction

@onready var colision_shape: CollisionShape2D = $CollisionShape2D
@onready var is_alive = true

func _physics_process(delta: float) -> void:
	if not is_alive:
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
	$AnimatedSprite2D.rotation_degrees = current_direction * -20
	Global.add_score(1)
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("flap"):
		target_direction *= -1
		direction_timer = 0.0
		current_speed = MIN_CHANGE_SPEED
		if not is_alive:
			restart()

func restart() -> void:
	is_alive = true
	Global.reset_score()
	$AnimationPlayer.play("RESET")
	$AnimatedSprite2D.play("default")

func game_over() -> void:
	is_alive = false
	play_dead()
	print("Game Over!")

func _on_colision_detector_area_entered(area: Area2D) -> void:
	print(area)
	if area.is_in_group("obstacle"):
		game_over()

func play_dead() -> void:
	$AnimatedSprite2D.stop()
	$AnimationPlayer.play("death")
	
