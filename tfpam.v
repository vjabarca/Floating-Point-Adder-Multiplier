//
// this is a simple test bench for the fpam problem. It will run a few
// easy test cases, and then a lot of more complex problems
//
`timescale 1ns/10ps


module tfpam();

reg clk,rst;
reg pushin;
reg [63:0] ab,bb,cb,db,eb,fb;
wire pushout;
wire [63:0] z;
real a,b,c,d,e,f,res,rz;
reg [63:0] rfifo[0:128];
reg [6:0] rpt,wpt;

real r0=0.0;
real r1=1.0;
real mr1=-1.0;
real r2=2.0;
real r2_5=2.5;

reg [63:0] mask = 64'hffffffff_fffffffC;
reg [63:0] delta;
integer waitclean=0;

reg debug=0;

fpam fp(clk,rst,pushin,ab,bb,cb,db,eb,fb,pushout,z);

initial begin
  clk=1;
  forever #4.125 clk=~clk;
end

initial begin
  if(debug) begin
    $dumpfile("fpam.vcd");
    $dumpvars(9,tfpam);
  end
  rst=0;
  pushin=0;
  wpt=0;
  rpt=0;
  #1;
  rst=1;
  repeat(5) @(posedge(clk));
  #1;
  rst=0;
end

function [31:0] random_range;
  input reg [31:0] low,high;
  reg [31:0] wk,delta;
  begin
    wk=$random;
    delta=high-low+1;
    wk=wk%delta;
    random_range = wk+low;
  end
endfunction

function real randreal;
  input reg unused;
  reg [63:0] wv;
  reg [31:0] rd;
  begin
    rd = $random;
    wv[63]=rd[13];
    wv[62:52]=random_range(11'h2f0,11'h420);
    wv[51:0]={$random,$random};
    randreal = $bitstoreal(wv);
  end
endfunction

task fail;
begin
  $display("\n\n\n  Simulation failed \n\n\n");
  $finish;
end
endtask

always @(posedge(clk)) begin
  if(waitclean > 5) begin
    if(pushout === 1'bx) begin
      $display("pushout is x");
      fail;
    end
    if(pushout === 1) begin
      delta = (z-rfifo[rpt]);
      if(delta[63]) delta=-delta;
      if(delta < 8) begin
        rpt=rpt+1;
      end else begin
        $display("\n\n\nOops ??? Expected %19.15e(%h)\n              Got %19.15e(%h)\n",
        rfifo[rpt],rfifo[rpt],z,z);
        fail;
      end
    end
  end else begin
    waitclean = waitclean+1;
  end
end

task sendone;
  input real ta,tb,tc,td,te,tf;
  input integer nrc;
  real exp;
  reg [63:0] expbits;
  begin
    pushin=1;
    a=ta; b=tb; c=tc; d=td; e=te; f=tf;
    ab = $realtobits(ta);
    bb = $realtobits(tb);
    cb = $realtobits(tc);
    db = $realtobits(td);
    eb = $realtobits(te);
    fb = $realtobits(tf);
    exp = (ta+tb)*(tc+td)*(te+tf);
    expbits = $realtobits(exp);
    rfifo[wpt]=expbits;
    wpt=wpt+1;
    if(rpt==wpt) begin
      $display("\n\n\nYou overran the fifo Morris");
      $display("\n\n\n it failed \n\n\n");
      $finish;
    end
    @(posedge(clk));
    #1;
    pushin=0;
    ab= {$random,$random};
    bb= {$random,$random};
    cb= {$random,$random};
    db= {$random,$random};
    eb= {$random,$random};
    fb= {$random,$random};
    repeat(nrc) @(posedge(clk)) #1;
  end
endtask

initial begin
  repeat(8) @(posedge(clk)) #1;
  sendone(r0,r1,r0,r1,r0,r1,0);
  sendone(r1,mr1,r0,r1,r0,r1,0);
  sendone(mr1,mr1,mr1,mr1,mr1,mr1,0);
  sendone(r0,r1,r0,r1,r0,r1,5);
  sendone(r1,mr1,r0,r1,r0,r1,5);
  sendone(mr1,mr1,mr1,mr1,mr1,mr1,5);

  repeat(1000) begin
    sendone(randreal(1),randreal(1),randreal(1),randreal(1),
        randreal(1),randreal(1),random_range(0,1) );
  end
  repeat(800) begin
    sendone(randreal(1),randreal(1),randreal(1),randreal(1),
        randreal(1),randreal(1),random_range(0,15) );
  end
  repeat(25) @(posedge(clk));
  if(rpt != wpt) begin
    $display("\n\n\nNot all data pushed out");
    fail;
  end
  $display("\n\n\nAll done with a smile\n\n");
  $finish;
end



endmodule


