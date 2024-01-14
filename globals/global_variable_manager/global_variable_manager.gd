@tool
#class_name name_of_class
extends Node

# purpose: 

# signals ----------------------------------------------------------------------------------------------------------------

# enums ------------------------------------------------------------------------------------------------------------------

# constants --------------------------------------------------------------------------------------------------------------

# variables --------------------------------------------------------------------------------------------------------------
var current_layer_id : int = 0 : set = set_current_layer_id
var current_level_id : int = 0 : set = set_current_level_id
var current_level_path : String = ""

# main functions ---------------------------------------------------------------------------------------------------------
func _ready():
	# connect signals
	gSignals.reset_level.connect(on_reset_level)
	
	# initialize variables
	
	# call functions
	pass


func _process(delta):
	if Input.is_action_just_pressed("reset_level"):
		gSignals.reset_level.emit()


# helper functions --------------------------------------------------------------------------------------------------------


# set/get functions -------------------------------------------------------------------------------------------------------


# signal functions --------------------------------------------------------------------------------------------------------
func set_current_layer_id(new_val):
	current_layer_id = new_val
	gSignals.on_set_current_layer_id.emit(current_layer_id)


func set_current_level_id(new_val):
	current_level_id = new_val
	current_level_path = "res://scenes/game/levels/levels/level_" + str(current_level_id).pad_zeros(2) + ".tscn"
	get_tree().change_scene_to_file(current_level_path)


func on_reset_level():
	print("reload scene")
	get_tree().reload_current_scene()
