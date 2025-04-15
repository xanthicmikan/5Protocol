`timescale 1ns / 1ns
module uart_tb;

    reg clk;
    reg rst_n;
    reg valid;
    reg [7:0] pi_data;
    reg rx;
 
    wire tx;
    wire tx_done;
    wire dir;
    wire ready;
    wire ena; 
    wire [7:0] po_data;
    wire  po_flag;

    always #10 clk = ~clk;
    
    initial begin
        clk = 0;
        rst_n = 0;
        rx = 1;
        #1;
        rst_n = 1;
        valid = 1;
        pi_data = 8'h55;
        #104160 //for 9600
        rx = 0;
        #104160
        rx = 1;
        #104160
        rx = 0;
        #104160
        rx = 1;
        #104160
        rx = 0;
        valid = 0;
        #800000
        $finish;
    end   

    uartRX uut_rx(
        .clk(clk),
        .rst_n(rst_n),
        .rx(rx),
        .po_data(po_data),
        .po_flag(po_flag)
    );

    uartTX uut_tx (
        .clk(clk),
        .rst_n(rst_n),
        .valid(valid),
        .pi_data(pi_data),
        .tx(tx),
        .dir(dir),
        .ready(ready),
        .ena(ena)
    );
    

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(2, uart_tb);
    end 
endmodule
