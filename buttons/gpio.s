 /* file gpio.s
 * DESCRIPTION: Play around with GPIO ports for buttons, joystick and LED.
 * AUTHOR:	Tomer Barletz
 * CREATED:	11/27/2014
 */

	.global	initGpioPorts
	.global	turnLedOn
	.global	turnLedOff
	.global	getPressedButton
	.code		32
	.extern	printString

/* FUNCTION:	initGpioPorts
 * DESCRIPTION: Initialize GPIO ports that will be used in other functions.
 * C PROTOTYPE: void initGpioPorts(void);
 * PARAMS:	None
 * OTHER R:	r4: store the address of IO0DIR
 * RETURN:	none
 */
initGpioPorts:
	STMFD	r13!, {r0-r3, lr}
	LDR	r0, =message1
	BL	printString
	LDMFD	r13!, {r0-r3, lr}

	/* Set GPIO P0.13 direction to output */
	LDR r4, =0x3fffc000		/* Load the address of IO0DIR */
	LDR r0, [r4]			/* Read the current value of IO0DIR */
	ORR r0, r0, #0x2000		/* Set bit 13 high to indicate an output */
	STR r0, [r4]			/* Write back the new value to IO0DIR */

	STMFD	r13!, {r0-r3, lr}
	LDR	r0, =message2
	BL	printString
	LDMFD	r13!, {r0-r3, lr}

	MOV	pc, lr

/* FUNCTION:	turnLedOn
 * DESCRIPTION: Turn the USB_LINK LED on.
 * C PROTOTYPE: void turnLedOn(void);
 * PARAMS:	None
 * OTHER R:	r4: store the address of FIO0CLR.
 *		r5: manipulate the value of FIO0CLR.
 * RETURN:	none
 */
turnLedOn:
	/* Turn USB_LINK LED on */
	LDR r4, =0x3fffc01c		/* Load the address of FIO0CLR */
	LDR r5, [r4]			/* Read the current value of FIO0CLR */
	ORR r5, r5, #0x2000		/* Set bit 13 low to turn on */
	STR r5, [r4]			/* Write back the new value to FIO0CLR */

	MOV	pc, lr

/* FUNCTION:	turnLedOff
 * DESCRIPTION: Turn the USB_LINK LED off.
 * C PROTOTYPE: void turnLedOff(void);
 * PARAMS:	None
 * OTHER R:	r4: store the address of FIO0SET.
 *		r5: manipulate the value of FIO0SET.
 * RETURN:	none
 */
turnLedOff:
	/* Turn USB_LINK LED off */
	LDR r4, =0x3fffc018		/* Load the address of FIO0SET */
	LDR r5, [r4]			/* Read the current value of FIO0SET */
	ORR r5, r5, #0x2000		/* Set bit 13 high to turn off */
	STR r5, [r4]			/* Write back the new value to FIO0SET */

	MOV	pc, lr

/* FUNCTION:	turnLedOff
 * DESCRIPTION: Turn the USB_LINK LED off.
 * C PROTOTYPE: void turnLedOff(void);
 * PARAMS:	None
 * OTHER R:	r0: return value for the pressed button.
 *		r4: store the address of FIO0PIN.
 *		r5: store the value of FIO0PIN.
 *		r6: store the result of ANDing the value with the bit offset of
 *		    a specific button.
 * RETURN:	The value of a pressed button, or 0 in case none is pressed.
 *		Available options are:
 *		BUT1:   1
 *		BUT2:   2
 *		CENTER: 3
 *		LEFT:   4
 *		RIGHT:  5
 *		UP:     6
 *		DOWN:   7
 */
getPressedButton:
	LDR r4, =0x3fffc014		/* Load the address of FIO0PIN */
	LDR r5, [r4]			/* Read the current value of FIO0PIN */

	/* In the following lines, until the end of the function, check if the
	   buttons mask matches one of the buttons. If so, update r0 and return;
	   if not, test for the next button. When none matched, return 0. */

	/* Test if BUT1 is pressed. */
	AND r6, r5, #0x20000000
	CMP r6, #0
	MOVEQ r0, #1
	BEQ donePressed

	/* Test if BUT2 is pressed. */
	AND r6, r5, #0x40000
	CMP r6, #0
	MOVEQ r0, #2
	BEQ donePressed

	/* Joystick buttons are on a different port. */
	LDR r4, =0x3fffc034		/* Load the address of FIO1PIN */
	LDR r5, [r4]			/* Read the current value of FIO1PIN */

	/* Test if CENTER is pressed. */
	AND r6, r5, #0x2000000
	CMP r6, #0
	MOVEQ r0, #3
	BEQ donePressed

	/* Test if LEFT is pressed. */
	AND r6, r5, #0x8000000
	CMP r6, #0
	MOVEQ r0, #4
	BEQ donePressed

	/* Test if RIGHT is pressed. */
	AND r6, r5, #0x400000
	CMP r6, #0
	MOVEQ r0, #5
	BEQ donePressed

	/* Test if UP is pressed. */
	AND r6, r5, #0x40000
	CMP r6, #0
	MOVEQ r0, #6
	BEQ donePressed

	/* Test if DOWN is pressed. */
	AND r6, r5, #0x80000
	CMP r6, #0
	MOVEQ r0, #7
	BEQ donePressed

	/* None of the buttons is pressed - return 0. */
	MOV r0, #0
donePressed:
	MOV	pc, lr

message1:
	.string	"\nInitializing GPIO ports...\n"

message2:
	.string	"\nDone!\n"
