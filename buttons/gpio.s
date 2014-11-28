 /* file gpio_keypad.s
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

turnLedOn:
	/* Turn USB_LINK LED on */
	LDR r4, =0x3fffc01c		/* Load the address of FIO0CLR */
	LDR r5, [r4]			/* Read the current value of FIO0CLR */
	ORR r5, r5, #0x2000		/* Set bit 13 low to turn on */
	STR r5, [r4]			/* Write back the new value to FIO0CLR */

	MOV	pc, lr

turnLedOff:
	/* Turn USB_LINK LED off */
	LDR r4, =0x3fffc018		/* Load the address of FIO0SET */
	LDR r5, [r4]			/* Read the current value of FIO0SET */
	ORR r5, r5, #0x2000		/* Set bit 13 high to turn off */
	STR r5, [r4]			/* Write back the new value to FIO0SET */

	MOV	pc, lr

getPressedButton:
	LDR r4, =0x3fffc014		/* Load the address of FIO0PIN */
	LDR r5, [r4]			/* Read the current value of FIO0PIN */

	AND r6, r5, #0x20000000
	CMP r6, #0
	MOVEQ r0, #1
	BEQ donePressed

	AND r6, r5, #0x40000
	CMP r6, #0
	MOVEQ r0, #2
	BEQ donePressed

	LDR r4, =0x3fffc034		/* Load the address of FIO1PIN */
	LDR r5, [r4]			/* Read the current value of FIO1PIN */

	AND r6, r5, #0x2000000
	CMP r6, #0
	MOVEQ r0, #3
	BEQ donePressed

	AND r6, r5, #0x8000000
	CMP r6, #0
	MOVEQ r0, #4
	BEQ donePressed

	AND r6, r5, #0x400000
	CMP r6, #0
	MOVEQ r0, #5
	BEQ donePressed

	AND r6, r5, #0x40000
	CMP r6, #0
	MOVEQ r0, #6
	BEQ donePressed

	AND r6, r5, #0x80000
	CMP r6, #0
	MOVEQ r0, #7
	BEQ donePressed

	MOV r0, #0
donePressed:
	MOV	pc, lr

message1:
	.string	"\nInitializing GPIO ports...\n"

message2:
	.string	"\nDone!\n"
