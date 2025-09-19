extends CanvasLayer

@onready var play_again_btn: Button = $Panel/PlayAgainButton
@onready var exit_btn: Button = $Panel/ExitButton
@onready var total_time_lbl: Label = $Panel/TotalTimeLabel

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visible = false
	play_again_btn.pressed.connect(_on_play_again_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)

func open_menu():
	if get_tree() == null:
		return
		
	visible = true
	get_tree().paused = true # pause for the buttons to work
	play_again_btn.grab_focus()

func close_menu():
	visible = false
	get_tree().paused = false # unpause

func _on_play_again_pressed():
	# get_tree().paused = false
	get_tree().change_scene_to_file("res://environment/levels/level_01.tscn")

func _on_exit_pressed():
	get_tree().paused = false
	close_menu()
	get_tree().change_scene_to_file("res://environment/main_menu.tscn")

func _update_time_text():
	var s = SaveManager.get_summary()
	var total := int(s.get("total_completed_time_sec", 0))
	var per: Array = s.get("per_round_times", [])

	if total_time_lbl:
		total_time_lbl.text = "Total Time: %s" % SaveManager.format_time_str(total)
