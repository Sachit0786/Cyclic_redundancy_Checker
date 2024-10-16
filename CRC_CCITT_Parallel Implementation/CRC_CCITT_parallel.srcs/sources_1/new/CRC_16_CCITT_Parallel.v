`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////
// Performs CRC-16-CCITT on input bytes.
// Polynomial is f(x) = x^16+x^12+x^5+1
// In FPGA it's a linear feedback shift register (LFSR).
// Set i_Init or reset i_Rst_n to initialize CRC to 0xFFFF (initial value).
// i_Init is used to start the machine for the first time.
// while the i_Rst_n is used when we are to send another chunk of data after some time and want to reset the value of crc register.
// Drive DV when the input byte is valid.
// CRC output will be maintained when i_Init and i_DV are low.
//////////////////////////////////////////////////////////////////////////////
module CRC_16_CCITT_Parallel
  (
   input i_Clk,
   input i_Rst_n,
   input i_Init,
   input i_DV,
   input [7:0] i_Data,
   output [15:0] o_CRC
   );

  reg [15:0] r_CRC;
  reg [15:0] next_CRC;

  // CRC Control logic
  always@(*) begin
        next_CRC[0] = i_Data[4] ^ i_Data[0] ^ r_CRC[8] ^ r_CRC[12];
        next_CRC[1] = i_Data[5] ^ i_Data[1] ^ r_CRC[9] ^ r_CRC[13];
        next_CRC[2] = i_Data[6] ^ i_Data[2] ^ r_CRC[10] ^ r_CRC[14];
        next_CRC[3] = i_Data[7] ^ i_Data[3] ^ r_CRC[11] ^ r_CRC[15];
        next_CRC[4] = i_Data[4] ^ r_CRC[12];
        next_CRC[5] = i_Data[5] ^ i_Data[4] ^ i_Data[0] ^ r_CRC[8] ^ r_CRC[12] ^ r_CRC[13];
        next_CRC[6] = i_Data[6] ^ i_Data[5] ^ i_Data[1] ^ r_CRC[9] ^ r_CRC[13] ^ r_CRC[14];
        next_CRC[7] = i_Data[7] ^ i_Data[6] ^ i_Data[2] ^ r_CRC[10] ^ r_CRC[14] ^ r_CRC[15];
        next_CRC[8] = i_Data[7] ^ i_Data[3] ^ r_CRC[0] ^ r_CRC[11] ^ r_CRC[15];
        next_CRC[9] = i_Data[4] ^ r_CRC[1] ^ r_CRC[12];
        next_CRC[10] = i_Data[5] ^ r_CRC[2] ^ r_CRC[13];
        next_CRC[11] = i_Data[6] ^ r_CRC[3] ^ r_CRC[14];
        next_CRC[12] = i_Data[7] ^ i_Data[4] ^ i_Data[0] ^ r_CRC[4] ^ r_CRC[8] ^ r_CRC[12] ^ r_CRC[15];
        next_CRC[13] = i_Data[5] ^ i_Data[1] ^ r_CRC[5] ^ r_CRC[9] ^ r_CRC[13];
        next_CRC[14] = i_Data[6] ^ i_Data[2] ^ r_CRC[6] ^ r_CRC[10] ^ r_CRC[14];
        next_CRC[15] = i_Data[7] ^ i_Data[3] ^ r_CRC[7] ^ r_CRC[11] ^ r_CRC[15];
  end
  
  always @ (posedge i_Clk or negedge i_Rst_n)
  begin
    if (~i_Rst_n)
      r_CRC <= 16'hFFFF;
    else
    begin
      if (i_Init)
        r_CRC <= 16'hFFFF;
      else if (i_DV)
      begin
        r_CRC <= next_CRC;
      end
    end
  end

  assign o_CRC = r_CRC;
endmodule