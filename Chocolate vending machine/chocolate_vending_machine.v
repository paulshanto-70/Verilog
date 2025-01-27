module vending_machine(
    input clk,
    input rst,
    input [1:0] coin, 
    output reg [2:0] chocolate 
);

// State Encoding
parameter IDLE = 2'b00, FIVE = 2'b01, TEN = 2'b10, TWENTY = 2'b11;

reg [1:0] PS, NS;

// State Transition
always @(posedge clk) begin
    if (rst)
        PS <= IDLE;
    else
        PS <= NS;
end

// Next State Logic and Output Logic
always @(*) begin
    NS = PS;
    chocolate = 3'b000; // Default to no chocolate
    
    case (PS)
        IDLE: begin
            if (coin == 2'b01)
                NS = FIVE;
            else if (coin == 2'b10)
                NS = TEN;
            else if (coin == 2'b11)
                NS = TWENTY;
            else 
                NS = IDLE;
        end
        
        FIVE: begin
            chocolate = 3'b001; // Dispense chocolate A
            NS = IDLE;  // Return to IDLE after dispensing
        end
        
        TEN: begin
            chocolate = 3'b010; // Dispense chocolate B
            NS = IDLE;  // Return to IDLE after dispensing
        end
        
        TWENTY: begin
            chocolate = 3'b100; // Dispense chocolate C
            NS = IDLE;  // Return to IDLE after dispensing
        end
    endcase
end

endmodule

module choco_tb();

    // Testbench signals
    reg clk;
    reg rst;
    reg [1:0] coin;
    wire [2:0] chocolate;

    // Instantiate the vending machine module
    vending_machine uut (
        .clk(clk),
        .rst(rst),
        .coin(coin),
        .chocolate(chocolate)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns clock period (100MHz)
    end

    // Test sequence
    initial begin
        // Initialize signals
        rst = 1;
        coin = 2'b00;
        #10;
        rst = 0;

        // Test case 1: Insert coin 5
        #10 coin = 2'b01;
        #10 coin = 2'b00;
        $display("Inserted 5 units, Chocolate: %0b", chocolate);

        // Test case 2: Insert 10
        #10 coin = 2'b10; 
        #10 coin = 2'b00;
        $display("Inserted 10 units, Chocolate: %0b", chocolate);

        // Test case 3: Insert 20
        #10 coin = 2'b11;
        #10 coin = 2'b00;
        $display("Inserted 20 units, Chocolate: %0b", chocolate);

    end

endmodule