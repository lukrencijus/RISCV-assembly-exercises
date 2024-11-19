# Task: Implement separate functions for `push` and `pop` in RISC-V assembly. 
# These functions will handle the stack operations independently,
# allowing you to push a value onto the stack or pop a value from the stack into a register.

# X=A+B-C-10+D

.data
A:    .word 1
B:    .word 2
C:    .word 3 
D:    .word 4
X:    .word 0

.text
 
main:
la t0, A
lw a0, 0(t0)
jal ra, push

la t0, B
lw a0, 0(t0)
jal ra, push

la t0, C
lw a0, 0(t0)
jal ra, push
    
la t0, D
lw a0, 0(t0)
jal ra, push
    
jal ra, math

la t0, X
sw a0, 0(t0)

lw a0, 0(t0)
li a7, 1
ecall

li a7, 10
ecall

math:
# save return address
mv t2, ra
    
# t1 = D
jal ra, pop
mv t1, a0

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
    
mv a0, t1

mv ra, t2
ret

push:
addi sp, sp, -4
sw   a0, 0(sp)
ret

pop:    
lw   a0, 0(sp)
addi sp, sp, 4
ret
