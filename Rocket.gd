extends RigidBody

var damage = 0.0

func _physics_process(_delta):
	var bodies = get_colliding_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			body.deal_damage(damage)
			
		queue_free()
		break
