extends Node

signal noray_connected

const NORAY_ADDRESS = "tomfol.io"
const NORAY_PORT = 8890

var is_host = false
var external_oid = ""
@export var player_scene: PackedScene

var peer = ENetMultiplayerPeer.new()

func _ready():
	Noray.on_connect_to_host.connect(on_noray_connected)
	Noray.on_connect_nat.connect(handle_nat_connection)
	Noray.on_connect_relay.connect(handle_relay_connection)
	
	Noray.connect_to_host(NORAY_ADDRESS, NORAY_PORT)

func on_noray_connected():
	print("Connected to Noray server")
	
	Noray.register_host()
	await Noray.on_pid
	await Noray.register_remote()
	print("My oid: "+Noray.oid)
	noray_connected.emit()

func host():
	print("Hosting")
	
	peer = ENetMultiplayerPeer.new()
	peer.create_server(Noray.local_port)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	is_host = true
	_add_player() # Add Host to lobby

func _on_hud_create_server():
	host()

func join(oid):
	Noray.connect_nat(oid)
	external_oid = oid

func _on_hud_join_server(oid):
	join(oid)

func handle_nat_connection(address, port):
	var err = await connect_to_server(address, port)
	
	if err != OK && !is_host:
		print("NAT failed, using relay")
		Noray.connect_relay(external_oid)
		err = OK
	
	return err

func handle_relay_connection(address, port):
	return await connect_to_server(address, port)

func connect_to_server(address, port):
	var err = OK
	
	if !is_host:
		var udp = PacketPeerUDP.new()
		udp.bind(Noray.local_port)
		udp.set_dest_address(address, port)
		
		err = await PacketHandshake.over_packet_peer(udp)
		udp.close()
		
		if err != OK:
			if err != ERR_BUSY:
				print("Handshake failed")
				return err
		else:
			print("Handshake success")
		
		peer = ENetMultiplayerPeer.new()
		err = peer.create_client(address, port, 0, 0, 0, Noray.local_port)
		
		if err != OK:
			return err
		
		multiplayer.multiplayer_peer = peer
		
		return OK
	else:
		err = await PacketHandshake.over_enet(multiplayer.multiplayer_peer.host, address, port)
	
	return err

func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child",player)

func exit_game(id):
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)
	
func del_player(id):
	rpc("_del_player",id)
	
@rpc("any_peer","call_local")
func _del_player(id):
	get_node(str(id)).queue_free()
	
