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

    mv t3, t1                # Use t3 to traverse the buffer
    # nes mums reikes t1 kad sugrizti
count_words:
    lb t5, 0(t3)               # uzsikrauname viena char is buffer
    beqz t5, close_file     # patikrinam ar nepasibaige buferis
    addi t3, t3, 1             # pasiruosiame kitam char

    # check if char is space or new line
    li t6, 32                  # space in ASCII
    beq t5, t6, there_is_a_word
    li t6, 10                  # new line in ASCII
    beq t5, t6, there_is_a_word

    j count_words # if it is not a space or new line we must continue

there_is_a_word:
    la   a0, word_count      # Load the address of word_count into register a0
    lw   a1, 0(a0)           # Load the current word count into register a1
    addi a1, a1, 1           # Increment the word count by 1 (a1 = a1 + 1)
    sw   a1, 0(a0)           # Store the updated word count back to memory
    j count_words

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

    # write word count
    la   a0, word_count      # Load address of word_count into a0
    lw   a1, 0(a0)           # Load word count value into a1

    li   a0, 1               # File descriptor 1 (stdout)
    li   a7, 64              # Syscall number for 'write' (64 is the syscall number for `write`)
    ecall                    # Make the syscall to print the integer

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