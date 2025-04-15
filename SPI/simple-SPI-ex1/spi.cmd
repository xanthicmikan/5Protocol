del wave
del wave.vcd
iverilog -o wave spi_master.v spi_slave.v spi_tb.v
vvp wave
gtkwave dump.vcd
pause