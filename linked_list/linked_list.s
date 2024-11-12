.data
start: .word 0          # Memory pointer for free memory, initially 0

.text
_start:
    la t0, start        
    li t1, 0x80000000    
    sw t1, 0(t0)         

    addi a0, zero, 0x52 	# 'R' (ASCII 82)
    jal ra, alloc_node

alloc_node:
    la t0, start         # Address of the `start` pointer
    lw t1, 0(t0)         # Load the current free memory position

    addi t2, t1, 12      # Calculate the new memory address
    sw t2, 0(t0)         # Update the `start` pointer to the new position


    addi t3, zero, 0xA   # MSByte for `val` = 0xA
    slli t3, t3, 8       # Shift left to set as MSByte
    or t3, t3, a0        # Combine MSByte with input value in a0
    sb t3, 0(t1)         # Store the `val` at offset 0 (1 byte)

    sw t1, 4(t1)         # Set `next` pointer to itself

    sw t1, 8(t1)         # Set `prev` pointer to itself

    mv a0, t1            # Return the start address of the node
    jalr zero, ra, 0     # Return to the caller