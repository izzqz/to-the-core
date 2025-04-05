extends Node2D

@onready var start_position = $Player.position

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_restart"):
		$Player.position = start_position
		$Player.is_alive = false
		$Player.restart()

	if event.is_action_pressed("debug_stop"):
		$Player.game_over()
		
