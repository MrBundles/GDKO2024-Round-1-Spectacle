@tool
#class_name name_of_class
extends CharacterBody2D

# purpose: 

# signals ----------------------------------------------------------------------------------------------------------------

# enums ------------------------------------------------------------------------------------------------------------------

# constants --------------------------------------------------------------------------------------------------------------

# variables --------------------------------------------------------------------------------------------------------------
@export var layer_id = 1 : set = set_layer_id

@export_group("color values")
@export var layer_colors : Array[Color] = []

@export_group("draw values")
var height : float = 32
var delta_height : float = 1
var target_height : float = 32
var width : float = 32
var rest_undulation_mult : float = 1
var rand_undulation_mult : float = 1

var rand = RandomNumberGenerator.new()


# main functions ---------------------------------------------------------------------------------------------------------
func _ready():
	# connect signals
	gSignals.start_layer_transition.connect(on_start_layer_transition)
	
	# initialize variables	
	rand.randomize()
	rand_undulation_mult += randf_range(-.2, -.1)
	
	# call functions
	


func _process(delta):
	# update width and height values
	rest_undulation_mult = clamp(rest_undulation_mult + 200 * delta, 0, 300)
	target_height = 32 + sin(Time.get_ticks_msec() / 90 * rand_undulation_mult) * rest_undulation_mult * delta
	delta_height = lerpf(delta_height, (height - target_height) * 0.5, 8 * delta)
	height -= delta_height
	width = 1024 / height
	queue_redraw()


func _draw():
	var color = layer_colors[layer_id]
	
	# draw head
	#draw_rect(Rect2(-Vector2(-16, height - 32), Vector2(width, height / 2)), color.lightened(.5), true)
	#draw_arc(Vector2(0, -height / 2 + 32), width / 4.0, deg_to_rad(5.0), deg_to_rad(-185.0), 32, color.darkened(.2), width / 2, true)
	draw_arc(Vector2(0, -height * 1.5 + 48), width / 4.0, deg_to_rad(5), deg_to_rad(-185.0), 32, color.lightened(0), (width - 4) / 2, true)
	
	# draw body
	#draw_rect(Rect2(-Vector2(width, height-64) / 2, Vector2(width, height / 2)), color, true)
	draw_rect(Rect2(Vector2(-width / 2, -height * 1.5 + 48), Vector2(width, height * 1.5 - 32)), color.lightened(0), true)
	
	# draw eye
	#var eye_position = Vector2(velocity.x / h_vel_max * 16, 16 - width*.5)
	var eye_position = Vector2(0, 32 - height*1.25)
	#draw_circle(eye_position, 16, color)
	draw_circle(eye_position, 6, color.lightened(.6))
	draw_circle(eye_position, 3, color.darkened(.5))
	
	# draw glasses
	var spectacle_size = Vector2(24, 24)
	var spectacle_thickness = 3.0
	#draw_rect(Rect2(eye_position - spectacle_size / 2, spectacle_size), color.darkened(.5), false, spectacle_thickness)
	#draw_line(eye_position + Vector2(-spectacle_size.x / 2, 0), eye_position + Vector2(-32, -2), color.darkened(.5), spectacle_thickness)
	#draw_line(eye_position + Vector2(spectacle_size.x / 2, 0), eye_position + Vector2(32, -2), color.darkened(.5), spectacle_thickness)
	


# helper functions --------------------------------------------------------------------------------------------------------


# set/get functions -------------------------------------------------------------------------------------------------------
func set_layer_id(new_val):
	layer_id = new_val
	
	for i in range(1,5):
		set_visibility_layer_bit(i-1, i == layer_id)
		set_collision_layer_value(i+4, i == layer_id)
		set_collision_mask_value(i+4, i == layer_id)

# signal functions --------------------------------------------------------------------------------------------------------
func on_start_layer_transition(new_layer_id):
	#layer_id = new_layer_id
	pass
