module router_register(input clk,                // Clock input
    input rst,                // Active-low reset signal
    input pkt_valid,          // Packet valid signal indicating data validity
    input [7:0] din,          // 8-bit data input
    input fifo_full,          // Signal indicating if the FIFO is full
    input detect_addr,        // Signal for address detection
    input ld_state,           // Signal indicating load state is active
    input laf_state,          // Signal indicating load after full state
    input full_state,         // Signal indicating the full state of the system
    input lfd_state,          // Signal indicating load first data state
    input rst_int_reg,        // Signal to reset the internal register
    output reg [7:0]dout,    // 8-bit data output
    output reg err,           // Error signal output
    output reg parity_done,   // Parity check completion flag
    output reg low_pkt_valid  // Signal indicating low packet validity
);
reg[7:0]header,int_reg,int_parity,ex_parity;


always@(posedge clk) begin
if(!rst) begin
dout<=0;
err<=0;
low_pkt_valid <=0;              
header <= 0;            
int_reg <= 0;
int_parity<=0;
ex_parity<=0;
parity_done<=0; 
end
end

always@(posedge clk) begin
if((ld_state && ~fifo_full && ~pkt_valid )||(laf_state && low_pkt_valid && ~parity_done))
parity_done<=1;
else if(detect_addr)
parity_done<=0;
end

always@(posedge clk) begin
if(ld_state && ~pkt_valid)
low_pkt_valid<=1;
else if(rst_int_reg)
low_pkt_valid<=0;
end
always@(posedge clk) begin
if(detect_addr && pkt_valid)
header<=din;
else if(lfd_state)
dout<=header;
else if (ld_state && ~fifo_full)
dout<=din;
else if (ld_state && fifo_full)
int_reg<=din;
else if(laf_state)
dout<=int_reg;
end
always@(posedge clk) begin
 if (detect_addr) 
 int_parity <= 0;      // Reset if address detection occurs
 else if (lfd_state && pkt_valid) 
 int_parity <= int_parity ^ header; // XOR with header data if packet is valid
 else if (ld_state && pkt_valid && ~full_state) 
 int_parity <= int_parity ^ din; // XOR with data input if in load state
 else 
 int_parity <= int_parity; // Hold current parity value
 end

always@(posedge clk) begin
if (detect_addr) 
 ex_parity <= 0; 
 else if((ld_state && !fifo_full && !pkt_valid) || 
             (laf_state && ~parity_done && low_pkt_valid))
 ex_parity<=din;
 end
 
 always@(posedge clk) begin
  if(parity_done)begin
 if(int_parity==ex_parity)
 err<=0;
 else
 err<=1;
 end
else
err<=0;
end
endmodule
