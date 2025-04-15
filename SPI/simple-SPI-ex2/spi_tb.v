`timescale  1ns/1ns

module spi_tb();

    wire cs_n;
    wire sck;
    wire mosi;
    wire tx_flag;
    wire [7:0] tx_data;
    
    reg miso;
    reg clk;
    reg rst_n;
    reg key;

    spi_ctrl uut(
        .sys_clk(clk),
        .sys_rst_n(rst_n),
        .key    (key),
        .miso   (miso),
        .sck    (sck),
        .cs_n   (cs_n),
        .mosi   (mosi),
        .tx_flag(tx_flag),
        .tx_data(tx_data));

    initial begin
        clk = 0;
        rst_n <= 0;
        key <= 0;
        miso <= 0;
        #100
        rst_n <= 1;
        #1000
        key <= 1;
        #20
        key <= 0;
        #500
        miso <= 0;
        #20
        miso <= 1;
        #20
        miso <= 0;
        #20
        miso <= 0;
        #20
        miso <= 1;
        #20
        miso <= 0;
        #50000
        $finish;
    end

    always #(2) clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(2, spi_tb);
    end 
endmodule

