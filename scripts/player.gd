extends CharacterBody2D

@export var gravity: float = 400     # Adjust based on desired fall speed
@export var move_speed: float = 300   # Horizontal movement speed
var direction: int = 1                 # 1 for right, -1 for left

func _physics_process(delta: float) -> void:
	# Apply gravity to vertical velocity
	velocity.y += gravity * delta
	
	# Set horizontal velocity based on direction
	velocity.x = direction * move_speed
	
	# Move the character and handle collisions
	move_and_slide()
	
	# Rotate sprite based on direction (e.g., 30 degrees tilt)
	$ColorRect.rotation_degrees = direction * 30

func _input(event: InputEvent) -> void:
	# Flip direction on input
	if event.is_action_pressed("flap"):
		direction *= -1

#func _on_body_entered(body: Node) -> void:
	## Handle collisions with obstacles
	#if body.is_in_group("obstacle"):
		#game_over()
#
#func game_over() -> void:
	## Handle game over logic (e.g., reload scene, show menu)
	#print("Game Over!")
	#get_tree().reload_current_scene()
