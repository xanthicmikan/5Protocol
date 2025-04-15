`timescale  1ns/1ns
module  spi_ctrl(
    input  wire sys_clk,
    input  wire sys_rst_n,
    input  wire key,
    input  wire miso,
    output reg  sck,
    output reg  cs_n,
    output reg  mosi,
    output reg  tx_flag,
    output wire [7:0] tx_data);

parameter IDLE = 3'b001,
          READ = 3'b010,
          SEND = 3'b100;

parameter READ_INST   = 8'b0000_0011;
parameter NUM_DATA    = 16'd100;
parameter SECTOR_ADDR = 8'b0000_0000,
          PAGE_ADDR   = 8'b0000_0100,
          BYTE_ADDR   = 8'b0010_0101;
parameter CNT_WAIT_MAX= 16'd6_00_00;


wire [7:0] fifo_data_num;
reg  [4:0] cnt_clk;
reg  [2:0] state;
reg  [15:0]cnt_byte;
reg  [1:0] cnt_sck;
reg  [2:0] cnt_bit;
reg        miso_flag;
reg  [7:0] data;
reg        po_flag_reg;
reg        po_flag;
reg  [7:0] po_data;
reg        fifo_read_valid;
reg  [15:0]cnt_wait;
reg        fifo_read_en;
reg  [7:0] read_data_num;


//cnt_clk
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_clk <= 5'd0;
    else if(state == READ)
        cnt_clk <= cnt_clk + 1'b1;

//cnt_byte
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_byte <= 16'd0;
    else if((cnt_clk == 5'd31) && (cnt_byte == NUM_DATA + 16'd3))
        cnt_byte <= 16'd0;
    else if(cnt_clk == 5'd31)
        cnt_byte <= cnt_byte + 1'b1;

//cnt_sck
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_sck <= 2'd0;
    else if(state == READ)
        cnt_sck <= cnt_sck + 1'b1;

//cs_n：
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cs_n <= 1'b1;
    else if(key == 1'b1)
        cs_n    <=  1'b0;
    else if((cnt_byte == NUM_DATA + 16'd3) && (cnt_clk == 5'd31) && (state == READ))
        cs_n <= 1'b1;

//sck
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        sck <= 1'b0;
    else if(cnt_sck == 2'd0)
        sck <= 1'b0;
    else if(cnt_sck == 2'd2)
        sck <= 1'b1;

//cnt_bit
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_bit <= 3'd0;
    else if(cnt_sck == 2'd2)
        cnt_bit <= cnt_bit + 1'b1;

//state
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state <= IDLE;
    else
    case(state)
        IDLE: if(key == 1'b1)
                state <= READ;
        READ: if((cnt_byte == NUM_DATA + 16'd3) && (cnt_clk == 5'd31))
                 state <= SEND;
        SEND: if((read_data_num == NUM_DATA)
                && ((cnt_wait == (CNT_WAIT_MAX - 1'b1))))
                state <= IDLE;
        default: state <= IDLE;
    endcase

//mosi
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        mosi <= 1'b0;
    else if((state == READ) && (cnt_byte>= 16'd4))
        mosi <= 1'b0;
    else if((state == READ) && (cnt_byte == 16'd0) && (cnt_sck == 2'd0))
        mosi <= READ_INST[7 - cnt_bit];
    else if((state == READ) && (cnt_byte == 16'd1) && (cnt_sck == 2'd0))
        mosi <= SECTOR_ADDR[7 - cnt_bit];
    else if((state == READ) && (cnt_byte == 16'd2) && (cnt_sck == 2'd0))
        mosi <= PAGE_ADDR[7 - cnt_bit];
    else if((state == READ) && (cnt_byte == 16'd3) && (cnt_sck == 2'd0))
        mosi <= BYTE_ADDR[7 - cnt_bit];

//miso_flag
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        miso_flag <= 1'b0;
    else if((cnt_byte >= 16'd4) && (cnt_sck == 2'd1))
        miso_flag <= 1'b1;
    else
        miso_flag <= 1'b0;

//data
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data <= 8'd0;
    else    if(miso_flag == 1'b1)
        data <= {data[6:0], miso};

//po_flag_reg
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_flag_reg <=  1'b0;
    else if((cnt_bit == 3'd7) && (miso_flag == 1'b1))
        po_flag_reg <= 1'b1;
    else
        po_flag_reg <= 1'b0;

//po_flag
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_flag <= 1'b0;
    else
        po_flag <= po_flag_reg;

//po_data
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_data <= 8'd0;
    else if(po_flag_reg == 1'b1)
        po_data <= data;
    else
        po_data <= po_data;

//fifo_read_valid
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        fifo_read_valid <=  1'b0;
    else if((read_data_num == NUM_DATA)
                && ((cnt_wait == (CNT_WAIT_MAX - 1'b1))))
        fifo_read_valid <= 1'b0;
    else if(fifo_data_num == NUM_DATA)
        fifo_read_valid <= 1'b1;

//cnt_wait:
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_wait <= 16'd0;
    else if(fifo_read_valid == 1'b0)
        cnt_wait <= 16'd0;
    else if(cnt_wait == (CNT_WAIT_MAX - 1'b1))
        cnt_wait <= 16'd0;
    else if(fifo_read_valid == 1'b1)
        cnt_wait <= cnt_wait + 1'b1;

//fifo_read_en:
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        fifo_read_en <= 1'b0;
    else if((cnt_wait == (CNT_WAIT_MAX - 1'b1))
                && (read_data_num < NUM_DATA))
        fifo_read_en <= 1'b1;
    else
        fifo_read_en <= 1'b0;

//read_data_num
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        read_data_num <= 8'd0;
    else if(fifo_read_valid == 1'b0)
        read_data_num <= 8'd0;
    else if(fifo_read_en == 1'b1)
        read_data_num <= read_data_num + 1'b1;

//tx_flag
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        tx_flag <=  1'b0;
    else
        tx_flag <= fifo_read_en;

//-------------fifo--------------//
sync_fifo fifo_data_inst(
    .i_clk  (sys_clk     ),
    .i_data (po_data     ),
    .i_w_en (po_flag     ),
    .i_r_en (fifo_read_en),

    .o_data (tx_data     ),
    .o_buf_empty (),
    .o_buf_full ());

endmodule
