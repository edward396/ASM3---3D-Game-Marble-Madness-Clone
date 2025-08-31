extends Node3D

func _ready():
	# Phát nhạc nền nếu node BackgroundMusic đã có stream
	if $BackgroundMusic and $BackgroundMusic.stream:
		$BackgroundMusic.play()
