.data
.align 4

filename:
	.asciz "test.txt"

bufferf:
    .space 2048 # buffer space (2kb)

.text
.globl _start

_start:
    # The file data will be read into bufferf
	la t1, bufferf
	
    # Open file
    li a0, -100                # AT_FDCWD
    la a1, filename            # File name
    li a2, 0                   # O_RDONLY
    li a7, 56                  # Syscall number for openat
    ecall
    bltz a0, exit_error        # Exit if open failed
    mv t0, a0                  # Save file descriptor in t0

read_loop:
    # Read from file
    mv a0, t0                  # File descriptor
    mv a1, t1                  # Buffer address
    li a2, 1024                # Buffer size (1kb)
    li a7, 63                  # Syscall number for read
    ecall
    bltz a0, read_error        # Exit if read failed
    beqz a0, close_file        # End of file (read 0 bytes)
    mv a2,a0                   # Bytes to print

    li t3, 0             # count words
    li t4, 0             # count sentences
    li t5, 0             # index through buffer
    li s1, 0             # previous byte
    li s2, 0             # flag for the first byte

count_spaces:
    mv s1, t5            # Load previous byte 
    lb t5, 0(t1)         # Load byte from buffer
    beqz t5, done_count  # If the byte is 0 (end of string), exit loop

    li t6, 32            # space in ASCII
    beq t5, t6, increment_space
    
    li t6, 46            # . in ASCII
    beq t5, t6, increment_sentence
    li t6, 33            # ! in ASCII
    beq t5, t6, increment_sentence
    li t6, 63            # ? in ASCII
    beq t5, t6, increment_sentence

    skip:
    addi t1, t1, 1       # Move buffer pointer to next byte
    li s2, 1
    j count_spaces

increment_space:
    beq s2, zero, skip
    beq s1, t5, skip
    addi t3, t3, 1       # Increment space counter
    addi t1, t1, 1       # Move buffer pointer to next byte
    j count_spaces

increment_sentence:
    beq s2, zero, skip
    beq s1, t5, skip
    addi t4, t4, 1
    addi t1, t1, 1
    j count_spaces

done_count:
    # Write to stdout
    li a0, 1                   # Stdout file descriptor
    la a1, bufferf             # load buffer again
    li a7, 64                  # Syscall number for write
    ecall
    bltz a0, write_error       # Exit if write failed

    j read_loop                # Continue reading

close_file:
    # Close the file
    mv a0, t0                  # File descriptor
    li a7, 57                  # Syscall number for close
    ecall

    # print the word count
    add a0, zero, t3
    la a1, bufferf
    call itoa
    li a7, 64
    li a0, 1
    la a1, bufferf
    li a2, 3
    ecall

    # print the sentence count
    add a0, zero, t4
    la a1, bufferf
    call itoa
    li a7, 64
    li a0, 1
    la a1, bufferf
    li a2, 3
    ecall

    # Exit successfully
    li a0, 0
    li a7, 93
    ecall

read_error:
write_error:
exit_error:
    li a0, 1
    li a7, 93
    ecall

# integer to ASCII
itoa:
    # Simple conversion for a two-digit number
    li t0, 10               # Load divisor 10 into t0
    divu t1, a0, t0         # Divide a0 by 10, result in t1 (quotient)
    remu t2, a0, t0         # Get remainder of a0 / 10, result in t2 (last digit)

    addi t1, t1, '0'        # Convert first digit to ASCII
    sb t1, 0(a1)            # Store first digit at buffer

    addi t2, t2, '0'        # Convert second digit to ASCII
    sb t2, 1(a1)            # Store second digit at buffer + 1

    li t3, '\n'             # Newline character
    sb t3, 2(a1)            # Store newline at buffer + 2

    ret                     # Return from function