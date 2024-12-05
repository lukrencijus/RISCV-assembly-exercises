.data
.align 4
filename:
	.asciz "test.txt"

bufferf:
    .space 2048 # buffer space (2kb)

word_count:
    .word 0                    # Word count variable

error_msg:
	.asciz "Error: Read failed.\n"
    # this is not used

.text
.globl _start

_start:
    # The file data will be read into bufferf
	la t1, bufferf

    li t2, 0                    # t2 will hold the word count (initialize it to 0)
	
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
    li a2, 1024                # Buffer size
    li a7, 63                  # Syscall number for read
    ecall
    bltz a0, read_error        # Exit if read failed
    beqz a0, close_file        # End of file (read 0 bytes)

    # Set up buffer traversal
    mv t3, t1                  # Start of buffer for traversal
    add t2, t1, a0             # End of buffer (t1 + bytes read)

process_buffer:
    # Check if we reached the end of the buffer
    beq t3, t2, read_loop      # If buffer processed, read more data

    lb t5, 0(t3)               # Load the current byte from the buffer
    beqz t5, close_file        # Check if this is the end of the file
    addi t3, t3, 1             # Move to the next character

    # Check for word boundaries (space or newline)
    li t6, 32                  # ASCII code for space
    beq t5, t6, increment_word_count
    li t6, 10                  # ASCII code for newline
    beq t5, t6, increment_word_count

    # Not a word boundary; continue processing
    j process_buffer

increment_word_count:
    la a0, word_count          # Load the address of word_count
    lw a1, 0(a0)               # Load the current word count
    addi a1, a1, 1             # Increment the word count
    sw a1, 0(a0)               # Store the updated word count
    j process_buffer           # Continue processing buffer

close_file:
    # Close the file
    mv a0, t0                  # File descriptor
    li a7, 57                  # Syscall number for close
    ecall

    # write word count
    la a1, word_count
    lw a0, 0(a1)
    li a7, 1
    ecall

    # Exit successfully
    li a0, 0
    li a7, 93
    ecall

read_error:
    li a0, 1
    li a7, 93
    ecall
write_error:
    li a0, 1
    li a7, 93
    ecall
exit_error:
    li a0, 1
    li a7, 93
    ecall