extends Control

@onready var Crosshair = $Crosshair
@onready var BottomLeftUtility = $Utility1/Utility1
@onready var Health = $Health/Health
@onready var HitMarker = $HitCrosshair

func _ready():
	HitMarker.hide()

func hit_marker():
	HitMarker.show()
	await get_tree().create_timer(0.25).timeout
	HitMarker.hide()
