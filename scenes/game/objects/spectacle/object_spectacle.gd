@tool
#class_name name_of_class
extends Polygon2D

# purpose: 

# signals ----------------------------------------------------------------------------------------------------------------

# enums ------------------------------------------------------------------------------------------------------------------

# constants --------------------------------------------------------------------------------------------------------------

# variables --------------------------------------------------------------------------------------------------------------
@export_group("polygon variables")
@export var node_count = 16 : set = set_node_count
@export var shape_radius = 32 : set = set_shape_radius
var polygon_points = []

@export_group("spectacle variables")
@export var rim_thickness = 8

# main functions ---------------------------------------------------------------------------------------------------------
func _ready():
	# connect signals
	
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


# signal functions --------------------------------------------------------------------------------------------------------


