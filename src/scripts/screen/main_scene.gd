extends Control

signal onchange_state(state: int)
signal onchange_turn(turn: int)
signal onchange_poster(poster:int)
signal next_state
signal gameend


@export var _turn: int = 10
var _poster: int = 0
var _state = Constant.STATE_INIT
var game_end = false

@onready var gameover_panel:Panel = $%GameoverPanel

func _set(property, value):
	if property == "state":
		self._state = value
		emit_signal("onchange_state", value)

	if property == "turn":
		self._turn = value
		emit_signal("onchange_turn", value)

	if property == "poster":
		self._poster = value
		emit_signal("onchange_poster", value)
		
func _ready():
	self.set("state",Constant.STATE_INIT)
	init_state()

func init_state():
	game_end = false
	_next_state()

func end_turn():
	self.set("turn", self._turn - 1)

func _next_state():
	if self._state == Constant.STATE_INIT:
		self.set("state", Constant.STATE_PLAYER)
	elif self._state == Constant.STATE_PLAYER:
		self.set("state", Constant.STATE_PRE_RECOGNITION)
	elif self._state == Constant.STATE_PRE_RECOGNITION:
		if game_end:
			self.set("state", Constant.STATE_END)
		else:
			self.set("state", Constant.STATE_POLICE)
	elif self._state == Constant.STATE_POLICE:
		self.set("state", Constant.STATE_POST_RECOGNITION)
	elif self._state == Constant.STATE_POST_RECOGNITION:
		if game_end:
			self.set("state", Constant.STATE_END)
		else:
			self.set("state", Constant.STATE_PLAYER)
	elif self._state == Constant.STATE_END:
		self.set("state", Constant.STATE_INIT)
	else:
		push_error("NON-ACCESIBLE STATE")

func _on_next_state():
	_next_state()

func _on_gameend():
	game_end = true

func _on_onchange_state(state):
	if state == Constant.STATE_END:
		gameover_panel.visible = true

	if state == Constant.STATE_PLAYER:
		end_turn()


func _on_police_manager_onadd_streetlights():
	set("poster", _poster + 1)

func _on_player_posting():
	set("poster", _poster - 1)
