module fifo_flush_async_grey (
    input wire wclock,
    input wire rclock,
    input wire reset,
    input wire fifo_wr_valid_i,
    input wire [3:0] fifo_wr_data_i,
    input wire fifo_rd_valid_i,
    output wire [31:0] fifo_rd_data_o,
    input wire fifo_flush_i,
    output wire fifo_empty_o,
    output wire fifo_full_o
);

  reg [31:0] wr_ptr, rd_ptr;
  wire [31:0] wr_ptr_grey, rd_ptr_grey;

  binary_to_greycode wr (wr_ptr, wr_ptr_grey);
  binary_to_greycode rd (rd_ptr, rd_ptr_grey);

  assign fifo_empty_o = rd_ptr == wr_ptr;
  assign fifo_full_o  = rd_ptr == wr_ptr + 1;

  genvar i_1;
  integer i_2;
  reg [3:0] fifo_data_q[31:0];

  wire [3:0] fifo_curr;
  wire [31:0] fifo_out;
  reg [31:0] fifo_out_show;
  assign fifo_rd_data_o = fifo_out_show;


  // assing appropriate part of fifo_data_q to output and pad with 0xC's
  for (i_1 = 0; i_1 < 8; i_1 = i_1 + 1) begin
    assign fifo_out[i_1*4+:4] = (i_1 + rd_ptr < wr_ptr) ? fifo_data_q[i_1+rd_ptr] : 4'hC;
  end
  assign fifo_curr = fifo_rd_valid_i ? fifo_data_q[rd_ptr]:0;

  // write to fifo
  always @(posedge wclock or negedge reset) begin
    if (reset) begin
      wr_ptr <= 0;
      for (i_2 = 0; i_2 < 32; i_2 = i_2 + 1) fifo_data_q[i_2] <= 0;
    end else begin
      if (fifo_wr_valid_i) begin
        fifo_data_q[wr_ptr] <= fifo_wr_data_i;
        wr_ptr              <= wr_ptr + 1;
      end else begin
        wr_ptr <= wr_ptr;
      end
    end
  end

  // read from fifo
  always @(posedge rclock or negedge reset) begin
    if (reset) begin
      rd_ptr = 0;
      fifo_out_show = 0;
    end else begin
      if (fifo_flush_i) begin
        fifo_out_show = fifo_out;
        rd_ptr = (rd_ptr + 9 > wr_ptr) ? wr_ptr : rd_ptr + 9;
      end else begin
        fifo_out_show = 0;
        rd_ptr = rd_ptr;
      end
    end
  end


endmodule