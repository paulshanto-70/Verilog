`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.10.2024 10:46:33
// Design Name: 
// Module Name: router_sync_tb
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


module router_sync_tb;
  // Registers for inputs and control signals
  reg clk = 0, rst;                    // Clock and reset signals
  reg detect_addr;                     // Signal to detect address
  reg full_0, full_1, full_2;          // Full flags for FIFO instances 0, 1, and 2
  reg empty_0, empty_1, empty_2;       // Empty flags for FIFO instances 0, 1, and 2
  reg wr_en_reg;                       // Register to control write enable
  reg rd_en_0, rd_en_1, rd_en_2;       // Read enable signals for FIFO instances 0, 1, and 2
  reg [1:0] din;                       // 2-bit data input

  // Wires for outputs from the synchronizer module
  wire fifo_full;                      // Signal indicating if the FIFO is full
  wire vld_out_0, vld_out_1, vld_out_2; // Valid output signals for the three FIFOs
  wire soft_reset_0, soft_reset_1, soft_reset_2; // Soft reset signals for the three FIFOs
  wire [2:0] wr_en;                    // Write enable signals for three FIFO instances

  // Instantiate the DUT (Device Under Test)
  router_sync dut (
      clk, rst, din, detect_addr, 
      full_0, full_1, full_2, 
      empty_0, empty_1, empty_2, 
      wr_en_reg, rd_en_0, rd_en_1, rd_en_2, 
      wr_en, fifo_full, 
      vld_out_0, vld_out_1, vld_out_2, 
      soft_reset_0, soft_reset_1, soft_reset_2
  );

  // Clock generation: Toggle clock every 5 time units
  always #5 clk = ~clk;

  // Initial block: Setup the testbench logic
  initial begin
    // Step 1: Initialize all inputs to their default values
    rst = 0;               // Assert reset
    detect_addr = 0;        // Disable address detection
    full_0 = 0; full_1 = 0; full_2 = 0; // FIFOs are not full
    empty_0 = 0; empty_1 = 0; empty_2 = 0; // FIFOs are not empty
    wr_en_reg = 0;          // Write enable is off
    rd_en_0 = 0; rd_en_1 = 0; rd_en_2 = 0; // Read enables are off
    din = 2'b00;            // Set data input to 0
    #10;                    // Wait 10 time units

    // Step 2: De-assert reset to start the system
    rst = 1;
    #10;                    // Wait 10 time units

    // Step 3: Apply stimulus - Enable reading from FIFO 0 and 1
    rd_en_0 = 0;            // Enable read for FIFO 0
    rd_en_1 = 1;            // Enable read for FIFO 1
    rd_en_2 = 0;            // Disable read for FIFO 2
    din = 2'b00;            // Set data input to 00
    detect_addr = 1;        // Enable address detection
    full_0 = 0; full_1 = 0; full_2 = 0; // Ensure FIFOs are not full
    wr_en_reg = 1;          // Enable write control
    empty_0 = 0; empty_1 = 0; empty_2 = 0; // Ensure FIFOs are not empty
  end

endmodule

