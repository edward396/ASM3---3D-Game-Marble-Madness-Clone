extends Control

@onready var level_menu = $LevelMenu

func _ready():
	$VBoxContainer/TutorialButton.pressed.connect(_on_tutorial_button_pressed)
	$VBoxContainer/PlayButton.pressed.connect(_on_play_button_pressed)
	$VBoxContainer/PlayByLevelButton.pressed.connect(_on_play_by_level_button_pressed)
	$VBoxContainer2/ExitButton.pressed.connect(_on_exit_button_pressed)
	$ScoreboardMenu.open_menu()
	
	
	level_menu.visible = false
	
	$LevelMenu/Level1Button.pressed.connect(func(): _start_level("res://environment/levels/level_01.tscn"))
	$LevelMenu/Level2Button.pressed.connect(func(): _start_level("res://environment/levels/level_02.tscn"))
	$LevelMenu/Level3Button.pressed.connect(func(): _start_level("res://environment/levels/level_03.tscn"))


func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://environment/levels/level_0.tscn")

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://environment/levels/level_01.tscn")

func _on_exit_button_pressed():
	print("Exit button pressed")
	get_tree().quit()

func _on_play_by_level_button_pressed() -> void:
	level_menu.visible = !level_menu.visible

func _start_level(path: String):
	get_tree().change_scene_to_file(path)
