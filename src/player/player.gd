extends Sprite2D

var is_turn = false;

func input_direction():
	var dir = Vector2.ZERO
	
	if Input.is_action_just_pressed("up"):
		dir = Vector2.UP
	if Input.is_action_just_pressed("down"):
		dir = Vector2.DOWN
	if Input.is_action_just_pressed("left"):
		dir = Vector2.LEFT
	if Input.is_action_just_pressed("right"):
		dir = Vector2.RIGHT
	
	return dir
	
func player_turn():
	var dir = input_direction()
	if dir == Vector2.ZERO:
		return
		
	translate(dir * 128)
	get_parent().emit_signal("next_state")

func _process(delta):
	if is_turn:
		player_turn()	
	
func _on_main_scene_onchange_state(state):
	if state == Constant.STATE_PLAYER:
		is_turn = true
	else:
		is_turn = false
