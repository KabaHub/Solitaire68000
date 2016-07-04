				; =================================
				;	Init Vectors
				; =================================
				
				org		$0
vector_000		dc.l 	$FFB500 ; Init Pile
vector_001		dc.l	Main
vector_002_255	dcb.l	254,break_exception
break_exception	illegal

				; =================================
				;	Main
				; =================================

				org		$1000

Main			lea		sBoard,a0
				lea		sText,a4
\GameLoop		jsr		PrintBoard
				jsr		AskPlayer
				jsr		MajBoard
				jsr		End?
				bne		\GameLoop
				lea		sWin,a0
				move.l	#33,d1
				move.l	#14,d2
				jsr		Print
				jsr		PrintBoard
				illegal

				; ================================
				;	Subroutines
				; ================================

				;ASKPLAYER
AskPlayer		move.l	a0,-(a7)
\Boucle			jsr		ClearAll
				jsr		PrintAsk
				move.l	#34,d1
				move.l	#12,d2
				lea		sBuffer,a0
				jsr		GetInput
				move.b	(a0)+,d0	; Complete registers d0...
				move.b	(a0)+,d1
				addq.l	#1,a0
				move.b	(a0)+,d2
				move.b	(a0),d3		; ... to d3
				jsr		Atoi
				jsr		GetMiddle
				jsr		TestMvmt
				bne		\Boucle
\End			move.l	(a7)+,a0
				rts

				;TESTMVMT
TestMvmt		movem.l	d0-d2/a0/a1,-(a7)
				jsr		TestFormat
				bne		\Bad
				lea		sBoard,a0
				jsr		GetCase
				cmp.b	#'o',(a1)
				bne		\Bad
				move.l	d2,d0
				move.l	d3,d1
				jsr		GetCase
				cmp.b	#'-',(a1)
				bne		\Bad
				move.l	d4,d0
				move.l	d5,d1
				jsr		GetCase
				cmp.b	#'o',(a1)
				bne		\Bad
				ori.b 	#%00000100,ccr ; Positionne le flag Z à 1
				bra		\End
\Bad			;jsr		PrintRefuse
				andi.b 	#%11111011,ccr ; Positionne le flag Z à 0
\End			movem.l	(a7)+,d0-d2/a0/a1
				rts

					;TESTFORMAT
TestFormat		movem.l	d0-d3/a0,-(a7)
				jsr		Sup1Inf7
				bne		\Bad
				move.l	d1,d0
				jsr		Sup1Inf7
				bne		\Bad
				move.l	d2,d0
				jsr		Sup1Inf7
				bne		\Bad
				move.l	d3,d0
				jsr		Sup1Inf7
				bne		\Bad
				ori.b 	#%00000100,ccr ; Positionne le flag Z à 1
				bra		\End
\Bad			andi.b 	#%11111011,ccr ; Positionne le flag Z à 0
\End			movem.l	(a7)+,d0-d3/a0
				rts

				;SUP1INF7	; Z = 1 si 1 < d0 < 7
Sup1Inf7		cmp.l	#1,d0
				blo		\Nop
				cmp.l	#7,d0
				bhi		\Nop
				ori.b 	#%00000100,ccr ; Positionne le flag Z à 1
				bra		\End
\Nop			andi.b 	#%11111011,ccr ; Positionne le flag Z à 0
\End			rts

				;Atoi
Atoi			move.l	a0,-(a7)
				sub.l	#$60,d0
				sub.l	#$30,d1
				sub.l	#$60,d2
				sub.l	#$30,d3
\End			move.l	(a7)+,a0
				rts

				;GetCase ; Set a1 to case d0,d1
GetCase			movem.l	d0-d2/a0,-(a7)
				lea		sBoard,a1
				subq.l	#1,d1
				add.l	d1,a1
				subq.l	#1,d0
				mulu.w	#8,d0
				add.l	d0,a1
\End			movem.l	(a7)+,d0-d2/a0
				rts

				;ChangeCase ; change (a1) case
ChangeCase		movem.l	d0-d5/a0-a2,-(a7)
				cmp.b	#'-',(a1)
				beq		\ChangeToO
\Else			move.b	#'-',(a1)
				bra		\End
\ChangeToO		move.b	#'o',(a1)
\End			movem.l	(a7)+,d0-d5/a0-a2
				rts

				;GetMiddle	Set d4,d5 fonction of d0,d1
GetMiddle		move.l	d0,d4
				add.l	d2,d4
				divu.w	#2,d4
				swap	d4
				clr.w	d4
				swap	d4
				move.l	d1,d5
				add.l	d3,d5
				divu.w	#2,d5
				swap	d5
				clr.w	d5
				swap	d5
				rts

				;MaJBoard
MajBoard		movem.l	d0-d5/a0-a2,-(a7)
				lea		sBoard,a0
				jsr		GetMiddle
				jsr		GetCase
				jsr		ChangeCase
				move.l	d2,d0
				move.l	d3,d1
				jsr		GetCase
				move.b	#'o',(a1)
				move.l	d4,d0
				move.l	d5,d1
				jsr		GetCase
				jsr		ChangeCase
\End			movem.l	(a7)+,d0-d5/a0-a2
				rts

				;Print12345678	: Print a1, d2++
Print1234567	move.l	a0,-(a7)
				lea		s1234567,a0
				jsr		Print
				addq.l	#2,d2
\End			move.l	(a7)+,a0
				rts

				;PrintABCDEFGH
PrintABCDEFG	movem.l	d0/d2/a0-a2,-(a7)
				lea		sABCDEFG,a0
				addq.l	#2,d2
				move.l	#6,d0
\Boucle			jsr		Print
				addq.l	#2,a0
				addq.l	#2,d2
				dbra	d0,\Boucle
\End			addq.l	#2,d1
				movem.l	(a7)+,d0/d2/a0-a2
				rts

				;PrintBoard
PrintBoard		movem.l	d0-d5/a0-a2,-(a7)
				lea		sBoard,a0
				move.b	#14,d1		;	INIT X
				move.b	#10,d2		;	INIT Y
				jsr		PrintABCDEFG
				jsr		Print1234567
				move.w	#6,d0		; N-1 = 7-1
				addq.l	#1,d1
\Boucle			jsr		PrintLine
				addq.l	#2,d2
				add.l	#8,a0
				dbra	d0,\Boucle
\End			movem.l	(a7)+,d0-d5/a0-a2
				rts

				;PRINTLINE With Spaces, please
PrintLine		movem.l	d0-d2/a0,-(a7)
\Boucle			tst.b	(a0)
				beq		\End
				move.b	(a0)+,d0
				jsr		PrintChar
				addq.l	#2,d1
				bra		\Boucle
\End			movem.l	(a7)+,d0-d2/a0
				rts

				;PRINTASK
PrintAsk		movem.l	d0-d2/a0,-(a7)
				move.l	#33,d1
				move.l	#10,d2
				lea		sText,a0
				jsr		Print
				move.l	#12,d2
				lea		sBlank,a0
				jsr		Print
				move.l	#14,d2
				jsr		Print
\End			movem.l	(a7)+,d0-d2/a0
				rts
				
				;PRINTREFUSE
PrintRefuse		movem.l	d0-d2/a0,-(a7)
				move.l	#33,d1
				move.l	#14,d2
				lea		sRefuse,a0
				jsr		Print
\End			movem.l	(a7)+,d0-d2/a0
				rts

				;End?  ; Z = 1 si le Jeu est terminé !
End?			movem.l	d0/a0,-(a7)
				lea		sBoard,a0
				clr.l	d0
\Boucle			cmp.b	#'f',(a0)
				beq		\EndBoucle
				cmp.b	#'o',(a0)+
				bne		\Noto
\Count			addq.l	#1,d0
\Noto			bra		\Boucle
\EndBoucle		cmp.l	#1,d0
				bne		\NotFinished
				ori.b 	#%00000100,ccr ; Positionne le flag Z à 1
				bra		\End
\NotFinished	andi.b 	#%11111011,ccr ; Positionne le flag Z à 0
\End			movem.l	(a7)+,d0/a0
				rts

				; ==============================
 				; Sous-Routines Annexes
 				; ==============================

				;PRINT
Print			movem.l	d0-d2/a0,-(a7)
\Boucle			tst.b	(a0)
				beq		\End
				move.b	(a0)+,d0
				addq.l	#1,d1
				jsr		PrintChar
				bra		\Boucle
\End			movem.l	(a7)+,d0-d2/a0
				rts

				;CLEARALL
ClearAll		clr.l	d0
				clr.l	d1
				clr.l	d2
				clr.l	d3
				clr.l	d4
				clr.l	d5
				rts

				;ABS
Abs				tst.l	d0
				bpl.s	quit
				neg.l	d0
quit			rts

				;WAIT
Wait			move.l	d0,-(a7)
				move.l	#$FFFF,d0
\Loop			nop
				dbra	d0,\Loop
\End			move.l	(a7)+,d0
				rts

				;PRINTCHAR
PrintChar		incbin	"PrintChar.bin"
				;GETINPUT
GetInput		incbin	"GetInput.bin"

				; ==============================
 				; Données
 				; ==============================

sBuffer			ds.b	60
s1234567		dc.b	"1 2 3 4 5 6 7",0
sABCDEFG		dc.b	'A',0,'B',0,'C',0,'D',0,'E',0,'F',0,'G',0
sBoard			dc.b	"  ooo  ",0,"  ooo  ",0,"ooooooo",0,"ooo-ooo",0,"ooooooo",0,"  ooo  ",0,"  ooo  ",0,'f' ; f = fin de plateau
sText			dc.b	"Déplacement : A1,B2 :",0
sBlank			dc.b	"                    ",0
sWin			dc.b	"Bravo! Vous avez gagne!",0
sDebug			dc.b	"DEBUG",0
sRefuse			dc.b	"Deplacement refuse",0
sFakeBuffer		dc.b	60
