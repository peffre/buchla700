* ------------------------------------------------------------------------------
* timeint.s -- MIDAS-VII timer interrupt handler
* Version 15 -- 1989-07-20 -- D.N. Lynx Crowe
* ------------------------------------------------------------------------------
*
* This code replaces the interrupt handler in bios.s, which is known to
* have a bug in it, and adds support for the VSDD and an array of programable
* timers with 1 Ms resolution.
*
* WARNING:  There are equates to addresses in the bios EPROM which may change
* when the bios is reassembled.  If the bios is reassembled be sure to update
* the equates flagged by "<<<=====".
*
* The addresses currently in the equates are for EPROMs dated 1988-04-18 or
* 1988-06-20 ONLY.
*
* ------------------------------------------------------------------------------
* Hardware timer usage:
* ---------------------
*	Timer 1		PLL divider for score clock -- fixed at 64
*	Timer 2		PLL divider for score clock -- nominally 3200
*	Timer 3		1 Ms Real Time Clock
*
* ------------------------------------------------------------------------------
*
		.text
*
		.xdef	_tsetup		* tsetup() -- timer setup function
		.xdef	timeint		* timer interrupt handler
*
		.xdef	_M1IoRec	* MIDI channel 1 IoRec		
		.xdef	_M2IoRec	* MIDI channel 2 IoRec		
		.xdef	_S1IoRec	* RS232 channel 1 IoRec		
		.xdef	_S2IoRec	* RS232 channel 2 IoRec		
		.xdef	_timers		* timer array -- short timers[NTIMERS]
		.xdef	_vi_clk		* VSDD scroll delay timer
		.xdef	_vi_tag		* VSDD VI tag
*
		.xref	lclsadr		* score object base address
		.xref	lclscrl		* score object scroll offset
		.xref	_v_odtab	* VSDD object descriptor table
*
		.page
* ==============================================================================
*
FRAMES		.equ	0		* set non-zero to enable frame pulses
*
* Equates to variables in bios.s:
* -------------------------------
* These variables are permanently assigned.
*
TIMEVEC		.equ	$00000400	* LONG - System timer trap vector
*
FC_SW		.equ	$00000420	* WORD - Frame clock switch
FC_VAL		.equ	$00000422	* LONG - Frame clock value
*
HZ_1K		.equ	$0000049A	* LONG - 1000 Hz clock
HZ_200		.equ	$0000049E	* LONG - 200 Hz clock
FRCLOCK		.equ	$000004A2	* LONG - 50 Hz clock
*
T3COUNT		.equ	$000004AA	* WORD - Timer 3 count
*
* ------------------------------------------------------------------------------
*
* WARNING:  The address of "FLOCK" depends on the version of the bios EPROM.
* The address below is for EPROMs dated 1988-04-18 or 1988-06-20 ONLY.
*
FLOCK		.equ	$00000E0C	* WORD - Floppy semaphore	<<<=====
*
* ==============================================================================
*
* Equates to routines in bios.s:
* ------------------------------
*
* WARNING:  The address of "FLOPVBL" depends on the version of the bios EPROM.
* The address below is for EPROMs dated 1988-04-18 or 1988-06-20 ONLY.
*
FLOPVBL		.equ	$001015EE	* floppy VI handler address	<<<=====
*
* ==============================================================================
*
		.page
*
* Hardware address equates:
* -------------------------
TI_VEC		.equ	$00000070	* Timer interrupt autovector
*
TIMER		.equ	$003A0001	* Timer base address
M1_ACIA		.equ	$003AC001	* MIDI ACIA channel 1 base address
*
* ------------------------------------------------------------------------------
*
* Timer register equates:
* -----------------------
TIME_CRX	.equ	TIMER		* Control register 1 or 3
TIME_CR2	.equ	TIMER+2		* Control register 2
TIME_T1H	.equ	TIMER+4		* Timer 1 high byte
TIME_T1L	.equ	TIMER+6		* Timer 1 low byte
TIME_T2H	.equ	TIMER+8		* Timer 2 high byte
TIME_T2L	.equ	TIMER+10	* Timer 2 low byte
TIME_T3H	.equ	TIMER+12	* Timer 3 high byte
TIME_T3L	.equ	TIMER+14	* Timer 3 low byte
*
* Serial I/O equates:
* -------------------
ACIA_CFR	.equ	2		* CFR offset from ACIA base
DTR_BIT		.equ	1		* DTR bit in ACIA CFR1
*
IO_CFR1		.equ	29		* cfr1 offset in M1IoRec
*
* ==============================================================================
*
* Miscellaneous equates:
* ----------------------
IPL7		.equ	$0700		* IPL mask for interrupt disable
*
FCMAX		.equ	$00FFFFFF	* Maximum frame counter value
FCMIN		.equ	$00000000	* Minimum frame counter value
*
NTIMERS		.equ	8		* Number of timers in the timer array
*
XBIOS		.equ	14		* XBIOS TRAP number
X_PIOREC	.equ	0		* X_PIOREC code
SR1_DEV		.equ	0		* RS232 ACIA channel 1
SR2_DEV		.equ	1		* RS232 ACIA channel 2
MC1_DEV		.equ	3		* MIDI ACIA channel 1
MC2_DEV		.equ	4		* MIDI ACIA channel 2
* ==============================================================================
*
		.page
* ==============================================================================
* _tsetup -- tsetup() -- timer setup function
* ==============================================================================
*
_tsetup:	move.w	sr,-(a7)		* Save old interrupt mask
		ori.w	#IPL7,sr		* Disable interrupts
*
		move.w	#SR1_DEV,-(a7)		* Establish S1IoRec
		move.w	#X_PIOREC,-(a7)		* ...
		trap	#XBIOS			* ...
		add.l	#4,a7			* ...
		move.l	d0,_S1IoRec		* ...
*
		move.w	#SR2_DEV,-(a7)		* Establish S2IoRec
		move.w	#X_PIOREC,-(a7)		* ...
		trap	#XBIOS			* ...
		add.l	#4,a7			* ...
		move.l	d0,_S2IoRec		* ...
*
		move.w	#MC1_DEV,-(a7)		* Establish M1IoRec
		move.w	#X_PIOREC,-(a7)		* ...
		trap	#XBIOS			* ...
		add.l	#4,a7			* ...
		move.l	d0,_M1IoRec		* ...
*
		move.w	#MC2_DEV,-(a7)		* Establish M2IoRec
		move.w	#X_PIOREC,-(a7)		* ...
		trap	#XBIOS			* ...
		add.l	#4,a7			* ...
		move.l	d0,_M2IoRec		* ...
*
		.page
*
		clr.w	FC_SW			* Stop the frame clock
		clr.l	FC_VAL			* ... and reset it
		clr.w	_vi_tag			* Clear VSDD VI tag
		clr.w	_vi_clk			* Clear VSDD delay timer
		clr.w	lclsadr			* Clear score scroll address
		clr.w	lclscrl			* Clear score scroll offset
*
		lea	_timers,a0		* Point at timer array
		move.w	#NTIMERS-1,d0		* Setup to clear timer array
*
tclr:		clr.w	(a0)+			* Clear a timer array entry
		dbra	d0,tclr			* Loop until done
*
		move.l	#nullrts,TIMEVEC	* Set timer interrupt vector
		move.l	#timeint,TI_VEC		* Set timer trap vector
*
		move.b	#$00,TIME_T1H		* Setup timer 1  (PLL)
		move.b	#$1F,TIME_T1L		* ... for divide by 64
		move.b	#$0C,TIME_T2H		* Setup timer 2  (FC)
		move.b	#$7F,TIME_T2L		* ... for divide by 3200
		move.b	#$03,TIME_T3H		* Setup timer 3  (RTC)
		move.b	#$20,TIME_T3L		* ... for 1Ms interval
		move.b	#$42,TIME_CRX		* Setup CR3
		move.b	#$41,TIME_CR2		* Setup CR2
		move.b	#$81,TIME_CRX		* Setup CR1
		move.b	#$80,TIME_CRX		* Start the timers
*
		move.w	(a7)+,sr		* Restore interrupts
*
nullrts:	rts				* Return to caller
*
		.page
* ==============================================================================
* timeint -- timer interrupt handler
* ==============================================================================
*
timeint:	movem.l	d0-d7/a0-a6,-(a7)	* Save registers
		move.b	TIME_CR2,d0		* Get timer interrupt status
* ------------------------------------------------------------------------------
* process 1 MS timer
* ------------------------------------------------------------------------------
		btst.l	#2,d0			* Check timer 3 status
		beq	tmi02			* Jump if not active
*
		move.b	TIME_T3H,d1		* Read timer 3 count
		lsl.w	#8,d1			* ...
		move.b	TIME_T3L,d1		* ...
		move.w	d1,T3COUNT		* ... and save it
*
		addq.l	#1,HZ_1K		* Update 1ms clock  (1 KHz)
*
		move.l	d0,-(a7)		* Preserve D0
* ------------------------------------------------------------------------------
* process VSDD timer
* ------------------------------------------------------------------------------
		tst.w	_vi_tag			* Does the VSDD need service ?
		beq	updtime			* Jump if not
*
		move.w	_vi_clk,d0		* Get VSDD scroll delay timer
		subq.w	#1,d0			* Decrement timer
		move.w	d0,_vi_clk		* Update timer
		bne	updtime			* Jump if it's not zero yet
*
		move.w	lclsadr,_v_odtab+12	* Update scroll address
		move.w	lclscrl,_v_odtab+10	* Update scroll offset
		clr.w	_vi_tag			* Reset the tag
*
		.page
*
* ------------------------------------------------------------------------------
* process programable timers
* ------------------------------------------------------------------------------
*
updtime:	move.w	#NTIMERS-1,d0		* Setup timer array counter
		lea	_timers,a0		* Point at timer array
*
tdcr:		move.w	(a0),d1			* Get timer array entry
		beq	tdcr1			* Jump if already 0
*
		subq.w	#1,d1			* Decrement timer
*
tdcr1:		move.w	d1,(a0)+		* Store updated timer value
		dbra	d0,tdcr			* Loop until done
*
* ------------------------------------------------------------------------------
* process timer hook vector
* ------------------------------------------------------------------------------
		movea.l	TIMEVEC,a0		* Get RTC vector
		move.w	#1,-(a7)		* Pass 1 msec on stack
		jsr	(a0)			* Process RTC vector
		addq.l	#2,a7			* Clean up stack
*
		move.l	(a7)+,d0		* Restore D0
*
		.page
* ------------------------------------------------------------------------------
* process 5 Ms clock
* ------------------------------------------------------------------------------
		move.w	tdiv1,d1		* Update divider
		addq.w	#1,d1			* ...
		move.w	d1,tdiv1		* ...
*
		cmpi.w	#5,d1			* Do we need to update HZ_200 ?
		blt	tmi02			* Jump if not
*
		addq.l	#1,HZ_200		* Update 5ms clock   (200 Hz)
* ------------------------------------------------------------------------------
* process 20 Ms floppy clock
* ------------------------------------------------------------------------------
		move.w	tdiv2,d1		* Update divider
		addq.w	#1,d1			* ...
		move.w	d1,tdiv2		* ...
*
		cmpi.w	#4,d1			* Do we need to update FRCLOCK ?
		blt	tmi01			* Jump if not
*
		addq.l	#1,FRCLOCK		* Update 20 Ms clock  (50 Hz)
		tst.w	FLOCK			* See if floppy is active
		bne	tmi00			* Don't call FLOPVBL if so
*
		jsr	FLOPVBL			* Check on the floppy
*
tmi00:		move.w	#0,tdiv2		* Reset tdiv2
*
tmi01:		move.w	#0,tdiv1		* Reset tdiv1
*
		.page
* ------------------------------------------------------------------------------
* process PLL timers
* ------------------------------------------------------------------------------
*
tmi02:		btst.l	#0,d0			* Check timer 1 int
		beq	tmi03			* Jump if not set
*
		move.b	TIME_T1H,d1		* Read timer 1 to clear int.
		move.b	TIME_T1L,d1		* ...
*
tmi03:		btst.l	#1,d0			* Check for timer 2 int.
		beq	tmi04			* Jump if not set
*
		move.b	TIME_T2H,d1		* Read timer 2 to clear int.
		move.b	TIME_T2L,d1		* ...
*
		.page
* ------------------------------------------------------------------------------
* update score frame counter
* ------------------------------------------------------------------------------
		tst.w	FC_SW			* Should we update the frame ?
		beq	tmi04			* Jump if not
*
		bmi	tmi05			* Jump if we count down
*
		move.l	FC_VAL,d0		* Get the frame count
		cmp.l	#FCMAX,d0		* See it we've topped out
		bge	tmi06			* Jump if limit was hit
*
		addq.l	#1,d0			* Count up 1 frame
		move.l	d0,FC_VAL		* Store updated frame count
*
		.ifne	FRAMES
		move.w	sr,d1			* Preserve interrupt status
		ori.w	#$0700,sr		* Disable interrupts
*
		movea.l	_M1IoRec,a0		* Point at M1IoRec
		move.b	IO_CFR1(a0),d0		* Get MIDI-1 CFR1 value
		or.b	#$80,d0			* Force MSB = 1 for CFR1 output
		movea.l	#M1_ACIA,a0		* Point at MIDI-1 ACIA channel
		bchg.l	#DTR_BIT,d0		* Toggle DTR for output
		move.b	d0,ACIA_CFR(a0)		* Output toggled DTR
		bchg.l	#DTR_BIT,d0		* Toggle DTR for output
		move.b	d0,ACIA_CFR(a0)		* Output toggled DTR
		move.w	d1,sr			* Restore interrupts
		.endc
*
		bra	tmi04			* Done
*
tmi07:		move.l	#FCMIN,FC_VAL		* Force hard limit, just in case
		bra	tmi04			* Done
*
tmi06:		move.l	#FCMAX,FC_VAL		* Force hard limit, just in case
		bra	tmi04			* Done
*
tmi05:		move.l	FC_VAL,d0		* Get the frame count
		ble	tmi07			* Done if already counted down
*
		subq.l	#1,d0			* Count down 1 frame
		move.l	d0,FC_VAL		* Store udpated frame count
		bra	tmi04			* Done
*
		nop				* Filler to force equal paths
*
tmi04:		movem.l	(a7)+,d0-d7/a0-a6	* Restore registers
		rte				* Return to interrupted code
*
		.page
* ==============================================================================
		.bss
* ==============================================================================
*
* A note on tdiv1 and tdiv2:
* --------------------------
*
* tdiv1 and tdiv2 are actually defined in the bios,  but since they could move
* we define them here and ignore the ones in the bios.
*
tdiv1:		ds.w	1		* Timer divider 1  (divides HZ_1K)
tdiv2:		ds.w	1		* Timer divider 2  (divides HZ_200)
*
* ------------------------------------------------------------------------------
*
_timers:	ds.w	NTIMERS		* Timer array -- short timers[NTIMERS];
*
_vi_clk:	ds.w	1		* VSDD scroll delay timer
_vi_tag:	ds.w	1		* VSDD VI 'needs service' tag
*
_S1IoRec:	ds.l	1		* address of RS232 channel 1 IoRec
_S2IoRec:	ds.l	1		* address of RS232 channel 2 IoRec
_M1IoRec:	ds.l	1		* address of MIDI channel 1 IoRec
_M2IoRec:	ds.l	1		* address of MIDI channel 2 IoRec
* ==============================================================================
*
		.end
