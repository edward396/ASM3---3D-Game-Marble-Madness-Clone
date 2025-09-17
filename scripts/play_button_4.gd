extends Button


func _on_pressed() -> void:
	var mm = $"../.."                      
	mm.get_node("VBoxContainer").visible = false
	mm.get_node("VBoxContainer2").visible = false
	mm.get_node("ScoreboardMenu").open_menu() 
