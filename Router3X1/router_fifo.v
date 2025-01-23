


module router_fifo(d_out,full,empty,clk,rst,s_rst,lfd,w_n,r_n,d_in);
input  clk,rst,s_rst,lfd,w_n,r_n;
input [7:0]d_in;
output full,empty;
output reg [7:0]d_out;
reg [8:0]fifo[15:0];
reg [3:0]rd_pt,wr_pt;
reg lfd_bit;
integer count=0,i,incounter;

always@(posedge clk)
begin
if(!rst)
begin

rd_pt<=0;
wr_pt<=0;
count<=0;
d_out<=0;
for(i=0;i<16;i=i+1)begin
fifo[i]=0;
end
end
else if(s_rst) begin
d_out <= 8'bz;
end
else if(incounter==0)
d_out<=8'bz;
end

always@(posedge clk) begin
if(!rst) 
lfd_bit<=0;
else
lfd_bit<=lfd;
end

always@(posedge clk)begin
 if(w_n &! full)
begin

fifo[wr_pt]<={lfd_bit,d_in};
wr_pt<=wr_pt+1;
count=count+1;
end
end



always@(posedge clk)begin
 if(r_n & !empty)
begin
if(fifo[rd_pt][8])begin
incounter<=fifo[rd_pt][7:2]+1'b1;
end
d_out=fifo[rd_pt][7:0];
rd_pt=rd_pt+1;
count=count-1;
if(!(incounter==0))
incounter=incounter-1;
end
end
assign full=(count==16);
assign empty=(count==0);
endmodule