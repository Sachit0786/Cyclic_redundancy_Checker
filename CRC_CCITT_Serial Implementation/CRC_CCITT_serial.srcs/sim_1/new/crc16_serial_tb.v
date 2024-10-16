`timescale 1ns / 1ps

module crc16_serial_tb();

    reg i_Clk = 0;
    reg i_Rst_n = 0;
    reg i_DV = 0;
    reg i_Init = 0;
    reg [7:0] i_Data = 8'h81;
    wire [15:0] o_CRC;
    integer i;
    
    crc16_serial uut(
    .clk(i_Clk),
    .i_rst_n(i_Rst_n),
    .i_Init(i_Init),
    .i_DV(i_DV),
    .Data(i_Data),
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


