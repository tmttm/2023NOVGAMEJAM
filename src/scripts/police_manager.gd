extends TileMap

signal onadd_streetlights

var PoliceClass = load("res://scripts/police_officer.gd")
var StreetlightClass = load("res://scripts/streetlight.gd")

const POLICE_LAYER = 0

@onready var player = $%Player 
var is_player_visible = false
var polices = []

var rng = RandomNumberGenerator.new()

var tiles = []
var streetlights = {}

var astar_grid: AStarGrid2D
var remain_target = 0
func _init():
	astar_grid = AStarGrid2D.new()
	astar_grid.region = Rect2i(-16,-16,32,32)
	astar_grid.cell_size = Vector2i(128, 128)
	astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER 
	astar_grid.update()

func _ready():

	rng.seed = 42

	for i in get_used_cells_by_id(1, 4):
		var id = get_cell_tile_data(1, i).terrain
		if id == 0:
			tiles.append(i)

func _on_main_scene_onchange_state(state):
	if state == Constant.STATE_INIT:
		pass
	elif state == Constant.STATE_PRE_RECOGNITION or state == Constant.STATE_POST_RECOGNITION:
		recognize()
	elif state == Constant.STATE_POLICE:
		move_polices()
	else:
		pass
	
func recognize():
	for p in polices:
		var player_pos = player.get_map_position()
		var police_front_pos = p.get_front_pos(self)
		
		if player_pos == police_front_pos:
			_game_over()
			return

	is_player_visible = is_player_in_lights()

	if is_player_visible:
		remain_target = 2
	
	var lights = get_lights()
	for p in polices:
		var police_pos = local_to_map(p.position)
		p.set_brightness(police_pos in lights)
		p.set_visible_exclaim(remain_target > 0)

	_next_stage()

func is_player_in_lights():
	var player_pos = player.get_map_position()

	for p in polices:
		if player_pos in p.get_lights(self):
			return true

	for k in streetlights:
		var sl = streetlights[k]
		if player_pos in sl.get_lights(self):
			return true

	return false

func get_lights():
	var lights = []

	for p in polices:
		for l in p.get_lights(self):
			lights.append(l)

	for k in streetlights:
		var sl = streetlights[k]
		for l in sl.get_lights(self):
			lights.append(l)
	
	return lights

func move_polices():
	if is_player_visible or remain_target > 0:
		move_to_player()
		remain_target -= 1
	else:
		move_random()

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

		var dpos = Vector2(path[1] - path[0])
		var angle = dpos.angle_to(p.dir) / PI

		
		var PRECESION = 0.001
		if len(path) <= 2 and abs(angle) < PRECESION:
			continue
		elif abs(angle) < PRECESION:
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

func is_occupied(pos: Vector2i):
	return pos in tiles

func get_shortest_path_to_player(from: Vector2i):
	var player_pos = player.get_map_position()
	return astar_grid.get_id_path(from, player_pos)

func get_streetlight(at: Vector2i):
	if at in streetlights:
		return streetlights[at]
	return null

func _on_child_entered_tree(node:Node2D):
	if node.get_script() == PoliceClass:
		polices.append(node)
		tiles.append(local_to_map(node.position))

	if node.get_script() == StreetlightClass:
		add_streetlight(node)

func add_streetlight(node):
	var k = local_to_map(node.position)
	streetlights[k] = node
	astar_grid.set_point_solid(k, true)
	tiles.append(local_to_map(node.position))
	emit_signal("onadd_streetlights")

func _game_over():
	get_parent().emit_signal("gameend")
	_next_stage()

func _next_stage():
	get_parent().emit_signal("next_state")
