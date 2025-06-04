extends Node3D

const astroidCount = 50
const spawnRadius = 3000
const spawnHeightRange = 20
@export var astroid_scene: PackedScene

func _ready():
	# Spawn Astroid Belt
	for i in astroidCount:
		var instance = astroid_scene.instantiate()
		instance.position = Vector3(randi()%spawnRadius, randi()%spawnHeightRange, randi()%spawnRadius)
		get_parent().add_child.call_deferred(instance, true)
