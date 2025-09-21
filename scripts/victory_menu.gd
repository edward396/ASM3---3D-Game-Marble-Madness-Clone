extends CanvasLayer

@onready var victory_sound: AudioStreamPlayer = $VictorySound

func play_victory():
	if victory_sound and victory_sound.stream:
		victory_sound.play()