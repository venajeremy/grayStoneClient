extends Node3D

#Sounds
@onready var enemyAudio = $"enemyAudio"
#Damage
const strike = preload("res://audio/wasp/damage/strike.wav")
const destroy = preload("res://audio/wasp/damage/destroy.wav")


func _play_sound(sound):
	for player in enemyAudio.get_children():
		if not player.playing:
			player.stream = sound
			player.play()
			break


func _on_primary_hitbox_damaged():
	_play_sound(strike)
