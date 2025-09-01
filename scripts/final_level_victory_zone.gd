extends Area3D

@onready var you_win: CanvasLayer = get_tree().current_scene.get_node("YouWin")

func _on_body_entered(body):
	if body.name == "Ball" and you_win:
		you_win.open_menu()