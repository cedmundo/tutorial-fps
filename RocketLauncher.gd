extends Weapon

export(float) var rocket_launch_power = 100.0

var rocket_preload = preload("res://Rocket.tscn")

func shoot():
	if magazine == 0:
		return
		
	magazine = clamp(magazine - 1, 0, magazine_capacity)
	var rocket : RigidBody = rocket_preload.instance()
	get_tree().get_root().add_child(rocket) # Add node to scene
	rocket.global_transform = muzzle.global_transform
	rocket.apply_central_impulse(
		-muzzle.global_transform.basis.z *
		rocket_launch_power
	)
	rocket.damage = damage
