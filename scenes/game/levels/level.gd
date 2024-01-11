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
@export_flags("layer 1", "layer 2", "layer 3", "layer 4") var show_layer_previews

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
	gVariables.current_layer_id = active_layer_id
	gSignals.start_layer_transition.emit(active_layer_id)
	gSignals.finish_layer_transition.emit(active_layer_id)


# signal functions --------------------------------------------------------------------------------------------------------


