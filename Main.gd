extends Spatial

enum GameState {
	ON_TITLE,
	PLAYING
}

onready var player = $Player
onready var enemies = $Enemies
onready var title = $Title
onready var last_score_label = $Title/LastScoreLabel

var state = GameState.ON_TITLE

func _process(_delta):
	if state == GameState.ON_TITLE:
		_process_on_title()
	elif state == GameState.PLAYING:
		_process_playing()

func _process_on_title():
	if Input.is_action_just_pressed("jump"):
		# Reset player
		player.health = player.default_health
		player.ammo = player.default_ammo
		player.global_transform.origin = Vector3(0, 2, 0)
		player.killed_units = 0
		player.is_alive = true
		
		# Reset enemies
		enemies.is_spawning = true
		enemies.current_wave = 0
		
		# Hide title
		title.visible = false
		
		# Set new state
		state = GameState.PLAYING
		
	if player.killed_units > 0:
		last_score_label.text = "Last score: %d" % [player.killed_units]
		
	
func _process_playing():
	if not player.is_alive:
		# Clean enemies
		enemies.is_spawning = false
		for child in enemies.get_children():
			child.queue_free()
			
		# Show title
		title.visible = true
		
		# Set new state
		state = GameState.ON_TITLE
