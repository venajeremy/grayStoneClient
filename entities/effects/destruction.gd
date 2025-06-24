extends Node3D

@onready var animationPlayer = $AnimatedSprite3D

var track

var velocity

func _ready():
	animationPlayer.connect("animation_looped", _destroy)
	animationPlayer.play("destruction")

func _destroy():
	queue_free()

func _physics_process(delta):
	position += velocity*delta
