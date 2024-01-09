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
	gSignals.on_set_current_layer_id.connect(on_set_current_layer_id)
	#gSignals.finish_layer_transition.connect(on_finish_layer_transition)
	
	# initialize variables
	
	# call functions
	custom_viewport = $SubViewport


func _process(delta):
	pass


# helper functions --------------------------------------------------------------------------------------------------------


# set/get functions -------------------------------------------------------------------------------------------------------
func set_layer_id(new_val):
	layer_id = new_val
	
	if not layer_id: return
	
	if layer_id > -1 and layer_id < layer_colors.size():
		$ColorRect.modulate = layer_colors[layer_id].darkened(.5)
		$LevelTilemap.modulate = layer_colors[layer_id]

# signal functions --------------------------------------------------------------------------------------------------------
func on_set_current_layer_id(new_layer_id):
	if new_layer_id == layer_id:
		layer = 1
	else:
		layer = 0

