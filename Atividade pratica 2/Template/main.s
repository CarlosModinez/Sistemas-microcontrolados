; main.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; Ver 1 19/03/2018
; Ver 2 26/08/2018
; Este é um projeto template.


; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
		
; Declarações EQU - Defines
;<NOME>         EQU <VALOR>
; ========================
; Definições de Valores


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
		IMPORT  PLL_Init
		IMPORT  SysTick_Init
		IMPORT  SysTick_Wait1ms			
		IMPORT  GPIO_Init
		IMPORT 	PortJ_Input
		IMPORT 	PortF_Output
		IMPORT	PortN_Output
			
cavaleiroN DCB 0x2, 0x1, 0, 0, 0, 0x1;
cavaleiroF DCB 0, 0, 0x10, 0x1, 0x10, 0;

contadorN DCB 0, 0, 0, 0, 0x1, 0x1, 0x1, 0x1, 0x2, 0x2, 0x2, 0x2, 0x3, 0x3, 0x3, 0x3;
contadorF DCB 0, 1, 0x10, 0x11, 0,  1, 0x10, 0x11, 0, 1, 0x10, 0x11, 0, 1, 0x10, 0x11;

velocidades DCW 1000, 500, 200;
; -------------------------------------------------------------------------------
; Função main()
Start  		
	BL PLL_Init                 
	BL SysTick_Init              
	BL GPIO_Init                
	
	LDR  	R5, =velocidades
	MOV 	R4, #0  ;contador de velocidades 
	
	MOV 	R9, #0		;Modo de operacao - 0 para cavaleiro e 1 para contador
	LDRH 	R10, [R5] 	;Velocidade: 1000, 500, ou 200
	MOV 	R11, #0		;Estado do algoritmo do passeio
	MOV 	R12, #0		;Estado do contador
	
MainLoop
	CMP R9, #0
	BLEQ Passeio_do_cavaleiro
	BL Contador
	;BL PortJ_Input				 
			
		  	 	
Passeio_do_cavaleiro
	LDR R8, =cavaleiroN
	LDR R7, =cavaleiroF
	
	LDRB R0, [R8, R11]
	BL PortN_Output
	LDRB R0, [R7, R11]
	BL PortF_Output
	MOV R0, R10                ;Chamar a rotina para esperar 0,5s
	BL SysTick_Wait1ms
	
	CMP R11, #5
	ITE HS
		MOVHS R11, #0
		ADDLO R11, #1
	
	
	BL PortJ_Input
	CMP R0, #2_11
	BNE Verifica_SW1
	
	B MainLoop



Contador
	LDR R8, =contadorN
	LDR R7, =contadorF
	
	LDRB R0, [R8, R12]
	BL PortN_Output
	LDRB R0, [R7, R12]
	BL PortF_Output
	MOV R0, R10                ;Chamar a rotina para esperar 0,5s
	BL SysTick_Wait1ms
	
	CMP R12, #15
	ITE HS
		MOVHS R12, #0
		ADDLO R12, #1
		
	BL PortJ_Input
	
	CMP R0, #2_11
	BNE Verifica_SW1
	
	B MainLoop
	

Verifica_SW1
	CMP R0, #2_01
	BNE Verifica_SW2
	
	MOV R0, #100
	PUSH{LR}
	BL SysTick_Wait1ms
	POP{LR}
	CMP R4, #4
	ITE HS
		MOVHS R4, #0
		ADDLO R4, #2
		
	
	LDRH R10, [R5, R4]
	B MainLoop

Verifica_SW2
	CMP R0, #2_10
	BNE MainLoop
	
	MOV R0, #100
	PUSH{LR}
	BL SysTick_Wait1ms
	POP{LR}
	
	CMP R9, #0
	ITE EQ
		MOVEQ R9, #1
		MOVNE R9, #0
	
	B MainLoop
	
; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN                        ;Garante que o fim da seção está alinhada 
    END                          ;Fim do arquivo
