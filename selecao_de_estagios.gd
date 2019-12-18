extends Node

var stage


func _ready():
	#get_node("/root/save_stages").loadStage("estagios", "total")
	#stage = get_node("/root/save_stages").stage
	stage = 5
	
	if stage == 1:
		$stage_button2.disabled = true
		$stage_button3.disabled = true
		$stage_button4.disabled = true
		$stage_button5.disabled = true

	elif stage == 2:
		$stage_button3.disabled = true
		$stage_button4.disabled = true
		$stage_button5.disabled = true

	elif stage == 3:
		$stage_button4.disabled = true
		$stage_button5.disabled = true

	elif stage == 4:
		$stage_button5.disabled = true

func _on_botao_0_pressed():
	$click.play()
	get_tree().change_scene("res://estagio_0.tscn")

func _on_botao_1_pressed():
	$click.play()
	yield(get_tree().create_timer(1), "timeout")
	get_tree().change_scene("res://estagio_1.tscn")

func _on_botao_2_pressed():
	$click.play()
	yield(get_tree().create_timer(1), "timeout")
	get_tree().change_scene("res://estagio_2.tscn")

func _on_botao_3_pressed():
	$click.play()
	yield(get_tree().create_timer(1), "timeout")
	get_tree().change_scene("res://estagio_3.tscn")

func _on_botao_4_pressed():
	$click.play()
	yield(get_tree().create_timer(1), "timeout")
	get_tree().change_scene("res://estagio_4.tscn")


func _on_botao_5_pressed():
	$click.play()
	yield(get_tree().create_timer(1), "timeout")
	get_tree().change_scene("res://estagio_5.tscn")


func _on_botao_6_pressed():
	$click.play()
	yield(get_tree().create_timer(1), "timeout")
	get_tree().change_scene("res://infinity_run.tscn")
