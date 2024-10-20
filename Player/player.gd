extends CharacterBody3D

@onready var navigation_agent := $NavigationAgent3D
@onready var camera := $CameraController/SpringArm3D/Camera3D

@export_range(0, 1000) var speed: int = 500
@export_range(0, 100) var turn_speed: int = 100

func _ready():
	pass
	
func _process(delta: float):
	# if we are desitination stop
	if (navigation_agent.is_navigation_finished()):
		return
	move_player(delta)
	pass
	
func _input(event):
	if event is InputEventMouseButton and event.is_action_pressed("game_fire_alternate"):
		# get the mouse position
		var mouse_position = event.position
		
		# perform a raycast to determine where the player clicked in the 3D world
		var ray_origin = camera.project_ray_origin(mouse_position)
		var ray_direction = camera.project_ray_normal(mouse_position)
		var ray_length = 1000.0 
		
		var query = PhysicsRayQueryParameters3D.new()
		query.from = ray_origin
		query.to = ray_origin + ray_direction * ray_length
		
		# raycast to the environment using the query object
		var space_state = get_world_3d().direct_space_state
		var result = space_state.intersect_ray(query)
		
		if (result):
			print_debug(result.position)
			navigation_agent.debug_enabled
			navigation_agent.set_target_position(result.position)
			
func move_player(delta:float):
	var target_position = navigation_agent.get_next_path_position()
	var direction = global_position.direction_to(target_position)
	
	velocity = direction * speed * delta
	face_direction(target_position, delta)
	move_and_slide()

func face_direction(direction: Vector3, delta: float):
	# calculate the target direction, keeping the Y component unchanged
	var target_direction = Vector3(direction.x, global_position.y, direction.z)
	
	# calculate the desired direction (where we want the player to face)
	var desired_direction = (target_direction - global_position).normalized()
	
	# get the current Y rotation (yaw)
	var current_rotation = rotation.y
	var target_rotation = atan2(-desired_direction.x, -desired_direction.z)
	rotation.y = lerp_angle(current_rotation, target_rotation, turn_speed * delta)
