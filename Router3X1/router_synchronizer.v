module router_sync (
    input clk,              // Clock input signal
    input rst,              // Active-low reset signal
    input [1:0] din,        // 2-bit input data to determine FIFO selection
    input detect_addr,      // Signal indicating if address detection is active
    input full_0,           // Signal indicating if FIFO 0 is full
    input full_1,           // Signal indicating if FIFO 1 is full
    input full_2,           // Signal indicating if FIFO 2 is full
    input empty_0,          // Signal indicating if FIFO 0 is empty
    input empty_1,          // Signal indicating if FIFO 1 is empty
    input empty_2,          // Signal indicating if FIFO 2 is empty
    input wr_en_reg,        // Write enable register input
    input rd_en_0,          // Read enable signal for FIFO 0
    input rd_en_1,          // Read enable signal for FIFO 1
    input rd_en_2,          // Read enable signal for FIFO 2
    output reg [2:0] wr_en, // 3-bit output to control write enable for each FIFO
    output reg fifo_full,   // Output indicating if the selected FIFO is full
    output vld_out_0,       // Valid output signal for FIFO 0 (not empty)
    output vld_out_1,       // Valid output signal for FIFO 1 (not empty)
    output vld_out_2,       // Valid output signal for FIFO 2 (not empty)
    output reg soft_reset_0,// Soft reset signal for FIFO 0
    output reg soft_reset_1,// Soft reset signal for FIFO 1
    output reg soft_reset_2 // Soft reset signal for FIFO 2
);

  // Registers to count cycles for each FIFO's inactivity
  reg [5:0] count0, count1, count2; 
  reg [1:0] tmp_din; // Temporary register to hold the address input

  // Capture 'din' value on the detection of address
  always @(posedge clk) begin
    if (!rst) 
      tmp_din <= 0; // Reset 'tmp_din' to 0 when reset is active
    else if (detect_addr) 
      tmp_din <= din; // Store 'din' if address detection is active
  end

  // Control logic for write enable and FIFO full status based on 'tmp_din'
  always @(*) begin
    case (tmp_din)
      2'b00: begin // Case for FIFO 0
        fifo_full <= full_0; // Set full status for FIFO 0
        wr_en <= (wr_en_reg) ? 3'b001 : 0; // Enable write if 'wr_en_reg' is set
      end
      2'b01: begin // Case for FIFO 1
        fifo_full <= full_1; // Set full status for FIFO 1
        wr_en <= (wr_en_reg) ? 3'b010 : 0; // Enable write if 'wr_en_reg' is set
      end
      2'b10: begin // Case for FIFO 2
        fifo_full <= full_2; // Set full status for FIFO 2
        wr_en <= (wr_en_reg) ? 3'b100 : 0; // Enable write if 'wr_en_reg' is set
      end
      default: begin // Default case: no FIFO selected
        fifo_full <= 0; 
        wr_en <= 0;
      end
    endcase
  end

  // Assign valid outputs based on FIFO emptiness
  assign vld_out_0 = (~empty_0); // Valid if FIFO 0 is not empty
  assign vld_out_1 = (~empty_1); // Valid if FIFO 1 is not empty
  assign vld_out_2 = (~empty_2); // Valid if FIFO 2 is not empty

  // Monitor FIFO 0 for inactivity and trigger soft reset if needed
  always @(posedge clk) begin
    if (!rst) begin
      count0 <= 0; 
      soft_reset_0 <= 0; // Reset state for FIFO 0
    end else if (vld_out_0) begin // If FIFO 0 has valid data
      if (!rd_en_0) begin // If not being read
        if (count0 == 29) begin // After 30 cycles
          soft_reset_0 <= 1; // Trigger soft reset
          count0 <= 0; // Reset counter
        end else begin
          soft_reset_0 <= 0;
          count0 <= count0 + 1; // Increment counter
        end
      end else 
        count0 <= 0; // Reset counter if being read
    end
  end

  // Monitor FIFO 1 for inactivity and trigger soft reset if needed
  always @(posedge clk) begin
    if (!rst) begin
      count1 <= 0;
      soft_reset_1 <= 0; // Reset state for FIFO 1
    end else if (vld_out_1) begin // If FIFO 1 has valid data
      if (!rd_en_1) begin // If not being read
        if (count1 == 29) begin // After 30 cycles
          soft_reset_1 <= 1; // Trigger soft reset
          count1 <= 0; // Reset counter
        end else begin
          soft_reset_1 <= 0;
          count1 <= count1 + 1; // Increment counter
        end
      end else 
        count1 <= 0; // Reset counter if being read
    end
  end

  // Monitor FIFO 2 for inactivity and trigger soft reset if needed
  always @(posedge clk) begin
    if (!rst) begin
      count2 <= 0;
      soft_reset_2 <= 0; // Reset state for FIFO 2
    end else if (vld_out_2) begin // If FIFO 2 has valid data
      if (!rd_en_2) begin // If not being read
        if (count2 == 29) begin // After 30 cycles
          soft_reset_2 <= 1; // Trigger soft reset
          count2 <= 0; // Reset counter
        end else begin
          soft_reset_2 <= 0;
          count2 <= count2 + 1; // Increment counter
        end
      end else 
        count2 <= 0; // Reset counter if being read
    end
  end
endmodule
