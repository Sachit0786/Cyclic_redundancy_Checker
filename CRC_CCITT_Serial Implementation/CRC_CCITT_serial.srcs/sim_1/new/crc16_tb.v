`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.10.2024 20:58:19
// Design Name: 
// Module Name: crc16_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module crc16_tb;

    reg clk;
    reg i_rst_n;
    reg i_DV;
    reg [7:0] Data;
    wire [15:0] CRC;

    // Instantiate the CRC16 module
    crc16 uut (
        .clk(clk),
        .i_rst_n(i_rst_n),
        .i_DV(i_DV),
        .Data(Data),
        .CRC(CRC)
    );

    // Clock generation (50% duty cycle)
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        i_rst_n = 0;
        i_DV = 0;
        Data = 8'h00;

        // Reset the CRC module
        #10 i_rst_n = 1;  // Deassert reset

        // Apply data with i_DV signal high
        #10 Data = 8'hA5; i_DV = 1;  // Supply data A5
        #10 Data = 8'h3C; i_DV = 1;  // Supply data 3C
        #10 Data = 8'hFF; i_DV = 1;  // Supply data FF

        // Stop data supply
        #10 i_DV = 0;

        // Reset the CRC again
        #10 i_rst_n = 0;  // Assert reset
        #10 i_rst_n = 1;  // Deassert reset

        #50 $finish;  // End simulation
    end

    initial begin
        // Monitor changes to display the results
        $monitor("Time: %0t | Data: %h | CRC: %h", $time, Data, CRC);
    end

endmodule


