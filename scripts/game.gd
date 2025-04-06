extends Node2D

@onready var start_position = $Player.position

func _ready() -> void:
	Global.restart_game.connect(func():
		Global.state = Global.GameState.MOVING
		$Player.restart()
	)
