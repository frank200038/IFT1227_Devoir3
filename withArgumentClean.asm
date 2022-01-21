#Author: Yan Zhuang, Yu Deng, Wenhao Xu

.data
  # Buffer reserved for data
  buffer: .space 400
  # Message
  msg:	.asciiz "Entrer un nombre:"
  msgError: .asciiz "Depassement d'espace"
  tab: .asciiz "\t"
  newline: .asciiz "\n"
.text

# This program has taken into account the situation where the user enters no number or only one number (In both cases, no sort is needed)
# Even though this part is not specified in the homework, we decide to take care of this detail.
# We also assume that all the number entered will be positive, except -1 which means the end of entering

main:
   # $s0: Address for buffer， $s1: # of elements
   
   la $s0,buffer 
   add $a0,$s0,$0 # Pass the address of buffer as an argument for function call
   li $a1,400 # Size of buffer
   jal saisir
   add $s1,$v0,$0 # Number of elements
   
   li $t0,-1
   beq $s1,$t0,errorMessage # If the returned value if -1, there is an overflow. Terminate program
   
   add $a0,$s0,0
   add $a1,$s1,0
   jal afficher # Display original array
   
   add $a0,$s0,0
   add $a1,$s1,0
   jal trier # Sort the array
   
   add $a0,$s0,0
   add $a1,$s1,0
   jal afficher # Display the sorted array
   
   li $v0,10 
   syscall

errorMessage: # Display error message and terminate the program
   la $a0,msgError
   li $v0,4
   syscall
   li $v0,10
   syscall
   
saisir:
  add $t0,$a0,$0 # Save address of the array
  li $t1,0 # Number of element
  li $t2,-1
  
  div $t3,$a1,4 # Obtain the max number of elements
  
loopForSaisir:
  # Display message to enter the number	
  la $a0,msg 
  li $v0,4
  syscall
  
  li $v0,5
  syscall
  add $t4,$v0,$0 # Add entered number to $t4
  beq $t4,$t2,returnForSaisir # Entered -1, finish
  
  sw $t4,0($t0) # Save number to array
  addiu $t0,$t0,4 # Move to next address
  addi $t1,$t1,1 # Entered 1 more element, count++
  
  sub $t5,$t3,$t1 # Check if we have more than 100 elements
  bltz $t5,errorForSaisir
  j loopForSaisir

returnForSaisir:
  add $v0,$t1,$0
  jr $ra
  
errorForSaisir: # Return -1
  li $v0,-1
  jr $ra
  
trier:
	
  add $t1,$a0,$0 # Address of array
  add $t2,$a1,$0 # size of array
  
  subiu $sp,$sp,4 # Store the start address in stack so we can retrieve it later
  sw $t1,0($sp)

  # Check if we only have one or less than one element. If yes, no need to sort.
  subi $t0,$a1,1 
  blez $t0,returnForTrier 
  
  li $t0,1 # $t1 = Exchange (Bool), True = 1, False = 0  
  
whileLoopForTrier:
  beqz $t0, returnForTrier
  
  lw $t1,0($sp) # Retrieve the start address of the array
  li $t0,0
  li $t3,0 # Track how many elements have been traversed
  
forLoopTrier:
  lw $t4,0($t1) # t[i]
  lw $t5,4($t1) # t[i+1]
  
  sub $t6,$t5,$t4
  bltz $t6,exchange
  
continue:
  addi $t3,$t3,1 # Traversed +1 element
  sub $t7,$t3,$t2
  addi $t7,$t7,1
  beq $t7,$0,whileLoopForTrier # Verify if we have traversed len(t)-1 elements. If yes, no more loop needed. Go back to while
  
  addiu $t1,$t1,4 # Move to next address
  j forLoopTrier
  
exchange:
  # swap the content
  sw $t5,0($t1)
  sw $t4,4($t1)
  li $t0,1
  j continue
  
returnForTrier:
  addiu $sp,$sp,4
  jr $ra

afficher:

  # Check if we have entered any elements. If no, print nothing (Only \n symbol)
  beq $a1,$0,returnForAfficher 
  
  add $t0,$a0,$0 # Address for the first element
  add $t1,$a1,$0 # size of the array
   
  li $t2,0 # Keep track of how many number have been printed
  li $t3,4 # 4 numbers per line, constant to be used later 
  
loopForAfficher:
  lw $t4,0($t0) # access array item
  
  # Print out the number
  li $v0,1
  add $a0,$t4,$0
  syscall
  
  addi $t2,$t2,1 # +1 element printed
  
  beq $t1,$t2,returnForAfficher # Printed all the elements, stop
  
  rem $t5,$t2,$t3
  beq $t5,$0, printReturn # If we have printed 4 items perline, output a new line character
  
  # print tab
  la $a0,tab
  li $v0,4
  syscall
  
continueForAfficher:
  addi $t0,$t0,4 # next array tiem
  j loopForAfficher
  
printReturn:
  la $a0,newline
  li $v0,4
  syscall
  j continueForAfficher

returnForAfficher:
  la $a0,newline
  li $v0,4
  syscall
  jr $ra 
  
   
   
  
