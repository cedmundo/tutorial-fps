extends KinematicBody

export(float) var vertical_sensibility = 0.1
export(float) var horizontal_sensibility = 0.1
export(float) var vertical_rotation_limit = 89
export(float) var walking_speed = 10

var velocity = Vector3.ZERO

onready var camera = $Camera

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		var coords = -event.get_relative()
		rotate_y(deg2rad(coords.x * horizontal_sensibility))
		camera.rotate_x(deg2rad(coords.y * vertical_sensibility))
		camera.rotation.x = clamp(camera.rotation.x, deg2rad(-vertical_rotation_limit), deg2rad(vertical_rotation_limit))

	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(_delta):
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
	
	velocity = direction * walking_speed
	velocity = move_and_slide(velocity, Vector3.UP)
