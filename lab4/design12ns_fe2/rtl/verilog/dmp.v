// *SYNOPSYS CONFIDENTIAL*
//
// This is an unpublished, proprietary work of Synopsys, Inc., and is fully 
// protected under copyright and trade secret laws.  You may not view, use, 
// disclose, copy, or distribute this file or any information contained herein 
// except pursuant to a valid written license from Synopsys.


// This file is generated automatically by 'veriloggen'.




module dmp(clk_ungated,
           ldst_dout,
           en,
           rst_a,
           test_mode,
           clk_dmp,
           q_cmdack,
           q_rdata,
           q_reop,
           q_rspval,
           en3,
           lpending,
           mload,
           mstore,
           nocache,
           sex,
           size,
           dc_disable_r,
           max_one_lpend,
           pcp_rd_rq,
           pcp_wr_rq,
           mc_addr,
           dwr,
           code_dmi_req,
           code_drd,
           code_ldvalid_r,
           en_misaligned,
           lram_base,
           ldst_dmi_req,
           pcp_addr,
           pcp_d_wr,
           ldst_dmi_addr,
           ldst_dmi_wdata,
           ldst_dmi_wr,
           ldst_dmi_be,
           ldst_addr,
           ldst_din,
           ldst_mask,
           ldst_wren,
           ldst_ck_en,
           q_address,
           q_be,
           q_cmd,
           q_cmdval,
           q_eop,
           q_rspack,
           q_wdata,
           q_plen,
           q_buffer,
           q_cache,
           q_mode,
           q_priv,
           ldvalid,
           sync_queue_idle,
           debug_if_r,
           dmp_mload,
           dmp_mstore,
           is_local_ram,
           mwait,
           dmp_holdup12,
           misaligned_int,
           q_ldvalid,
           loc_ldvalid,
           is_peripheral,
           q_busy,
           cgm_queue_idle,
           drd,
           dmp_dwr,
           dmp_en3,
           dmp_addr,
           dmp_size,
           dmp_sex,
           hold_loc,
           is_code_ram,
           debug_if_a,
           misaligned_err,
           pcp_d_rd,
           pcp_ack,
           pcp_dlat,
           pcp_dak,
           ldst_dmi_rdata);


// Includes found automatically in dependent files.
`include "ext_msb.v"
`include "arcutil.v"
`include "extutil.v"
`include "xdefs.v"
`include "arcutil_pkg_defines.v"


input  clk_ungated;
input  [31:0]  ldst_dout;
input  en;
input  rst_a;
input  test_mode;
input  clk_dmp;
input  q_cmdack;
input  [31:0]  q_rdata;
input  q_reop;
input  q_rspval;
input  en3;
input  lpending;
input  mload;
input  mstore;
input  nocache;
input  sex;
input  [1:0]  size;
input  dc_disable_r;
input  max_one_lpend;
input  pcp_rd_rq;
input  pcp_wr_rq;
input  [31:0]  mc_addr;
input  [31:0]  dwr;
input  code_dmi_req;
input  [31:0]  code_drd;
input  code_ldvalid_r;
input  en_misaligned;
input  [EXT_A_MSB:LDST_A_MSB+3]  lram_base;
input  ldst_dmi_req;
input  [EXT_A_MSB:0]  pcp_addr;
input  [31:0]  pcp_d_wr;
input  [31:0]  ldst_dmi_addr;
input  [31:0]  ldst_dmi_wdata;
input  ldst_dmi_wr;
input  [3:0]  ldst_dmi_be;
output [LDST_A_MSB:0]  ldst_addr;
output [31:0]  ldst_din;
output [3:0]  ldst_mask;
output ldst_wren;
output ldst_ck_en;
output [EXT_A_MSB:0]  q_address;
output [3:0]  q_be;
output [1:0]  q_cmd;
output q_cmdval;
output q_eop;
output q_rspack;
output [31:0]  q_wdata;
output [8:0]  q_plen;
output q_buffer;
output q_cache;
output q_mode;
output q_priv;
output ldvalid;
output sync_queue_idle;
output debug_if_r;
output dmp_mload;
output dmp_mstore;
output is_local_ram;
output mwait;
output dmp_holdup12;
output misaligned_int;
output q_ldvalid;
output loc_ldvalid;
output is_peripheral;
output q_busy;
output cgm_queue_idle;
output [31:0]  drd;
output [31:0]  dmp_dwr;
output dmp_en3;
output [31:0]  dmp_addr;
output [1:0]  dmp_size;
output dmp_sex;
output hold_loc;
output is_code_ram;
output debug_if_a;
output misaligned_err;
output [31:0]  pcp_d_rd;
output pcp_ack;
output pcp_dlat;
output pcp_dak;
output [31:0]  ldst_dmi_rdata;

wire clk_ungated;
wire  [31:0] ldst_dout;
wire en;
wire rst_a;
wire test_mode;
wire clk_dmp;
wire q_cmdack;
wire  [31:0] q_rdata;
wire q_reop;
wire q_rspval;
wire en3;
wire lpending;
wire mload;
wire mstore;
wire nocache;
wire sex;
wire  [1:0] size;
wire dc_disable_r;
wire max_one_lpend;
wire pcp_rd_rq;
wire pcp_wr_rq;
wire  [31:0] mc_addr;
wire  [31:0] dwr;
wire code_dmi_req;
wire  [31:0] code_drd;
wire code_ldvalid_r;
wire en_misaligned;
wire  [EXT_A_MSB:LDST_A_MSB+3] lram_base;
wire ldst_dmi_req;
wire  [EXT_A_MSB:0] pcp_addr;
wire  [31:0] pcp_d_wr;
wire  [31:0] ldst_dmi_addr;
wire  [31:0] ldst_dmi_wdata;
wire ldst_dmi_wr;
wire  [3:0] ldst_dmi_be;
wire  [LDST_A_MSB:0] ldst_addr;
wire  [31:0] ldst_din;
wire  [3:0] ldst_mask;
wire ldst_wren;
wire ldst_ck_en;
wire  [EXT_A_MSB:0] q_address;
wire  [3:0] q_be;
wire  [1:0] q_cmd;
wire q_cmdval;
wire q_eop;
wire q_rspack;
wire  [31:0] q_wdata;
wire  [8:0] q_plen;
wire q_buffer;
wire q_cache;
wire q_mode;
wire q_priv;
wire ldvalid;
wire sync_queue_idle;
wire debug_if_r;
wire dmp_mload;
wire dmp_mstore;
wire is_local_ram;
wire mwait;
wire dmp_holdup12;
wire misaligned_int;
wire q_ldvalid;
wire loc_ldvalid;
wire is_peripheral;
wire q_busy;
wire cgm_queue_idle;
wire  [31:0] drd;
wire  [31:0] dmp_dwr;
wire dmp_en3;
wire  [31:0] dmp_addr;
wire  [1:0] dmp_size;
wire dmp_sex;
wire hold_loc;
wire is_code_ram;
wire debug_if_a;
wire misaligned_err;
wire  [31:0] pcp_d_rd;
wire pcp_ack;
wire pcp_dlat;
wire pcp_dak;
wire  [31:0] ldst_dmi_rdata;


// Intermediate signals
wire i_dmp_mload;
wire i_dmp_mstore;
wire i_is_local_ram;
wire i_mwait;
wire i_q_ldvalid;
wire i_is_peripheral;
wire i_q_busy;
wire  [31:0] i_dmp_dwr;
wire i_dmp_en3;
wire  [31:0] i_dmp_addr;
wire  [1:0] i_dmp_size;
wire i_dmp_sex;
wire i_hold_loc;
wire i_dmp_nocache;
wire  [31:0] i_q_drd;
wire i_q_mwait;
wire  [31:0] i_ldst_drd;
wire i_ldst_ldvalid;
wire i_stored_ld_rtn;
wire  [31:0] i_dmp_drd;
wire i_dmp_ldvalid;
wire i_dmp_idle;
wire i_is_ldst_ram;


// Dummy signals for 'unconnected' ports
// (doing this, rather than leaving them genuinely unconnected, stops
//  simulators emitting pointless warnings)
wire u_unconnected_0;
wire u_unconnected_1;
wire u_unconnected_2;
wire u_unconnected_3;
wire u_unconnected_4;
wire u_unconnected_5;


// Instantiation of module ldst_queue
ldst_queue ildst_queue(
  .clk_dmp(clk_dmp),
  .rst_a(rst_a),
  .dmp_dwr(i_dmp_dwr),
  .dmp_en3(i_dmp_en3),
  .dmp_addr(i_dmp_addr),
  .dmp_mload(i_dmp_mload),
  .dmp_mstore(i_dmp_mstore),
  .dmp_nocache(i_dmp_nocache),
  .dmp_size(i_dmp_size),
  .dmp_sex(i_dmp_sex),
  .is_local_ram(i_is_local_ram),
  .is_peripheral(i_is_peripheral),
  .q_cmdack(q_cmdack),
  .q_rdata(q_rdata),
  .q_reop(q_reop),
  .q_rspval(q_rspval),
  .dc_disable_r(dc_disable_r),
  .a_pc_en(u_unconnected_0),
  .b_pc_en(u_unconnected_1),
  .sel_dat(u_unconnected_2),
  .cgm_queue_idle(cgm_queue_idle),
  .sync_queue_idle(sync_queue_idle),
  .q_drd(i_q_drd),
  .q_ldvalid(i_q_ldvalid),
  .q_mwait(i_q_mwait),
  .q_busy(i_q_busy),
  .q_address(q_address),
  .q_wdata(q_wdata),
  .q_be(q_be),
  .q_cmdval(q_cmdval),
  .q_eop(q_eop),
  .q_plen(q_plen),
  .q_rspack(q_rspack),
  .q_cache(q_cache),
  .q_priv(q_priv),
  .q_buffer(q_buffer),
  .q_mode(q_mode),
  .q_cmd(q_cmd)
);


// Instantiation of module ld_arb
ld_arb ild_arb(
  .dmp_mload(i_dmp_mload),
  .dmp_mstore(i_dmp_mstore),
  .q_drd(i_q_drd),
  .q_ldvalid(i_q_ldvalid),
  .q_mwait(i_q_mwait),
  .q_busy(i_q_busy),
  .ldst_dmi_req(ldst_dmi_req),
  .ldst_drd(i_ldst_drd),
  .ldst_ldvalid(i_ldst_ldvalid),
  .stored_ld_rtn(i_stored_ld_rtn),
  .code_dmi_req(code_dmi_req),
  .code_ldvalid_r(code_ldvalid_r),
  .code_drd(code_drd),
  .hold_loc(i_hold_loc),
  .hold_p(u_unconnected_3),
  .dmp_drd(i_dmp_drd),
  .dmp_ldvalid(i_dmp_ldvalid),
  .loc_ldvalid(loc_ldvalid),
  .mwait(i_mwait),
  .dmp_idle(i_dmp_idle)
);


// Instantiation of module decoder
decoder idecoder(
  .dmp_addr(i_dmp_addr),
  .lram_base(lram_base),
  .is_ldst_ram(i_is_ldst_ram),
  .is_code_ram(is_code_ram),
  .is_local_ramx(u_unconnected_4),
  .is_local_ramy(u_unconnected_5),
  .is_local_ram(i_is_local_ram),
  .is_peripheral(i_is_peripheral)
);


// Instantiation of module debug_access
debug_access idebug_access(
  .clk_dmp(clk_dmp),
  .rst_a(rst_a),
  .en(en),
  .pcp_wr_rq(pcp_wr_rq),
  .pcp_rd_rq(pcp_rd_rq),
  .pcp_addr(pcp_addr),
  .pcp_d_wr(pcp_d_wr),
  .is_local_ram(i_is_local_ram),
  .dwr(dwr),
  .en3(en3),
  .mc_addr(mc_addr),
  .mload(mload),
  .mstore(mstore),
  .nocache(nocache),
  .size(size),
  .sex(sex),
  .lpending(lpending),
  .max_one_lpend(max_one_lpend),
  .dmp_drd(i_dmp_drd),
  .dmp_ldvalid(i_dmp_ldvalid),
  .mwait(i_mwait),
  .dmp_idle(i_dmp_idle),
  .debug_if_r(debug_if_r),
  .debug_if_a(debug_if_a),
  .pcp_d_rd(pcp_d_rd),
  .pcp_ack(pcp_ack),
  .pcp_dlat(pcp_dlat),
  .pcp_dak(pcp_dak),
  .dmp_holdup12(dmp_holdup12),
  .drd(drd),
  .ldvalid(ldvalid),
  .dmp_dwr(i_dmp_dwr),
  .dmp_addr(i_dmp_addr),
  .dmp_mload(i_dmp_mload),
  .dmp_mstore(i_dmp_mstore),
  .dmp_nocache(i_dmp_nocache),
  .dmp_sex(i_dmp_sex),
  .dmp_size(i_dmp_size),
  .dmp_en3(i_dmp_en3)
);


// Instantiation of module mem_align_chk
mem_align_chk imem_align_chk(
  .clk_dmp(clk_dmp),
  .rst_a(rst_a),
  .en3(en3),
  .mc_addr(mc_addr),
  .mload(mload),
  .mstore(mstore),
  .size(size),
  .en_misaligned(en_misaligned),
  .misaligned_int(misaligned_int),
  .misaligned_err(misaligned_err)
);


// Instantiation of module dccm_control
dccm_control idccm_control(
  .clk_ungated(clk_ungated),
  .rst_a(rst_a),
  .test_mode(test_mode),
  .dmp_dwr(i_dmp_dwr),
  .dmp_en3(i_dmp_en3),
  .dmp_addr(i_dmp_addr),
  .dmp_mload(i_dmp_mload),
  .dmp_mstore(i_dmp_mstore),
  .dmp_size(i_dmp_size),
  .dmp_sex(i_dmp_sex),
  .ldst_dmi_req(ldst_dmi_req),
  .ldst_dmi_addr(ldst_dmi_addr),
  .ldst_dmi_wdata(ldst_dmi_wdata),
  .ldst_dmi_wr(ldst_dmi_wr),
  .ldst_dmi_be(ldst_dmi_be),
  .ldst_dout(ldst_dout),
  .hold_loc(i_hold_loc),
  .is_ldst_ram(i_is_ldst_ram),
  .is_peripheral(i_is_peripheral),
  .ldst_addr(ldst_addr),
  .ldst_din(ldst_din),
  .ldst_mask(ldst_mask),
  .ldst_wren(ldst_wren),
  .ldst_ck_en(ldst_ck_en),
  .ldst_dmi_rdata(ldst_dmi_rdata),
  .ldst_drd(i_ldst_drd),
  .ldst_ldvalid(i_ldst_ldvalid),
  .stored_ld_rtn(i_stored_ld_rtn)
);


// Output drives
assign dmp_mload        = i_dmp_mload;
assign dmp_mstore       = i_dmp_mstore;
assign is_local_ram     = i_is_local_ram;
assign mwait            = i_mwait;
assign q_ldvalid        = i_q_ldvalid;
assign is_peripheral    = i_is_peripheral;
assign q_busy           = i_q_busy;
assign dmp_dwr          = i_dmp_dwr;
assign dmp_en3          = i_dmp_en3;
assign dmp_addr         = i_dmp_addr;
assign dmp_size         = i_dmp_size;
assign dmp_sex          = i_dmp_sex;
assign hold_loc         = i_hold_loc;

endmodule


