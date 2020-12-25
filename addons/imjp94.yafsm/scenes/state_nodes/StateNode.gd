tool
extends "res://addons/imjp94.yafsm/scenes/flowchart/FlowChartNode.gd"
const State = preload("../../src/states/State.gd")

signal name_edit_entered(new_name) # Emits when focused exit or Enter pressed

onready var name_edit = $MarginContainer/NameEdit

var undo_redo

var state setget set_state

var _to_free

func _init():
	_to_free = []
	set_state(State.new("State"))

func _ready():
	name_edit.text = "State"
	name_edit.connect("focus_exited", self, "_on_NameEdit_focus_exited")
	name_edit.connect("text_entered", self, "_on_NameEdit_text_entered")
	set_process_input(false) # _input only required when name_edit enabled to check mouse click outside

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.doubleclick:
			enable_name_edit(true)
			accept_event()

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if get_focus_owner() == name_edit:
				var local_event = name_edit.make_input_local(event)
				if not name_edit.get_rect().has_point(local_event.position):
					name_edit.release_focus()

func enable_name_edit(v):
	if v:
		set_process_input(true)
		name_edit.editable = true
		name_edit.mouse_filter = MOUSE_FILTER_PASS
		name_edit.grab_focus()
	else:
		set_process_input(false)
		name_edit.editable = false
		name_edit.mouse_filter = MOUSE_FILTER_IGNORE
		name_edit.release_focus()

func _on_state_name_changed(new_name):
	name_edit.text = new_name

func _on_state_changed(new_state):
	if state:
		state.connect("name_changed", self, "_on_state_name_changed")
		if name_edit:
			name_edit.text = state.name

func _on_NameEdit_focus_exited():
	enable_name_edit(false)
	emit_signal("name_edit_entered", name_edit.text)

func _on_NameEdit_text_entered(new_text):
	enable_name_edit(false)
	emit_signal("name_edit_entered", new_text)

func set_state(s):
	if state != s:
		state = s
		_on_state_changed(s)
