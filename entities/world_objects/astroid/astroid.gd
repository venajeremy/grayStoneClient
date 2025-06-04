extends CharacterBody3D

var rotationSpeed = 50
#((randi()%75)/75.0)*PI
var movementSpeed = 100
#randi()%100
var rotationConstant = Vector3(((randi()%rotationSpeed)/75.0)*PI,((randi()%rotationSpeed)/75.0)*PI,((randi()%rotationSpeed)/75.0)*PI)

func _ready():
	velocity = Vector3(0,0,-movementSpeed)

func _physics_process(delta):
	rotation += rotationConstant*delta
	move_and_slide()
