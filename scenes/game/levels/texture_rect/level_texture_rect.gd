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
	gSignals.on_set_current_layer_id.connect(on_set_current_layer_id)
	
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


func on_set_current_layer_id(current_layer_id):
	if current_layer_id == layer_id:
		z_index = 1
	else:
		z_index = 0
