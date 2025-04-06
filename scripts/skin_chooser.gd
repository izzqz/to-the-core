extends CenterContainer

@onready var left_button: Button = $HBoxContainer/Left_Button
@onready var right_button: Button = $HBoxContainer/Right_Button
@onready var skin_preview: TextureRect = $HBoxContainer/Skin_Preview

var current_skin_index := 0

func _ready() -> void:
	update_skin_display()

func update_skin_display() -> void:
	skin_preview.texture = Global.SKINS.get(current_skin_index).preview
	Global.current_skin = current_skin_index

func _on_left_button_pressed() -> void:
	current_skin_index = (current_skin_index - 1 + Global.SKINS.size()) % Global.SKINS.size()
	update_skin_display()

func _on_right_button_pressed() -> void:
	current_skin_index = (current_skin_index + 1) % Global.SKINS.size()
	update_skin_display()
