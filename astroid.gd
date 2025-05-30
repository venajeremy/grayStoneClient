extends CharacterBody3D

var rotationSpeed = ((randi()%75)/75.0)*PI
var movementSpeed = randi()%100
var rotationConstant = Vector3(rotationSpeed,0,0)

func _ready():
	velocity = Vector3(0,0,-movementSpeed)

func _physics_process(delta):
	rotation += rotationConstant*delta
	move_and_slide()
