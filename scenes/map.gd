extends Node3D

const astroidCount = 50
const spawnRadius = 3000
const spawnHeightRange = 20
@export var astroid_scene: PackedScene

@rpc("any_peer", "call_local", "reliable", 0)
func _initialize_world():
	# Spawn Astroid Belt
	for i in astroidCount:
		var instance = astroid_scene.instantiate()
		instance.position = Vector3(randi()%spawnRadius, randi()%spawnHeightRange, randi()%spawnRadius)
		instance.name = "astroid"+str(i)
		call_deferred("add_child",instance)


func _on_multiplayer_create_server_success() -> void:
	_initialize_world.rpc()
