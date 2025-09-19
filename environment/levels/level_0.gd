extends Node3D

@onready var bg_music: AudioStreamPlayer = $BackgroundMusic
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var beep_sound: AudioStreamPlayer = $BeepSound
@onready var start_sound: AudioStreamPlayer = $StartSound
@onready var countdown_label: Label = $CountDownLabel

@onready var victory_menu: CanvasLayer = $VictoryMenu
@onready var victory_label: Label = $VictoryMenu/Panel/VictoryLabel
@onready var next_button: Button = $VictoryMenu/Panel/NextButton

@onready var tutorial_panel: Panel = $UI/TutorialPanel

func _ready():
	tutorial_panel.visible = true

	victory_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	victory_menu.visible = false

	if bg_music and bg_music.stream:
		bg_music.play()

	get_tree().paused = false
	pause_menu.hide()

	_start_countdown()

func _start_countdown() -> void:
	get_tree().paused = true
	countdown_label.visible = true
	
	for n in [3, 2, 1]:
		countdown_label.text = str(n)
		beep_sound.play()
		await get_tree().create_timer(1.0, true).timeout
		
	countdown_label.text = "GO!"
	start_sound.play()
	await get_tree().create_timer(0.5, true).timeout

	countdown_label.visible = false
	get_tree().paused = false

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()

func _toggle_pause():
	if get_tree().paused:
		get_tree().paused = false
		if has_node("PauseMenu"):
			pause_menu.close_menu()
	else:
		get_tree().paused = true
		if has_node("PauseMenu"):
			pause_menu.open_menu()

# Victory
func on_round_win():
	get_tree().paused = true

	victory_menu.visible = true

	next_button.pressed.connect(
		func():
			get_tree().paused = false
			get_tree().change_scene_to_file("res://environment/main_menu.tscn"),
		CONNECT_ONE_SHOT
	)
