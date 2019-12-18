extends StaticBody2D


#----------VARIAVEIS ALTERAVEIS---------------

const armadura_monstro = 5#--------------------------ARMADURA DO MONSTRO PARA PODER TOMAR HIT
const monstro_hp = 3#--------------------------------QUANTIDADE DE HITS QUE MONSTRO DEVE RECEBER PARA MORRER
const dano = 5#--------------------------------------DANO QUE MONSTRO CAUSA NO KNIGHT(PORCENTAGEM)
const stamina_recebida_ao_matar = 30#----------------STAMINA QUE KNIGHT RECEBE AO MATAR O MONSTRO(PORCENTAGEM)

#-------DELAY DE TOLERANCIA-----
const delay_volta_do_vulneravel_apos_ataque = 0.4#-----------TEMPO PARA MONSTRO VOLTAR ATACAR DEPOIS DE LEVAR HIT
const timer_entre_ataques = 0.35#-----------------------TEMPO DE ESPERA ENTRE ATAQUES
const delay_monstro_vulneravel = 5#------------------TEMPO QUE O MONSTRO PASSA VULNERAVEL
const delay_tolerancia_defesa = 0.05#-----------------TEMPO QUE O KNIGHT AINDA PODE SE DEFENDER MESMO APOS O SPRITE DE ATAQUE
const delay_tomou_pp = 0.35#--------------------------TEMPO QUE FICA NO SPRITE DE ATAQUE SE TOMAR PP



#-----ATAQUE 1 MONSTRO----------------
const delay_ataque_1_aviso_1 = 0.4#-----TEMPO QUE O MONSTRO PASSA NO SPRITE AVISO 1
const delay_ataque_1_pausa_1 = 0.4#--------TEMPO QUE O MONSTRO PASSA NO SPRITE PAUSA 1
const delay_ataque_1_aviso_2 = 0.4#-----TEMPO QUE O MONSTRO PASSA NO SPRITE AVISO 2
const delay_ultimo_sprite = 0.4#------TEMPO NO ULTIMO SPRITE(SPRITE DE PAUSA)
const delay_ataque_hit_1 = 0.3#----------------------TEMPO QUE O HITBOX DO ATAQUE FICA ATIVO
const delay_ataque_1_pausa_3 = 0.4

const delay_knight_defendeu = 0.05

var monstro_tipo = 0
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
var delay_hit_monstro
var timer_knight_defendeu = null
var atualizando_life = false
var show_initial_inst = 0
var show_int_hit = 0

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
	timer_ate_hitar.set_wait_time(delay_ultimo_sprite)
	add_child(timer_ate_hitar)

	
#---------TIMER PARA QUANDO KNIGHT DEFENDE -----------------------
	timer_knight_defendeu = Timer.new()
	timer_knight_defendeu.set_one_shot(true)
	timer_knight_defendeu.set_wait_time(delay_knight_defendeu)
	timer_knight_defendeu.connect("timeout", self, "knight_defendeu_com_sucesso")
	add_child(timer_knight_defendeu)


#------FUNCOES DE ATAQUE-----------------------------
func termina_ataque():
	atacou_stand_by = true


func knight_defendeu_com_sucesso():
	knight.termina_pedra()
	knight_defendeu = false

func volta_a_atacar():
	if !monstro_apanhou:
		$stun.hide()
		$life.show()#------LIFE AQUI
		print("voltou a atacar")
		$sprites_monstro.frame = 0
		monstro_vulneravel = false
		atacou_stand_by = true
		armadura_atual = armadura_monstro
		knight.monstro_vulneravel_set(monstro_vulneravel)
	monstro_apanhou = false

func altera_timer(delay_ataque, delay_hit_monstro):
	timer_ate_hitar.set_wait_time(delay_ataque)
	tempo_hit_monstro = delay_hit_monstro

#-------------------------ATAQUE 1------------------------------------
func monstro_ataque_1():
	if !monstro_atacando:
		altera_timer(delay_ultimo_sprite, delay_ataque_hit_1)
		monstro_atacando = true
		$sprites_monstro.frame = 1
		$alertA.play()
		yield(get_tree().create_timer(delay_ataque_1_aviso_1), "timeout")
		$sprites_monstro.frame = 2
		yield(get_tree().create_timer(delay_ataque_1_pausa_1), "timeout")
		$alertA.play()
		$sprites_monstro.frame = 1
		yield(get_tree().create_timer(delay_ataque_1_aviso_2), "timeout")
		$sprites_monstro.frame = 2
		timer_ate_hitar.start()
		yield(timer_ate_hitar, "timeout")
		$sprites_monstro.frame = 5
		perfect_parry_desativado = true
		yield(get_tree().create_timer(delay_tolerancia_defesa), "timeout")#------TEMPO DE TOLERANCIA PARA DEFESA
		$area_ataque/shape_ataque.disabled = false
		if !perfect_parry and armadura_atual > 0:
			yield(get_tree().create_timer(tempo_hit_monstro), "timeout")
		else:
			tutorial_pp()
			$area_ataque/shape_ataque.disabled = true
			yield(get_tree().create_timer(delay_tomou_pp+0.1), "timeout")
			vulneravel()
		$area_ataque/shape_ataque.disabled = true
	#-----------MINI DELAY DEPOIS DE KNIGHT DEFENDER O ATAQUE COM SUCESSO
		if knight_defendeu == true and !perfect_parry:
			yield(get_tree().create_timer(delay_knight_defendeu), "timeout")
			knight_defendeu = false
			if !monstro_vulneravel:
				$sprites_monstro.frame = 0
	
	#--------------------------------------------------------------------------------------
		perfect_parry = false
		if !monstro_vulneravel:
			$sprites_monstro.frame = 0
		yield(get_tree().create_timer(delay_ataque_1_pausa_3), "timeout")
	#------------FIM DE ATAQUE----------------------------------------------------------
		if !atacou_stand_by_timer.time_left:
			atacou_stand_by_timer.start()
		monstro_atacando = false
		if monstro_vulneravel == false:
			$"sprites_monstro".frame = 0
	

func tutorial_pp():
	if show_initial_inst == 1 or show_initial_inst == 2:
		$instructions.show()
		$instructions.text = "Perfect Parry! The monster get instant stunned!"
		if show_initial_inst == 1:
			show_initial_inst = 4
		else:
			show_initial_inst = 3


#----FUNCAO CAUSAR DANO COM ATAQUE----

func monstro_dano():
	knight.perde_stamina_monstro(dano)

#-----------------FUNCAO SELECIONAR ATAQUE------

func seleciona_ataque():
	perfect_parry_desativado = false
	if !monstro_atacando:
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
	
	if show_initial_inst == 1 or show_initial_inst == 3:
		$instructions.text = "You defended! The monster's armor reduced."
		yield(get_tree().create_timer(3), "timeout")
		if $instructions.text == "You defended! The monster's armor reduced.":
			$instructions.hide()
		if show_initial_inst == 3:
			show_initial_inst = 4
		else:
			show_initial_inst = 2

	if armadura_atual <= 0 and monstro_vulneravel == false:
		vulneravel()
		armadura_atual = armadura_monstro

func vulneravel():
	if show_int_hit == 0:
		$hit.show()
	$stun.show()
	$life.hide()
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
	$hit.hide()
	$instructions.hide()
	show_int_hit = 1
	monstro_apanhou = true
	monstro_hp_atual -=1
	print("monstro hp = ",monstro_hp_atual)
	yield(get_tree().create_timer(delay_volta_do_vulneravel_apos_ataque), "timeout")
	monstro_vulneravel = false
	$stun.hide()
	$life.show()#------LIFE AQUI
	knight.monstro_vulneravel_set(monstro_vulneravel)
	if monstro_hp_atual<=0:
		$life.hide()#----------LIFE AQUI
		monstro_vulneravel = true
		$animacoes.seek(0)
		$die.play()
		$animacoes.play("morte")
		
	else:
		armadura_atual = armadura_monstro

func atualiza_life():
	if !atualizando_life:
		atualizando_life = true
		$life.value = (100*monstro_hp_atual) / monstro_hp
		yield(get_tree().create_timer(1), "timeout")
		atualizando_life = false
	

func _process(delta):
#------PENSAR EM OUTRA SOLUCAO-------------
	if comeca_atacar == true:
		if show_initial_inst == 0:
			$instructions.show()
			show_initial_inst = 1
		atualiza_life()
		if atacou_stand_by == true and monstro_vulneravel==false:
			atacou_stand_by = false
			seleciona_ataque()
		
#-------------------------------------------