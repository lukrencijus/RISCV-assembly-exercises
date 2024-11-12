.data
start: .word 0              # Keeps track of current memory allocation address
head_node: .word 0          # Points to the head node of the list
tail_node: .word 0          # Points to the tail node of the list

.text
# Main Function to create nodes and build list
_start:
    # Allocate the first node ('R') and set it as head and tail
    addi a0, zero, 0x52     # 'R' in HEX 52 (ASCII 82)
    addi a1, zero, 0        # First node, no previous node yet
    jal ra, alloc_node
    sw a0, head_node
    sw a0, tail_node

    # Allocate the second node ('V') and add it to the tail
    addi a0, zero, 0x56     # 'V' in HEX 56 (ASCII 86)
    jal ra, alloc_node      # Allocate new node ('V')
    mv a1, a0               # a1 = address of newly allocated node
    lw a0, head_node        # Load head node address into a0
    jal ra, add_tail        # Add new node ('V') to the tail
    sw a1, tail_node        # Update tail to the new node

    # Allocate the third node ('I') and add it to the tail
    addi a0, zero, 0x49     # 'I' in HEX 49 (ASCII 73)
    jal ra, alloc_node      # Allocate new node ('I')
    mv a1, a0               # a1 = address of newly allocated node
    lw a0, head_node        # Load head node address into a0
    jal ra, add_tail        # Add new node ('I') to the tail
    sw a1, tail_node        # Update tail to the new node

    # Allocate the fourth node ('S') and add it to the tail
    addi a0, zero, 0x53     # 'S' in HEX 53 (ASCII 83)
    jal ra, alloc_node      # Allocate new node ('S')
    mv a1, a0               # a1 = address of newly allocated node
    lw a0, head_node        # Load head node address into a0
    jal ra, add_tail        # Add new node ('S') to the tail
    sw a1, tail_node        # Update tail to the new node

    # Allocate the fifth node ('C') and add it to the tail
    addi a0, zero, 0x43     # 'C' in HEX 43 (ASCII 67)
    jal ra, alloc_node      # Allocate new node ('C')
    mv a1, a0               # a1 = address of newly allocated node
    lw a0, head_node        # Load head node address into a0
    jal ra, add_tail        # Add new node ('C') to the tail
    sw a1, tail_node        # Update tail to the new node

    # End of program
    li a7, 10
    ecall



alloc_node:
    la t0, start # Load the address of 'start' into t0
    lw t1, 0(t0) # Load the current value of 'start' into t1

    addi t2, t1, 9 # Each node is 9 bytes
    sw t2, 0(t0) # Store the updated address back to 'start'

    # value
    sb a0, 0(t1) # Store the value (8-bit) in the first byte of the node

    # next (initially points to itself)
    sw t1, 1(t1) # Initially set next to point to itself (not NULL)

    # prev (initially points to itself)
    sw t1, 5(t1) # Initially set prev to point to itself (not NULL)

    # If this is not the first node, update previous node's next and new node's prev
    beq a1, zero, end_alloc # If a1 is zero, it's the first node, so skip the linking

    # Update the previous node's next to point to the new node
    sw t1, 1(a1)

    # Update the new node's prev to point to the previous node
    sw a1, 5(t1)

end_alloc:
    mv a0, t1 # Return the address of the allocated node in a0

    jalr zero, ra, 0 # Return from the function




# Add Tail Function
# This function adds the new node to the end of the list
add_tail:
    # Args:
    # a0: Address of head node
    # a1: Address of new node to be added to the tail

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
