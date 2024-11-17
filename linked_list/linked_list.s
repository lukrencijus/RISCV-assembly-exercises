.data
start: .word 0
head_node: .word 0
tail_node: .word 0

.text

_start:
    # create head node with ASCII value 'R'
    addi a0, zero, 0x52         # 'R' in HEX 52 (ASCII 82)
    jal ra, alloc_node
    la t0, head_node
    sw a0, 0(t0)
    la t0, tail_node
    sw a0, 0(t0)
    jal ra, make_circular

    # add nodes with ASCII values 'V', 'I', 'S', 'C' to the tail
    addi a0, zero, 0x56         # 'V' in HEX 56 (ASCII 86)
    jal ra, create_node

    addi a0, zero, 0x49         # 'I' in HEX 49 (ASCII 73)
    jal ra, create_node

    addi a0, zero, 0x53         # 'S' in HEX 53 (ASCII 83)
    jal ra, create_node

    addi a0, zero, 0x43         # 'C' in HEX 43 (ASCII 67)
    jal ra, create_node

    # traverse the list nodes and print their value
    lw a0, head_node
    jal ra, print_list
    bltz a0, end

    # find the node with 'V' value from the list
    lw a0, head_node
    li a1, 0x56            # 'V' in HEX 56 (ASCII 86)
    jal ra, find_node
    bltz a0, end
    
    # remove the node with 'V' value from the list
    mv a1, a0
    lw a0, head_node
    jal ra, del_node
    bltz a0, end
    la t0, head_node
    sw a0, 0(t0)

    # comment the next line, if you want to print updated list
    # j end 
    li a0, 10
    li a7, 11
    ecall
    lw a0, head_node
    jal ra, print_list

# exit
end:
    li a7, 93
    ecall



create_node:
    addi t5, ra, 0
    jal ra, alloc_node
    lw a1, tail_node
    jal ra, make_circular
    mv a1, a0
    lw a0, head_node
    jal ra, add_tail
    la t0, tail_node
    sw a1, 0(t0)
    addi ra, t5, 0
    jr ra



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
    lw t2, 5(a0)            # load the 'prev' of head

    sw a1, 1(t2)            # t2->next = a1

    sw t2, 5(a1)            # a1->prev = t2

    sw a0, 1(a1)            # a1->next = a0

    sw a1, 5(a0)            # a0 ->prev = a1

    jalr zero, ra, 0 



# a0: address of head node
print_list:
    mv t0, a0
    li t1, 0
    mv t3, a0

print_loop:
    lb a1, 0(t0)
    mv a0, a1
    li a7, 11
    ecall
    bltz a0, print_fail

    addi t1, t1, 1

    # move to the next node
    lw t0, 1(t0)
    bne t0, t3, print_loop
    li a0, 0
    jalr zero, ra, 0

print_fail:
    beq t0, zero, continue
    j print_bytes

continue:
    li a0, -1
    jalr zero, ra, 0

print_bytes:
    mv a0, t1
    jalr zero, ra, 0



# a0: address of head node
# a1: address of node to be deleted
del_node:
    mv t2, a0

del_loop:
    beq t2, a1, found_node
    lw t2, 1(t2)
    beq t2, a0, not_found
    j del_loop

found_node:
    lw t4, 5(t2)              # t4 = node->prev
    lw t5, 1(t2)              # t5 = node->next

    sw t5, 1(t4)              # t4->next = t5
    sw t4, 5(t5)              # t5->prev = t4

    beq t2, a0, update_head
    jalr zero, ra, 0

update_head:
    sw t5, 0(a0)
    mv a0, t5
    jalr zero, ra, 0

not_found:
    addi a0, zero, -1
    jalr zero, ra, 0



# a0: address of head node
# a1: value of node to find
find_node:
    mv t2, a0

find_loop:
    lb t4, 0(t2)
    beq t4, a1, return_node
    lw t2, 1(t2)
    beq t2, a0, not_found
    j find_loop

return_node:
    mv a0, t2
    jalr zero, ra, 0