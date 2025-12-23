    .section .text
    .globl main
main:
    # Constants
    li t0, 0x400020  # IO op bass address + IO_GPIO offset (0x400000 + 0x20)
    li t1, 0x00000055  # pattern to write
    li t3, 0x400004 # IO op bass address  + IO_LEDS offset (0x400000 + 0x4)

    sw t1, 0(t0) # write GPIO register
    lw t2, 0(t0) # read it back
    sw t2, 0(t3) # move readback to LEDs


# blinking loop (delay of 100000 cycles)
loop:
    addi t1, t1, 1
    sw t1, 0(t0)
    sw t1, 0(t3)

    li t4, 100000
delay:
    addi t4, t4, -1
    bnez t4, delay
    j loop
