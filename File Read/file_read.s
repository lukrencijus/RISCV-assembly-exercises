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
	la t1, bufferf
	
    # Open file
    li a0, -100                # Current working directory
    la a1, filename            # File name
    li a2, 0                   # Read-only mode
    li a7, 56                  # Syscall number for openat
    ecall
    bltz a0, exit_error        # Exit if open failed

read_loop:
    # Read from file
    la a1, bufferf
    li a2, 2048                # Buffer size (2kb)
    li a7, 63                  # Syscall number for read
    ecall
    bltz a0, read_error        # Exit if read failed
    beqz a0, close_file        # End of file (read 0 bytes)

    li t3, 1                   # Count words
    li t4, 0                   # Count sentences
    li t5, 0                   # Index through buffer
    li s1, 0                   # Previous byte
    li s2, 0                   # Flag for the first byte

    li s3, 'A'
    li s4, 'Z'
    li s5, 'a'
    li s6, 'z'
    li s8, 0                   # Uppercase letter counter
    li s9, 0                   # Lowercase letter counter

count_everything:
    mv s1, t5                  # Load previous byte 
    lb t5, 0(t1)               # Load byte from buffer
    beqz t5, done_count        # If the byte is 0 (end of string), exit loop

    li t6, 32                  # Space in ASCII
    beq t5, t6, increment_space
    li t6, 10                  # New line in ASCII
    beq t5, t6, increment_space
    
    li t6, 46                  # . in ASCII
    beq t5, t6, increment_sentence
    li t6, 33                  # ! in ASCII
    beq t5, t6, increment_sentence
    li t6, 63                  # ? in ASCII
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
    li s2, 1                   # Flag we are no longer in first bit    
    j count_everything

increment_space:
    beq s2, zero, skip         # If bit is the first bit - we skip
    beq s1, t5, skip           # If bit is the same as last bit - we skip
    addi t3, t3, 1             # Increment space counter
    addi t1, t1, 1             # Move buffer pointer to next byte
    j count_everything

increment_sentence:
    beq s2, zero, skip         # If bit is the first bit - we skip
    beq s1, t5, skip           # If bit is the same as last bit - we skip
    addi t4, t4, 1             # Increment sentence counter
    addi t1, t1, 1             # Move buffer pointer to next byte
    j count_everything

add_last:
    addi t3, t3, -1            # Lower the word counter
    j write
    
done_count:
    # Check if last bit was space or new line - lower word counter
    li t6, 32                   # Space in ASCII
    beq s1, t6, add_last
    li t6, 10                   # New line in ASCII
    beq s1, t6, add_last

write:
    # Comment next line if you want to print the text from file
    beq zero, zero, close_file
    li a0, STDOUT              # Stdout file descriptor
    la a1, bufferf             # Load buffer again
    li a7, SYS_WRITE           # Syscall number for write
    ecall
    bltz a0, write_error       # Exit if write failed

    j read_loop                # Continue reading

close_file:
    # Close the file
    mv a0, t0                  # File descriptor
    li a7, 57                  # Syscall number for close
    ecall

    # print string "Word count: "
    li a0, STDOUT              # File descriptor, 1
    la a1, word_count          # Address of the message
    lbu a2, l_word_count       # Length of string
    li a7, SYS_WRITE           # System call code for write
    ecall                      # Make the syscall
    # print the word count
    add a0, zero, t3
    jal ra, print

    # print string "Sentence count: "
    li a0, STDOUT              # File descriptor, 1
    la a1, sentence_count      # Address of the message
    lbu a2, l_sentence_count   # Length of string
    li a7, SYS_WRITE           # System call code for write
    ecall                      # Make the syscall
    # print the sentence count
    add a0, zero, t4
    jal ra, print

    # print string "Uppercase letter count: "
    li a0, STDOUT              # File descriptor, 1
    la a1, uppercase_count     # Address of the message
    lbu a2, l_uppercase_count  # Length of string
    li a7, SYS_WRITE           # System call code for write
    ecall                      # Make the syscall
    # print the uppercase letter count
    add a0, zero, s8
    jal ra, print

    # print string "Lowercase letter count: "
    li a0, STDOUT              # File descriptor, 1
    la a1, lowercase_count     # Address of the message
    lbu a2, l_lowercase_count  # Length of string
    li a7, SYS_WRITE           # System call code for write
    ecall                      # Make the syscall
    # print the lowercase letter count
    add a0, zero, s9
    jal ra, print

    # Exit successfully
    li a0, 0
    li a7, EXIT
    ecall

# Exit unsuccessfully
read_error:
write_error:
exit_error:
    li a0, 1
    li a7, EXIT
    ecall

# Print ASCII integers
print:
    add s11, zero, ra
    la a1, bufferf
    call itoa
    li a7, SYS_WRITE
    li a0, STDOUT
    la a1, bufferf
    li a2, 5
    ecall
    add ra, zero, s11
    ret

# integer to ASCII
itoa:
    # Conversion for a four-digit number
    li s0, 1000               # Load divisor 1000 into s0
    divu s1, a0, s0           # Divide a0 by 1000, result in s1 (thousands place)
    remu s2, a0, s0           # Get remainder of a0 / 1000, result in s2

    li s0, 100                # Load divisor 100 into s0
    divu s3, s2, s0           # Divide s2 by 100, result in s3 (hundreds place)
    remu s4, s2, s0           # Get remainder of s2 / 100, result in s4

    li s0, 10                 # Load divisor 10 into s0
    divu s5, s4, s0           # Divide s4 by 10, result in s5 (tens place)
    remu s6, s4, s0           # Get remainder of s4 / 10, result in s6 (ones place)

    addi s1, s1, '0'          # Convert thousands digit to ASCII
    sb s1, 0(a1)              # Store thousands digit at buffer

    addi s3, s3, '0'          # Convert hundreds digit to ASCII
    sb s3, 1(a1)              # Store hundreds digit at buffer + 1

    addi s5, s5, '0'          # Convert tens digit to ASCII
    sb s5, 2(a1)              # Store tens digit at buffer + 2

    addi s6, s6, '0'          # Convert ones digit to ASCII
    sb s6, 3(a1)              # Store ones digit at buffer + 3

    li s7, '\n'               # Newline character
    sb s7, 4(a1)              # Store newline at buffer + 4

    ret                       # Return from function
