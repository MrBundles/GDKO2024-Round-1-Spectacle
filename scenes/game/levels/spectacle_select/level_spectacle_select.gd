#@tool
#class_name name_of_class
extends Area2D

# purpose: 

# signals ----------------------------------------------------------------------------------------------------------------

# enums ------------------------------------------------------------------------------------------------------------------

# constants --------------------------------------------------------------------------------------------------------------

# variables --------------------------------------------------------------------------------------------------------------
@export var layer_id = 1
var wheel_layer_id = 1
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
	draw_arc(Vector2.ZERO, length_current / 2, deg_to_rad(168.75), deg_to_rad(191.25), 32, layer_colors[layer_id], length_current, true)
	draw_arc(Vector2.ZERO, 50, deg_to_rad(167.25), deg_to_rad(192.75), 32, layer_colors[wheel_layer_id], 100, true)


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
		gSignals.spectacle_select_layer.emit(layer_id)


# signal functions --------------------------------------------------------------------------------------------------------
func _on_mouse_entered():
	if layer_id == 0: return
	if gVariables.current_layer_id == layer_id: return
	hovered = true
	update_length()


func _on_mouse_exited():
	hovered = false
	update_length()
