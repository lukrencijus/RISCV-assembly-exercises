    .section .data
buffer: .space 16           # Allocate space for up to 16 characters, including a null terminator

    .section .text
    .globl _start

_start:
    # Step 1: Load the number 13 into register a0
    li a0, 13               # Load the number 13 into a0

    # Step 2: Convert integer in a0 to string and store in buffer
    la a1, buffer           # Load address of buffer into a1
    call itoa               # Call function to convert integer to string

    # Step 3: Use sys_write to print the string
    li a7, 64               # System call number for sys_write (64)
    li a0, 1                # File descriptor 1 (stdout)
    la a1, buffer           # Load the address of the buffer containing the string representation
    li a2, 3                # Length of string "13\n" is 3 bytes
    ecall                   # Make the system call

    # Step 4: Exit the program
    li a7, 93               # System call number for sys_exit (93)
    li a0, 0                # Exit status 0 (success)
    ecall                   # Exit the program

# Function: itoa - Converts an integer in a0 to a string in a1 (buffer)
# a0: The integer to convert
# a1: The address of the buffer to store the string
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
