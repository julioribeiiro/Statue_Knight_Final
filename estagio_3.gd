extends Node

var estagio = 3
var texto
var started = false

func _ready():
	texto = "Trying to enter the royal castle was always a struggle. Surprisingly, nowadays it’s a little easier."
	$knight.texto = texto
	$knight.estagio = estagio

func _process(delta):
	if started:
		started = false
		$fundo2.stop()
		$fundo.play()