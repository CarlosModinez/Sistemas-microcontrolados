; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 12/03/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declarações EQU - Defines
;<NOME>         EQU <VALOR>
NUMEROS_ALEATORIOS EQU 0x20000000
NUMEROS_PRIMOS EQU 0x20000100

; -------------------------------------------------------------------------------
; Área de Dados - Declarações de variáveis
		AREA  DATA, ALIGN=2
		; Se alguma variável for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a variável <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma variável de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posição da RAM		

; -------------------------------------------------------------------------------
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma função do arquivo for chamada em outro arquivo	
        EXPORT Start                ; Permite chamar a função Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		; Se chamar alguma função externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; função <func>
entrada DCB 193, 63, 176, 127, 43, 19, 211, 3, 203, 5, 21, 127, 206, 245, 157, 237, 241, 105, 252, 19;

; -------------------------------------------------------------------------------
; Função main()
Start  
; Comece o código aqui <======================================================
	MOV R10, #20; Tamanho do vetor
	MOV R9, #0; Contador	
	MOV R4, #0 ;Contador de numeros primos
	
	LDR R0, =entrada  ; R0 -> Endereco do vetor de de entrada de números aleatórios
	LDRB R1, [R0] ; R1 -> Valor da primeira posicao do vetor
	
	LDR R2, =NUMEROS_ALEATORIOS
	STRB R1, [R2] ; Escrevendo R1 na primeira posicao do vetor da RAM
	CMP R1, #0  ;Se O valor do vetor for 0, acabou o vetor 
	BL iterar
	BL encontrar_numeros_primos ; Funcao que popula o vetor NUMEROS_PRIMOS com os numeros primos da lista de aleatorios
	
	
iterar ;Salva o vetor na RAM (NUMEROS_ALEATORIOS)
	LDRB R1, [R0], #1
	STRB R1, [R2], #1
	ADD R9, #1
	CMP R10, R9
	PUSH{LR}
	BLNE iterar
	POP{LR}
	BX LR
	
	
encontrar_numeros_primos
	MOV R10, #2 ;Primeiro divisor
	LDR R0, = NUMEROS_ALEATORIOS
	LDRB R1, [R0]  ;Numero que quero checar
	LDR R2, =NUMEROS_PRIMOS
	BLCC comparar;
 
comparar
	CMP R1,R10
	BCS verificar_primo
	CMP R1,R10
	BCC adicionar_numero
	
verificar_primo
	UDIV R5, R1, R10 
	MUL R5, R10
	SUB R6, R1, R5
	
	CMP R6, #0
	IT EQ
		ADDEQ R7, #1
		
	ADD R10, #1
	B comparar
	
adicionar_numero
	MOV R10, #2
	CMP R7, #1
	ITT EQ 
		STRBEQ R1, [R2], #1
		ADDEQ R4, #1
	
	LDRB R1, [R0], #1
	LDRB R1, [R0]
	MOV R7, #0
	CMP R1, #0
	BNE comparar	
	B ordenar_vetor


ordenar_vetor
	LDR R0, =NUMEROS_PRIMOS 
	LDRB R1, [R0, R10] 
	LDRB R2, [R0, R9] 
	MOV R10, #0 ; counter i 
	;a = R!
	;b = R2
	;aux = R3


	B for_i
	
for_i
	CMP R10, R4 ;Compara i com o tamanho do vetor
	BHS fim 
	
	LDRB R1, [R0, R10]  
	MOV R9, R10 ;counter j  (j >= i)
	B for_j
	
for_j
	LDRB R2, [R0, R9] ; b[j]
	CMP R1, R2 ;if a < b -> realiza a troca
	ITTTT LO
		STRBLO R2, [R0, R10] ; Escrevendo R1 na posicao R10 do vetor da RAM
		STRBLO R1, [R0, R9]
		LDRBLO R1, [R0, R10] 
		LDRBLO R2, [R0, R9] 
	
	CMP R9, R4 ;compara j com o tamanho do vetor
	ITEE HS 
		ADDHS R10, #1
		ADDLO R9, #1
		BLO for_j
		
	B for_i

	
fim
	MOV R0, #0
	NOP
    ALIGN                           ; garante que o fim da seção está alinhada 
    END                             ; fim do arquivo
