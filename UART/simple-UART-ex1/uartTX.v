`timescale 1ns / 1ns
module uartTX(
 
    input    clk,
    input    rst_n,
    input    valid,
    input [7:0]  pi_data,

    output    tx,
    output    tx_done,
    output  reg  dir=1,
    output  reg  ready,
    output  reg  ena
    );            

    reg [7:0] pi_data_reg;
    reg    work_en;
    reg [17:0] baud_cnt;
    reg [3:0] bit_cnt;
    reg    bit_flag;
    reg    tx_reg;
    reg    tx_done_reg;
 
    parameter  CLK_FREQ = 'd50000000;
    parameter  BAUD_RATE = 'd9600;
    parameter  BAUD_CNT_MAX = CLK_FREQ/BAUD_RATE;
 
    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 'd0) begin
            pi_data_reg <= 'd0;
        end
        else if (valid == 'd1) begin
            pi_data_reg <= pi_data ;
        end
        else begin
            pi_data_reg <= pi_data_reg;
        end
    end

   	always @(posedge clk or negedge rst_n) begin
   	    if (rst_n == 'd0) begin
   	        work_en <= 'd0;
   	    end
   	    else if (valid == 'd1) begin 
   	        work_en <= 'd1;
   	    end
   	    else if (tx_done == 'd1) begin
   	        work_en <= 'd0;
   	    end
   	end

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 'd0)begin
            baud_cnt <= 'd0;
        end
        else if(work_en == 'd1 && (baud_cnt == BAUD_CNT_MAX - 'd1))begin
            baud_cnt <= 'd0 ;
        end
        else if (work_en == 'd1) begin
            baud_cnt <= baud_cnt + 'd1 ; 
        end
        else begin
            baud_cnt <= 'd0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 'd0) begin
            bit_flag <= 'd0;
        end
        else if (baud_cnt == 'd1) begin
            bit_flag <= 'd1;
        end
        else begin
            bit_flag <= 'd0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 'd0)begin
            bit_cnt <= 'd0;
        end
        else if ((work_en == 'd1) && (bit_flag == 'd1) && (bit_cnt == 'd11)) begin
            bit_cnt <= 'd0;
        end
        else if ((work_en == 'd1) && (bit_flag == 'd1)) begin
            bit_cnt <= bit_cnt + 'd1;
        end
        else if (work_en == 'd0) begin
            bit_cnt <= 'd0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 'd0) begin
            tx_reg <= 'd0;
        end
        else begin
            case (bit_cnt)
                4'd1: tx_reg <= 'd0;
                4'd2: tx_reg <= pi_data_reg[0];
                4'd3: tx_reg <= pi_data_reg[1];
                4'd4: tx_reg <= pi_data_reg[2];
                4'd5: tx_reg <= pi_data_reg[3];
                4'd6: tx_reg <= pi_data_reg[4];
                4'd7: tx_reg <= pi_data_reg[5];
                4'd8: tx_reg <= pi_data_reg[6];
                4'd9: tx_reg <= pi_data_reg[7];
                4'd10:tx_reg <= 'd1;
                4'd11:tx_reg <= 'd1;
                default :tx_reg <= 'd1; 
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 'd0) begin
            tx_done_reg <= 'd0;
        end
        else if ((bit_flag == 'd1) && (bit_cnt == 'd10)) begin
            tx_done_reg <= 'd1;
        end
        else begin
            tx_done_reg <= 'd0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 'd0) begin
            ready <= 'd1;
        end
        else if (tx_done == 'd1) begin
            ready <= 'd1;
        end
        else if (valid == 'd1) begin
            ready <= 'd0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (rst_n) begin
            ena <= 'd0;
        end
        else begin
            ena <= tx_done;
        end
    end
    
    assign tx = tx_reg;
    assign tx_done = tx_done_reg;
endmodule