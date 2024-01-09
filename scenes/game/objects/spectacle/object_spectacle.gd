#@tool
#class_name name_of_class
extends Polygon2D

# purpose: 

# signals ----------------------------------------------------------------------------------------------------------------

# enums ------------------------------------------------------------------------------------------------------------------

# constants --------------------------------------------------------------------------------------------------------------

# variables --------------------------------------------------------------------------------------------------------------
@export var target_layer_id = 0 : set = set_target_layer_id
@export var enabled = false: set = set_enabled

@export_group("viewports")
@export_node_path("SubViewport") var layer_1_viewport_path
@export_node_path("SubViewport") var layer_2_viewport_path
@export_node_path("SubViewport") var layer_3_viewport_path
@export_node_path("SubViewport") var layer_4_viewport_path

@export_group("color values")
@export var layer_colors : Array[Color] = []

@export_group("polygon values")
var node_count = 16 : set = set_node_count
@export var enabled_radius = 64
var target_radius = 0
@export var current_radius = 32 : set = set_current_radius
var transition_radius = 2400
var polygon_points = []

@export_group("spectacle values")
@export var rim_thickness = 8

@export_group("tween values")
var transition_tween : Tween


# main functions ---------------------------------------------------------------------------------------------------------
func _ready():
	# connect signals
	gSignals.refresh_viewport_textures.connect(refresh_viewport_textures)
	
	# initialize variables
	current_radius = 0
	
	# call functions
	generate_polygon()


func _process(delta):
	position = get_viewport().get_mouse_position()
	texture_offset = position
	
	current_radius = lerpf(current_radius, target_radius, 10 * delta)
	
	queue_redraw()
	get_input()


func _draw():
	if not polygon_points or polygon_points.size() < 1: return
	if not target_layer_id: return
	
	var outline_points = polygon_points.duplicate()
	outline_points.append(polygon_points[0])
	draw_polyline(PackedVector2Array(outline_points), layer_colors[target_layer_id].lightened(.25), rim_thickness, true)


# helper functions --------------------------------------------------------------------------------------------------------
func generate_polygon():
	polygon_points.clear()
	for i in node_count:
		var node_angle = deg_to_rad(360.0 / node_count * i)
		polygon_points.append(Vector2(current_radius, 0).rotated(node_angle))
	
	set_polygon(PackedVector2Array(polygon_points))
	
	if not $Particles: return
	$Particles.emission_points = PackedVector2Array(polygon_points)


func get_input():
	if target_radius == transition_radius:
		return
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and enabled:
		gSignals.start_layer_transition.emit(target_layer_id)
		gVariables.current_layer_id = target_layer_id
		target_radius = transition_radius
	
	if Input.is_action_just_pressed("spectacle_cancel") and enabled:
		enabled = false
	
	if Input.is_action_just_pressed("spectacle_select_layer_1"):
		if gVariables.current_layer_id == 1:
			enabled = false
		elif target_layer_id == 1:
			enabled = !enabled
		else:
			enabled = true
			target_layer_id = 1
	elif Input.is_action_just_pressed("spectacle_select_layer_2"):
		if gVariables.current_layer_id == 2:
			enabled = false
		elif target_layer_id == 2:
			enabled = !enabled
		else:
			enabled = true
			target_layer_id = 2
	elif Input.is_action_just_pressed("spectacle_select_layer_3"):
		if gVariables.current_layer_id == 3:
			enabled = false
		elif target_layer_id == 3:
			enabled = !enabled
		else:
			enabled = true
			target_layer_id = 3
	elif Input.is_action_just_pressed("spectacle_select_layer_4"):
		if gVariables.current_layer_id == 4:
			enabled = false
		elif target_layer_id == 4:
			enabled = !enabled
		else:
			enabled = true
			target_layer_id = 4

# set/get functions -------------------------------------------------------------------------------------------------------
func set_node_count(new_val):
	node_count = new_val
	generate_polygon()


func set_current_radius(new_val):
	current_radius = new_val
	var circumference = 2 * PI * current_radius
	node_count = circumference / 6
	rim_thickness = current_radius * .05
	
	if transition_radius - current_radius < 1:
		gSignals.finish_layer_transition.emit(target_layer_id)
		enabled = false
		current_radius = 0


func set_enabled(new_val):
	enabled = new_val
	
	if enabled:
		target_radius = enabled_radius
	else:
		target_radius = 0


func set_target_layer_id(new_val):
	target_layer_id = new_val
	refresh_viewport_textures()


# signal functions --------------------------------------------------------------------------------------------------------
func refresh_viewport_textures():
	var viewport_path
	if target_layer_id == 1:
		viewport_path = layer_1_viewport_path
	elif target_layer_id == 2:
		viewport_path = layer_2_viewport_path
	elif target_layer_id == 3:
		viewport_path = layer_3_viewport_path
	elif target_layer_id == 4:
		viewport_path = layer_4_viewport_path
	else:
		return
	
	if not viewport_path: return
	var viewport :SubViewport = get_node(viewport_path)
	texture = viewport.get_texture()
