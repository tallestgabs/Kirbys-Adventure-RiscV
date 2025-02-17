.data
.include "sprites/mapaMatriz.s"			# matriz de cores
.include "sprites/backgroundTile.s"		# Tile de Background
.include "sprites/chaoTile.s"			# Tile de Chão
.include "sprites/nuvem_esqTile.s"		# Tile de Nuvem esquerda
.include "sprites/nuvem_meioTile.s"		# Tile de Nuvem meio
.include "sprites/nuvem_dirTile.s"		# Tile de Nuvem direita
.include "sprites/porta_esq_cimaTile.s"		# Tile de Porta esquerda cima
.include "sprites/porta_esq_baixoTile.s"	# Tile de Porta esquerda baixo
.include "sprites/porta_dir_cimaTile.s"		# Tile de Porta direita cima
.include "sprites/porta_dir_baixoTile.s"	# Tile de Porta direita baixo
.include "sprites/kirbyTile.s"			# Tile do Personagem


KIRBY_POS:	.half 16,175
OLD_KIRBY_POS: 	.half 16,175

.text
.macro sound_effect(%a0,%a1,%a2,%a3)
		addi sp, sp, -20   # Reserva espa�o na pilha
		sw a0, 0(sp)       # Salva a0
		sw a1, 4(sp)       # Salva a1
		sw a2, 8(sp)       # Salva a2
		sw a3, 12(sp)      # Salva a3
		sw a7, 16(sp)      # Salva a7
		
	        li a0 %a0
	        li a1 %a1
	        li a2 %a2
	        li a3 %a3
	        li a7 31
	        ecall
	        
	        lw a0, 0(sp)       # Restaura a0
		lw a1, 4(sp)       # Restaura a1
		lw a2, 8(sp)       # Restaura a2
		lw a3, 12(sp)      # Restaura a3
		lw a7, 16(sp)      # Restaura a7
		addi sp, sp, 20    # Libera espa�o na pilha
.end_macro	
	
		call CARREGA_MAPA
		
		la a0, kirbyTile
		li a1, 16			# coluna
		li a2, 175			# linha
		li a3, 0			# frame 0
		call PRINT
		
		#call MUSIC			# Toca a música inicial
	
	
GAME_LOOP: 	call KEY2
		
		xori s0, s0, 1			# vai alternando entre 0 e 1
	
		la t0, KIRBY_POS
		
		la a0, kirbyTile
		lh a1, 0(t0)
		lh a2, 2(t0)			# 2 porque é half word, para word é 4
		mv a3, s0
		
		call PRINT
		
		li t0, 0xFF200604		# escolhe o frame 0 ou 1
		sw s0, 0(t0)
		
		la t0, OLD_KIRBY_POS
		
		la a0, backgroundTile
		lh a1, 0(t0)
		lh a2, 2(t0)			# 2 porque é half word, para word é 4
		
		mv a3, s0
		xori a3, a3, 1
		
		call PRINT
	
		j GAME_LOOP
	
	
### Apenas verifica se ha tecla pressionada
KEY2:		li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
		lw t0,0(t1)			# Le bit de Controle Teclado
		andi t0,t0,0x0001		# mascara o bit menos significativo
   		beq t0,zero,FIM   	   	# Se nao ha tecla pressionada entao vai para FIM
  		lw t2,4(t1)  			# le o valor da tecla tecla
  		
  		li t0, 'w'			# carrega codigo ascii da letra
		beq t2, t0, KIRBY_MOVE_CIMA
	
		li t0, 'a'			# carrega codigo ascii da letra
		beq t2, t0, KIRBY_MOVE_ESQUERDA
		
		li t0, 's'			# carrega codigo ascii da letra
		beq t2, t0, KIRBY_MOVE_BAIXO
		
		li t0, 'd'			# carrega codigo ascii da letra
		beq t2, t0, KIRBY_MOVE_DIREITA
		
FIM:
		ret				# retorna



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
		
		lh t1, 2(t0)			# pega segundo valor -> posição Y
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

PRINT:		li t0, 0xFF0	 		# endereço do frame
		add t0, t0, a3	 		# define qual vai ser o frame
		slli t0, t0, 20  		# 5 bits hexa faltantes sao 20 bits
		
		add t0, t0, a1	 		# carrega diretamente o x
		
		li t1, 320	 		# linha x320 (t1 apenas para suporte aqui)
		mul t1, t1, a2	 		# 320 x y 
		add t0, t0, t1   		# soma ao endereço do bitmap display
		
		addi t1, a0, 8	 		# pulando largura e altura da imagem (2 words)
		
		mv t2, zero
		mv t3, zero
		
		lw t4,0(a0)			# pega largura da imagem
		lw t5,4(a0)			# pega altura da imagem
		
		
PRINT_LINHA:	lw t6, 0(t1)			# pega de 4 em 4 pixeis da imagem  -> imagem deve ser multiplo de 4
		sw t6, 0(t0)
		
		addi t0, t0, 4 			# soma 4 no endereço do bitmap
		addi t1, t1, 4			# tambem soma 4 no endereço da imagem
		
		addi t3, t3, 4			# adiciona 4 na coluna
		
		blt t3, t4, PRINT_LINHA		# se o contador < largura entao ele continua desenhando
		
		#else
		addi t0, t0, 320		# ele passa para a linha de baixo
		sub t0, t0, t4			# ele volta para o começo da linha
		
		mv t3, zero
		addi t2, t2, 1 			# incrementa contador de linha
		
		ble t2, t5, PRINT_LINHA
		
		ret
		

# tipos de numeros que tem no mapa 
# 0 = background
# 1 = chao	(personagem nao pode atravessar esse bloco)
# 2 = nuvem 
# 3 = nuvem
# 4 = nuvem
# 5 = porta
# 6 = porta
# 7 = porta
# 8 = porta

#---------------------------------------------------------
# t0 = contador de coluna
# t1 = valores dos tiles e também é usado para comparações
# t2 = contador de linha
# t3 = endereço da matriz do mapa
# t4 = tipo de tile que será printado

CARREGA_MAPA:
		# 0 usa registrador
	
		addi sp, sp, -52
		li t1, 1
		sw t1, 0(sp)
		
		li t1, 2
		sw t1, 4(sp)
		
		li t1, 3
		sw t1, 8(sp)
		
		li t1, 4
		sw t1, 12(sp)
		
		li t1, 5
		sw t1, 16(sp)
		
		li t1, 6
		sw t1, 20(sp)
		
		li t1, 7
		sw t1, 24(sp)
		
		li t1, 8
		sw t1, 28(sp)
		
		sw ra, 32(sp)			# para retornar para a 1 chamada
		
		li t0, 0 			# 20 * 16 = 320 para o contador de colunas  (limite será 20)  
		li t2, 0			# 15 * 16 = 240 para o contador de linha (limite será 15)
		la t3, mapaMatriz		# carrega matriz em t3
		addi t3, t3, 8			# pula as words da imagem
		
MAP_LOOP:		
		
		lb t4, 0(t3)			# guarda o tipo de tile que será printado	(5 porque ignora as duas primeiras words e pega o proximo byte)

		lw t1, 16(sp)			# pega o valor 5
		addi t1, t1, 15			# adiciona 15 para dar 20 e fazer a comparação
		beq t0, t1, INCREMENTA_LINHA	# coluna = 20? INCREMENTA linha e zera coluna
		
		lw t1, 16(sp)			# pega o valor 5
		addi t1, t1, 10			# adiciona 10 para dar 15 e fazer a comparação
		bgt t2, t1, LEAVE		# linha > 15? LEAVE
		

		beq t4, zero, PRINTA_BACKGROUND	# valor 0
		
		lw t1, 0(sp)			# pega o valor 1
		beq t4, t1, PRINTA_CHAO
		
		lw t1, 4(sp)			# pega o valor 2
		beq t4, t1, PRINTA_NUVEM_DIR
		
		lw t1, 8(sp)			# pega o valor 3
		beq t4, t1, PRINTA_NUVEM_ESQ
		
		lw t1, 12(sp)			# pega o valor 4
		beq t4, t1, PRINTA_NUVEM_MEIO
		
		lw t1, 16(sp)			# pega o valor 5
		beq t4, t1, PRINTA_PORTA_DIR_BAIXO
		
		lw t1, 20(sp)			# pega o valor 6
		beq t4, t1, PRINTA_PORTA_DIR_CIMA
		
		lw t1, 24(sp)			# pega o valor 7
		beq t4, t1, PRINTA_PORTA_ESQ_BAIXO
		
		#lw t1, 26(sp)			# pega o valor 8
		#beq t4, t1, PRINTA_PORTA_ESQ_CIMA

		
LEAVE:		
		lw ra, 32(sp)
		addi sp, sp, 52
		ret
			
		
INCREMENTA_LINHA:
		li t0, 0			# renova contador de coluna
		addi t2, t2, 1			# aumenta o contador de linha

		addi t3, t3, 80			# largura do display
		addi t3, t3, -20		# subtrai pela largura da matriz
		j MAP_LOOP
	
				
PRINTA_BACKGROUND:
		la, a0, backgroundTile
		mv a1, t0			# a1 = contador de coluna
		slli a1, a1, 4			# x16
		mv a2, t2			# a2 = contador de linha
		slli a2, a2, 4			# x16
		li a3, 0			# frame
		
		# salva os valores de colunas e linhas, e o valor da matriz
		sw t0, 36(sp)
		sw t2, 40(sp)
		sw t3, 44(sp)
		
		call PRINT
		
		li a3, 1			# para printar no frame 1 também
		call PRINT
		
		# restaura os valores
		lw t0, 36(sp)
		lw t2, 40(sp)
		lw t3, 44(sp)
		addi t3, t3, 1 			# para pegar o proximo byte da matriz do mapa
		addi t0, t0, 1			# incrementa coluna
		j MAP_LOOP

PRINTA_CHAO:
		la, a0, chaoTile
		mv a1, t0			# a1 = contador de coluna
		slli a1, a1, 4			# x16
		mv a2, t2			# a2 = contador de linha
		slli a2, a2, 4			# x16
		li a3, 0			# frame
		
		# salva os valores de colunas e linhas, e o valor da matriz
		sw t0, 36(sp)
		sw t2, 40(sp)
		sw t3, 44(sp)
		
		call PRINT
		
		li a3, 1			# para printar no frame 1 também
		call PRINT
		
		# restaura os valores
		lw t0, 36(sp)
		lw t2, 40(sp)
		lw t3, 44(sp)
		addi t3, t3, 1 			# para pegar o proximo byte da matriz do mapa
		addi t0, t0, 1			# incrementa coluna
		j MAP_LOOP

PRINTA_NUVEM_DIR:
		la, a0, nuvem_dirTile
		mv a1, t0			# a1 = contador de coluna
		slli a1, a1, 4			# x16
		mv a2, t2			# a2 = contador de linha
		slli a2, a2, 4			# x16
		li a3, 0			# frame
		
		# salva os valores de colunas e linhas, e o valor da matriz
		sw t0, 36(sp)
		sw t2, 40(sp)
		sw t3, 44(sp)
		
		call PRINT
		
		li a3, 1			# para printar no frame 1 também
		call PRINT
		
		# restaura os valores
		lw t0, 36(sp)
		lw t2, 40(sp)
		lw t3, 44(sp)
		addi t3, t3, 1 			# para pegar o proximo byte da matriz do mapa
		addi t0, t0, 1			# incrementa coluna
		j MAP_LOOP
		
PRINTA_NUVEM_ESQ:
		la, a0, nuvem_esqTile
		mv a1, t0			# a1 = contador de coluna
		slli a1, a1, 4			# x16
		mv a2, t2			# a2 = contador de linha
		slli a2, a2, 4			# x16
		li a3, 0			# frame
		
		# salva os valores de colunas e linhas, e o valor da matriz
		sw t0, 36(sp)
		sw t2, 40(sp)
		sw t3, 44(sp)
		
		call PRINT
		
		li a3, 1			# para printar no frame 1 também
		call PRINT
		
		# restaura os valores
		lw t0, 36(sp)
		lw t2, 40(sp)
		lw t3, 44(sp)
		addi t3, t3, 1 			# para pegar o proximo byte da matriz do mapa
		addi t0, t0, 1			# incrementa coluna
		j MAP_LOOP
		
PRINTA_NUVEM_MEIO:
		la, a0, nuvem_meioTile
		mv a1, t0			# a1 = contador de coluna
		slli a1, a1, 4			# x16
		mv a2, t2			# a2 = contador de linha
		slli a2, a2, 4			# x16
		li a3, 0			# frame
		
		# salva os valores de colunas e linhas, e o valor da matriz
		sw t0, 36(sp)
		sw t2, 40(sp)
		sw t3, 44(sp)
		
		call PRINT
		
		li a3, 1			# para printar no frame 1 também
		call PRINT
		
		# restaura os valores
		lw t0, 36(sp)
		lw t2, 40(sp)
		lw t3, 44(sp)
		addi t3, t3, 1 			# para pegar o proximo byte da matriz do mapa
		addi t0, t0, 1			# incrementa coluna
		j MAP_LOOP

PRINTA_PORTA_DIR_BAIXO:	
		la, a0, porta_dir_baixoTile
		mv a1, t0			# a1 = contador de coluna
		slli a1, a1, 4			# x16
		mv a2, t2			# a2 = contador de linha
		slli a2, a2, 4			# x16
		li a3, 0			# frame
		
		# salva os valores de colunas e linhas, e o valor da matriz
		sw t0, 36(sp)
		sw t2, 40(sp)
		sw t3, 44(sp)
		
		call PRINT
		
		li a3, 1			# para printar no frame 1 também
		call PRINT
		
		# restaura os valores
		lw t0, 36(sp)
		lw t2, 40(sp)
		lw t3, 44(sp)
		addi t3, t3, 1 			# para pegar o proximo byte da matriz do mapa
		addi t0, t0, 1			# incrementa coluna
		j MAP_LOOP
		
PRINTA_PORTA_DIR_CIMA:	
		la, a0, porta_dir_cimaTile
		mv a1, t0			# a1 = contador de coluna
		slli a1, a1, 4			# x16
		mv a2, t2			# a2 = contador de linha
		slli a2, a2, 4			# x16
		li a3, 0			# frame
		
		# salva os valores de colunas e linhas, e o valor da matriz
		sw t0, 36(sp)
		sw t2, 40(sp)
		sw t3, 44(sp)
		
		call PRINT
		
		li a3, 1			# para printar no frame 1 também
		call PRINT
		
		# restaura os valores
		lw t0, 36(sp)
		lw t2, 40(sp)
		lw t3, 44(sp)
		addi t3, t3, 1 			# para pegar o proximo byte da matriz do mapa
		addi t0, t0, 1			# incrementa coluna
		j MAP_LOOP
		
PRINTA_PORTA_ESQ_BAIXO:	
		la, a0, porta_esq_baixoTile
		mv a1, t0			# a1 = contador de coluna
		slli a1, a1, 4			# x16
		mv a2, t2			# a2 = contador de linha
		slli a2, a2, 4			# x16
		li a3, 0			# frame
		
		# salva os valores de colunas e linhas, e o valor da matriz
		sw t0, 36(sp)
		sw t2, 40(sp)
		sw t3, 44(sp)
		
		call PRINT
		
		li a3, 1			# para printar no frame 1 também
		call PRINT
		
		# restaura os valores
		lw t0, 36(sp)
		lw t2, 40(sp)
		lw t3, 44(sp)
		addi t3, t3, 1 			# para pegar o proximo byte da matriz do mapa
		addi t0, t0, 1			# incrementa coluna
		j MAP_LOOP
		
PRINTA_PORTA_ESQ_CIMA:	
		la, a0, porta_esq_cimaTile
		mv a1, t0			# a1 = contador de coluna
		slli a1, a1, 4			# x16
		mv a2, t2			# a2 = contador de linha
		slli a2, a2, 4			# x16
		li a3, 0			# frame
		
		# salva os valores de colunas e linhas, e o valor da matriz
		sw t0, 36(sp)
		sw t2, 40(sp)
		sw t3, 44(sp)
		
		call PRINT
		
		li a3, 1			# para printar no frame 1 também
		call PRINT
		
		# restaura os valores
		lw t0, 36(sp)
		lw t2, 40(sp)
		lw t3, 44(sp)
		addi t3, t3, 1 			# para pegar o proximo byte da matriz do mapa
		addi t0, t0, 1			# incrementa coluna
		j MAP_LOOP
		
		

EXIT:
	li a7, 10
	ecall

# imports
.include "music.s"

