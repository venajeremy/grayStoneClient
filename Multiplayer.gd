extends Node

const port = 60413
const localport = 9999

@export var player_scene: PackedScene

@onready var peer = ENetMultiplayerPeer.new()

func _on_hud_create_server():
	var error = peer.create_server(localport)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player() # Add Host to lobby

func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child",player)

func exit_game(id):
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)

func _on_hud_join_server(ip = "localhost"):
	print("Joining Server: "+ip+", "+str(port))
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer

func del_player(id):
	rpc("_del_player",id)

@rpc("any_peer","call_local")
func _del_player(id):
	get_node(str(id)).queue_free()
