extends CenterContainer
@onready var main_menu_button: Button = $VBoxContainer/main_menu_button

func _ready() -> void:
	main_menu_button.grab_focus()
func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://start_menu.tscn")
	
