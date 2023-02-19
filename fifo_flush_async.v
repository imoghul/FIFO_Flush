module fifo_flush_async (input wire clk,
                   input wire reset,
                   input wire fifo_wr_valid_i,
                   input wire [3:0] fifo_wr_data_i,
                   output wire fifo_data_avail_o,
                   input wire fifo_rd_valid_i,
                   output wire [31:0] fifo_rd_data_o,
                   input wire fifo_flush_i,
                   output wire fifo_flush_done_o,
                   output wire fifo_empty_o,
                   output wire fifo_full_o);
    
    genvar  i_1;
    integer i_2;
    reg   [3:0]  fifo_data_q [31:0];
    
    wire [31:0] fifo_out;
    reg [31:0] fifo_out_show;
    assign fifo_rd_data_o = fifo_out_show;
    
    assign fifo_flush_done_o = fifo_rd_valid_i;

  	wire next_fifo_empty;
    assign next_fifo_empty = rd_ptr == wr_ptr;
    reg empty,fifo_empty;
    always @ (posedge clk or negedge reset)
      if(reset) begin
      empty = 1;
      fifo_empty = 1;
      end
      else begin
        empty <= next_fifo_empty;
        fifo_empty <= empty;
      end
    assign fifo_empty_o = fifo_empty;
    
  	wire next_fifo_full;
    assign next_fifo_full = rd_ptr == wr_ptr+1;
    reg full,fifo_full;
    always @ (posedge clk or negedge reset)
      if(reset) begin
        fifo_full = 0;
        full = 0;
      end
      else begin
        full <= next_fifo_full;
        fifo_full <= full;
      end

    assign fifo_full_o = fifo_full;



    // assing appropriate part of fifo_data_q to output and pad with 0xC's
    for( i_1 = 0;i_1<8;i_1 = i_1+1 ) begin
        assign fifo_out[i_1*4+:4] = ( i_1+rd_ptr<wr_ptr )?fifo_data_q[i_1+rd_ptr]:4'hC;
    end
    
    
    reg [31:0] wr_ptr,rd_ptr;
    
    reg pushed; // something has been pushed onto the fifo since the last time rd_ptr and wr_ptr were the same;
    
    // write to fifo
    always @ ( posedge clk or negedge reset ) begin
        if ( reset ) begin
            wr_ptr   = 0;
            pushed   = 0;
            for( i_2 = 0;i_2<32;i_2 = i_2+1 ) fifo_data_q[i_2] = 0;
        end
        else begin
            if ( fifo_wr_valid_i ) begin
                fifo_data_q[wr_ptr] = fifo_wr_data_i;
                wr_ptr              = wr_ptr+1;
                pushed              = 1;
            end
            else begin
                pushed = pushed;
                wr_ptr = wr_ptr;
            end
        end
    end
    
    // determine the clock cycle when the flush starts
    reg[1:0] flush_stage;
    reg flush_start;
    wire flush_end;
    wire nxt_flush_start;
    assign nxt_flush_start = flush_stage == 1;
    assign flush_end = !fifo_flush_i;
    assign fifo_data_avail_o = !flush_start && !flush_end;
    always @ ( posedge clk or negedge reset ) begin
        if ( reset ) begin
            flush_stage = 0;
        end
        else begin
            if ( fifo_flush_i ) begin
                if ( !flush_stage ) begin
                   flush_stage = 1;
                end
                else begin
                  flush_stage  = 2;
                end
            end
            else begin
              flush_stage = 0;
            end
        end
    end

    // set flush_start
    always @ * begin
      if(reset) begin
        flush_start = 0;
      end
      else begin
        flush_start = nxt_flush_start;
      end
    end

    
    // perform the flush
    always @ (posedge clk or negedge reset) begin
      if( reset )begin 
        fifo_out_show = 0;
        rd_ptr = 0;
      end
      else begin
        if(flush_start) begin
          fifo_out_show = fifo_out;
          rd_ptr = (rd_ptr+8>wr_ptr-1)?wr_ptr-1:rd_ptr+8;
        end
        else if(flush_end) fifo_out_show = 0;
        else begin
          fifo_out_show = fifo_out_show;
        end
      end
    end
    
endmodule
