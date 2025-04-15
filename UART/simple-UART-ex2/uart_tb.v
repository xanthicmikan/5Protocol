`timescale 1ns / 1ns

module uart_tb;
    parameter CLOCK_RATE = 'd50000000;
    parameter BAUD_RATE = 'd115200;

    reg clk;

    // rx interface
    reg rx;
    reg rxEn;
    wire [7:0] out;
    wire rxDone;
    wire rxBusy;
    wire rxErr;

    // tx interface
    wire tx;
    reg txEn;
    reg txStart;
    reg [7:0] data_in;
    wire txDone;
    wire txBusy;

    wire rxClk;
    wire txClk;
    
    always #10 clk = ~clk;
    
    initial begin
        clk = 0;
        #1;

        data_in = 8'b00010100;
        txStart = 1;
        txEn = 1;
        #1;
        rxEn = 1;
        rx = 1;
        #5000
        rx = 0;
        #8680
        rx = 1;
        #8680
        rx = 0;
        #8680
        rx = 1;
        #8680
        rx = 0;
        #8680
        rx = 0;
        #8680
        rx = 0;
        #8680
        rx = 0;
        #8680
        rx = 0;
        #8680
        rx = 0;
        #8680
        rx = 1;
        #500000
        $finish;
    end   

    BaudRateGen #(
        .CLOCK_RATE(CLOCK_RATE),
        .BAUD_RATE(BAUD_RATE)
    ) genInst (
        .clk(clk),
        .rxClk(rxClk),
        .txClk(txClk)
    );
    
    uartRX uut_rx (
        .clk(rxClk),
        .en(rxEn),
        .in(rx),
        .out(out),
        .done(rxDone),
        .busy(rxBusy),
        .err(rxErr)
    );
    
    uartTX uut_tx (
        .clk(txClk),
        .en(txEn),
        .start(txStart),
        .in(data_in),
        .out(tx),
        .done(txDone),
        .busy(txBusy)
    );
    
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(2, uart_tb);
    end 
endmodule
