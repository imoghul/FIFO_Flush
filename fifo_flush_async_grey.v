

module fifo_flush_async_grey (
    input wire wclock,
    input wire rclock,
    input wire reset,
    input wire fifo_wr_valid_i,
    input wire [3:0] fifo_wr_data_i,
    input wire fifo_rd_valid_i,
    output wire [31:0] fifo_rd_data_o,
    output wire [3:0] fifo_curr_o,
    input wire fifo_flush_i,
    output wire fifo_empty_o,
    output wire fifo_full_o
);
  integer i_2;

  reg [3:0] fifo_data_q[31:0];
  wire [31:0] wr_ptr, rd_ptr;
  reg [31:0] size;
  assign fifo_full_o  = size == 32;

  assign fifo_empty_o = wr_ptr == rd_ptr;


  greycode_counter wr_ptr_counter (
      .clk(wclock),
      .rst(reset),
      .en (fifo_wr_valid_i && !fifo_full_o),
      .out(wr_ptr)
  );
  always @(posedge wclock or negedge reset) begin
    if (reset) begin
      size = 0;
      for (i_2 = 0; i_2 < 32; i_2 = i_2 + 1) fifo_data_q[i_2] <= 0;
    end else begin
      if (fifo_wr_valid_i) begin
        fifo_data_q[wr_ptr] <= fifo_wr_data_i;
        size = size + 1;
      end else begin
        size = size;
        fifo_data_q[wr_ptr] <= fifo_data_q[wr_ptr];
      end
    end
  end

  assign rd_signal = fifo_flush_i;
  greycode_counter rd_ptr_counter (
      .clk(rclock),
      .rst(reset),
      .en (rd_signal && !fifo_empty_o),
      .out(rd_ptr)
  );
  reg [3:0] out;
  assign fifo_curr_o = out;
  always @(posedge rclock or negedge reset) begin
    if (reset) begin
      out = 0;
      size = 0;
    end
    else begin
      size = rd_signal ? size - 1 : size;
      out = rd_signal ? fifo_data_q[rd_ptr] : 0;
    end
  end








endmodule
