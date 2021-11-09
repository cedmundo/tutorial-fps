extends Spatial

export(bool) var is_spawning = true
export(Array, int) var wave_sizes : Array
export(NodePath) var player_path : NodePath

onready var player = get_node(player_path)

var enemy_preload = preload("res://Enemy.tscn")
var current_wave = 0

func _process(_delta):
	if not is_spawning:
		return
	
	if wave_sizes.size() == 0:
		return
		
	if get_child_count() > 0:
		return
		
	var spawn_count = wave_sizes[current_wave % wave_sizes.size()]
	for i in range(spawn_count):
		var new_enemy = enemy_preload.instance()
		add_child(new_enemy)
		new_enemy.rotate_y(rand_range(0.0, 1.0))
		new_enemy.target = player
		new_enemy.name = "Enemy%d" % [i]
		new_enemy.global_transform.origin = Vector3(
			rand_range(-40, 40),
			2.0,
			rand_range(-40, 40)
		)
		
	current_wave += 1
