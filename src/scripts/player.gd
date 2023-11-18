extends Node2D

signal posting

var is_turn = false
var is_moving = false

@onready var tile_map = $%PoliceManager
@onready var sprite = $Sprite
@onready var animation_player = $AnimationPlayer
var prev_dir = Vector2i.DOWN

const low = Color("#707070")
const high = Color("#ffffff")

func input_direction():
	var dir = Vector2i.ZERO
	
	if Input.is_action_just_pressed("up"):
		dir = Vector2i.UP
	if Input.is_action_just_pressed("down"):
		dir = Vector2i.DOWN
	if Input.is_action_just_pressed("left"):
		dir = Vector2i.LEFT
	if Input.is_action_just_pressed("right"):
		dir = Vector2i.RIGHT

	return dir
	
func player_turn():
	var cur_map_pos = get_map_position()

	var dir = input_direction()
	var post = Input.is_action_just_pressed("post")

	if dir == Vector2i.ZERO and not post:
		return

	if post:
		var front = cur_map_pos + prev_dir
		var sl = tile_map.get_streetlight(front)
		if sl:
			sl.post()
			emit_signal("posting")

	else:
		prev_dir = dir
	
		if not is_obstacle(cur_map_pos + dir):
			move(dir)
	
	_next_stage()

func animate_non_moving():
	if prev_dir == Vector2i.DOWN:
		animation_player.play("DOWN")
	elif prev_dir == Vector2i.UP:
		animation_player.play("UP")
	else:
		animation_player.play("side")
		sprite.flip_h = prev_dir.x > 0
	

func _physics_process(delta):
	if is_moving  == false:
		animate_non_moving()
		return
	animation_player.play("walking")
	if global_position == sprite.global_position:
		is_moving = false
		return
			
	sprite.global_position = sprite.global_position.move_toward(global_position, 16)

func move(dir):
	var map_pos = tile_map.local_to_map(self.position)
	var next_pos = map_pos + dir

	is_moving = true

	self.global_position = tile_map.map_to_local(next_pos)
	sprite.global_position = tile_map.map_to_local(map_pos)

func _process(delta):
	if is_turn:
		player_turn()
	
func brightness():
	if tile_map.is_player_in_lights():
		modulate = high
	else:
		modulate = low
		
func _next_stage():
	get_parent().emit_signal("next_state")
			
func get_map_position():
	var map_pos = tile_map.local_to_map(self.position)
	return map_pos
	
func is_obstacle(pos: Vector2i):
	return tile_map.is_occupied(pos)
	
func _on_main_scene_onchange_state(state):
	brightness()
	if state == Constant.STATE_PLAYER:
		is_turn = true
	else:
		is_turn = false
