`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.10.2024 13:14:32
// Design Name: 
// Module Name: router_tb
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

module router_tb(); // Testbench for the router

    reg clk=0;                              // Clock signal
    reg rst;                                // Reset signal
    reg pkt_valid;                          // Packet validity signal
    reg rd_en_0, rd_en_1, rd_en_2;          // Read enable signals for FIFOs
    reg [7:0] din;                          // Data input to router
    wire vld_out_0, vld_out_1, vld_out_2;   // Valid outputs from FIFOs
    wire err, busy;                         // Error and busy signals
    wire [7:0] dout_0, dout_1, dout_2;      // Data outputs from FIFOs
    integer i;                              // Loop variable for testing
    router_top_module dut(clk, rst, din, pkt_valid, rd_en_0, rd_en_1, rd_en_2, vld_out_0, vld_out_1, vld_out_2, err, busy, dout_0, dout_1, dout_2);
    
    // Clock generation
    always #5 clk = ~clk;
    
    // Task for generating a payload of specified length
    task payload_XB;
        input [6:0] len;            // Length of the payload
        input read;                 // Read enable flag
        input simRead;              // Simulation read enable flag
        input [1:0] addr;           // Address to write/read from FIFO
        input [7:0] ext_parity;     // External parity for the payload
        reg [7:0] header, data;     // Header and data variables
        reg [7:0] parity;           // Parity accumulator
        begin
            parity = 0;
            wait(!busy) begin 
                @(negedge clk);         // Wait for negative edge of clock
                pkt_valid = 1;          // Indicate packet is valid
                header = {len, addr};   // Create header with length and address
                din = header;           // Load header into data input
                parity = parity ^ din;  // Calculate parity
            end
            @(negedge clk);             // Wait for negative edge of clock
            for (i = 0; i < len; i = i + 1) begin
                wait(!busy) begin 
                    @(negedge clk);             // Wait for negative edge of clock
                    data = {$random} % 256;     // Generate random data byte
                    din = data;                 // Load data into data input
                    parity = parity ^ din;      // Update parity
                end
                if(read && simRead && i == 5) begin
                    rd_en_0 = (addr == 0);      // Set read enable for FIFO 0
                    rd_en_1 = (addr == 1);      // Set read enable for FIFO 1
                    rd_en_2 = (addr == 2);      // Set read enable for FIFO 2
                end
            end
            
            wait(!busy) begin 
                @(negedge clk);                                 // Wait for negative edge of clock
                pkt_valid = 0;                                  // Indicate packet is no longer valid
                din = (ext_parity == 0) ? parity : ext_parity;  // Load parity or external parity
            end
            
            if (read) begin
                @(negedge clk);     // Wait for negative edge of clock
                @(negedge clk);     // Wait for negative edge of clock
                
                if(addr == 0) begin
                    rd_en_0 = simRead ? rd_en_0 : 1;        // Set read enable for FIFO 0
                    wait(dut.fifo_0.empty);                 // Wait until FIFO 0 is empty
                    rd_en_0 = 0;
                end else if(addr == 1) begin
                    rd_en_1 = simRead ? rd_en_1 : 1;        // Set read enable for FIFO 1
                    wait(dut.fifo_1.empty);                 // Wait until FIFO 1 is empty
                    rd_en_1 = 0;
                end else if(addr == 2) begin
                    rd_en_2 = simRead ? rd_en_2 : 1;        // Set read enable for FIFO 2
                    wait(dut.fifo_2.empty);                 // Wait until FIFO 2 is empty
                    rd_en_2 = 0;
                end
            end
        end
    endtask
    
    initial begin
        // Initialize signals
        
        pkt_valid = 0;
        rd_en_0 = 0;
        rd_en_1 = 0;
        rd_en_2 = 0;
        din = 0;
        rst = 0; //Apply reset
        #10 rst = 1; // De assert reset
        
        // Test cases with different payload lengths and read addresses
        #20 payload_XB(6'd8, 1, 0, 2'b0, 0); // Payload Length = 8Bytes, Address = 0, sequential Write & Read.
        #30; rst = 0; #10; rst = 1;
        #20 payload_XB(6'd20, 1, 1, 2'b01, 0); // Payload Length = 20Bytes, Address = 1, simultaneous Write & Read.
        #30; rst = 0; #10; rst = 1;
        #20 payload_XB(6'd16, 1, 0,2'b10, 0); // Payload Length = 16Bytes, Address = 1, Reading Disabled.
        #30; rst = 0; #10; rst = 1;
        #20 payload_XB(6'd14, 1, 0, 2'b10, 8'h25); // Payload Length = 16Bytes, Address = 2, Corrupted packet. Squential Write & Read.
    end
     
endmodule
