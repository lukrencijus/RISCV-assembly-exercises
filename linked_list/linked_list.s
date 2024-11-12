.data
start: .word 0
head_node: .word 0

.text
_start:
    addi a0, zero, 0x52 	# 'R' in HEX (ASCII 82)
    jal ra, alloc_node
    
    la t0, head_node
    sw a0, 0(t0)
    
    addi a0, zero, 0x56    # 'V' in HEX (ASCII 86)
    jal ra, alloc_node
    
    mv a1, a0
    
    la a0, head_node
    lw a0, 0(a0)
    jal ra, add_tail

alloc_node:
    la t0, start
    lw t1, 0(t0)

    addi t2, t1, 10
    sw t2, 0(t0)
    
    addi t3, zero, 0xA
    slli t3, t3, 8
    or t3, t3, a0
    
    # value
    sh t3, 0(t1)        

    # next
    sw t1, 2(t1)

    # prev
    sw t1, 6(t1)

    mv a0, t1
    jalr zero, ra, 0
    
    
    
add_tail:
    mv t0, a0
find_tail:
    lw t1, 2(t0)
    beq t1, t0, set_tail
    
    # move to next node
    mv t0, t1
    j find_tail

set_tail:
    sw a1, 2(t0)
    sw t0, 6(a1)
    sw a1, 2(a1)    
    jalr zero, ra, 0
