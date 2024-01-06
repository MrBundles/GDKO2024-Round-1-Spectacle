@tool
#class_name name_of_class
extends CanvasLayer

# purpose: 

# signals ----------------------------------------------------------------------------------------------------------------

# enums ------------------------------------------------------------------------------------------------------------------

# constants --------------------------------------------------------------------------------------------------------------

# variables --------------------------------------------------------------------------------------------------------------
@export var layer_id = 0 : set = set_layer_id

@export_group("color values")
@export var layer_colors : Array[Color] = []


# main functions ---------------------------------------------------------------------------------------------------------
func _ready():
	# connect signals
	
	# initialize variables
	
	# call functions
	pass
	custom_viewport = $SubViewport


func _process(delta):
	pass


# helper functions --------------------------------------------------------------------------------------------------------


# set/get functions -------------------------------------------------------------------------------------------------------
func set_layer_id(new_val):
	layer_id = new_val
	
	if layer_id < layer_colors.size():
		$ModulateTarget.modulate = layer_colors[layer_id]

# signal functions --------------------------------------------------------------------------------------------------------


