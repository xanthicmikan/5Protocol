`timescale 1ns / 1ns
module spi_tb;

    reg mclk, reset, load, start, read;
    reg [7:0]data_in;
    wire [7:0]data_out;
    wire mosi, miso, cs;
    wire sclk;

    spi_master master (
        .mclk(mclk), 
        .reset(reset), 
        .load(load), 
        .miso(miso), 
        .start(start), 
        .read(read), 
        .data_in(data_in), 
        .data_out(data_out), 
        .mosi(mosi), 
        .cs(cs),
        .sclk(sclk)
    );

    spi_slave slave (
        .sclk(mclk), 
        .cs(cs), 
        .mosi(mosi), 
        .reset(reset), 
        .read(read), 
        .load(load), 
        .data_in(data_in), 
        .data_out(data_out), 
        .miso(miso)
    );
    
    always #16.67 mclk = ~mclk;

    
    initial begin
        mclk = 0;
        reset = 0;
        load = 0;
        start = 0;
        #20;
        reset = 1;
        #20;
        data_in = 8'h46;
        load = 1;
        read = 0;
        start = 1;
        #20;
        load = 0;
        #20;
        

        #500
        $finish;
    end      
    
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(2, spi_tb);
    end 
    
endmodule