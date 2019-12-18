extends Node

var monstro_morreu = 0
var type = 1
var monstros_mortos = 0
var started = false

func _ready():
	$knight.estagio = 10

func att_score():
	if monstros_mortos < 10:
		$bg/score.text = "Score: 000"+str(monstros_mortos*10)
	elif monstros_mortos >= 10 and monstros_mortos < 100:
		$bg/score.text = "Score: 00"+str(monstros_mortos*10)
	elif monstros_mortos >= 100 and monstros_mortos < 1000:
		$bg/score.text = "Score: 0"+str(monstros_mortos*10)
	else:
		$bg/score.text = "Score: "+str(monstros_mortos*10)

func _process(delta):
	if monstro_morreu == 1:
		monstro_morreu = 0
		if type == 0:
			var new_monster = load("res://Monstro_P1_IR.tscn").instance()
			new_monster.position.y = 889.501
			new_monster.position.x = $knight.position.x + 1360
			add_child(new_monster)
			monstros_mortos += 1
			att_score()
			type += 1
		elif type == 1:
			var new_monster_1 = load("res://Monstro_P2_IR.tscn").instance()
			new_monster_1.position.y = 889.501
			new_monster_1.position.x = $knight.position.x + 1360
			add_child(new_monster_1)
			monstros_mortos += 1
			att_score()
			type += 1
		elif type == 2:
			var new_monster_2 = load("res://Monstro_Ca1_IR.tscn").instance()
			new_monster_2.position.y = 889.501
			new_monster_2.position.x = $knight.position.x + 1360
			add_child(new_monster_2)
			type += 1
			monstros_mortos += 1
			att_score()
		elif type == 3:
			var new_monster_3 = load("res://Monstro_Ca2_IR.tscn").instance()
			new_monster_3.position.y = 889.501
			new_monster_3.position.x = $knight.position.x + 1360
			add_child(new_monster_3)
			monstros_mortos += 1
			att_score()
			type = 0
		