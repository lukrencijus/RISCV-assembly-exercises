.data
start: .word 0
head_node: .word 0

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
    sw t1, 1(t1) # issaugoti kad rodytu i next node

    # prev
    sw t1, 5(t1) # issaugoti kad rodytu i prev node

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
    sw a1, 1(a1)    
    jalr zero, ra, 0



print_list:
    mv t1, a0
        

print_loop:
    lw t3, 1(t1) # next
    lb a1, 0(t1)
    
    addi a7, zero, 64
    addi a0, zero, 1
    addi a2, a1, 0
    ecall

    blt a0, zero, print_fail

    add t2, t2, a0

    beq t1, t3, print_done # if next = same node
    mv t1, t3
    j print_loop

print_fail:
    li a0, -1
    jalr zero, ra, 0

print_done:
    mv a0, t2
    jalr zero, ra, 0
