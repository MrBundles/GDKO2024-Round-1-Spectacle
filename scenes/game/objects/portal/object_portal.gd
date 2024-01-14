@tool
#class_name name_of_class
extends Area2D

# purpose: 

# signals ----------------------------------------------------------------------------------------------------------------

# enums ------------------------------------------------------------------------------------------------------------------
enum PORTAL_TYPES {exit, level_select}

# constants --------------------------------------------------------------------------------------------------------------

# variables --------------------------------------------------------------------------------------------------------------
@export var layer_id = 1 : set = set_layer_id
@export var portal_type : PORTAL_TYPES = 0
@export var layer_colors : Array[Color] = []
var exit_flag = false

@export_group("level select values")
@export var level_id = 0


# main functions ---------------------------------------------------------------------------------------------------------
func _ready():
	# connect signals
	
	# initialize variables
	layer_id = layer_id
	
	# call functions
	check_exit_flag()


func _process(delta):
	pass


# helper functions --------------------------------------------------------------------------------------------------------
func check_exit_flag():
	await get_tree().create_timer(0.5).timeout
	var baby_count = get_tree().get_nodes_in_group("baby").size()
	if baby_count < 1:
		modulate = layer_colors[layer_id].lightened(1)
		exit_flag = true

# set/get functions -------------------------------------------------------------------------------------------------------
func set_layer_id(new_val):
	layer_id = new_val
	
	modulate = layer_colors[layer_id].lightened(.5)
	
	for i in range(1,5):
		set_visibility_layer_bit(i-1, i == layer_id)
		$CPUParticles2D.set_visibility_layer_bit(i-1, i == layer_id)
		$EventParticles.set_visibility_layer_bit(i-1, i == layer_id)
		set_collision_layer_value(i, i == layer_id)
		set_collision_mask_value(i, i == layer_id)
		set_collision_layer_value(i+4, i == layer_id)
		set_collision_mask_value(i+4, i == layer_id)


# signal functions --------------------------------------------------------------------------------------------------------
func _on_body_entered(body):
	match portal_type:
		PORTAL_TYPES.exit:
			if body.is_in_group("baby"):
				body.queue_free()
				$EventParticles.emitting = true
				check_exit_flag()
			
			elif body.is_in_group("player") and exit_flag:
				body.queue_free()
				$EventParticles.emitting = true
				gSignals.level_win.emit()
				
				await get_tree().create_timer(1.0).timeout
				var current_level_id = gVariables.current_level_id
				gVariables.current_level_id = current_level_id + 1
		
		PORTAL_TYPES.level_select:
			body.queue_free()
			$EventParticles.emitting = true
			await get_tree().create_timer(1.0).timeout
			gVariables.current_level_id = level_id
