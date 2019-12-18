extends KinematicBody2D

#------VARIAVEIS PARA ALTERACAO----------------------

const delay_ataque_knight = 0.4#----------------TEMPO QUE KNIGHT FICA NO SPRITE DE ATAQUE
const stamina_total = 100.0#--------------------STAMINA DO KNIGHT 100%
const tempo_para_perder_stamina = 1#------------TEMPO NECESSARIO TRANSFORMADO EM ESTATUA PARA PERDER STAMINA
const perda_de_stamina = 1#---------------------PERDA DE STAMINA A CADA tempo_para_perder_stamina

var velocidade = 400#---------------------------VELOCIDADE DE MOVIMENTO
var delay_hurt = 0.3#-------------------------TEMPO QUE O KNIGHT FICA NO SPRITE DE DEFESA

const delay_perfect_parry = 0.05#----------------PARA ACERTAR O PP KNIGHT PRECISA CLICAR 
#-----------------------------------------------delay_perfect_parry(segundos) ANTES DO DELAY DO ULTIMO SPRITE DO MONSTRO TERMINAR
var delay_transformado_em_pedra = 0.3#--------TEMPO QUE O KNIGHT CONTINUA TRANSFORMADO EM PEDRA DEPOIS DE PASSAR O DELAY PP
const tempo_minimo_pedra = 0.1

const tempo_para_virar_pedra = 0.05#---------------TEMPO QUE O KNIGHT PRECISA PARA RECARREGAR A HABILIDADE DE VIRAR PEDRA

const tempo_depois_que_morre = 2#---------------TEMPO QUE TOUCH FICA DESABILITADO DEPOIS QUE KNIGHT MORRE

#--------------------------------------------

var andando = false
var encontrou_monstro = false
var walking = false
var stamina = stamina_total
var perfect_parry = false
var started = false
var speed = Vector2()
var colision = null
var monstro = null
var touch = false
var stand_by_stamina = false
var monstro_atacou = false
var monstro_vulneravel = false
var tipo_perde_stamina = null
var in_stone = false
var cooldown = true
var timer = null
var knight_morto=false
var knight_atacando = false
var acertou_pp = false
var timer_diferenca = 0
var fim_estagio = false
var tempo_pedra
var monstro_tipo = 0
var timer_transformado_em_pedra = null
var continuando_pedra = false
var knight_defendeu = false
var estagio
var deu_zoom = false
var texto = ""

var checa_monstro_atacou = false

func _ready():
	$texto.show()
	$ending.hide()
	started = false
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(tempo_para_virar_pedra)
	timer.connect("timeout", self, "vira_pedra_true")
	add_child(timer)
	


	timer_transformado_em_pedra = Timer.new()
	timer_transformado_em_pedra.set_one_shot(true)
	timer_transformado_em_pedra.set_wait_time(delay_transformado_em_pedra)
	add_child(timer_transformado_em_pedra)


func monstro_vulneravel_set(valor_novo):
	var monstro_vulneravel_temp
	monstro_vulneravel_temp = valor_novo
	if monstro_vulneravel_temp and !acertou_pp and !deu_zoom:
		if !$movimentos_camera.is_playing():
			$movimentos_camera.play("zoom_in")
	elif !monstro_vulneravel_temp:
		if !$movimentos_camera.is_playing():
			$movimentos_camera.play("zoom_out")
	#yield(get_tree().create_timer(0.3), "timeout")
	monstro_vulneravel = monstro_vulneravel_temp
	deu_zoom = true


func check_walk():
	if speed.x != 0 and !walking and monstro == null:
		walking = true
		encontrou_monstro = false
		$sprites_knight.play("walk")
	elif monstro != null and !encontrou_monstro:
		encontrou_monstro = true
		$sprites_knight.play("idle")
		walking = false



func vira_pedra_true():
	if !knight_morto:
		$touch.show()
		cooldown = true



func termina_pedra():
	
	if timer.time_left == 0:
		$touch.hide()
		timer.start()
	in_stone = false
	walking = false
	$sprites_knight.play("idle")
	touch = false
	checa_monstro_atacou = false


func monstro_atacou():
	if monstro_atacou == true and checa_monstro_atacou == false:
		if !acertou_pp:
			$parry.text = "Parry!"
			$anim_parry.play("parry")
			$acertou_parry.play()
		knight_defendeu = true
		monstro.dano_armadura(3)
		$defended.play()
		monstro_atacou = false
		checa_monstro_atacou = true
		monstro.knight_defendeu = true
		$movimentos_camera.play("shake_defesa")
		if !acertou_pp and !monstro_vulneravel:
			continuando_pedra = true
			$sprites_knight.play("stone")
			$touch.hide()
			timer.start()
			yield(get_tree().create_timer(monstro.delay_knight_defendeu + monstro.tempo_hit_monstro + monstro.delay_tolerancia_defesa - timer_transformado_em_pedra.time_left), "timeout")
			$touch.show()
			termina_pedra()
			continuando_pedra = false
		elif monstro_vulneravel:
			termina_pedra()




#-----FUNCAO PARA TOUCH ON/OFF ---------------
func checar_touch():
	#TODAS AS FUNCOES QUANDO TOUCH ESTA ATIVADO
	
	if monstro_vulneravel==true and touch==true and !knight_atacando and !in_stone:
		knight_atacando = true
		monstro_vulneravel = false
		cooldown = false
		$movimentos_camera.stop()
		$movimentos_camera.play("zoom_shake")
		$sprites_knight.play("attack")
		$dando_hit.play()
		monstro.monstro_apanhou()
		yield(get_tree().create_timer(delay_ataque_knight), "timeout")
		$sprites_knight.play("idle")
		if timer.time_left == 0:
			$touch.hide()
			timer.start()
		knight_atacando = false

	elif touch == true and cooldown==true and monstro_vulneravel==false and !knight_atacando and !in_stone:
		if monstro == null and position.x > 1000:#----EH ATIVADO SE PLAYER ATIVA STONE ANTES DE CHEGAR NO MONSTRO
			speed.x = 0
			$sprites_knight.play("stone")
			in_stone = true
			cooldown = false
			yield(get_tree().create_timer(delay_transformado_em_pedra), "timeout")
			termina_pedra()
			perde_stamina_pedra()


		#----ONDE PLAYER PODE SE DEFENDER A ATAQUES DE MONSTROS
		elif monstro != null and !acertou_pp:#----------EH ATIVADO DURANTE BATALHA CONTRA MONSTRO
			if monstro.timer_ate_hitar.time_left > 0 and monstro.timer_ate_hitar.time_left - delay_perfect_parry <= 0:
				$parry.text = "Perfect Parry!"
				$anim_parry.play("parry")
				$acertou_pp.play()
				acertou_pp = true
				$sprites_knight.play("stone")
				touch = false
				timer_diferenca = delay_perfect_parry - monstro.timer_ate_hitar.time_left
				cooldown = false
				monstro.perfect_parry = true
				$movimentos_camera.play("zoom_in")
				deu_zoom = true
				if timer.time_left == 0:
					timer.start()



			$sprites_knight.play("stone")
			in_stone = true
			cooldown = false
			if !acertou_pp and !monstro_atacou:
				timer_transformado_em_pedra.start()
				yield(timer_transformado_em_pedra, "timeout")
			else:
				yield(get_tree().create_timer(monstro.delay_tomou_pp + timer_diferenca), "timeout")
				if monstro_tipo == 1 or monstro_tipo == 2 or monstro_tipo == 3:
					if !$movimentos_camera.is_playing():
						$movimentos_camera.play("zoom_out")
				termina_pedra()
			if !knight_defendeu:
				termina_pedra()
				if !acertou_pp:
					perde_stamina_pedra()
			knight_defendeu = false
			acertou_pp = false


#---------- TODAS AS FUNCOES QUANDO TOUCH ESTA DESATIVADO ------------------
	else:
		if monstro_atacou == true and in_stone == false:
			cooldown = false
			delay_hurt = monstro.tempo_hit_monstro
			monstro_atacou = false
			monstro.monstro_dano()
			$tomou_hit.play()
			$sprites_knight.play("hurt")
			$movimentos_camera.play("shake_screen")
			yield(get_tree().create_timer(delay_hurt), "timeout")
			if stamina > 0:
				$sprites_knight.play("idle")
			tipo_perde_stamina = "monstro"
			if timer.time_left == 0:
				timer.start()

#----FUNCAO QUE PERDE STAMINA GRADATIVAMENTE----
func perde_stamina_pedra():#--PODE SER MELHORADO
	stamina -= perda_de_stamina
	tipo_perde_stamina = "estatua"


func knight_morto():
	if !knight_morto:
		$die.play()
		$touch.hide()
		knight_morto=true
		$sprites_knight.play("dead")
		$texto.show()
		yield(get_tree().create_timer(tempo_depois_que_morre), "timeout")
		$texto.hide()
		$ending/congratz.text = "Try again!"
		$ending.show()


func finalizou_estagio():
	started = false
	fim_estagio = true
	$touch.hide()
	$after_win/Texto_fim.text = texto
	$after_win.show()
	$interface.hide()


#-----------FUNCAO QUE PERDE/GANHA STAMINA DE MONSTRO-------------------

func perde_stamina_monstro(dano):
	stamina -= dano

func ganha_stamina_monstro(ganho):
	stamina += ganho


func ajuste_stamina():
	if stamina > 100:
		stamina = 100


	$interface/stamina.value = stamina*100
	if $interface/stamina.value < $interface/stamina_fundo.value and tipo_perde_stamina == "monstro":
		$interface/stamina_fundo.value -= 10
		#MUDA DE COR PARA PERDEU PARA MONSTRO


	elif $interface/stamina.value < $interface/stamina_fundo.value and tipo_perde_stamina == "estatua":
		$interface/stamina_fundo.value -= 10
		#MUDA PARA COR PARA PERDEU PARA ESTATUA


	if $interface/stamina.value > $interface/stamina_fundo.value:
		$interface/stamina_fundo.value = $interface/stamina.value

	if stamina <= 0:
		knight_morto()
	elif stamina > 50:
		$movimento_stamina.stop()
	elif stamina <= 50 and stamina > 25:
		$movimento_stamina.play("medio")
	elif stamina <= 25:
		$movimento_stamina.play("low")
		

func walk():
	if !andando:
		andando = true
		speed.x = velocidade
		yield(get_tree().create_timer(0.3), "timeout")
		speed.x = 0
		yield(get_tree().create_timer(0.3), "timeout")
		andando = false

func _physics_process(delta):
#----------FUNCOES PRE-GAME-----------------------

	if started == true and !fim_estagio:
		check_walk()
		if in_stone and !acertou_pp:
			monstro_atacou()
		
#-----------PERSONAGEM SE MOVE ATE COLIDIR------------
		ajuste_stamina()
		colision = move_and_collide(speed*delta)

#-------------APOS COLIDIR INICIA ATAQUE DO MONSTRO-------
		if colision != null:
			monstro = colision.get_collider()
			monstro.comeca_atacar = true
			monstro.knight = $"."
			monstro_tipo = monstro.monstro_tipo
			$passos.stop()
		else:
			walk()
			if !$passos.is_playing():
				$passos.play()

#-------------FUNCOES PERSONAGEM--------------------------
		if knight_morto==false:
			checar_touch()
		else:
			speed.x = 0
			if touch==true:
				get_tree().change_scene("res://selecao_de_estagios.tscn")
	#----INICIANDO O JOGO--------
	elif !started and !fim_estagio:
		if touch==true:
			if estagio == 5:
				$dragon.play()
			cooldown = false
			timer.start()
			started = true
			$texto.hide()
			$texto.text = "You are Stoned!"
			get_parent().started = true
			
	elif !started and fim_estagio:
		walk()
		colision = move_and_collide(speed*delta)


#---------------------------------------------------------


#------QUANDO HIT DO MONSTRO CHEGA------------
func _on_area_toma_dano_area_entered(area):
	if started:
		monstro_atacou = true
func _on_area_toma_dano_area_exited(area):
	if !in_stone:
		monstro_atacou = false

#------FUNCOES TOUCH------------------------
func _on_touch_pressed():
	touch = true
func _on_touch_released():
	touch = false


func _on_touch_fim_pressed():
	$ending/color.play("stages")
	$button_end.play()
	yield(get_tree().create_timer(0.3), "timeout")
	if estagio == 1:
		get_node("/root/save_stages").stage = estagio+1
		get_node("/root/save_stages").saveStage("estagios", "total")
	get_tree().change_scene("res://selecao_de_estagios.tscn")


func _on_touch_restart_pressed():
	$ending/color.play("restart")
	$button_end.play()
	if estagio == 0:
		yield(get_tree().create_timer(0.3), "timeout")
		get_tree().change_scene("res://estagio_0.tscn")
	elif estagio == 1:
		yield(get_tree().create_timer(0.3), "timeout")
		get_tree().change_scene("res://estagio_1.tscn")
	elif estagio == 2:
		yield(get_tree().create_timer(0.3), "timeout")
		get_tree().change_scene("res://estagio_2.tscn")
	elif estagio == 3:
		yield(get_tree().create_timer(0.3), "timeout")
		get_tree().change_scene("res://estagio_3.tscn")
	elif estagio == 4:
		yield(get_tree().create_timer(0.3), "timeout")
		get_tree().change_scene("res://estagio_4.tscn")
	elif estagio == 5:
		yield(get_tree().create_timer(0.3), "timeout")
		get_tree().change_scene("res://estagio_5.tscn")
