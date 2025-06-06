extends Control

signal joinServer(ip, port)
signal createServer(port)

@onready var IPInputJoin = $Join/EnterIP/IPInputJoin
@onready var PortInputJoin = $Join/EnterPort/PortInputJoin
@onready var JoinButton = $Join/JoinButton
@onready var ErrorLabel = $ErrorLabel

@onready var PortInputHost = $Host/EnterPort/PortInputHost
@onready var HostButton = $Host/HostButton

# Called when the node enters the scene tree for the first time.
func _ready():
	IPInputJoin.grab_focus()

func _input(event):
	if JoinButton.button_pressed or event.is_action_pressed("enter"):
		joinServer.emit(IPInputJoin.text, int(PortInputJoin.text))
	if HostButton.button_pressed or event.is_action_pressed("backslash"):
		createServer.emit(int(PortInputHost.text))
