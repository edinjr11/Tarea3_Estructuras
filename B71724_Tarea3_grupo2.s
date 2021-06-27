.text # declare text segment

# Tarea 3. Edin Cascante Espinoza B71724.
# En este codigo se resuelve el problema presentado en la tarea 3, este programa
# logra solicitar los catetos de un triangulo rectangulo al usuario y calcular 
# diferentes parametros del mismo.

	main:	
		la $a0,soliOne # Se muestra el mensaje para solicitar el cateto A
		li $v0,4
		syscall
		
		li $v0, 6 #Lee un float que queda en $f0
		syscall	

		mov.s $f1, $f0
		
		
		la $a0,soliTwo # Se muestra el mensaje para solicitar el cateto B
		li $v0,4
		syscall
		
		li $v0, 6 #Lee un float que queda en $f0
		syscall	

		mov.s $f2, $f0
		
		# Se guardaron A y B en $f1 y $f2 respectivamente.
		
		# Se hace llamado a la funcion que calcula los parametros solicitados:
		jal parameterCalc
		
	parameterCalc:
		# Inicialmente se almacenan las variables en $f1 y $f2 en el stack
		addi $sp, $sp, -8
		s.s $f2, 4($sp)
		s.s $f1, 0($sp)
		
		# Para calcular la hipotenusa primero necesitamos la suma de los cuadrados de los catetos
		
		l.s $f1, 0($sp)
		mul.s $f1,$f1,$f1
		l.s $f2, 4($sp)
		mul.s $f2,$f2,$f2
		add.s $f1,$f1,$f2
		
		addi $t0, $0, 2
		mtc1 $t0, $f2 #se transfiere un valor de un registro entero a uno flotante
		cvt.s.w $f2, $f2  #f2=2 Convierte un valor entero en un registro punto flotante en un valor en punto flotante	
		div.s $f3, $f1, $f2 #$f3=x=N/2 valor inicial de la semilla

		addi $t0, $0, 20 #numero de iteraciones
		
		j Raiz
		
	Raiz:
		div.s $f0, $f1, $f3 #$f0=N/x
		add.s $f0, $f3, $f0 #$f0=x+N/x
		div.s $f3, $f0, $f2 ##$f3=(x+N/x)/2

		beq $t0, $0, endRaiz
		addi $t0, $t0, -1
		j Raiz
	
	endRaiz:
		
		li $v0, 2
		mov.s $f12, $f3
		syscall
		
		j inverseSin
		
	inverseSin:
		# $t0 es el contador n de la sumatoria
		addi $t0, $zero, 0
		
		
		# El resultado se guarda en $f22 por lo cual se asegura que se inicie en 0
		addi $t3, $zero, 0
		mtc1 $t3, $f22 #se transfiere un valor de un registro entero a uno flotante
		cvt.s.w $f22, $f22 
		cvt.d.s $f22, $f22
		
		# El primer valor siempre es x
		l.s $f16, 0($sp)
		cvt.d.s $f16,$f16
	loopSin:
		# ------------------------------------------------------
		l.s $f30,0($sp)
		
		addi $t3, $zero, 1
		mtc1 $t3, $f4 #se transfiere un valor de un registro entero a uno flotante
		cvt.s.w $f4, $f4 
		
		addi $t3, $zero, 4
		mtc1 $t3, $f6 #se transfiere un valor de un registro entero a uno flotante
		cvt.s.w $f6, $f6 
		
		add $t1, $zero, $t0
	fourN:
		beq $t0,$zero,continueTwo
		mul.s $f4,$f4,$f6
		addi $t1,$t1,-1
		beq $t1,$zero,continue
		j fourN
		
	continue:
		# Se pasa n a flotante en f2
		
		mtc1 $t0, $f2 #se transfiere un valor de un registro entero a uno flotante
		cvt.s.w $f2, $f2
		
		# Se calcula (2n)!
		
		add.s $f6,$f2,$f2
		cvt.d.s $f6,$f6
		
		jal Fact
		mov.d $f16,$f14
		
		# Se calcula (n!)exp(2)
		mtc1 $t0, $f6 #se transfiere un valor de un registro entero a uno flotante
		cvt.s.w $f6, $f6
		cvt.d.s $f6,$f6
		
		jal Fact
		mov.d $f18,$f14
		mul.d $f18,$f18,$f18
		
		# Se calcula (2n+1)
		mtc1 $t0, $f2 #se transfiere un valor de un registro entero a uno flotante
		cvt.s.w $f2, $f2
		
		addi $t3, $zero, 1
		mtc1 $t3, $f20 #se transfiere un valor de un registro entero a uno flotante
		cvt.s.w $f20, $f20
		
		add.s $f2,$f2,$f2
		add.s $f20,$f20,$f2 
		
		# Se realiza la operación de la fracción de la serie de Taylor y se guarda en $f16
		
		cvt.d.s $f4, $f4
		cvt.d.s $f20, $f20
		
		mul.d $f4,$f4,$f18
		mul.d $f4,$f4,$f20
		div.d $f16,$f16,$f4
		
		# Se calcula x exp(2n+1) y se guarda en $f18
		
		add $a1,$t0,$t0
		addi $a1,$a1,1
		jal exponente
		mov.s $f18,$f30
		
		# Se hace el producto final y se guarda en $f16
		cvt.d.s $f18,$f18
		mul.d $f16,$f16,$f18
		
	continueTwo:
		# ------------------------------
		add.d $f22,$f22,$f16

		addi $t0,$t0,1
		slti $t1,$t0,21
		bne $t1,$zero,loopSin
		
		#---------------------
		li $v0, 4	
		la $a0, newLine
		syscall
		
		mov.d $f12,$f22
		li $v0, 3 
		syscall	
		#---------------------
		#------------------------------------------------------------------------------
		
		# Se realiza el syscall para finalizar la operacion
		li $v0, 10
		syscall
		 
	# Se define la funcion factorial que será util en las proximas funciones
	
	Fact:
		addi $sp, $sp, -8
		cvt.s.d $f6,$f6
		s.s $f6, 0($sp)
		sw $ra, 4($sp)
		
		# Declaro $f8=1 y $f10=0
		addi $t3, $zero, 1
		mtc1 $t3, $f8 #se transfiere un valor de un registro entero a uno flotante
		cvt.s.w $f8, $f8 
		cvt.d.s $f8, $f8 
		
		addi $t3, $zero, 0
		mtc1 $t3, $f10 #se transfiere un valor de un registro entero a uno flotante
		cvt.s.w $f10, $f10 
		cvt.d.s $f10, $f10
		# --------------------
		cvt.d.s $f6,$f6
		c.lt.d $f6,$f8
		bc1f L1
		
		add.d $f14, $f8, $f10
		addi $sp, $sp, 8
		jr $ra
		
	L1:
		sub.d $f6,$f6,$f8
		jal Fact
		
		lw $ra, 4($sp)
		l.s $f6, 0($sp)
		addi $sp, $sp, 8
		
		cvt.d.s $f6,$f6
		mul.d $f14, $f6, $f14
		
		jr $ra
		
	# Se define la funcion exponente, que permite calcular variables exponenciales
	
	exponente:
		addi $sp, $sp, -12
		sw $ra, 8($sp)
		sw $a1, 4($sp)
		s.s $f30, 0($sp)
		
		lw $t3, 4($sp)
		l.s $f31, 0($sp)
	
	exponenteLoop:
		mul.s $f30, $f30, $f31
		addi $t3,$t3,-1
		
		slti $t1,$t3,2
		beq $t1,$zero,exponenteLoop 
		
		lw $a1, 4($sp)
		lw $ra, 8($sp)
		addi $sp, $sp, 12
		
		jr $ra
		
.data # declare data segment
	space: .asciiz " "
	newLine: .asciiz "\n Fact: "
	soliOne: .asciiz "\n Inserte la magnitud del cateto A: "
	soliTwo: .asciiz "\n Inserte la magnitud del cateto B: "
