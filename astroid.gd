extends CharacterBody3D

var rotationSpeed = randf()*PI/200
var movementSpeed = randf()*50
var rotationConstant = Vector3(rotationSpeed,0,0)

func _ready():
	velocity = Vector3(0,0,-movementSpeed)

func _physics_process(delta):
	rotation += rotationConstant
	move_and_slide()
	
