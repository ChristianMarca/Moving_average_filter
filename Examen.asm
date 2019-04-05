
_map:
	LNK	#0

;Examen.c,12 :: 		unsigned map(unsigned x, unsigned in_min, unsigned in_max, unsigned out_min, unsigned out_max)
; out_max start address is: 4 (W2)
	MOV	[W14-8], W2
;Examen.c,14 :: 		return (unsigned)((x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min);
	SUB	W10, W11, W1
	SUB	W2, W13, W0
; out_max end address is: 4 (W2)
	MUL.UU	W1, W0, W4
	SUB	W12, W11, W2
	REPEAT	#17
	DIV.U	W4, W2
	ADD	W0, W13, W0
;Examen.c,15 :: 		}
L_end_map:
	ULNK
	RETURN
; end of _map

_configuracion_incial:

;Examen.c,16 :: 		void configuracion_incial(){
;Examen.c,17 :: 		PORTB = 0x0000;
	CLR	PORTB
;Examen.c,18 :: 		TRISB.F1 = 1;       // set pin as input - needed for ADC to work
	BSET	TRISB, #1
;Examen.c,19 :: 		Chip_Select = 1;                       // Deselect DAC
	BSET	LATF0_bit, BitPos(LATF0_bit+0)
;Examen.c,20 :: 		Chip_Select_Direction = 0;             // Set CS# pin as Output
	BCLR	TRISF0_bit, BitPos(TRISF0_bit+0)
;Examen.c,21 :: 		SPI1_Init();                           // Initialize SPI module
	CALL	_SPI1_Init
;Examen.c,23 :: 		pos=M-1;
	MOV	_M, W1
	MOV	#lo_addr(_pos), W0
	SUB	W1, #1, [W0]
;Examen.c,24 :: 		cont=0;
	CLR	W0
	MOV	W0, _cont
;Examen.c,25 :: 		}
L_end_configuracion_incial:
	RETURN
; end of _configuracion_incial

_DAC_Output:

;Examen.c,26 :: 		void DAC_Output(unsigned int valueDAC) {
;Examen.c,29 :: 		Chip_Select = 0;                       // Select DAC chip
	BCLR	LATF0_bit, BitPos(LATF0_bit+0)
;Examen.c,32 :: 		temp = (valueDAC >> 8) & 0x0F;         // Store valueDAC[11..8] to temp[3..0]
	LSR	W10, #8, W0
	AND	W0, #15, W0
;Examen.c,33 :: 		temp |= 0x30;                          // Define DAC setting, see MCP4921 datasheet
	ZE	W0, W1
	MOV	#48, W0
	IOR	W1, W0, W0
;Examen.c,34 :: 		SPI1_Write(temp);                      // Send high byte via SPI
	PUSH	W10
	ZE	W0, W10
	CALL	_SPI1_Write
	POP	W10
;Examen.c,38 :: 		SPI1_Write(temp);                      // Send low byte via SPI
	ZE	W10, W10
	CALL	_SPI1_Write
;Examen.c,40 :: 		Chip_Select = 1;                       // Deselect DAC chip
	BSET	LATF0_bit, BitPos(LATF0_bit+0)
;Examen.c,41 :: 		}
L_end_DAC_Output:
	RETURN
; end of _DAC_Output

_main:
	MOV	#2048, W15
	MOV	#6142, W0
	MOV	WREG, 32
	MOV	#1, W0
	MOV	WREG, 52
	MOV	#4, W0
	IOR	68
	LNK	#2

;Examen.c,42 :: 		void main() {
;Examen.c,43 :: 		configuracion_incial();
	PUSH	W10
	CALL	_configuracion_incial
;Examen.c,44 :: 		while (1) {
L_main0:
;Examen.c,47 :: 		if (cont >= M-1){
	MOV	_M, W0
	SUB	W0, #1, W1
	MOV	#lo_addr(_cont), W0
	CP	W1, [W0]
	BRA LE	L__main12
	GOTO	L_main2
L__main12:
;Examen.c,49 :: 		datos[M-1]=ADC1_Read(1);
	MOV	_M, W0
	DEC	W0
	SL	W0, #1, W1
	MOV	#lo_addr(_datos), W0
	ADD	W0, W1, W0
	MOV	W0, [W14+0]
	MOV	#1, W10
	CALL	_ADC1_Read
	MOV	[W14+0], W1
	MOV	W0, [W1]
;Examen.c,50 :: 		suma=0;
	CLR	W0
	MOV	W0, _suma
;Examen.c,51 :: 		for(i=0;i<=M-1;i++){
	CLR	W0
	MOV	W0, _i
L_main3:
	MOV	_M, W0
	SUB	W0, #1, W1
	MOV	#lo_addr(_i), W0
	CP	W1, [W0]
	BRA GE	L__main13
	GOTO	L_main4
L__main13:
;Examen.c,52 :: 		suma=suma+datos[i];
	MOV	_i, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_datos), W0
	ADD	W0, W1, W0
	MOV	[W0], W1
	MOV	#lo_addr(_suma), W0
	ADD	W1, [W0], [W0]
;Examen.c,53 :: 		if(i>=1){
	MOV	_i, W0
	CP	W0, #1
	BRA GE	L__main14
	GOTO	L_main6
L__main14:
;Examen.c,54 :: 		datos[i-1]=datos[i];
	MOV	_i, W0
	DEC	W0
	SL	W0, #1, W1
	MOV	#lo_addr(_datos), W0
	ADD	W0, W1, W2
	MOV	_i, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_datos), W0
	ADD	W0, W1, W0
	MOV	[W0], [W2]
;Examen.c,55 :: 		}
L_main6:
;Examen.c,51 :: 		for(i=0;i<=M-1;i++){
	MOV	#1, W1
	MOV	#lo_addr(_i), W0
	ADD	W1, [W0], [W0]
;Examen.c,56 :: 		}
	GOTO	L_main3
L_main4:
;Examen.c,57 :: 		prom=(float)(suma/M);
	MOV	_suma, W0
	MOV	_M, W2
	REPEAT	#17
	DIV.U	W0, W2
	CLR	W1
	CALL	__Long2Float
	MOV	W0, _prom
	MOV	W1, _prom+2
;Examen.c,58 :: 		}
	GOTO	L_main7
L_main2:
;Examen.c,61 :: 		datos[cont]=ADC1_Read(1);
	MOV	_cont, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_datos), W0
	ADD	W0, W1, W0
	MOV	W0, [W14+0]
	MOV	#1, W10
	CALL	_ADC1_Read
	MOV	[W14+0], W1
	MOV	W0, [W1]
;Examen.c,62 :: 		cont=cont+1;
	MOV	#1, W1
	MOV	#lo_addr(_cont), W0
	ADD	W1, [W0], [W0]
;Examen.c,63 :: 		}
L_main7:
;Examen.c,64 :: 		DAC_Output(prom);
	MOV	_prom, W0
	MOV	_prom+2, W1
	CALL	__Float2Longint
	MOV	W0, W10
	CALL	_DAC_Output
;Examen.c,66 :: 		}
	GOTO	L_main0
;Examen.c,67 :: 		}
L_end_main:
	POP	W10
	ULNK
L__main_end_loop:
	BRA	L__main_end_loop
; end of _main
