.data
start: .word 0
head_node: .word 0
tail_node: .word 0

.text
_start:
    addi a0, zero, 0x52 	# 'R' in HEX 52 (ASCII 82)
    jal ra, alloc_node
    
    la t0, head_node
    sw a0, 0(t0)
    
    addi a0, zero, 0x56    # 'V' in HEX 56 (ASCII 86)
    jal ra, alloc_node
    mv a1, a0
    la a0, head_node
    lw a0, 0(a0)
    jal ra, add_tail
    
    addi a0, zero, 0x49    # 'I' in HEX 49 (ASCII 73)
    jal ra, alloc_node
    mv a1, a0
    la a0, head_node
    lw a0, 0(a0)
    jal ra, add_tail
    
    addi a0, zero, 0x53    # 'S' in HEX 53 (ASCII 83)
    jal ra, alloc_node
    mv a1, a0
    la a0, head_node
    lw a0, 0(a0)
    jal ra, add_tail
    
    addi a0, zero, 0x43    # 'C' in HEX 43 (ASCII 67)
    jal ra, alloc_node
    mv a1, a0
    la a0, head_node
    lw a0, 0(a0)
    jal ra, add_tail

    # Fix circular links
    la a0, head_node
    lw a0, 0(a0)
    jal ra, make_circular


    
    la a0, head_node
    lw a0, 0(a0)
    jal ra, print_list
    
    addi a7, zero, 93
    addi a0, zero, 0
    ecall  

alloc_node:
    la t0, start
    lw t1, 0(t0)

    addi t2, t1, 9 # each node is 9 bytes
    sw t2, 0(t0)
    
    # value
    sb a0, 0(t1)

    # next
    sw t1, 1(t1)

    # prev
    sw t1, 5(t1)

    mv a0, t1
    jalr zero, ra, 0
    
    
    
add_tail:
    mv t0, a0
    
find_tail:
    lw t1, 1(t0)
    beq t1, t0, set_tail
    
    # move to next node
    mv t0, t1
    j find_tail

set_tail:
    sw a1, 1(t0)
    sw t0, 5(a1)
    jalr zero, ra, 0


# sitai funkcijai reikia paduoti:
# a0 head node
# t2 previuos node
make_circular:
    mv t0, a0                  # t0 = head_node
    li t2, 0                   # t2 = previous node, initialized to 0

connect_nodes:
    lw t1, 1(t0)               # t1 = next of current node (load word from offset 1)
    sw t2, 5(t0)               # current_node.prev = t2 (store previous node in current's prev)
    beq t1, t0, finalize_circular # If next == head_node, this is the tail
    mv t2, t0                  # Update previous node (t2 = current node)
    mv t0, t1                  # Move to the next node
    j connect_nodes            # Repeat loop

finalize_circular:
    sw a0, 1(t0)               # tail.next = head_node (store head_node address in tail.next)
    sw t0, 5(a0)               # head_node.prev = tail (store tail address in head_node.prev)
    jalr zero, ra, 0           # Return
