.ORIG x1000

    ; JSR TheWheel
    ; HALT

TheWheel 
    
    ST R1, save1
    ST R2, save2
    ST R3, save3
    ST R4, save4
    ST R5, save5
    ST R6, save6
    ST R7, save7
    
    AND R5, R5, #0
    ADD R5, R5, #15         ; Giver R5 værdien 15, for at kunne loope 15 gange senere
    LEA R1, ARRAY           ; Loader addressen på ARRAY ind i R1
    LD R6, sixteen          ; Henter -16 ind i R6
    
    ;repeat                  ; For at køre ind
        
    LD R2, delay            ;Loader værdien fra delay ind i R2
    
    defaultValue
        LDI R3, physicalSwitches
        AND R4, R3, #1      ; Bruger AND for at se hvilket bit er value 1, her er det for at tjekke 0001
        BRnz psw2
        LD R2, delay
        BRnzp LOOPARRAY     ; Kører ned til LOOPARRAY med den givne delay i dette tilfælde, og starter hjulet		
        
    psw2
        AND R4, R3, #2      ; For at tjekke 0010
        BRnz psw3  
        LD R2, delay2
        BRnzp LOOPARRAY     ; Kører ned til LOOPARRAY med den givne delay i dette tilfælde, og starter hjulet	
    psw3
        AND R4, R3, #4      ; For at tjekke 0100
        BRnz psw4 
        LD R2, delay3
        BRnzp LOOPARRAY     ; Kører ned til LOOPARRAY med den givne delay i dette tilfælde, og starter hjulet	
    psw4
        AND R4, R3, #8      ; For at tjekke 1000
        BRnz defaultValue
        LD R2, delay4       ; Sidste form for "fart" på hjulet

    LOOPARRAY
        
        LDR R0, R1, #0      ; Henter værdien på addresse "ARRAY", og ligger ind i R0
        STI R0, hexDisplay  ; Gemmer værdien fra addresse "xFE12", og ligger ind R0
        JSR delaySub
        ;ADD R2, R2, #15     ;Delay bliver 15 større
        ADD R1, R1, #1      ; Inkrementere i ARRAY
        ADD R5, R5, #-1     ; -1 på counter
        BRp skip            ; Så længe counteren ikke er nul
        ADD R5, R5, #15     ; Refiller counteren med 15
        LEA R1, ARRAY       ; Loader addressen på ARRAY ind i R1
    skip
                            ; Subroutine for for tjekke om spacebar er trykket ned
        LDI R3, buttons     ; Henter værdien fra buttons (xFE0E), og ligger det ind R3
        AND R3, R3, R6      ; Vi tjekker om spacebar er trykket, ved at minusse med 16, på værdien i buttons
        BRz LOOPARRAY       ; Går først videre når den er 0
    
    delayLoop
        
        LDR R0, R1, #0      ; Henter værdien på addresse "ARRAY", og ligger ind i R0
        STI R0, hexDisplay  ; Gemmer værdien fra addresse "xFE12", og ligger ind R0
        JSR delaySub
        ADD R2, R2, #15     ;Delay bliver 15 større
        ADD R1, R1, #1      ; Inkrementere i ARRAY
        ADD R5, R5, #-1     ; -1 på counter
        BRp skip1            ; Så længe counteren ikke er nul
        ADD R5, R5, #15     ; Refiller counteren med 15
        LEA R1, ARRAY       ; Loader addressen på ARRAY ind i R1
    
    skip1
        LD R3, maxDelay
        NOT R3, R3
        ADD R3, R3, #1
        ADD R3, R3, R2
        BRnz delayLoop
        
    done 
	ADD R1, R0, #0	       ; Hjulets værdi ligges over i R1
	LEA R0, resultString   
	PUTS		       ; Printer resultString, som printer resultat af hvad hjulet ender på
	LD R3, toAscii         ; Konverterer om til ASCII værdi, da værdien er i Hex           
	ADD R0, R1, R3	       ; Ligger den konverteret sammen med den ukonverteret værdi, og ender med resultatet i ASCII på R0
	OUT
	ADD R0, R1, #0
        LD R1, save1
        LD R2, save2
        LD R3, save3
        LD R4, save4
        LD R5, save5
        LD R6, save6
        LD R7, save7
        RET

; Vores ARRAY, med bestemte værdier

ARRAY    .fill #1       ;Fylder array med værdier
         .fill #2
         .fill #3
         .fill #4
         .fill #5
         .fill #1
         .fill #2
         .fill #3
         .fill #4    
         .fill #5
         .fill #6
         .fill #1
         .fill #2
         .fill #3
         .fill #4

physicalSwitches    .fill xFE0B
sixteen             .fill x10   
toAscii             .fill x30
buttons             .fill xfe0e
hexDisplay          .fill xfe12
ms                  .FILL xFE1C
delay	            .FILL #70
delay2              .FILL #150
delay3              .FILL #275
delay4              .FILL #500
maxDelay            .FILL #1000
string              .STRINGZ "DelayReached\n"

save0   .BLKW 1
save1   .BLKW 1
save2   .BLKW 1
save3   .BLKW 1
save4   .BLKW 1
save5   .BLKW 1
save6   .BLKW 1
save7   .BLKW 1
save01  .BLKW 1
save03  .BLKW 1
save07  .BLKW 1


delaySub
    ST R1, save01
    ST R3, save03
    ST R7, save07
    
    LDI R1, ms      ;Loader værdien fra ms ind i R1
    ADD R1, R1, R2  ;Ligger de to værdier sammen, ligger delay oveni
    NOT R1, R1      ;Notter den ene af dem for at kunne trække fra
    ADD R1, R1, #1  ;Ligger en til pga. Tour-compliment
        
    masterDelay
    
        LDI R3, ms      ;Loader værdien fra ms ind i R1
        ADD R3, R1, R3  ;Delay og antal millisekunder bliver lagt sammen
        BRn masterDelay ;Bliver ved med at branche hvis det er en minus værdi
        
        
        LD R1, save01
        LD R3, save03
        LD R7, save07
        RET


resultString	   .STRINGZ "\nWheel result is: "


        
.END