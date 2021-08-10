//
// This is a simple floating point add multiply unit
// This is used to include the fpadd and fpmul blocks
// It adds 3 pairs of numbers, and then multiplies the sums
// 
module fpam(clk, rst, pushin, a, b, c, d, e, f, pushout, z);
input         clk, rst;                   // a clock and reset include
input  [63:0] a, b, c, d, e, f;
input         pushin;
output        pushout;
output [63:0] z;
wire   [63:0] z0, z1, z2, zm;
wire          pout0, pout1, pout2;
reg    [63:0] al, bl, cl, dl, el, fl, res;
reg           pushinl,pushoutl;
wire          pushoutm;
//////////////////////////////////////////////////////////////////////////
wire   [63:0] z0_h, z1_h, z2_h;
wire          pout0_h, pout1_h, pout2_h;
//////////////////////////////////////////////////////////////////////////
assign z       = res;
assign pushout = pushoutl;
/////////////////////////////////////////////////////////////////////////
always @(posedge(clk) or posedge(rst)) begin
  if(rst) begin
    al       <= 0;
    bl       <= 0;
    cl       <= 0;
    dl       <= 0;
    el       <= 0;
    fl       <= 0;
    pushoutl <= 0;
    pushinl  <= 0;
    res      <= 0;
  end else begin
    al       <= #1 a;
    bl       <= #1 b;
    cl       <= #1 c;
    dl       <= #1 d;
    el       <= #1 e;
    fl       <= #1 f;
    pushinl  <= #1 pushin;
    pushoutl <= #1 pushoutm;
    res      <= #1 zm;
  end
end
///////////////////////////////////////////////////////////
fpadd  a0(clk, rst, pushinl, al, bl, pout0, z0);
d_ff1  pout0_hold(.clk(clk), .reset(rst), .D(pout0), .Q(pout0_h));
d_ff64 a0_hold(.clk(clk), .reset(rst), .D(z0), .Q(z0_h));
/////////////////////////////////////////////////////////
fpadd  a1(clk, rst, pushinl, cl, dl, pout1, z1);
d_ff1  pout1_hold(.clk(clk), .reset(rst), .D(pout1), .Q(pout1_h));
d_ff64 a1_hold(.clk(clk), .reset(rst), .D(z1), .Q(z1_h));
/////////////////////////////////////////////////////////
fpadd  a2(clk, rst, pushinl, el, fl, pout2, z2);
d_ff1  pout2_hold(.clk(clk), .reset(rst), .D(pout2), .Q(pout2_h));
d_ff64 a2_hold(.clk(clk), .reset(rst), .D(z2), .Q(z2_h));


fpmul  m0(clk, rst, pout0_h&pout1_h&pout2_h, z0_h, z1_h, z2_h, pushoutm, zm);

endmodule













