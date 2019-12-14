
module testbench
 import bsg_hardfloat_pkg::*;
 #(parameter tr_ring_width_p = 202
   , parameter rom_data_width_p = 202 + 4
   , parameter rom_addr_width_p = 1024
   )
  (
`ifdef VERILATOR
   input clk_i
   , input reset_i
`endif
   );

`ifndef VERILATOR
logic clk_i, reset_i;

bsg_nonsynth_clock_gen
        #( .cycle_time_p(50)
         ) clock_gen
        ( .o(clk_i)
        );

bsg_nonsynth_reset_gen #(  .num_clocks_p     (1)
                         , .reset_cycles_lo_p(1)
                         , .reset_cycles_hi_p(10)
                         )  reset_gen
                         (  .clk_i(clk_i)        
                          , .async_reset_o(reset_i)
                         );
`endif

  logic [dword_width_gp-1:0] a_li, b_li, c_li;
  bsg_fp_op_e op_li;
  bsg_fp_pr_e ipr_li, opr_li;
  bsg_fp_rm_e rm_li;

  logic [dword_width_gp-1:0] data_lo;
  bsg_fp_eflags_s eflags_lo;

  bsg_hardfloat_fpu
   dut
    (.clk_i(clk_i)
     ,.reset_i(reset_i)
  
     ,.a_i(a_li)
     ,.b_i(b_li)
     ,.c_i(c_li)
  
     ,.op_i(op_li)
     ,.ipr_i(ipr_li)
     ,.opr_i(opr_li)
     ,.rm_i(rm_li)
  
     ,.o(data_lo)
     ,.eflags_o(eflags_lo)
     );
 
  typedef struct packed
  {
    logic [63:0] op1;
    logic [63:0] op2;
    logic [63:0] op3;
    bsg_fp_rm_e  rm;
    bsg_fp_pr_e  ipr;
    bsg_fp_pr_e  opr;
    bsg_fp_op_e  fnc;
  }  trace_send_s;

  typedef struct packed
  {
    logic [63:0]    res;
    bsg_fp_eflags_s exc;
    logic [132:0]   zero;
  }  trace_recv_s;

  trace_recv_s tr_data_li;
  logic tr_data_v_li, tr_data_ready_lo;
  trace_send_s tr_data_lo;
  logic tr_data_v_lo, tr_data_yumi_li;

  logic [rom_addr_width_p-1:0] rom_addr_li;
  logic [rom_data_width_p-1:0] rom_data_lo;

  logic error_lo, done_lo;
  bsg_trace_replay
   #(.payload_width_p(tr_ring_width_p)
     ,.rom_addr_width_p(rom_addr_width_p)
     )
   trace_replay
    (.clk_i(clk_i)
     ,.reset_i(reset_i)
     ,.en_i(1'b1)

     ,.data_i(tr_data_li)
     ,.v_i(tr_data_v_li)
     ,.ready_o(tr_ready_lo)

     ,.data_o(tr_data_lo)
     ,.v_o(tr_data_v_lo)
     ,.yumi_i(tr_data_yumi_li)

     ,.rom_addr_o(rom_addr_li)
     ,.rom_data_i(rom_data_lo)

     ,.done_o(done_lo)
     ,.error_o(error_lo)
     );

  bsg_trace_rom
   #(.width_p(rom_data_width_p)
     ,.addr_width_p(rom_addr_width_p)
     )
   trace_rom
    (.addr_i(rom_addr_li)
     ,.data_o(rom_data_lo)
     );

  trace_send_s tr_data_r;
  always_ff @(posedge clk_i)
    if (tr_data_v_lo)
      tr_data_r <= tr_data_lo;

  wire res_is_nan_lo = (data_lo[62-:11] == '1) & (|data_lo[0+:52]);
  always_comb
    begin
      a_li   = tr_data_r.op1;
      b_li   = tr_data_r.op2;
      c_li   = tr_data_r.op3;
      rm_li  = tr_data_r.rm;
      ipr_li = tr_data_r.ipr;
      opr_li = tr_data_r.opr;
      op_li  = tr_data_r.fnc;

      tr_data_yumi_li = tr_data_v_lo;

      tr_data_li.res  = (eflags_lo.nv | res_is_nan_lo) ? '0 : data_lo;
      tr_data_li.exc  = eflags_lo;
      tr_data_li.zero = '0;

      tr_data_v_li = tr_ready_lo;
    end

endmodule

