;***********************************************
;*                                             *
;*        BRAIN BRAISER  ( PUZZLE GAME )        *
;*                                             *
;*          AUTHOR : Lutz Gro\rfhennig         *
;*                                             *
;*     100% ASSEMBLER ( PROFIMAT AMIGA )       *
;*                                             *
;*        CREATED DATE : 22.05.90              *
;*                                             *
;*        COMPLETION    : 29.06.90              *
;*                                             *
;*               VERSION 1.0                   *
;*                                             *
;***********************************************

; EXEC OFFSETS

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

; INTUITION OFFSETS

OPENSCREEN     = -198
CLOSESCREEN    = -066
OPENWINDOW     = -204
CLOSEWINDOW    = -072
DRAWIMAGE      = -114

; GRAPHICS OFFSETS

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

; CONSTANTS

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

WRITE_TEXT:MACRO *\TEXT,%\LENGTH,%\X,%\Y

       PEN_TO  \X,\Y
       LEA     \TEXT,A0
       MOVEQ   #\LENGTH,D0
       JSR     PRINTTEXT(A6)
       ENDM

SHADOW_WRITE:MACRO *\TEXT,%\COUNT,%\X,%\Y,%\COL

       PEN_COLOR 0
       WRITE_TEXT \TEXT,\COUNT,\X,\Y
       PEN_COLOR \COL
       WRITE_TEXT \TEXT,\COUNT,\X-2,\Y-2
       ENDM

DRAW_MODE:MACRO %\MODE

       MOVE.L  GFXBASE,A6              ; GFXBASE in A6
       MOVE.L  RASTPORT,A1             ; RASTPORT in A1
       MOVEQ   #\MODE,D0
       JSR     SETDRMD(A6)
       ENDM

OPENLIB:MACRO *\NAME,*\BASE

       MOVE.L  EXECBASE,A6
       LEA     \NAME,A1
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

DRAW_3D_BOX:MACRO %\X1,%\Y1,%\X2,%\Y2,%\COLOR

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

DRAW_SHADOW_BOX:MACRO %\X1,%\Y1,%\X2,%\Y2,%\COLOR

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

; -- Main Program --

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
       MOVE.L  #PLAYFIELD,MAP_POINTER
       MOVE.W  #0,PLAYER_FLAGS
       MOVE.W  #0,POINTER_X
       MOVE.W  #0,COUNTER
       MOVE.W  #40,POINTER_Y
       MOVE.W  #2,TILE_X
       MOVE.W  #40,TILE_Y
       MOVE.W  #0,BLOCK_X

       MOVE.L  RASTPORT,DUMMY_RASTPORT
       OPENWIND WINDOWDEVS,WINDOWHD
       TST.L   D0
       BEQ     END4
       DRAW_3D_BOX 0,0,399,199,5
       DRAW_3D_BOX 50,20,150,100,5
       DRAW_3D_BOX 250,20,350,100,5

       DRAW_3D_BOX 50,120,150,135,5
       DRAW_3D_BOX 250,120,350,135,5
       DRAW_3D_BOX 180,120,220,135,5

       DRAW_SHADOW_BOX 167,169,233,178,0

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

SETUP_END:
       CLOSEWIND WINDOWHD
       MOVE.L  DUMMY_RASTPORT,RASTPORT

       SCREEN_COL SCREEN_BLACK,8

       MONOTASKING

       BSR     BUILD_UP_SCREEN
       BSR     BUILD_PLAYFIELD
       BSR     BUILD_UI

       BSR     WRITE_SCORE
       BSR     WRITE_SCORE_2

       SCREEN_COL SCREEN_COLORS,8

       MOVE.L  STRDA,D0
       MOVE.W  D0,TIME_BASE
       MOVE.W  TIME_BASE,TIME

       BSR     INIT_IRQ

MAIN_LOOP:

       BSR     TEST_SPECIAL_KEYS

       BTST    #2,PLAYER_FLAGS
       BNE     GAME_OVER_ROUTINE

       BRA     MAIN_LOOP

END:

       BSR     EXIT_IRQ
END_2:
       BSR     FREE_POINTER

END4:  CLOSESCR  SCREENHD

END3:  CLOSELIB GFXBASE
END1:  CLOSELIB INTBASE
END2:
       MULTITASKING
     
       EXIT_AMIGA
;----------------------------------------------------------

TEST_SPECIAL_KEYS:

       MOVE.B  KEYBOARD,D0
       CMP.B   #$75,D0
       BEQ     ESCAPE_GAME
       CMP.B   #$CD,D0
       BEQ     SET_PAUSE_MODE
       RTS

ESCAPE_GAME:
       BSET    #2,PLAYER_FLAGS
       RTS

SET_PAUSE_MODE:
       BCHG    #3,PLAYER_FLAGS
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
       BEQ     MODE_HUMAN_HUMAN
       CMP.W   #2,D0
       BEQ     MODE_HUMAN_CPU
       CMP.W   #4,D0
       BEQ     TOGGLE_P1_INPUT
       CMP.W   #5,D0
       BEQ     TOGGLE_P2_INPUT
       CMP.W   #6,D0
       BEQ     TOGGLE_JOYSTICKS
       BRA     WAIT_LOOP

MODE_HUMAN_HUMAN:

       BCLR    #1,PLAYER_FLAGS
       BRA     SETUP_END

MODE_HUMAN_CPU:

       BSET    #1,PLAYER_FLAGS
       BRA     SETUP_END

TOGGLE_P1_INPUT:

       BTST    #4,PLAYER_FLAGS
       BNE     P1_JOY_MODE

       BSET    #4,PLAYER_FLAGS
       BSR     CLEAR_FIELD
       SHADOW_WRITE JOYTEXT,8,68,132,2
       BRA     WAIT_LOOP
P1_JOY_MODE:
       BCLR    #4,PLAYER_FLAGS
       BSR     CLEAR_FIELD
       SHADOW_WRITE KEYTEXT,8,68,132,2
       BRA     WAIT_LOOP

TOGGLE_P2_INPUT:

       BTST    #5,PLAYER_FLAGS
       BNE     P2_JOY_MODE

       BSET    #5,PLAYER_FLAGS
       BSR     CLEAR_FIELD2
       SHADOW_WRITE JOYTEXT,8,268,132,3
       BRA     WAIT_LOOP
P2_JOY_MODE:
       BCLR    #5,PLAYER_FLAGS
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

TOGGLE_JOYSTICKS:

       BTST    #6,PLAYER_FLAGS
       BNE     JOYSTICK_SWAP

       BSET    #6,PLAYER_FLAGS
       BSR     CLEAR_FIELD3
       SHADOW_WRITE JOY2TEXT,1,198,132,1
       BRA     WAIT_LOOP
JOY2:
       BCLR    #6,PLAYER_FLAGS
       BSR     CLEAR_FIELD3
       SHADOW_WRITE JOY1TEXT,1,198,132,1
       BRA     WAIT_LOOP

;----------------------------------------------------------

GAME_OVER_ROUTINE:

       BSR     EXIT_IRQ
       MULTITASKING

       MOVE.L  RASTPORT,DUMMY_RASTPORT
       MOVE.L  #0,GADGET_2
       OPENWIND WINDOWDEVS,WINDOWHD
       TST.L   D0
       BEQ     END4
       DRAW_3D_BOX 0,0,399,199,5
       DRAW_3D_BOX 50,20,150,100,5
       DRAW_3D_BOX 250,20,350,100,5

       DRAW_MODE 0

       SHADOW_WRITE GAMETEXT5,7,272,65,1
       SHADOW_WRITE GAMETEXT6,7,72,55,1
       SHADOW_WRITE GAMETEXT7,7,72,75,1

       SHADOW_WRITE GAMETEXT1,17,112,140,2
       SHADOW_WRITE GAMETEXT2,17,112,160,3

       SHADOW_WRITE GAMETEXT8,9,164,120,1

       BSR     DETERMINE_WINNER

       LEA     GADGET_ACTIVE,A4
       BRA     WAIT_LOOP

GADGET_ACTIVE:

       MOVE.W  $26(A1),D0
       CMP.W   #1,D0
       BEQ     REPLAY
       CMP.W   #2,D0
       BEQ     END_GAME
       BRA     WAIT_LOOP

;----------------------------------------------------------

REPLAY:

       CLOSEWIND WINDOWHD
       MOVE.L  #GADGET_3,GADGET_2
       MOVE.L  DUMMY_RASTPORT,RASTPORT
       BRA     SET_UP

END_GAME:

       CLOSEWIND WINDOWHD
       MONOTASKING
       BRA       END_2

DETERMINE_WINNER:

       MOVE.L  SCORE,D0
       BSR     HEX_TO_ASCII
       BSR     ADJUST_WINNER
       SHADOW_WRITE SCORE_ASCII,4,256,140,2
       MOVE.L  SCORE2,D0
       BSR     HEX_TO_ASCII
       BSR     ADJUST_WINNER
       SHADOW_WRITE SCORE_ASCII,4,256,160,3

       MOVE.L  SCORE2,D0
       CMP.L   SCORE,D0
       BEQ     P1_EQUALS_P2
       CMP.L   SCORE,D0
       BLO     P1_BELOW_P2
       CMP.L   SCORE,D0
       BHI     P1_ABOVE_P2
BACK_WINNER:
       RTS

P1_EQUALS_P2:

       SHADOW_WRITE GAMETEXT4,13,148,180,1
       BRA     BACK_WINNER
P1_BELOW_P2:
       BSR     WRITE_WINNER_TEXT
       SHADOW_WRITE SETTEXT1,8,216,180,2
       BRA     BACK_WINNER

P1_ABOVE_P2:
       BSR     WRITE_WINNER_TEXT
       SHADOW_WRITE SETTEXT2,8,216,180,3
       BRA     BACK_WINNER

WRITE_WINNER_TEXT:
       SHADOW_WRITE GAMETEXT3,10,120,180,1
       RTS

ADJUST_WINNER:
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
       DRAW_3D_BOX  0,0,639,22,5
       DRAW_3D_BOX  484,28,639,255,5

       DRAW_SHADOW_BOX 501,37,624,71,0
       DRAW_SHADOW_BOX 501,83,624,118,0
       DRAW_SHADOW_BOX 501,130,624,149,0

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

SOUND_ROUTINE:                                 ; PERIOD IN D0

       MOVE.L  #SOUND_DATA,C0THI
       MOVE.W  #165,C0TL
       MOVE.W  #64,C0VOL
       MOVE.W  D0,C0PER

       MOVE.W  #$8201,CTLW
       RTS

;----------------------------------------------------------
JOYSTICK_LEFT_RIGHT:                           ; PLAYER 1

       MOVE.W  $DFF00C,D0
       BTST    #1,D0
       BNE     SP_RIGHT
       BTST    #9,D0
       BNE     SP_LEFT
       BTST    #7,$BFE001
       BEQ     SPACE1
       BRA     IRQ4

;----------------------------------------------------------
JOYSTICK_UP_DOWN:                              ; PLAYER 2

       BTST    #6,PLAYER_FLAGS
       BNE     JOYSTICK_UP_DOWN_ALT

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
JOYSTICK_UP_DOWN_ALT:                          ; PLAYER 2 (2 JOYSTICKS)
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
BUILD_UI:
       LEA     PLAYFIELD,A5
       MOVE.L  INTBASE,A6
       MOVEQ   #11,D6
BUILD_ROW:
       MOVEQ   #12,D7
       MOVE.W  #2,TILE_X

BUILD_LOOP:
       BRA     GET_TILE_ADDRESS
BUILD_DRAW:
       MOVE.W  TILE_X,D0
       MOVE.W  TILE_Y,D1
       BSR     DRAW_TILE
BUILD_STEP:
       ADD.W   #34,TILE_X
       DBRA    D7,BUILD_LOOP
       ADD.W   #17,TILE_Y
       DBRA    D6,BUILD_ROW

       MOVE.W  #2,TILE_X
       MOVE.W  #40,TILE_Y
       RTS

;----------------------------------------------------------

DRAW_TILE:

       MOVE.L  RASTPORT,A0
       LEA     ACTION_IMAGE,A1
       JMP     DRAWIMAGE(A6)

;----------------------------------------------------------
GET_TILE_ADDRESS:
       MOVEQ   #0,D0
       MOVE.B  (A5)+,D0
       CMP.B   #20,D0
       BEQ     BUILD_STEP

       ASL.L   #6,D0
       MOVE.L  #COUNT_DATA,D1
       ADD.L   D1,D0
       MOVE.L  D0,TILE_IMAGE_POINTER
       BRA     BUILD_DRAW

GET_SCORE_ADDRESS:
       MOVEQ   #0,D0
       MOVE.B  (A5)+,D0
       MOVEQ   #24,D1
       MULS    D1,D0
       MOVE.L  #SCORES_TABLE,D1
       ADD.L   D1,D0
       MOVE.L  D0,SCORE_IMAGE_POINTER
       RTS

;----------------------------------------------------------
WRITE_SCORE:
       MOVE.L  SCORE,D0
       BSR     HEX_TO_ASCII

       MOVE.L  INTBASE,A6
       LEA     SCORE_ASCII,A5
       MOVEQ   #3,D7

SCORE_LOOP:
       BSR     GET_SCORE_ADDRESS
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
       BSR     GET_SCORE_ADDRESS
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
       BSR     GET_SCORE_ADDRESS
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
       LEA     PLAYFIELD,A0
       MOVE.L  #155,D7

PLAY_LOOP:
       BSR     RND
       CMP.B   #19,D0
       BHI     PLAY_LOOP
       MOVE.B  D0,(A0)+
       DBRA    D7,PLAY_LOOP
       RTS

;----------------------------------------------------------
INVERT_SIGNS:
       LEA     PLAYFIELD,A0
       MOVE.L  #155,D7

INVERT_LOOP:

       MOVE.B  (A0),D0
       CMP.B   #20,D0
       BEQ     SKIP
       CMP.B   #19,D0
       BEQ     SKIP
       CMP.B   #9,D0
       BEQ     SKIP

       MOVEQ   #18,D1
       SUB.B   D0,D1
       MOVE.B  D1,(A0)+
INVERT_CONTINUE:
       DBRA    D7,INVERT_LOOP
       RTS

SKIP:
       ADDQ.L  #1,A0
       BRA     INVERT_CONTINUE

;----------------------------------------------------------
SET_POINTER:
       MOVE.L  GFXBASE,A6
       MOVE.L  VIEWPORT,A0
       LEA     SPRITE,A1
       MOVE.W  POINTER_X,D0
       MOVE.W  POINTER_Y,D1
       JMP     MOVESPRITE(A6)

FREE_POINTER:
       MOVE.L  GFXBASE,A6
       MOVEQ   #0,D0
       JMP     FREESPRITE(A6)

;----------------------------------------------------------
TEST_KEYS:
       MOVE.W  #0,COUNTER
       BRA     TEST_COLUMN             ; PLAYER 2
TEST2:
       BTST    #5,PLAYER_FLAGS
       BNE     JOYSTICK_UP_DOWN

       MOVE.B  KEYBOARD,D0             
       CMP.B   #$67,D0                 ; CURSOR UP
       BEQ     SP_UP
       CMP.B   #$65,D0                 ; CURSOR DOWN
       BEQ     SP_DOWN
       CMP.B   #$7F,D0                 ; SPACEBAR
       BEQ     SPACE
       BRA     IRQ4

TEST_KEYS_1:        
       MOVE.W  #0,COUNTER              ; PLAYER 1
       BRA     TEST_ROW
TEST1:
       BTST    #4,PLAYER_FLAGS
       BNE     JOYSTICK_LEFT_RIGHT

       MOVE.B  KEYBOARD,D0
       CMP.B   #$37,D0                 ; ALT LEFT
       BEQ     SP_LEFT
       CMP.B   #$33,D0                 ; AMIGA LEFT
       BEQ     SP_RIGHT
       CMP.B   #$7F,D0                 ; SPACEBAR
       BEQ     SPACE1
       BRA     IRQ4

SP_UP:
       CMP.W   #40,POINTER_Y           ; INSIDE FIELD ?
       BEQ     OUTSIDE                 ; NO, OUTSIDE
       SUB.W   #17,POINTER_Y
       SUB.L   #13,MAP_POINTER
       SUBQ.B  #1,BLOCK_Y
       MOVE.W  #600,D0
       BSR     SOUND_ROUTINE
       BRA     IRQ4

SP_DOWN:
       CMP.W   #227,POINTER_Y          ; INSIDE FIELD ?
       BEQ     OUTSIDE                 ; NO, OUTSIDE
       ADD.W   #17,POINTER_Y
       ADD.L   #13,MAP_POINTER
       ADDQ.B  #1,BLOCK_Y
       MOVE.W  #600,D0
       BSR     SOUND_ROUTINE
       BRA     IRQ4

SP_LEFT:
       CMP.W   #0,POINTER_X            ; INSIDE FIELD ?
       BEQ     OUTSIDE                 ; NO, OUTSIDE
       SUB.W   #34,POINTER_X
       SUBQ.L  #1,MAP_POINTER
       SUBQ.B  #1,BLOCK_X
... (file continues)