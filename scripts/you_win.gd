extends CanvasLayer

@onready var play_again_btn: Button = $Panel/PlayAgainButton
@onready var exit_btn: Button = $Panel/ExitButton

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visible = false
	
	#Connect the buttons
	play_again_btn.pressed.connect(_on_play_again_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)

func open_menu():
	visible = true
	get_tree().paused = true # pause for the buttons to work
	play_again_btn.grab_focus()

func close_menu():
	visible = false
	get_tree().paused = false # unpause

func _on_play_again_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://environment/levels/level_01.tscn")

func _on_exit_pressed():
	get_tree().paused = false
	close_menu()
	get_tree().change_scene_to_file("res://environment/main_menu.tscn")
