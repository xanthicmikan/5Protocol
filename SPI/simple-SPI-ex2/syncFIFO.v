module sync_fifo
    #(parameter BUF_SIZE=8, 
                BUF_WIDTH=8) 
    (

    input                 i_clk,
    input                 i_rst,
    input                 i_w_en,
    input                 i_r_en,
    input [BUF_WIDTH-1:0] i_data,

    output reg [BUF_WIDTH-1:0] o_data,
    output                     o_buf_empty,
    output                     o_buf_full );

    reg [3:0] fifo_cnt;
    reg [$clog2(BUF_SIZE)-1:0] r_ptr,w_ptr; 
    reg [BUF_WIDTH-1:0] buf_mem[BUF_SIZE-1:0]; 

    assign o_buf_empty=(fifo_cnt==4'd0)?1'b1:1'b0;
    assign o_buf_full=(fifo_cnt==4'd8)?1'b1:1'b0;

    //counter
    always@(posedge i_clk or posedge i_rst) 
        begin
            if(i_rst)
                fifo_cnt<=4'd0;
            else if((!o_buf_full&&i_w_en)&&(!o_buf_empty&&i_r_en)) 
                fifo_cnt<=fifo_cnt;
            else if(!o_buf_full&&i_w_en)
                fifo_cnt<=fifo_cnt+1;
            else if(!o_buf_empty&&i_r_en) 
                fifo_cnt<=fifo_cnt-1;
            else
                fifo_cnt <= fifo_cnt;
        end

    //read data
    always@(posedge i_clk or posedge i_rst)
        begin
            if(i_rst)
                o_data<=8'd0;
            else if(!o_buf_empty&&i_r_en)
                o_data<=buf_mem[r_ptr];
        end
    //write
    always@(posedge i_clk)
        begin
            if(!o_buf_full&&i_w_en)
                buf_mem[w_ptr]<=i_data;
        end

    always@(posedge i_clk or posedge i_rst) 
        begin
            if(i_rst) begin
                w_ptr <= 0;
                r_ptr <= 0;
            end
            else begin
                if(!o_buf_full&&i_w_en)
                    w_ptr <= w_ptr + 1;
                if(!o_buf_empty&&i_r_en)
                    r_ptr <= r_ptr + 1;
            end
        end

endmodule