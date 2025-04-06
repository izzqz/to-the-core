extends Control

@onready var score_label: Label = $Score/CenterContainer/Score
@onready var skin_chooser: CenterContainer = $Score/Skin_Chooser
@onready var restart_button: TextureButton = $Score/CenterContainer2/Restart_Button

@onready var play_button_texture := preload("res://assets/ui/play.png")
@onready var restart_button_texture := preload("res://assets/ui/restart.png")

var is_death_screen = true
var is_fist_start = true

func _ready() -> void:
	Global.score_changed.connect(_on_score_changed)
	Global.flash_fx.connect(play_flash_fx)
	Global.game_over.connect(_on_game_over)
	set_score(Global.score)
	
	if (is_fist_start):
		restart_button.texture_normal = play_button_texture
		is_fist_start = false

func _on_score_changed(new_score: float) -> void:
	set_score(new_score)

func set_score(new_score: float) -> void:
	var km = new_score * 10.00
	score_label.text = "%dkm" % km

func play_flash_fx() -> void:
	$AnimationPlayer.play("flash")

func _on_restart_button_pressed() -> void:
	Global.restart_game.emit()
	is_death_screen = false
	Global.state = Global.GameState.MOVING
	restart_button.hide()
	skin_chooser.hide()
	$AnimationPlayer.play("fadeout")

func _on_game_over() -> void:
	if (!is_fist_start):
		restart_button.texture_normal = restart_button_texture
	restart_button.show()
	skin_chooser.show()
	is_death_screen = true
	Global.state = Global.GameState.DEATH_SCREEN

func _on_background_button_down() -> void:
	_on_restart_button_pressed()
