extends TileMap

var PoliceClass = load("res://scripts/police_officer.gd")

const POLICE_LAYER = 0

@onready var player = $%Player 
var is_player_visible = false
var polices = []

var rng = RandomNumberGenerator.new()

var tiles = []

var astar_grid: AStarGrid2D
var remain_target = 0

func _ready():
	astar_grid = AStarGrid2D.new()
	astar_grid.size = Vector2i(32,32)
	astar_grid.cell_size = Vector2i(128, 128)
	astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER 
	astar_grid.update()

	rng.seed = 42

	tiles.append_array(get_used_cells_by_id(1, 2))

func _on_main_scene_onchange_state(state):
	if state == Constant.STATE_INIT:
		init_polices()
	elif state == Constant.STATE_PRE_RECOGNITION or state == Constant.STATE_POST_RECOGNITION:
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
	for p in polices:
		var player_pos = player.get_map_position()
		var police_pos = p.get_front_pos(self)
		
		if player_pos == police_pos:
			_game_over()
			return
	is_player_visible = is_player_in_lights()
	if is_player_visible:
		remain_target = 1
	print(is_player_visible, remain_target)
	_next_stage()

func is_player_in_lights():
	var player_pos = player.get_map_position()

	for p in polices:
		print(p.get_lights(self), player_pos)
		if player_pos in p.get_lights(self):
			return true
	return false

func move_polices():
	if is_player_visible or remain_target > 0:
		move_to_player()
		move_to_player()
		remain_target -= 1
	else:
		move_random()
	# # TODO: move polices
	_next_stage()

func move_random():
	for p in polices:
		var _max = 2 if not p.is_obstacle_in_front(self) else 1
		var idx = rng.randi_range(0,_max)
		
		match idx:
			0:
				p.turn(true)
			1:
				p.turn(false)
			2:
				p.move_forward(self)

func move_to_player():
	for p in polices:
		var police_pos = local_to_map(p.position)
		var path = get_shortest_path_to_player(police_pos)

		if len(path) <= 2:
			continue

		var dpos = Vector2(path[1] - police_pos)
		var angle = dpos.angle_to(p.dir) / PI

		var PRECESION = 0.001
		if abs(angle) < PRECESION:
			p.move_forward(self)
		elif abs(angle - 0.5) < PRECESION:
			p.turn(false)
		elif abs(angle + 0.5) < PRECESION:
			p.turn(true)
		else:
			p.turn(rng.randf() < 0.5)
			
		
func move_cell(from: Vector2i, to:Vector2i):
	var idx = tiles.find(from)
	tiles.remove_at(idx)
	tiles.append(to)


	astar_grid.set_point_solid(from, false)
	astar_grid.set_point_solid(to, true)

	astar_grid.update()

func is_occupied(pos: Vector2i):
	return pos in tiles

func get_shortest_path_to_player(from: Vector2i):
	var player_pos = player.get_map_position()

	return astar_grid.get_id_path(from, player_pos)

func _on_child_entered_tree(node:Node2D):
	if node.get_script() == PoliceClass:
		polices.append(node)
		tiles.append(local_to_map(node.position))

func _game_over():
	get_parent().emit_signal("gameend")
	_next_stage()

func _next_stage():
	get_parent().emit_signal("next_state")


