extends KinematicBody

export(float) var max_health = 100
export(float) var move_speed = 40.0
export(float) var proximity_speed = 25.0
export(float) var gravity = 9.8
export(float) var attack_range = 3.0

onready var health = max_health
onready var reach_ray = $ReachRay

var target
var velocity : Vector3
var gravity_vec : Vector3
var snap : Vector3
var speed : float = move_speed

func deal_damage(amount):
	health -= amount
	if health <= 0:
		health = 0
		queue_free()

	print(name, " ouch ... ", health)
	
	
func _physics_process(delta):
	_check_reaching_player()
	_move_towards_target(delta)

func _check_reaching_player():
	if not reach_ray.is_colliding():
		return
		
	var body = reach_ray.get_collider()
	if not body:
		return
		
	if body.is_in_group("players"):
		speed = proximity_speed

func _move_towards_target(delta):
	if not target:
		return
		
	var target_position = target.global_transform.origin
	var enemy_position = global_transform.origin
	var direction = target_position - enemy_position
	if direction.length() < attack_range:
		print(name, " in attack range")
		velocity = Vector3.ZERO
	else:
		velocity = direction * speed * delta
		
	if is_on_floor():
		gravity_vec = Vector3.ZERO
		snap = -get_floor_normal()
	else:
		gravity_vec += Vector3.DOWN * gravity * delta
		snap = Vector3.DOWN
		
	look_at(target_position, Vector3.UP)
	velocity = move_and_slide_with_snap(
		velocity + gravity_vec,
		snap,
		Vector3.UP
	)
