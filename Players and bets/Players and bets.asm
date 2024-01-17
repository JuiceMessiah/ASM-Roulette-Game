.ORIG x0500

;JSSR R1, PlayerAmountSR Når vi skal samle mother document

LEA R0, PROMT
    PUTS
    GETC
    OUT
    LD R1, TOINT     ; Vi konvertere næste input til decimal
    ADD R1, R0, R1
    ST R1, TotalPlayers
JSR PlayerAmount
spinAgain
LD R5, TheWheelSR
JSRR R5  ; Modtag værdi for hjulet i register
JSR Prize
BRnzp spinAgain
HALT

PlaceBetOnWheel
        ST R0, Save000 
        ST R1, Save001
        ST R2, Save002
        ST R7, Save007
        
        LD R0, BetNumber1
        PUTS
        
        GETC
        OUT 
        LD R1, TOINT     ; Vi konverterer næste input til decimal
        ADD R1, R0, R1
        STR R1, R5, #0
        LD R0, Save000 
        LD R1, Save001
        LD R2, Save002
        LD R7, Save007
        
        RET


PlayerAmount
        ST R0, Save00 
        ST R1, Save01
        ST R2, Save02
        ST R4, Save04
        ST R7, Save07
        LD R2, Players
        LD R4, Balances
        LD R5, WheelBets
        LD R3, Bets
        
    cycle  
        JSR PlayerCreate
        ADD R2, R2, #12
        ADD R4, R4, #1
        ADD R5, R5, #1
        ADD R3, R3, #1
        
        ADD R1, R1, #-1 ;værdi til antal spilere decrementet
        BRp cycle
        LD R7, Save07
        LD R0, Save00
        LD R1, Save01
        LD R2, Save02
        LD R4, Save04
        
        RET

PlayerCreate
        ;Gemmer registres værdier i memory
        ST R0, Save0 
        ST R1, Save1
        ST R2, Save2
        ST R3, Save3
        ST R4, Save4
        ST R5, Save5
        ST R7, Save7

        LEA R0, INTRO   ; Loader intro
        PUTS            ; Viser intro på terminal
        
        AND R3, R3, #0  ; Nulstiller R3
        ADD R3, R3, #10 ; Lægger 10 over i R3
       
    STOREPLAYER
        GETC            ; Modtag input fra keyboard
        OUT             ; Viser output i terminal
        ADD R4, R0, #-10; For at give R4 inputtet "ENTER" fra keyboard i ASCII
        BRz NameDone
        
        STR R0, R2, #0  ; Lægger inputtet fra R0 ind i R2
        ADD R2, R2, #1  ; Lægger 1 til inputtet for at tage næste addresse.
        ADD R3, R3, #-1 ; Decrementer loop op til 10 gange
        BRp STOREPLAYER
    
    NameDone    
        LEA R0, DepositBalance  ; Loader number promt
        PUTS
        GETC
        OUT
        LD R4,TOINT     ; Vi konvertere fra ASCII til integer/decimal
        ADD R0, R4, R0  ; Lægger inputtet til den konverterede værdi for at få det rigtige input
        ADD R1, R0, #0  ; Vi lægger inputtet over i R1
        
        
    StoreBalance
        ADD R5, R1, #0  ; Vi lægger inputtet over i R5, som er total
        GETC
        OUT
        ADD R3, R0, #-10; Vi tjekker for "ENTER"
        BRz DONE
        LD R3,TOINT     ; Vi konvertere næste input til decimal
        ADD R0, R3, R0  ; Lægger inputtet til den konverterede værdi for at få det rigtige input
        AND R3, R3, #0  
        ADD R3, R3, #9  ; Lægger 9 til R3
        
        
    TIMES10
        ADD R1, R1, R5  ; Vi kører loopet 9 gange 
        
        ADD R3, R3, #-1 ; Decrementer counter
        BRp TIMES10
        ADD R1, R0, R1  ; Vi lægger total sammen med inputtet
        BRnzp StoreBalance
    
    DONE
        LD R4, Save4
        STR R1, R4, #0  ; Store total i Balance
        LD R5, Save5
        JSR PlaceBet
        JSR PlaceBetOnWheel
        
        LD R0, Save0
        LD R1, Save1
        LD R2, Save2
        LD R3, Save3
        LD R4, Save4
        LD R5, Save5
        LD R7, Save7
        RET
        
PlaceBet
        ST R0, Save000 
        ST R1, Save001
        ST R3, Save003
        ST R5, Save005
        ST R7, Save007
    
    Again        
        LEA R0, DepositBet
        PUTS
        GETC
        OUT 
        LD R1, TOINT     ; Vi konverterer næste input til decimal
        ADD R1, R0, R1
    
    StoreBet
        ADD R5, R1, #0  ; Vi lægger inputtet over i R5, som er total
        GETC
        OUT
        ADD R3, R0, #-10; Vi tjekker for "ENTER"
        BRz Done1
        LD R3,TOINT     ; Vi konvertere næste input til decimal
        ADD R0, R3, R0  ; Lægger inputtet til den konverterede værdi for at få det rigtige input
        AND R3, R3, #0  
        ADD R3, R3, #9  ; Lægger 9 til R3
        
        
    Times10Bet
        ADD R1, R1, R5  ; Vi kører loopet 9 gange 
        
        ADD R3, R3, #-1 ; Decrementer counter
        BRp Times10Bet
        ADD R1, R0, R1  ; Vi lægger total sammen med inputtet
        BRnzp StoreBet
        
    Done1
        LDR R2, R4, #0  ; balance ind fra memory
        NOT R2, R2      ;inverterer balance
        ADD R2, R2, #1  ; Lægger 1 til pga. offset
        ADD R2, R2, R1 ; tjekker for deposit er mindre en
        Brp Again
        LD R3, Save3
        STR R1, R3, #0  
        NOT R2, R2      ;inverterer balance
        ADD R2, R2, #1
        STR R2, R4, #0
        LD R5, Save5
        
        
        LD R0, Save000 
        LD R1, Save001
        LD R3, Save003
        LD R5, Save005
        LD R7, Save007
        RET
   
Prize

	ST R1, Save1 
	ST R2, Save2
	ST R3, Save3
	ST R4, Save4
	ST R5, Save5
	ST R6, Save6
	ST R7, Save7	

        LD R6, TotalPlayers 
        LD R4, Balances
        ST R0, Result
        LD R1, WheelBets
        LD R3, Bets

    LoopPlayers  
        LD R0, Result
        LDR R2, R1, #0 ;loader bet
        
        NOT R2, R2      ;inverterer bet
        ADD R2, R2, #1
        ADD R2, R0, R2
        
        BRnp Lost1
        
        LDR R2, R3, #0  ; bets ind fra memory
        ADD R5, R2, #0  ; Lægger R2's værdi over i R5 når vi skal addere prize, Ellers vil det stige eksponentielt. 
        ADD R0, R0, #-1 ; Decrementer R0 og sætter værdien ind i R4 - Maks antal loop 
    Loop
        ADD R2, R2, R5  
        ADD R0, R0, #-1
        BRnp Loop
        
        LDR R0, R4, #0 ; loader balance
        ADD R0, R2, R0 ; Winner value bliver lagt sammen med balance
        STR R0, R4, #0 ; Nye værdi bliver gemt i balance
	LD R0, WinText 
	PUTS
        BRnzp Finish
   
    Lost1        
        LD R0, LossText
        PUTS
    
    Finish    
        ADD R4, R4, #1 ;Inkrementer addresser
        ADD R3, R3, #1
        ADD R1, R1, #1
        ADD R6, R6, #-1 ;Decreament addresse 
        BRp LoopPlayers
	LD R1, Save1 
	LD R2, Save2
	LD R3, Save3
	LD R4, Save4
	LD R5, Save5
	LD R6, Save6
	LD R7, Save7	
        RET

    TheWheelSR .FILL x1000
    Balances .FILL Balance1
    Bets .FILL Bet1
    WheelBets .FILL WheelBet1
    Players .FILL PlayerOne
    BetNumber1 .FILL BetNumber
    TOINT .FILL x-30
    TotalPlayers .BLKW 1
    WinText .FILL Won
    LossText .FILL Loss
    Result .BLKW 1
   
    Save000 .BLKW 1
    Save001 .BLKW 1
    Save002 .BLKW 1
    Save003 .BLKW 1
    Save005 .BLKW 1
    Save007 .BLKW 1
      
    Save0 .BLKW 1
    Save1 .BLKW 1
    Save2 .BLKW 1
    Save3 .BLKW 1
    Save4 .BLKW 1
    Save5 .BLKW 1
    Save6 .BLKW 1
    Save7 .BLKW 1
    
    Save00 .BLKW 1
    Save01 .BLKW 1
    Save02 .BLKW 1
    Save03 .BLKW 1
    Save04 .BLKW 1
    Save07 .BLKW 1
    
    Balance1 .BLKW 1
    Balance2 .BLKW 1
    Balance3 .BLKW 1
    Balance4 .BLKW 1
    
    Bet1 .BLKW 1
    Bet2 .BLKW 1
    Bet3 .BLKW 1
    Bet4 .BLKW 1
    
    WheelBet1 .BLKW 1
    WheelBet2 .BLKW 1
    WheelBet3 .BLKW 1
    WheelBet4 .BLKW 1
    
    PROMT .STRINGZ "\nHow many Players are playing from 1-4?\n"
    INTRO   .STRINGZ "\nPlease enter your player name:\n"
    DepositBalance .STRINGZ "\nPlease enter your Balance:\n"
    DepositBet .STRINGZ "\nHow much money do you want to bet\n"
    BetNumber .STRINGZ "\nWhich number do you want to bet on? 1-6\n"

    
    Won .STRINGZ "\nCongratulations, You have won!\n"
    Loss .STRINGZ "\nYou have lost. Better luck next time!\n"
    
    PlayerOne   .BLKW 12
    PlayerTwo   .BLKW 12
    PlayerThree .BLKW 12
    PlayerFour  .BLKW 12
    
    
.END