`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////
// Performs CRC-16-CCITT on input bytes.
// Polynomial is f(x) = x^16+x^12+x^5+1
// In FPGA it's a linear feedback shift register (LFSR).
// Set i_Init to initialize CRC to 0xFFFF (initial value).
//
// This testbench will drive ASCII 1-9 in order to the CRC
// calculator.  Note that data bytes are driven non-consecutively
// in clock cycles.  This tests out the i_DV input.
//////////////////////////////////////////////////////////////////////////////
module CRC_16_CCITT_Parallel_TB();
  
  // Instantiate internal signals
  reg i_Init = 0;
  reg i_Clk = 0;
  reg i_DV = 0;
  reg i_Rst_n = 1'b0; // start in reset
  reg [7:0]  i_Data = 8'h81;
  wire [15:0] o_CRC;
  integer i;

  // Instantiate the DUT (Design Under Test)
  CRC_16_CCITT_Parallel uut(
    .i_Clk(i_Clk),
    .i_Rst_n(i_Rst_n),
    .i_Init(i_Init),
    .i_DV(i_DV),
    .i_Data(i_Data),
    .o_CRC(o_CRC)
  );

  // Clock Generator:
  always #2 i_Clk = ~i_Clk;
  
  initial begin
    //initially the reset is 0 for 10ns
    #10 

    // Initialize CRC prior to sending new data.
    @(posedge i_Clk) begin
        i_Init <= 1'b1;
        i_Rst_n <= 1'b1;
    end
    
    @(posedge i_Clk)
        i_Init <= 1'b0;

    for (i = 0; i < 8; i = i + 1) begin
      @(posedge i_Clk) begin
        i_DV   <= 1'b1;
        i_Data <= i_Data + 1;
        $display("Value of CRC is %h", o_CRC);
      end
    end

    @(posedge i_Clk)
        i_DV <= 1'b0;
    
    repeat (10) @(posedge i_Clk) begin
        i_DV   <= 1'b1;
        i_Data <= i_Data + 1;
        $display("Value of CRC is %h", o_CRC);
    end
    
    @(posedge i_Clk) begin
        i_DV <= 1'b0;
    end
    #16
        
    @(posedge i_Clk)
        $display("Final value of CRC is %h", o_CRC);
        
    @(posedge i_Clk)
        i_Rst_n = 1'b0;
     
    @(posedge i_Clk)
        i_Rst_n = 1'b1;
        
    for (i = 0; i < 8; i = i + 1) begin
      @(posedge i_Clk) begin
        i_DV   <= 1'b1;
        i_Data <= i_Data + 1;
        $display("Value of CRC is %h", o_CRC);
      end
    end
    
    @(posedge i_Clk) begin
        i_DV <= 1'b0;
    end
    #16
        
    @(posedge i_Clk)
        $display("Final value of CRC is %h", o_CRC);
            
    $finish;
  end
endmodule
