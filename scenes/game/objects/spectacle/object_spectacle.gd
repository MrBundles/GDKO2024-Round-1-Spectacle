@tool
#class_name name_of_class
extends Polygon2D

# purpose: 

# signals ----------------------------------------------------------------------------------------------------------------

# enums ------------------------------------------------------------------------------------------------------------------

# constants --------------------------------------------------------------------------------------------------------------

# variables --------------------------------------------------------------------------------------------------------------
@export_node_path("SubViewport") var viewport_path

@export_group("polygon values")
@export var node_count = 16 : set = set_node_count
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
	draw_polyline(PackedVector2Array(outline_points), Color.DIM_GRAY, rim_thickness, true)


# helper functions --------------------------------------------------------------------------------------------------------
func generate_polygon():
	polygon_points.clear()
	for i in node_count:
		var node_angle = deg_to_rad(360 / node_count * i)
		polygon_points.append(Vector2(shape_radius, 0).rotated(node_angle))
	
	set_polygon(PackedVector2Array(polygon_points))


# set/get functions -------------------------------------------------------------------------------------------------------
func set_node_count(new_val):
	node_count = new_val
	generate_polygon()

func set_shape_radius(new_val):
	shape_radius = new_val
	generate_polygon()

func set_active(new_val):
	active = new_val


# signal functions --------------------------------------------------------------------------------------------------------
func refresh_viewport_textures():
	var viewport :SubViewport = get_node(viewport_path)
	texture = viewport.get_texture()

