# Global data
.data
  # Buffer reserved for data
  buffer: .space 400
  # Message
  msg:	.asciiz "Entrer un nombre:"
  msgError: .asciiz "Depassement d'espace"
  tab: .asciiz "\t"
  newline: .asciiz "\n"
.text
main:
   # $s0: Address for buffer， $s1: # of elements
   la $s0,buffer 
   add $a0,$s0,$0 # Pass the address of buffer as an argument for function call
   li $a1,400 # Size of buffer
   jal saisir
   add $s1,$v0,$0 # Number of elements
   
   li $t0,-1
   beq $s1,$t0,errorMessage # If the returned value if -1, there is an overflow. Terminate program
   
   jal afficher # Display original array
   jal trier # Sort the array
   
   lw $s0,0($sp) # Retreive the original address of array
   addiu $sp,$sp,4 # Restore the stack pointer
   
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
   add $t0,$a0,$0 # Save address for buffer
   li $t1,0 # Number of element
   li $t2,-1 
   li $t3,100 # Max number of elements
loopForSaisir:

   # Display message to enter the number	
   la $a0,msg 
   li $v0,4
   syscall
    
   li $v0,5
   syscall
   add $t4,$v0,$0 # Add entered number to $t2
   beq $t4,$t2,returnForSaisir # Entered -1, finish
   
   sw $t4,0($t0) # Save the number to array
   addiu $t0,$t0,4 # Move to next address
   addi $t1,$t1,1 # Entered 1 more element
   
   sub $t5,$t3,$t1 # Compare if we have more than 100 elements
   bltz $t5,errorForSaisir
   j loopForSaisir
   
returnForSaisir:
   add $v0,$t1,$0
   jr $ra
   
errorForSaisir: # Return -1
   li $v0,-1
   jr $ra

trier:
   li $t0,1 # Exchange, True = 1, False = 0
   
   subiu $sp,$sp,4 # Store the start address in stack so we can retrieve it later
   sw $s0,0($sp)
   
whileLoopForTrier:
   beqz $t0, returnForTrier
   
   lw $s0,0($sp) # Retrieve the start address of the array
   li $t0,0
   li $t1,0 # Track how many elements have been traversed
forLoopTrier:
   
   lw $t2,0($s0) # t[i]
   lw $t3,4($s0) # t[i+1]
   
   sub $t4,$t3,$t2
   bltz $t4,exchange
  
continue:
   addi $t1,$t1,1 # Traversed + 1 element
   sub $t5,$t1,$s1
   addi $t5,$t5,1
   beq $t5,$0,whileLoopForTrier # Verify if we have traversed len(t)-1 elements. If yes, no more loop needed. Go back to while
   
   addiu $s0,$s0,4 # Move to next address
   j forLoopTrier # Need to compare more. Start again foor loop
   
exchange:
   # swap the content
   sw $t3,0($s0) 
   sw $t2,4($s0)
   li $t0,1 
   j continue
   
returnForTrier:
   jr $ra
 
afficher:
   add $t0,$s0,$0
   
   li $t1,0 # Keep track of how many number have been printed
   li $t2,4 # 4 numbers per line, constant to be used later
   
loopForAfficher:
   lw $t3,0($t0) # access array item
   
   # Print out the number
   li $v0,1
   add $a0,$t3,$0
   syscall 
   
   addi $t1,$t1,1 # Printed one more element
   
   beq $s1,$t1,returnForAfficher # Have already printed all elements, stop 
   
   rem $t4, $t1,$t2  
   beq $t4,$0,printReturn # If we have printed 4 items per line, Output a newline character
   
   #print tab
   la $a0,tab
   li $v0,4
   syscall
   
continueForAfficher:
   addi $t0,$t0,4 # next array item
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
   
   