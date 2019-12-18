extends Node

var estagio = 2
var texto
var started = false

func _ready():
	texto = "The cemiteries grew around the cities like pus spreading from an infected wound. However, the graves are a better end than walking in this cursed land."
	$knight.texto = texto
	$knight.estagio = estagio
	
func _process(delta):
	if started:
		started = false
		$fundo2.stop()
		$fundo.play()