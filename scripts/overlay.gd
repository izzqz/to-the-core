extends Control

@onready var score_label := $Score/CenterContainer/Score

func _ready() -> void:
	Global.score_changed.connect(_on_score_changed)
	Global.flash_fx.connect(play_flash_fx)
	set_score(Global.score)

func _on_score_changed(new_score: float) -> void:
	set_score(new_score)

func set_score(new_score: float) -> void:
	var km = new_score * 10.00
	score_label.text = "%dkm" % km

func play_flash_fx() -> void:
	$AnimationPlayer.play("flash")
