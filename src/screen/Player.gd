extends Sprite2D

var step = 12

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
	
func _process(delta):
	var dir = input_direction()
	translate(dir * 128)
