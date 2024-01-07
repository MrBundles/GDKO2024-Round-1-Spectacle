@tool
#class_name name_of_class
extends TextureRect

# purpose: 

# signals ----------------------------------------------------------------------------------------------------------------

# enums ------------------------------------------------------------------------------------------------------------------

# constants --------------------------------------------------------------------------------------------------------------

# variables --------------------------------------------------------------------------------------------------------------
@export_node_path("SubViewport") var viewport_path
@export var layer_id = 0


# main functions ---------------------------------------------------------------------------------------------------------
func _ready():
	# connect signals
	gSignals.refresh_viewport_textures.connect(refresh_viewport_textures)
	gSignals.finish_layer_transition.connect(finish_layer_transition)
	
	# initialize variables
	
	# call functions
	pass


func _process(delta):
	pass


# helper functions --------------------------------------------------------------------------------------------------------


# set/get functions -------------------------------------------------------------------------------------------------------


# signal functions --------------------------------------------------------------------------------------------------------
func refresh_viewport_textures():
	if not viewport_path: return
	var viewport :SubViewport = get_node(viewport_path)
	texture = viewport.get_texture()


func finish_layer_transition(new_layer_id):
	if new_layer_id == layer_id:
		z_index = 1
	else:
		z_index = 0
