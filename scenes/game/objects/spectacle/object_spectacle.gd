@tool
#class_name name_of_class
extends Polygon2D

# purpose: 

# signals ----------------------------------------------------------------------------------------------------------------

# enums ------------------------------------------------------------------------------------------------------------------

# constants --------------------------------------------------------------------------------------------------------------

# variables --------------------------------------------------------------------------------------------------------------
@export_node_path("SubViewport") var viewport_path
@export var layer_id = 0 : set = set_layer_id
@export var target_layer_id = 0
@export var enabled : bool : set = set_enabled

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
	gSignals.start_layer_transition.connect(on_start_layer_transition)
	
	# initialize variables
	
	# call functions
	generate_polygon()


func _process(delta):
	texture_offset = position
	queue_redraw()
	$Area2D.monitoring = !active


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
func set_layer_id(new_val):
	layer_id = clamp(new_val, 0, 4)
	
	if not $Area2D: return
	
	for i in range(1,5):
		$Area2D.set_collision_layer_value(i, i==layer_id)
		$Area2D.set_collision_mask_value(i, i==layer_id)
		set_visibility_layer_bit(i-1, i==layer_id)


func set_node_count(new_val):
	node_count = new_val
	generate_polygon()


func set_initial_shape_radius(new_val):
	initial_shape_radius = new_val
	shape_radius = initial_shape_radius
	
	if has_node("Area2D/CollisionShape2D"):
		var collision_shape : CollisionShape2D = $Area2D/CollisionShape2D
		var new_circle_shape_2d = CircleShape2D.new()
		new_circle_shape_2d.radius = initial_shape_radius
		collision_shape.shape = new_circle_shape_2d


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


func set_enabled(new_val):
	enabled = new_val
	
	if not $Area2D: return
	if not $Particles: return
	
	$Area2D.monitoring = enabled
	$Particles.emitting = enabled


# signal functions --------------------------------------------------------------------------------------------------------
func refresh_viewport_textures():
	if not viewport_path: return
	
	var viewport :SubViewport = get_node(viewport_path)
	texture = viewport.get_texture()


func _on_area_2d_body_entered(body):
	if body.is_in_group("player") and not active:
		active = true


func on_start_layer_transition(new_layer_id):
	var parent_layer = get_parent().layer_id
	if new_layer_id != parent_layer:
		$Area2D.monitoring = false
	else:
		$Area2D.monitoring = true
