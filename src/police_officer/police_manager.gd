extends TileMap

var PoliceClass = load("res://police_officer/police_officer.gd")

const POLICE_LAYER = 0

var player = null
var polices = []

var rng = RandomNumberGenerator.new()

var tiles = []

func _ready():
	rng.seed = 42

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
	_next_stage()

func move_polices():
	for p in polices:
		# print(p)
		var _max = 2 if not p.is_obstacle_in_front(self) else 1
		var idx = rng.randi_range(0,_max)
		
		match idx:
			0:
				p.turn(true)
			1:
				p.turn(false)
			2:
				p.move_forward(self)
		
	# TODO: move polices
	_next_stage()

func move_cell(from: Vector2i, to:Vector2i):
	var idx = tiles.find(from)
	tiles.remove_at(idx)
	tiles.append(to)
	
func is_occupied(pos: Vector2i):
	return pos in tiles

func _on_child_entered_tree(node:Node2D):
	if node.get_script() == PoliceClass:
		polices.append(node)
		tiles.append(local_to_map(node.position))

func _next_stage():
	get_parent().emit_signal("next_state")
