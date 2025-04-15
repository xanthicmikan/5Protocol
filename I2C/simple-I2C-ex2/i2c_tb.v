`timescale 1ns / 1ps

module i2c_tb;

    // Inputs
    reg clk;
    reg rst;
    reg [6:0] addr;
    reg [7:0] data_in;
    reg enable;
    reg rw;
    
    // Outputs
    wire [7:0] data_out;
    wire ready;
    
    wire i2c_sda;
    wire i2c_scl;
    
    // Instantiate the Unit Under Test (UUT)
    i2cm master (
        .clk(clk), 
        .rst(rst), 
        .addr(addr), 
        .data_in(data_in), 
        .enable(enable), 
        .rw(rw), 
        .data_out(data_out), 
        .ready(ready), 
        .i2c_sda(i2c_sda), 
        .i2c_scl(i2c_scl)
    );
    
    i2cs slave (
    .sda(i2c_sda), 
    .scl(i2c_scl)
    );
    
    always #1 clk = ~clk;

    
    initial begin
        clk = 0;
        rst = 1;
    
        #100;
        
        rst = 0;
        addr = 7'b0010100;
        data_in = 8'b10101010;
        rw = 0;// 0:write 1:read
        enable = 1;
        #10;
        enable = 0;

        #500
        $finish;
    end      
    
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(2, i2c_tb);
    end 
    
endmodule