extends Control

func _ready():
	$VBoxContainer/PlayButton.pressed.connect(_on_play_button_pressed)
	$VBoxContainer2/ExitButton.pressed.connect(_on_exit_button_pressed)

func _on_play_button_pressed():
	# Thay đổi scene sang màn chơi đầu tiên
	get_tree().change_scene_to_file("res://environment/levels/level_01.tscn")

func _on_exit_button_pressed():
	print("Exit button pressed") # Thêm dòng này để kiểm tra

	get_tree().quit()
