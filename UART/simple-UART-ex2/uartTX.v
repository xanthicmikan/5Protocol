module uartTX (
    input      clk,
    input      en,
    input      start,
    input[7:0] in,
    output reg out,
    output reg done,
    output reg busy);

    parameter RESET    = 3'b001;
    parameter IDLE     = 3'b010;
    parameter START_BIT= 3'b011;
    parameter DATA_BITS= 3'b100;
    parameter STOP_BIT = 3'b101;

    reg [2:0] state  = RESET;
    reg [7:0] data   = 8'b0;
    reg [2:0] bitIdx = 3'b0;
    wire [2:0] idx;

    assign idx = bitIdx;

    always @(posedge clk) begin
        case (state)
            default     : begin
                state   <= IDLE;
            end
            IDLE       : begin
                out     <= 1'b1;
                done    <= 1'b0;
                busy    <= 1'b0;
                bitIdx  <= 3'b0;
                data    <= 8'b0;
                if (start & en) begin
                    data    <= in;
                    state   <= START_BIT;
                end
            end
            START_BIT  : begin
                out     <= 1'b0;
                busy    <= 1'b1;
                state   <= DATA_BITS;
            end
            DATA_BITS  : begin
                out     <= data[idx];
                if (&bitIdx) begin
                    bitIdx  <= 3'b0;
                    state   <= STOP_BIT;
                end else begin
                    bitIdx  <= bitIdx + 1'b1;
                end
            end
            STOP_BIT   : begin
                done    <= 1'b1;
                data    <= 8'b0;
                state   <= IDLE;
            end
        endcase
    end

endmodule
