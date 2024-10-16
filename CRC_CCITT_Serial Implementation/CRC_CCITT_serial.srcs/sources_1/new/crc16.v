`timescale 1ns / 1ps

module crc16(
    input wire clk,          // Clock signal
    input wire i_rst_n,      // Active low reset signal
    input wire i_DV,         // Data Valid signal (indicates when data is supplied)
    input wire [7:0] Data,   // 8-bit input data
    output reg [15:0] CRC    // 16-bit CRC output
);

    reg [15:0] o_Crc;
    integer i;

    always @(posedge clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            // Reset the CRC to the initial value of 0xffff
            o_Crc <= 16'hffff;
            CRC <= 16'hffff;
        end else if (i_DV) begin
            // Perform CRC calculation only when data is valid (i_DV is high)
            o_Crc = o_Crc ^ (Data << 8);  // XOR data shifted by 8 bits

            // Perform CRC16 calculation
            for (i = 0; i < 8; i = i + 1) begin
                if (o_Crc[15])  // Check the MSB of o_Crc
                    o_Crc = (o_Crc << 1) ^ 16'h1021;  // Polynomial XOR if MSB is 1
                else
                    o_Crc = o_Crc << 1;  // Just shift left if MSB is 0
            end

            // Store the updated CRC value
            CRC <= o_Crc & 16'hffff;
        end
    end

endmodule


