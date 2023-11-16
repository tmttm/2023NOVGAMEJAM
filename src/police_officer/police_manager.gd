extends TileMap

var PoliceClass = load("res://police_officer/police_officer.gd")

const POLICE_LAYER = 0

var polices = []

func _on_main_scene_onchange_state(state):
	if state == Constant.STATE_INIT:
		init_polices()
	if state == Constant.STATE_PRE_RECOGNITION or state == Constant.STATE_POST_RECOGNITION:
		recognize()
	elif state == Constant.STATE_POLICE:
		move_polices()
	else:
		pass

func init_polices():
	# load tilemap
	pass
	
func recognize():
	# TODO: is in light in player
	get_parent().emit_signal("next_state")

func move_polices():
	print(polices)
	# TODO: move polices


func _on_child_entered_tree(node:Node2D):
	if node.get_script() == PoliceClass:
		polices.append(node)
