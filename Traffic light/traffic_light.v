module traffic_light_fsm (
    input clk,
    input rst,          
    output reg NS_red,  
    output reg NS_yellow,
    output reg NS_green,
    output reg EW_red,  
    output reg EW_yellow,
    output reg EW_green  
);

    parameter S1_NSG_EWR = 2'b00;
    parameter S2_NSY_EWR = 2'b01;
    parameter S3_NSR_EWG  = 2'b10;
    parameter S4_NSR_EWY = 2'b11;

    parameter GREEN_TIME = 10; 
    parameter YELLOW_TIME = 3; 
    reg [1:0] PS, NS;
    reg [31:0] timer; 
    

    always @(posedge clk) begin
        if (rst)
            PS <= S1_NSG_EWR;
        else
            PS <= NS;
    end
    always @(*) begin
        case (PS)
            S1_NSG_EWR: 
                if (timer == GREEN_TIME)
                    NS = S2_NSY_EWR;
                else
                    NS = S1_NSG_EWR;

            S2_NSY_EWR: 
                if (timer == YELLOW_TIME)
                    NS = S3_NSR_EWG ;
                else
                    NS = S2_NSY_EWR;

            S3_NSR_EWG : 
                if (timer == GREEN_TIME)
                    NS = S4_NSR_EWY;
                else
                    NS = S3_NSR_EWG ;

            S4_NSR_EWY: 
                if (timer == YELLOW_TIME)
                    NS = S1_NSG_EWR;
                else
                    NS = S4_NSR_EWY;

            default: NS = S1_NSG_EWR;
        endcase
    end

    always @(posedge clk) begin
        if (rst)
            timer <= 0;
        else if (PS != NS)
            timer <= 0;
        else
            timer <= timer + 1;
    end

    always @(*) begin
        case (PS)
            S1_NSG_EWR: begin
                NS_green = 1;
                NS_yellow = 0;
                NS_red = 0;
                EW_green = 0;
                EW_yellow = 0;
                EW_red = 1;
            end

            S2_NSY_EWR: begin
                NS_green = 0;
                NS_yellow = 1;
                NS_red = 0;
                EW_green = 0;
                EW_yellow = 0;
                EW_red = 1;
            end

            S3_NSR_EWG : begin
                NS_green = 0;
                NS_yellow = 0;
                NS_red = 1;
                EW_green = 1;
                EW_yellow = 0;
                EW_red = 0;
            end

            S4_NSR_EWY: begin
                NS_green = 0;
                NS_yellow = 0;
                NS_red = 1;
                EW_green = 0;
                EW_yellow = 1;
                EW_red = 0;
            end

            default: begin
                NS_green = 0;
                NS_yellow = 0;
                NS_red = 1;
                EW_green = 0;
                EW_yellow = 0;
                EW_red = 1;
            end
        endcase
    end
endmodule

module TF_tb ();
    reg clk=0, rst;
    wire NS_red, NS_yellow, NS_green, EW_red, EW_yellow, EW_green;
    traffic_light_fsm dut (clk, rst, NS_red, NS_yellow, NS_green, EW_red, EW_yellow, EW_green);

    always #5 clk = ~clk;

    initial begin
        rst = 1;
        #10;
        rst = 0;
    end
    initial begin
        $monitor("Time=%0t | NS_red=%b NS_yellow=%b NS_green=%b | EW_red=%b EW_yellow=%b EW_green=%b", $time, NS_red, NS_yellow, NS_green, EW_red, EW_yellow, EW_green);
    end

endmodule