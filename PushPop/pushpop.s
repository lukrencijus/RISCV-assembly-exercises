main:
addi a1, zero, 1 # A
addi a2, zero, 2 # B
addi a3, zero, 3 # C
addi a4, zero, 4 # D

add a0, zero, a1
# jalr 
# call push



# call pop

call math
add x1, t3, zero

addi a7, zero, 1    
add a0, zero, x1
ecall

li a7, 93
ecall

math:
add t3, t1, t2
ret



push:
sw a0, 0, sp
addi sp, sp, -4
add sp, sp, zero
addi sp, sp, +4
#return
