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
module fpadd(clk, rst, pushin, a, b, pushout, r);
input         clk, rst, pushin;//inputs 
input  [63:0] a,b;             // the a and b inputs
output [63:0] r;               // the results from this multiply
output        pushout;	       // indicates we have an answer this cycle
////////////////////////////////////////////////////////////////////////////////////////
parameter         fbw  = 104;
parameter [fbw:0] zero = 0; 
////////////////////////////////////////////////////////////////////////////////////////
reg         sA, sB;	                            // the signs of the a and b inputs
reg [10:0]  expA, expB, expR;                       // the exponents of each
reg [fbw:0] fractA, fractB, fractR, denormB, f2, d2;// the fraction of A and B  present	
reg         zeroA, zeroB;	                    // a zero operand (special case for later)
///////////////////////////////////////////////////////////////////////////////////////
reg            signres;    // sign of the result
reg     [10:0] expres;	   // the exponent result
reg     [63:0] resout;	   // the output value from the always block
integer        iea,ieb,ied;// exponent stuff for difference...
integer        renorm;	   // How much to renormalize...
reg            stopinside;
/////////////////////////////////////////////////////////////////////////////////////////
reg     [10:0]  expA_ff1, expR_ff1, expR_t, expR_ff2, expR_ff3, expR_t3;
integer         ied_ff1, ied_ff2, ied_ff3, ied_ff4;
reg             sA_ff1, sA_ff2, sB_ff1, sB_ff2;
reg     [fbw:0] fractA_ff1, fractA_ff2;
reg     [fbw:0] fractB_ff1, fractB_t, fractB_ff2;
reg     [fbw:0] fractR_ff1, fractR_t, fractR_ff2, fractR_t2, fractR_ff3, fractR_t3;
reg             signres_ff1, signres_ff2, signres_ff3, signres_ff4, signres_t4;
integer         renorm_ff1, renorm_ff2, renorm_ff3, renorm_t3, renorm_ff4, renorm_t4;
reg             pushin_ff1, pushin_ff2, pushin_ff3, pushin_ff4;
///////////////////////////////////////////////////////////////////////////////////////
assign r       = resout;
assign pushout = pushin_ff4;
////////////////////////////////////////////
always @ (posedge clk or posedge rst) begin

  if (rst) begin
    /////ZONE #1/////
    expA_ff1    <= 0;
    ied_ff1     <= 0;	
	sA_ff1      <= 0;	
    sB_ff1      <= 0;
    fractA_ff1  <= 0;	
    fractB_ff1  <= 0;
    signres_ff1 <= 0;
	renorm_ff1  <= 0;
    pushin_ff1  <= 0;
	////ZONE #2//////
    expR_ff1    <= 0;
	ied_ff2     <= 0;
	sA_ff2      <= 0;
	sB_ff2      <= 0;
	fractA_ff2  <= 0;
    fractB_ff2  <= 0;
	fractR_ff1  <= 0;
	signres_ff2 <= 0;
	renorm_ff2  <= 0;
    pushin_ff2  <= 0;
	////ZONE #3//////	
    expR_ff2    <= 0;
	ied_ff3     <= 0;
	fractR_ff2  <= 0;
	signres_ff3 <= 0;
	renorm_ff3  <= 0;
    pushin_ff3  <= 0;	
	////ZONE #4//////	
    expR_ff3    <= 0;
	ied_ff4     <= 0;
	fractR_ff3  <= 0;
	signres_ff4 <= 0;
	renorm_ff4  <= 0;
    pushin_ff4  <= 0;

  end else begin
	/////////ZONE #1//////////
    expA_ff1    <= #1 expA;
	ied_ff1     <= #1 ied;
    sA_ff1      <= #1 sA;
    sB_ff1      <= #1 sB;
    fractA_ff1  <= #1 fractA;
    fractB_ff1  <= #1 fractB;
    signres_ff1 <= #1 signres;
	renorm_ff1  <= #1 renorm;
    pushin_ff1  <= #1 pushin;
	///////////ZONE #2////////////
	expR_ff1    <= #1 expR;
	ied_ff2     <= #1 ied_ff1;
	sA_ff2      <= #1 sA_ff1;
	sB_ff2      <= #1 sB_ff1;
	fractA_ff2  <= #1 fractA_ff1;
	fractB_ff2  <= #1 fractB_t;
	fractR_ff1  <= #1 fractR; 
    signres_ff2 <= #1 signres_ff1;
	renorm_ff2  <= #1 renorm_ff1; 
    pushin_ff2  <= #1 pushin_ff1;
	///////////ZONE #3////////////
    expR_ff2    <= #1 expR_t;
	ied_ff3     <= #1 ied_ff2;
	fractR_ff2  <= #1 fractR_t;
	signres_ff3 <= #1 signres_ff2;
	renorm_ff3  <= #1 renorm_ff2; 
    pushin_ff3  <= #1 pushin_ff2;
	///////////ZONE #4////////////	
    expR_ff3    <= #1 expR_ff2;	
	ied_ff4     <= #1 ied_ff3;
	fractR_ff3  <= #1 fractR_t2;	
	signres_ff4 <= #1 signres_ff3;
	renorm_ff4  <= #1 renorm_t3;
    pushin_ff4  <= #1 pushin_ff3;	
  end
end
///////////////////////////////////////
always @(*) begin
  zeroA  = (a[62:0]==0)?1:0;
  zeroB  = (b[62:0]==0)?1:0;
  renorm = 0;

  if( b[62:0] > a[62:0] ) begin
    expA    = b[62:52];
    expB    = a[62:52];
    sA      = b[63];
    sB      = a[63];
    fractA  = (zeroB)?0:{2'b1, b[51:0], zero[fbw:54]};
    fractB  = (zeroA)?0:{2'b1, a[51:0], zero[fbw:54]};
    signres = sA;
  end else begin
    sA      = a[63];
    sB      = b[63];
    expA    = a[62:52];
    expB    = b[62:52];
    fractA  = (zeroA)?0:{2'b1, a[51:0], zero[fbw:54]};
    fractB  = (zeroB)?0:{2'b1, b[51:0], zero[fbw:54]};
    signres = sA;
  end

  ied = expA - expB;
//////////////////////////Zone #1/////////////////////////////
  fractB_t = fractB_ff1;

  if(ied_ff1 > 60) begin
    expR   = expA_ff1;
    fractR = fractA_ff1;
  end else begin
    expR     = expA_ff1;
    denormB  = 0;
    fractB_t = (ied_ff1[5])?{32'b0,fractB_t[fbw:32]}: {fractB_t};
    fractB_t = (ied_ff1[4])?{16'b0,fractB_t[fbw:16]}: {fractB_t};
    fractB_t = (ied_ff1[3])?{ 8'b0,fractB_t[fbw:8 ]}: {fractB_t};
    fractB_t = (ied_ff1[2])?{ 4'b0,fractB_t[fbw:4 ]}: {fractB_t};
    fractB_t = (ied_ff1[1])?{ 2'b0,fractB_t[fbw:2 ]}: {fractB_t};
    fractB_t = (ied_ff1[0])?{ 1'b0,fractB_t[fbw:1 ]}: {fractB_t};
    fractR = 0;
  end
//////////////////////////Zone #2/////////////////////////////
  expR_t = expR_ff1;
  fractR_t = fractR_ff1;
  
  if(ied_ff2 <= 60) begin
    if(sA_ff2 == sB_ff2) 
	  fractR_t = fractA_ff2 + fractB_ff2; 
	else 
	  fractR_t = fractA_ff2 - fractB_ff2;
    //fractAdd=fractR;
    //renorm=0;
	if(fractR_t[fbw]) begin
      fractR_t = {1'b0, fractR_t[fbw:1]};
      expR_t   = expR_t + 1;
    end 
  end
//////////////////////////Zone #3/////////////////////////////
fractR_t2 = fractR_ff2; 
renorm_t3 = renorm_ff3;

  if (ied_ff3 <= 60) begin
    //renorm_t3 = 0;
    if(fractR_t2[fbw-1:fbw-32] == 0) begin 
	  renorm_t3[5] = 1; 
	  fractR_t2 = {1'b0, fractR_t2[fbw-33:0], 32'b0}; 
    end
    if(fractR_t2[fbw-1:fbw-16] == 0) begin 
	  renorm_t3[4] = 1; 
	  fractR_t2 = {1'b0, fractR_t2[fbw-17:0], 16'b0}; 
    end
    if(fractR_t2[fbw-1:fbw-8] == 0) begin 
	  renorm_t3[3] = 1; 
	  fractR_t2 = {1'b0, fractR_t2[fbw-9:0], 8'b0}; 
    end
    if(fractR_t2[fbw-1:fbw-4] == 0) begin 
	  renorm_t3[2] = 1; 
	  fractR_t2 = {1'b0, fractR_t2[fbw-5:0], 4'b0}; 
    end
    if(fractR_t2[fbw-1:fbw-2] == 0) begin 
	  renorm_t3[1] = 1; 
	  fractR_t2 = {1'b0, fractR_t2[fbw-3:0], 2'b0}; 
    end
    if(fractR_t2[fbw-1   ] == 0) begin 
	  renorm_t3[0] = 1; 
	  fractR_t2 = {1'b0, fractR_t2[fbw-2:0], 1'b0}; 
    end
  end
//////////////////////////Zone #4/////////////////////////////  
  expR_t3 = expR_ff3; 
  fractR_t3 = fractR_ff3;
  signres_t4 = signres_ff4;
  renorm_t4 = renorm_ff4;

  if (ied_ff4 <= 60) begin
    //fractPreRound=fractR;
    if(fractR_t3 != 0) begin
      if(fractR_t3[fbw-55:0] == 0 && fractR_t3[fbw-54] == 1) begin
	if(fractR_t3[fbw-53] == 1) fractR_t3 = fractR_t3 + {1'b1, zero[fbw-54:0]};
      end else begin
        if(fractR_t3[fbw-54] == 1) fractR_t3 = fractR_t3 + {1'b1, zero[fbw-54:0]};
      end
      expR_t3 = expR_t3 - renorm_t4;
      if(fractR_t3[fbw-1] == 0) begin
       expR_t3   = expR_t3 + 1;
       fractR_t3 = {1'b0, fractR_t3[fbw-1:1]};
      end
    end else begin
      expR_t3   = 0;
      signres_t4 = 0;
    end
  end

  resout = {signres_t4, expR_t3, fractR_t3[fbw-2:fbw-53]};

end

endmodule
