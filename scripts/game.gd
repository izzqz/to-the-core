extends Node2D

@onready var start_position = $Player.position

func _ready() -> void:
	Global.restart_game.connect(func():
		Global.state = Global.GameState.MOVING
		$Player.restart()
	)

#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("debug_restart"):
		#$Player.position = start_position
		#$Player.restart()
#
	#if event.is_action_pressed("debug_stop"):
		#$Player.game_over()
		
