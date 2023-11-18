extends Node2D


var postered_sprite = preload("res://streetlight/streetlight_postered.png")
var postered = false
@onready var sprite = $Sprite2D

func post():
	if not postered:
		postered = true
		sprite.texture = postered_sprite
	return not postered

func get_lights(tile_map: TileMap):
	var lights = []
	for m in find_children('Marker2D*', "Marker2D", true):
		var v = tile_map.local_to_map(m.global_position)
		lights.append(v)
	return lights