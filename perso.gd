extends KinematicBody2D
var colision = null
var speed = Vector2()
var clicou = false
var velo = 200
var walking = false

func _ready():
	speed.x = 0

func walk():
	if !walking:
		walking = true
		speed.x = velo
		yield(get_tree().create_timer(0.3), "timeout")
		speed.x = 0
		yield(get_tree().create_timer(0.2), "timeout")
		walking = false

func walk_frame():
	if $sprites_kina.frame == 0 and !walking:
		position.x += 30
		walking = true
	elif $sprites_kina.frame == 1 and walking:
		position.x += 30
		walking = false
	

func _process(delta):
	if !clicou:
		walk()
		#walk_frame()
	colision = move_and_collide(speed*delta)

func _on_touch_pressed():
	if !clicou:
		clicou = true
		$"../passos".stop()
		$"../fundo/instrucoes/fundo".hide()
		$"../fundo/instrucoes/Instructions".hide()
		$"../fundo/instrucoes/Instructions2".hide()
		$"../fundo/start/start".hide()
		$sprites_kina.play("statue")
		speed.x = 0
		yield(get_tree().create_timer(1),"timeout")
		get_tree().change_scene("res://selecao_de_estagios.tscn")
		clicou = false
