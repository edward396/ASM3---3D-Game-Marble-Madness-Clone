extends CanvasLayer

@export var top_n: int = 20
@export var pause_on_open: bool = false   # Để dùng trong gameplay thì bật true; ở Main Menu để false

@onready var panel: Control                = $Panel
@onready var recap_lbl: Label             = $Panel/Header/RecapLabel
@onready var score_list: ItemList         = $Panel/Body/ScoreList
@onready var details_lbl: Label           = $Panel/Body/DetailsLabel 
@onready var winners_only_chk: CheckBox   = $Panel/Footer/WinnersOnly 
@onready var btn_export: Button           = $Panel/Footer/ExportButton
@onready var btn_reset: Button            = $Panel/Footer/ResetButton
@onready var btn_close: Button            = $Panel/Footer/CloseButton 

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED	
	score_list.item_selected.connect(_on_item_selected)

func open_menu() -> void:
	if pause_on_open:
		get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
	_refresh()

func close_menu() -> void:
	print('yes')
	visible = false
	if pause_on_open:
		get_tree().paused = false
		
	$".".visible = false
	$"../VBoxContainer".visible = true
	$"../VBoxContainer2".visible = true

func _refresh() -> void:
	score_list.clear()
	if details_lbl: details_lbl.text = ""

	var list: Array = SaveManager.get_leaderboard(top_n * 5)
	

	if winners_only_chk and winners_only_chk.button_pressed:
		var filtered: Array = []
		for e in list:
			if str(e.get("status","")) == "winner":
				filtered.append(e)
		list = filtered
	
	if top_n > 0 and list.size() > top_n:
		list = list.slice(0, top_n)

	var rank := 1
	
	for e in list:
		var cr: int = int(e.get("completed_rounds", 0))
		var tc: int = int(e.get("total_completed_time_sec", 0))
		var st: String = str(e.get("status",""))
		var ts: String = str(e.get("ts",""))

		var line: String = "%2d) Rounds: %d  |  %s  |  %s" % [
			rank, cr, SaveManager.format_time_str(tc), st
		]
		line += "  |  " + ts
		score_list.add_item(line)
		var idx := score_list.get_item_count() - 1
		score_list.set_item_metadata(idx, e)
		rank += 1
		
	if SaveManager.was_last_run_new_best() and score_list.get_item_count() > 0:
		score_list.set_item_text(0, score_list.get_item_text(0) + "  ★ NEW BEST")

	if recap_lbl:
		if list.is_empty():
			recap_lbl.text = "No records yet."
		else:
			var top_summary: String = ""
			var top_n: int = min(15, list.size())  # Show at most 20 records
			for i in range(top_n):
				var entry: Dictionary = list[i]
				var best_rounds: int = int(entry.get("completed_rounds", 0))
				var best_time: int = int(entry.get("total_completed_time_sec", 0))
				top_summary += "%d) Rounds: %d  |  %s\n" % [i+1, best_rounds, SaveManager.format_time_str(best_time)]
				recap_lbl.text = "SCORE BOARD: \n" + top_summary

func _on_item_selected(idx: int) -> void:
	var e: Dictionary = score_list.get_item_metadata(idx)
	if details_lbl and e:
		var per: Array = e.get("per_round_times", [])
		var partial: int = int(e.get("partial_time_sec", 0))
		var parts: Array[String] = []
		for i in per.size():
			parts.append("R%d: %s" % [i+1, SaveManager.format_time_str(int(per[i]))])
		if partial > 0:
			parts.append("R%d (partial): %s" % [per.size()+1, SaveManager.format_time_str(partial)])
		
		if parts.is_empty():
			details_lbl.text = "No per-round details."
		else:
			details_lbl.text = " | ".join(PackedStringArray(parts))

func _on_export() -> void:
	print('yes')
	SaveManager.export_csv() 
