module fifo_flush (
    input wire clk,
    input wire reset,
    input wire fifo_wr_valid_i,
    input wire [3:0] fifo_wr_data_i,
    output wire fifo_data_avail_o,
    input wire fifo_rd_valid_i,
    output wire [31:0] fifo_rd_data_o,
    input wire fifo_flush_i,
    output wire fifo_flush_done_o,
    output wire fifo_empty_o,
    output wire fifo_full_o
);

  genvar i_1;
  integer i_2;
  reg [3:0] fifo_data_q[31:0];
  reg [31:0] wr_ptr, rd_ptr;
  wire [31:0] fifo_out;
  reg  [31:0] fifo_out_show;


  assign fifo_flush_done_o = fifo_rd_valid_i;

  assign next_fifo_empty_o = rd_ptr == wr_ptr;
  reg fifo_empty;
  always @(posedge clk or negedge reset)
    if (reset) fifo_empty = 1;
    else fifo_empty = next_fifo_empty_o;
  assign fifo_empty_o     = fifo_empty;


  assign next_fifo_full_o = rd_ptr == wr_ptr + 1;
  reg fifo_full;
  always @(posedge clk or negedge reset)
    if (reset) fifo_full = 0;
    else fifo_full = next_fifo_full_o;
  assign fifo_full_o = next_fifo_full_o;

  // assing appropriate part of fifo_data_q to output and pad with 0xC's
  for (i_1 = 0; i_1 < 8; i_1 = i_1 + 1) begin
    assign fifo_out[i_1*4+:4] = (i_1 + rd_ptr < wr_ptr) ? fifo_data_q[i_1+rd_ptr] : 4'hC;
  end



  reg pushed; // something has been pushed onto the fifo since the last time rd_ptr and wr_ptr were the same;

  // write to fifo
  always @(posedge clk or negedge reset) begin
    if (reset) begin
      wr_ptr = 0;
      pushed = 0;
      for (i_2 = 0; i_2 < 32; i_2 = i_2 + 1) fifo_data_q[i_2] = 0;
    end else begin
      if (fifo_wr_valid_i) begin
        fifo_data_q[wr_ptr] = fifo_wr_data_i;
        wr_ptr              = wr_ptr + 1;
        pushed              = 1;
      end else begin
        pushed = pushed;
        wr_ptr = wr_ptr;
      end
    end
  end


  // determine the clock cycle when the flush starts
  reg [1:0] flush_stage;
  reg flush_end;
  reg fifo_data_avail;
  always @(posedge clk or negedge reset) begin
    if (reset) begin
      flush_stage = 0;
      flush_end   = 0;
    end else begin
      if (fifo_flush_i) begin
        if (!flush_stage) begin
          flush_end   <= flush_end;
          flush_stage <= 1;
        end else begin
          flush_end   <= flush_end;
          flush_stage <= 2;
        end
      end else begin
        flush_end   <= flush_stage != 0;
        flush_stage <= 0;
      end
    end
  end

  // set flush_start
  reg  flush_start;
  wire nxt_flush_start;
  assign nxt_flush_start = flush_stage == 1;
  always @* begin
    if (reset) begin
      flush_start = 0;
    end else begin
      flush_start = nxt_flush_start;
    end
  end


  // set avail
  assign next_fifo_data_avail = wr_ptr >= rd_ptr + 4;  //!flush_start && !flush_end;
  
  assign fifo_data_avail_o = fifo_data_avail;
  always @(posedge clk or negedge reset)
    if (reset) begin
      fifo_data_avail = 0;
    end else begin
      if (flush_end) begin
        fifo_data_avail = 0;
      end else if (next_fifo_data_avail) begin
        fifo_data_avail = 1;
      end else fifo_data_avail = fifo_data_avail;
    end


  // perform the flush
  always @(posedge clk or negedge reset) begin
    if (reset) begin
      fifo_out_show = 0;
      rd_ptr = 0;
    end else begin
      if (flush_start) begin
        fifo_out_show <= fifo_out;
        rd_ptr <= (rd_ptr + 8 > wr_ptr) ? wr_ptr : rd_ptr + 8;
      end else if (flush_end) begin
        fifo_out_show <= 0;
        rd_ptr <= rd_ptr;
        
      end else begin
        fifo_out_show <= fifo_out_show;
        rd_ptr <= rd_ptr;
      end
    end
  end

  assign fifo_rd_data_o = (flush_stage == 2) ? fifo_out_show : 0;

endmodule
