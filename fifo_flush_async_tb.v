module fifo_flush_async_tb;
  reg rst, rclock, wclock;
  reg fifo_wr_valid_i, fifo_rd_valid_i, fifo_flush_i;
  reg [3:0] fifo_wr_data_i;
  wire fifo_empty_o, fifo_full_o;
  wire [31:0] fifo_rd_data_o;
  wire [ 3:0] fifo_curr_o;
  fifo_flush_async_grey DUT (
      .rclock(rclock),
      .wclock(wclock),
      .reset(rst),
      .fifo_wr_valid_i(fifo_wr_valid_i),
      .fifo_rd_valid_i(fifo_rd_valid_i),
      .fifo_flush_i(fifo_flush_i),
      .fifo_wr_data_i(fifo_wr_data_i),
      .fifo_empty_o(fifo_empty_o),
      .fifo_full_o(fifo_full_o),
      .fifo_rd_data_o(fifo_rd_data_o),
      .fifo_curr_o(fifo_curr_o)
  );

  // free-running clock
  initial begin
    rclock = 1;
    wclock = 1;
  end
  always #5 wclock = ~wclock;
  always #1 rclock = ~rclock;

  // active low asynchronous reset
  initial begin
    rst = 1;
    #2 rst = 0;
  end

  // write
  initial begin
    fifo_wr_valid_i = 0;
    fifo_wr_data_i  = 0;
    #20 fifo_wr_data_i = 4'hA;
    fifo_wr_valid_i = 1;
    #10 fifo_wr_data_i = 4'h3;
    #10 fifo_wr_data_i = 4'h5;
    #10 fifo_wr_data_i = 4'h0;
    fifo_wr_valid_i = 0;
    #10 fifo_wr_data_i = 4'hB;
    #10 fifo_wr_data_i = 4'hD;
    fifo_wr_valid_i = 1;
    #10 fifo_wr_data_i = 4'h1;
    #10 fifo_wr_data_i = 4'h4;
    fifo_wr_valid_i = 0;
    #10 fifo_wr_data_i = 4'h0;
  end

  // read
  initial begin
    fifo_rd_valid_i = 0;
    fifo_flush_i = 0;
    #60 fifo_flush_i = 1;
    #4 fifo_flush_i = 0;
    #38 fifo_flush_i = 1;
    #2 fifo_flush_i = 0;
  end

  initial begin
    #150 $stop;
  end

endmodule
