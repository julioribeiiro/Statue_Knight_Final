extends Node

var estagio = 5
var texto
var started = false

func _ready():
	texto = "Statue Knight didn’t find what he was looking for... No time magic, no powerful weapon, only pain and sorrow and dragon and death."
	$knight.texto = texto
	$knight.estagio = estagio

func _process(delta):
	if started:
		started = false
		$fundo2.stop()
		$fundo.play()