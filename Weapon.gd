class_name Weapon
extends Spatial

enum FireMode {
	FULL_AUTO,
	SEMI_AUTO
}

enum AmmoType {
	MEDIUM_CALIBER,
	SMALL_CALIBER,
}

const aim_pushback_offset = 0.1

export(NodePath) var aim_ray_path : NodePath
export(NodePath) var camera_path : NodePath
export(NodePath) var player_path : NodePath
export(NodePath) var crosshair_path : NodePath
export(NodePath) var ammo_label_path : NodePath
export(Array, Vector2) var recoil_pattern : Array
export(float) var damage = 20.0
export(float) var ads_accuracy_bonus = 30.0
export(FireMode) var fire_mode = FireMode.SEMI_AUTO
export(float) var fire_rate_secs = 0.2
export(int) var magazine_capacity = 5
export(AmmoType) var ammo_type = AmmoType.MEDIUM_CALIBER
export(bool) var is_active = false

onready var aim_ray = get_node(aim_ray_path)
onready var camera = get_node(camera_path)
onready var player = get_node(player_path)
onready var crosshair = get_node(crosshair_path)
onready var ammo_label = get_node(ammo_label_path)
onready var muzzle = $Muzzle
onready var animation_tree = $AnimationTree
onready var magazine = magazine_capacity

var recoil_position = 0
var accuracy_bonus : float
var accuracy : float
var is_ads = false
var is_moving = false
var is_shooting = false
	
func _process(_delta):
	if not is_active:
		return
		
	if Input.is_action_just_pressed("ads"):
		accuracy_bonus = ads_accuracy_bonus
		is_ads = true
		crosshair.modulate = Color(1, 1, 1, 0)
		
	if Input.is_action_just_released("ads"):
		accuracy_bonus = 0
		is_ads = false
		crosshair.modulate = Color(1, 1, 1, 1)
		
	# Aiming and shooting
	if fire_mode == FireMode.SEMI_AUTO:
		if Input.is_action_just_pressed("fire"):
			shoot()
	elif fire_mode == FireMode.FULL_AUTO:
		if Input.is_action_just_pressed("fire"):
			is_shooting = true
			keep_shooting()
			
		if Input.is_action_just_released("fire"):
			is_shooting = false
		
	# Reload
	if Input.is_action_just_pressed("reload"):
		reload()
		
	ammo_label.text = "Ammo: %s/%s" % [magazine, player.ammo[ammo_type]]
		
	# Update animation tree parameters
	animation_tree.set("parameters/conditions/IsADS", is_ads)
	animation_tree.set("parameters/conditions/NotIsADS", not is_ads)
	animation_tree.set("parameters/conditions/IsMoving", is_moving)
	animation_tree.set("parameters/conditions/NotIsMoving", not is_moving)

func keep_shooting():
	if not is_shooting:
		return
		
	shoot()
	yield(get_tree().create_timer(fire_rate_secs), "timeout")
	keep_shooting()

func shoot():
	if magazine == 0:
		return
		
	magazine = clamp(magazine - 1, 0, magazine_capacity)
		
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

func reload():
	var missing = magazine_capacity - magazine
	var taking = min(missing, player.ammo[ammo_type])
	if missing == 0 or player.ammo[ammo_type] == 0:
		return
		
	player.ammo[ammo_type] = player.ammo[ammo_type] - taking
	magazine = magazine + taking
	print("capacity: ", magazine_capacity, " magazine: ", magazine, " taking: ", taking, " missing: ", missing, " ammo: ", player.ammo[ammo_type])
