.data
start: .word 0
head_node: .word 0
tail_node: .word 0
prev_node: .word 0

.text
_start:
    addi a0, zero, 0x52     # 'R' in HEX 52 (ASCII 82)
    jal ra, alloc_node
    sw a0, head_node
    sw a0, tail_node
    sw a0, prev_node

    addi a0, zero, 0x56     # 'V' in HEX 56 (ASCII 86)
    jal ra, alloc_node
    lw a1, prev_node
    jal ra, make_circular
    mv a1 a0
    lw a0, head_node
    jal ra, add_tail
    sw a1, tail_node
    sw a1, prev_node

    addi a0, zero, 0x49     # 'I' in HEX 49 (ASCII 73)
    jal ra, alloc_node 
    lw a1, prev_node
    jal ra, make_circular
    mv a1, a0
    lw a0, head_node
    jal ra, add_tail
    sw a1, tail_node
    sw a1, prev_node

    addi a0, zero, 0x53     # 'S' in HEX 53 (ASCII 83)
    jal ra, alloc_node
    lw a1, prev_node
    jal ra, make_circular
    mv a1, a0
    lw a0, head_node
    jal ra, add_tail
    sw a1, tail_node
    sw a1, prev_node

    addi a0, zero, 0x43     # 'C' in HEX 43 (ASCII 67)
    jal ra, alloc_node
    lw a1, prev_node
    jal ra, make_circular
    mv a1, a0
    lw a0, head_node
    jal ra, add_tail
    sw a1, tail_node
    sw a1, prev_node

    li a7, 10
    ecall



# a0 to be allocated
alloc_node:
    la t0, start            # Load the address of 'start' into t0
    lw t1, 0(t0)            # Load current value of 'start' (next free address)

    # Store value in the first byte of the node
    sb a0, 0(t1)            # Store the 8-bit value in byte 0 of the node

    addi t2, t1, 9          # Calculate the address for the next node
    sw t2, 0(t0)            # Update `start` with the new address

    #next
    sw t1, 1(t1)            # Set `next` to point to itself (offset 1)

    # Set `prev` pointer (self-reference initially)
    sw t1, 5(t1)            # Set `prev` to point to itself (offset 5)

    # Return new node address
    mv a0, t1               # Return the current node address in a0
    jalr zero, ra, 0        # Return from function



# a1 previous node
make_circular:
    la t0, start            # Load address of 'start' into t0
    lw t1, 0(t0)            # Load current value of 'start' (new node address)

    # Update previous node's `next` to point to new node
    sw t1, 1(a1)            # a1->next = t1 (new node)

    # Update new node's `prev` to point to previous node
    sw a1, 5(t1)            # t1->prev = a1 (previous node)

    # Return to caller
    jalr zero, ra, 0        # Return from function



# a0: Address of head node
# a1: Address of new node to be added to the tail
add_tail:
    # Load the current tail node using the head node
    lw t2, 5(a0)            # Load the 'prev' of head, which is the current tail (t2 = tail)

    # Update the current tail's next to point to the new node (a1)
    sw a1, 1(t2)            # t2->next = a1 (current tail's next points to new node)

    # Update the new node's prev to point to the current tail (t2)
    sw t2, 5(a1)            # a1->prev = t2 (new node's prev points to current tail)

    # Update the new node's next to point to the head (a0)
    sw a0, 1(a1)            # a1->next = a0 (new node's next points to head)

    # Update the head's prev to point to the new node (a1)
    sw a1, 5(a0)            # a0 ->prev = a1 (head's prev points to new node)

    # Return (No need to modify a0 since it's not changing the list address)
    jalr zero, ra, 0        # Return from the function
