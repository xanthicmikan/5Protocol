del wave
del wave.vcd
iverilog -o wave i2c.v i2c_tb.v
vvp wave
gtkwave dump.vcd
pause