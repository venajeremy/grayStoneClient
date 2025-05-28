extends CharacterBody3D

const speed = 100
const trustMult = 5
const sensitivity = -0.04
const rotationSensitivity = -5
var acceleration = Vector3()
var angularVelocity = Vector3()
var angularAcceleration = Vector3()



# Ship components
@onready var guns = $Guns.get_children()
@onready var gun_anim = $AnimationPlayer
var gunSelected = 0
@onready var gunCount = guns.size()

# Sounds
@onready var shipAudio = $shipAudio
# Gun Sounds
const laser1 = preload("res://audio/wasp/gun/gun1.wav")
const laser2 = preload("res://audio/wasp/gun/gun2.wav")
const laser3 = preload("res://audio/wasp/gun/gun3.wav")
const laser4 = preload("res://audio/wasp/gun/gun4.wav")
# Movement Audio
const thruster = preload("res://audio/wasp/movement/thruster.wav")
const speedThruster = preload("res://audio/wasp/movement/thruster2.wav")
# Bullets
var bullet = load("res://bullet.tscn")
var instance

<<<<<<< Updated upstream
=======
#UI/Navigation components
@onready var Axis_x: Node3D = $"Speed Axis Indicator/+X"
@onready var Axis_y: Node3D = $"Speed Axis Indicator/+Y"
@onready var Axis_z: Node3D = $"Speed Axis Indicator/+Z"
@onready var direction_of_movement: Node3D = $"Direction of movement"
@onready var pointing_vector: MeshInstance3D = $"Ship/Pointing Vector"




func _enter_tree():
	set_multiplayer_authority(name.to_int())
>>>>>>> Stashed changes

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_object_local(Vector3(0,1,0),deg_to_rad(event.relative.x * sensitivity))
		rotate_object_local(Vector3(1,0,0),deg_to_rad(event.relative.y * sensitivity))


<<<<<<< Updated upstream
func _physics_process(delta):
	acceleration = Vector3(0,0,0)
	
	# Handle input
	if Input.is_action_pressed("w"):
		acceleration += -speed*transform.basis.z * delta
	if Input.is_action_pressed("s"):
		acceleration += speed*transform.basis.z * delta
	if Input.is_action_pressed("d"):
		acceleration += speed*transform.basis.x * delta
	if Input.is_action_pressed("a"):
		acceleration += -speed*transform.basis.x * delta
	if Input.is_action_pressed("space"):
		acceleration += speed*transform.basis.y * delta
	if Input.is_action_pressed("ctrl"):
		acceleration += -speed*transform.basis.y * delta
	if Input.is_action_pressed("shift"):
		acceleration += acceleration*trustMult
	if Input.is_action_pressed("q"):
		rotate_object_local(Vector3(0,0,1),deg_to_rad(-rotationSensitivity))
	if Input.is_action_pressed("e"):
		rotate_object_local(Vector3(0,0,1),deg_to_rad(rotationSensitivity))
	if Input.is_action_pressed("lmb"):
		_fire()
			
	velocity += acceleration
	move_and_slide()
	
=======
func _physics_process(delta):                #Think of this like a loop runing multiple times a second
	if is_multiplayer_authority():
		acceleration = Vector3(0,0,0)
		# Handle input
		if Input.is_action_pressed("Up Mouse Button"):
			acceleration += -speed*transform.basis.z * delta   #Think of this like deltaV (remember acceleration is just a change in V)
		if Input.is_action_pressed("Down Mouse Button"):
			acceleration += speed*transform.basis.z * delta    #Also "acceleration" var is technically a vector, meaning it retains all the x,y,z components
		if Input.is_action_pressed("d"):
			acceleration += speed*transform.basis.x * delta
		if Input.is_action_pressed("a"):
			acceleration += -speed*transform.basis.x * delta
		if Input.is_action_pressed("w"):
			acceleration += speed*transform.basis.y * delta
		if Input.is_action_pressed("s"):
			acceleration += -speed*transform.basis.y * delta
		if Input.is_action_pressed("shift"):
			acceleration += acceleration*trustMult
		if Input.is_action_pressed("q"):
			rotate_object_local(Vector3(0,0,1),deg_to_rad(-rotationSensitivity))
		if Input.is_action_pressed("e"):
			rotate_object_local(Vector3(0,0,1),deg_to_rad(rotationSensitivity))
		if Input.is_action_pressed("lmb"):
			_fire()
		if Input.is_action_pressed("esc"):
			$"../".exit_game(name.to_int())
			get_tree().quit()
		
		velocity += acceleration
		move_and_slide()
	
	#Find Individual velocity vector components for UI/Debug Use
		var velocity_x = velocity.dot(transform.basis.x)
		var velocity_y = velocity.dot(transform.basis.y)
		var velocity_z = velocity.dot(transform.basis.z)
	
		var scale_factorx = 0.0 + velocity_x*0.1
		var scale_factory = 0.0 + velocity_y*0.1
		var scale_factorz = 0.0 + -velocity_z*0.1
	
		Axis_x.scale = Vector3(scale_factorx, Axis_x.scale.y, Axis_x.scale.z)  # Only scale X
		Axis_y.scale = Vector3(Axis_y.scale.x, scale_factory, Axis_y.scale.z)  # Only scale Y
		Axis_z.scale = Vector3(Axis_z.scale.x, Axis_z.scale.y, scale_factorz)  # Only scale Z	

	#Direction of Motion Indicator
	var velocity_scale = velocity.length()*0.1
	direction_of_movement.look_at(global_transform.origin + velocity, Vector3.UP)
	direction_of_movement.scale=Vector3(direction_of_movement.scale.x,direction_of_movement.scale.y,velocity_scale)
	
	#Pointing Vector
	
	



>>>>>>> Stashed changes
func _play_sound(sound):
	for player in shipAudio.get_children():
		if not player.playing:
			player.stream = sound
			player.play()
			break

func _fire():
	if !gun_anim.is_playing():
			# Play Animation
			gun_anim.play("shoot")
			
			# Play Sound
			var rng = RandomNumberGenerator.new()
			if(rng.randi_range(0,1)==0):
				_play_sound(laser1)
			else:
				_play_sound(laser2)
			
			# Create Bullet
			instance = bullet.instantiate()
			instance.position = guns[gunSelected].global_position
			instance.transform.basis = guns[gunSelected].global_transform.basis
			
			# Cycle Which gun is firing
			gunSelected=gunSelected+1
			if(gunSelected>=gunCount):
				gunSelected=0;
			
			get_parent().add_child(instance)
