@tool
#class_name name_of_class
extends Area2D

# purpose: 

# signals ----------------------------------------------------------------------------------------------------------------

# enums ------------------------------------------------------------------------------------------------------------------

# constants --------------------------------------------------------------------------------------------------------------

# variables --------------------------------------------------------------------------------------------------------------
@export var layer_id = 1 : set = set_layer_id
@export var layer_colors : Array[Color] = []


# main functions ---------------------------------------------------------------------------------------------------------
func _ready():
	# connect signals
	
	# initialize variables
	layer_id = layer_id
	
	# call functions
	pass


func _process(delta):
	pass


# helper functions --------------------------------------------------------------------------------------------------------


# set/get functions -------------------------------------------------------------------------------------------------------
func set_layer_id(new_val):
	layer_id = new_val
	
	modulate = layer_colors[layer_id].lightened(.5)
	
	for i in range(1,5):
		set_visibility_layer_bit(i-1, i == layer_id)
		$CPUParticles2D.set_visibility_layer_bit(i-1, i == layer_id)
		$EventParticles.set_visibility_layer_bit(i-1, i == layer_id)
		set_collision_layer_value(i+4, i == layer_id)
		set_collision_mask_value(i+4, i == layer_id)


# signal functions --------------------------------------------------------------------------------------------------------
func _on_body_entered(body):
	if body.is_in_group("baby"):
		body.queue_free()
		$EventParticles.emitting = true
		
		await get_tree().create_timer(0.5).timeout
		var baby_count = get_tree().get_nodes_in_group("baby").size()
		if baby_count < 1:
			gSignals.level_win.emit()
