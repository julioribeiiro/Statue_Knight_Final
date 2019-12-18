extends StaticBody2D


#----------VARIAVEIS ALTERAVEIS---------------

const armadura_monstro = 8#--------------------------ARMADURA DO MONSTRO PARA PODER TOMAR HIT
const monstro_hp = 5#--------------------------------QUANTIDADE DE HITS QUE MONSTRO DEVE RECEBER PARA MORRER
var dano    #--------------------------------------DANO QUE MONSTRO CAUSA NO KNIGHT(PORCENTAGEM)
const stamina_recebida_ao_matar = 30#----------------STAMINA QUE KNIGHT RECEBE AO MATAR O MONSTRO(PORCENTAGEM)

#-------DELAY DE TOLERANCIA-----
const delay_volta_do_vulneravel_apos_ataque = 0.4#-----------TEMPO PARA MONSTRO VOLTAR ATACAR DEPOIS DE LEVAR HIT
const timer_entre_ataques = 0.1#-----------------------TEMPO DE ESPERA ENTRE ATAQUES
const delay_monstro_vulneravel = 5#------------------TEMPO QUE O MONSTRO PASSA VULNERAVEL
const delay_tolerancia_defesa = 0.05#-----------------TEMPO QUE O KNIGHT AINDA PODE SE DEFENDER MESMO APOS O SPRITE DE ATAQUE
const delay_tomou_pp = 0.35#--------------------------TEMPO QUE FICA NO SPRITE DE ATAQUE SE TOMAR PP

const delay_knight_defendeu = 0.1 #---------------TEMPO QUE MONSTRO FICA PARADO APOS DEFENDER ATAQUE COM SUCESSO

#-----ATAQUE 1 MONSTRO----------------
const delay_ataque_1_aviso_1 = 0.25
const delay_ataque_1_pausa_1 = 0.15
const delay_ataque_1_aviso_2 = 0.25
const delay_ataque_1_pausa_2 = 0.15
const delay_ataque_1_hit_1 = 0.3
const dano_1_ataque_1 = 6
const delay_ataque_1_pausa_3 = 0.05
const delay_ataque_1_hit_2 = 0.3
const dano_2_ataque_1 = 6
const delay_ataque_1_pausa_4 = 0.05
const delay_ataque_1_hit_3 = 0.3
const dano_3_ataque_1 = 6
const delay_ataque_1_pausa_5 = 0.22




#-----VARIAVEIS DE DANO------

var monstro_tipo = 2
var monstro_apanhou = false
var armadura_atual = armadura_monstro
var monstro_hp_atual = monstro_hp
var atacou_stand_by = true
var ataque = 1
var comeca_atacar = false
var knight = null
var atacou_stand_by_timer = null
var delay_monstro_vulneravel_timer = null
var perfect_parry_desativado = true
var monstro_atacando = false
var perfect_parry = false
var monstro_vulneravel = false
var timer_ate_hitar = null
var estagio = null
var knight_defendeu = false
var tempo_hit_monstro


func _ready():
	$stun.hide()
	$area_ataque/shape_ataque.disabled = true
	estagio = get_parent()
	atacou_stand_by_timer = Timer.new()
	atacou_stand_by_timer.set_one_shot(true)
	atacou_stand_by_timer.set_wait_time(timer_entre_ataques)
	atacou_stand_by_timer.connect("timeout", self, "termina_ataque")
	add_child(atacou_stand_by_timer)

	delay_monstro_vulneravel_timer = Timer.new()
	delay_monstro_vulneravel_timer.set_one_shot(true)
	delay_monstro_vulneravel_timer.set_wait_time(delay_monstro_vulneravel)
	delay_monstro_vulneravel_timer.connect("timeout", self, "volta_a_atacar")
	add_child(delay_monstro_vulneravel_timer)

#----------TIMER DE ULTIMO SPRITE ATAQUE 1----------------------------------
	timer_ate_hitar = Timer.new()
	timer_ate_hitar.set_one_shot(true)
	add_child(timer_ate_hitar)


#------FUNCOES DE ATAQUE-----------------------------
func termina_ataque():
	atacou_stand_by = true
	
func tomou_pp():
	armadura_atual -= 3
	#---------ANIMACAO PERDE ARMADURA
	if armadura_atual <= 0 and monstro_vulneravel == false:
		vulneravel()
		armadura_atual = armadura_monstro


func volta_a_atacar():
	if !monstro_apanhou:
		$stun.hide()
		print("voltou a atacar")
		$sprites_monstro.frame = 0
		monstro_vulneravel = false
		atacou_stand_by = true
		armadura_atual = armadura_monstro
		knight.monstro_vulneravel_set(monstro_vulneravel)
	monstro_apanhou = false

func altera_timer(dano_monstro, delay_ataque, timer_hit):
	tempo_hit_monstro = timer_hit
	dano = dano_monstro
	timer_ate_hitar.set_wait_time(delay_ataque)

#-------------------------ATAQUE 1------------------------------------
func monstro_ataque_1():
	if !monstro_atacando:
		altera_timer(dano_1_ataque_1, delay_ataque_1_pausa_2, delay_ataque_1_hit_1)
		$Label.text = "Ataque 1 Padrao 1"
		monstro_atacando = true
		$sprites_monstro.frame = 2#----------FRAME DE AVISO VAI VIRAR 1 SEGUNDO
		$alertA.play()
		yield(get_tree().create_timer(delay_ataque_1_aviso_1), "timeout")#-------DELAY DE AVISO
		$sprites_monstro.frame = 1
		yield(get_tree().create_timer(delay_ataque_1_pausa_1), "timeout")
		$sprites_monstro.frame = 2#----------FRAME DE AVISO VAI VIRAR 1 SEGUNDO
		$alertA.play()
		yield(get_tree().create_timer(delay_ataque_1_aviso_2), "timeout")
		$sprites_monstro.frame = 1
		timer_ate_hitar.start()#-------------COMECA O DELAY_ATAQUE_1_PAUSA_2
		yield(timer_ate_hitar, "timeout")
		$sprites_monstro.frame = 5
		perfect_parry_desativado = true
		yield(get_tree().create_timer(delay_tolerancia_defesa), "timeout")#------TEMPO DE TOLERANCIA PARA DEFESA
		$area_ataque/shape_ataque.disabled = false
		if !perfect_parry and armadura_atual > 0:
			yield(get_tree().create_timer(tempo_hit_monstro), "timeout")
		else:
			$area_ataque/shape_ataque.disabled = true
			yield(get_tree().create_timer(delay_tomou_pp+0.1), "timeout")
			tomou_pp()#------PODE SER ALTERADO PARA PP_DRAGAO
			knight_defendeu = true
	
		$area_ataque/shape_ataque.disabled = true
	#-----------MINI DELAY DEPOIS DE KNIGHT DEFENDER O ATAQUE COM SUCESSO
		if knight_defendeu == true and !perfect_parry:
			yield(get_tree().create_timer(delay_knight_defendeu), "timeout")
			knight_defendeu = false
	#--------------------------------------------------------------------------------------
		perfect_parry = false
		
		if !monstro_vulneravel:
		#------COMECA OUTRO PADRAO-------------------------------------------------
			$Label.text = "Ataque 1 Padrao 2"
			altera_timer(dano_2_ataque_1, delay_ataque_1_pausa_3, delay_ataque_1_hit_2)
			$sprites_monstro.frame = 1#---------------FRAME DE PAUSA
			timer_ate_hitar.start()#-----------COMECA O DELAY_ATAQUE_1_PAUSA_3
			yield(timer_ate_hitar, "timeout")
			$sprites_monstro.frame = 5
			perfect_parry_desativado = true
		#------------ALTERAR ESTA PARTE QUANDO FOR ALTERAR PERFECT PARRY
			yield(get_tree().create_timer(delay_tolerancia_defesa), "timeout")#------TEMPO DE TOLERANCIA PARA DEFESA
			$area_ataque/shape_ataque.disabled = false
			if !perfect_parry and armadura_atual > 0:
				yield(get_tree().create_timer(tempo_hit_monstro), "timeout")
			else:
				$area_ataque/shape_ataque.disabled = true
				yield(get_tree().create_timer(delay_tomou_pp+0.1), "timeout")
				tomou_pp()#------PODE SER ALTERADO PARA PP_DRAGAO
				knight_defendeu = true
			
			$area_ataque/shape_ataque.disabled = true
		#-----------MINI DELAY DEPOIS DE KNIGHT DEFENDER O ATAQUE COM SUCESSO
			if knight_defendeu == true and !perfect_parry:
				yield(get_tree().create_timer(delay_knight_defendeu), "timeout")
				knight_defendeu = false
		#--------------------------------------------------------------------------------------
			perfect_parry = false
		
			if !monstro_vulneravel:
				$sprites_monstro.frame = 0
	
			if !monstro_vulneravel:
			#------COMECA OUTRO PADRAO-------------------------------------------------
				$Label.text = "Ataque 1 Padrao 3"
				altera_timer(dano_3_ataque_1, delay_ataque_1_pausa_4, delay_ataque_1_hit_3)
				$sprites_monstro.frame = 1#---------------FRAME DE PAUSA
				timer_ate_hitar.start()#-----------COMECA O DELAY_ATAQUE_1_PAUSA_3
				yield(timer_ate_hitar, "timeout")
				$sprites_monstro.frame = 5
				perfect_parry_desativado = true
			#------------ALTERAR ESTA PARTE QUANDO FOR ALTERAR PERFECT PARRY
				yield(get_tree().create_timer(delay_tolerancia_defesa), "timeout")#------TEMPO DE TOLERANCIA PARA DEFESA
				$area_ataque/shape_ataque.disabled = false
				if !perfect_parry and armadura_atual > 0:
					yield(get_tree().create_timer(tempo_hit_monstro), "timeout")
				else:
					$area_ataque/shape_ataque.disabled = true
					yield(get_tree().create_timer(delay_tomou_pp+0.1), "timeout")
					tomou_pp()#------PODE SER ALTERADO PARA PP_DRAGAO
					knight_defendeu = true
				
				$area_ataque/shape_ataque.disabled = true
			#-----------MINI DELAY DEPOIS DE KNIGHT DEFENDER O ATAQUE COM SUCESSO
				if knight_defendeu == true and !perfect_parry:
					yield(get_tree().create_timer(delay_knight_defendeu), "timeout")
					knight_defendeu = false
			#--------------------------------------------------------------------------------------
				perfect_parry = false
			
				$Label.text = "Ataque 1 Pausa final"
				if !monstro_vulneravel:
					$sprites_monstro.frame = 0
				yield(get_tree().create_timer(delay_ataque_1_pausa_5), "timeout")
	
			#------------------------------------TERMINA ATAQUE-------------------------------------------
				if !atacou_stand_by_timer.time_left:
					atacou_stand_by_timer.start()
				monstro_atacando = false
				if monstro_vulneravel == false:
					$"sprites_monstro".frame = 0



#----FUNCAO CAUSAR DANO COM ATAQUE----

func monstro_dano():
	knight.perde_stamina_monstro(dano)

#-----------------FUNCAO SELECIONAR ATAQUE------

func seleciona_ataque():
	perfect_parry_desativado = false
	if !monstro_atacando and !monstro_vulneravel:
		ataque = 1
		if ataque == 1:
			monstro_ataque_1()


#--------------FUNCAO REDUCAO DE ARMADURA--------------------------------
func dano_armadura(tipo):
	if tipo == 1:
		armadura_atual -= 200
	elif tipo == 2:
		armadura_atual -= 1
	elif tipo == 3:
		armadura_atual -= 1
	print(armadura_atual)
	if armadura_atual <= 0 and monstro_vulneravel == false:
		vulneravel()
		armadura_atual = armadura_monstro

func vulneravel():
	$stun.show()
	monstro_apanhou = false
	monstro_vulneravel = true
	knight.monstro_vulneravel_set(monstro_vulneravel)
	$sprites_monstro.frame = 4
	delay_monstro_vulneravel_timer.start()



func monstro_morreu():
	knight.monstro = null
	knight.ganha_stamina_monstro(stamina_recebida_ao_matar)
	queue_free()

func monstro_apanhou():
	monstro_apanhou = true
	monstro_hp_atual -=1
	print("monstro hp = ",monstro_hp_atual)
	yield(get_tree().create_timer(delay_volta_do_vulneravel_apos_ataque), "timeout")
	monstro_vulneravel = false
	$stun.hide()
	monstro_atacando = false
	knight.monstro_vulneravel_set(monstro_vulneravel)
	if monstro_hp_atual<=0:
		monstro_vulneravel = true
		$die.play()
		$animacoes.play("morte")
	if !monstro_vulneravel:
		seleciona_ataque()

	else:
		armadura_atual = armadura_monstro

func _process(delta):
#------PENSAR EM OUTRA SOLUCAO-------------
	if comeca_atacar == true:
		if atacou_stand_by == true and monstro_vulneravel==false:
			atacou_stand_by = false
			seleciona_ataque()
#-------------------------------------------