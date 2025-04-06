extends Control

@onready var score_label: Label = $Score/CenterContainer/Score
@onready var restart_button: Button = $Score/CenterContainer2/Restart_Button

var is_death_screen = true
var is_fist_start = true

func _ready() -> void:
	Global.score_changed.connect(_on_score_changed)
	Global.flash_fx.connect(play_flash_fx)
	Global.game_over.connect(_on_game_over)
	set_score(Global.score)
	
	if (is_fist_start):
		restart_button.text = "Start"
		is_fist_start = false

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("flap") and is_death_screen):
		_on_restart_button_pressed()

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
	$AnimationPlayer.play("fadeout")

func _on_game_over() -> void:
	if (!is_fist_start):
		restart_button.text = "Restart"
	restart_button.show()
	is_death_screen = true
	Global.state = Global.GameState.DEATH_SCREEN
