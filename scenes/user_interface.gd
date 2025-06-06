extends Control

@onready var JoinHostMenu = $JoinHostMenu
@onready var ShipUI = $ShipUi

func _ready():
	ShipUI.hide()
	JoinHostMenu.show()

func _on_multiplayer_create_server_success():
	ShipUI.show()
	JoinHostMenu.hide()

func _on_multiplayer_join_server_success():
	ShipUI.show()
	JoinHostMenu.hide()


func _on_multiplayer_create_server_status(err: Variant) -> void:
	JoinHostMenu.ErrorLabel.text = "Server Connection Status: "+str(err)

func _on_multiplayer_join_server_status(err: Variant) -> void:
	JoinHostMenu.ErrorLabel.text = "Server Creation Status: "+str(err)
