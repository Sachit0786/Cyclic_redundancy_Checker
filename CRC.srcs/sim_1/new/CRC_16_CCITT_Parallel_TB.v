`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.09.2024 01:05:40
// Design Name: 
// Module Name: CRC_16_CCITT_Parallel_TB
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


//////////////////////////////////////////////////////////////////////////////
// Performs CRC-16-CCITT on input bytes.
// Polynomial is f(x) = x^16+x^12+x^5+1
// In FPGA it's a linear feedback shift register (LFSR).
// Set i_Init to initialize CRC to 0xFFFF (initial value).
//
// This testbench will drive ASCII 1-9 in order to the CRC
// calculator.  Note that data bytes are driven non-consecutively
// in clock cycles.  This tests out the i_DV input.
//
// Expected CRC is 0x29B1
//////////////////////////////////////////////////////////////////////////////
module CRC_16_CCITT_Parallel_TB();
  
  // Instantiate internal signals
  reg r_Init = 0;
  reg r_Clk = 0;
  reg r_DV = 0;
  reg r_Rst_n = 1'b0; // start in reset
  reg [7:0]  r_Data = 8'h30;
  wire [15:0] w_CRC, w_CRC_Reversed_Xor;
  reg [15:0] Result;
  integer ii;

  // Instantiate the DUT (Design Under Test)
  CRC_16_CCITT_Parallel UUT (
    .i_Clk(r_Clk),
    .i_Rst_n(r_Rst_n),
    .i_Init(r_Init),
    .i_DV(r_DV),
    .i_Data(r_Data),
    .o_CRC(w_CRC),
    .o_CRC_Reversed_Xor(w_CRC_Reversed_Xor)
  );

  // Clock Generator:
  always #2 r_Clk = ~r_Clk;
  
  initial begin
    #10 r_Rst_n <= 1'b1; // Release Reset

    // Initialize CRC prior to sending new data.
    @(posedge r_Clk);
    r_Init <= 1'b1;
    @(posedge r_Clk);
    r_Init <= 1'b0;

    for (ii = 0; ii < 8; ii = ii + 1) begin
      @(posedge r_Clk);
      r_DV   <= 1'b1;
      r_Data <= r_Data + 1;
      $display("Value of CRC is %h", w_CRC);
    end

    @(posedge r_Clk);
    r_DV <= 1'b0;
    repeat (10) @(posedge r_Clk);
    r_DV   <= 1'b1;
    r_Data <= r_Data + 1;
    $display("Value of CRC is %h", w_CRC);
    @(posedge r_Clk);
    r_DV <= 1'b0;
    @(posedge r_Clk);
    @(posedge r_Clk);
    $display("Final value of CRC is %h", w_CRC);

    // Equivalent to CRC_Sim.Init();
    Result = 16'hFFFF;

    // Equivalent to CRC_Sim.AddByteSerial
    for (ii = 8'h31; ii < 8'h3A; ii = ii + 1) begin
      Result = AddByteSerial(Result, ii);
    end
    $display("Final Value using Serial Forward %h", Result);      

    // Equivalent to CRC_Sim.Init();
    Result = 16'hFFFF;
    for (ii = 8'h31; ii < 8'h3A; ii = ii + 1) begin
      Result = AddByteSerial(Result, ReverseBits(ii));
    end
    $display("Final Value using Serial Reverse %h", Result);

    // Equivalent to CRC_Sim.Init();
    Result = 16'hFFFF;
    for (ii = 8'h31; ii < 8'h3A; ii = ii + 1) begin
      Result = AddByteParallel(Result, ii);
    end
    $display("Final Value using Parallel Forward %h", Result); 

    // Equivalent to CRC_Sim.Init();
    Result = 16'hFFFF;
    for (ii = 8'h31; ii < 8'h3A; ii = ii + 1) begin
      Result = AddByteParallel(Result, ReverseBits(ii));
    end
    $display("Final Value using Parallel Reverse %h", Result);

    // Add testing here for debug
    Result = 16'hFFFF;
    Result = AddByteParallel(Result, 8'h45);
    Result = AddByteParallel(Result, 8'h53);
    $display("Serial Normal: %h, Backwards %h%h", Result, ReverseBits(Result[15:8]), ReverseBits(Result[7:0]));

    // REVERSED INPUTS
    Result = 16'hFFFF;
    Result = AddByteParallel(Result, ReverseBits(8'h45));
    Result = AddByteParallel(Result, ReverseBits(8'h53));
    $display("Reversed Inputs:");
    $display("Normal: %h, Backwards %h%h", Result, ReverseBits(Result[15:8]), ReverseBits(Result[7:0]));

    // Equivalent to CRC_Sim.ReverseFinalCrc();
    Result = ReverseBits16(Result);
    // Equivalent to CRC_Sim.XorFinalCrc();
    Result = Result ^ 16'hFFFF;
    $display("God please work:");
    $display("Be 0x5787: %h", Result);

    // Initialize CRC prior to sending new data.
    @(posedge r_Clk);
    r_Init <= 1'b1;
    @(posedge r_Clk);
    r_Init <= 1'b0;

    // Send Reversed 0x45 0x53
    @(posedge r_Clk);
    r_DV   <= 1'b1;
    r_Data <= ReverseBits(8'h45);
    @(posedge r_Clk);      
    r_DV   <= 1'b1;
    r_Data <= ReverseBits(8'h53);      
    @(posedge r_Clk);      
    r_DV   <= 1'b0;
    @(posedge r_Clk);

    $display("Be 0x5787 Please: %h", w_CRC_Reversed_Xor);
    $finish;
  end

  // Verilog function to replace ReverseBits
  function [7:0] ReverseBits(input [7:0] data);
    integer jj;
    begin
      for (jj = 0; jj < 8; jj = jj + 1) begin
        ReverseBits[jj] = data[7-jj];
      end
    end
  endfunction

  // Verilog function to reverse 16-bit value
  function [15:0] ReverseBits16(input [15:0] data);
    integer jj;
    begin
      for (jj = 0; jj < 16; jj = jj + 1) begin
        ReverseBits16[jj] = data[15-jj];
      end
    end
  endfunction

  // Verilog task to replace AddByteParallel
  function [15:0] AddByteParallel(input [15:0] crc, input [7:0] D);
    reg [15:0] C;
    reg [15:0] RunningCRC;
    begin
      C = crc; // store previous value before modifying

      RunningCRC[0] = C[8] ^ C[12] ^ D[0] ^ D[4];
      RunningCRC[1] = C[9] ^ C[13] ^ D[1] ^ D[5];
      RunningCRC[2] = C[10] ^ C[14] ^ D[2] ^ D[6];
      RunningCRC[3] = C[11] ^ C[15] ^ D[3] ^ D[7];
      RunningCRC[4] = C[12] ^ D[4];
      RunningCRC[5] = C[8] ^ C[12] ^ C[13] ^ D[0] ^ D[4] ^ D[5];
      RunningCRC[6] = C[9] ^ C[13] ^ C[14] ^ D[1] ^ D[5] ^ D[6];
      RunningCRC[7] = C[10] ^ C[14] ^ C[15] ^ D[2] ^ D[6] ^ D[7];
      RunningCRC[8] = C[0] ^ C[11] ^ C[15] ^ D[3] ^ D[7];
      RunningCRC[9] = C[1] ^ C[12] ^ D[4];
      RunningCRC[10] = C[2] ^ C[13] ^ D[5];
      RunningCRC[11] = C[3] ^ C[14] ^ D[6];
      RunningCRC[12] = C[4] ^ C[8] ^ C[12] ^ C[15] ^ D[0] ^ D[4] ^ D[7];
      RunningCRC[13] = C[5] ^ C[9] ^ C[13] ^ D[1] ^ D[5];
      RunningCRC[14] = C[6] ^ C[10] ^ C[14] ^ D[2] ^ D[6];
      RunningCRC[15] = C[7] ^ C[11] ^ C[15] ^ D[3] ^ D[7];

      AddByteParallel = RunningCRC;
    end
  endfunction

  // Verilog task to replace AddByteSerial
  function [15:0] AddByteSerial(input [15:0] crc, input [7:0] D);
    integer jj;
    reg [15:0] RunningCRC;
    begin
      RunningCRC = crc;
      for (jj = 0; jj < 8; jj = jj + 1) begin
        RunningCRC = {RunningCRC[14:0], (RunningCRC[15] ^ D[jj])};
        if (RunningCRC[15] ^ D[jj])
          RunningCRC = RunningCRC ^ 16'h1021;
      end
      AddByteSerial = RunningCRC;
    end
  endfunction

endmodule

