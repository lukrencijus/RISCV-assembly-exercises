.data
.align 4
filename:
    .asciz "test.txt"

bufferf:
    .space 2048                  # buffer space (2KB)

word_count:
    .word 0                      # Word count variable

error_msg:
    .asciz "Error: Read failed.\n"
    # this is not used

.text
.globl _start

_start:
    # The file data will be read into bufferf
    la t1, bufferf

    li t2, 0                      # t2 will hold the word count (initialize it to 0)

    # Open file
    li a0, -100                    # AT_FDCWD
    la a1, filename                # File name
    li a2, 0                       # O_RDONLY
    li a7, 56                      # Syscall number for openat
    ecall
    bltz a0, exit_error            # Exit if open failed
    mv t0, a0                      # Save file descriptor in t0

read_loop:
    # Read from file
    mv a0, t0                      # File descriptor
    mv a1, t1                      # Buffer address
    li a2, 1024                    # Buffer size
    li a7, 63                      # Syscall number for read
    ecall
    bltz a0, read_error            # Exit if read failed
    beqz a0, close_file            # End of file (read 0 bytes)

    # Set up buffer traversal
    mv t3, t1                      # Start of buffer for traversal
    add t2, t1, a0                 # End of buffer (t1 + bytes read)

process_buffer:
    # Check if we reached the end of the buffer
    bge t3, t2, read_loop          # If buffer processed, read more data

    lb t5, 0(t3)                   # Load the current byte from the buffer
    addi t3, t3, 1                 # Move to the next character

    # Check for word boundaries (space or newline)
    li t6, 32                      # ASCII code for space
    beq t5, t6, increment_word_count
    li t6, 10                      # ASCII code for newline
    beq t5, t6, increment_word_count

    # Not a word boundary; continue processing
    j process_buffer

increment_word_count:
    la a0, word_count              # Load the address of word_count
    lw a1, 0(a0)                   # Load the current word count
    addi a1, a1, 1                 # Increment the word count
    sw a1, 0(a0)                   # Store the updated word count
    j process_buffer               # Continue processing buffer

close_file:
    # Close the file
    mv a0, t0                      # File descriptor
    li a7, 57                      # Syscall number for close
    ecall

    # Convert the word count to string for printing
    la a0, word_count              # Load the address of word_count
    lw a1, 0(a0)                   # Load the current word count
    call int_to_string             # Convert integer to string in a0

    # Write the word count
    li a7, 64                      # Syscall number for write
    li a0, 1                       # File descriptor 1 (stdout)
    ecall

    # Exit successfully
    li a0, 0
    li a7, 93                      # Syscall number for exit
    ecall

read_error:
    # Print read error message
    li a0, 1                       # File descriptor 1 (stdout)
    la a1, error_msg               # Load address of error message
    li a2, 19                      # Length of the error message
    li a7, 64                      # Syscall number for write
    ecall

    j exit_error                   # Jump to exit error

write_error:
    # Print write error message
    li a0, 1                       # File descriptor 1 (stdout)
    la a1, error_msg               # Load address of error message
    li a2, 19                      # Length of the error message
    li a7, 64                      # Syscall number for write
    ecall

    j exit_error                   # Jump to exit error

exit_error:
    # Exit the program with status 1 (error)
    li a0, 1
    li a7, 93                      # Syscall number for exit
    ecall

# Helper function to convert integer to string (int_to_string)
int_to_string:
    addi sp, sp, -16               # Make space for local variables
    sw ra, 12(sp)                   # Save return address
    sw a0, 8(sp)                    # Save integer to convert

    li t0, 10                      # Set base to 10 (decimal)
    li t1, 0                       # Initialize string index
    li t2, 0                       # Initialize sign (0 means positive)

convert_loop:
    lw t3, 8(sp)                   # Load number to convert
    div t3, t3, t0                 # Divide number by 10
    mfhi t4                        # Remainder (digit)
    addi t4, t4, 48                # Convert to ASCII
    sb t4, 0(a0)                   # Store the digit in the string
    addi a0, a0, 1                 # Move to the next character in the string
    bnez t3, convert_loop          # Continue if number is not zero

    sb zero, 0(a0)                 # Null-terminate the string
    lw ra, 12(sp)                   # Restore return address
    addi sp, sp, 16                # Restore stack pointer
    jr ra                          # Return
