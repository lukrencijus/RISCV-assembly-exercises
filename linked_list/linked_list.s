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



    lw a0, head_node
    li a1, 0x56            # 'V' in HEX 56 (ASCII 86)
    jal ra, find_node
    
    mv a1, a0
    lw a0, head_node
    jal ra, del_node
    # updated head node

    #new line and print updated list
    li a0, 10
    li a7, 11
    ecall
    lw a0, head_node
    jal ra, print_list

    li a7, 10
    ecall

not_found:
    li a0, -1
    li a7, 10
    ecall



# a0: address of node to be allocated
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



# a1: address of previous node
make_circular:
    la t0, start
    lw t1, 0(t0)

    addi t2, t1, 9
    sw t2, 0(t0)

    sw t1, 1(a1)            # a1->next = t1

    sw a1, 5(t1)            # t1->prev = a1

    jalr zero, ra, 0 



# a0: address of head node
# a1: address of new node to be added to the tail
add_tail:
    lw t2, 5(a0)            # Load the 'prev' of head

    sw a1, 1(t2)            # t2->next = a1

    sw t2, 5(a1)            # a1->prev = t2

    sw a0, 1(a1)            # a1->next = a0

    sw a1, 5(a0)            # a0 ->prev = a1

    jalr zero, ra, 0 



# a0: address of head node
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



# a0: address of head node
# a1: address of node to be deleted
del_node:
    mv t2, a0             # Start from the head node
    mv t3, a0             # Store the head for loop detection

del_loop:
    beq t2, a1, found_node    # Node to delete found
    lw t2, 1(t2)              # Move to the next node
    beq t2, t3, not_found     # Loop back to head, node not found

found_node:
    lw t4, 5(t2)              # t4 = node->prev
    lw t5, 1(t2)              # t5 = node->next

    sw t5, 1(t4)              # t4->next = t5
    sw t4, 5(t5)              # t5->prev = t4

    beq t2, a0, update_head   # If the deleted node is the head, update head
    jalr zero, ra, 0          # Return original head

update_head:
    sw t5, 0(a0)              # Update head to the next node
    mv a0, t5                 # Return new head
    jalr zero, ra, 0

    # return -1 if not found



# a0: address of head node
# a1: value of node to find
find_node:
    mv t2, a0                # Start at the head
    mv t3, a0                # Loop detection

find_loop:
    lb t4, 0(t2)             # Load value of current node
    beq t4, a1, return_node  # If value matches, return address
    lw t2, 1(t2)             # Move to next node
    beq t2, t3, not_found    # If loop back to head, not found
    j find_loop

return_node:
    mv a0, t2                # Return node address
    jalr zero, ra, 0