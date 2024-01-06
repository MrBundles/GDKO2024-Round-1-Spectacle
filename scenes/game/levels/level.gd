@tool
#class_name name_of_class
extends Node

# purpose: 

# signals ----------------------------------------------------------------------------------------------------------------

# enums ------------------------------------------------------------------------------------------------------------------

# constants --------------------------------------------------------------------------------------------------------------

# variables --------------------------------------------------------------------------------------------------------------
@export_group("layer values")
@export var active_layer_id = 0 : set = set_active_layer_id

# main functions ---------------------------------------------------------------------------------------------------------
func _ready():
	# connect signals
	
	# initialize variables
	
	# call functions
	gSignals.refresh_viewport_textures.emit()

func _process(delta):
	if Engine.is_editor_hint():
		gSignals.refresh_viewport_textures.emit()


# helper functions --------------------------------------------------------------------------------------------------------


# set/get functions -------------------------------------------------------------------------------------------------------
func set_active_layer_id(new_val):
	active_layer_id = new_val
	
	gSignals.start_layer_transition.emit(active_layer_id)
	gSignals.finish_layer_transition.emit(active_layer_id)


# signal functions --------------------------------------------------------------------------------------------------------


