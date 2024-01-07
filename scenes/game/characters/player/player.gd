#@tool
#class_name name_of_class
extends CharacterBody2D

# purpose: 

# signals ----------------------------------------------------------------------------------------------------------------

# enums ------------------------------------------------------------------------------------------------------------------

# constants --------------------------------------------------------------------------------------------------------------

# variables --------------------------------------------------------------------------------------------------------------
@export_group("movement values")
@export var h_accel = 10.0
@export var h_decel = 10.0
@export var gravity = 10.0
@export var jump = 10.0
@export var h_vel_max = 100.0
@export var up_vel_max = 100.0
@export var down_vel_max = 100.0
var jump_cancel_flag = true
var transition_flag = false

@export_group("color values")
@export var layer_colors : Array[Color] = []


# main functions ---------------------------------------------------------------------------------------------------------
func _ready():
	# connect signals
	gSignals.start_layer_transition.connect(on_start_layer_transition)
	gSignals.finish_layer_transition.connect(on_finish_layer_transition)
	
	# initialize variables
	
	# call functions
	pass


func _process(delta):
	if not transition_flag:
		get_input(delta)
		move_and_slide()


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
			velocity.y = clamp(velocity.y - jump * delta, -up_vel_max, down_vel_max)
	elif Input.is_action_just_released("move_up"):
		if velocity.y < 0 and jump_cancel_flag:
			velocity.y = velocity.y / 2.0
			jump_cancel_flag = false
	else:
		velocity.y = clamp(velocity.y + gravity * delta, -up_vel_max, down_vel_max)
	

# set/get functions -------------------------------------------------------------------------------------------------------


# signal functions --------------------------------------------------------------------------------------------------------
func on_start_layer_transition(new_layer_id):
	#transition_flag = true
	pass
	
	#for i in range(1,5):
		#set_collision_layer_value(i, i==0)
		#set_collision_mask_value(i, i==0)


func on_finish_layer_transition(new_layer_id):
	#transition_flag = false
	
	for i in range(1,5):
		set_collision_layer_value(i, i==new_layer_id)
		set_collision_mask_value(i, i==new_layer_id)
		print(get_collision_layer_value(i))
