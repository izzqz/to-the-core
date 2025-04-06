extends Node

var score := 0.0
signal score_changed(new_score: float)
signal flash_fx
signal restart_game
signal game_over

var SKINS := [
	{
		"name": "default",
		"preview": preload("res://assets/player/skins/bozhidar/player_skin.png"),
		"alive_animation": preload("res://assets/player/skins/bozhidar/default_alive_animation.tres"),
		"popa": preload("res://assets/player/skins/bozhidar/player_popa.png")
	},
	{
		"name": "amogus",
		"preview": preload("res://assets/player/skins/amogus/amgs_skin.png"),
		"alive_animation": preload("res://assets/player/skins/amogus/amogus_alive_animation.tres"),
		"popa": preload("res://assets/player/skins/amogus/amgs_popa.png")
	},
	{
		"name": "lady",
		"preview": preload("res://assets/player/skins/pink/pink_skin.png"),
		"alive_animation": preload("res://assets/player/skins/pink/lady_alive_animation.tres"),
		"popa": preload("res://assets/player/skins/pink/pink_popa.png")
	}
]

enum GameState {
	DEATH_SCREEN,
	MOVING
}

var junk: Array[Node] = []
var current_skin: int = 0
var state = GameState.DEATH_SCREEN

func add_score(amount: float) -> void:
	score += amount
	score_changed.emit(score)

func reset_score() -> void:
	score = 0
	score_changed.emit(score)

func junk_put(node: Node) -> void:
	junk.push_front(node)

func cleanup() -> void:
	for node in junk:
		node.queue_free()

	junk = []
