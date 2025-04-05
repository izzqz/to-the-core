extends Node2D

@export var animation_duration: float = 15
@export var random_spread: float = 300
@export var initial_velocity_scale: float = 700.0
@export var rotation_min: float = -10.0  # Minimum rotation in radians
@export var rotation_max: float = 10.0   # Maximum rotation in radians

var screen_center_x: float
var animations_active: int = 0

func _ready():
	screen_center_x = get_viewport_rect().size.x / 2
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
	
	# Calculate target position (horizontal center with some random spread)
	var random_offset = Vector2(
		randf_range(-random_spread, random_spread),
		randf_range(-random_spread, random_spread)
	)
	
	# Use horizontal center but keep original vertical position
	var target_position = Vector2(screen_center_x, initial_position.y) + random_offset
	
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
