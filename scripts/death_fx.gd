extends Node2D

@export var animation_duration: float = 15
@export var random_spread: float = 300
@export var initial_velocity_scale: float = 700.0
@export var rotation_min: float = -10.0  # Minimum rotation in radians
@export var rotation_max: float = 10.0   # Maximum rotation in radians

var animations_active: int = 0

func _ready():
	animations_active = get_child_count()

	for node in get_children():
		node.hide()
	fire()

func fire() -> void:
	for node in get_children():
		node.show()
		throw_node(node)

func throw_node(node: Node2D):
	# Store initial position
	var initial_position = node.global_position
	var initial_rotation = node.rotation
	
	# Get the camera and viewport
	var viewport = get_viewport()
	var camera = viewport.get_camera_2d()
	
	# Calculate screen center in global coordinates
	var viewport_size = viewport.get_visible_rect().size
	var screen_center
	
	if camera:
		# If camera exists, use its position to find the actual center of the screen
		screen_center = camera.get_screen_center_position()
	else:
		# Fallback to viewport center if no camera
		screen_center = Vector2(viewport_size.x / 2, viewport_size.y / 2)
	
	# Calculate target position (screen center with some random spread)
	var random_offset = Vector2(
		randf_range(-random_spread, random_spread),
		randf_range(-random_spread, random_spread)
	)
	
	# Use screen center but keep vertical position if needed
	var target_position = screen_center + random_offset
	
	# Generate random final rotation
	var target_rotation = initial_rotation + randf_range(rotation_min, rotation_max)
	
	# Calculate initial velocity direction (away from target)
	var direction = (initial_position - target_position).normalized()
	var initial_velocity = direction * initial_velocity_scale
	
	# Create and configure tween for curved animation
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	
	# Add parallel property tracks for position and rotation
	tween.tween_property(node, "global_position", target_position, animation_duration)
	tween.parallel().tween_property(node, "rotation", target_rotation, animation_duration)
	
	# Connect signal for when animation completes
	tween.finished.connect(func(): _on_animation_completed())

func _on_animation_completed():
	animations_active -= 1
	if animations_active <= 0:
		# All animations have completed
		pass
