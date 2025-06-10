extends Control

@onready var JoinHostMenu = $JoinHostMenu

func _ready():
	JoinHostMenu.show()

func _on_multiplayer_create_server_success():
	JoinHostMenu.hide()

func _on_multiplayer_join_server_success():
	JoinHostMenu.hide()


func _on_multiplayer_create_server_status(err: Variant) -> void:
	JoinHostMenu.ErrorLabel.text = "Server Connection Status: "+str(err)

func _on_multiplayer_join_server_status(err: Variant) -> void:
	JoinHostMenu.ErrorLabel.text = "Server Creation Status: "+str(err)
