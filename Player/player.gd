extends CharacterBody3D

@onready var navigation_agent := $NavigationAgent3D
@onready var camera := $CameraController/SpringArm3D/Camera3D

@export_range(0, 100) var speed: int = 5
@export_range(0, 100) var turn_speed: int = 5

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
		# Get the mouse position
		var mouse_position = event.position
		
		# Perform a raycast to determine where the player clicked in the 3D world
		var ray_origin = camera.project_ray_origin(mouse_position)
		var ray_direction = camera.project_ray_normal(mouse_position)
		var ray_length = 1000.0 # The distance the ray can check
		
		# Create a PhysicsRayQueryParameters3D object
		var query = PhysicsRayQueryParameters3D.new()
		query.from = ray_origin
		query.to = ray_origin + ray_direction * ray_length
		
		# Raycast to the environment using the query object
		var space_state = get_world_3d().direct_space_state
		var result = space_state.intersect_ray(query)
		
		if (result):
			print_debug(result.position)
			navigation_agent.debug_enabled
			navigation_agent.set_target_position(result.position)
			
			
func move_player(delta):
	var target_position = navigation_agent.get_next_path_position()
	var direction = global_position.direction_to(target_position)
	
	velocity = direction * speed
	face_direction(target_position)
	move_and_slide()

func face_direction(direction: Vector3):
	look_at(Vector3(direction.x, global_position.y, direction.z), Vector3.UP)
