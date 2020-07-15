@ script: cw1.s
@ Coursework 1 - Column Cipher Program
@
@ description:  Demonstrate the use of bubble sort to create a cipher using a key and message
@		It will also simulate the use of a 2D array using column and row counters.
@
@ authors: Jake Williams	(ekf17xeu/100209394)
@          Tim Tufnail-Clarke	(ssq16shu/100166648)
@
@ date: 13/11/18
@ version: 1.0


.data @Data Section, static memory starts here
.balign 4

@Static Memory Variables

mode: .word 0 @Will store the mode of the program (0 = encode, 1 = decode)
keyLength: .word 0 @Stores the length of the key / Amount of columns
messageLength: .word 0 @Stores the length of the message
nrows: .word 0 @Stors the amount of rows for the message
textLn: .skip 1000 @Allocate an array of 1000 characters - This will be the message
keyArray: .skip 25 @Allocate 25 bytes for the key
indexArray: .skip 25 @Will keep track of index array

@ Test Variables

output: .asciz "Testing: %d\n" @Test output for digits
output_String: .asciz "Testing: %c\n" @Test output for characters

.text         @Instructions Set
.balign 4
.global main  @Main Function

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@ Function: main
@ Parameters: argv - Number of arguments
@	      argv - Pointers to the addresses of the arguments
@			- Mode
@			- Key
@
@ Returns: void
@ Description:  It will take both the mode and key arguments and store them in static memory. It will also grab the message from
@	        the textfile and store that in an array. It will then remove any illegal characters from the message (such as
@	      	spaces and punctuation, and removes upper case characters). It will then work out the amount of rows the cipher
@		will need to function, and then add blank spaces in the last row with 'x'. Finally, it will read the mode and
@		decide whether to encode or decode the message.
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

main:

	@r4 - argv
	@r5 - Pointer to the mode variable in the command line arguments
	@r8 - mode in static memory

	@This method will take the mode from the command line arguments and store it in static memory

	PUSH {r4-r12,lr} @Pushes r4-12 scratch registers and link register onto stack

	MOV r4,r1 @Moves argv into r4
	LDR r5,[r4, #4] @ r5 = Pointer to Mode
	LDR r5,[r5] @Loads the value in r5 into r5, Now hold whatever mode was entered by the user
	LDR r8,=mode @r8 = pointer to mode in static memory
	STR r5,[r8] @Store the mode entered by the user into static memory 'mode'

	@r6 - Pointer to the key in the command line arguments
	@r8 - Stores the static array keyArray where the key characters will be stored
	@r7 - Key Length Variable: this will increment by one when a character is added to the array
	@   			   in the loop and will give us the length of the key when completed.
	@r2 - Will store the character from the command line argument key.

	LDR r6,[r4,#8] @r6 = Pointer to first element of message (array)
	LDR r8,=keyArray @This will store the key in static memory
	MOV r7,#0 @Key Length Variable

	@This loop will cycle through each character in the key and add it to the key array while also
	@claculating the length of the key

	keyLoop:
		LDRB r2,[r6],#1 @Increments by one to get the next element in the array
		CMP r2,#0 @If it has reached the end of the line, it will equal 0
		BEQ endKeyLoop @Skip to end the loop

		STRB r2,[r8],#1 @Stores the current character in r2 into the new keyArray

		ADD r7,r7,#1 @Increment the key Length variable by 1
		B keyLoop

	endKeyLoop:

	@This will now store the key length variable (r7) used in the above loop and store it in static memory
	LDR r1,=keyLength @Load keyLength into r1
	STR r7,[r1] @Store r7 into the value of r1

	LDR r8,=textLn @r8 - base array address for textLn / address of the first element
	MOV r9,#0 @r9 - Stores the length of the message
	MOV r11, r8  @Moves the text from the base address into r11
	removeCharLoop:
		BL getchar @Gets the first character from the text file
		CMP r0,#-1 @If it is at the end of the file it will return -1
		BEQ endloop @Hence why it exits the loop if it equals -1

		@ Remove all characters except alphabet characters upper and lower case

		CMP r0,#65 @If it is less than 'A', ignore the character
		BLT removeCharLoop
		CMP r0,#122 @If it is greater than 'z', ignore the character
		BGT removeCharLoop

		CMP r0,#90 @If it is less than 'Z' move to check
		ADDLE r0,r0,#32 @Turns upper case into lower case characters
		BLT check
			CMP r0,#97 @If it is less than 'a', ignore the character
			BLT removeCharLoop
		check:
			STRB r0,[r11],#1 @Store the character into the message array
			ADD r9,r9,#1 @Increment the length of the message by 1
		B removeCharLoop @Branch back to the beginning
	endloop:

	LDR r1,=messageLength @Store the length of the message into static memory
	STR r9,[r1]

	@ Finding the amount of rows in the 2D array

	@r4 - Stores the number of rows (nrows) in static memory
	@r5 - Message Length
	@r6 - Key Length
	@r7 - Integer to calculate the amount of rows the cipher will require
	@r8 - Counter to indicate when a new row is required to be made
	@r9 - Total Loops, will store the loop when it equals the message length (r5)

	

	LDR r4,=nrows @Load the static memory address of nrows into r4
	LDR r5,=messageLength 
	LDR r5,[r5] @Load the static mem address of messageLength and load the value inside
	LDR r6,=keyLength
	LDR r6,[r6] @Same process as above but using keyLength and r6
	SUB r6,r6,#1 @Subtract r6 by 1 to get keyLength-1 (since it is used as an index check)
	MOV r7,#0 @ This will store the amount of rows for the loop
	MOV r8,#0 @ This will act as a counter for when to know when to add 1 to a row
	MOV r9,#0 @ This will count the total iterations, so it doesnt run into null data in array

	findRowsLoop:
		CMP r9,r5 @If the total amount of iterations equal the length of the message:
		BEQ exitRowLoop @Exit the loop

		CMP r8,r6 @If the counter is equal to the keyLength-1, move to the reset method
		BEQ resetR8

		ADD r9,r9,#1 @Increment the total iterations by 1
		ADD r8,r8,#1 @Increment the counter by 1

		B findRowsLoop

		resetR8:
			ADD r7,r7,#1 @Add 1 to the amount of rows
			MOV r8,#0 @Reset the counter to 0

			B findRowsLoop 

	exitRowLoop:

	@The method below will find out the new message length by using the newly created nrows variable
	@and multiplying it by the key length (which represents the amount of columns)

	STR r7,[r4] @Store the value of r7 into the value of nrows in static memory
	LDR r4,[r4] @Loads the value of rows into r4
	ADD r6,r6,#1 @Increments the key length register by one as it was previously subtracted by 1
	MUL r10,r4,r6 @nrows*keyLength (same as nRows*nColumns) to find the new messageLength
	LDR r5,=messageLength @Loads r5 with the static memory 'messageLength'
	STR r10,[r5] @Store the new value of messageLength into the static memory

	@Now we have the new message length, we need to fill the empty spaces with X's

	@ The following method  will fill the empty spaces with the appropriate amount of X's

	LDR r4,=messageLength @ This will now equal the rows*columns
	LDR r4,[r4] @Loads the value of r4 into r4
	LDR r5,=textLn @Loads the message array into r5
	MOV r6,#0 @ Will act as a counter
	
	fillLoop:

		CMP r6,r4 @If the counter is the same as the message length:
		BEQ exitFillLoop @Exit the loop

		LDRB r2,[r5],#1 @Loads the next value of the message array into r2
		CMP r2,#0 @If r2 is blank, branch to fill method:
		BEQ fill

		ADD r6,r6,#1 @If the character is not blank, increment the counter by 1 and restart the loop
		B fillLoop

		fill:
		MOV r0,#120 @Move the ascii value of 'x' into r0
		STRB r0,[r11],#1 @ Stores an 'x' in the place of the 0
		ADD r6,r6,#1 @Increment the counter by 1
		B fillLoop 

	exitFillLoop:

	LDR r4,=textLn

	@ Creating an indicies array
	@ This could have been done earlier, but has not been required until now

	@r4 - indexArray, this is where we will add the elements
	@r5 - Key Length -1, this is used to identify when we've added enough elements.
	@r6 - Counter, we will use this to track the amount of iterations, but also use it to add the number to the indexArray array

	LDR r4,=indexArray @r4 will store the index array, starting at element 0
	LDR r5,=keyLength
	LDR r5,[r5]
	SUB r5,r5,#1 @r5 will store the key length - 1, to repesent indexes
	MOV r6,#0 @r6 will act as a counter
	

	fillIndexArrayLoop:
		STRB r6,[r4],#1 @Store the value in the counter into the index array 

		CMP r5,r6 @If it has reached the same size as the keyLength-1, exit the loop
		BEQ exitIndexArrayLoop

		ADD r6,r6,#1 @Increment the counter by 1
		B fillIndexArrayLoop
	exitIndexArrayLoop:

	LDR r4,=mode
	LDRB r4,[r4]  @Loads the value of mode into r4 from static memoryf

	CMP r4,#48 @If the mode is equal to the ASCII equivalent of '0', it will branch to the encode method
	BEQ encoder

	CMP r4,#49 @If the mode is equal to the ASCII equavalent of '1', it will branch to the decode method
	BEQ decoder

	@In this section of the code we have to branch twice as we need to use branch link 'BL' to get to different functions in the code
	@However we also needed the condition BEQ for choosing which mode it will be going to
	@This is why we have a branch to encoder then branch link to encode, as one will access the branch
	@and the other will access the function outside of main.

	encoder:
		BL encode @This will branch to the function encode below the main function
		B exitChoice @This is required so that doesn't sequetially access the decoder branch after its finish with the encode function

	decoder:

	@BL decode @This will branch to the function encode located below the encode function

	exitChoice:

	POP {r4-r12,lr} @Pops registers r4-r12 and the link register off the stack
	BX lr @Branches back to where link register was last (same as a return), this is the end of the program.

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@ Function: encode
@ Parameters: None
@
@ Returns: Encoded Message
@
@ Description: It will re-arrange the key into alphabetical order, and apply the same sorting to a list of integers in order.
@              This re-arranged list of integers will be used in a printing method to get the correct index of a character
@              in the message array, and will print the encoded message onto screen and put into stdout.
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


encode:
	PUSH {r4-r12,lr} @Pushed registers r4-r12 and link register onto stack

	@ Using a bubble sort to organise the indexArray

	@r0 - i - First value to compare
	@r1 - i+1 - Second value in list to compare
	@r2 - Outer encode loop counter 
	@r4: indexArray (first element when inititalised)
	@r5: keyArray (firstElement when initialised)
	@r8: keyLength - 1, As we need to use it as an index tracker, so the last element will be the length -1
	@r9: Index for keyArray, if it equals keyLength-1 it will exit the innerEncodeLoop
	@r10: Index for keyArray + 1: Used to switch the elements if a switch is required

	LDR r4,=indexArray @Loads the first element of indexArray from static memory into r4
	LDR r5,=keyArray @Loads the first element of keyArray from static memory into r5
	LDR r8,=keyLength @Stores the address of static memory keyLength
	LDR r8,[r8] @r8: keyLength value
	SUB r8,r8,#1 @r8: keyLength -1
	MOV r9,#0 @Inner index
	MOV r2,#0 @Outer counter

	outerEncodeLoop:
		CMP r2,r6 @If the outer encode loop index is the same as keyLength, the loop is finished
		BEQ exitOuterEncodeLoop

		MOV r9,#0 @Inner index = 0
		MOV r10,#0 @Inner index+1 = 0 (It is added later)
		
		innerEncodeLoop:
			CMP r9,r8 @If the inner index is equal to the keyLength-1, the loop has reached the end of the key
			BEQ exitInnerEncodeLoop @It will now exit and reset the values to 0

			LDRB r0,[r5, r9] @r0 now stores the ASCII value of i
			ADD r10,r9,#1 @r10 now stores the index of i+1, so it now needs to fetch the character.
			LDRB r1,[r5,r10] @r1 now stores the ASCII value of i+1 using r10 as an index

			@If the ASCII value of the first element is less than the value of the second, the characters are in the correct order
			@Hence why when it is r0 is less than r1, it will move to the skip method below are does not re-arrange the characters

			CMP r0,r1
			BLT skip

			@Since it now knows that the characters are in the incorrect order, it must now switch them
			@It does this by using the register r0 and r1, which store the first and second character respectively
			@It then uses the index's (in r9 and r10) and stores the characters in opposite indexs
			@This will switch then in the keyArray 

			STRB r0,[r5,r10] @Stores the value in r0 into the index r10 of the keyArray
			STRB r1,[r5,r9] @Stores the value in r1 into the index r9 of the keyArray

			@Now we need to apply the same logic to the indexArray, as it will be used to find out what characters to print in what order
			@It loads the values from the index array in the indexes provided above and stores the integers in r0 and r1, as previously used by the key characters
			@It will then store them in the opposite places, resulting after the loop in an index list which can be used to print the message characters
			@ in the correct order

			LDRB r0,[r4,r9] @Loads the value stored in index r9 into r0
			LDRB r1,[r4,r10] @Loads the value stored in index r10 into r1
			STRB r0,[r4,r10] @Stores the value in r0 into the index r10 of the index array
			STRB r1,[r4,r9] @Stores the value in r1 into the index r9 of the index array

			skip: @Will go here automatically if the selected characters are already sorted

			ADD r9,r9,#1 @Moves to the next character

			B innerEncodeLoop

		exitInnerEncodeLoop:

	ADD r2,r2,#1 @r2 = r2 + 1 - Increments the counter

	B outerEncodeLoop

	exitOuterEncodeLoop:

	@Now to print the encrypted message

	@r4 - Message Array (textLn)
	@r5 - Index Array
	@r6 - Key Length
	@r7 - nrows
	@r8 - Outer loop counter (will stop loop when it equals the size of the keylength)
	@r9 - Inner loop counter (will stop loop when it equals the size of nrows)

	@r0 - Character (put through putchar)
	@r2 - Character Index (this is calculated using the keyLength, index from indexArray and inner loop counter)
	@r3 - Index value from indexArray

	LDR r4,=textLn
	LDR r5,=indexArray
	LDR r6,=keyLength
	LDR r6,[r6] @Stores the value of the keyLength into r6
	LDR r7,=nrows
	LDR r7,[r7] @Stores the value of nrows into r7

	MOV r8,#0

	@ Outer loop will increment up to key length
	@ Inner loop will increment up to nrows

	outerPrintLoop:
		CMP r8,r6 @If the couner is equal to the keyLength, exit the loop
		BEQ exitOuterPrintLoop

		MOV r9,#0 @Reset 

		innerPrintLoop:
			CMP r9,r7 @If the inner loop index equals the amount of rows, it will exit.
			BEQ exitInnerPrintLoop

			@The 3 lines below is my method of accessing the correct character from the message array.
			@It will first access the integer in indexArray at index r8, and store it in r3
			@It then uses a multiply and add method where it will times r9 by r6 to find what row it is on
			@ and it will use r3 to find what column it is on.

			@For example, using codeword dragon, the index array will be [2,0,3,5,4,1], so the first value of r3 will be 2
			@The first value of r9 is 0 and first value of r6 will be the keylength (in the case of dragon, that would be 6)
			@Using MLA we get: (0*6) + 2, which will end up returning 2. This is the index of the first character we need from the message
			@This value is stored in r2, and is then used in the next line to load the character at index r2 into r0

			LDRB r3,[r5,r8] @Loads the index number at index r8 from the index array into r3
			MLA r2,r9,r6,r3 @r2 = (r9*r6) + r3
			LDRB r0,[r4,r2] @Loads the appropriate character into r0

			@After this we will use BL putchar so that it will push the character into stdout and will output on the screen

			BL putchar

			ADD r9,r9,#1 @Increments the inner loop counter by 1

			B innerPrintLoop

		exitInnerPrintLoop:

	ADD r8,r8,#1 @Increments the outer loop counter by 1

	B outerPrintLoop

	exitOuterPrintLoop:

	POP {r4-r12,lr}
	BX lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@ Function: decode
@ Paremeters: None
@
@ Returns: Decrypted Message
@ Description: Takes the key from command line arguments and will decode the message.
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

decode:
	PUSH {r4-r12,lr}

	@We did not find the time to finish the decode function.

	POP {r4-r12,lr}
	BX lr




@External

.global printf





