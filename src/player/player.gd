extends Sprite2D

var is_turn = false;
@onready var tile_map = $%PoliceManager

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
	var dir = input_direction()
	if dir == Vector2i.ZERO:
		return
	var cur_map_pos = get_map_position()

	if not is_obstacle(cur_map_pos + dir):
		translate(dir * 128)
	
	_next_stage()

func _process(delta):
	if is_turn:
		player_turn()	
			
func _next_stage():
	get_parent().emit_signal("next_state")


func _on_main_scene_onchange_state(state):
	if state == Constant.STATE_PLAYER:
		is_turn = true
	else:
		is_turn = false

func get_map_position():
	var map_pos = tile_map.local_to_map(self.position)
	return map_pos

func is_obstacle(pos: Vector2i):
	return tile_map.is_occupied(pos)

