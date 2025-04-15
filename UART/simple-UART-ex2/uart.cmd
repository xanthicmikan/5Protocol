del wave
del wave.vcd
iverilog -o wave uartRX.v uartTX.v BaudRateGen.v uart_tb.v
vvp wave
gtkwave dump.vcd
pause