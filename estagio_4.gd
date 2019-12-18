extends Node

var estagio = 4
var texto
var started = false

func _ready():
	texto = "It’s still possible to find war plan, research notes and bureaucracy in the papers that litter most rooms, even though no one remembers how everything started..."
	$knight.texto = texto
	$knight.estagio = estagio
	
func _process(delta):
	if started:
		started = false
		$fundo2.stop()
		$fundo.play()