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
	JoinHostMenu.ErrorLabel.text = "Server Join Status: "+str(err)


func _on_multiplayer_client_disconnected() -> void:
	JoinHostMenu.show()
	# Window Mouse Mode
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
