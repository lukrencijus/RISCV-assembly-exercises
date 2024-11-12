.data
start: .word 0
head_node: .word 0
tail_node: .word 0
prev_node: .word 0

.text
_start:
    addi a0, zero, 0x52     # 'R' in HEX 52 (ASCII 82)
    jal ra, alloc_node
    la t0, head_node
    sw a0, 0(t0)
    la t0, tail_node
    sw a0, 0(t0)
    la t0, prev_node
    sw a0, 0(t0)
    lw a1, prev_node
    jal ra, make_circular

    addi a0, zero, 0x56     # 'V' in HEX 56 (ASCII 86)
    jal ra, alloc_node
    lw a1, prev_node
    jal ra, make_circular
    mv a1 a0
    lw a0, head_node
    jal ra, add_tail
    la t0, tail_node
    sw a1, 0(t0)
    la t0, prev_node
    sw a1, 0(t0)

    addi a0, zero, 0x49     # 'I' in HEX 49 (ASCII 73)
    jal ra, alloc_node 
    lw a1, prev_node
    jal ra, make_circular
    mv a1, a0
    lw a0, head_node
    jal ra, add_tail
    la t0, tail_node
    sw a1, 0(t0)
    la t0, prev_node
    sw a1, 0(t0)

    addi a0, zero, 0x53     # 'S' in HEX 53 (ASCII 83)
    jal ra, alloc_node
    lw a1, prev_node
    jal ra, make_circular
    mv a1, a0
    lw a0, head_node
    jal ra, add_tail
    la t0, tail_node
    sw a1, 0(t0)
    la t0, prev_node
    sw a1, 0(t0)

    addi a0, zero, 0x43     # 'C' in HEX 43 (ASCII 67)
    jal ra, alloc_node
    lw a1, prev_node
    jal ra, make_circular
    mv a1, a0
    lw a0, head_node
    jal ra, add_tail
    la t0, tail_node
    sw a1, 0(t0)
    la t0, prev_node
    sw a1, 0(t0)

    lw a0, head_node
    jal ra, print_list

    li a7, 10
    ecall



# a0 to be allocated
alloc_node:
    la t0, start
    lw t1, 0(t0)

    # value
    sb a0, 0(t1)

    # next
    sw t1, 1(t1) 

    # prev
    sw t1, 5(t1)

    mv a0, t1
    jalr zero, ra, 0



# a1 previous node
make_circular:
    la t0, start
    lw t1, 0(t0)

    addi t2, t1, 9
    sw t2, 0(t0)

    sw t1, 1(a1)            # a1->next = t1

    sw a1, 5(t1)            # t1->prev = a1

    jalr zero, ra, 0 



# a0: Address of head node
# a1: Address of new node to be added to the tail
add_tail:
    lw t2, 5(a0)            # Load the 'prev' of head

    sw a1, 1(t2)            # t2->next = a1

    sw t2, 5(a1)            # a1->prev = t2

    sw a0, 1(a1)            # a1->next = a0

    sw a1, 5(a0)            # a0 ->prev = a1

    jalr zero, ra, 0 



# a0: Address of head node
print_list:
    mv t0, a0
    li t1, 0               # Initialize byte count to 0
    mv t3, a0              # Store head node address in t3 to detect when we loop back

print_loop:
    lb a1, 0(t0)
    mv a0, a1
    li a7, 11
    ecall
    bltz a0, print_fail

    addi t1, t1, 1

    # Move to the next node
    lw t0, 1(t0)
    bne t0, t3, print_loop # Continue if current node is not head node

    mv a0, t1              # Return total byte count in a0
    jalr zero, ra, 0

print_fail:
    li a0, -1              # Return -1 on failure
    jalr zero, ra, 0