@tool
#class_name name_of_class
extends Polygon2D

# purpose: 

# signals ----------------------------------------------------------------------------------------------------------------

# enums ------------------------------------------------------------------------------------------------------------------

# constants --------------------------------------------------------------------------------------------------------------

# variables --------------------------------------------------------------------------------------------------------------
@export var target_layer_id = 0

@export_group("viewports")
@export_node_path("SubViewport") var layer_1_viewport_path
@export_node_path("SubViewport") var layer_2_viewport_path
@export_node_path("SubViewport") var layer_3_viewport_path
@export_node_path("SubViewport") var layer_4_viewport_path

@export_group("color values")
@export var layer_colors : Array[Color] = []

@export_group("polygon values")
var node_count = 16 : set = set_node_count
@export var initial_shape_radius = 64 : set = set_initial_shape_radius
@export var shape_radius = 32 : set = set_shape_radius
var polygon_points = []

@export_group("spectacle values")
@export var rim_thickness = 8
@export var active = false : set = set_active

@export_group("tween values")
var transition_tween : Tween


# main functions ---------------------------------------------------------------------------------------------------------
func _ready():
	# connect signals
	gSignals.refresh_viewport_textures.connect(refresh_viewport_textures)
	
	# initialize variables
	
	# call functions
	generate_polygon()


func _process(delta):
	position = get_viewport().get_mouse_position()
	texture_offset = position
	queue_redraw()


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
		polygon_points.append(Vector2(shape_radius, 0).rotated(node_angle))
	
	set_polygon(PackedVector2Array(polygon_points))
	
	if not $Particles: return
	$Particles.emission_points = PackedVector2Array(polygon_points)


func finish_layer_transition():
	gSignals.finish_layer_transition.emit(target_layer_id)
	shape_radius = initial_shape_radius
	active = false


# set/get functions -------------------------------------------------------------------------------------------------------
func set_node_count(new_val):
	node_count = new_val
	generate_polygon()


func set_initial_shape_radius(new_val):
	initial_shape_radius = new_val
	shape_radius = initial_shape_radius


func set_shape_radius(new_val):
	shape_radius = new_val
	var circumference = 2 * PI * shape_radius
	node_count = circumference / 6


func set_active(new_val):
	if new_val == active: return
	
	active = new_val
	
	if not active: return
	
	gSignals.start_layer_transition.emit(target_layer_id)
	transition_tween = create_tween()
	var tween_duration = 1.0
	transition_tween.tween_property(self, "shape_radius", 2400, tween_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	transition_tween.tween_callback(finish_layer_transition)


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
	
	var viewport :SubViewport = get_node(viewport_path)
	texture = viewport.get_texture()
