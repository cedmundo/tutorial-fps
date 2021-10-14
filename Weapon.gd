extends MeshInstance

const aim_pushback_offset = 0.1

export(NodePath) var aim_ray_path : NodePath
export(NodePath) var camera_path : NodePath
export(NodePath) var muzzle_path : NodePath
export(NodePath) var player_path : NodePath
export(NodePath) var animation_tree_path : NodePath
export(NodePath) var crosshair_path : NodePath
export(Array, Vector2) var recoil_pattern : Array
export(float) var damage = 20.0
export(float) var ads_accuracy_bonus = 30.0

onready var aim_ray = get_node(aim_ray_path)
onready var camera = get_node(camera_path)
onready var muzzle = get_node(muzzle_path)
onready var player = get_node(player_path)
onready var animation_tree = get_node(animation_tree_path)
onready var crosshair = get_node(crosshair_path)

var recoil_position = 0
var accuracy_bonus : float
var is_ads = false
var is_moving = false
	
func _process(_delta):
	if Input.is_action_just_pressed("ads"):
		accuracy_bonus = ads_accuracy_bonus
		is_ads = true
		crosshair.modulate = Color(1, 1, 1, 0)
		
	if Input.is_action_just_released("ads"):
		accuracy_bonus = 0
		is_ads = false
		crosshair.modulate = Color(1, 1, 1, 1)
		
	animation_tree.set("parameters/conditions/IsADS", is_ads)
	animation_tree.set("parameters/conditions/NotIsADS", not is_ads)
	animation_tree.set("parameters/conditions/IsMoving", is_moving)
	animation_tree.set("parameters/conditions/NotIsMoving", not is_moving)
	

func shoot(accuracy : float):
	var space = get_world().direct_space_state
	var collision_point = aim_ray.get_collision_point()
	if aim_ray.is_colliding():
		var slightly_behind = (
			collision_point - camera.global_transform.basis.z *
			aim_pushback_offset
		)
		var hit = space.intersect_ray(
			muzzle.global_transform.origin,
			slightly_behind
		)
		if hit and hit.collider:
			var collider = hit.collider
			if collider.is_in_group("enemies"):
				collider.deal_damage(damage)
				
	var total_patterns = recoil_pattern.size()
	if total_patterns > 0:
		recoil_position += 1
		var push_camera_to = recoil_pattern[recoil_position % total_patterns]
		player.rotate_y(deg2rad(push_camera_to.y) / (accuracy / 100))
		camera.rotate_x(deg2rad(push_camera_to.x) / (accuracy / 100))
