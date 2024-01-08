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
var height = 64
var delta_height = 1
var target_height = 64
var width = 64
var delta_width = 1
var target_width = 64


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
	
	queue_redraw()


func _draw():
	if not v_vel_max or not h_vel_max: return
	
	# update width and height values
	
	target_height = 64 - 32 * velocity.y / v_vel_max
	delta_height = lerpf(delta_height, (height - target_height) * 0.5, .2)
	height -= delta_height
	width = 4096 / height
	print("height: %s	delta_height: %s	target_height: %s" % [height, delta_height, target_height])


	var color = layer_colors[layer_id]
	
	# draw head
	var head_pos = Vector2.ZERO + Vector2(0, sin(Time.get_ticks_msec() / 200.0) * 4)
	draw_arc(head_pos, width / 4, 0, -PI, 32, color, 32, true)
	#draw_circle(Vector2.ZERO, size.x / 2, Color.WHITE)
	
	# draw body
	draw_rect(Rect2(-Vector2(width, height) / 2, Vector2(width, height)), color, true)


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
			velocity.x = 1 * delta
		elif velocity.x > 0:
			velocity.x = -1 * delta
	
	# process coyote timer
	if is_on_floor():
		$CoyoteTimer.start()
		velocity.y = 0
		jump_cancel_flag = true
	
	# process jump inputs
	if Input.is_action_just_pressed("move_up"):
		if $CoyoteTimer.time_left > 0:
			velocity.y = clamp(velocity.y - jump * delta, -v_vel_max, v_vel_max)
	elif Input.is_action_just_released("move_up"):
		if velocity.y < 0 and jump_cancel_flag:
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
