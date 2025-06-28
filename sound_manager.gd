extends Node
@onready var foot_one: AudioStreamPlayer2D = $foot_one
@onready var foot_two: AudioStreamPlayer2D = $foot_two
@onready var jump_sound: AudioStreamPlayer2D = $jump_sound
@onready var bgm: AudioStreamPlayer2D = $bgm
@onready var footstep_cooldown: Timer = $footstep_cooldown

func _ready() -> void:
		bgm.play()

func play_step_one():
	if footstep_cooldown.time_left>0:
		return
	foot_one.play()
	footstep_cooldown.start()

func play_step_two():
	if footstep_cooldown.time_left>0:
		return
	foot_two.play()
	footstep_cooldown.start()
	
func play_jump():
	jump_sound.play()
