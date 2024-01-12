#@tool
#class_name name_of_class
extends Button

# purpose: 

# signals ----------------------------------------------------------------------------------------------------------------

# enums ------------------------------------------------------------------------------------------------------------------

# constants --------------------------------------------------------------------------------------------------------------

# variables --------------------------------------------------------------------------------------------------------------
var size_normal : Vector2 = Vector2(64,64)
var size_hovered : Vector2 = Vector2(64,64)
var size_clicked : Vector2 = Vector2(64,64)
var size_current : Vector2 = Vector2(64,64)
var size_target : Vector2 = Vector2(64,64)

@export var jelly_color : Color = Color.WHITE
var hovered : bool = false
var clicked : bool = false

# main functions ---------------------------------------------------------------------------------------------------------
func _ready():
	# connect signals
	
	# initialize variables
	print(size_normal)
	size_normal = size
	print(size_normal)
	size_hovered = size_normal * 1.2
	size_clicked = size_normal * 1.5
	
	# call functions
	size_current = size_normal


func _process(delta):
	$Node2D.queue_redraw()
	#print(size_normal)


# helper functions --------------------------------------------------------------------------------------------------------
func update_size():
	var tween_duration = 1.0
	var tween = get_tree().create_tween()
	tween.set_parallel()
	
	if clicked:
		size_target = size_clicked
	elif hovered:
		size_target = size_hovered
	else:
		size_target = size_normal
	
	tween.tween_property(self, "size_current:x", size_target.x, tween_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "size_current:y", size_target.y, tween_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)


# set/get functions -------------------------------------------------------------------------------------------------------


# signal functions --------------------------------------------------------------------------------------------------------
func _on_mouse_entered():
	hovered = true
	update_size()


func _on_mouse_exited():
	hovered = false
	update_size()


func _on_button_down():
	clicked = true
	update_size()


func _on_button_up():
	clicked = false
	update_size()


func _on_node_2d_draw():
	var draw_pos = (size_normal - size_current) / 2
	$Node2D.draw_rect(Rect2(draw_pos, size_current), jelly_color, true)
