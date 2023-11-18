extends Node2D

@onready var sprite = $Sprite2D
@onready var light = $Sprite2D/Light

var dir = Vector2i.RIGHT
var is_moving = false
var is_turing = false

func _ready():
	pass

func moving():
	if is_moving  == false:
		return
		
	if global_position == sprite.global_position:
		is_moving = false
		return
			
	sprite.global_position = sprite.global_position.move_toward(global_position, 16)

func move_toward_angle(from : float, to: float, delta : float):
	var ans = fposmod(to - from, TAU)
	if ans > PI:
		ans -= TAU
	return from + ans * delta

func turning(delta):
	if is_turing == false:
		return
	
	if abs(global_rotation - light.global_rotation) < 0.01:
		light.global_rotation = global_rotation
		is_turing = false
		return

	light.global_rotation = move_toward_angle(light.global_rotation, global_rotation, delta * TAU)
	

func _physics_process(delta):
	moving()
	turning(delta)

func move_forward(tile_map: TileMap):
	var map_pos = tile_map.local_to_map(self.position)
	var front_pos = get_front_pos(tile_map)
	
	tile_map.move_cell(map_pos, front_pos)
	is_moving = true

	self.global_position = tile_map.map_to_local(front_pos)
	sprite.global_position = tile_map.map_to_local(map_pos)

func is_obstacle_in_front(tile_map: TileMap):
	var front_pos = get_front_pos(tile_map)
	
	return tile_map.is_occupied(front_pos)

func get_front_pos(tile_map: TileMap):
	var map_pos = tile_map.local_to_map(self.position)

	return map_pos + dir

func turn(ccw):
	var _sign = 1 if ccw else -1
	self.dir = Vector2i(Vector2(dir).rotated(_sign * PI/2))
	
	var cur_dir = global_rotation

	is_turing = true
	
	self.global_rotation = self.global_rotation + _sign * PI/2
	light.global_rotation = cur_dir

	

func get_lights(tile_map: TileMap):
	var lights = []
	for m in find_children('Marker2D*', "Marker2D", true):
		var v = tile_map.local_to_map(m.global_position)
		lights.append(v)
	return lights
