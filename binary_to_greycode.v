module binary_to_greycode(
  input wire[31:0] in;
  output wire[31:0] out;
)

  assign out[31] = in[31];
  for(integer i = 30;i>=0;i=i-1)
    assign out[i] = in[i]^in[i+1];

endmodule
