module routerfifo_tb;
  // Register declarations for inputs and control signals
  reg clk = 0, rst;            // Clock and reset signals
  reg wr_en, rd_en, soft_rst;  // Write enable, read enable, and soft reset
  reg lfd_state;               // Load first data state signal

  reg [7:0] din;               // 8-bit data input
  wire [7:0] dout;             // 8-bit data output
  wire full, empty;            // Full and empty status flags for FIFO

  // Instantiate the FIFO module under test (DUT)
  router_fifo dut(dout,full,empty,clk,rst,soft_rst,lfd_state,wr_en,rd_en,din);

  // Generate a clock with a period of 10 units (toggle every 5 units)
  always #5 clk = ~clk;

  // Loop variables for iteration
  integer i, j;

  // Initial block: Testbench logic begins here
  initial begin
    // Step 1: Apply reset
    rst = 0;              // Assert reset
    #10;                  // Wait for 10 units
    rst = 1;              // De-assert reset

    // Step 2: Initialize control signals and inputs
    soft_rst = 1;         // Apply soft reset
    wr_en = 0;            // Disable write
    rd_en = 0;            // Disable read
    din = 8'b0;           // Initialize data input to 0
    #10;                  // Wait for 10 units

    // Step 3: Write data to the FIFO
    wr_en = 1;            // Enable write
    soft_rst = 0; 
    @(negedge clk )       // De-assert soft reset
    lfd_state = 1;        // Set load first data state
din=8'h10;
@(negedge clk);
lfd_state = 0;
    // Write 15 random 8-bit values into the FIFO
    for (i = 0; i < 15; i = i + 1) begin
      din = $urandom_range(0, 255);  // Generate random data (0 to 255)
      @(negedge clk);                           // Wait for 10 units
                 // Clear load first data state after the first write
    end

    // Step 4: Read data from the FIFO
    wr_en = 0;            // Disable write
    rd_en = 1;            // Enable read

    // Read 16 data values from the FIFO and display them
    for (j = 0; j < 16; j = j + 1) begin
      $display("D[%d]: %h", j, dout);  // Display the data read from the FIFO
      #10;                             // Wait for 10 units between reads
    end
  end
endmodule
