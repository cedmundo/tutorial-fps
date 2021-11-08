extends Spatial

export(NodePath) var ammo_label_path : NodePath
export(bool) var is_active = false
export(float) var damage = 40.0

onready var animation_tree = $AnimationTree
onready var ammo_label = get_node(ammo_label_path)

var accuracy = 0.0
var accuracy_bonus = 0.0
var is_moving = false

func _process(_delta):
	if not is_active:
		return
		
	ammo_label.text = ""
	
	if Input.is_action_just_pressed("fire"):
		animation_tree.set("parameters/conditions/hit", true)
		yield(get_tree().create_timer(0.1), "timeout")
		animation_tree.set("parameters/conditions/hit", false)
		

func _on_Area_body_entered(body):
	if body.is_in_group("enemies"):
		body.deal_damage(damage)
