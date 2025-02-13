# Kirby's music

.data
# Numero de Notas a tocar
NUM: .word 62
# lista de nota,duração,nota,duração,nota,duração,...
NOTAS: 79,249,79,83,91,333,84,499,96,333,93,166,91,333,84,499,91,333,89,166,88,166,88,166,89,166,91,166,84,333,86,333,88,1332,91,333,84,499,96,333,93,166,91,333,84,499,91,333,89,166,88,166,88,166,89,166,91,166,84,333,86,333,84,1332,84,249,84,83,86,166,88,333,84,166,86,166,84,166

.text

MUSIC:
	la s0,NUM		# define o endereço do número de notas
	lw s1,0(s0)		# le o numero de notas
	la s0,NOTAS		# define o endereço das notas
	li t0,0			# zera o contador de notas
	li a2,7			# define o instrumento
	li a3,70		# define o volume

LOOP:	beq t0,s1, TERMINA	# contador chegou no final? então  vá para TERMINA
	lw a0,0(s0)		# le o valor da nota
	lw a1,4(s0)		# le a duracao da nota
	li a7,31		# define a chamada de syscall
	ecall			# toca a nota
	mv a0,a1		# passa a duração da nota para a pausa
	li a7,32		# define a chamada de syscal 
	ecall			# realiza uma pausa de a0 ms
	addi s0,s0,8		# incrementa para o endereço da próxima nota
	addi t0,t0,1		# incrementa o contador de notas
	j LOOP			# volta ao loop
	
TERMINA: # Limpa todos os registradores e retorna para o game principal
	
	li s0, 0
	li s1, 0
	li a0, 0
	li a1, 0
	li a2, 0
	li a3, 0
	li a7, 0
	li t0, 0	
	ret			# Retorna para o game principal

# carrega 0 provisoriamente ja que nao temos nada de importante