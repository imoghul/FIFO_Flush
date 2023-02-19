module fifo_flush_tb; reg rst, clock; reg fifo_wr_valid_i, fifo_rd_valid_i, fifo_flush_i; reg [3:0] fifo_wr_data_i; wire fifo_data_avail_o, fifo_flush_done_o, fifo_empty_o, fifo_full_o; wire [31:0] fifo_rd_data_o; fifo_flush DUT( .clk( clock ), .reset( rst ), .fifo_wr_valid_i( fifo_wr_valid_i ), .fifo_rd_valid_i( fifo_rd_valid_i ), .fifo_flush_i( fifo_flush_i ), .fifo_wr_data_i( fifo_wr_data_i ), .fifo_data_avail_o( fifo_data_avail_o ), .fifo_flush_done_o( fifo_flush_done_o ), .fifo_empty_o( fifo_empty_o ), .fifo_full_o( fifo_full_o ), .fifo_rd_data_o( fifo_rd_data_o ) );

// free-running clock
initial clock   = 1;
always #5 clock = ~clock;
assign en       = 1;
initial begin

    $dumpfile( "fifo_flush_tb.vcd" );
    $dumpvars( 0, DUT );

end
// active low synchronous reset
initial begin
    rst                 = 1;
    fifo_wr_valid_i     = 0;
    fifo_wr_data_i      = 0;
    fifo_rd_valid_i     = 0;
    fifo_flush_i        = 0;
    #10 rst             = 0;
    #10 fifo_wr_valid_i = 1;
    fifo_wr_data_i      = 4'hA;
    #10 fifo_wr_data_i  = 4'h6;
    #10 fifo_wr_data_i  = 4'h8;
    #10 fifo_wr_valid_i = 0;
    #10 fifo_wr_valid_i = 1;
    fifo_flush_i        = 1;
    fifo_wr_data_i      = 4'hA;
    #10 fifo_wr_data_i  = 4'h0;
    #10 fifo_wr_data_i  = 4'h8;
    #10 fifo_wr_data_i  = 4'hA;
    fifo_rd_valid_i     = 1;
    #10 fifo_wr_data_i  = 4'h3;
    fifo_rd_valid_i     = 0;
    fifo_flush_i        = 0;
    #10 fifo_wr_valid_i = 0;
    #20 fifo_flush_i    = 1;
    #20 fifo_rd_valid_i = 1;
end

initial begin
    #150 $finish;
end

endmodule
