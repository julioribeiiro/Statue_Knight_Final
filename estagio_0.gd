extends Node

var estagio = 0
var texto
var started = false


func _ready():
	texto = "The Finn Forest was famous because of its apples and beautiful vegetation... Now, there are nothing beautiful, no apples, and only moanings."
	$knight.estagio = estagio
	$knight.texto = texto

func _process(delta):
	if started:
		started = false
		$fundo2.stop()
		$fundo.play()

