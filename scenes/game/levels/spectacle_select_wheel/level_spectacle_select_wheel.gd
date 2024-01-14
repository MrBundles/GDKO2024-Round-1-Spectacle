#@tool
#class_name name_of_class
extends Node2D

# purpose: 

# signals ----------------------------------------------------------------------------------------------------------------

# enums ------------------------------------------------------------------------------------------------------------------

# constants --------------------------------------------------------------------------------------------------------------

# variables --------------------------------------------------------------------------------------------------------------
@export var layer_id = 1 : set = set_layer_id
@export var layer_1_enable = true
@export var layer_2_enable = true
@export var layer_3_enable = true
@export var layer_4_enable = true

# main functions ---------------------------------------------------------------------------------------------------------
func _ready():
	# connect signals
	gSignals.start_layer_transition.connect(on_start_layer_transition)
	
	# initialize variables
	if not layer_1_enable:
		$SpectacleSelect1.layer_id = 0
	if not layer_2_enable:
		$SpectacleSelect2.layer_id = 0
	if not layer_3_enable:
		$SpectacleSelect3.layer_id = 0
	if not layer_4_enable:
		$SpectacleSelect4.layer_id = 0
	
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

