@tool
#class_name name_of_class
extends CharacterBody2D

# purpose: 

# signals ----------------------------------------------------------------------------------------------------------------

# enums ------------------------------------------------------------------------------------------------------------------

# constants --------------------------------------------------------------------------------------------------------------

# variables --------------------------------------------------------------------------------------------------------------
@export var layer_id = 0 : set = set_layer_id

@export_group("movement values")
@export var h_accel = 10.0
@export var h_decel = 10.0
@export var gravity = 10.0
@export var jump = 10.0
@export var h_vel_max = 100.0
@export var v_vel_max = 100.0
var jump_cancel_flag = true
var transition_flag = false

@export_group("color values")
@export var layer_colors : Array[Color] = []

@export_group("draw values")
var height : float = 64
var delta_height : float = 1
var target_height : float = 64
var width : float = 64


# main functions ---------------------------------------------------------------------------------------------------------
func _ready():
	# connect signals
	gSignals.start_layer_transition.connect(on_start_layer_transition)
	gSignals.finish_layer_transition.connect(on_finish_layer_transition)
	
	# initialize variables
	
	# call functions
	pass


func _process(delta):
	if not transition_flag and not Engine.is_editor_hint():
		get_input(delta)
		move_and_slide()
	
	# update width and height values
	if is_on_floor():
		if velocity.x == 0:
			target_height = 64 + sin(Time.get_ticks_msec() / 200.0) * 400 * delta
		else:
			target_height = 64 - 8 * abs(velocity.x) / h_vel_max
			$MoveTimer.start()
	else:
		target_height = 64 - 24 * velocity.y / v_vel_max
	
	delta_height = lerpf(delta_height, (height - target_height) * 0.5, 8 * delta)
	height -= delta_height
	width = 4096 / height
	queue_redraw()


func _draw():
	if not v_vel_max or not h_vel_max: return
	
	var color = layer_colors[layer_id]
	
	# draw head
	#draw_rect(Rect2(-Vector2(-16, height - 32), Vector2(width, height / 2)), color.lightened(.5), true)
	#draw_arc(Vector2(0, -height / 2 + 32), width / 4.0, deg_to_rad(5.0), deg_to_rad(-185.0), 32, color.darkened(.2), width / 2, true)
	draw_arc(Vector2(0, -height * 1.5 + 96), width / 4.0, deg_to_rad(10), deg_to_rad(-190.0), 32, color.darkened(0), (width - 4) / 2, true)
	
	# draw body
	#draw_rect(Rect2(-Vector2(width, height-64) / 2, Vector2(width, height / 2)), color, true)
	draw_rect(Rect2(Vector2(-width / 2, -height * 1.5 + 96), Vector2(width, height * 1.5 - 64)), color, true)
	
	#draw eye
	#var eye_position = Vector2(velocity.x / h_vel_max * 16, 16 - width*.5)
	var eye_position = Vector2(velocity.x / h_vel_max * 16, 64 - height*1.25)
	#draw_circle(eye_position, 16, color)
	draw_circle(eye_position, 8, color.lightened(.6))
	draw_circle(eye_position, 4, color.darkened(.5))
	


# helper functions --------------------------------------------------------------------------------------------------------
func get_input(delta):
	# process horizontal inputs
	if Input.is_action_pressed("move_left"):
		velocity.x = clamp(velocity.x - h_accel * delta, -h_vel_max, h_vel_max)
	elif Input.is_action_pressed("move_right"):
		velocity.x = clamp(velocity.x + h_accel * delta, -h_vel_max, h_vel_max)
	elif velocity.x < -h_decel * delta:
		velocity.x = clamp(velocity.x + h_decel * delta, -h_vel_max, h_vel_max)
	elif velocity.x > h_decel * delta:
		velocity.x = clamp(velocity.x - h_decel * delta, -h_vel_max, h_vel_max)
	else:
		velocity.x = 0
	
	# process bumps on ceiling
	if is_on_ceiling():
		velocity.y += 1 * delta
	
	# process bumps on walls
	if is_on_wall():
		if velocity.x < 0:
			velocity.x = 10
		elif velocity.x > 0:
			velocity.x = -10
	
	# process coyote timer
	if is_on_floor():
		$CoyoteTimer.start()
		velocity.y = 0
		jump_cancel_flag = true
	
	# process jump inputs
	if Input.is_action_pressed("move_up") and not $CoyoteTimer.is_stopped():
		velocity.y = clamp(velocity.y - jump * delta, -v_vel_max, v_vel_max)
	elif Input.is_action_just_released("move_up") and velocity.y < 0 and jump_cancel_flag:
		velocity.y = velocity.y / 2.0
		jump_cancel_flag = false
	else:
		velocity.y = clamp(velocity.y + gravity * delta, -v_vel_max, v_vel_max)
	

# set/get functions -------------------------------------------------------------------------------------------------------
func set_layer_id(new_val):
	layer_id = new_val


# signal functions --------------------------------------------------------------------------------------------------------
func on_start_layer_transition(new_layer_id):
	set_collision_layer_value(new_layer_id, true)
	layer_id = new_layer_id


func on_finish_layer_transition(new_layer_id):
	for i in range(1,5):
		set_collision_layer_value(i, i==new_layer_id)
		set_collision_mask_value(i, i==new_layer_id)


func _on_coyote_timer_timeout():
	$CoyoteTimer.stop()
	print("timer stopped")
