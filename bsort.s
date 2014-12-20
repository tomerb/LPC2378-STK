/* file bsort.s
 * DESCRIPTION: Assembly language function implementing bubble sort.
 * AUTHOR:	Tomer Barletz
 * CREATED:	11/14/2014
 */

	.global	BubbleSort
	.code		32
	.extern	printString

BubbleSort_Descending:
	CMP	r7, r6
	STRGT	r6, [r0, r3, LSL #2]	/* if (r7 > r6) arr[i] =   r6 */
	STRGT	r7, [r0, r5, LSL #2]	/* if (r7 > r6) arr[i-1] = r7 */
	B	BubbleSort_LoopEnd

/* FUNCTION:	BubbleSort
 * DESCRIPTION: Sort an array of integers using the bubble sort algorithm.
 * C PROTOTYPE: void BubbleSort(int Array[], int ArraySize);
 * PARAMS:	r0: address of Array
 *		r1: the size of Array
 *		r2: 0 - descending order, any other value - acending order
 * OTHER R:	r3: loop counter
 *		r4: swapped flag (indicate if a swap was made. If not - the
 *		    the array is sorted and we're done.
 *		r5: tmp storage for array index - 1
 *		r6: value of Array[i-1]
 *		r7: value of Array[i]
 * RETURN:	none
 */
BubbleSort:
	STMFD	r13!, {r0-r3, lr}
	LDR	r0, =message1
	BL	printString
	LDMFD	r13!, {r0-r3, lr}

	MOV	r3, #1			/* initialize loop counter	*/
	MOV	r4, #0			/* initialize swapped flag	*/

	/* for (int i = 1; i < ArraySize; ++i) */
BubbleSort_Loop:
	CMP	r3, r1			/* check for more elements to copy */
	BEQ	BubbleSort_Again

	/* if didn't branch - check if (i-1 > i) */
	SUB	r5, r3, #1		/* store i-1 in r5 */
	LDR	r6, [r0, r5, LSL #2]	/* r6 = arr[i-1] */
	LDR	r7, [r0, r3, LSL #2]	/* r7 = arr[i] */
	CMP	r2, #0			/* check if acsending or descending */
	BEQ	BubbleSort_Descending	/* if(0) sort in descending */
BubbleSort_Asceding:			/* else sort in ascending */
	CMP	r6, r7
	STRGT	r6, [r0, r3, LSL #2]	/* if (r6 > r7) arr[i] =   r6 */
	STRGT	r7, [r0, r5, LSL #2]	/* if (r6 > r7) arr[i-1] = r7 */

BubbleSort_LoopEnd:
	MOVGT	r4, #1			/* swapped = true */
	ADD	r3, #1			/* increment counter */
	B	BubbleSort_Loop	/* repeat if more elements */

BubbleSort_Again:
	CMP	r4, #1			/* if (swapped) */
	MOVEQ	r4, #0			/* reset swapped flag */
	MOVEQ	r3, #1			/* i = 1 */
	BEQ	BubbleSort_Loop	/* loop again */

BubbleSort_End:
	STMFD	r13!, {r0-r3, lr}
	LDR	r0, =message2
	BL	printString
	LDMFD	r13!, {r0-r3, lr}

	MOV	pc, lr

message1:
	.string	"\nSorting...\n"

message2:
	.string	"\ndone!\n"
