extends Control

func _ready():
	$VBoxContainer/PlayButton.pressed.connect(_on_play_button_pressed)
	$VBoxContainer2/ExitButton.pressed.connect(_on_exit_button_pressed)
	$ScoreboardMenu.open_menu() 
	
func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://environment/levels/level_01.tscn")

func _on_exit_button_pressed():
	print("Exit button pressed")
	get_tree().quit()

func _on_play_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://environment/levels/level_02.tscn")

func _on_play_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://environment/levels/level_03.tscn")
