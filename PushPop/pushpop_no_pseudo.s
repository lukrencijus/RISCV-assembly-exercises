.data
A:    .word 1
B:    .word 2
C:    .word 3 
D:    .word 4
X:    .word 0

.text
 
main:
    lui t0, %hi(A)
    addi t0, t0, %lo(A)
    lw a0, 0(t0)
    jal ra, push

    lui t0, %hi(B)
    addi t0, t0, %lo(B)
    lw a0, 0(t0)
    jal ra, push

    lui t0, %hi(C)
    addi t0, t0, %lo(C)
    lw a0, 0(t0)
    jal ra, push

    lui t0, %hi(D)
    addi t0, t0, %lo(D)
    lw a0, 0(t0)
    jal ra, push

    jal ra, math

    lui t0, %hi(X)
    addi t0, t0, %lo(X)
    sw a0, 0(t0)

    lw a0, 0(t0)
    addi a7, x0, 1
    ecall

    addi a7, x0, 10
    ecall

math:
    # Save return address
    addi t2, ra, 0
    
    # t1 = D
    jal ra, pop
    addi t1, a0, 0

    # t1 = D - C
    jal ra, pop
    sub t1, t1, a0

    # t1 = D - C + B
    jal ra, pop
    add t1, t1, a0

    # t1 = D - C + B + A
    jal ra, pop
    add t1, t1, a0

    # t1 = A + B - C - 10 + D
    addi t1, t1, -10
    
    addi a0, t1, 0

    addi ra, t2, 0
    jalr x0, ra, 0

push:
    addi sp, sp, -4
    sw   a0, 0(sp)
    jalr x0, ra, 0

pop:
    lw   a0, 0(sp)
    addi sp, sp, 4
    jalr x0, ra, 0
