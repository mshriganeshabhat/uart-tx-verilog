`timescale 1ns / 1ps

module tb_uart;
    reg clk;
    reg reset;
    reg tx_start;
    reg [7:0] tx_data;
    wire tx;
    wire tx_done;

    // Connect the testbench to your UART module
    uart_tx uut (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_done(tx_done)
    );

    // Generate Clock Signal (100MHz)
    always #5 clk = ~clk;

    initial begin
        // Initialize everything
        clk = 0;
        reset = 1;
        tx_start = 0;
        tx_data = 8'b0;
        
        #20;
        reset = 0; // Release reset
        
        #20;
        // Transmit first data packet: 8'hA5 (Binary: 10100101)
        tx_data = 8'hA5;
        tx_start = 1;
        #10;
        tx_start = 0;
        
        // Wait until transmission completes
        @(posedge tx_done);
        #100;
        
        // Transmit second data packet: 8'h5C (Binary: 01011100)
        tx_data = 8'h5C;
        tx_start = 1;
        #10;
        tx_start = 0;
        
        @(posedge tx_done);
        #200;
        $finish; // End the simulation
    end
endmodule
