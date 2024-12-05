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
    mv a2, a0                  # Bytes to print

    # Count words in the buffer
    li t3, 0                    # t3 word-in-progress flag (0: no word, 1: inside a word)
    li t4, 0                    # t4 the local word count for this chunk

count_words:
    lb t5, 0(t1)               # uzsikrauname viena char is buffer
    beqz t5, done_counting     # patikrinam ar nepasibaige buferis
    addi t1, t1, 1             # pasiruosiame kitam char

    # check if char is space or new line
    li t6, 32                  # space in ASCII
    beq t5, t6, word_boundry
    li t6, 10                  # new line in ASCII
    beq t5, t6 word_boundry

    # if it is not a space or new line we must continue
    # if we are inside a word, continue
    beqz t3, not_in_word #pakeisti i count_words?
    j continue_counting

word_boundry:
    beqz t3, not_a_new_word
    li t3, 0
    j continue_counting

not_a_new_word:
    li t3, 1
    addi t4, t4, 1

continue_counting:
    addi a2, a2, -1
    bnez a2, count_words

done_counting:
    add t2, t2, t4
    j read_loop

close_file:
    # Close the file
    mv a0, t0                  # File descriptor
    li a7, 57                  # Syscall number for close
    ecall


    # Write to stdout
    li a0, 1                   # Stdout file descriptor
    mv a1, t1                  # Buffer address
    li a7, 64                  # Syscall number for write
    ecall
    bltz a0, write_error       # Exit if write failed

    # write word count
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