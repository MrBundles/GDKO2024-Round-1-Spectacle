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

# main functions ---------------------------------------------------------------------------------------------------------
func _ready():
	# connect signals
	
	# initialize variables
	
	# call functions
	pass


func _process(delta):
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


