# 12345678
# 02345678
# 01345678
# 01245678
# 01235678
# 01234678
# 01234578
# 01234568
# 01234567
##################################

# kintamieji 
# kuriuos reikia prisiminti
addi t5, zero, 0  # dabartinis eiluciu kiekis
addi t2, zero, 0  # ko nebus eiluteje
repeat:
# kuriu galima ir neprisiminti
addi t0, zero, 0  # nuo ko predesime eiti ir kas bus spausdinamas
addi t1, zero, 8  # iki kiek eisime
addi t3, zero, 1  # kas kiek eisime
addi t4, zero, -1 # skaiciu kiekis eiluteje
addi t6, zero, 9  # iki kiek eiluciu kiekio eisime

# loop'o pradzia
again:
# pirmo skaiciaus neprintinti
beq t0, t2, skip

# isprintiname skaiciu
addi a7, zero, 1
add a0, zero, t0
ecall

skip:
# pridedame +1 prie einancio skaiciaus
add t0, t0, t3

#pridedame +1 prie skaiciu kiekio
add t4, t4, t3
beq t1, t4, newline # new line tik tada kai visi isprintinti

ble t0, t1, again # kartojame loop'a

# isprintiname new line
newline:
li a7, 11
li a0, 10
ecall

add t5, t5, t3   # +1 prie eiluciu kiekio
beq t5, t6, exit # exit kai jau visos eilutes isprintintos

#kokio skaiciaus neprintinti
add t2, t2, t3
beq t0, t2, skip

beq t1, t4, repeat # kartojame viska is naujo

exit:
    li a7, 93
    ecall