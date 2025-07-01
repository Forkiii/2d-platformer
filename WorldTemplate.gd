extends Node2D
@export var next_level: PackedScene
var level_time = 0.0
var start_level_msec = 0.0
@onready var level_completed: ColorRect = $CanvasLayer/LevelCompleted
@onready var start_in_label: Label = $CanvasLayer/StartIn/CenterContainer/StartInLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var level_time_label: Label = %LevelTimeLabel
@onready var sound_manager: Node = $SoundManager
@onready var start_button: Button = %StartButton

func _ready():
	if not next_level is PackedScene:
		next_level=load("res://victory_screen.tscn")
	Events.level_completed.connect(show_level_completed)
	get_tree().paused = true
	await get_tree().create_timer(0.5).timeout
	get_tree().paused = false
	start_level_msec =  Time.get_ticks_msec()

	
func _process(delta):
	level_time = Time.get_ticks_msec() - start_level_msec
	level_time_label.text= str(level_time/1000.0)
		
func go_to_next_level():
	if not next_level is PackedScene: return
	await LevelTransition.fade_to_black()
	LevelTransition.fade_from_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
func show_level_completed():
	level_completed.show() 	
	level_completed.retry_button.grab_focus()
	get_tree().paused = true
	
		

func _on_level_completed_next_level() -> void:
	go_to_next_level()
func _on_level_completed_retry() -> void:
	get_tree().reload_current_scene()	
