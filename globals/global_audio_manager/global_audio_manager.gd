@tool
#class_name name_of_class
extends Node

# purpose: 

# signals ----------------------------------------------------------------------------------------------------------------

# enums ------------------------------------------------------------------------------------------------------------------

# constants --------------------------------------------------------------------------------------------------------------

# variables --------------------------------------------------------------------------------------------------------------


# main functions ---------------------------------------------------------------------------------------------------------
func _ready():
	# connect signals
	gSignals.start_layer_transition.connect(on_start_layer_transition)
	
	# initialize variables
	
	# call functions
	pass


func _process(delta):
	pass


# helper functions --------------------------------------------------------------------------------------------------------


# set/get functions -------------------------------------------------------------------------------------------------------


# signal functions --------------------------------------------------------------------------------------------------------
func on_start_layer_transition(new_layer_id):
	AudioServer.set_bus_effect_enabled(0,0,new_layer_id == 2)
	AudioServer.set_bus_effect_enabled(0,1,new_layer_id == 3)
	AudioServer.set_bus_effect_enabled(0,2,new_layer_id == 4)

