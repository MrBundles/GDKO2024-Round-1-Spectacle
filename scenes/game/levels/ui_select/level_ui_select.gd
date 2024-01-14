#@tool
#class_name name_of_class
extends Area2D

# purpose: 

# signals ----------------------------------------------------------------------------------------------------------------

# enums ------------------------------------------------------------------------------------------------------------------
enum UI_TYPES {back, reset}
# constants --------------------------------------------------------------------------------------------------------------

# variables --------------------------------------------------------------------------------------------------------------
@export var ui_type : UI_TYPES = UI_TYPES.back
@export var layer_colors : Array[Color] = []
var hovered = false
var clicked = false : set = set_clicked
var length_normal = 150
var length_hovered = 200
var length_clicked = 225
var length_current = 200
var length_target = 200

# main functions ---------------------------------------------------------------------------------------------------------
func _ready():
	# connect signals
	
	# initialize variables
	length_current = length_normal
	
	# call functions
	update_length()


func _process(delta):
	get_input(delta)
	queue_redraw()


func _draw():
	#draw_circle(Vector2(-length_current, 0), length_current * tan(deg_to_rad(11.25)), layer_colors[layer_id])
	draw_arc(Vector2.ZERO, length_current / 2, deg_to_rad(156.5), deg_to_rad(203.5), 32, layer_colors[gVariables.current_layer_id].darkened(.5), length_current, true)


# helper functions --------------------------------------------------------------------------------------------------------
func get_input(delta):
	clicked = Input.is_action_just_released("mouse_click") and hovered


func update_length():
	var tween_duration = 0.5
	var tween = get_tree().create_tween()
	
	if clicked:
		length_target = length_clicked
	elif hovered:
		length_target = length_hovered
	else:
		length_target = length_normal
	
	tween.tween_property(self, "length_current", length_target, tween_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)


# set/get functions -------------------------------------------------------------------------------------------------------
func set_clicked(new_val):
	if clicked == new_val: return
	
	clicked = new_val
	update_length()
	
	if clicked:
		match ui_type:
			UI_TYPES.back:
				gVariables.current_level_id = 0
			UI_TYPES.reset:
				gSignals.reset_level.emit()


# signal functions --------------------------------------------------------------------------------------------------------
func _on_mouse_entered():
	hovered = true
	update_length()


func _on_mouse_exited():
	hovered = false
	update_length()
