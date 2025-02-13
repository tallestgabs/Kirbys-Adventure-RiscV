.data
.include "sprites/"
.include "sprites/"
.include "sprites/"

KIRBY_POS:	.half 0,0
OLD_KIRBY_POS: 	.half 0,0

.text
		# Adicionar uma imagem de Menu
		call MUSIC	# Toca a música inicial
		
SETUP:	
		la a0, map2teste
		li a1, 0
		li a2, 0
		li a3, 0
		call PRINT
		li a3, 1
		call PRINT
	
	
GAME_LOOP: 	call KEY2
		
		xori s0, s0, 1	# vai alternando entre 0 e 1
	
		la t0, KIRBY_POS
		
		la a0, Kirby0
		lh a1, 0(t0)
		lh a2, 2(t0)	# 2 porque é half word, para word é 4
		mv a3, s0
		call PRINT
	
		li t0, 0xFF200604	# escolhe o frfame 0 ou 1
		sw s0, 0(t0)
		
		la t0, OLD_KIRBY_POS
		
		la a0, tileMap
		lh a1, 0(t0)
		lh a2, 2(t0)	# 2 porque é half word, para word é 4
		
		mv a3, s0
		xori a3, a3, 1
		
		call PRINT
	
		j GAME_LOOP
	
	
### Apenas verifica se h� tecla pressionada
KEY2:		li t1,0xFF200000		# carrega o endere�o de controle do KDMMIO
		lw t0,0(t1)			# Le bit de Controle Teclado
		andi t0,t0,0x0001		# mascara o bit menos significativo
   		beq t0,zero,FIM   	   	# Se n�o h� tecla pressionada ent�o vai para FIM
  		lw t2,4(t1)  			# le o valor da tecla tecla
  		
  		
  		
  		li t0, 'w'			# carrega codigo ascii da letra
		beq t2, t0, KIRBY_MOVE_CIMA
	
		li t0, 'a'			# carrega codigo ascii da letra
		beq t2, t0, KIRBY_MOVE_ESQUERDA
		
		li t0, 's'			# carrega codigo ascii da letra
		beq t2, t0, KIRBY_MOVE_BAIXO
		
		li t0, 'd'			# carrega codigo ascii da letra
		beq t2, t0, KIRBY_MOVE_DIREITA
	
FIM:		ret				# retorna



KIRBY_MOVE_CIMA:
		la t0, KIRBY_POS
		la t1, OLD_KIRBY_POS
		lw t2, 0(t0)
		sw t2, 0(t1)
		
		lh t1, 2(t0)
		addi t1, t1, -16
		sh t1,2(t0)
		ret
		

KIRBY_MOVE_ESQUERDA:
		la t0, KIRBY_POS
		la t1, OLD_KIRBY_POS
		lw t2, 0(t0)
		sw t2, 0(t1)
		
		lh t1, 0(t0)
		addi t1, t1, -16
		sh t1,0(t0)
		ret
		
		
KIRBY_MOVE_BAIXO:
		la t0, KIRBY_POS
		la t1, OLD_KIRBY_POS
		lw t2, 0(t0)
		sw t2, 0(t1)
		
		lh t1, 2(t0)		# pega segundo valor -> posição Y
		addi t1, t1, 16
		sh t1,2(t0)
		ret
		
KIRBY_MOVE_DIREITA:
		la t0, KIRBY_POS
		la t1, OLD_KIRBY_POS
		lw t2, 0(t0)
		sw t2, 0(t1)
		
		lh t1, 0(t0)
		addi t1, t1, 16
		sh t1,0(t0)
		ret



#
#	a0 = endereço imagem
#	a1 = x
#	a2 = y
#	a3 = frame (0 ou 1)
#
#
#	t0 = endereço bitmap display
#	t1 = endereço da imagem
#	t2 = contador de linha
#	t3 = contador de coluna
#	t4 = largura
#	t5 = altura
#
PRINT:		li t0, 0xFF0	 # endereço do frame
		add t0, t0, a3	 # define qual vai ser o frame
		slli t0, t0, 20  # 5 bits hexa faltantes sao 20 bits
		
		add t0, t0, a1	 # carrega diretamente o x
		
		li t1, 320	 # linha x320 (t1 apenas para suporte aqui)
		mul t1, t1, a2	 # 320 x y 
		add t0, t0, t1   # soma ao endereço do bitmap display
		
		addi t1, a0, 8	 # pulando largura e altura da imagem (2 words)
		
		mv t2, zero
		mv t3, zero
		
		lw t4,0(a0)	# pega largura da imagem
		lw t5,4(a0)	# pega altura da imagem
		
		
PRINT_LINHA:	lw t6, 0(t1)	# pega de 4 em 4 pixeis da imagem  -> imagem deve ser multiplo de 4
		sw t6, 0(t0)
		
		addi t0, t0, 4 	# soma 4 no endereço do bitmap
		addi t1, t1, 4	# tambem soma 4 no endereço da imagem
		
		addi t3, t3, 4	# adiciona 4 na coluna
		
		blt t3, t4, PRINT_LINHA		# se o contador < largura entao ele continua desenhando
		
		#else
		addi t0, t0, 320	# ele passa para a linha de baixo
		sub t0, t0, t4		# ele volta para o começo da linha
		
		mv t3, zero
		addi t2, t2, 1 		# incrementa contador de linha
		
		ble t2, t5, PRINT_LINHA
		
		ret
		

# imports
.include "music.s"

