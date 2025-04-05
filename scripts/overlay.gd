extends Control

@onready var score_label := $Score/CenterContainer/Score

func _ready() -> void:
	Global.score_changed.connect(_on_score_changed)
	Global.flash_fx.connect(play_flash_fx)
	set_score(Global.score)

func _on_score_changed(new_score: int) -> void:
	set_score(new_score)

func set_score(new_score: int) -> void:
	var meters = float(new_score) / 100.0  # Use 100.0 to ensure float division
	score_label.text = "%.1fm" % meters  # %.1f formats to one decimal place

func play_flash_fx() -> void:
	$AnimationPlayer.play("flash")
