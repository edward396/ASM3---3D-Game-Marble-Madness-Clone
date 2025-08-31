extends Node3D

@onready var bg_music: AudioStreamPlayer = $BackgroundMusic
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var timer_label: Label = $TimerLabel
@onready var game_timer: Timer = $CountDownTimer
@onready var game_over_menu: CanvasLayer = $GameOverMenu

var time_left: int = 60
var update_timer: Timer
var is_game_over := false


func _ready():
	#Play bg music
	if bg_music and bg_music.stream:
		bg_music.play()
	
	game_over_menu.visible = false

	#Always unpause when first enter the level
	get_tree().paused = false
	pause_menu.hide()

	#Reset timer
	time_left = int(game_timer.wait_time)
	timer_label.text = format_time(time_left)

	#Connect timer signal
	update_timer = Timer.new()
	update_timer.wait_time = 1.0
	update_timer.one_shot = false
	update_timer.autostart = true
	add_child(update_timer)
	update_timer.timeout.connect(_on_update_time)

	#count the whole time
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

#Update Game Over scene later
func _on_game_over():
	if is_game_over: return
	
	is_game_over = true
	
	if update_timer:
		update_timer.stop()
	
	get_tree().paused = true # tạm dừng gameplay
	game_over_menu.visible = true
	
func format_time(seconds: int) -> String:
	var mins = seconds / 60
	var secs = seconds % 60
	return "%02d:%02d" % [mins, secs]
