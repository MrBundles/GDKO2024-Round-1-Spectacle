@tool
#class_name name_of_class
extends Polygon2D

# purpose: 

# signals ----------------------------------------------------------------------------------------------------------------

# enums ------------------------------------------------------------------------------------------------------------------

# constants --------------------------------------------------------------------------------------------------------------

# variables --------------------------------------------------------------------------------------------------------------
@export_node_path("SubViewport") var viewport_path
@export var new_layer_id = 0

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



# main functions ---------------------------------------------------------------------------------------------------------
func _ready():
	# connect signals
	gSignals.refresh_viewport_textures.connect(refresh_viewport_textures)
	
	# initialize variables
	
	# call functions
	generate_polygon()


func _process(delta):
	texture_offset = position
	queue_redraw()


func _draw():
	if not polygon_points:
		return
	var outline_points = polygon_points.duplicate()
	outline_points.append(polygon_points[0])
	draw_polyline(PackedVector2Array(outline_points), layer_colors[new_layer_id].darkened(.25), rim_thickness, true)


# helper functions --------------------------------------------------------------------------------------------------------
func generate_polygon():
	polygon_points.clear()
	for i in node_count:
		var node_angle = deg_to_rad(360.0 / node_count * i)
		polygon_points.append(Vector2(shape_radius, 0).rotated(node_angle))
	
	set_polygon(PackedVector2Array(polygon_points))


func finish_layer_transition():
	gSignals.finish_layer_transition.emit(new_layer_id)
	shape_radius = initial_shape_radius
	active = false
	$Area2D.monitoring = true


# set/get functions -------------------------------------------------------------------------------------------------------
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
	node_count = circumference / 10.0


func set_active(new_val):
	active = new_val
	
	if not active: return
	
	gSignals.start_layer_transition.emit(new_layer_id)
	$Area2D.monitoring = false
	var tween = get_tree().create_tween()
	var tween_duration = 1.5
	tween.tween_property(self, "shape_radius", 2500, tween_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(finish_layer_transition)


# signal functions --------------------------------------------------------------------------------------------------------
func refresh_viewport_textures():
	if not viewport_path: return
	
	var viewport :SubViewport = get_node(viewport_path)
	texture = viewport.get_texture()


func _on_area_2d_body_entered(body):
	if body.is_in_group("player") and not active:
		active = true
