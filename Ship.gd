extends CharacterBody3D

const speed = 100
const trustMult = 5
const velocityCap = 500
const sensitivity = -0.04
const rotationSensitivity = -5
var acceleration = Vector3()
var angularVelocity = Vector3()
var angularAcceleration = Vector3()


# Boost settings
@export var base_acceleration = 100.0
@export var boost_multiplier = 300.0
var pre_boost_velocity = Vector3.ZERO
var is_boosting = false

# Ship components
@onready var cam = $Camera3D
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

func _enter_tree():
	set_multiplayer_authority(name.to_int(), true)

# Called when the node enters the scene tree for the first time.
func _ready():
	cam.current = is_multiplayer_authority()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_object_local(Vector3(0,1,0),deg_to_rad(event.relative.x * sensitivity))
		rotate_object_local(Vector3(1,0,0),deg_to_rad(event.relative.y * sensitivity))


func _physics_process(delta):
	if !is_multiplayer_authority():
		return
	
	acceleration = Vector3(0,0,0)
	var frame_start_velocity = velocity
	
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
	if Input.is_action_pressed("q"):
		rotate_object_local(Vector3(0,0,1),deg_to_rad(-rotationSensitivity))
	if Input.is_action_pressed("e"):
		rotate_object_local(Vector3(0,0,1),deg_to_rad(rotationSensitivity))
	if Input.is_action_pressed("lmb"):
		_fire.rpc()
	if Input.is_action_pressed("esc"):
		$"../".exit_game(name.to_int())
		get_tree().quit()
	
	# BOOST SYSTEM
	if Input.is_action_just_pressed("shift"):
		# Store pre-boost velocity
		pre_boost_velocity = frame_start_velocity
		is_boosting = true
		
		# Calculate boost direction (always forward where you're facing)
		var boost_direction = -transform.basis.z.normalized()
		
		# Apply boost in facing direction while maintaining original speed
		velocity = boost_direction * pre_boost_velocity.length() * boost_multiplier
	
	if Input.is_action_just_released("shift"):
		is_boosting = false
		# Optionally apply some braking here if needed

	velocity += acceleration
	if(velocity.length() > velocityCap):
		velocity = (velocity/velocity.length())*velocityCap
	
	
	move_and_slide()
	
	


func _play_sound(sound):
	for player in shipAudio.get_children():
		if not player.playing:
			player.stream = sound
			player.play()
			break

@rpc("any_peer", "call_local", "reliable", 0)
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
			
			get_parent().add_child(instance, true)
