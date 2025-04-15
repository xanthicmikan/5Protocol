`timescale 1ns / 1ns

module i2c_tb;

    reg clk;
    reg rst_n;
    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        rst_n = 0;
        #100;
        rst_n = 1;
    end

    reg enable;
    wire busy;

    initial begin
        enable = 0;
        @(posedge rst_n);

        enable = 1;
        @(negedge busy);
        enable = 0;
        #10000;

        enable = 1;
        @(negedge busy);
        enable = 0;
        #10000;
    end

    wire [15:0] rddata;
    wire isack;

    i2c #(
        .DIV_CLK(100),
        .WR_MAX (8'd2),
        .RD_MAX (8'd2)
    ) u_iic (
        .clk   (clk),
        .rst_n (rst_n),

        .enable(enable),
        .busy  (busy),

        .rdlen (8'd2),
        .wrlen (8'd2),
        .rddata(rddata),
        .wrdata(16'h2755),

        .isack (isack),
        .scl   (scl),
        .sda   (sda)
    );

    initial begin
        $dumpvars;
        #5000000;
        $finish;
    end

endmodule
