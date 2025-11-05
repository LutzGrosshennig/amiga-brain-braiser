;***********************************************
;*                                             *
;*        BRAIN BRAISER  ( DENK SPIEL )        *
;*                                             *
;*          AUTOR : Lutz Großhennig            *
;*                                             *
;*     100% ASSEMBLER ( PROFIMAT AMIGA )       *
;*                                             *
;*        ERSTELLUNG DATUM : 22.05.90          *
;*                                             *
;*        FERTIGSTELLUNG   : 29.06.90          *
;*                                             *
;*               VERSION 1.0                   *
;*                                             *
;***********************************************

; OFFSETS EXEC

OPENLIBRARY    = -408
CLOSELIBRARY   = -414
ALLOCMEM       = -198
FREEMEM        = -210
FORBID         = -132
PERMIT         = -138
WAIT           = -318
GETMSG         = -372
FINDTASK       = -294
WAITPORT       = -384
REPLYMSG       = -378

; OFFSETS INTUITION

OPENSCREEN     = -198
CLOSESCREEN    = -066
OPENWINDOW     = -204
CLOSEWINDOW    = -072
DRAWIMAGE      = -114

; OFFSETS GRAPHICS

DRAW           = -246
MOVETO         = -240
SETAPEN        = -342
SETBPEN        = -348
RECTFILL       = -306
LOADRGB4       = -192
PRINTTEXT      = -060
MOVESPRITE     = -426
FREESPRITE     = -414
SETRGB4        = -288
SETDRMD        = -354

; KONSTANTEN

EXECBASE       = 4
MOUSEBUTTON    = $BFE001
VHPOSR         = $DFF006
INTENA         = $DFF09A
KEYBOARD       = $BFEC01
REQUEST        = $10001

CTLW           = $DFF096
C0THI          = $DFF0A0
C0TLO          = $DFF0A2
C0TL           = $DFF0A4
C0PER          = $DFF0A6
C0VOL          = $DFF0A8

;---------  MACROS  -----------------------------------------

WRITE_TEXT:MACRO *\TEXT,%\LAENGE,%\X,%\Y

       PEN_TO  \X,\Y
       LEA     \TEXT,A0
       MOVEQ   #\LAENGE,D0
       JSR     PRINTTEXT(A6)
       ENDM

SHADOW_WRITE:MACRO *\TEXT,%\COUNT,%\X,%\Y,%\COL

       PEN_COLOR 0
       WRITE_TEXT \TEXT,\COUNT,\X,\Y
       PEN_COLOR \COL
       WRITE_TEXT \TEXT,\COUNT,\X-2,\Y-2
       ENDM

DRAW_MODE:MACRO %\MODE

       MOVE.L  GFXBASE,A6              ; JAM1 = 0
       MOVE.L  RASTPORT,A1             ; JAM2 = 1
       MOVEQ   #\MODE,D0               ; COMP = 2
       JSR     SETDRMD(A6)             ; INVE = 4
       ENDM

OPENLIB:MACRO *\NANE,*\BASE

       MOVE.L  EXECBASE,A6
       LEA     \NANE,A1
       JSR     OPENLIBRARY(A6)
       MOVE.L  D0,\BASE
       ENDM

CLOSELIB:MACRO *\BASE

       MOVE.L  EXECBASE,A6
       MOVE.L  \BASE,A1
       JSR     CLOSELIBRARY(A6)
       ENDM

OPENSCR:MACRO  *\SCREENDEVS,*\HD

       MOVE.L  INTBASE,A6
       LEA     \SCREENDEVS,A0
       JSR     OPENSCREEN(A6)
       MOVE.L  D0,\HD
       ADD.L   #44,D0
       MOVE.L  D0,VIEWPORT
       ADD.L   #40,D0
       MOVE.L  D0,RASTPORT
       ENDM

CLOSESCR:MACRO *\HD

       MOVE.L  INTBASE,A6
       MOVE.L  \HD,A0
       JSR     CLOSESCREEN(A6)
       ENDM

OPENWIND:MACRO *\WINDOWDEVS,*\HD

       MOVE.L  INTBASE,A6
       LEA     \WINDOWDEVS,A0
       JSR     OPENWINDOW(A6)
       MOVE.L  D0,\HD
       MOVE.L  D0,A0
       MOVE.L  50(A0),RASTPORT
       ENDM

CLOSEWIND:MACRO *\HD

       MOVE.L  INTBASE,A6
       MOVE.L  \HD,A0
       JSR     CLOSEWINDOW(A6)
       ENDM

PEN_TO:MACRO %\X,%\Y

       MOVE.W  #\X,D0
       MOVE.W  #\Y,D1
       BSR     MOVE_PEN_TO
       ENDM
   
DRAWTO:MACRO %\X,%\Y

       MOVE.W  #\X,D0
       MOVE.W  #\Y,D1
       JSR     DRAW(A6)
       ENDM

LINE:MACRO %\X1,%\Y1,%\X2,%\Y2

       PEN_TO  \X1,\Y1
       DRAWTO  \X2,\Y2
       ENDM

DO_3D_BOX:MACRO %\X1,%\Y1,%\X2,%\Y2,%\COLOR

       BOX     \X1,\Y1,\X2,\Y2,\COLOR
       PEN_COLOR 1
       LINE    \X1,\Y1,\X2,\Y1
       LINE    \X1,\Y1,\X1,\Y2
       LINE    \X1+1,\Y1,\X1+1,\Y2-1
       PEN_COLOR 4
       LINE    \X2,\Y1+1,\X2,\Y2
       LINE    \X2-1,\Y1+2,\X2-1,\Y2
       LINE    \X1+1,\Y2,\X2,\Y2
       ENDM

DO_SHADOW_BOX:MACRO %\X1,%\Y1,%\X2,%\Y2,%\COLOR

       BOX     \X1,\Y1,\X2,\Y2,0
       PEN_COLOR 4
       LINE    \X1,\Y1,\X2,\Y1
       LINE    \X1,\Y1,\X1,\Y2
       LINE    \X1-1,\Y1,\X1-1,\Y2-1
       PEN_COLOR 1
       LINE    \X2,\Y1+1,\X2,\Y2
       LINE    \X2+1,\Y1+2,\X2+1,\Y2
       LINE    \X1+1,\Y2,\X2,\Y2
       ENDM

PEN_COLOR:MACRO %\COLOR

       MOVEQ   #\COLOR,D0
       BSR     SET_A_PEN
       ENDM

BOX:MACRO %\X1,%\Y1,%\X2,%\Y2,%\COLOR

       PEN_COLOR \COLOR
       MOVE.W  #\X1,D0
       MOVE.W  #\Y1,D1
       MOVE.W  #\X2,D2
       MOVE.W  #\Y2,D3
       JSR     RECTFILL(A6)
       ENDM

SCREEN_COL:MACRO *\TAB,%\NR

       MOVE.L  GFXBASE,A6
       MOVE.L  VIEWPORT,A0
       LEA     \TAB,A1
       MOVEQ   #\NR,D0
       JSR     LOADRGB4(A6)
       ENDM

IMAGE:MACRO *\POINTER,%\X,%\Y

       MOVE.L  INTBASE,A6
       MOVE.L  RASTPORT,A0
       LEA     \POINTER,A1
       MOVE.W  #\X,D0
       MOVE.W  #\Y,D1
       JSR     DRAWIMAGE(A6)
       ENDM

MONOTASKING:MACRO

       MOVE.L  EXECBASE,A6
       JSR     FORBID(A6)
       ENDM

MULTITASKING:MACRO

       MOVE.L  EXECBASE,A6
       JSR     PERMIT(A6)
       ENDM

INIT_AMIGA:MACRO

       MOVE.L  SP,INT_SP
       MOVE.L  EXECBASE,A6
       SUBA.L  A1,A1
       JSR     FINDTASK(A6)
       MOVE.L  D0,OWN_TASK
       MOVE.L  D0,A4
       TST.L   172(A4)
       BNE     \1

       LEA     92(A4),A0
       JSR     WAITPORT(A6)
       LEA     92(A4),A0
       JSR     GETMSG(A6)
       MOVE.L  D0,WB_MSG
\1:
       ENDM

EXIT_AMIGA:MACRO

       TST.L   WB_MSG
       BEQ     \1
       MOVE.L  EXECBASE,A6
       JSR     FORBID(A6)
       MOVE.L  WB_MSG,A1
       JSR     REPLYMSG(A6)
\1:
       MOVEQ   #0,D0
       MOVE.L  INT_SP,SP
       RTS
       ENDM

; -- Hauptprogramm --

START:
  
       INIT_AMIGA

       OPENLIB INTNAME,INTBASE
       TST.L   D0
       BEQ     END2
       OPENLIB GFXNAME,GFXBASE
       TST.L   D0
       BEQ     END1

       OPENSCR    SCREENDEVS,SCREENHD
       TST.L   D0
       BEQ     END3
       SCREEN_COL SCREEN_COLORS,8

SET_UP:
       MOVE.L  #0,SCORE
       MOVE.L  #0,SCORE2
       MOVE.L  #SPIELFELD,MAPPOINTER
       MOVE.W  #0,PLAYER
       MOVE.W  #0,SP_X
       MOVE.W  #0,ZAEHLER
       MOVE.W  #40,SP_Y
       MOVE.W  #2,XPOS
       MOVE.W  #40,YPOS
       MOVE.W  #0,BLOCK_X


       MOVE.L  RASTPORT,DUMMYRASTPORT
       OPENWIND WINDOWDEVS,WINDOWHD
       TST.L   D0
       BEQ     END4
       DO_3D_BOX 0,0,399,199,5
       DO_3D_BOX 50,20,150,100,5
       DO_3D_BOX 250,20,350,100,5

       DO_3D_BOX 50,120,150,135,5
       DO_3D_BOX 250,120,350,135,5
       DO_3D_BOX 180,120,220,135,5

       DO_SHADOW_BOX 167,169,233,178,0

       DRAW_MODE 0

       SHADOW_WRITE SETTEXT1,8,68,45,1
       SHADOW_WRITE SETTEXT4,5,80,65,1
       SHADOW_WRITE SETTEXT3,5,80,85,1

       SHADOW_WRITE SETTEXT1,8,268,45,1
       SHADOW_WRITE SETTEXT4,5,280,65,1
       SHADOW_WRITE SETTEXT2,8,268,85,1

       SHADOW_WRITE SETTEXT5,27,92,160,1

       SHADOW_WRITE SETTEXT1,8,68,115,2
       SHADOW_WRITE SETTEXT2,8,268,115,3

       SHADOW_WRITE KEYTEXT,8,68,132,2
       SHADOW_WRITE KEYTEXT,8,268,132,3

       SHADOW_WRITE JOYTEXT,9,164,115,1
       SHADOW_WRITE JOY1TEXT,1,198,132,1

       LEA     GADGET_DONE,A4
       BRA     WAIT_LOOP

SETUP_ENDE:
       CLOSEWIND WINDOWHD
       MOVE.L  DUMMYRASTPORT,RASTPORT

       SCREEN_COL SCREEN_BLACK,8

       MONOTASKING

       BSR     BUILD_UP_SCREEN
       BSR     BUILD_PLAYFIELD
       BSR     BUILD_UP

       BSR     WRITE_SCORE
       BSR     WRITE_SCORE_2

       SCREEN_COL SCREEN_COLORS,8

       MOVE.L  STRDA,D0
       MOVE.W  D0,TIMEBASE
       MOVE.W  TIMEBASE,TIME

       BSR     INIT_IRQ

MAINLOOP:

       BSR     TEST_SPE_KEYS

       BTST    #2,PLAYER
       BNE     GAME_OVER

       BRA     MAINLOOP

ENDE:

       BSR     EXIT_IRQ
ENDE_2:
       BSR     FREE_POINTER

END4:  CLOSESCR  SCREENHD

END3:  CLOSELIB GFXBASE
END1:  CLOSELIB INTBASE
END2:
       MULTITASKING
     
       EXIT_AMIGA
;----------------------------------------------------------

TEST_SPE_KEYS:

       MOVE.B  KEYBOARD,D0
       CMP.B   #$75,D0
       BEQ     ESCAPE_GAME
       CMP.B   #$CD,D0
       BEQ     SET_PAUSE_MODE
       RTS

ESCAPE_GAME:
       BSET    #2,PLAYER
       RTS

SET_PAUSE_MODE:
       BCHG    #3,PLAYER
SET_PAUSE:
       CMP.B   #$CC,KEYBOARD
       BNE     SET_PAUSE
       RTS

;----------------------------------------------------------
MOVE_PEN_TO:
       MOVE.L  GFXBASE,A6
       MOVE.L  RASTPORT,A1
       JMP     MOVETO(A6)
SET_A_PEN:
       MOVE.L  GFXBASE,A6
       MOVE.L  RASTPORT,A1
       JMP     SETAPEN(A6)
SET_B_PEN:
       MOVE.L  GFXBASE,A6
       MOVE.L  RASTPORT,A1
       JMP     SETBPEN(A6)

;----------------------------------------------------------

GADGET_DONE:

       MOVE.W  $26(A1),D0
       CMP.W   #1,D0
       BEQ     HUMAN_HUMAN
       CMP.W   #2,D0
       BEQ     HUMAN_AMIGA
       CMP.W   #4,D0
       BEQ     P1_CHANGE_INPUT
       CMP.W   #5,D0
       BEQ     P2_CHANGE_INPUT
       CMP.W   #6,D0
       BEQ     CHANGE_JOYSTICKS
       BRA     WAIT_LOOP

HUMAN_HUMAN:

       BCLR    #1,PLAYER
       BRA     SETUP_ENDE

HUMAN_AMIGA:

       BSET    #1,PLAYER
       BRA     SETUP_ENDE

P1_CHANGE_INPUT:

       BTST    #4,PLAYER
       BNE     P1_JOY

       BSET    #4,PLAYER
       BSR     CLEAR_FIELD
       SHADOW_WRITE JOYTEXT,8,68,132,2
       BRA     WAIT_LOOP
P1_JOY:
       BCLR    #4,PLAYER
       BSR     CLEAR_FIELD
       SHADOW_WRITE KEYTEXT,8,68,132,2
       BRA     WAIT_LOOP

P2_CHANGE_INPUT:

       BTST    #5,PLAYER
       BNE     P2_JOY

       BSET    #5,PLAYER
       BSR     CLEAR_FIELD2
       SHADOW_WRITE JOYTEXT,8,268,132,3
       BRA     WAIT_LOOP
P2_JOY:
       BCLR    #5,PLAYER
       BSR     CLEAR_FIELD2
       SHADOW_WRITE KEYTEXT,8,268,132,3
       BRA     WAIT_LOOP


CLEAR_FIELD:
       BOX     52,122,148,133,5
       RTS
CLEAR_FIELD2:
       BOX     252,122,348,133,5
       RTS
CLEAR_FIELD3:
       BOX     185,122,205,133,5
       RTS

CHANGE_JOYSTICKS:

       BTST    #6,PLAYER
       BNE     JOY2

       BSET    #6,PLAYER
       BSR     CLEAR_FIELD3
       SHADOW_WRITE JOY2TEXT,1,198,132,1
       BRA     WAIT_LOOP
JOY2:
       BCLR    #6,PLAYER
       BSR     CLEAR_FIELD3
       SHADOW_WRITE JOY1TEXT,1,198,132,1
       BRA     WAIT_LOOP

;----------------------------------------------------------

GAME_OVER:

       BSR     EXIT_IRQ
       MULTITASKING

       MOVE.L  RASTPORT,DUMMYRASTPORT
       MOVE.L  #0,GADGET_2
       OPENWIND WINDOWDEVS,WINDOWHD
       TST.L   D0
       BEQ     END4
       DO_3D_BOX 0,0,399,199,5
       DO_3D_BOX 50,20,150,100,5
       DO_3D_BOX 250,20,350,100,5

       DRAW_MODE 0

       SHADOW_WRITE GAMETEXT5,7,272,65,1
       SHADOW_WRITE GAMETEXT6,7,72,55,1
       SHADOW_WRITE GAMETEXT7,7,72,75,1

       SHADOW_WRITE GAMETEXT1,17,112,140,2
       SHADOW_WRITE GAMETEXT2,17,112,160,3

       SHADOW_WRITE GAMETEXT8,9,164,120,1

       BSR     WINNER

       LEA     GADGET_ACTIVE,A4
       BRA     WAIT_LOOP

GADGET_ACTIVE:

       MOVE.W  $26(A1),D0
       CMP.W   #1,D0
       BEQ     NOCHMAL
       CMP.W   #2,D0
       BEQ     END_THE_GAME
       BRA     WAIT_LOOP

;----------------------------------------------------------

NOCHMAL:

       CLOSEWIND WINDOWHD
       MOVE.L  #GADGET_3,GADGET_2
       MOVE.L  DUMMYRASTPORT,RASTPORT
       BRA     SET_UP

END_THE_GAME:

       CLOSEWIND WINDOWHD
       MONOTASKING
       BRA       ENDE_2

WINNER:

       MOVE.L  SCORE,D0
       BSR     HEX_TO_ASCII
       BSR     CHANGE_WINNER
       SHADOW_WRITE SCORE_ASCII,4,256,140,2
       MOVE.L  SCORE2,D0
       BSR     HEX_TO_ASCII
       BSR     CHANGE_WINNER
       SHADOW_WRITE SCORE_ASCII,4,256,160,3

       MOVE.L  SCORE2,D0
       CMP.L   SCORE,D0
       BEQ     P1_GLEICH_P2
       CMP.L   SCORE,D0
       BLO     P1_G_P2
       CMP.L   SCORE,D0
       BHI     P1_K_P2
BACK_WINNER:
       RTS

P1_GLEICH_P2:

       SHADOW_WRITE GAMETEXT4,13,148,180,1
       BRA     BACK_WINNER
P1_G_P2:
       BSR     WRITE_GEWINNER
       SHADOW_WRITE SETTEXT1,8,216,180,2
       BRA     BACK_WINNER

P1_K_P2:
       BSR     WRITE_GEWINNER
       SHADOW_WRITE SETTEXT2,8,216,180,3
       BRA     BACK_WINNER

WRITE_GEWINNER:
       SHADOW_WRITE GAMETEXT3,10,120,180,1
       RTS

CHANGE_WINNER:
       LEA     SCORE_ASCII,A0
       MOVEQ   #3,D7
WINNER_LOOP:
       ADD.B   #48,(A0)+
       DBRA    D7,WINNER_LOOP
       RTS

;----------------------------------------------------------

WAIT_LOOP:
       MOVE.L  EXECBASE,A6
       MOVE.L  WINDOWHD,A0
       MOVE.L  86(A0),A0
       MOVE.L  A0,A5
       MOVE.B  $F(A0),D1
       MOVEQ   #0,D0
       BSET    D1,D0
       JSR     WAIT(A6)

       MOVE.L  A5,A0
       JSR     GETMSG(A6)
       TST.L   D0
       BEQ     WAIT_LOOP

       MOVE.L  D0,A0
       MOVE.L  $14(A0),D4
       MOVE.W  $18(A0),D5
       MOVE.L  $1C(A0),A1

       CMP.L   #$20,D4
       BEQ     GADGET_OK
       CMP.L   #$40,D4
       BEQ     GADGET_OK

       BRA     WAIT_LOOP

GADGET_OK:
       JMP     (A4)
;----------------------------------------------------------

BUILD_UP_SCREEN:
       DO_3D_BOX  0,0,639,22,5
       DO_3D_BOX  484,28,639,255,5

       DO_SHADOW_BOX 501,37,624,71,0
       DO_SHADOW_BOX 501,83,624,118,0
       DO_SHADOW_BOX 501,130,624,149,0

       BOX     0,39,443,243,7

       IMAGE   PLA1,502,38
       IMAGE   PLA2,502,84
       IMAGE   TIME_IM,502,131
       IMAGE   BRAIN_IM,231,2

       DRAW_MODE 0

       SHADOW_WRITE TEXT1,13,509,170,1
       SHADOW_WRITE TEXT2,17,495,185,1
       SHADOW_WRITE TEXT3,17,495,230,1
       SHADOW_WRITE TEXT4,15,505,245,1
       RTS

;----------------------------------------------------------

SOUND:                                 ; PERIODE IN D0

       MOVE.L  #SOUND_DATA,C0THI
       MOVE.W  #165,C0TL
       MOVE.W  #64,C0VOL
       MOVE.W  D0,C0PER

       MOVE.W  #$8201,CTLW
       RTS

;----------------------------------------------------------
JOYSTICK_LR:                           ; PLAYER 1

       MOVE.W  $DFF00C,D0
       BTST    #1,D0
       BNE     SP_RIGHT
       BTST    #9,D0
       BNE     SP_LEFT
       BTST    #7,$BFE001
       BEQ     SPACE1
       BRA     IRQ4

;----------------------------------------------------------

JOYSTICK_UD:                           ; PLAYER 2

       BTST    #6,PLAYER
       BNE     JOYSTICK_UD_2

       MOVE.W  $DFF00C,D0
       MOVE.W  D0,D1
       LSR.W   #1,D1
       EOR.W   D0,D1
       BTST    #0,D1
       BNE     SP_DOWN
       BTST    #8,D1
       BNE     SP_UP
       BTST    #7,$BFE001
       BEQ     SPACE
       BRA     IRQ4

;----------------------------------------------------------

JOYSTICK_UD_2:                         ; PLAYER 2
                                       ; 2 JOYSTICKS
       MOVE.W  $DFF00A,D0
       MOVE.W  D0,D1
       LSR.W   #1,D1
       EOR.W   D0,D1
       BTST    #0,D1
       BNE     SP_DOWN
       BTST    #8,D1
       BNE     SP_UP
       BTST    #6,$BFE001
       BEQ     SPACE
       BRA     IRQ4

;----------------------------------------------------------

INIT_IRQ:
       MOVE.W  #$4000,INTENA
       MOVE.L  $6C,OLDIRQ
       MOVE.L  #NEW_IRQ,$6C
       MOVE.W  #$C000,INTENA
       RTS

EXIT_IRQ:
       MOVE.W  #$4080,INTENA
       MOVE.L  OLDIRQ,$6C
       MOVE.W  #$C000,INTENA
       RTS

;----------------------------------------------------------
SPRITE_COLOR:
       MOVE.L  GFXBASE,A6
       MOVE.L  VIEWPORT,A0
       MOVEQ   #17,D0
       JMP     SETRGB4(A6)

;----------------------------------------------------------

BUILD_UP:
       LEA     SPIELFELD,A5
       MOVE.L  INTBASE,A6
       MOVEQ   #11,D6
BUILD_1:
       MOVEQ   #12,D7
       MOVE.W  #2,XPOS

BUILD_LOOP:
       BRA     GET_ADDRESS
BUILD3:
       MOVE.W  XPOS,D0
       MOVE.W  YPOS,D1
       BSR     DRAW_IT
BUILD2:
       ADD.W   #34,XPOS
       DBRA    D7,BUILD_LOOP
       ADD.W   #17,YPOS
       DBRA    D6,BUILD_1

       MOVE.W  #2,XPOS
       MOVE.W  #40,YPOS
       RTS

;----------------------------------------------------------

DRAW_IT:

       MOVE.L  RASTPORT,A0
       LEA     ACTION,A1
       JMP     DRAWIMAGE(A6)

;----------------------------------------------------------

GET_ADDRESS:
       MOVEQ   #0,D0
       MOVE.B  (A5)+,D0
       CMP.B   #20,D0
       BEQ     BUILD2

       ASL.L   #6,D0
       MOVE.L  #COUNT_DATA,D1
       ADD.L   D1,D0
       MOVE.L  D0,IM_PO
       BRA     BUILD3

GET_SCORE:
       MOVEQ   #0,D0
       MOVE.B  (A5)+,D0
       MOVEQ   #24,D1
       MULS    D1,D0
       MOVE.L  #SCORES,D1
       ADD.L   D1,D0
       MOVE.L  D0,SC_PO
       RTS

;----------------------------------------------------------

WRITE_SCORE:
       MOVE.L  SCORE,D0
       BSR     HEX_TO_ASCII

       MOVE.L  INTBASE,A6
       LEA     SCORE_ASCII,A5
       MOVEQ   #3,D7

SCORE_LOOP:
       BSR     GET_SCORE
       MOVE.W  SCORE_X,D0
       MOVE.W  SCORE_Y,D1
       BSR     SCORE_IT
       ADD.W   #10,SCORE_X
       DBRA    D7,SCORE_LOOP

       MOVE.W  #560,SCORE_X
       RTS

WRITE_SCORE_2:

       MOVE.L  SCORE2,D0
       BSR     HEX_TO_ASCII

       MOVE.L  INTBASE,A6
       LEA     SCORE_ASCII,A5
       MOVEQ   #3,D7

SCORE2_LOOP:
       BSR     GET_SCORE
       MOVE.W  SCORE_X,D0
       MOVE.W  SCORE_Y2,D1
       BSR     SCORE_IT
       ADD.W   #10,SCORE_X
       DBRA    D7,SCORE2_LOOP

       MOVE.W  #560,SCORE_X
       RTS

;----------------------------------------------------------

SCORE_IT:
       MOVE.L  RASTPORT,A0
       LEA     SCORE_IM,A1
       JMP     DRAWIMAGE(A6)

;----------------------------------------------------------

WRITE_TIME:

       MOVEQ   #0,D0
       MOVE.W  TIME,D0
       BSR     TIME_TO_ASCII

       MOVE.L  INTBASE,A6
       LEA     TIME_ASCII,A5
       MOVEQ   #3,D7

TIME_LOOP:
       BSR     GET_SCORE
       MOVE.W  TIME_X,D0
       MOVE.W  TIME_Y,D1
       BSR     SCORE_IT
       ADD.W   #10,TIME_X
       DBRA    D7,TIME_LOOP

       MOVE.W  #560,TIME_X
       RTS

;----------------------------------------------------------

RND:
       MOVEQ   #0,D0
       MOVE.W  VHPOSR,D0
       LSR.W   #8,D0
       MOVE.W  VHPOSR,D1
       EOR.B   D1,D0
       RTS

;----------------------------------------------------------

BUILD_PLAYFIELD:
       LEA     SPIELFELD,A0
       MOVE.L  #155,D7

PLAY_LOOP:
       BSR     RND
       CMP.B   #19,D0
       BHI     PLAY_LOOP
       MOVE.B  D0,(A0)+
       DBRA    D7,PLAY_LOOP
       RTS

;----------------------------------------------------------

CHANGE_VORZEICHEN:
       LEA     SPIELFELD,A0
       MOVE.L  #155,D7

CHANGE_LOOP:

       MOVE.B  (A0),D0
       CMP.B   #20,D0
       BEQ     WEITER
       CMP.B   #19,D0
       BEQ     WEITER
       CMP.B   #9,D0
       BEQ     WEITER

       MOVEQ   #18,D1
       SUB.B   D0,D1
       MOVE.B  D1,(A0)+
CHANGE_BACK:
       DBRA    D7,CHANGE_LOOP
       RTS

WEITER:
       ADDQ.L  #1,A0
       BRA     CHANGE_BACK

;----------------------------------------------------------

SET_POINTER:
       MOVE.L  GFXBASE,A6
       MOVE.L  VIEWPORT,A0
       LEA     SPRITE,A1
       MOVE.W  SP_X,D0
       MOVE.W  SP_Y,D1
       JMP     MOVESPRITE(A6)

FREE_POINTER:
       MOVE.L  GFXBASE,A6
       MOVEQ   #0,D0
       JMP     FREESPRITE(A6)

;----------------------------------------------------------

TEST_KEYS:
       MOVE.W  #0,ZAEHLER
       BRA     TEST_COLOUM             ; PLAYER 2
TEST2:
       BTST    #5,PLAYER
       BNE     JOYSTICK_UD

       MOVE.B  KEYBOARD,D0             
       CMP.B   #$67,D0                 ; CURSOR UP
       BEQ     SP_UP
       CMP.B   #$65,D0                 ; CURSOR DOWN
       BEQ     SP_DOWN
       CMP.B   #$7F,D0                 ; SPACEBAR
       BEQ     SPACE
       BRA     IRQ4

TEST_KEYS_1:        
       MOVE.W  #0,ZAEHLER              ; PLAYER 1
       BRA     TEST_ROW
TEST1:
       BTST    #4,PLAYER
       BNE     JOYSTICK_LR

       MOVE.B  KEYBOARD,D0
       CMP.B   #$37,D0                 ; ALT LEFT
       BEQ     SP_LEFT
       CMP.B   #$33,D0                 ; AMIGA LEFT
       BEQ     SP_RIGHT
       CMP.B   #$7F,D0                 ; SPACEBAR
       BEQ     SPACE1
       BRA     IRQ4

SP_UP:
       CMP.W   #40,SP_Y                ; INNERHALB DES FELDES ?
       BEQ     RAUS                    ; NEIN RAUS
       SUB.W   #17,SP_Y
       SUB.L   #13,MAPPOINTER
       SUBQ.B  #1,BLOCK_Y
       MOVE.W  #600,D0
       BSR     SOUND
       BRA     IRQ4

SP_DOWN:
       CMP.W   #227,SP_Y               ; INNERHALB DES FELDES ?
       BEQ     RAUS                    ; NEIN RAUS
       ADD.W   #17,SP_Y
       ADD.L   #13,MAPPOINTER
       ADDQ.B  #1,BLOCK_Y
       MOVE.W  #600,D0
       BSR     SOUND
       BRA     IRQ4

SP_LEFT:
       CMP.W   #0,SP_X                 ; INNERHALB DES FELDES ?
       BEQ     RAUS                    ; NEIN RAUS
       SUB.W   #34,SP_X
       SUBQ.L  #1,MAPPOINTER
       SUBQ.B  #1,BLOCK_X
       MOVE.W  #600,D0
       BSR     SOUND
       BRA     IRQ4

SP_RIGHT:
       CMP.W   #408,SP_X               ; INNERHALB DES FELDES ?
       BEQ     RAUS                    ; NEIN RAUS
       ADD.W   #34,SP_X
       ADDQ.L  #1,MAPPOINTER
       ADDQ.B  #1,BLOCK_X
       MOVE.W  #600,D0
       BSR     SOUND
       BRA     IRQ4

;----------------------------------------------------------
                                       ; PLAYER 2
SPACE:

       MOVE.L  MAPPOINTER,A0
       MOVEQ   #0,D0
       MOVE.B  (A0),D0

       CMP.B   #19,D0
       BEQ     GET_XTENS               ; XTENSION
       CMP.B   #9,D0
       BEQ     ZERO1                   ; ZEROPLAY
       CMP.B   #20,D0
       BEQ     BESETZT                 ; FELD IST BESETZT !

       SUB.L   #9,D0                   ; SCORE DES FELDES
       ADD.L   D0,SCORE2               ; ADDIEREN
       BMI     SET_ZERO2               ; WENN SCORE2 NEGATIV DANN 0
RETURN2:
       MOVE.B  #20,(A0)                ; FELD ALS BESETZT MARKIEREN
       BSR     WRITE_SCORE_2           ; NEUEN SCORE AUSGEBEN
DO_SPACE_BAR:
       PEN_COLOR 3                     ; FELD MIT PLAYER FARBE
       BSR     DO_BLOCK                ; AUSFÜLLEN
       BCLR    #0,PLAYER               ; PLAYER WECHSELT
       MOVE.W  TIMEBASE,TIME           ; UHR STELLEN
BESETZT:
       MOVE.W  #900,D0                 ; TASTATUR KLICKEN
       BSR     SOUND                   ; SETZEN
       BRA     IRQ4                    ; ZURÜCK

SET_ZERO2:
       MOVE.L  #0,SCORE                ; SCORE AUF 0 SETZEN
       BRA     RETURN2                 ; ZURÜCK

;----------------------------------------------------------

SPACE1:                                ; PLAYER 1

       MOVE.L  MAPPOINTER,A0           ; \
       MOVEQ   #0,D0                   ;  } AKTUELLEN FELD INHALT AUSLESEN
       MOVE.B  (A0),D0                 ; /
       CMP.B   #19,D0                  ; X-FELD ?
       BEQ     GET_XTENS1              ; DANN SCORES WECHSELN
       CMP.B   #9,D0                   ; 0-FELD ?
       BEQ     ZERO2                   ; DANN VORZ. WECHSEL
       CMP.B   #20,D0                  ; FELD BESETZT ?
       BEQ     BESETZT1                ; DANN RAUS

       SUB.L   #9,D0                   ; WERT DES FELDES
       ADD.L   D0,SCORE                ; ZUM SCORE ADDIREREN
       BMI     SET_ZERO1               ; SCORE NEGATIV ? NULL SETZEN
RETURN1:
       MOVE.B  #20,(A0)                ; FELD ALS BESETZT MARKIEREN
       BSR     WRITE_SCORE             ; NEUEN SCORE AUSGEBEN
DO_SPACE2:
       PEN_COLOR 2                     ; FELD MIT FARBE DES PLAYERS
       BSR     DO_BLOCK                ; AUSFÜLLEN
       BSET    #0,PLAYER               ; PLAYER WECHSELT
       MOVE.W  TIMEBASE,TIME           ; UHR STELLEN

BESETZT1:
RAUS:    
       MOVE.W  #900,D0                 ; FREQUENZ SETZEN
       BSR     SOUND                   ; TASTATUR KLICK
       BRA     IRQ4                    ; ZURÜCK

SET_ZERO1:
       MOVE.L  #0,SCORE                ; SCORE NULL SETZEN
       BRA     RETURN1                 ; ZURÜCK

;----------------------------------------------------------

GET_XTENS:
       BSR     GET_XTENSION            ; WECHSELN
       BRA     DO_SPACE_BAR            ; ZURÜCK
GET_XTENS1:
       BSR     GET_XTENSION            ; WECHSELN
       BRA     DO_SPACE2               ; ZURÜCK

GET_XTENSION:

       MOVE.B  #20,(A0)                ; FELD ALS BESETZT MAKIEREN
       MOVE.L  SCORE,D0                ; \
       MOVE.L  SCORE2,SCORE            ;  } SCORES  AUSTAUSCHEN
       MOVE.L  D0,SCORE2               ; /
       BSR     WRITE_SCORE             ; \ SCORES AUSGEBEN
       BSR     WRITE_SCORE_2           ; /
       RTS                             ; ZURÜCK

;----------------------------------------------------------

ZERO1:
       BSR     ZEROPLAY                ; VORZ. WECHSELN
       BRA     DO_SPACE_BAR            ; ZURÜCK
ZERO2:
       BSR     ZEROPLAY                ; VORZ. WECHSELN
       BRA     DO_SPACE2               ; ZURÜCK

ZEROPLAY:
       MOVE.B  #20,(A0)                ; FELD ALS BESETZT MAKIEREN
       BSR     CHANGE_VORZEICHEN       ; VORZEICHEN WECHSELN
       BSR     BUILD_UP                ; SPIELFELD NEU AUSGEBEN
       RTS                             ; ZURÜCK

;-----------------------------------------------------------

DO_BLOCK:
       MOVE.L  GFXBASE,A6              ; FÜLLT DAS AKTUELLE
       MOVE.L  RASTPORT,A1             ; FELD IN DER FARBE
       MOVEQ   #0,D0                   ; DES SPIELERS AUS
       MOVEQ   #0,D1
       MOVE.B  BLOCK_X,D0
       MOVE.B  BLOCK_Y,D1
       MULU    #34,D0
       MULU    #17,D1
       ADDQ.W  #2,D0
       ADD.W   #40,D1
       MOVE.L  D0,D2
       MOVE.L  D1,D3
       ADD.W   #31,D2
       ADD.W   #15,D3
       JMP     RECTFILL(A6)

;----------------------------------------------------------

HEX_TO_ASCII:                          ; SCORE IN D0

       MOVE.L  #1000,D1                ; TAUSENDER IN D1
       MOVEQ   #0,D4                   ; D4 LÖSCHEN
       LEA     SCORE_ASCII,A0          ; PUFFER IN A0
       MOVEQ   #3,D2                   ; 4 STELLEN BEARBEITEN
     
HEX_TEST_LOOP:

       MOVE.L  D0,D3                   ; D0 IN D3 SICHERN
       DIVU    D1,D3                   ; SCORE / D1
       MOVE.W  D3,D4                   ; ERGEBNIS IN D4
       MOVE.L  D4,D3                   ; OBERES WORT IN D3 LÖSCHEN
       MULU    D1,D3                   ; ERGEBNIS * D1
       SUB.L   D3,D0                   ; SCORE MINUS ERGEBNIS * D1
       BSR     HEX_EINTRAGEN           ; ERGEBNIS SICHERN
       DIVU    #10,D1                  ; D1 / 10
       DBRA    D2,HEX_TEST_LOOP        ; WIEDERHOLEN
       RTS                             ; ZURÜCK

HEX_EINTRAGEN:
       MOVE.B  D4,(A0)+                ; ERBEBNIS IN DEN PUFFER
       RTS                             ; ZURÜCK

;----------------------------------------------------------

TIME_TO_ASCII:                         ; TIME IN D0

       MOVE.L  #1000,D1
       LEA     TIME_ASCII,A0
       MOVEQ   #3,D2
       MOVEQ   #0,D4

TIME_TEST_LOOP:

       MOVE.L  D0,D3                   ; SIEHE HEX_TO_ASCII
       DIVU    D1,D3
       MOVE.W  D3,D4
       MOVE.L  D4,D3
       MULU    D1,D3
       SUB.L   D3,D0
       BSR     TIME_EINTRAGEN
       DIVU    #10,D1
       DBRA    D2,TIME_TEST_LOOP
       RTS

TIME_EINTRAGEN:
       MOVE.B  D4,(A0)+
       RTS

;----------------------------------------------------------

TEST_ROW:                              ; ZUG NOCH MÖGLICH ?
                                       ; FÜR PLAYER 1
       MOVEQ   #0,D0                   ; D0 LÖSCHEN
       LEA     SPIELFELD,A0            ; SPIELFELD BEGINN
       MOVE.B  BLOCK_Y,D0              ; \
       MULU    #13,D0                  ;  } REIHE BERECHNEN
       ADD.L   D0,A0                   ; /
       MOVEQ   #12,D7                  ; 13 DURCHLÄUFE

ROW_LOOP:

       MOVE.B  (A0)+,D0                ; WERT DES FELDES HOLEN
       CMP.B   #20,D0                  ; IST DAS FELD BESETZT ?
       BNE     ZUG_MÖGLICH2            ; NEIN, DANN IST EIN ZUG MÖGLICH

       DBRA    D7,ROW_LOOP             ; SONST WIEDERHOLEN

       ADD.L   #25,SCORE2              ; ALLES BESETZT P2 ERHÄLT BONUS
       BSR     WRITE_SCORE_2           ; NEUEN SCORE AUSGEBEN
       BSET    #2,PLAYER               ; GAME OVER
       BRA     IRQ4                    ; ZURÜCK

;----------------------------------------------------------

TEST_COLOUM:                           ; ZUG NOCH MÖGLICH ?
                                       ; FÜR PLAYER 2
       MOVEQ   #0,D0                   ; D0 LÖSCHEN
       MOVE.B  BLOCK_X,D0              ; \
       LEA     SPIELFELD,A0            ;  } SPALTE BERECHNEN
       ADD.L   D0,A0                   ; /
       MOVEQ   #10,D7                  ; 11 DURCHLÄUFE

COLOUM_LOOP:

       MOVE.B  (A0),D0                 ; FELD EINLESEN
       CMP.B   #20,D0                  ; FELD BESETZT ?
       BNE     ZUG_MÖGLICH             ; NEIN ZUG MÖGLICH
       ADD.L   #13,A0                  ; SONST NÄCHSTES FELD
       DBRA    D7,COLOUM_LOOP          ; ÜBERPRÜFEN

       ADD.L   #25,SCORE               ; ALLES BESETZT P1 ERHÄLT BONUS
       BSR     WRITE_SCORE             ; NEUEN SCORE AUSGEBEN
       BSET    #2,PLAYER               ; GAME OVER
       BRA     IRQ4                    ; ZURÜCK

ZUG_MÖGLICH:
       BRA     TEST2                   ; ZURÜCK
ZUG_MÖGLICH2:
       BRA     TEST1                   ; ZURÜCK

;----------------------------------------------------------

COMPUTER:

       MOVE.W  #0,ZAEHLER              ; COUNTER LOESCHEN

       MOVEQ   #0,D0                   ; \
       MOVEQ   #-1,D1                  ;  } VARIABLEN REGISTER
       MOVEQ   #0,D2                   ; /

       MOVE.B  BLOCK_X,D0              ; \
       LEA     SPIELFELD,A0            ;  } SPALTE BERECHNEN
       ADD.L   D0,A0                   ; /
       MOVEQ   #11,D7                  ; 12 REIHEN
       MOVE.L  #0,A2                   ; A2 LÖSCHEN

COMPUTER_LOOP:

       MOVE.B  (A0),D0                 ; FELD WERT HOLEN
       CMP.B   #20,D0                  ; FELD BESETZT ?
       BNE     FELD_FREI               ; NEIN UNTERSUCHEN
NEXT:
       ADD.L   #13,A0                  ; NAECHSTE REIHE
       ADDQ.W  #1,D2                   ; BLOCK_Y +1
       DBRA    D7,COMPUTER_LOOP        ; WIEDERHOLEN

       CMP.L   #0,A2                   ; ALLE FELDER BESETZT ?
       BEQ     NO_MORE_STUFF           ; JA GAME OVER

       MOVE.B  D3,BLOCK_Y              ; BLOCK_Y SICHERN
       MULU    #17,D3                  ; \
       ADD.L   #40,D3                  ;  } SP_Y BERECHNEN
       MOVE.W  D3,SP_Y                 ; /

       MOVE.B  #20,(A2)                ; FELD = BESETZT
       MOVE.L  A2,MAPPOINTER           ; MAPPOINTER SICHERN

       CMP.B   #9,D1                   ; FELD = 0
       BEQ     DO_COMP_ZERO            ; VORZEICHEN WECHSELN

       SUB.L   #9,D1                   ; WERT IN +- WANDELN
       ADD.L   D1,SCORE2               ; SCORE2 + WERT
       BMI     SET_ZEROC               ; WENN - DANN 0 SETZEN
RETURNC:
       BSR     WRITE_SCORE_2           ; SCORE2 AUSGEBEN
RETURNC1:
       PEN_COLOR 3                     ; FELD IN PLAYER FARBE
       BSR     DO_BLOCK                ; AUSFÜLLEN
       BCLR    #0,PLAYER               ; PLAYER WECHSELT
       MOVE.W  TIMEBASE,TIME           ; UHR STELLEN
       MOVE.W  #900,D0                 ; FREQUENZ SETZEN
       BSR     SOUND                   ; TASTATUR KLICK

       BRA     IRQ4                    ; ZURÜCK

NO_MORE_STUFF:

       ADD.L   #25,SCORE               ; GEWINNER + 25
       BSR     WRITE_SCORE             ; SCORE AUSGEBEN
       BSET    #2,PLAYER               ; GAME OVER
       BRA     IRQ4                    ; ZURÜCK

SET_ZEROC:
       MOVE.L  #0,SCORE2               ; SCORE = 0
       BRA     RETURNC                 ; ZURÜCK

DO_COMP_ZERO:
       BSR     ZEROPLAY                ; VORZEICHEN WECHSELN
       BRA     RETURNC1                ; ZURÜCK

;----------------------------------------------------------

FELD_FREI:
       CMP.B   D0,D1                   ; NEUER WERT > ALS ALTER
       BLT     NIMM_FELD               ; JA NEUEN WERT NEHMEN
       BRA     NEXT                    ; NEIN WEITERMACHEN

NIMM_FELD:
       MOVE.L  D0,D1                   ; WERT = GRÖßTER WERT
       MOVE.L  D2,D3                   ; NEUER BLOCK_Y
       MOVE.L  A0,A2                   ; NEUER MAPPOINTER
       BRA     NEXT                    ; WEITERMACHEN

;----------------------------------------------------------

DO_COLORS:
       MOVE.W  (A0)+,D1                ; \
       MOVE.W  (A0)+,D2                ;  } FARBEN EINLESEN
       MOVE.W  (A0),D3                 ; /
       BSR     SPRITE_COLOR            ; FARBEN SETZEN
       RTS                             ; ZURÜCK

;----------------------------------------------------------

GELB:
       CMP.W   #$10,SP_GELB            ; FARBE = DUNKEL ?
       BEQ     RESET_GELB              ; JA NEU SETZEN
GELB1:
       LEA     SP_GELB,A0              ; SPRITE FARBE
       BSR     DO_COLORS               ; NEU SETZEN
       ADDQ.W  #1,SP_GELB              ; FARBTON
       ADDQ.W  #1,SP_GELB+2            ; AUFHELLEN
       BRA     IRQ_END                 ; ZURÜCK

;----------------------------------------------------------

MINT:
       CMP.W   #$10,SP_MINT+4          ; FARBE = DUNKEL ?
       BEQ     RESET_MINT              ; JA NEU SETZEN
MINT1:
       LEA     SP_MINT,A0              ; SPRITE FARBE
       BSR     DO_COLORS               ; NEU SETZEN
       ADDQ.W  #1,SP_MINT+4            ; FARBTON
       ADDQ.W  #1,SP_MINT+2            ; AUFHELLEN
       BRA     IRQ_END                 ; ZURÜCK

;----------------------------------------------------------

RESET_GELB:
       MOVE.L  #0,SP_GELB              ; FARBE = SCHWARZ
       BRA     GELB1                   ; ZURÜCK

RESET_MINT:
       MOVE.L  #0,SP_MINT+2            ; FARBE = SCHWARZ
       BRA     MINT1                   ; ZURÜCK

;----------------------------------------------------------

CHANGE_PLAYER:

       BTST    #0,PLAYER               ; PLAYER 2
       BNE     ADD_PLAY_1              ; JA P1 ERHÄLT BONUS

       ADD.L   #15,SCORE2              ; PLAYER 2 BONUS ADDIEREN
       BSR     WRITE_SCORE_2           ; NEUEN SCORE AUSGEBEN
       BRA     CHANGE_PLAY             ; PLAYER WECHSELT

ADD_PLAY_1:
       ADD.L   #15,SCORE               ; PLAYER 1 BONUS ADDIEREN
       BSR     WRITE_SCORE             ; NEUEN SCORE AUGEBEN

CHANGE_PLAY:
       BCHG    #0,PLAYER               ; PLAYER WECHSELN
       MOVE.W  TIMEBASE,TIME           ; UHR NEU STELLEN
       BRA     IRQ_1                   ; ZURÜCK

;----------------------------------------------------------

NEW_IRQ:

       MOVEM.L D0-D7/A0-A6,-(A7)       ; ALLE REGS SICHERN

       MOVE.W  #1,CTLW                 ; STOP SOUND

       BTST    #3,PLAYER               ; PAUSE ?
       BNE     IRQ_END2                ; JA ZUM ENDE

       BSR     SET_POINTER             ; SPRITE SETZEN
       BSR     WRITE_TIME              ; UHR AUSGEBEN

       CMP.W   #0,TIME                 ; UHR ABGELAUFEN ?
       BEQ     CHANGE_PLAYER           ; JA PLAYER WECHSELT

IRQ_1:
       CMP.W   #4,ZAEHLER              ; ZAEHLER = 4
       BNE     IRQ4                    ; NEIN ZUM ENDE

       BTST    #0,PLAYER               ; PLAYER 1 ?
       BEQ     TEST_KEYS_1             ; JA EINGABEN TESTEN
                                       ; NEIN PLAYER 2
       BTST    #1,PLAYER               ; COMPUTER GEGNER
       BEQ     COMPUTER                ; JA COMPUTER ZUG
       BRA     TEST_KEYS               ; NEIN EINGABEN TESTEN
IRQ4:
       CMP.W   #2,ZAEHLER              ; ZAEHLER = 2 ?
       BNE     IRQ_END                 ; NEIN ENDE
                                       ; JA FARBE DIMMEN
       BTST    #0,PLAYER               ; WELCHER SPIELER ?
       BEQ     MINT                    ; PLAYER 1
       BRA     GELB                    ; PLAYER 2

IRQ_END:

       ADDQ.W  #1,ZAEHLER              ; ZAEHLER +1
       SUBQ.W  #1,TIME                 ; UHR - 1

IRQ_END2:
       MOVEM.L (A7)+,D0-D7/A0-A6       ; ALLE REGS ZURÜCK
       DC.W    $4EF9                   ; IRQ ENDE
OLDIRQ:
       DC.L    0

; ---------------------   DATEN BEREICH  ------------------

SCREENDEVS:
       DC.W    0,0,640,256,3
       DC.B    0,1
       DC.W    $8002,15
       DC.L    0,SCR_NAME,0,0

WINDOWDEVS:
       DC.W    100,50,400,200
       DC.B    1,0
       DC.L    $60,$11800
GADGET:    DC.L    GADGET_1,0,0
SCREENHD:  DC.L    0,0
       DC.W    500,200,640,256,15

GADGET_1:
       DC.L    GADGET_2
       DC.W    50,20,101,81,1,1,1
       DC.L    0,0,0,0,0
       DC.W    1
       DC.L    0

GADGET_2:
       DC.L    GADGET_3
       DC.W    250,20,101,81,1,1,1
       DC.L    0,0,0,0,0
       DC.W    2
       DC.L    0

GADGET_3:
       DC.L    GADGET_4
       DC.W    168,170,64,10,0,$A02,4
       DC.L    0,0,0,0,STR_INFO
       DC.W    3
       DC.L    0

STR_INFO:
       DC.L    STR_PUFFER,0
       DC.W    0,5,0,0,0,0,0,0
       DC.L    0
STRDA: DC.L    400,0

GADGET_4:
       DC.L    GADGET_5
       DC.W    50,120,101,16,1,1,1
       DC.L    0,0,0,0,0
       DC.W    4
       DC.L    0

GADGET_5:
       DC.L    GADGET_6
       DC.W    250,120,101,16,1,1,1
       DC.L    0,0,0,0,0
       DC.W    5
       DC.L    0

GADGET_6:
       DC.L    0
       DC.W    180,120,41,16,1,1,1
       DC.L    0,0,0,0,0
       DC.W    6
       DC.L    0

;----------------------------------------------------------

SCREEN_BLACK:  DS.W    8,0
SCREEN_COLORS: DC.W    $0000,$0EEE,$00FF,$0FF0,$0444,$0777,$0AAA,$0090
SP_GELB:       DS.W    3,0
SP_MINT:       DS.W    3,0

;----------------------------------------------------------
 ALIGN.L

INT_SP:        DC.L    0
OWN_TASK:      DC.L    0
WB_MSG:        DC.L    0
WINDOWHD:      DC.L    0
RASTPORT:      DC.L    0
DUMMYRASTPORT: DC.L    0
INTBASE:       DC.L    0
GFXBASE:       DC.L    0
VIEWPORT:      DC.L    0
SCORE:         DC.L    0
SCORE2:        DC.L    0
MAPPOINTER:    DC.L    0

TIME:          DC.W    0
TIMEBASE:      DC.W    0
SP_X:          DC.W    0
ZAEHLER:       DC.W    0
SP_Y:          DC.W    0
XPOS:          DC.W    0
YPOS:          DC.W    0
SCORE_X:       DC.W    560
SCORE_Y:       DC.W    55
SCORE_Y2:      DC.W    102
TIME_Y:        DC.W    134
TIME_X:        DC.W    560

BLOCK_X:       DC.B    0
BLOCK_Y:       DC.B    0
PLAYER:        DC.B    0,0

; ---- IMAGE STRUKTUREN -----------------------------------

ACTION:
       DC.W    0,0,32,16,1
IM_PO: DC.L    0
       DC.B    1,0
       DC.L    0

SCORE_IM:
       DC.W    0,0,10,12,1
SC_PO: DC.L    0
       DC.B    1,0
       DC.L    0

SPRITE:
       DC.L    SPRITE_LOOK
       DC.W    16
       DC.W    0,0
       DC.W    0

PLA1:
       DC.W    0,0,122,33,3
       DC.L    PL1_DATA
       DC.B    7,0
       DC.L    0
PLA2:
       DC.W    0,0,122,33,3
       DC.L    PL2_DATA
       DC.B    7,0
       DC.L    0
TIME_IM:
       DC.W    0,0,122,18,3
       DC.L    TIME_DATA
       DC.B    7,0
       DC.L    0
BRAIN_IM:
       DC.W    0,0,180,19,3
       DC.L    BRAIN_DATA
       DC.B    7,0
       DC.L    0

SPIELFELD:
       DS.B    160,0

; -------------------      TEXTE        -------------------------

SCORE_ASCII:   DS.B    6,0
TIME_ASCII:    DS.B    6,0
STR_PUFFER:    DC.B    "0400",0,0
INTNAME:       DC.B    "intuition.library",0
GFXNAME:       DC.B    "graphics.library",0
TEXT1:         DC.B    "BRAIN BRAISER"     ; 13 CHARS
TEXT2:         DC.B    "der GEHIRN röster" ; 17
TEXT3:         DC.B    "Geschrieben von :" ; 17
TEXT4:         DC.B    "Lutz Großhennig"   ; 15
SCR_NAME:      DC.B "                          BRAIN BRAISER SETUP MENUE",0
SETTEXT1:      DC.B    "PLAYER 1"          ; 8
SETTEXT2:      DC.B    "PLAYER 2"          ; 8
SETTEXT3:      DC.B    "AMIGA"             ; 5
SETTEXT4:      DC.B    "GEGEN"             ; 5
SETTEXT5:      DC.B    "BITTE STELLEN SIE DIE UHR :" ; 27
GAMETEXT1:     DC.B    "PUNKTE PLAYER 1 :" ; 17
GAMETEXT2:     DC.B    "PUNKTE PLAYER 2 :" ; 17
GAMETEXT3:     DC.B    "GEWINNER :"        ; 11
GAMETEXT4:     DC.B    "UNENDSCHIEDEN"     ; 14
GAMETEXT5:     DC.B    "BEENDEN"           ; 7
GAMETEXT6:     DC.B    "NOCHMAL"           ; 7
GAMETEXT7:     DC.B    "SPIELEN"           ; 7
GAMETEXT8:     DC.B    "GAME OVER"         ; 9
KEYTEXT:       DC.B    "KEYBOARD"          ; 8
JOYTEXT:       DC.B    "JOYSTICKS"         ; 9
JOY1TEXT:      DC.B    "1"
JOY2TEXT:      DC.B    "2"

; -------------  BILD DATEN ---------------------------------

  ALIGN.L

; The DATA segment needs to go into the chipram!
  DATA

SPRITE_LOOK:
               DC.W    0,0
               DC.W    %1111111111111111,0    ;1
               DC.W    %1111111111111111,0    ;2
               DC.W    %1100000000000011,0    ;3
               DC.W    %1100000000000011,0    ;4
               DC.W    %1100000000000011,0    ;5
               DC.W    %1100000000000011,0    ;6
               DC.W    %1100000000000011,0    ;7
               DC.W    %1100000000000011,0    ;8
               DC.W    %1100000000000011,0    ;9
               DC.W    %1100000000000011,0    ;10
               DC.W    %1100000000000011,0    ;11
               DC.W    %1100000000000011,0    ;12
               DC.W    %1100000000000011,0    ;13
               DC.W    %1100000000000011,0    ;14
               DC.W    %1111111111111111,0    ;15
               DC.W    %1111111111111111,0    ;16
               DC.W    0,0

PL1_DATA:      IBYTES  "DATA/PL1.BIT"
PL2_DATA:      IBYTES  "DATA/PL2.BIT"
TIME_DATA:     IBYTES  "DATA/TIME.BIT"
BRAIN_DATA:    IBYTES  "DATA/BRAIN.BIT"
COUNT_DATA:    IBYTES  "DATA/-9.BIT"    ; 0
               IBYTES  "DATA/-8.BIT"    ; 1
               IBYTES  "DATA/-7.BIT"    ; 2
               IBYTES  "DATA/-6.BIT"    ; 3
               IBYTES  "DATA/-5.BIT"    ; 4
               IBYTES  "DATA/-4.BIT"    ; 5
               IBYTES  "DATA/-3.BIT"    ; 6
               IBYTES  "DATA/-2.BIT"    ; 7
               IBYTES  "DATA/-1.BIT"    ; 8
               IBYTES  "DATA/0.BIT"     ; 9
               IBYTES  "DATA/1.BIT"     ; 10
               IBYTES  "DATA/2.BIT"     ; 11
               IBYTES  "DATA/3.BIT"     ; 12
               IBYTES  "DATA/4.BIT"     ; 13
               IBYTES  "DATA/5.BIT"     ; 14
               IBYTES  "DATA/6.BIT"     ; 15
               IBYTES  "DATA/7.BIT"     ; 16
               IBYTES  "DATA/8.BIT"     ; 17
               IBYTES  "DATA/9.BIT"     ; 18
               IBYTES  "DATA/X.BIT"     ; 19
SCORES:        IBYTES  "DATA/SCORES.BIT"
SOUND_DATA:    IBYTES  "DATA/KLICK.SND"

END
