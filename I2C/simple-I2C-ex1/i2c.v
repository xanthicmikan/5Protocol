module i2c #(
    parameter DIV_CLK = 100,
    parameter WR_MAX  = 8'd1,
    parameter RD_MAX  = 8'd1
) (
    input clk,
    input rst_n,

    input enable,
    output reg busy,

    input [7:0] rdlen,
    input [7:0] wrlen,

    output reg [RD_MAX*8-1:0] rddata,
    input [WR_MAX*8-1:0] wrdata,

    output reg isack,

    output scl,
    inout  sda
);

    reg [$clog2(DIV_CLK):0] clk_cnt;
    reg scl_clk;
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            clk_cnt <= 16'd0;
            scl_clk <= 1'd0;
        end else begin
            if (clk_cnt == (DIV_CLK >> 1) - 1) begin
                clk_cnt <= 16'd0;
                scl_clk = ~scl_clk;
            end else begin
                clk_cnt <= clk_cnt + 16'd1;
            end

        end
    end

    localparam  ST_IDLE = 0, 
                ST_START = 1, 
                ST_WR_DATA = 2, 
                ST_WR_READ_ACK = 3, 
                ST_WR_CHECK_ACK = 4, 
                ST_RD_START = 5, 
                ST_RD_DATA = 6, 
                ST_RD_ACK_REPLY = 7, 
                ST_RD_ACK_DONE = 8, 
                ST_STOP = 9;

    reg [3:0] state = ST_IDLE;
    assign scl = (state == ST_IDLE || state == ST_START) ? 1 : scl_clk;

    // SDA 
    reg sda_r = 1;
    reg sda_oe = 1;
    assign sda = sda_oe ? sda_r : 1'bz;

    reg [7:0] byte_no = 0;
    reg [3:0] bit_no = 0;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            isack <= 0;
            busy <= 0;
            rddata <= 0;
        end else begin

            case (state)
                ST_IDLE: begin
                    sda_r <= 1;

                    if (enable) begin
                        busy <= 1;
                    end

                    if (busy && clk_cnt == DIV_CLK >> 2 && scl_clk == 1) begin
                        state <= ST_START;
                    end

                end

                // when scl_clk is high, sda h->l
                ST_START: begin
                    if (clk_cnt == DIV_CLK >> 2 && scl_clk == 1) begin
                        sda_r <= 0;
                        state <= ST_WR_DATA;
                        byte_no <= wrlen;
                        bit_no <= 4'd0;
                        isack <= 0;
                    end
                end

                // wrdata 
                ST_WR_DATA: begin
                    if (clk_cnt == DIV_CLK >> 2 && scl_clk == 0) begin

                        if (bit_no == 4'd8) begin
                            state   <= ST_WR_READ_ACK;
                            byte_no <= byte_no - 1'b1;
                            bit_no  <= 4'd0;
                            sda_oe  <= 0;
                        end else begin
                            bit_no <= bit_no + 1'b1;
                            sda_r  <= wrdata[byte_no*8-1-bit_no-:1];
                            sda_oe <= 1;
                        end
                    end
                end

                // 
                ST_WR_READ_ACK: begin
                    if (clk_cnt == DIV_CLK >> 2 && scl_clk == 1) begin

                        if (sda == 0)
                        //if (1)//only for test without slave device
                            isack <= 1;
                        state <= ST_WR_CHECK_ACK;
                    end
                end

                ST_WR_CHECK_ACK: begin
                    if (clk_cnt == DIV_CLK >> 2 && scl_clk == 0) begin

                        if (isack && byte_no != 0) begin
                            state <= ST_WR_DATA;
                            bit_no <= bit_no + 1'b1;
                            sda_r <= wrdata[byte_no*8-1-bit_no-:1];
                            sda_oe <= 1;
                            isack <= 0;
                        end else if (isack && rdlen > 0) begin
                            state  <= ST_RD_START;
                            sda_oe <= 1;
                            sda_r  <= 1;
                        end else begin
                            state  <= ST_STOP;
                            sda_r  <= 0;
                            sda_oe <= 0;
                        end

                    end
                end

                ST_RD_START: begin
                    if (clk_cnt == DIV_CLK >> 2 && scl_clk == 1) begin
                        sda_r <= 0;

                    end else if (clk_cnt == DIV_CLK >> 2 && scl_clk == 0) begin
                        sda_oe  <= 0;
                        state   <= ST_RD_DATA;
                        bit_no  <= 0;
                        byte_no <= rdlen;
                    end
                end

                // when scl_clk is high,get sda 
                ST_RD_DATA: begin
                    if (clk_cnt == DIV_CLK >> 2 && scl_clk == 1) begin

                        bit_no <= bit_no + 1'b1;
                        rddata[byte_no*8-1-bit_no-:1] <= sda;
                        //rddata[byte_no*8-1-bit_no-:1] <= 1;// only for test without slave device

                        if (bit_no == 4'd7) begin
                            state   <= ST_RD_ACK_REPLY;
                            byte_no <= byte_no - 1'b1;
                            bit_no  <= 4'd0;
                        end

                    end
                end

                ST_RD_ACK_REPLY: begin
                    if (clk_cnt == DIV_CLK >> 2 && scl_clk == 0) begin
                        sda_oe = 1;
                        sda_r <= 0;
                        state <= ST_RD_ACK_DONE;
                    end
                end

                ST_RD_ACK_DONE: begin
                    if (clk_cnt == DIV_CLK >> 2 && scl_clk == 0) begin

                        if (byte_no == 0) begin
                            sda_oe = 1;
                            state <= ST_STOP;
                        end else begin
                            sda_oe = 0;
                            state <= ST_RD_DATA;
                        end
                    end
                end

                ST_STOP: begin
                    if (clk_cnt == DIV_CLK >> 2 && scl_clk == 1) begin
                        sda_oe <= 1;
                        sda_r  <= 1;
                        state  <= ST_IDLE;
                        busy   <= 0;
                    end
                end

            endcase
        end
    end

endmodule
