extends Rig

@onready var animation_tree:AnimationTree = %AnimationTree

func _process(delta: float) -> void:
	animation_tree.set("parameters/IWR/blend_position", Vector2(get_real_velocity().x, get_real_velocity().y))
