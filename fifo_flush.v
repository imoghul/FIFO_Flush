module fifo_flush (input wire clk,
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
    
    wire [31:0] fifo_out ;
    reg [31:0] fifo_out_show;
    assign fifo_rd_data_o = fifo_out_show;
    
    
    // assing appropriate part of fifo_data_q to output and pad with 0xC's
    for( i_1 = 0;i_1<8;i_1 = i_1+1 ) begin
        assign fifo_out[i_1*4+:4] = ( i_1+rd_ptr<wr_ptr )?fifo_data_q[i_1+rd_ptr]:4'hC;
    end
    
    initial begin
        $dumpfile( "fifo_flush_tb.vcd" );
        $dumpvars( 0, DUT );
        $dumpvars( 0, fifo_data_q[0], fifo_data_q[1], fifo_data_q[2], fifo_data_q[3], fifo_data_q[4], fifo_data_q[5], fifo_data_q[6], fifo_data_q[7], fifo_data_q[8], fifo_data_q[9], fifo_data_q[10] );
        $dumpvars( 0, fifo_data_q[11], fifo_data_q[12], fifo_data_q[13], fifo_data_q[14], fifo_data_q[15], fifo_data_q[16], fifo_data_q[17], fifo_data_q[18], fifo_data_q[19], fifo_data_q[20], fifo_data_q[21], fifo_data_q[22] );
        $dumpvars( 0, fifo_data_q[23], fifo_data_q[24], fifo_data_q[25], fifo_data_q[26], fifo_data_q[27], fifo_data_q[28], fifo_data_q[29], fifo_data_q[30], fifo_data_q[31] );
    end
    
    
    
    reg [4:0] wr_ptr,rd_ptr;
    
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
    wire flush_start;
    assign flush_start = flush_stage == 1;
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
            else flush_stage = 0;
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
        end
        else begin
          fifo_out_show = fifo_out_show;
        end
      end
    end
    
endmodule