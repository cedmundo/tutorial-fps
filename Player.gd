extends KinematicBody

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

var velocity = Vector3.ZERO
var gravity_vec = Vector3.ZERO
var snap = Vector3.ZERO

onready var camera = $Camera

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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
