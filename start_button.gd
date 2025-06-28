extends Button

@onready var start_button: Button = %StartButton
func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	start_button.grab_focus()
	pass
func _on_pressed_on_start_button_pressed() -> void:
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://LevelOne.tscn")
	LevelTransition.fade_from_black()
func _on_quit_button_pressed() -> void:
	get_tree().quit()
	
	
