#@tool
#class_name name_of_class
extends Node2D

# purpose: 

# signals ----------------------------------------------------------------------------------------------------------------

# enums ------------------------------------------------------------------------------------------------------------------

# constants --------------------------------------------------------------------------------------------------------------

# variables --------------------------------------------------------------------------------------------------------------
@export var layer_id = 1 : set = set_layer_id

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
func set_layer_id(new_val):
	layer_id = new_val
	
	for child in get_children():
		if not "wheel_layer_id" in child: return
		child.wheel_layer_id = layer_id

# signal functions --------------------------------------------------------------------------------------------------------
func on_start_layer_transition(new_layer_id):
	layer_id = new_layer_id

