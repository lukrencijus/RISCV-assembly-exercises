#counter = 0;
#While counter < 8
#    If counter != 4
#        Output counter
#    counter = counter + 1
##################################

addi t0, zero, 0
addi t1, zero, 8
addi t2, zero, 4
addi t3, zero, 1

again:

addi a7, zero, 1
add a0, zero, t0

ecall

skip:

add t0, t0, t3

beq t0, t2, skip
ble t0, t1, again
