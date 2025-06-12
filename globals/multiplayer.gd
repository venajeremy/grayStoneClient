extends Node

signal joinServerStatus(res)
signal joinServerSuccess()
signal createServerStatus(res)
signal createServerSuccess()
signal clientDisconnected()

@export var player_scene: PackedScene
@onready var peer = ENetMultiplayerPeer.new()

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_player_connected(_id):
	pass

func _on_player_disconnected(_id):
	pass

func _on_hud_create_server(port = 9999):
	print("Creating Server On Port: "+str(port))
	peer.close() # Delete if current peer incase user already tried to join server
	var error = peer.create_server(port)
	if error:
		createServerStatus.emit(error)
		return error
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player() # Add Host to lobby
	createServerSuccess.emit()

func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child",player)

func exit_game(id):
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)

func _on_hud_join_server(ip = "localhost", port = 9999):
	print("Joining Server With IP: "+ip+" And Port: "+str(port))
	var error = peer.create_client(ip, port)
	if error:
		joinServerStatus.emit(error)
		return error
	multiplayer.multiplayer_peer = peer
	
	joinServerStatus.emit("Connecting To Server...")

func del_player(id):
	rpc("_del_player",id)
	
@rpc("any_peer","call_local")
func _del_player(id):
	get_node(str(id)).queue_free()

func _on_connected_ok():
	joinServerSuccess.emit()

func _on_server_disconnected():
	clientDisconnected.emit()
	

func _on_connected_fail():
	peer.close()
	joinServerStatus.emit("Could Not Connect To Provided IP and Port")
