`timescale 1ns / 1ns
module uartRX
    (
    input  wire  clk,
    input  wire  rst_n,
    input  wire  rx,
    output reg [7:0] po_data,
    output reg  po_flag
    );

    parameter  BAUD_RATE = 'd9600;
    parameter  CLK_FREQ  = 'd50000000;
    parameter  BAUD_CNT_MAX = CLK_FREQ/BAUD_RATE;

    reg  rx_reg1;
    reg  rx_reg2;
    reg  rx_reg3;
    reg  start_flag;
    reg  work_en;
    reg  bit_flag;
    reg  [3:0]  bit_cnt;
    reg  [12:0]  baud_cnt;
    reg  [7:0]  rx_data;
    reg  rx_flag;

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 'd0) begin
            rx_reg1 <= 'd1;
        end
        else begin
            rx_reg1 <= rx;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 'd0) begin
            rx_reg2 <= 'd1;
        end
        else begin
            rx_reg2 <= rx_reg1;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 'd0) begin
            rx_reg3 <= 'd1;
        end
        else begin
            rx_reg3 <= rx_reg2;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 'd0) begin
            start_flag <= 'd0;
        end
        else if ((rx_reg2 == 0) && (rx_reg3 == 1) && (work_en == 'd0)) begin 
            start_flag <= 'd1;
        end
        else begin
            start_flag <= 'd0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 'd0) begin
            work_en <= 'd0;
        end
        else if (start_flag == 1) begin
            work_en <= 'd1;
        end
        else if ((bit_flag == 1) && (bit_cnt == 'd8)) begin
            work_en <= 'd0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 'd0) begin
            baud_cnt <= 'd0;
        end
        else if ((baud_cnt == BAUD_CNT_MAX-1) || (work_en == 'd0)) begin
            baud_cnt <= 'd0;
        end
        else begin
            baud_cnt <= baud_cnt + 'd1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 'd0) begin
            bit_flag <= 'd0;
        end
        else if (baud_cnt == BAUD_CNT_MAX/2-1) begin
            bit_flag <= 'd1;
        end
        else begin
            bit_flag <= 'd0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 'd0) begin
            bit_cnt <= 'd0;
        end
        else if ((bit_flag == 'd1) && (bit_cnt == 'd8)) begin
            bit_cnt <= 'd0;
        end
        else if (bit_flag == 'd1) begin
            bit_cnt <= bit_cnt + 'd1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 'd0) begin
            rx_data <= 'd0;
        end
        else if ((bit_flag == 'd1) && (bit_cnt >= 'd1) && (bit_cnt <= 'd8)) begin
            rx_data <= {rx_reg3,rx_data[7:1]};
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 'd0) begin
            rx_flag <= 'd0;
        end
        else if ((bit_flag == 'd1) && (bit_cnt == 'd8)) begin
            rx_flag <= 'd1;
        end
        else begin
            rx_flag <= 'd0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 'd0) begin
            po_data <= 'd0;
        end
        else if (rx_flag == 'd1) begin
            po_data <= rx_data;
        end
        else begin
            po_data <= po_data;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 'd0) begin
            po_flag <= 'd0;
        end
        else begin
            po_flag <= rx_flag;
        end
    end

endmodule