module router_top_module(
    input clk,                    // Clock input
    input rst,                    // Reset input
    input [7:0] d_in,             // Data input (8 bits)
    input pkt_valid,              // Packet validity signal
    input rd_en_0,                // Read enable for FIFO 0
    input rd_en_1,                // Read enable for FIFO 1
    input rd_en_2,                // Read enable for FIFO 2
    output vld_out_0,             // Valid output for FIFO 0
    output vld_out_1,             // Valid output for FIFO 1
    output vld_out_2,             // Valid output for FIFO 2
    output err,                   // Error signal
    output busy,                  // Busy signal indicating processing
    output [7:0] dout_0,          // Data output from FIFO 0
    output [7:0] dout_1,          // Data output from FIFO 1
    output [7:0] dout_2           // Data output from FIFO 2
);
wire parity_done,low_pkt_valid,soft_reset0,soft_reset1,soft_reset2,fifo_full;
wire wrt_en_reg,detect_addr,rst_int_reg,ld_state,laf_state,lfd_state,full_state;
wire[7:0] data_in;
wire full_0,full_1,full_2,empty_0,empty_1,empty_2;
wire[2:0] wrt_en;

router_fifo fifo_0(dout_0,full_0,empty_0,clk,rst,soft_reset0,lfd_state,wrt_en[0],rd_en_0,data_in);
router_fifo fifo_1(dout_1,full_1,empty_1,clk,rst,soft_reset1,lfd_state,wrt_en[1],rd_en_1,data_in);
router_fifo fifo_2(dout_2,full_2,empty_2,clk,rst,soft_reset2,lfd_state,wrt_en[2],rd_en_2,data_in);
 
router_sync synchronizer(clk,rst,d_in[1:0],detect_addr,full_0,full_1,full_2,empty_0,empty_1,empty_2,
     wrt_en_reg,rd_en_0,rd_en_1,rd_en_2,wrt_en,fifo_full,vld_out_0,vld_out_1,vld_out_2,soft_reset0,
soft_reset1,soft_reset2);

router_register register(clk,rst,pkt_valid,d_in,fifo_full,detect_addr,ld_state,laf_state,full_state,lfd_state,
rst_int_reg,data_in,err,parity_done,low_pkt_valid);

fsm_router fsm(clk,rst,pkt_valid,fifo_full,empty_0,empty_1,empty_2,soft_reset0,soft_reset1,soft_reset2,
 parity_done,low_pkt_valid,d_in[1:0],wrt_en_reg,detect_addr,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);
endmodule