extends Node
var clicou = false


func _on_TouchScreenButton_pressed():
	if !clicou:
		$perso/sprites_kina.play("statue")
		yield(get_tree().create_timer(1), "timeout")
		get_tree().change_scene("res://selecao_de_estagios.tscn")
