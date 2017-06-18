;Instituto Tecnologico de Costa Rica
;Arquitectura de Computadoras
;Profesor Kirstein Gätjens Soto
;Tarea: Ralph el Compresor
;Juan Fernando Villacis Llobet
;2016201681
;II Semestre 2016
;5/9/2016

;Manual de Usuario
;Este es un programa que comprimey descomprime archivos 
;Para comprimir se introduce en la linea de comandos la opcion -c seguida del pathname de un archivo txt
;el producto de esta operacion es un archivo .rlp
;para comprimir lo que hace el programa es tomar los 15 caracteres mas comunes y reemplazarlos por un codigo de un nible
;el resto los deja con su ascii normal
;ademas de eso, en la pantalla se muestra el tamano del archivo original, del compreso y el porcentaje de compresion
;ademas se incluyen los 15 caracteres mas comunes en el archivo (los que se reemplazaron por un codigo de un nible),seguidos de cuantas veces aparecen en el archivo
;si un caracter de los mas comunes es uno de formato, entonces lo que se muestra es el nemonico ascii que lo representa (ej, spc = espacio, cr = retorno de carro)
;para descomprimir se introduce en la linea de comandos la opcion -d seguida del pathname de un archivo .rlp 
;el resultado de este procedimiento es un archivo .txt del mismo nombre que el archivo de la entrada con el texto descomprimido
;para observar la ayuda se puede introducir la opcion -a o simplemente no introducir nada en la linea de comandos despues de invocar al programa


;Analisis de Resultados
;Entrada por la linea de comandos: A
;Compresion: A
;Descompresion: A
;Muestra de tamano inicial, final y tabla de top15: A
;Acerca de: A 
;Ayuda: A
;Manejo de errores: A 

 datos segment
	handle dw ?;donde se guardara el handle del archivo con el que se trabajara
	handle2 dw ?;donde se guardara el handle del archivo que se creara si es que se escoge la compresion
	buffer db ?;donde se guarda lo que se lee
	buffer_escritura db 0;donde se guarda lo que se escribira
	b db 0;representa si actualmente se tiene en el byte de lo que se va a escribir el contenido de un nible o de un byte
	
	tamano_antes db "Tamano antes de comprimir: $"
	tamano_despues db "Tamano despues de comprimir: $"
	tasa_compresion db "Tasa de compresion: $"
	tasa_infinito db "infinito$"

	numero db 7 dup ('$');donde se convierte de cb16 a ascii, queda al reves
	numero_bien db 7 dup ('$')
	flotante dw 0;donde se guardara temporalmente un numero para poder sacar la parte flotante del porcentaje de compresion
	acercade db "Ralph el Compresor	     	       Creado por Juan Villacis",0dh,0ah,'$'
	acercade2 db  "Arquitectura de computadoras		2 semestre		2016",0dh,0ah,0dh,0ah,'$'
	
	error_msg db "ERROR: $"
	error_msg_opcioninvalida db "Opcion no valida$"
	error_msg_nombreinvalido db "Nombre de archivo no valido$"
	error_msg_fallolectura db "Error en lectura del archivo$"
	error_msg_tamanoarchivo db "Tamano de archivo no aceptado$"
	error_msg_formatoinvalido db "Formato de archivo no valido$"

	success_msg_descomprimir db "Descomprimido con exito$"
	caracteres_mas_abundantes db "Caracteres mas abundnantes: ",0dh,0ah,'$'
	longitud db ?;guarda la longitud de la entrada
	pathname db 256 dup (0);donde se guardara el archivo
	pathname_sinformato db 256 dup (0);donde se guardara el pathaname sin el formato del punto
	
	
	tipo_operacion db ?;donde se guarda si es ocmpresion o descompresion, 0:compresion, 1:descopmpresion
	contador dw 0;donde se almacena el tamano del archivo a comprimir
	cont_salida dw 18;donde se guardara el tamano del archivo comprimido,se inicializa en 18 para contar los trees bytes del tag y los quince del top15
	guarda_temp_numero dw ?;guarda temporalmente el numero que esta moviendo en la asignacion del top15
	guarda_temp_letra db ?;ismo que el de arriba, solo que con la letra
	vector_cuenta_letras dw 256 dup (0);se guarda la cuenta de cada uno de los caracteres dentro del archivo
	vector_top15_letras db 15 dup (0);se guarda el ascii del top15 de letras
	vector_top15_numeros dw 15 dup(0);se guarda la cantidadde veces que cada letra se encontro

	ayuda db "Este programa comprime un archivo",0dh,0ah,'$'
	ayuda2 db "Las opciones del programa comienzan con - y no es case sensitive",0dh,0ah,,'$'
	ayuda3 db "Las opciones son:",0dh,0ah,,'$'
	ayuda4 db "-D: para descomprimir",0dh,0ah,,'$'
	ayuda5 db "-C: para comprimir",0dh,0ah,,'$'
	ayuda6 db "Las opciones se deben seguir con el pathname del archivo",0dh,0ah,,'$'
	ayuda7 db "El resultado de la compresion es un archivo .rlp, mientras que si se descomprime el resultado sera un archivo .txt",0dh,0ah,,'$'
	
	noimprimibles db "nul$soh$stx$etx$eot$enq$ack$bel$bs $tab$lf $vt $ff $cr $so $si $dle$dc1$dc2$dc3$dc4$nak$syn$etb$can$em $sub$esc$fs $gs $rs $us $spc$"

	tag db "RLP";tag al inicio del compreso
	

 datos ends

                  
 pila segment stack 'stack'

    dw 256 dup (?)

 pila ends


 codigo segment

    assume  cs:codigo, ds:datos, ss:pila

	noimprimible_imprimible proc near;si el caracter del top15 es un no imprimible secambia por un nemonico,sino entonces se deja como estaba
		push ax
		push bx
		push dx

		cmp dl,20h
		jnbe imprimible;el caracter es imprimible
		mov al,dl
		mov bl,4
		mul bl
		mov bx,ax
		lea dx,noimprimibles[bx]
		mov ah,09h
		int 21h
		jmp fin_noimprimible_imprimible

		imprimible:
			mov ah,02h
			int 21h
			jmp fin_noimprimible_imprimible


		fin_noimprimible_imprimible:
		pop dx
		pop bx
		pop ax
		ret
		noimprimible_imprimible endp
	arregla_numero_bien proc near;vuelve a poner en $ todos los elementos de numero y numero_bien
		mov numero_bien[0],'$'
		mov numero[0],'$'
		mov numero_bien[1],'$'
		mov numero[1],'$'
		mov numero_bien[2],'$'
		mov numero[2],'$'
		mov numero_bien[3],'$'
		mov numero[3],'$'
		mov numero_bien[4],'$'
		mov numero[4],'$'
		mov numero_bien[5],'$'
		mov numero[5],'$'
		mov numero_bien[6],'$'
		mov numero[6],'$'
		ret
		arregla_numero_bien endp

	imprimir_top15 proc near;donde se imprime la tabla con el top15 de caracteres
		push ax
		push dx
		push si
		push di
		
		mov ah,09h
		lea dx,caracteres_mas_abundantes
		int 21h
		xor si,si
		xor di,di
		ciclo_imprimir_top15:
			mov ax,vector_top15_numeros[di];convertir numero a ascii
			cmp ax,0
			je fin_imprimir_top15
			call numero_ascii
			
			
			mov dl,vector_top15_letras[si]
			call noimprimible_imprimible
			mov ah,02h
			;int 21h;imprimir la letra
			mov dl,' '
			int 21h
			
			mov ah,09h
			lea dx,numero_bien
			int 21h;imprimir el numero convertido a ascii
			call arregla_numero_bien;arregla los valores de numero_bien
			mov ah,02h
			mov dl,0dh
			int 21h
			mov dl,0ah
			int 21h
			inc si;aumentar el indice del vector de letras
			add di,2;aumentar el indice del vector de numeros
			cmp si,14
			ja fin_imprimir_top15
			jmp ciclo_imprimir_top15
			
		fin_imprimir_top15:
		pop si
		pop di
		pop dx
		pop ax
		ret
	imprimir_top15 endp

	numero_ascii proc near;se convierte de numer a ascii
		;el numero esta en el ax
		 push ax
		 push bx
		 push cx
		 push dx
		 push di
		 push si
		
		 xor dx,dx
		 xor di,di
		 mov bx,10
		init_decimal_division:
			 div bx
			 add dx,30h;se convierte del valor numerico al valor ascii
			 mov numero[di],dl;se mueve el digito a la variable donde se almacenara el numero (como tira de caracteres) antes de moverlo a la variable donde se almacenara 
			 cmp ax,0
			 jbe estandarizar_numero; el numero queda al reves entonces se va a un lugar donde se le da la vuelta y se le agrega un - si es negativo
			 inc di
			 xor dx,dx;se limpia la parte de arriba que tenia el residuo
			 jmp init_decimal_division
		estandarizar_numero:;se le da vuelta al numero que esta al reves
			xor si,si
			mov dx,di;guardar el tamano que tenia el numero antes de entrar
			estandarizacion:
				cmp si,dx
				ja salir_estandarizacion
				mov al,numero[di]
				mov numero_bien[si],al
				dec di
				inc si
				jmp estandarizacion
			salir_estandarizacion:
		 pop si
		 pop di
		 pop dx
		 pop cx
		 pop bx
		 pop ax
		 ret
		numero_ascii endp
		
	
	mensajes_iniciales proc ;se encarga de mostrar los mensajes iniciales
		mov ah,09h
		lea dx,acercade
		int 21h
		lea dx, acercade2
		int 21h
		ret 
	mensajes_iniciales endp
	
	agregar_terminacion proc near;le agrega el .formato si le hace falta
		push ax
		push cx
		push dx
		push di
		push si
		
		xor dl,dl;en dl se guardara la informacion de si el nombre tiene un punto o no
		xor di,di;apuntara a la variable donde se guardara el nombre
		mov cl,longitud
		add cx,80h
		
		agregar_letras:;donde se agregan las letras a la variable
			inc si
			mov al,es:[si]
			cmp al,' '
			je espaciador_no_incluir;si se incluyen espaciadores al inicio estos se deben ingnorar
			cmp al,9h
			je espaciador_no_incluir
			cmp al,0Bh
			je espaciador_no_incluir
			cmp al,'.'
			jne no_es_punto;donde se indica que si tiene punto decimal entonces no hay que agregarselo
			inc dl
			no_es_punto:
			mov pathname[di],al
			inc di
			espaciador_no_incluir:
			cmp cx,si
		ja agregar_letras
		cmp  dl,1;para ver si hay que agregarle extension o no al nombre
		je no_hay_que_agregarle_punto
		cmp tipo_operacion,0;determinar si hay que agregarle .rlp o .txt
		jne agregar_rlp
		
		agregar_txt:;aqui se agregara el .txt
			mov pathname[di],'.'
			inc di
			mov pathname[di],'t'
			inc di
			mov pathname[di],'x'
			inc di
			mov pathname[di],'t'
			inc di
		jmp no_hay_que_agregarle_punto
		agregar_rlp:;se le agrega la extension .rlp
			mov pathname[di],'.'
			inc di
			mov pathname[di],'r'
			inc di
			mov pathname[di],'l'
			inc di
			mov pathname[di],'p'
			inc di
		no_hay_que_agregarle_punto:
		mov pathname[di],0;agregar el caracter nulo al final del nombre
		
		pop si
		pop di
		pop dx
		pop cx
		pop ax
		ret 
	agregar_terminacion endp
	
	cambiar_formato proc near
		push di
		
		xor di,di
		
		ciclo_copia_pathname:
			mov al,pathname[di]
			cmp al,'.'
			je cambiar_terminacion
			mov pathname_sinformato[di],al
			inc di
			jmp ciclo_copia_pathname
			cambiar_terminacion:
				cmp tipo_operacion,0 
				je txt_a_rlp
				;inc di
				mov pathname_sinformato[di],'.'
				inc di
				mov pathname_sinformato[di],'t'
				inc di
				mov pathname_sinformato[di],'x'
				inc di
				mov pathname_sinformato[di],'t'
				jmp fin_cambiar_terminacion
				txt_a_rlp:
				;inc di
					mov pathname_sinformato[di],'.'
					inc di
					mov pathname_sinformato[di],'r'
					inc di
					mov pathname_sinformato[di],'l'
					inc di
					mov pathname_sinformato[di],'p'
				fin_cambiar_terminacion:
		pop di
		ret
		cambiar_formato endp
				
		
	
	contar_caracteres proc near;se encarga de recorrer el archivo y contar todos los caracteres
		
		push ax
		push bx 
		push cx
		push dx
		
		mov cx,1
		lea dx,buffer
		ciclo_de_cuenta:
			mov ah,3fh
			mov bx,handle
			int 21h
			lea bx,error_msg_fallolectura
			jc errores_conejo_conejo_conejo_conejo
			cmp ax,0
			je fin_contar_caracteres;ya no hay caracteres que leer
			mov al,byte ptr buffer;la letra que se leyo
			mov bl,2
			mul bl;multiplica por 2 porque la letra es un inmediato que se comporta como el indice de la lista donde se cuenta cuantas de ellas aparecen
			mov si,ax;mueve a si el indice del word donde 
			inc vector_cuenta_letras[si]
			add contador,1;se prefiere add porque si afecta la CF mientras que INC no lo hace
			lea bx,error_msg_tamanoarchivo;
			jc errores_conejo_conejo_conejo_conejo;si el tamano del archivo es mayor que el permitido
			jmp ciclo_de_cuenta
			
		fin_contar_caracteres:
		
		pop dx
		pop cx
		pop bx
		pop ax
		ret
		contar_caracteres endp
		
		top15 proc near
			push si
			push di
			
			xor si,si;donde se almacenara el indice del vector con todas las cantidades
			ciclo256:;ciclo que se repite para cada uno de los elementos de la tabla ascii
				mov dx,vector_cuenta_letras[si]
				xor di,di;donde se almacenara el indice del vector top15
				ciclo15:;ciclo que se repite para cada uno de los elementos del top15 para determinar si la cantidad de repeticiones esta en el top15
					cmp dx,vector_top15_numeros[di]
					jna continuar_ciclo15
					call agregar_top15
					
					continuar_ciclo15:
						add di,2;para que apunte al siguiente 
						cmp di,28
						ja fin_top15
						jmp ciclo15;para que continue comparando
					fin_top15:
						add si,2;para que apunte al siguiente elemento
						cmp si,510;determinar si ya se acabo
						ja fin_ciclo256
						jmp ciclo256
						errores_conejo_conejo_conejo_conejo:
							jmp errores_conejo_conejo_conejo
			fin_ciclo256:
				pop di
				pop si
						
			
			
			ret
		top15 endp
		
		agregar_top15 proc near
			push ax
			push bx
			push cx
			push dx
			push si
			
			mov cl,2;se va a usar para dividir el indice porque se usara para trabajr con posiciones equivalentes en unalista de words y otra de bytes
			
			mov bx,vector_top15_numeros[di];guarda la cantidad que va a ser sustituida
			mov guarda_temp_numero,bx
			mov ax,di
			div cl
			xor ah,ah
			mov bx,ax;
			mov ah,vector_top15_letras[bx];guarda la letra que va a ser sustituida
			mov guarda_temp_letra,ah
			
			mov vector_top15_numeros[di],dx
			mov ax,si;para poner el ascii del numero, primero hay que dividirlo entre 2 porque se esta usando  el si como indice en una lista de words
			mov dl,2
			div dl
			mov vector_top15_letras[bx],al;mueve el ascii del caracter al top15 de letras
			add di,2
			inc bx
			ciclo_agregacion_top15:;donde se agregan el numero que se va a agregar a la posicion que le corresponde
				cmp bx,14
				jnbe terminar_agregacion_top15
				mov cx,guarda_temp_numero
				mov al,guarda_temp_letra
				xchg cx,vector_top15_numeros[di]
				xchg al,vector_top15_letras[bx]
				mov guarda_temp_numero,cx
				mov guarda_temp_letra,al
				add di,2
				inc bx;para que apunten al siguiente elemento
				jmp ciclo_agregacion_top15
				

			terminar_agregacion_top15:
				pop si
				pop dx
				pop cx
				pop bx
				pop ax
				ret
			agregar_top15 endp
				
		
		escribir_archivo proc near;donde se realiza la codificacion del archivo
			push ax
			push bx
			push cx
			push dx
			
			
			mov ah,40h
			mov bx,handle2
			mov cx,3
			lea dx,tag
			int 21h;escribir el tag rlp
			mov ah,40h
			mov cx,15
			lea dx,vector_top15_letras
			int 21h;escribir los ascii de los 15 caracteres
			mov ah,40h
			mov cx,2;escribir la longitud del archivo
			lea dx,contador;poner la longitud
			int 21h
			ciclo_lectura_escritura:;donde se lee un caracter y se traduce al archivo comprimido
				mov cx,1
				mov bx,handle
				lea dx,buffer
				mov ah,3fh
				int 21h;leer un caracter del archivo a comprimir
				cmp ax,0
				je fin_ciclo_lectura_escritura
				call codificar;codifica la letra del buffer y la 
				jmp ciclo_lectura_escritura
				
			fin_ciclo_lectura_escritura:;donde se va despues de haber leido y traducido todos los caracteres
			cmp b,0
			je finalizar_lectura_escritura
			or buffer_escritura,00001111b;poner un 1111 (que no significa nada) para poder rellenar el byte que hacia falta por escribir
			call escribir_bin
			finalizar_lectura_escritura:
			
			pop dx
			pop cx
			pop bx
			pop ax
			ret
		escribir_archivo endp
		
		
		codificar proc near;se convierte el caracter en su representacion disminuida
			push ax
			push bx
			push cx
			
			mov al,byte ptr buffer
			xor bx,bx;se usara para apuntar
			pertenece_top15:;para determinar si pertenece al top 15
				cmp al,vector_top15_letras[bx]
				je si_pertenece_top15
				inc bx
				cmp bx,15
				jae no_pertenece_top15
				jmp pertenece_top15
				
			si_pertenece_top15:;se escribe el nible que lo representa
				cmp b,0
				je escribir_nible;esta vacio, hay que escribir un nible
				or buffer_escritura,bl;en bl esta el numero de indice detro del top15,que tambien representa el codigo
				call escribir_bin;que se escriba lo que este en el buffer de escritura
				mov b,0;0 representa que el buffer_escritura esta vació, 1 representa que tiene un nible adentro
				jmp codificar_end
				escribir_nible:
					mov cl,4;cuantos espacios tiene que rotar
					shl bl,cl
					mov buffer_escritura,bl
					inc b
					jmp codificar_end
			no_pertenece_top15:;el caracter no pertenece, entonces hay que escribir el 1111 y el ascii
				cmp b,0
				je escribir_1111_ascii
				or buffer_escritura,00001111b;poner el 1111 en el buffer 
				call escribir_bin
				mov buffer_escritura,al;escribir eel ascii
				call escribir_bin
				mov b,0;mostrar el estado del buffer_escritura
				jmp codificar_end
				errores_conejo_conejo_conejo:
					jmp errores_conejo_conejo
				
				escribir_1111_ascii:;se debe escribir el 1111 y la mitad del ascii en el byte e imprimirlo y despues poner la otra mitad
					mov buffer_escritura,al;pone el caracter en el buffer
					mov cl,4;para mover la mitad del ascii al final del buffer
					shr buffer_escritura,cl
					or buffer_escritura,11110000b;pone el 1111 al inicio del caracter
					call escribir_bin
					mov buffer_escritura,al
					mov cl,4
					shl buffer_escritura,cl;deja el buffer con la mitad del caracter
					inc b;dejar el estado del buffer_escritura
					jmp codificar_end
			codificar_end:
			
			pop cx
			pop bx
			pop ax
			ret
		codificar endp
		
		escribir_bin proc near;se escriben el byte guardado en buffer_escritura
			push ax
			push bx
			push cx
			push dx
		
			mov ah,40h
			mov bx,handle2
			mov cx,1
			lea dx,buffer_escritura
			int 21h
			inc cont_salida;se guarda el tamano del archivo comprimido, por cada byte que se escrie se incrementa en uno el contador
			
			pop dx
			pop cx
			pop bx
			pop ax
			
			ret
		escribir_bin endp
		
		descodificacion proc near;donde se descomprime el arhcivo
			push ax
			push bx
			push cx
			push dx
		
			call descodificacion_inicial;donde se lee el top 15 y el tag
			
			ciclo_decodificacion:;donde se analiza cada uno de los caracteres que se lee del compreso
				; cmp b,1
				; je no_leer_en_esta_ocasion; el dato ya se leyo, se da cuando el dato anterior ocupa medio byte del que se deberia leer en esta ocasion
				mov ah,3fh
				lea dx,buffer
				mov bx,handle
				mov cx,1
				int 21h
				jc errores_conejo_conejo
				cmp ax,0 
				je fin_decodificacion 
				call escribir_descompreso;donde se escriben los datos en el descompreso
				jmp ciclo_decodificacion
			
			
			
			fin_decodificacion:
			
			
			pop dx
			pop cx
			pop bx
			pop ax
			
		ret
		descodificacion endp
		
		descodificacion_inicial proc near;donde se lee el top15 y el tag y la longitud
			push ax
			push bx
			push cx
			push dx
			
			mov cx,1
			mov ah,3fh
			mov bx,handle
			lea dx,buffer
			int 21h
			cmp byte ptr buffer, 'R'
			jne error_decodificacion_inicial
			mov ah,3fh
			int 21h
			cmp byte ptr buffer, 'L'
			jne error_decodificacion_inicial
			mov ah,3fh
			int 21h
			cmp byte ptr buffer, 'P'
			jne error_decodificacion_inicial;compara el tag
			
			xor bx,bx
			
			ciclo_determinacion_top15:;pone en el vector top15letras el ascii de los 15 caracteres mas comunes
				mov si,bx;guardar el valor de bx
				mov bx,handle
				lea dx,buffer
				mov ah,3fh
				int 21h
				lea bx,error_msg_formatoinvalido
				cmp ax,0
				je  errores_conejo_conejo;el formato no es valido, no fue un archivo creado por el compresor,fue modificado externamente
				mov bx,si;retorna el valor de bx
				mov al,byte ptr buffer
				mov vector_top15_letras[bx],al
				inc bx
				cmp bx,15 
				jae continuar_decodificacion_inicial
				jmp ciclo_determinacion_top15
				errores_conejo_conejo:
					jmp errores_conejo
			continuar_decodificacion_inicial:	
			mov ah,3fh
			mov bx,handle
			lea dx,buffer
			int 21h
			lea bx,error_msg_formatoinvalido
			cmp ax,0
			je errores_conejo_conejo;formato invalido
			mov ah,3fh
			mov bx,handle
			lea dx,buffer
			int 21h
			jc error_decodificacion_inicial;si hubo un error leyendo la longitud del archivo
			jmp fin_decodificacion_inicial
			
			
			
			error_decodificacion_inicial:
				lea bx,error_msg_formatoinvalido
				jmp errores
			
			
			fin_decodificacion_inicial:
			
			pop dx
			pop cx
			pop bx
			pop ax
			
			
		ret
		descodificacion_inicial endp
		
		escribir_descompreso proc near
			push ax
			push bx
			push cx
			push dx
		
			mov cl,4;para los shifts y rotates
			mov al,byte ptr buffer;mueve el codigo
			mov ah,al;lo copia en otro registro
			cmp b,1 
			je esciribir_segundo_nible;para que se salte el primer nible
			
			shr ah,cl
			cmp ah,00001111b
			je e1111_y_ascii;tiene que escribir un ascii normal
				escribir_primer_nible:;se sabe que es un caracter del top15
					mov bl,al
					xor bh,bh;limpia la parte alta del bx, que se usara como apuntador
					shr bl,cl;deja el codigo en la parte baja del bx
					mov al,byte ptr vector_top15_letras[bx];mueve el ascii que le corresponde
					mov byte ptr buffer_escritura,al
					call escribir_bin
				esciribir_segundo_nible:;se determina si es un 1111 o un top15
					mov al,byte ptr buffer;mueve el codigo
					mov b,0;limpia el valor de b
					mov bl,al
					and al,00001111b;limpia la parte alta del al
					and bl,00001111b;limpia
					cmp bl,00001111b;determinar si es un 1111
					je escribir_caracter
						xor bh,bh; limpia la parte alta del bx para usarlo como apuntador
						mov al,byte ptr vector_top15_letras[bx]
						mov byte ptr buffer_escritura,al
						call escribir_bin;escribe el caracter del top15 en el archivo
						jmp fin_escribir_descompreso
					escribir_caracter:
						mov ah,3fh
						mov bx,handle
						mov cx,1
						lea dx,buffer_escritura
						int 21h
						cmp ax,0
						je fin_escribir_descompreso;es 0, no se leyo nada, se salta el proceso de escritura, el archivo ya se termino
						call escribir_bin
						jmp fin_escribir_descompreso
					
			
			e1111_y_ascii:;hay que mover el nible a laparte superior del buffer_escritura y despues hacer otra lectura y mover el nible ms a la parte inferior
				shl al,cl
				mov byte ptr buffer_escritura,al
				call escribir_medio_byte
				jmp fin_escribir_descompreso
				
			fin_escribir_descompreso:
			
			pop dx
			pop cx
			pop bx
			pop ax
				
		ret
		escribir_descompreso endp
		
		escribir_medio_byte proc near
			push ax
			push bx
			push cx
			push dx
		
			mov ah,3fh
			mov cx,1
			mov bx,handle
			lea dx,buffer
			int 21h;lee elsiguiente byte
			mov al,byte ptr buffer
			mov cl,4
			shr al,cl
			or byte ptr buffer_escritura,al;se completa con la mitad del ascii que le faltaba
			call escribir_bin;se escribe
			mov b,1;para indicar que en la siguiente lectura debe saltarse medio byte
			
			 mov AX, 4201h
			 mov CX, 0FFFFh
			 mov DX, 0FFFFh
			 int 21h;mover el fp una posicion hacia atras
			 
			 pop dx
			 pop cx
			 pop bx
			 pop ax
			 ret
		escribir_medio_byte endp






                                                                             
 inicio: 
		 mov ax,ds
		 mov es,ax
			
		 mov ax, ds
         mov es, ax

         mov ax, datos
         mov ds, ax

         mov ax, pila
         mov ss, ax
		 
		 mov si,80h
		 mov al,byte ptr es:[si]
		 cmp al,0
		 je ayuda_conejo_conejo;la entrada esta vacia,se mostrara la ayuda
		 mov longitud,al ;mueve la longitud de la entrada
		 inc si
 determinar_opciones:
		 inc si;para que apunte al primer caracter
		 mov al,es:[si];para no tener que acceder a memoria en todas las comparaciones
		 cmp al,' ';si es espaciador debe buscar el siguiente caracter
		 je determinar_opciones
		 cmp al,09h;tab horizontal
		 je determinar_opciones
		 cmp al,0Bh; tab vertical
		 je determinar_opciones
		 cmp al,'-'
		 je opciones_programa
		 lea bx,error_msg_opcioninvalida;no se incluyeron opciones
		 jmp errores
		 
 opciones_programa:
		 call mensajes_iniciales;rutina que muestra los mensajes iniciales
		 inc si
		 mov al,es:[si]
		 or al,00100000b;convertir la letra a minuscula
		 cmp al,'a'
		 je ayuda_conejo;salta a donde se muestra la ayuda
		 cmp al,'c';salta a donde se comprimen los archivos
		 je comprimir
		 cmp al,'d'
		 je descomprimir_conejo;salta a donde se descomprimen los archivos
		 lea bx,error_msg_opcioninvalida;mueve a dx el puntero del mensaje de error que se mostrara
		 jmp errores
		 ayuda_conejo_conejo:
			jmp ayuda_conejo
		 
 comprimir: 
		 mov tipo_operacion,0;para indicar que es una compresion
		 call agregar_terminacion;mueve el nombre del archivo a la variable pathname y tal vez le agrega la terminacion
		 mov ah,3dh
		 lea dx,pathname
		 mov al,0
		 int 21h
		 lea bx,error_msg_nombreinvalido;pone en bx el puntero al mensaje de error por si ocurre un error
		 jc errores_conejo
		 mov handle,ax
		 call contar_caracteres
		 call top15

		 mov ah,3eh
		 mov bx,handle
		 int 21h;cerrar archivo a comprimir para poder volver a tener el fp al inicio del archivo
		 mov ah,3dh
		 mov al,0
		 lea dx,pathname
		 int 21h;abrir el archivo 
		 mov handle,ax
		 ;aqui ya se tiene la tabla con el top15 
		 call cambiar_formato;cambia el formato del pathname de txt a rlp
		 mov ah,3ch
		 lea dx,pathname_sinformato
		 mov cx,2;atributo de lectura escritura
		 int 21h;crear el archivo donde se pondran los datos comprimidos
		 mov handle2,ax
		 call escribir_archivo;escribira en el nuevo archivo los datos
		 jmp comprimir_continuar
		 errores_conejo:
			jmp errores
		 descomprimir_conejo:
			jmp descomprimir
		ayuda_conejo:
			jmp ayuda_msg
		 comprimir_continuar:

		 mov ax,contador; escribir el tamano antes de comprimir
		 call numero_ascii
		 lea dx,tamano_antes
		 mov ah,09h
		 int 21h
		 lea dx,numero_bien
		 mov ah,09h
		 int 21h
		 call arregla_numero_bien;arregla los valores de numero_bien
		 mov ah,02h
		 mov dl,'B'
		 int 21h
		 mov dl,0dh
		 int 21h
		 mov dl,0ah
		 int 21h

		 mov ax,cont_salida;escribir tamano despues de comprimir
		 call numero_ascii
		 mov ah,02h
		 lea dx,tamano_despues
		 mov ah,09h
		 int 21h 
		 lea dx,numero_bien
		 mov ah,09h
		 int 21h
		 call arregla_numero_bien
		 mov ah,02h
		 mov dl,'B'
		 int 21h
		 mov dl,0dh
		 int 21h
		 mov dl,0ah
		 int 21h


		 mov ax,cont_salida
		 mov bx,100
		 mul bx
		 mov bx,contador
		 cmp bx,0 
		 je infinito
		 div bx
		 mov flotante,dx
		 call numero_ascii;la parte entera quedo en el ax, entonces se puede llamar a numero_ascii sin hacer nada mas
		 mov ah,09h
		 lea dx,tasa_compresion
		 int 21h
		 lea dx,numero_bien;parte entera del porcentaje 
		 int 21h
		 call arregla_numero_bien
		 mov ah,02h
		 mov dl,'.'
		 int 21h
		 mov bx,100
		 mov ax,flotante
		 mul bx
		 mov bx,cont_salida
		 div bx
		 call numero_ascii;el punto flotante queda en el ax, solo se debe imprimir
		 mov ah,09h
		 lea dx,numero_bien;parte flotante del porcentaje
		 int 21h
		 call arregla_numero_bien
		 mov ah,02h
		 mov dl,0dh
		 int 21h
		 mov dl,0ah
		 int 21h
		 call imprimir_top15
		 jmp salida;elproceso se realizo con exito
		 infinito:
		 lea dx, tasa_compresion
		 mov ah,09h
		 int 21h
		 lea dx,tasa_infinito
		 int 21h
		 jmp salida
 descomprimir:
		 mov tipo_operacion,1 
		 call agregar_terminacion
		 mov ax,3d00h
		 lea dx,pathname
		 int 21h;abrir el archivo que se descomprimira
		 lea bx,error_msg_fallolectura
		 jc errores;hubo errores en la apertura del archivo
		 mov handle,ax
		 
		 call cambiar_formato
		 mov ah,3ch
		 lea dx,pathname_sinformato;pathname del txt donde se descomprimira
		 mov cx,2;atributo de r/w
		 int 21h;crea el archivvo
		 lea bx,error_msg_fallolectura
		 jc errores
		 mov handle2,ax
		 call descodificacion
		 
		 
		 mov ah,09h
		 lea dx,success_msg_descomprimir
		 int 21h
		 jmp salida
 
 errores:
		 mov ah,09h
		 lea dx,error_msg
		 int 21h
		 mov dx,bx
		 int 21h
		 jmp salida
		 
 ayuda_msg:
		 mov ah,09h
		 lea dx,ayuda
		 int 21h
		 lea dx,ayuda2
		 int 21h
		 lea dx,ayuda3
		 int 21h
		 lea dx,ayuda4
		 int 21h
		 lea dx,ayuda5
		 int 21h
		 lea dx,ayuda6
		 int 21h
		 lea dx,ayuda7
		 int 21h
		 jmp salida

    salida:
		 mov ax, 4C00h
         int 21h

     
 codigo ends

 end inicio