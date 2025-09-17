extends Node

const SAVE_PATH   := "res://run_time.json"
const SCORES_PATH := "res://scoreboard.json"

var per_round_times: Array[int] = []  
var partial_time_sec: int = 0        
var total_completed_time_sec: int = 0 
var status: String = "in_progress"    

var scores: Array = []               
var last_run_id: String = ""
var last_run_new_best: bool = false

func _ready() -> void:
	_load_scores()
	load_last()

func reset_run() -> void:
	per_round_times.clear()
	partial_time_sec = 0
	total_completed_time_sec = 0
	status = "in_progress"
	last_run_id = ""
	last_run_new_best = false
	_save_partial()

func add_completed_round_time(round_seconds: int) -> void:
	round_seconds = max(round_seconds, 0)
	per_round_times.append(round_seconds)
	total_completed_time_sec += round_seconds
	print(total_completed_time_sec)
	_save_partial()

func mark_game_over_with_partial(current_round_elapsed_sec: int) -> void:
	status = "game_over"
	partial_time_sec = max(current_round_elapsed_sec, 0)
	_append_score_and_save()

func mark_winner() -> void:
	status = "winner"	
	partial_time_sec = 0
	_append_score_and_save()

func get_summary() -> Dictionary:
	return {
		"per_round_times": per_round_times.duplicate(),
		"partial_time_sec": partial_time_sec,
		"completed_rounds": per_round_times.size(),
		"total_completed_time_sec": total_completed_time_sec,
		"status": status
	}

func get_leaderboard(top_n: int = 20) -> Array:
	var list: Array = scores.duplicate()
	list.sort_custom(Callable(self, "_cmp_score"))  
	if top_n > 0 and list.size() > top_n:
		list = list.slice(0, top_n)
		
	return list

func get_last_run() -> Dictionary:
	if last_run_id == "":
		return {}
	for e in scores:
		if e.get("id","") == last_run_id:
			return e
	return {}

func was_last_run_new_best() -> bool:
	return last_run_new_best

func clear_scoreboard() -> void:
	scores.clear()
	_save_scores()

func export_csv(path: String = "user://scoreboard.csv") -> void:
	var rows: Array[String] = ["id,ts,status,completed_rounds,total_completed_time_sec,per_round_times,partial_time_sec"]
	for e in scores:
		var cols: PackedStringArray = PackedStringArray([
			str(e.get("id","")),
			str(e.get("ts","")),
			str(e.get("status","")),
			str(e.get("completed_rounds",0)),
			str(e.get("total_completed_time_sec",0)),
			"\"" + JSON.stringify(e.get("per_round_times",[])) + "\"",
			str(e.get("partial_time_sec",0))
		])
		var line: String = ",".join(cols)  
		rows.append(line)
	var out: String = "\n".join(PackedStringArray(rows))
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.store_string(out)
		f.close()


func format_time_str(sec: int) -> String:
	var m := sec / 60
	var s := sec % 60
	return "%02d:%02d" % [m, s]

func _cmp_score(a: Dictionary, b: Dictionary) -> bool:
	var ra: int = int(a.get("completed_rounds", 0))
	var rb: int = int(b.get("completed_rounds", 0))
	if ra != rb:
		return ra > rb
	var ta: int = int(a.get("total_completed_time_sec", 0))
	var tb: int = int(b.get("total_completed_time_sec", 0))
	if ta != tb:
		return ta < tb
	return str(a.get("ts","")) < str(b.get("ts",""))

func _append_score_and_save() -> void:
	var entry := {
		"id": "%d-%d" % [Time.get_unix_time_from_system(), randi()],
		"ts": Time.get_datetime_string_from_system(),
		"status": status,
		"completed_rounds": per_round_times.size(),
		"total_completed_time_sec": total_completed_time_sec,
		"per_round_times": per_round_times.duplicate(),
		"partial_time_sec": partial_time_sec
	}

	var has_best := false
	var best: Dictionary = {}
	for e in scores:
		if !has_best:
			best = e
			has_best = true
		elif _cmp_score(e, best):
			best = e

	last_run_new_best = false
	if !has_best or _cmp_score(entry, best):
		last_run_new_best = true

	scores.append(entry)
	last_run_id = entry.id

	_save_final()
	_save_scores()

func _save_partial() -> void:
	_save_to_disk({
		"per_round_times": per_round_times,
		"partial_time_sec": partial_time_sec,
		"total_completed_time_sec": total_completed_time_sec,
		"status": status,
		"type": "partial",
		"ts": Time.get_datetime_string_from_system()
	})

func _save_final() -> void:
	_save_to_disk({
		"per_round_times": per_round_times,
		"partial_time_sec": partial_time_sec,
		"total_completed_time_sec": total_completed_time_sec,
		"status": status,
		"type": "final",
		"ts": Time.get_datetime_string_from_system()
	})

func _save_to_disk(data: Dictionary) -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))
		f.close()

func _to_int_array(v) -> Array[int]:
	var out: Array[int] = []
	if v is Array:
		for x in v:
			out.append(int(x))
	return out
	
func load_last() -> Dictionary:
	if FileAccess.file_exists(SAVE_PATH):
		var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if f:
			var txt := f.get_as_text()
			f.close()
			var j := JSON.new()
			if j.parse(txt) == OK and typeof(j.data) == TYPE_DICTIONARY:
				var d: Dictionary = j.data
				per_round_times            = _to_int_array(d.get("per_round_times", []))
				partial_time_sec           = int(d.get("partial_time_sec", 0))
				total_completed_time_sec   = int(d.get("total_completed_time_sec", 0))
				status                     = str(d.get("status", "in_progress"))
				return d
	return {}

func _load_scores() -> void:
	if FileAccess.file_exists(SCORES_PATH):
		var f := FileAccess.open(SCORES_PATH, FileAccess.READ)
		if f:
			var txt := f.get_as_text()
			f.close()
			var j := JSON.new()
			if j.parse(txt) == OK and typeof(j.data) == TYPE_ARRAY:
				scores = j.data

func _save_scores() -> void:
	var f := FileAccess.open(SCORES_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(scores))
		f.close()
