module fsm_router(
    input clk,              // Clock input
    input rst,              // Active-low reset signal
    input pkt_valid,        // Signal indicating a valid packet is present
    input fifo_full,        // Signal indicating FIFO is full
    input fifo_empty_0,     // Signal indicating FIFO 0 is empty
    input fifo_empty_1,     // Signal indicating FIFO 1 is empty
    input fifo_empty_2,     // Signal indicating FIFO 2 is empty
    input soft_rst_0,       // Soft reset signal for FIFO 0
    input soft_rst_1,       // Soft reset signal for FIFO 1
    input soft_rst_2,       // Soft reset signal for FIFO 2
    input parity_done,      // Signal indicating parity check is complete
    input low_pkt_valid,    // Signal indicating a low-valid packet condition
    input [1:0] din,        // 2-bit input specifying the destination FIFO

    output wr_en_req,       // Write enable request signal
    output detect_addr,     // Signal to detect packet address
    output ld_state,        // Load data state indicator
    output laf_state,       // Load after full state indicator
    output lfd_state,       // Load first data state indicator
    output full_state,      // FIFO full state indicator
    output rst_int_reg,     // Reset internal register signal
    output busy             // Busy signal indicating FSM activity
);

  // State encoding for the FSM (1x3 router control)
  parameter DECODE_ADDRESS     = 3'b000; // State to decode packet address
  parameter LOAD_FIRST_DATA    = 3'b001; // State to load the first data word
  parameter LOAD_DATA          = 3'b010; // State to load subsequent data words
  parameter WAIT_TILL_EMPTY    = 3'b011; // Wait for the target FIFO to become empty
  parameter CHECK_PARITY_ERROR = 3'b100; // State to check for parity errors
  parameter LOAD_PARITY        = 3'b101; // Load parity word
  parameter FIFO_FULL_STATE    = 3'b110; // State when FIFO is full
  parameter LOAD_AFTER_FULL    = 3'b111; // Load data after the FIFO becomes non-full

  reg [2:0] PS, NS; // Current State (PS) and Next State (NS) registers

  // State transition logic triggered on the rising edge of the clock
  always @(posedge clk) begin
    if (!rst) 
      PS <= DECODE_ADDRESS; // Reset state to DECODE_ADDRESS
    else if (soft_rst_0 || soft_rst_1 || soft_rst_2) 
      PS <= DECODE_ADDRESS; // On any soft reset, transition to DECODE_ADDRESS
    else 
      PS <= NS; // Transition to the next state
  end

  // Next state logic based on the current state and input conditions
  always @(*) begin
    NS = DECODE_ADDRESS; // Default next state
    case (PS)
      DECODE_ADDRESS: begin
        if ((pkt_valid && din == 0 && fifo_empty_0) ||
            (pkt_valid && din == 1 && fifo_empty_1) ||
            (pkt_valid && din == 2 && fifo_empty_2))
          NS = LOAD_FIRST_DATA; // Load first data if FIFO is empty
        else if ((pkt_valid && din == 0 && ~fifo_empty_0) ||
                 (pkt_valid && din == 1 && !fifo_empty_1) ||
                 (pkt_valid && din == 2 && !fifo_empty_2))
          NS = WAIT_TILL_EMPTY; // Wait if target FIFO is not empty
        else 
          NS = DECODE_ADDRESS; // Stay in the current state
      end

      LOAD_FIRST_DATA: NS = LOAD_DATA; // Transition to LOAD_DATA state

      LOAD_DATA: begin
        if (fifo_full) 
          NS = FIFO_FULL_STATE; // If FIFO is full, transition to full state
        else if (!fifo_full && !pkt_valid) 
          NS = LOAD_PARITY; // If no more data, load parity
        else 
          NS = LOAD_DATA; // Continue loading data
      end

      WAIT_TILL_EMPTY: begin
        if (fifo_empty_0 || fifo_empty_1 || fifo_empty_2) 
          NS = LOAD_FIRST_DATA; // If any FIFO becomes empty, load first data
        else 
          NS = WAIT_TILL_EMPTY; // Continue waiting
      end

      FIFO_FULL_STATE: begin
        if (!fifo_full) 
          NS = LOAD_AFTER_FULL; // If FIFO is no longer full, load after full
        else 
          NS = FIFO_FULL_STATE; // Stay in the full state
      end

      LOAD_AFTER_FULL: begin
        if (!parity_done && !low_pkt_valid) 
          NS = LOAD_DATA; // If parity not done and valid, load data
        else if (!parity_done && low_pkt_valid) 
          NS = LOAD_PARITY; // If low packet valid, load parity
        else if (parity_done) 
          NS = DECODE_ADDRESS; // If parity done, decode next address
      end

      LOAD_PARITY: NS = CHECK_PARITY_ERROR; // Transition to parity check

      CHECK_PARITY_ERROR: begin
        if (fifo_full) 
          NS = FIFO_FULL_STATE; // If FIFO is full, go to full state
        else 
          NS = DECODE_ADDRESS; // Otherwise, decode next address
      end
    endcase
  end

  // Output assignments based on the current state
  assign detect_addr = (PS == DECODE_ADDRESS); // Detect address in decode state
  assign wr_en_req = (PS == LOAD_DATA || PS == LOAD_PARITY || PS == LOAD_AFTER_FULL); // Write enable in specific states
  assign full_state = (PS == FIFO_FULL_STATE); // Indicate FIFO full state
  assign lfd_state = (PS == LOAD_FIRST_DATA); // Indicate load first data state
  assign busy = (PS == LOAD_FIRST_DATA || PS == LOAD_PARITY || PS == FIFO_FULL_STATE || PS == LOAD_AFTER_FULL || PS == WAIT_TILL_EMPTY || PS == CHECK_PARITY_ERROR); // Indicate FSM is busy
  assign ld_state = (PS == LOAD_DATA); // Indicate load data state
  assign laf_state = (PS == LOAD_AFTER_FULL); // Indicate load after full state
  assign rst_int_reg = (PS == CHECK_PARITY_ERROR); // Reset internal register during parity check

endmodule