extends CharacterBody2D

@export var gravity: float = 400     # Adjust based on desired fall speed
@export var move_speed: float = 300   # Horizontal movement speed
@export var MAX_FALL_SPEED: float = 500  # Maximum falling speed
@export var direction_change_speed: float = 10.0  # How quickly direction changes (higher = faster)

var target_direction: int = 1        # Target direction (1 for right, -1 for left)
var current_direction: float = 1.0   # Current interpolated direction

func _physics_process(delta: float) -> void:
	# Apply gravity to vertical velocity with MAX_FALL_SPEED limit
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, MAX_FALL_SPEED)
	
	# Smoothly interpolate direction
	current_direction = lerp(current_direction, float(target_direction), direction_change_speed * delta)
	
	# Set horizontal velocity based on interpolated direction
	velocity.x = current_direction * move_speed
	
	# Move the character and handle collisions
	move_and_slide()
	
	# Rotate sprite based on interpolated direction
	$ColorRect.rotation_degrees = current_direction * 30

func _input(event: InputEvent) -> void:
	# Change target direction on input
	if event.is_action_pressed("flap"):
		target_direction *= -1

#func _on_body_entered(body: Node) -> void:
	## Handle collisions with obstacles
	#if body.is_in_group("obstacle"):
		#game_over()
#
#func game_over() -> void:
	## Handle game over logic (e.g., reload scene, show menu)
	#print("Game Over!")
	#get_tree().reload_current_scene()
