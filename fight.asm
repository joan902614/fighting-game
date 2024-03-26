.org 	0000H
ljmp    main
.org	0003H
    acall    External_Interrupt_0
    reti    

.org    000BH
    mov     R7,B
    cjne    R7,#1,long
    cpl 	P1.2	; complement the IO-bit that relates the buzzer 
	mov 	TH0,#0xFB 	  ; setting counter to 200 ticks
    mov 	TL0,#0x50
    reti
long:
    acall Timer0
.org    0100H
main:
    acall	INIT_LCD
    mov     R5, #0
    acall   fightlcd
    acall   startlcd  
    mov     IE, #81H
    mov     B,#0
Loop:
    mov     R7,B
    cjne    R7,#1,Loop
    acall	INIT_LCD
    mov		TMOD, #0x01  
    mov 	TH0,#0xFB 	  ; setting counter to 200 ticks
    mov 	TL0,#0x50
	mov		IE, #0x82	  ; allow timer interrupt
    mov R4, #0
    acall loo001
    mov R2,#03H
    mov R3,#0BH
    mov R0,#0
    mov R1,#0
    acall   Clear
peo:
    ;score
    acall score

    mov  A,R0
    clr C
    subb A,#9
    lcall longr
    mov  A,R1
    clr C
    subb A,#9
    lcall longl

    ;people
    acall   peoplep

    ;keyboard    
    acall   key
    mov    R7,A
    mov     A,R7
    clr     C
    subb    A, #1BH
    jz      forwardl
    mov     A,R7
    clr     C
    subb    A, #1CH
    jz      backwardl
    mov     A,R7
    clr     C
    subb    A, #3BH
    jz      forwardr
    mov     A,R7
    clr     C
    subb    A, #42H
    jz      backwardr
    mov     A,R7
    clr     C
    subb    A, #15H
    jz      attackl
    mov     A,R7
    clr     C
    subb    A, #43H
    jz      attackr
    mov     A,R7
    clr     C
    subb    A, #F0H
    jz      wait
    ajmp    peo

wait:
    acall   key
    ajmp    peo
forwardl:
    acall sound
    acall closer
    jz      wait
    inc R2
    acall   Clear
    ajmp    peo
backwardl:
    acall sound
    mov     A,R2
    clr     C
    subb    A,#1 
    jz      wait
    dec R2
    acall   Clear
    ajmp    peo
forwardr:
    acall sound
    acall closer
    jz      wait
    dec R3
    acall   Clear
    ajmp    peo
backwardr:
    acall sound
    mov     A,R3
    clr     C
    subb    A,#13 
    jz      wait
    inc R3
    acall   Clear
    ajmp    peo
attackl:
    acall closer
    jz    scorel

    mov R4,#0
    acall loo002 
    acall   Clear
    acall   peoplep
    acall score
    acall   sound
    mov     A,#3
    acall   _DELAY1
    mov R4,#0
    acall loo001
    acall   Clear
    ajmp    peo
attackr:
    acall closer
    jz    scorer

    mov R4,#0
    acall loo003 
    acall   Clear
    acall   peoplep
    acall score
    acall   sound
    mov     A,#3
    acall   _DELAY1
    mov R4,#0
    acall loo001
    acall   Clear
    ajmp    peo
scorel:
    inc R1
    mov R4,#0
    acall loo002 
    acall   Clear
    mov A,R2
    acall printposision1
    mov R4,#00h
    mov R5,#01h
    acall   peolcd
    mov A,R2
    acall printposision2
    mov R4,#02h
    mov R5,#03h
    acall   peolcd

    mov A,R3
    acall printposision1
    mov R4,#0b11111111
    mov R5,#0b11111111
    acall   peolcd
    mov A,R3
    acall printposision2
    mov R4,#0b11111111
    mov R5,#0b11111111
    acall   peolcd

    acall score
    acall   sound
    mov     A,#3
    acall   _DELAY1
    mov R4,#0
    acall loo001
    acall   Clear
    ajmp    peo
scorer:
    inc R0
    mov R4,#0
    acall loo003 
    acall   Clear
    mov A,R2
    acall printposision1
    mov R4,#0b11111111
    mov R5,#0b11111111
    acall   peolcd
    mov A,R2
    acall printposision2
    mov R4,#0b11111111
    mov R5,#0b11111111
    acall   peolcd

    mov A,R3
    acall printposision1
    mov R4,#04h
    mov R5,#05h
    acall   peolcd
    mov A,R3
    acall printposision2
    mov R4,#06h
    mov R5,#07h
    acall   peolcd
    acall score
    acall   sound
    mov     A,#3
    acall   _DELAY1
    mov R4,#0
    acall loo001
    acall   Clear
    ajmp    peo


longr:
    jz winr
    ret
longl:
    jz winl
    ret
winl:  
    acall winlcd
    printwin:
    mov     dptr, #STRING6  
    mov     A, R0
    movc    A, @A+dptr
    mov	    dptr, #8001H
    acall   WAIT_DISP_READY
    movx    @dptr, A
    inc     R0
    cjne    R0, #8, printwin
    mov A, #100
    acall   _DELAY1
    ajmp main
winr:
    acall winlcd
    printwin:
    mov     dptr, #STRING7 
    mov     A, R0
    movc    A, @A+dptr
    mov	    dptr, #8001H
    acall   WAIT_DISP_READY
    movx    @dptr, A
    inc     R0
    cjne    R0, #8, printwin
    mov A, #100
    acall   _DELAY1
    ajmp main
closer:
    mov A,R3
    clr C
    subb    A,R2
    clr     C
    subb    A, #2
    ret
sound:
    setb	TR0
    mov     A,#5
    acall   _DELAY1
    clr     TR0
 ret

winlcd:
    mov R0,#0
    mov A, #100
    acall   _DELAY1
    acall Clear
    mov     A,#4
    acall printposision1
    ret
    
peolcd:
	mov	dptr,#8001H	
	mov	A,R4		;中
    acall   WAIT_DISP_READY
	movx	@dptr,A	
	mov	A,R5		;正
    acall   WAIT_DISP_READY
	movx	@dptr,A	
    ret
printposision1:
    mov		dptr, #8000H
	add		A, #80H
    acall   WAIT_DISP_READY
	movx	@dptr, A
    ret
printposision2:
    mov		dptr, #8000H
	add		A, #c0H
    acall   WAIT_DISP_READY
	movx	@dptr, A
    ret


loo001: 
	;指派CGRAM
     mov 	DPTR, #8000H
     mov 	A, #40h
	 add 	A, R4
     acall	WAIT_DISP_READY
     movx 	@dptr, A
     mov 	A, R4
	 ;data
	 mov 	DPTR,#data1
     movc 	A, @A+dptr
     mov 	DPTR, #8001H
     acall   WAIT_DISP_READY
     movx 	@dptr, A
     
     inc R4
     cjne R4,#70,loo001
    ret
loo002: 
	;指派CGRAM
     mov 	DPTR, #8000H
     mov 	A, #40h
	 add 	A, R4
     acall	WAIT_DISP_READY
     movx 	@dptr, A
     mov 	A, R4
	 ;data
	 mov 	DPTR,#data2
     movc 	A, @A+dptr
     mov 	DPTR, #8001H
     acall   WAIT_DISP_READY
     movx 	@dptr, A
     
     inc R4
     cjne R4,#70,loo002
    ret
loo003: 
	;指派CGRAM
     mov 	DPTR, #8000H
     mov 	A, #40h
	 add 	A, R4
     acall	WAIT_DISP_READY
     movx 	@dptr, A
     mov 	A, R4
	 ;data
	 mov 	DPTR,#data3
     movc 	A, @A+dptr
     mov 	DPTR, #8001H
     acall   WAIT_DISP_READY
     movx 	@dptr, A
     
     inc R4
     cjne R4,#70,loo003
    ret

peoplep:
    mov A,R2
    acall printposision1
    mov R4,#00h
    mov R5,#01h
    acall   peolcd
    mov A,R2
    acall printposision2
    mov R4,#02h
    mov R5,#03h
    acall   peolcd
    mov A,R3
    acall printposision1
    mov R4,#04h
    mov R5,#05h
    acall   peolcd
    mov A,R3
    acall printposision2
    mov R4,#06h
    mov R5,#07h
    acall   peolcd
 ret
score:
    mov A,#0
    acall printposision1
    mov     dptr, #STRING5
    mov     A,R0
    movc    A, @A+dptr
    mov	    dptr, #8001H
    acall   WAIT_DISP_READY
    movx    @dptr, A
    mov A,#FH
    acall printposision1
    mov     dptr, #STRING5
    mov     A,R1
    movc    A, @A+dptr
    mov	    dptr, #8001H
    acall   WAIT_DISP_READY
    movx    @dptr, A
 ret
key:
    push ACC                   
    mov A, R0
    push ACC
    push PSW
    mov R0, #11                   ;1 byte 11 clock cycles: start, data (8), parity, stop
    mov  A, #0
    mov TL0, A
    mov TH0, A
    setb p1.1                   ;allow keyboard to send data
    bigloop:
     wait0:
      jnb p1.1, wait0   ; await falling edge
     mov C, p1.0         ; read data bit
     mov A, TH0
     rrc A
     mov TH0, A
     mov A, TL0
     rrc A
     mov TL0, A
     wait1:              ; await rising edge
      jb p1.1, wait1
     djnz R0, bigloop
    clr p1.1                   ; one byte sent -> stop keyboard from sending more
    pop PSW                     ; restore registers
    pop ACC
    mov R0, A
    pop ACC
    mov A ,TL0
    rlc a
    mov A ,TH0
    rlc a

    ret


printposision1:
    mov		dptr, #8000H
	add		A, #80H
    acall   WAIT_DISP_READY
	movx	@dptr, A
    ret
printposision2:
    mov		dptr, #8000H
	add		A, #c0H
    acall   WAIT_DISP_READY
	movx	@dptr, A
    ret


fightlcd:
	mov		A, #0
    acall   printposision1

    mov     R1, #0
 printfight1:
    mov     dptr, #STRING1
    mov     A, #25
    clr     C
    subb    A, R5
    add     A, R1
    movc    A, @A+dptr
    mov	    dptr, #8001H
    acall   WAIT_DISP_READY
    movx    @dptr, A
    
    inc     R1
    mov     A, R1
    mov     0x03, R5
    inc     0x03
    cjne    A, 0x03, printfight1

    mov     A, #15
    clr     C
    subb    A, R5
    acall   printposision2

    mov     R2, #0
 printfight2:
    mov     dptr, #STRING2 
    mov     A, R2
    movc    A, @A+dptr
    mov	    dptr, #8001H
    acall   WAIT_DISP_READY
    movx    @dptr, A
    
    inc     R2
    mov     A, R2
    mov     0x03, R5
    inc     0x03
    cjne    A, 0x03, printfight2

    mov     A, #25
    acall   _DELAY
    acall   Clear

    inc     R5
    cjne    R5, #25,fightlcd
    ret

startlcd:
    mov		A, #0
    acall   printposision1

    mov     R1, #0
 printstart1:
    mov     dptr, #STRING3 
    mov     A, R1
    movc    A, @A+dptr
    mov	    dptr, #8001H
    acall   WAIT_DISP_READY
    movx    @dptr, A
    inc     R1
    cjne    R1, #16, printstart1

	mov		A, #04H
    acall   printposision2

    mov     R1, #17
 printstart2:
    mov     dptr, #STRING3 
    mov     A, R1
    movc    A, @A+dptr
    mov	    dptr, #8001H
    acall   WAIT_DISP_READY
    movx    @dptr, A
    inc     R1
    cjne    R1, #25, printstart2

    ret 

External_Interrupt_0:
    acall	INIT_LCD
    mov	    TH0,#184
	mov	    TL0,#0
	mov	    TMOD, #0x01
	mov	    IE, #0x82
	setb	TR0	
    mov     A, #0	
    mov     R1, #ffH
    ret
Timer0:
    inc     A
    cjne    A, #100, endTimer0

    inc     R1
    mov		A, #07H
    acall   printposision1
    mov     A, R1
    mov		dptr, #STRING4
    movc    A, @dptr+A
    mov		dptr, #8001H
    acall   WAIT_DISP_READY
	movx	@dptr, A
    
    mov     A, #0
    cjne    R1, #3, endTimer0
 stop:
    clr    TR0
    mov		A, #05H
    acall   printposision1
  printstart:
    mov     dptr, #STRING4
    mov     A, R1
    movc    A, @A+dptr
    mov	    dptr, #8001H
    acall   WAIT_DISP_READY
    movx    @dptr, A
    inc     R1
    cjne    R1, #8, printstart
    mov     B,#1
    mov     A,#50
    acall   _DELAY
    ret
 endTimer0:  
    mov     TH0, #184 
    mov     TL0, #0
    ret


_DELAY:
	mov R0, A
_DELAY_I:
	mov R1, #100		;R1 = 100
_DELAY_J:
	mov R2, #100		;R2 = 100
_DELAY_K:
	djnz R2, _DELAY_K	;if(--R2 != 0) goto DELAY_K
	djnz R1, _DELAY_J	;if(--R1 != 0) goto DELAY_J
	djnz R0, _DELAY_I	;if(--R0 != 0) goto DELAY_I
	
	ret
_DELAY1:
	mov R4, A
_DELAY_I1:
	mov R5, #100		;R1 = 100
_DELAY_J1:
	mov R6, #100		;R2 = 100
_DELAY_K1:
	djnz R6, _DELAY_K1	;if(--R2 != 0) goto DELAY_K
	djnz R5, _DELAY_J1	;if(--R1 != 0) goto DELAY_J
	djnz R4, _DELAY_I1	;if(--R0 != 0) goto DELAY_I
	
	ret
WAIT_DISP_READY:                        
	push 	dph
	push 	dpl
	push 	acc
WAIT_DISP_READY_I:
    mov 	dptr, #8002h
    movx	A, @dptr
    jb 		Acc.7, WAIT_DISP_READY_I
    pop 	acc
	pop 	dpl
	pop		dph

    ret


INIT_LCD:
	; write instruction register
	mov		dptr,#8000H	

	; Set 8-bit I/O, display in 2 line
	mov		A,#38H		
	acall	WAIT_DISP_READY
	movx 	@dptr,A	

	;Set no display cursor, no flashing
	mov		A,#0CH		
	acall   WAIT_DISP_READY
	movx	@dptr,A

	;Set move cursor in each write to the right, no shift
	mov		A,#06H		
	acall   WAIT_DISP_READY
	movx	@dptr,A
Clear:
    mov		dptr,#8000H	
	mov		A,#01H		
	acall   WAIT_DISP_READY
	movx	@dptr,A

	ret


STRING1:
    .db "                 xxFightxx"
STRING2:
    .db "xxFightxx                 "
STRING3:
    .db "Press the button to start"
STRING4:
    .db "321start"
STRING5:
    .db "9876543210"
STRING6:
    .db "~1P win~"
STRING7:
    .db "~2P win~"
data1:	

    .db 00000000b  ;left up walking 1
    .db 00000000b  
    .db 00000000b
    .db 00000000b
    .db 00000000b
    .db 00000011b
    .db 00000100b
    .db 00001000b

    .db 00000000b ;right up walking 1
    .db 00000110b
    .db 00001111b
    .db 00000110b
    .db 00001100b
    .db 00011100b
    .db 00011100b
    .db 00011010b

    .db 00010001b ;left down walking 1
    .db 00000001b
    .db 00000010b
    .db 00000100b
    .db 00001000b
    .db 00010000b
    .db 00010000b
    .db 00000000b

    .db 00010001b ;right down walking 1
    .db 00010000b
    .db 00010000b
    .db 00001000b
    .db 00000100b
    .db 00000111b
    .db 00000000b
    .db 00000000b

    .db 00000000b  ;left up walking 1
    .db 00001100b  
    .db 00011110b
    .db 00001100b
    .db 00000110b
    .db 00000111b
    .db 00000111b
    .db 00001011b

    .db 00000000b ;right up walking 1
    .db 00000000b
    .db 00000000b
    .db 00000000b
    .db 00000000b
    .db 00011000b
    .db 00000100b
    .db 00000010b

    .db 00010001b ;left down walking 1
    .db 00000001b
    .db 00000001b
    .db 00000010b
    .db 00000100b
    .db 00011100b
    .db 00000000b
    .db 00000000b

    .db 00010000b ;right down walking 1
    .db 00010000b
    .db 00001000b
    .db 00000100b
    .db 00000010b
    .db 00000001b
    .db 00000001b
    .db 00000000b

data2:

    .db 00000000b ;left up
    .db 00000001b
    .db 00000011b
    .db 00000001b
    .db 00000001b
    .db 00000011b
    .db 00000101b
    .db 00000011b

    .db 00000000b ;right up
    .db 00010000b
    .db 00011000b
    .db 00010000b
    .db 00000101b
    .db 00011001b
    .db 00010001b
    .db 00010010b
    
    .db 00000001b ;left down
    .db 00000011b
    .db 00000110b
    .db 00000100b
    .db 00001000b
    .db 00010000b
    .db 00011100b
    .db 00000000b
    
    .db 00010100b ;right down
    .db 00011000b
    .db 00000000b
    .db 00000000b
    .db 00000000b
    .db 00000000b
    .db 00000000b
    .db 00000000b

    .db 00000000b  ;left up walking 1
    .db 00001100b  
    .db 00011110b
    .db 00001100b
    .db 00000110b
    .db 00000111b
    .db 00000111b
    .db 00001011b

    .db 00000000b ;right up walking 1
    .db 00000000b
    .db 00000000b
    .db 00000000b
    .db 00000000b
    .db 00011000b
    .db 00000100b
    .db 00000010b

    .db 00010001b ;left down walking 1
    .db 00000001b
    .db 00000001b
    .db 00000010b
    .db 00000100b
    .db 00011100b
    .db 00000000b
    .db 00000000b

    .db 00010000b ;right down walking 1
    .db 00010000b
    .db 00001000b
    .db 00000100b
    .db 00000010b
    .db 00000001b
    .db 00000001b
    .db 00000000b

data3:

    .db 00000000b  ;left up walking 1
    .db 00000000b  
    .db 00000000b
    .db 00000000b
    .db 00000000b
    .db 00000011b
    .db 00000100b
    .db 00001000b

    .db 00000000b ;right up walking 1
    .db 00000110b
    .db 00001111b
    .db 00000110b
    .db 00001100b
    .db 00011100b
    .db 00011100b
    .db 00011010b

    .db 00010001b ;left down walking 1
    .db 00000001b
    .db 00000010b
    .db 00000100b
    .db 00001000b
    .db 00010000b
    .db 00010000b
    .db 00000000b

    .db 00010001b ;right down walking 1
    .db 00010000b
    .db 00010000b
    .db 00001000b
    .db 00000100b
    .db 00000111b
    .db 00000000b
    .db 00000000b

    .db 00000000b ;left up
    .db 00000001b
    .db 00000011b
    .db 00000001b
    .db 00010100b
    .db 00010011b
    .db 00010001b
    .db 00001001b

    .db 00000000b ;right up
    .db 00010000b
    .db 00011000b
    .db 00010000b
    .db 00010000b
    .db 00011000b
    .db 00010100b
    .db 00011000b
    
    .db 00000101b ;left down
    .db 00000011b
    .db 00000000b
    .db 00000000b
    .db 00000000b
    .db 00000000b
    .db 00000000b
    .db 00000000b
    
    .db 00010000b ;right down
    .db 00011000b
    .db 00001100b
    .db 00000100b
    .db 00000010b
    .db 00000001b
    .db 00000111b
    .db 00000000b


.end