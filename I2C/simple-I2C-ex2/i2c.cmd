del wave
del wave.vcd
iverilog -o wave i2cm.v i2cs.v i2c_tb.v
vvp wave
gtkwave dump.vcd
pause