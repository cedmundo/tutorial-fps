extends KinematicBody

export(float) var max_health = 100

onready var health = max_health

func deal_damage(amount):
	health -= amount
	if health <= 0:
		health = 0
		queue_free()
