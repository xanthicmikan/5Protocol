module BaudRateGen  #(
    parameter CLOCK_RATE = 'd50000000, //def == 50MHz
    parameter BAUD_RATE = 'd9600
)(
    input wire clk,
    output reg rxClk,
    output reg txClk
);
parameter MAX_RATE_RX = CLOCK_RATE / (2*BAUD_RATE);
parameter MAX_RATE_TX = CLOCK_RATE / (2*BAUD_RATE);
parameter RX_CNT_WIDTH = $clog2(MAX_RATE_RX);
parameter TX_CNT_WIDTH = $clog2(MAX_RATE_TX);

reg [RX_CNT_WIDTH - 1:0] rxCounter = 0;
reg [TX_CNT_WIDTH - 1:0] txCounter = 0;

initial begin
    rxClk = 1'b0;
    txClk = 1'b0;
end

always @(posedge clk) begin
    // rx clock
    if (rxCounter == MAX_RATE_RX[RX_CNT_WIDTH-1:0]) begin
        rxCounter <= 0;
        rxClk <= ~rxClk;
    end else begin
        rxCounter <= rxCounter + 1'b1;
    end
    // tx clock
    if (txCounter == MAX_RATE_TX[TX_CNT_WIDTH-1:0]) begin
        txCounter <= 0;
        txClk <= ~txClk;
    end else begin
        txCounter <= txCounter + 1'b1;
    end
end

endmodule
