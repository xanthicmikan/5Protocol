del wave
del wave.vcd
iverilog -o wave spi_ctrl.v spi_tb.v syncFIFO.v
vvp wave
gtkwave dump.vcd
pause