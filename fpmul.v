//
// This is a simple version of a 64 bit floating point multiplier 
// used in EE287 as a homework problem.
// This is a reduced complexity floating point.  There is no NaN
// overflow, underflow, or infinity values processed.
//
// Inspired by IEEE 754-2008 (Available from the SJSU library to students)
//
// 63  62:52 51:0
// S   Exp   Fract (assumed high order 1)
// 
// Note: all zero exp and fract is a zero 
//  
// 
module fpmul(clk, rst, pushin, a, b, c, pushout, r);
input         clk, rst, pushin;//A valid a,b,c
input  [63:0] a, b, c;	       //the a,b and c inputs
output [63:0] r;	       //the results from this multiply
output        pushout;	       //indicates we have an answer this cycle
////////////////////////////////////////////////////////////////////////////////////////
reg         sA, sB, sC;		   //the signs of the a and b inputs
reg [10:0]  expA, expB, expC;	   //the exponents of each
reg [52:0]  fractA, fractB, fractC;//the fraction of A and B  present
reg         zeroA, zeroB, zeroC;   //a zero operand (special case for later)
reg [159:0] rres, rconstant; //result of the multiplication, rounded result, rounding constant	
reg         signres;		   //sign of the result
reg [10:0]  expres;	           //the exponent result
reg [63:0]  resout;	           //the output value from the always block
////////////////////////////////////////////////////////////////////////////////     
reg         signres_ff1, signres_ff2, signres_ff3, signres_ff4, signres_ff5, signres_ff6, signres_ff7, signres_ff8, signres_ff9, signres_ff10, signres_ff11, signres_ff12, signres_t12;         
reg [10:0]  expres_ff1, expres_ff2, expres_ff3, expres_ff4, expres_ff5, expres_ff6, expres_ff7, expres_ff8, expres_ff9, expres_ff10, expres_ff11,expres_ff12, expres_t11, expres_t12;	
reg [52:0]  fractC_ff1, fractC_ff2, fractC_ff3, fractC_ff4, fractC_ff5, fractC_ff6;
reg [105:0] mres_ff6;
reg [158:0] mres_ff12, mres_t12;
reg         zeroA_ff1, zeroA_ff2, zeroA_ff3, zeroA_ff4, zeroA_ff5, zeroA_ff6, zeroA_ff7, zeroA_ff8, zeroA_ff9, zeroA_ff10, zeroA_ff11, zeroA_ff12;
reg         zeroB_ff1, zeroB_ff2, zeroB_ff3, zeroB_ff4, zeroB_ff5, zeroB_ff6, zeroB_ff7, zeroB_ff8, zeroB_ff9, zeroB_ff10, zeroB_ff11,zeroB_ff12;
reg         zeroC_ff1, zeroC_ff2, zeroC_ff3, zeroC_ff4, zeroC_ff5, zeroC_ff6, zeroC_ff7, zeroC_ff8, zeroC_ff9, zeroC_ff10, zeroC_ff11,zeroC_ff12;
reg         pushin_ff1, pushin_ff2, pushin_ff3, pushin_ff4, pushin_ff5, pushin_ff6, pushin_ff7, pushin_ff8, pushin_ff9, pushin_ff10, pushin_ff11,pushin_ff12; 
/////////////////////////////////////////////////////////////////////////////////
wire [105:0] mres;
wire [158:0] mres_tot;		
/////////////////////////////////////////////////////////////////////
//reg [159:0] rres_ff1, rres_t;        
/////////////////////////////
assign r       = resout;
assign pushout = pushin_ff12;
///////////////////////////////////////////
always @ (posedge clk or posedge rst) begin
  if(rst) begin
    ////ZONE #1//////
    signres_ff1 <= 0;
    expres_ff1  <= 0;
    fractC_ff1  <= 0;
    zeroA_ff1   <= 0;
    zeroB_ff1   <= 0;
    zeroC_ff1   <= 0;  
    pushin_ff1  <= 0;
    ////ZONE #2//////
    signres_ff2 <= 0;
    expres_ff2  <= 0;
    fractC_ff2  <= 0;
    zeroA_ff2   <= 0;
    zeroB_ff2   <= 0;
    zeroC_ff2   <= 0;
    pushin_ff2  <= 0;
    ////ZONE #3//////
    signres_ff3 <= 0;
    expres_ff3  <= 0;
    fractC_ff3  <= 0;
    zeroA_ff3   <= 0;   
    zeroB_ff3   <= 0;
    zeroC_ff3   <= 0;
    pushin_ff3  <= 0;
    ////ZONE #4//////
    signres_ff4 <= 0;
    expres_ff4  <= 0;   
    fractC_ff4  <= 0;
    zeroA_ff4   <= 0;
    zeroB_ff4   <= 0;
    zeroC_ff4   <= 0;
    pushin_ff4  <= 0;
    ////ZONE #5//////
    signres_ff5 <= 0;
    expres_ff5  <= 0;  
    fractC_ff5  <= 0;
    zeroA_ff5   <= 0;
    zeroB_ff5   <= 0;
    zeroC_ff5   <= 0;
    pushin_ff5  <= 0;    
    /*///ZONE #6//////
    signres_ff6 <= 0;
    expres_ff6  <= 0; 
    fractC_ff6  <= 0;  
    mres_ff6    <= 0; 
    zeroA_ff6   <= 0;
    zeroB_ff6   <= 0;
    zeroC_ff6   <= 0;
    pushin_ff6  <= 0;*/   
    ////ZONE #7//////(next DW02_mult_5_stage)//
    signres_ff7 <= 0;
    expres_ff7  <= 0; 
    zeroA_ff7   <= 0;
    zeroB_ff7   <= 0;
    zeroC_ff7   <= 0;
    pushin_ff7  <= 0;
    ////ZONE #8//////
    signres_ff8 <= 0;
    expres_ff8  <= 0; 
    zeroA_ff8   <= 0;
    zeroB_ff8   <= 0;
    zeroC_ff8   <= 0;
    pushin_ff8  <= 0;
    ////ZONE #9//////
    signres_ff9 <= 0;
    expres_ff9  <= 0; 
    zeroA_ff9   <= 0;
    zeroB_ff9   <= 0;
    zeroC_ff9   <= 0;
    pushin_ff9  <= 0;
    ////ZONE #10//////
    signres_ff10 <= 0;
    expres_ff10  <= 0; 
    zeroA_ff10   <= 0;
    zeroB_ff10   <= 0;
    zeroC_ff10   <= 0;
    pushin_ff10  <= 0;
    ////ZONE #11//////
    signres_ff11 <= 0;
    expres_ff11  <= 0; 
    zeroA_ff11   <= 0;
    zeroB_ff11   <= 0;
    zeroC_ff11   <= 0;
    pushin_ff11  <= 0;
    ////ZONE #12//////
    signres_ff12 <= 0;
    expres_ff12  <= 0; 
    zeroA_ff12   <= 0;
    zeroB_ff12   <= 0;
    zeroC_ff12   <= 0;
    pushin_ff12  <= 0;
  end else begin
    ///////////ZONE #1////////
    signres_ff1 <= #1 signres;
    expres_ff1  <= #1 expres;
    fractC_ff1  <= #1 fractC;
    zeroA_ff1   <= #1 zeroA;
    zeroB_ff1   <= #1 zeroB;
    zeroC_ff1   <= #1 zeroC;
    pushin_ff1  <= #1 pushin;
    ///////////ZONE #2////////////
    signres_ff2 <= #1 signres_ff1;
    expres_ff2  <= #1 expres_ff1;
    fractC_ff2  <= #1 fractC_ff1;
    zeroA_ff2   <= #1 zeroA_ff1;
    zeroB_ff2   <= #1 zeroB_ff1;
    zeroC_ff2   <= #1 zeroC_ff1;
    pushin_ff2  <= #1 pushin_ff1;
    ///////////ZONE #3////////////
    signres_ff3 <= #1 signres_ff2;
    expres_ff3  <= #1 expres_ff2;
    fractC_ff3  <= #1 fractC_ff2;
    zeroA_ff3   <= #1 zeroA_ff2;   
    zeroB_ff3   <= #1 zeroB_ff2;
    zeroC_ff3   <= #1 zeroC_ff2;
    pushin_ff3  <= #1 pushin_ff2;
    ///////////ZONE #4////////////
    signres_ff4 <= #1 signres_ff3;
    expres_ff4  <= #1 expres_ff3;   
    fractC_ff4  <= #1 fractC_ff3;
    zeroA_ff4   <= #1 zeroA_ff3;
    zeroB_ff4   <= #1 zeroB_ff3;
    zeroC_ff4   <= #1 zeroC_ff3;
    pushin_ff4  <= #1 pushin_ff3;
    ///////////ZONE #5////////////
    signres_ff5 <= #1 signres_ff4;
    expres_ff5  <= #1 expres_ff4;  
    fractC_ff5  <= #1 fractC_ff4;
    zeroA_ff5   <= #1 zeroA_ff4;
    zeroB_ff5   <= #1 zeroB_ff4;
    zeroC_ff5   <= #1 zeroC_ff4;
    pushin_ff5  <= #1 pushin_ff4;    
    /*///////////ZONE #6///////////
    signres_ff6 <= #1 signres_ff5;
    expres_ff6  <= #1 expres_ff5; 
    fractC_ff6  <= #1 fractC_ff5;  
    mres_ff6    <= #1 mres;  
    zeroA_ff6   <= #1 zeroA_ff5;
    zeroB_ff6   <= #1 zeroB_ff5;
    zeroC_ff6   <= #1 zeroC_ff5;
    pushin_ff6  <= #1 pushin_ff5; */  
    ///////////ZONE #7////////////(next DW02_mult_5_stage)//
    signres_ff7 <= #1 signres_ff5;
    expres_ff7  <= #1 expres_ff5; 
    zeroA_ff7   <= #1 zeroA_ff5;
    zeroB_ff7   <= #1 zeroB_ff5;
    zeroC_ff7   <= #1 zeroC_ff5;
    pushin_ff7  <= #1 pushin_ff5;
    ///////////ZONE #8////////////
    signres_ff8 <= #1 signres_ff7;
    expres_ff8  <= #1 expres_ff7; 
    zeroA_ff8   <= #1 zeroA_ff7;
    zeroB_ff8   <= #1 zeroB_ff7;
    zeroC_ff8   <= #1 zeroC_ff7;
    pushin_ff8  <= #1 pushin_ff7;
    ////////////ZONE #9///////////
    signres_ff9 <= #1 signres_ff8;
    expres_ff9  <= #1 expres_ff8; 
    zeroA_ff9   <= #1 zeroA_ff8;
    zeroB_ff9   <= #1 zeroB_ff8;
    zeroC_ff9   <= #1 zeroC_ff8;
    pushin_ff9  <= #1 pushin_ff8;
    ///////////ZONE #10////////////
    signres_ff10 <= #1 signres_ff9;
    expres_ff10  <= #1 expres_ff9; 
    zeroA_ff10   <= #1 zeroA_ff9;
    zeroB_ff10   <= #1 zeroB_ff9;
    zeroC_ff10   <= #1 zeroC_ff9;
    pushin_ff10  <= #1 pushin_ff9;
    ////////////ZONE #11////////////
    signres_ff11 <= #1 signres_ff10;
    expres_ff11  <= #1 expres_ff10; 
    zeroA_ff11   <= #1 zeroA_ff10;
    zeroB_ff11   <= #1 zeroB_ff10;
    zeroC_ff11   <= #1 zeroC_ff10;
    pushin_ff11  <= #1 pushin_ff10;
    ////////////ZONE #12////////////
    signres_ff12 <= #1 signres_ff11;
    expres_ff12  <= #1 expres_t11; 
    mres_ff12    <= #1 mres_tot; 
    zeroA_ff12   <= #1 zeroA_ff11;
    zeroB_ff12   <= #1 zeroB_ff11;
    zeroC_ff12   <= #1 zeroC_ff11;
    pushin_ff12  <= #1 pushin_ff11;
  end
end

DW02_mult_6_stage	#(53,53)  a0(fractA,fractB,1'b0,clk,mres); 
DW02_mult_6_stage	#(106,53) a1(mres,fractC_ff5,1'b0,clk,mres_tot); 

always @ (*) begin
  sA     = a[63];
  sB     = b[63];
  sC     = c[63];
  expA   = a[62:52];
  expB   = b[62:52];
  expC   = c[62:52];
  fractA = { 1'b1, a[51:0]};
  fractB = { 1'b1, b[51:0]};
  fractC = { 1'b1, c[51:0]}; 
  zeroA  = (a[62:0]==0)?1:0;
  zeroB  = (b[62:0]==0)?1:0;
  zeroC  = (c[62:0]==0)?1:0; 

  rconstant = 159'b0;

  signres   = sA^sB^sC; 
  expres = expA + expB + expC;
  expres_t11 =  expres_ff11;
  expres_t11 = expres_t11 - 11'd2045;

  mres_t12 = mres_ff12;

  if (mres_ff12[158] == 1) 
    rconstant[105] = 1; 
  else if(mres_ff12[157] == 1'b1) 
    rconstant[104] = 1; 
  else 
    rconstant[103] = 1;
  rres = mres_t12 + rconstant;

  signres_t12 = signres_ff12;
  expres_t12 = expres_ff12;

  if((zeroA_ff12 == 1) || (zeroB_ff12 == 1) || (zeroC_ff12 == 1)) begin // sets a zero result to a true 0
    rres   = 0;
    expres_t12  = 0;
    signres_t12 = 0;
    resout  = 64'b0;
  end else begin
    if(rres[158] == 1'b1) begin
      expres_t12 = expres_t12 + 1;
      resout = {signres_t12, expres_t12, rres[157:106]};
    end else if(rres[157] == 1'b0) begin // less than 1/2
      expres_t12 = expres_t12 - 1;
      resout = {signres_t12, expres_t12, rres[155:104]};
    end else begin 
      resout = {signres_t12, expres_t12, rres[156:105]};
    end
  end
end

endmodule
