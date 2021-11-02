extends KinematicBody

const speed_threshold = 0.1

export(float) var vertical_sensibility = 0.1
export(float) var horizontal_sensibility = 0.1
export(float) var vertical_rotation_limit = 89
export(float) var walking_speed = 5.0
export(float) var sprint_speed = 10.0
export(float) var gravity = 9.8
export(float) var walking_jump_power = 2.0
export(float) var sprint_jump_power = 3.0
export(float) var ground_acceleration = 8.0
export(float) var air_acceleration = 4.0
export(float) var standing_accuracy = 60.0
export(float) var walking_accuracy = 30.0
export(float) var sprinting_accuracy = 10.0
export(float) var accuracy_change_speed = 15.0
export(Array, int) var default_ammo = [120, 30, 5]
export(NodePath) var default_weapon_path : NodePath
export(NodePath) var weapon_1_path : NodePath
export(NodePath) var weapon_2_path : NodePath
export(NodePath) var weapon_3_path : NodePath

var velocity = Vector3.ZERO
var gravity_vec = Vector3.ZERO
var snap = Vector3.ZERO
var target_accuracy : float
var accuracy : float
var ammo : Array = default_ammo
var weapon : Weapon

onready var camera = $Camera
onready var weapon_camera = $Camera/WeaponViewport/Viewport/WeaponCamera
onready var aim_ray = $Camera/AimRay
onready var crosshair = $Crosshair
onready var weapon_1 = get_node(weapon_1_path)
onready var weapon_2 = get_node(weapon_2_path)
onready var weapon_3 = get_node(weapon_3_path)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	target_accuracy = standing_accuracy
	_enable_weapon(get_node(default_weapon_path))

func _input(event):
	if event is InputEventMouseMotion:
		var coords = -event.get_relative()
		rotate_y(deg2rad(coords.x * horizontal_sensibility))
		camera.rotate_x(deg2rad(coords.y * vertical_sensibility))
		camera.rotation.x = clamp(
			camera.rotation.x, 
			deg2rad(-vertical_rotation_limit), 
			deg2rad(vertical_rotation_limit)
		)

	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	weapon_camera.global_transform = camera.global_transform
	
	# Visualize the accuracy
	accuracy = lerp(accuracy, target_accuracy + weapon.accuracy_bonus, accuracy_change_speed * delta)
	crosshair.accuracy = accuracy
	weapon.accuracy = accuracy
	
	if Input.is_action_just_pressed("switch_weapon_1"):
		_enable_weapon(weapon_1)
		
	if Input.is_action_just_pressed("switch_weapon_2"):
		_enable_weapon(weapon_2)
		
	if Input.is_action_just_pressed("switch_weapon_3"):
		_enable_weapon(weapon_3)

func _physics_process(delta):
	var input_strength : Vector2 = Vector2.ZERO
	input_strength.x = (
		Input.get_action_strength("right") -
		Input.get_action_strength("left")
	)
	input_strength.y = (
		Input.get_action_strength("forward") -
		Input.get_action_strength("backward")
	)
	
	var direction : Vector3 = Vector3.ZERO
	direction += global_transform.basis.x * input_strength.x
	direction += -global_transform.basis.z * input_strength.y
	direction = direction.normalized()
	
	var jump_power = walking_jump_power
	var speed = walking_speed
	if Input.is_action_pressed("sprint"):
		speed = sprint_speed
		jump_power = sprint_jump_power
		
	var acceleration = 0.0
	if is_on_floor():
		gravity_vec = Vector3.ZERO
		snap = -get_floor_normal()
		acceleration = ground_acceleration
	else:
		gravity_vec += Vector3.DOWN * gravity * delta
		snap = Vector3.DOWN
		acceleration = air_acceleration
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		gravity_vec = Vector3.UP * jump_power
		snap = Vector3.ZERO
	
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	velocity = move_and_slide_with_snap(velocity + gravity_vec, snap, Vector3.UP)

	# Update accuracy
	var ideal_velocity = direction * speed + gravity_vec
	if abs(sprint_speed - ideal_velocity.length()) <= speed_threshold:
		target_accuracy = sprinting_accuracy
		weapon.is_moving = true
	elif abs(walking_speed - ideal_velocity.length()) <= speed_threshold:
		target_accuracy = walking_accuracy
		weapon.is_moving = true
	else:
		target_accuracy = standing_accuracy
		weapon.is_moving = false

func _enable_weapon(new_weapon):
	if weapon:
		weapon.visible = false
		weapon.is_active = false
		
	weapon = new_weapon
	weapon.visible = true
	weapon.is_active = true
		
