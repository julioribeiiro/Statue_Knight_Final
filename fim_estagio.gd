extends Node2D

var botao_ativo = false
var knight = null

func _ready():
	pass
	
func _process(delta):
	pass
		
	

func _on_area_area_entered(area):
	knight = area.get_parent()
	knight.finalizou_estagio()
	botao_ativo = true
