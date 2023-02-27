`define binary_to_greycode(in) {in[31],in[30:0]^in[31:1]};
module greycode_counter (
    input wire clk,
    input wire rst,
    input wire en,
    output wire [31:0] out
);

  reg [31:0] binary;
  reg [31:0] grey;

  assign out = grey;

  always @(posedge clk or negedge rst) begin
    if (rst) begin
      binary = 1;
      grey   = 0;
    end else begin
      if (en) begin
        binary <= binary + 1;
        grey   <= {binary[31], binary[30:0] ^ binary[31:1]};  //`binary_to_greycode(binary);
      end else begin
        binary <= binary;
        grey   <= grey;
      end
    end
  end


endmodule
