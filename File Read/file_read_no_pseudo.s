.equ STDOUT, 1
.equ SYS_WRITE, 64
.equ EXIT, 93

.data
.align 4

bufferf:
    .space 2048                # Buffer space (2kb)

.section .rodata
.align 2

filename:
	.asciz "test.txt"

word_count:
    .ascii  "\nWord count: "
l_word_count:
    .byte   .-word_count

sentence_count:
    .ascii  "Sentence count: "
l_sentence_count:
    .byte   .-sentence_count

uppercase_count:
    .ascii  "Uppercase letter count: "
l_uppercase_count:
    .byte   .-uppercase_count

lowercase_count:
    .ascii  "Lowercase letter count: "
l_lowercase_count:
    .byte   .-lowercase_count

.text
.globl _start

_start:
    # The file data will be read into bufferf
    lui t1, %hi(bufferf)
    addi t1, t1, %lo(bufferf)
	
    # Open file           
    addi a0, x0, -100          # Current working directory         
    lui a1, %hi(filename)      # File name
    addi a1, a1, %lo(filename)               
    addi a2, x0, 0             # Read-only mode              
    addi a7, x0, 56            # Syscall number for openat
    ecall     
    blt a0, x0, exit_error     # Exit if open failed

read_loop:
    # Read from file
    lui a1, %hi(bufferf)
    addi a1, a1, %lo(bufferf)             
    # Buffer size (2kb)
    lui a2, 1                  # Load upper immediate with 1, which represents 1 << 12 = 4096
    addi a2, a2, -2048         # Subtract 2048 to adjust the value down to 2048                       
    addi a7, x0, 63            # Syscall number for read
    ecall     
    blt a0, x0, read_error     # Exit if read failed
    beq a0, x0, close_file     # End of file (read 0 bytes)
              
    addi t3, x0, 1             # Count words            
    addi t4, x0, 0             # Count sentences                 
    addi t5, x0, 0             # Index through buffer                
    addi s1, x0, 0             # Previous byte               
    addi s2, x0, 0             # Flag for the first byte

    addi s3, x0, 65            # 'A' in ASCII
    addi s4, x0, 90            # 'Z' in ASCII
    addi s5, x0, 97            # 'a' in ASCII
    addi s6, x0, 122           # 'z' in ASCII              
    addi s8, x0, 0             # Uppercase letter counter                 
    addi s9, x0, 0             # Lowercase letter counter

count_everything:
    addi s1, t5, 0             # Load previous byte
    lb t5, 0(t1)               # Load byte from buffer     
    beq t5, x0, done_count     # If the byte is 0 (end of string), exit loop
              
    addi t6, x0, 32            # Space in ASCII
    beq t5, t6, increment_space               
    addi t6, x0, 10            # New line in ASCII
    beq t5, t6, increment_space
                
    addi t6, x0, 46            # . in ASCII
    beq t5, t6, increment_sentence              
    addi t6, x0, 33            # ! in ASCII
    beq t5, t6, increment_sentence                
    addi t6, x0, 63            # ? in ASCII
    beq t5, t6, increment_sentence

    blt t5, s3, go             # Check uppercase letters
    bgt t5, s4, go
    addi s8, s8, 1             # Increment uppercase letter counter

go:
    blt t5, s5, skip           # Check lowercase letters 
    bgt t5, s6, skip
    addi s9, s9, 1             # Increment lowercase letter counter

skip:
    addi t1, t1, 1             # Move buffer pointer to next byte              
    addi s2, x0, 1             # Flag we are no longer in first bit
    jal x0, count_everything

increment_space:
    beq s2, zero, skip         # If bit is the first bit - we skip
    beq s1, t5, skip           # If bit is the same as last bit - we skip
    addi t3, t3, 1             # Increment space counter
    addi t1, t1, 1             # Move buffer pointer to next byte
    jal x0, count_everything

increment_sentence:
    beq s2, zero, skip         # If bit is the first bit - we skip
    beq s1, t5, skip           # If bit is the same as last bit - we skip
    addi t4, t4, 1             # Increment sentence counter
    addi t1, t1, 1             # Move buffer pointer to next byte
    jal x0, count_everything

add_last:
    addi t3, t3, -1            # Lower the word counter
    jal x0, write
    
done_count:
    # Check if last bit was space or new line - lower word counter              
    addi t6, x0, 32            # Space in ASCII
    beq s1, t6, add_last               
    addi t6, x0, 10            # New line in ASCII
    beq s1, t6, add_last

write:
    # Comment next line if you want to print the text from file
    beq zero, zero, close_file        
    addi a0, x0, STDOUT        # Stdout file descriptor         
    lui a1, %hi(bufferf)       # Load buffer again
    addi a1, a1, %lo(bufferf)       
    addi a7, x0, SYS_WRITE     # Syscall number for write
    ecall   
    blt a0, x0, write_error    # Exit if write failed
    jal x0, read_loop          # Continue reading

close_file:
    # Close the file             
    addi a0, t0, 0             # File descriptor              
    addi a7, x0, 57            # Syscall number for close
    ecall

    # print string "Word count: "            
    addi a0, x0, STDOUT        # File descriptor, 1       
    lui a1, %hi(word_count)    # Address of the message
    addi a1, a1, %lo(word_count)
    lbu a2, l_word_count       # Length of string         
    addi a7, x0, SYS_WRITE     # System call code for write
    ecall                      # Make the syscall
    # print the word count
    add a0, zero, t3
    jal ra, print

    # print string "Sentence count: "
    addi a0, x0, STDOUT        # File descriptor, 1   
    lui a1, %hi(sentence_count)# Address of the message
    addi a1, a1, %lo(sentence_count)
    lbu a2, l_sentence_count   # Length of string
    addi a7, x0, SYS_WRITE     # System call code for write
    ecall                      # Make the syscall
    # print the sentence count
    add a0, zero, t4
    jal ra, print

    # print string "Uppercase letter count: "
    addi a0, x0, STDOUT        # File descriptor, 1  
    lui a1, %hi(uppercase_count)# Address of the message
    addi a1, a1, %lo(uppercase_count)
    lbu a2, l_uppercase_count  # Length of string
    addi a7, x0, SYS_WRITE     # System call code for write
    ecall                      # Make the syscall
    # print the uppercase letter count
    add a0, zero, s8
    jal ra, print

    # print string "Lowercase letter count: "
    addi a0, x0, STDOUT        # File descriptor, 1  
    lui a1, %hi(lowercase_count)# Address of the message
    addi a1, a1, %lo(lowercase_count)
    lbu a2, l_lowercase_count  # Length of string
    addi a7, x0, SYS_WRITE     # System call code for write
    ecall                      # Make the syscall
    # print the lowercase letter count
    add a0, zero, s9
    jal ra, print

    # Exit successfully
    addi a0, x0, 0
    addi a7, x0, EXIT
    ecall

# Exit unsuccessfully
read_error:
write_error:
exit_error:
    addi a0, x0, 1
    addi a7, x0, EXIT
    ecall

# Print ASCII integers
print:
    add s11, zero, ra
    lui a1, %hi(bufferf)
    addi a1, a1, %lo(bufferf)
    lui ra, %hi(itoa)          # Load the upper 20 bits of the absolute address of 'itoa'
    addi ra, ra, %lo(itoa)     # Add the lower 12 bits to complete the address
    jalr ra                    # Jump to the address
    addi a7, x0, SYS_WRITE
    addi a0, x0, STDOUT
    lui a1, %hi(bufferf)
    addi a1, a1, %lo(bufferf)
    addi a2, x0, 5             # 5 = 0000 + \n
    ecall
    add ra, zero, s11
    jalr x0, ra, 0

# integer to ASCII
itoa:
    # Conversion for a four-digit number          
    addi s0, x0, 1000          # Load divisor 1000 into s0
    divu s1, a0, s0            # Divide a0 by 1000, result in s1 (thousands place)
    remu s2, a0, s0            # Get remainder of a0 / 1000, result in s2
          
    addi s0, x0, 100           # Load divisor 100 into s0
    divu s3, s2, s0            # Divide s2 by 100, result in s3 (hundreds place)
    remu s4, s2, s0            # Get remainder of s2 / 100, result in s4
               
    addi s0, x0, 10            # Load divisor 10 into s0
    divu s5, s4, s0            # Divide s4 by 10, result in s5 (tens place)
    remu s6, s4, s0            # Get remainder of s4 / 10, result in s6 (ones place)

    addi s1, s1, '0'           # Convert thousands digit to ASCII
    sb s1, 0(a1)               # Store thousands digit at buffer

    addi s3, s3, '0'           # Convert hundreds digit to ASCII
    sb s3, 1(a1)               # Store hundreds digit at buffer + 1

    addi s5, s5, '0'           # Convert tens digit to ASCII
    sb s5, 2(a1)               # Store tens digit at buffer + 2

    addi s6, s6, '0'           # Convert ones digit to ASCII
    sb s6, 3(a1)               # Store ones digit at buffer + 3

    addi s7, x0, 10            # New line in ASCII
    sb s7, 4(a1)               # Store newline at buffer + 4

    jalr x0, ra, 0             # Return from function
