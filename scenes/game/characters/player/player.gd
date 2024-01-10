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
var rest_undulation_mult = 1

@export_group("trail values")
@export var debug_draw_trail : bool = false
@export var baby_list : Array = []
var trail_node_list = []
var previous_valid_trail_node = {}



# main functions ---------------------------------------------------------------------------------------------------------
func _ready():
	# connect signals
	gSignals.start_layer_transition.connect(on_start_layer_transition)
	gSignals.finish_layer_transition.connect(on_finish_layer_transition)
	
	# initialize variables
	previous_valid_trail_node = {"pos" : position, "height" : height, "valid" : is_on_floor()}
	
	# call functions
	pass


func _process(delta):
	if not transition_flag and not Engine.is_editor_hint():
		get_input(delta)
		move_and_slide()
	
	update_squish(delta)
	add_trail_node()
	update_babies()
	queue_redraw()

func _draw():
	if not v_vel_max or not h_vel_max: return
	
	var color = layer_colors[layer_id]
	
	# draw trail
	if debug_draw_trail:
		for node in trail_node_list:
			var node_color = color.darkened(.2)
			if node["valid"]:
				node_color = color.lightened(.2)
				
			draw_circle(node["pos"] - global_position, 8, node_color)
	
	# draw head
	#draw_rect(Rect2(-Vector2(-16, height - 32), Vector2(width, height / 2)), color.lightened(.5), true)
	#draw_arc(Vector2(0, -height / 2 + 32), width / 4.0, deg_to_rad(5.0), deg_to_rad(-185.0), 32, color.darkened(.2), width / 2, true)
	var start_angle = deg_to_rad(5)
	var end_angle = deg_to_rad(-185.0)
	draw_arc(Vector2(0, -height * 1.5 + 96), width / 4.0, start_angle, end_angle, 32, color, (width - 4) / 2, true)
	
	# draw body
	#draw_rect(Rect2(-Vector2(width, height-64) / 2, Vector2(width, height / 2)), color, true)
	draw_rect(Rect2(Vector2(-width / 2, -height * 1.5 + 96), Vector2(width, height * 1.5 - 64)), color, true)
	
	# draw eye
	#var eye_position = Vector2(velocity.x / h_vel_max * 16, 16 - width*.5)
	var eye_position = Vector2(velocity.x / h_vel_max * 16, 64 - height*1.25)
	#draw_circle(eye_position, 16, color)
	draw_circle(eye_position, 8, color.lightened(.6))
	draw_circle(eye_position, 4, color.darkened(.5))
	
	# draw glasses
	var spectacle_size = Vector2(24, 24)
	var spectacle_thickness = 3.0
	#draw_rect(Rect2(eye_position - spectacle_size / 2, spectacle_size), color.darkened(.5), false, spectacle_thickness)
	#draw_line(eye_position + Vector2(-spectacle_size.x / 2, 0), eye_position + Vector2(-32, -2), color.darkened(.5), spectacle_thickness)
	#draw_line(eye_position + Vector2(spectacle_size.x / 2, 0), eye_position + Vector2(32, -2), color.darkened(.5), spectacle_thickness)


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
	
	# process coyote timer
	if is_on_floor():
		$CoyoteTimer.start()
		velocity.y = 0
		jump_cancel_flag = true
	
	# process jump inputs
	if Input.is_action_pressed("move_up") and not $CoyoteTimer.is_stopped():
		velocity.y = clamp(velocity.y - jump * delta, -v_vel_max, v_vel_max)
		$CoyoteTimer.stop()
	elif Input.is_action_just_released("move_up") and velocity.y < 0 and jump_cancel_flag:
		velocity.y = velocity.y / 2.0
		jump_cancel_flag = false
	else:
		velocity.y = clamp(velocity.y + gravity * delta, -v_vel_max, v_vel_max)


func update_babies():
	for i in range(baby_list.size()):
		var baby = baby_list[i]
		var current_pos_id = 0
		var target_pos_id = 0
		var offset = Vector2(0, 16)
		
		# iterate once through the list of nodes to identify the current and target node indexes
		var valid_node_count = 0
		for j in range(trail_node_list.size()):
			# if both the current and target node indexes have been found, escape the loop
			if current_pos_id != 0 and target_pos_id != 0:
				break
			else:
				var node = trail_node_list[j]
				if current_pos_id == 0 and node["pos"] + offset == baby.position:
					current_pos_id = j
				if target_pos_id == 0 and node["valid"]:
					valid_node_count += 1
					if valid_node_count > i + 1:
						target_pos_id = j
		
		if current_pos_id > target_pos_id:
			current_pos_id -= 1
		elif current_pos_id < target_pos_id:
			current_pos_id += 1
		
		var current_pos = trail_node_list[current_pos_id]["pos"]
		var current_height = trail_node_list[current_pos_id]["height"]
		baby.position = current_pos + offset
		if current_pos_id != target_pos_id:
			baby.height = current_height / 2


func update_squish(delta):
	# update width and height values
	if is_on_floor():
		if velocity.x == 0:
			rest_undulation_mult = clamp(rest_undulation_mult + 200 * delta, 0, 400)
			target_height = 64 + sin(Time.get_ticks_msec() / 173.0) * rest_undulation_mult * delta
		else:
			target_height = 64 - 12 * abs(velocity.x) / h_vel_max
			rest_undulation_mult = 0
	else:
		target_height = 64 - 24 * velocity.y / v_vel_max
		rest_undulation_mult = 0
	
	delta_height = lerpf(delta_height, (height - target_height) * 0.5, 8 * delta)
	height -= delta_height
	width = 4096 / height


func add_trail_node():
	if velocity.length() < 1: return
	
	# define and add a new trail node to the list
	var valid = is_on_floor() and position.distance_to(previous_valid_trail_node["pos"]) > 48
	var trail_node = {"pos" : position, "height" : height, "valid" : valid}
	trail_node_list.insert(0, trail_node)
	
	# if this position is a valid location for a trail node, set the previous trail node to this node
	if valid:
		previous_valid_trail_node = trail_node
	
	# limit the length of the trail node list to 100 nodes
	while trail_node_list.size() > 1000:
		trail_node_list.pop_back()


# set/get functions -------------------------------------------------------------------------------------------------------
func set_layer_id(new_val):
	layer_id = new_val


# signal functions --------------------------------------------------------------------------------------------------------
func on_start_layer_transition(new_layer_id):
	layer_id = new_layer_id
	
	for i in range(1,5):
		set_collision_layer_value(i, i==new_layer_id)
		set_collision_mask_value(i, i==new_layer_id)


func on_finish_layer_transition(new_layer_id):
	pass


func _on_area_2d_body_entered(body):
	if body.is_in_group("baby") and not body in baby_list:
		baby_list.append(body)
