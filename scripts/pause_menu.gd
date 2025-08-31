extends CanvasLayer

@onready var resume_btn: Button = $Control/Panel/ResumeButton
@onready var exit_btn: Button = $Control/Panel/ExitButton

func _enter_tree():
	visible = false

func _ready():
	#UI runs when game paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visible = false

	#Connect the buttons
	resume_btn.pressed.connect(_on_resume_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)

func open_menu():
	visible = true
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	resume_btn.grab_focus()

func close_menu():
	visible = false

func _on_resume_pressed():
	get_tree().paused = false
	close_menu()
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_exit_pressed():
	get_tree().paused = false
	close_menu()
	get_tree().change_scene_to_file("res://environment/main_menu.tscn")
