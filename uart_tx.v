module uart_tx (
    input wire clk,
    input wire reset,
    input wire tx_start,
    input wire [7:0] tx_data,
    output reg tx,
    output reg tx_done
);

    // Simple Baud Rate Generator (Simplifying for simulation)
    // In real hardware, you would count down from your clock frequency to 9600 baud.
    reg [3:0] clk_cnt = 0;
    reg baud_tick;
    always @(posedge clk) begin
        if (clk_cnt == 4) begin
            clk_cnt <= 0;
            baud_tick <= 1;
        end else begin
            clk_cnt <= clk_cnt + 1;
            baud_tick <= 0;
        end
    end

    // State Machine States
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0] state = IDLE;
    reg [2:0] bit_idx = 0;
    reg [7:0] data_shifter = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            tx <= 1'b1;
            tx_done <= 1'b0;
        end else if (baud_tick) begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    tx_done <= 1'b0;
                    if (tx_start) begin
                        data_shifter <= tx_data;
                        state <= START;
                    end
                end
                START: begin
                    tx <= 1'b0; // Start bit is low
                    state <= DATA;
                    bit_idx <= 0;
                end
                DATA: begin
                    tx <= data_shifter[bit_idx];
                    if (bit_idx == 7) begin
                        state <= STOP;
                    end else begin
                        bit_idx <= bit_idx + 1;
                    end
                end
                STOP: begin
                    tx <= 1'b1; // Stop bit is high
                    tx_done <= 1'b1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
