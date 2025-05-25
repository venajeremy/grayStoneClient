extends Control

signal joinServer(ip)

@onready var tempIPInput = $IPInput

# Called when the node enters the scene tree for the first time.
func _ready():
	tempIPInput.grab_focus()

func _input(event):
	if event.is_action_pressed("enter"):
		joinServer.emit(tempIPInput.text)
