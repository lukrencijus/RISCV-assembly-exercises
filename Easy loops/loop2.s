#counter = 8;
#While counter > 0
#    If counter != 4
#        Output counter
#    counter = counter - 1
##################################

addi t0, zero, 8
addi t1, zero, 0
addi t2, zero, 4
addi t3, zero, -1

again:

addi a7, zero, 1
add a0, zero, t0

ecall

skip:

add t0, t0, t3

beq t0, t2, skip
ble t1, t0, again
