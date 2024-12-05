.data
.align 4
filename:
	.asciz "test.txt"

bufferf:
    .space 2048                # buffer space (2KB)

word_count:
    .word 0                    # Word count variable

error_msg:
	.asciz "Error: Read failed.\n"  # This message is not used but kept for error handling

.text
.globl _start

_start:
    # Initialize word count to 0
    li t2, 0                    # t2 will hold the word count (initialize it to 0)

    # The file data will be read into bufferf
	la t1, bufferf              # Load address of bufferf into t1
	
    # Open file
    li a0, -100                 # AT_FDCWD
    la a1, filename             # File name
    li a2, 0                    # O_RDONLY
    li a7, 56                   # Syscall number for openat
    ecall
    bltz a0, exit_error         # Exit if open failed
    mv t0, a0                   # Save file descriptor in t0

read_loop:
    # Read from file
    mv a0, t0                   # File descriptor
    mv a1, t1                   # Buffer address
    li a2, 1024                 # Buffer size (1024 bytes)
    li a7, 63                   # Syscall number for read
    ecall
    bltz a0, read_error         # Exit if read failed
    beqz a0, close_file         # End of file (read 0 bytes)
    mv a2, a0                   # Store number of bytes read in a2

    # Count words in the buffer
    li t3, 0                    # t3 will hold the word-in-progress flag (0: no word, 1: inside a word)
    li t4, 0                    # t4 will hold the local word count for this chunk

count_words:
    lb t5, 0(t1)                # Load byte from buffer (bufferf)
    beqz t5, done_counting      # If we reached the end of buffer, stop counting
    addi t1, t1, 1              # Increment buffer address
    li t6, 32                   # ASCII space (delimiter for words)

    # Check if character is a space or newline (word boundary)
    beq t5, t6, word_boundary   # If space, handle word boundary
    li t6, 10                   # ASCII newline
    beq t5, t6, word_boundary   # If newline, handle word boundary

    # If inside a word, continue
    beqz t3, not_in_word
    j continue_counting

word_boundary:
    # If not inside a word, it's a new word
    beqz t3, not_a_new_word
    li t3, 0                    # Word boundary encountered, no longer in word
    j continue_counting

not_a_new_word:
    # If currently not in word, this is a new word
    li t3, 1                    # We are now in a word
    addi t4, t4, 1              # Increment local word count

continue_counting:
    # Decrement remaining bytes to read (move to next byte in buffer)
    sub a2, a2, 1
    bnez a2, count_words        # If there are more bytes, continue counting

done_counting:
    # Add local word count to global word count (t2)
    add t2, t2, t4              # Add the word count from this chunk to the total word count

    # Write to stdout (optional)
    # You can choose to print progress here, if needed

    j read_loop                 # Continue reading the file

close_file:
    # Close the file
    mv a0, t0                   # File descriptor
    li a7, 57                   # Syscall number for close
    ecall

    # Print the word count to stdout
    li a0, 1                    # Stdout file descriptor
    li a7, 64                   # Syscall number for write
    la a1, word_count           # Load address of word count variable
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
