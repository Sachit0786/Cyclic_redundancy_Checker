`timescale 1ns / 1ps

module crc16_serial(
    input clk,          // Clock signal
    input i_rst_n,      // Active low reset signal
    input i_Init,
    input i_DV,         // Data Valid signal (indicates when data is supplied)
    input [7:0] Data,   // 8-bit input data
    output [15:0] o_CRC    // 16-bit CRC output
);

    reg [15:0] r_CRC;
    integer i;

    always @(posedge clk or negedge i_rst_n) begin
        if (~i_rst_n) begin
            // Reset the CRC to the initial value of 0xffff
            r_CRC <= 16'hffff;
        end
        else
        begin
            if(i_Init) begin
                r_CRC <= 16'hffff;
            end
            else if (i_DV) 
            begin
            // Perform CRC calculation only when data is valid (i_DV is high)
            r_CRC = r_CRC ^ {Data,8'h00};  // XOR data shifted by 8 bits

            // Perform CRC16 calculation
            for (i = 0; i < 8; i = i + 1) begin
                if (r_CRC[15])  // Check the MSB of o_Crc
                    r_CRC = (r_CRC << 1) ^ 16'h1021;  // Polynomial XOR if MSB is 1
                else
                    r_CRC = r_CRC << 1;  // Just shift left if MSB is 0
            end
        end
        // Store the updated CRC value
        r_CRC <= r_CRC & 16'hffff;
        end
    end
    
    assign o_CRC = r_CRC;
    
endmodule
