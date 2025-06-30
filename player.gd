extends CharacterBody2D


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var movement_data : PlayerMovementData
var air_jump = false
var just_wall_jumped 
var game_started = false
var is_wall_sliding := false
var wall_normal := 0 # 1 for right wall, -1 for left wall
@onready var sound_manager: Node = $SoundManager
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer: Timer = $CoyoteJumpTimer
@onready var starting_position = global_position
@export var wall_jump_velocity := Vector2(180.0, -150.0) # x, y components
@export var wall_slide_gravity := 10.0
@export var max_wall_slide_speed := 50.0
@export var was_on_floor_jump = is_on_floor()
@export var played_jump = false
@onready var bgm: AudioStreamPlayer2D = $SoundManager/bgm

var jump_sound_reset = true
var time_midair= 0.0
var switch_foot=true
var time_spent_wakling= 0.0


func _physics_process(delta):
	var input_axis := Input.get_axis("ui_left", "ui_right")
	if not game_started and (input_axis != 0 or Input.is_action_just_pressed("ui_accept")):
		game_started = true
	if game_started:
		apply_gravity(delta)
		handle_wall_jump(input_axis)
		handle_jump()
		handle_acceleration(input_axis,delta)
		handle_air_acceleration(input_axis,delta)
		apply_friction(input_axis,delta)
		apply_air_resistance(input_axis,delta)
		wallslide(delta)
		exit_map_bounds()
		move_and_slide()
		var was_on_floor = is_on_floor()
		var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
		if just_left_ledge:
			coyote_jump_timer.start()
		just_wall_jumped = false
		
		
		
	##animations
		update_animations(input_axis)
		
	###sounds
		if is_on_floor():
			play_footsteps(delta) 

		
		
#functions
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta * movement_data.gravity_scale
func wallslide(delta):
	if not game_started:
		is_wall_sliding = false
		return
	if is_on_wall_only() and not is_on_floor() and velocity.y > 0:
		is_wall_sliding = true
		velocity.y = min(velocity.y + wall_slide_gravity, max_wall_slide_speed)
	else:
		is_wall_sliding = false
func handle_wall_jump(input_axis):
	if not is_on_wall_only(): 
		is_wall_sliding = false
		return
	var wall_normal = get_wall_normal()   
	is_wall_sliding = true
	if is_wall_sliding:
		velocity.x = 0  
	if input_axis != 0:
		animated_sprite_2d.flip_h = (input_axis < 0)
	velocity.y = min(velocity.y + wall_slide_gravity, max_wall_slide_speed)
	if not is_on_wall_only(): return
	if Input.is_action_just_pressed("ui_right")and wall_normal.x > 0.5:
		velocity.x = wall_normal.normalized().x * movement_data.speed
		velocity.y = movement_data.jump_velocity
		sound_manager.play_jump()
		just_wall_jumped = true
	if Input.is_action_just_pressed("ui_left") and wall_normal.x < -0.5:
		velocity.x = wall_normal.normalized().x * movement_data.speed
		velocity.y= movement_data.jump_velocity
		sound_manager.play_jump()
		just_wall_jumped = true
func handle_jump():
	# reset air jump
	if is_on_floor(): 
		air_jump = true
	#normal jump
	if (is_on_floor() or coyote_jump_timer.time_left > 0.1) and not just_wall_jumped:
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = movement_data.jump_velocity
			sound_manager.play_jump()
			coyote_jump_timer.stop()
	#short jump
	elif not is_on_floor():
		if Input.is_action_just_released("ui_accept") and velocity.y < movement_data.jump_velocity/2:
			velocity.y = movement_data.jump_velocity/2
	#airjump 
		if Input.is_action_just_pressed("ui_accept") and air_jump and not just_wall_jumped:
			velocity.y = movement_data.jump_velocity * 0.8
			sound_manager.play_jump()
			air_jump=false
func handle_acceleration(input_axis,delta):
	if not is_on_floor():return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x,movement_data.speed * input_axis,movement_data.acceleration * delta)

func apply_friction(input_axis,delta):
	if input_axis==0:
		velocity.x = move_toward(velocity.x,0,movement_data.friction * delta)
func apply_air_resistance(input_axis,delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x=move_toward(velocity.x,0,movement_data.air_resistance * delta)
func handle_air_acceleration(input_axis,delta):
	if is_on_floor():return
	if input_axis !=0:
		velocity.x=move_toward(velocity.x, movement_data.speed * input_axis,
		 movement_data.air_acceleration * delta)
#animations
func update_animations(input_axis):
	if input_axis !=0 and not is_on_wall() and is_on_floor():
		animated_sprite_2d.flip_h=(input_axis<0)
		animated_sprite_2d.play("run")
	elif not is_on_floor() and not is_on_wall():
		animated_sprite_2d.play("jump")
		if(Input.is_action_pressed("ui_left")):
			animated_sprite_2d.flip_h=(-1)
		if(Input.is_action_pressed("ui_right")):
			animated_sprite_2d.flip_h=(0)	
	elif is_wall_sliding:
		air_jump=true
		animated_sprite_2d.play("climb")
	else:
		animated_sprite_2d.play("idle")
func _on_hazard_detector_area_entered(area):
	get_tree().reload_current_scene()
func exit_map_bounds():
	if(position.y>599):
		get_tree().reload_current_scene()
		
		
func play_footsteps(delta):
		if velocity.x==0:
			time_spent_wakling=0
		else:
			time_spent_wakling+=delta
			if(time_spent_wakling>0.15):
				if(switch_foot):
					sound_manager.play_step_two()
					
				else:
					sound_manager.play_step_one()
				switch_foot=!switch_foot
				time_spent_wakling=0
