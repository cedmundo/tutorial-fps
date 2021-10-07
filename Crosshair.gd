extends VBoxContainer

export(float, 1.0, 100.0) var accuracy = 100.0
export(float) var min_sparse = 0.1
export(float) var max_sparse = 1.5

onready var top_bar = $TopBar
onready var bottom_bar = $BottomBar
onready var left_bar = $Center/LeftBar
onready var right_bar = $Center/RightBar

func _process(_delta):
	var mapped_accuracy = (
		_remap_value(clamp(accuracy, 1.0, 100.0), 100.0, 1.0, min_sparse, max_sparse)
	)
	top_bar.anchor_top = -mapped_accuracy
	bottom_bar.anchor_bottom = mapped_accuracy
	
	left_bar.anchor_left = -mapped_accuracy
	right_bar.anchor_right = mapped_accuracy

func _remap_value(value, low1, high1, low2, high2):
	return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
