extends Node2D

const INIT = 0
const PLAYER = 1
const POLICE = 2
const RECOGNITION = 3
const END = 4

var round = INIT
var game_end = false

func _ready():
	round = INIT

func init_stage():
	game_end = false
	next_stage()

func next_stage():
	if self.round == INIT:
		round = PLAYER
	elif self.round == PLAYER:
		round = POLICE
	elif self.round == POLICE:
		round = RECOGNITION
	elif self.round == RECOGNITION:
		if game_end:
			round = END
		else:
			round = PLAYER
	elif self.round == END:
		round = INIT
		
