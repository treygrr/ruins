extends Node3D

@export_range(0.0, 90.0)
@export_category("Rotation")
var camera_rotation_horizontal = 45.0
 
@export_range(-70.0, 0.0)
var camera_rotation_vertical = -65.0

@export_range(-180.0, 180.0)
var camera_max_vertical = -70.0

@export_range(180.0, 180.0)
var camera_min_vertical = 0.0

# setting?
@export_range(0, 1000)


var camera_soft_lock_move_speed = 500

var camera_rotation_vertical_soft_lock = -65.0  
var camera_rotation_horizontal_soft_lock = 45.0 
var camera_timout_duration = 3.0

# camera distance allowance
@export_category("Distance")
@export_range(0.0, 100.0)
var camera_max_distance = 20.0
@export_range(5.0, 100.0)
var camera_min_distance = 5.0

@export_range(5.0, 100)
var camera_distance = 10.0
var camera_distance_soft_lock = 10.0

var moving_camera = false

func _ready():
	$SpringArm3D/Camera3D.get_parent()

func _input(event):
	# can camera move logic
	if Input.is_action_pressed("game_camera_reset"):
		moving_camera = false
		return
	if event is InputEvent:
		if event.is_action_pressed("game_camera_move"):
			moving_camera = true
		if event.is_action_released("game_camera_move"):
			moving_camera = false
			
	# move camera xy
	if event is InputEventMouseMotion and moving_camera:
		camera_rotation_horizontal += -float(event.relative.x)
		camera_rotation_vertical += -float(event.relative.y)
		if camera_rotation_vertical < camera_max_vertical:
			camera_rotation_vertical = camera_max_vertical
		if camera_rotation_vertical > camera_min_vertical:
			camera_rotation_vertical = camera_min_vertical
			
	# move camera in and out (zoom)
	if event is InputEvent:
		if event.is_action("game_camera_zoom_in"):
			print_debug("game_camera_zoom_in")
			if (camera_distance - 1.0) <= camera_min_distance:
				camera_distance = camera_min_distance
			else:
				camera_distance -= 1.0
		if event.is_action("game_camera_zoom_out"):
			print_debug("game_camera_zoom_out")
			if (camera_distance + 1.0) >= camera_max_distance:
				camera_distance = camera_max_distance
			else:
				camera_distance += 1.0
	
func _process(delta: float) -> void:	
	# update camera rotation and zoom
	$SpringArm3D.global_rotation_degrees.y = camera_rotation_horizontal
	$SpringArm3D.global_rotation_degrees.x = camera_rotation_vertical
	 
	if Input.is_action_pressed("game_camera_reset"):
		# smoothly move camera back to the soft lock position using delta for frame-rate independence
		camera_rotation_horizontal = lerp(
			camera_rotation_horizontal,
			float(camera_rotation_horizontal_soft_lock), 
			0.1 * delta * camera_soft_lock_move_speed)
		camera_rotation_vertical = lerp(
			camera_rotation_vertical, 
			float(camera_rotation_vertical_soft_lock), 
			0.1 * delta * camera_soft_lock_move_speed)
		camera_distance = lerp(
			camera_distance, 
			float(camera_distance_soft_lock), 
			0.1 * delta * camera_soft_lock_move_speed)
	
	# update the camera zoom (spring arm length)
	$SpringArm3D.spring_length = camera_distance
