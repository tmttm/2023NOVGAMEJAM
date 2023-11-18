extends Control

signal onchange_state(state: int)
signal next_state
signal gameend

var _state = Constant.STATE_INIT
var game_end = false
@onready var gameover_panel:Panel = $%GameoverPanel

func _set(property, value):
	if property == "state":
		self._state = value
		emit_signal("onchange_state", value)
		
func _ready():
	self.set("state",Constant.STATE_INIT)
	init_state()

func init_state():
	game_end = false
	_next_state()

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
