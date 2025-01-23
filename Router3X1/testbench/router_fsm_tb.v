`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.10.2024 09:46:00
// Design Name: 
// Module Name: fsm_router_tb
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


module fsm_tb();
   // Registers to simulate input signals
  reg clk = 0, rst, pkt_valid, fifo_full;
  reg fifo_empty_0, fifo_empty_1, fifo_empty_2;
  reg soft_rst_0, soft_rst_1, soft_rst_2;
  reg parity_done, low_pkt_valid;
  reg [1:0] din; // 2-bit data input for FSM

  // Wires to monitor output signals from the FSM controller
  wire wr_en_reg, detect_addr, lfd_state,ld_state, laf_state;
  wire full_state, rst_int_reg, busy;
   
  // Instantiate the FSM Controller module (Unit Under Test)
  fsm_router DUT (
        clk, rst, pkt_valid, fifo_full, 
        fifo_empty_0, fifo_empty_1, fifo_empty_2, 
        soft_rst_0, soft_rst_1, soft_rst_2, 
        parity_done, low_pkt_valid, 
        din[1:0], wr_en_reg, 
        detect_addr, ld_state, laf_state, 
        lfd_state, full_state, 
        rst_int_reg, busy
    );

  parameter DECODE_ADDRESS      = 3'b000;
  parameter LOAD_FIRST_DATA 	  = 3'b001;
  parameter LOAD_DATA 		      = 3'b010;
  parameter WAIT_TILL_EMPTY 	  = 3'b011;
  parameter CHECK_PARITY_ERROR  = 3'b100;
  parameter LOAD_PARITY 		    = 3'b101;
  parameter FIFO_FULL_STATE 	  = 3'b110;
  parameter LOAD_AFTER_FULL 	  = 3'b111;
  
  reg [3*8:0]string_cmd;

  always@(DUT.PS) begin
    case (DUT.PS)
	    DECODE_ADDRESS      :  string_cmd = "DA";
	    LOAD_FIRST_DATA     :  string_cmd = "LFD";
	    LOAD_DATA    	      :  string_cmd = "LD";
	    WAIT_TILL_EMPTY     :  string_cmd = "WTE";
	    CHECK_PARITY_ERROR  :  string_cmd = "CPE";
	    LOAD_PARITY    	    :  string_cmd = "LP";
	    FIFO_FULL_STATE     :  string_cmd = "FFS";
	    LOAD_AFTER_FULL     :  string_cmd = "LAF";
	  endcase
  end

  // Clock generation: Toggle the clock every 5 time units
  always #5 clk = ~clk;

  // Initial block to provide stimulus and simulate the FSM behavior
  initial begin
    // Step 1: Initialize all inputs to 0
    rst = 0;                // Assert reset to initialize the system
    pkt_valid = 0;
    fifo_full = 0;
    fifo_empty_0 = 0;
    fifo_empty_1 = 0;
    fifo_empty_2 = 0;
    soft_rst_0 = 0;
    soft_rst_1 = 0;
    soft_rst_2 = 0;
    parity_done = 0;
    low_pkt_valid = 0;
    din = 0;

    #10 rst = 1;            // De-assert reset to start the FSM
    pkt_valid = 1;          // Indicate that a valid packet is present
    fifo_empty_0 = 1;       // FIFO 0 is empty, ready to accept data
    din = 2'b00;            // Provide data input
    #10;                    // Wait for 10 time units
    fifo_full = 0;          // FIFO has space available
    pkt_valid = 0;          // No more valid packets for now
    #10;                    // Wait for 10 time units
    fifo_full = 0;

    #10 rst = 0; #10 rst = 1;            // De-assert reset to start the FSM
    pkt_valid = 1;          // Indicate that a valid packet is present
    fifo_empty_0 = 0;       // FIFO 0 is empty, ready to accept data
    din = 2'b00;            // Provide data input
    #10;                    // Wait for 10 time units
    fifo_full = 1;          // FIFO has space available
    pkt_valid = 0;          // No more valid packets for now
    #10;                    // Wait for 10 time units
    fifo_full = 0;

    #10 rst = 0; #10 rst = 1;            // De-assert reset to start the FSM
    pkt_valid = 1;          // Indicate that a valid packet is present
    fifo_empty_0 = 1;       // FIFO 0 is empty, ready to accept data
    din = 2'b00;            // Provide data input
    #10;                    // Wait for 10 time units
    fifo_full = 0;          // FIFO has space available
    pkt_valid = 0;          // No more valid packets for now
    #10;                    // Wait for 10 time units
    fifo_full = 1;

    // The simulation can be extended with more test cases as needed
  end
  endmodule