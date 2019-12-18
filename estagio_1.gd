extends Node

var estagio = 1
var texto
var started = false

func _ready():
	texto = "As the All-Seer ravaged the land, almost everything was lost, but in the Finn Forest, the Forest Guard’s diligence remains."
	$knight.texto = texto
	$knight.estagio = estagio

func _process(delta):
	if started:
		started = false
		$fundo2.stop()
		$fundo.play()

