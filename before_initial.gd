extends Node
var clicou = 0


func goto_initial():
	get_tree().change_scene("res://Tela_inicial.tscn")

func clicked():
	clicou = 1

func _on_touch_pressed():
	if clicou == 0:
		$anim.stop()
		$Label.visible_characters = -1
		clicou = 1
	
	elif clicou == 1:
		goto_initial()
	
