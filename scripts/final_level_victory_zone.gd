extends Area3D

@onready var you_win: CanvasLayer = get_tree().current_scene.get_node("YouWin")
@onready var you_win_sound: AudioStreamPlayer = you_win.get_node("YouWinSound")
@onready var level = $".."
func _on_body_entered(body):
	if body.name == "Ball" and you_win:
		if Globals.is_free_play:
			level.on_round_win()
		else:
			if you_win:
				you_win.open_menu()
				if you_win_sound:
					you_win_sound.play()
