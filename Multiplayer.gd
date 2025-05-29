extends Node

const port = 443
const localport = 9999

@export var player_scene: PackedScene

@onready var peer = ENetMultiplayerPeer.new()

func _on_hud_create_server():
	var error = peer.create_server(port)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player() # Add Host to lobby
	
	upnp_setup()

func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child",player)

func exit_game(id):
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)

func _on_hud_join_server(ip = "localhost"):
	peer.create_client(ip, port, 0, 0, 0, localport)
	multiplayer.multiplayer_peer = peer
	
func del_player(id):
	rpc("_del_player",id)
	
@rpc("any_peer","call_local")
func _del_player(id):
	get_node(str(id)).queue_free()

func upnp_setup():
	# UPNP queries take some time.
	var upnp = UPNP.new()
	var err = upnp.discover()

	if err != OK:
		push_error(str(err))
		print("Error In UPNP Setup: "+err)
		return

	if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
		upnp.add_port_mapping(port, port, ProjectSettings.get_setting("application/config/name"), "UDP")
		upnp.add_port_mapping(port, port, ProjectSettings.get_setting("application/config/name"), "TCP")
		print("UPNP Setup Successful")
	else:
		print("Could Not Get UPNP Gateway")
