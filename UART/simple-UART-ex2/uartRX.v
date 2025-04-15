module uartRX (
    input  wire       clk,
    input  wire       en,
    input  wire       in,
    output reg  [7:0] out,
    output reg        done,
    output reg        busy,
    output reg        err);

    // states of state machine
    parameter RESET = 2'b00;
    parameter IDLE = 2'b01;
    parameter DATA_BITS = 2'b10;
    parameter STOP_BIT = 2'b11;

    reg [2:0] state;
    reg [2:0] bitIdx = 3'b0;
    reg [1:0] inputSw = 2'b0;
    reg [2:0] clockCount = 3'b0;
    reg [7:0] receivedData = 8'b0;

    initial begin
        out <= 8'b0;
        err <= 1'b0;
        done <= 1'b0;
        busy <= 1'b0;
    end

    always @(posedge clk) begin
        inputSw = { inputSw[0], in };

        if (!en) begin
            state = RESET;
        end

        case (state)
            RESET: begin
                out <= 8'b0;
                err <= 1'b0;
                done <= 1'b0;
                busy <= 1'b0;
                bitIdx <= 3'b0;
                clockCount <= 4'b0;
                receivedData <= 8'b0;
                if (en) begin
                    state <= IDLE;
                end
            end

            IDLE: begin
                done <= 1'b0;
                if (&clockCount) begin
                    out <= 8'b0;
                    bitIdx <= 3'b0;
                    clockCount <= 4'b0;
                    receivedData <= 8'b0;
                    busy <= 1'b1;
                    err <= 1'b0;
                end else if (!(&inputSw) || |clockCount) begin
                    if (&inputSw) begin
                        err <= 1'b1;
                        state <= RESET;
                    end
                    clockCount <= clockCount + 4'b1;
                    state <= DATA_BITS;
                end
            end

            DATA_BITS: begin
                if (&clockCount) begin 
                    clockCount <= 4'b0;
                end else begin
                    clockCount <= clockCount + 4'b1;
                    receivedData[bitIdx] <= inputSw[0];
                    if (&bitIdx) begin
                        bitIdx <= 3'b0;
                        state <= STOP_BIT;
                    end else begin
                        bitIdx <= bitIdx + 3'b1;
                    end
                end
            end

            STOP_BIT: begin
                if (&clockCount || (clockCount >= 4'h8 && !(|inputSw))) begin
                    state <= IDLE;
                    done <= 1'b1;
                    busy <= 1'b0;
                    out <= receivedData;
                    clockCount <= 4'b0;
                end else begin
                    clockCount <= clockCount + 1;
                    if (!(|inputSw)) begin
                        err <= 1'b1;
                        state <= RESET;
                    end
                end
            end

            default: state <= IDLE;
        endcase
    end

endmodule
