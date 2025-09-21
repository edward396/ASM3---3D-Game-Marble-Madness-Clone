extends Node3D

@onready var bg_music: AudioStreamPlayer = $BackgroundMusic
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var timer_label: Label = $TimerLabel
@onready var game_timer: Timer = $CountDownTimer
@onready var game_over_menu: CanvasLayer = $GameOverMenu
@onready var beep_sound: AudioStreamPlayer = $BeepSound
@onready var start_sound: AudioStreamPlayer = $StartSound
@onready var time_up_sound: AudioStreamPlayer = $TimeUpSound
@onready var countdown_label: Label = $CountDownLabel

@onready var victory_menu: CanvasLayer = $VictoryMenu
@onready var victory_label: Label = $VictoryMenu/Panel/VictoryLabel
@onready var next_button: Button = $VictoryMenu/Panel/NextButton
@onready var back_button: Button = $VictoryMenu/Panel/BackButton

@export var round_index: int = 3
@export var is_final_round: bool = true
@export var next_level_path: String = ""

var time_left: int = 60
var update_timer: Timer
var is_game_over := false

func _ready():
	victory_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	victory_menu.visible = false

	#Play bg music
	if bg_music and bg_music.stream:
		bg_music.play()
	
	#UI
	game_over_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	game_over_menu.visible = false

	#Always unpause when first enter the level
	get_tree().paused = false
	pause_menu.hide()

	#Initialize timer
	time_left = int(game_timer.wait_time)
	timer_label.text = format_time(time_left)

	#Connect timer signal
	update_timer = Timer.new()
	update_timer.wait_time = 1.0
	update_timer.one_shot = false
	update_timer.autostart = true
	add_child(update_timer)
	update_timer.timeout.connect(_on_update_time)

	#Count down 3 2 1
	_start_countdown()

func _start_countdown() -> void:
	# Pause gameplay, but UI & sound still running
	get_tree().paused = true
	countdown_label.visible = true
	
	for n in [3, 2, 1]:
		countdown_label.text = str(n)
		beep_sound.play()
		await get_tree().create_timer(1.0, true).timeout # true = run when paused
		
	countdown_label.text = "GO!"
	start_sound.play()
	await get_tree().create_timer(0.5, true).timeout

	# start game
	countdown_label.visible = false
	get_tree().paused = false
	update_timer.start() # start ticking each sec
	game_timer.start()

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()

func _toggle_pause():
	if get_tree().paused:
		get_tree().paused = false
		if has_node("PauseMenu"):
			pause_menu.close_menu()
		
		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		get_tree().paused = true
		if has_node("PauseMenu"):
			pause_menu.open_menu()

func _on_update_time():
	if is_game_over: return

	time_left = max(0, time_left - 1)
	timer_label.text = format_time(time_left)
	
	if time_left == 0:
		_on_game_over()
		
func _on_game_over():
	if is_game_over: return
	
	is_game_over = true
	
	if update_timer:
		update_timer.stop()
	var elapsed_sec = int(game_timer.wait_time) - max(time_left, 0)
	SaveManager.mark_game_over_with_partial(max(elapsed_sec, 0))
	
	get_tree().paused = true # pause gameplay
	game_over_menu.visible = true
	
	time_up_sound.play()

func on_round_win():
	if is_game_over: return
	is_game_over = true

	# stop timer
	if update_timer:
		update_timer.stop()

	if Globals.is_free_play:
		get_tree().paused = true
		victory_menu.visible = true
		victory_menu.play_victory()
		# if Play By Level -> Back to Main Menu
		back_button.visible = true
		next_button.visible = false
		back_button.pressed.connect(_on_back_pressed, CONNECT_ONE_SHOT)
		return
	else:
		# if normal play -> WIN ALL
		var elapsed_sec = int(game_timer.wait_time) - max(time_left, 0)
		SaveManager.add_completed_round_time(max(elapsed_sec, 0))
		SaveManager.mark_winner()
		get_tree().paused = false
		get_tree().change_scene_to_file("res://ui/YouWinScreen.tscn")

func _on_back_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://environment/main_menu.tscn")

func format_time(seconds: int) -> String:
	var mins = seconds / 60
	var secs = seconds % 60
	return "%02d:%02d" % [mins, secs]
