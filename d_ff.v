/////////////////////Flip-Flops used in fpam.v///////////////////////////////////////
//when we only need one Flip Flop
module d_ff1 (input clk,
              input reset,
              input D,
              output reg Q);

always @ (posedge clk or posedge reset) begin
  if (reset) begin
    Q <= 0;
  end else begin
    Q <= D;
  end
end
endmodule   //d_ff1
/////////////////////////////////////////////////////////////////////////////////////
//when we need a 64 input Flip-Flop
module d_ff64 (input clk,
               input reset,
               input [63:0] D,
               output reg [63:0] Q);

always @ (posedge clk or posedge reset) begin
  if (reset) begin
    Q <= 64'b0;
  end else begin
    Q <= D;
  end
end
endmodule   //d_ff64 



