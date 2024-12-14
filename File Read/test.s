.data
counts:    .space 104           # 26 integers (4 bytes each) initialized to 0
file_name: .asciiz "input.txt"  # Name of the input file
newline:   .asciiz "\n"         # For printing newline
buffer:    .space 1             # Temporary storage for one character

.text
.globl main

main:
    # Open file
    li a7, 56                # syscall: open
    la a0, file_name         # file name
    li a1, 0                 # read-only mode
    ecall
    mv t0, a0                # save file descriptor in t0

read_loop:
    # Read one character from the file
    li a7, 63                # syscall: read
    mv a0, t0                # file descriptor
    la a1, buffer            # buffer to store character
    li a2, 1                 # read 1 byte
    ecall

    # Check EOF
    beqz a0, end_read_loop   # If a0 == 0, end of file

    lb t1, buffer            # Load the character from buffer
    jal ra, check_and_count  # Process the character
    j read_loop              # Loop back to read the next character

end_read_loop:
    # Close file
    li a7, 57              # syscall: close
    mv a0, t0              # file descriptor
    ecall

    # Print counts
    li t0, 0               # Initialize index
print_loop:
    li t1, 26              # Total letters
    beq t0, t1, exit       # If index == 26, exit loop

    # Print letter
    addi t2, t0, 97        # ASCII 'a' + index
    mv a0, t2
    li a7, 11              # syscall: putchar
    ecall

    # Print count
    la t3, counts          # Load counts array base
    slli t4, t0, 2         # Multiply index by 4
    add t3, t3, t4         # Address of counts[t0]
    lw t4, 0(t3)           # Load count
    mv a0, t4
    li a7, 1               # syscall: print integer
    ecall

    # Print newline
    la a0, newline
    li a7, 4               # syscall: print string
    ecall

    # Increment index
    addi t0, t0, 1         # Increment
    j print_loop

exit:
    li a7, 10              # syscall: exit
    ecall

# Function: check_and_count
# Description: Check if the character is a letter, convert to lowercase if needed,
#              and increment the corresponding count in the array.
check_and_count:
    # Check if character is an uppercase letter
    li t2, 65               # ASCII 'A'
    li t3, 90               # ASCII 'Z'
    blt t1, t2, check_lower # If t1 < 'A', check lowercase
    bgt t1, t3, check_lower # If t1 > 'Z', check lowercase

    # Convert uppercase to lowercase
    addi t1, t1, 32         # 'A'-'Z' -> 'a'-'z'

check_lower:
    li t2, 97               # ASCII 'a'
    li t3, 122              # ASCII 'z'
    blt t1, t2, not_letter  # If t1 < 'a', not a letter
    bgt t1, t3, not_letter  # If t1 > 'z', not a letter

    # Map to index
    sub t1, t1, t2          # t1 = t1 - 'a'

    # Increment the corresponding count
    slli t1, t1, 2          # t1 = t1 * 4 (word offset)
    la t2, counts           # Base address of counts array
    add t2, t2, t1          # Address of counts[t1]
    lw t3, 0(t2)            # Load counts[t1]
    addi t3, t3, 1          # Increment count
    sw t3, 0(t2)            # Store updated count back

not_letter:
    ret
