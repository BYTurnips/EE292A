// *SYNOPSYS CONFIDENTIAL*
//
// This is an unpublished, proprietary work of Synopsys, Inc., and is fully 
// protected under copyright and trade secret laws.  You may not view, use, 
// disclose, copy, or distribute this file or any information contained herein 
// except pursuant to a valid written license from Synopsys.


// This file is generated automatically by 'veriloggen'.




module arc600(clk_ungated,
              ldst_dout,
              code_ram_rdata,
              rst_a,
              ctrl_cpu_start_sync_r,
              l_irq_4,
              l_irq_5,
              l_irq_6,
              l_irq_7,
              l_irq_8,
              l_irq_9,
              l_irq_10,
              l_irq_11,
              l_irq_12,
              l_irq_13,
              l_irq_14,
              l_irq_15,
              l_irq_16,
              l_irq_17,
              l_irq_18,
              l_irq_19,
              test_mode,
              clk,
              clk_debug,
              clk_dmp,
              ibus_busy,
              q_cmdack,
              q_rdata,
              q_reop,
              q_rspval,
              mem_access,
              memory_error,
              h_addr,
              h_dataw,
              h_write,
              h_read,
              aux_access,
              core_access,
              pcp_rd_rq,
              pcp_wr_rq,
              code_dmi_req,
              code_dmi_addr,
              code_dmi_wdata,
              code_dmi_wr,
              code_dmi_be,
              arc_start_a,
              halt,
              xstep,
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
              code_ram_addr,
              code_ram_wdata,
              code_ram_wr,
              code_ram_be,
              code_ram_ck_en,
              en,
              wd_clear,
              ck_disable,
              ck_dmp_gated,
              en_debug_r,
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
              hold_host,
              code_dmi_rdata,
              noaccess,
              reset_applied_r,
              power_toggle,
              pc_sel_r,
              h_datar,
              pcp_d_rd,
              pcp_ack,
              pcp_dlat,
              pcp_dak,
              ldst_dmi_rdata);


// Includes found automatically in dependent files.
`include "arcutil_pkg_defines.v"
`include "arcutil.v"
`include "asmutil.v"
`include "extutil.v"
`include "che_util.v"
`include "xdefs.v"
`include "uxdefs.v"
`include "ext_msb.v"


input  clk_ungated;
input  [31:0]  ldst_dout;
input  [31:0]  code_ram_rdata;
input  rst_a;
input  ctrl_cpu_start_sync_r;
input  l_irq_4;
input  l_irq_5;
input  l_irq_6;
input  l_irq_7;
input  l_irq_8;
input  l_irq_9;
input  l_irq_10;
input  l_irq_11;
input  l_irq_12;
input  l_irq_13;
input  l_irq_14;
input  l_irq_15;
input  l_irq_16;
input  l_irq_17;
input  l_irq_18;
input  l_irq_19;
input  test_mode;
input  clk;
input  clk_debug;
input  clk_dmp;
input  ibus_busy;
input  q_cmdack;
input  [31:0]  q_rdata;
input  q_reop;
input  q_rspval;
input  mem_access;
input  memory_error;
input  [31:0]  h_addr;
input  [31:0]  h_dataw;
input  h_write;
input  h_read;
input  aux_access;
input  core_access;
input  pcp_rd_rq;
input  pcp_wr_rq;
input  code_dmi_req;
input  [31:0]  code_dmi_addr;
input  [31:0]  code_dmi_wdata;
input  code_dmi_wr;
input  [3:0]  code_dmi_be;
input  arc_start_a;
input  halt;
input  xstep;
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
output [CODE_RAM_ADDR_MSB-CODE_RAM_ADDR_LSB:0]  code_ram_addr;
output [31:0]  code_ram_wdata;
output code_ram_wr;
output [3:0]  code_ram_be;
output code_ram_ck_en;
output en;
output wd_clear;
output ck_disable;
output ck_dmp_gated;
output en_debug_r;
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
output hold_host;
output [31:0]  code_dmi_rdata;
output noaccess;
output reset_applied_r;
output power_toggle;
output pc_sel_r;
output [31:0]  h_datar;
output [31:0]  pcp_d_rd;
output pcp_ack;
output pcp_dlat;
output pcp_dak;
output [31:0]  ldst_dmi_rdata;

wire clk_ungated;
wire  [31:0] ldst_dout;
wire  [31:0] code_ram_rdata;
wire rst_a;
wire ctrl_cpu_start_sync_r;
wire l_irq_4;
wire l_irq_5;
wire l_irq_6;
wire l_irq_7;
wire l_irq_8;
wire l_irq_9;
wire l_irq_10;
wire l_irq_11;
wire l_irq_12;
wire l_irq_13;
wire l_irq_14;
wire l_irq_15;
wire l_irq_16;
wire l_irq_17;
wire l_irq_18;
wire l_irq_19;
wire test_mode;
wire clk;
wire clk_debug;
wire clk_dmp;
wire ibus_busy;
wire q_cmdack;
wire  [31:0] q_rdata;
wire q_reop;
wire q_rspval;
wire mem_access;
wire memory_error;
wire  [31:0] h_addr;
wire  [31:0] h_dataw;
wire h_write;
wire h_read;
wire aux_access;
wire core_access;
wire pcp_rd_rq;
wire pcp_wr_rq;
wire code_dmi_req;
wire  [31:0] code_dmi_addr;
wire  [31:0] code_dmi_wdata;
wire code_dmi_wr;
wire  [3:0] code_dmi_be;
wire arc_start_a;
wire halt;
wire xstep;
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
wire  [CODE_RAM_ADDR_MSB-CODE_RAM_ADDR_LSB:0] code_ram_addr;
wire  [31:0] code_ram_wdata;
wire code_ram_wr;
wire  [3:0] code_ram_be;
wire code_ram_ck_en;
wire en;
wire wd_clear;
wire ck_disable;
wire ck_dmp_gated;
wire en_debug_r;
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
wire hold_host;
wire  [31:0] code_dmi_rdata;
wire noaccess;
wire reset_applied_r;
wire power_toggle;
wire pc_sel_r;
wire  [31:0] h_datar;
wire  [31:0] pcp_d_rd;
wire pcp_ack;
wire pcp_dlat;
wire pcp_dak;
wire  [31:0] ldst_dmi_rdata;


// Intermediate signals
wire i_en;
wire i_ldvalid;
wire i_sync_queue_idle;
wire i_debug_if_r;
wire i_dmp_mload;
wire i_dmp_mstore;
wire i_is_local_ram;
wire i_mwait;
wire i_dmp_holdup12;
wire i_misaligned_int;
wire i_q_ldvalid;
wire i_loc_ldvalid;
wire i_is_peripheral;
wire i_q_busy;
wire i_cgm_queue_idle;
wire  [31:0] i_drd;
wire  [31:0] i_dmp_dwr;
wire i_dmp_en3;
wire  [31:0] i_dmp_addr;
wire  [1:0] i_dmp_size;
wire i_dmp_sex;
wire i_hold_loc;
wire i_is_code_ram;
wire i_debug_if_a;
wire i_misaligned_err;
wire i_en3;
wire i_lpending;
wire i_mload;
wire i_mstore;
wire i_nocache;
wire i_sex;
wire  [1:0] i_size;
wire i_dc_disable_r;
wire i_max_one_lpend;
wire  [31:0] i_mc_addr;
wire  [31:0] i_dwr;
wire  [31:0] i_code_drd;
wire i_code_ldvalid_r;
wire i_en_misaligned;
wire  [EXT_A_MSB:LDST_A_MSB+3] i_lram_base;


// Dummy signals for 'unconnected' ports
// (doing this, rather than leaving them genuinely unconnected, stops
//  simulators emitting pointless warnings)


// Instantiation of module quarc
quarc iquarc(
  .clk_ungated(clk_ungated),
  .code_ram_rdata(code_ram_rdata),
  .rst_a(rst_a),
  .ctrl_cpu_start_sync_r(ctrl_cpu_start_sync_r),
  .l_irq_4(l_irq_4),
  .l_irq_5(l_irq_5),
  .l_irq_6(l_irq_6),
  .l_irq_7(l_irq_7),
  .l_irq_8(l_irq_8),
  .l_irq_9(l_irq_9),
  .l_irq_10(l_irq_10),
  .l_irq_11(l_irq_11),
  .l_irq_12(l_irq_12),
  .l_irq_13(l_irq_13),
  .l_irq_14(l_irq_14),
  .l_irq_15(l_irq_15),
  .l_irq_16(l_irq_16),
  .l_irq_17(l_irq_17),
  .l_irq_18(l_irq_18),
  .l_irq_19(l_irq_19),
  .test_mode(test_mode),
  .clk(clk),
  .clk_debug(clk_debug),
  .ibus_busy(ibus_busy),
  .mem_access(mem_access),
  .memory_error(memory_error),
  .h_addr(h_addr),
  .h_dataw(h_dataw),
  .h_write(h_write),
  .h_read(h_read),
  .aux_access(aux_access),
  .core_access(core_access),
  .ldvalid(i_ldvalid),
  .sync_queue_idle(i_sync_queue_idle),
  .debug_if_r(i_debug_if_r),
  .dmp_mload(i_dmp_mload),
  .dmp_mstore(i_dmp_mstore),
  .is_local_ram(i_is_local_ram),
  .mwait(i_mwait),
  .dmp_holdup12(i_dmp_holdup12),
  .misaligned_int(i_misaligned_int),
  .q_ldvalid(i_q_ldvalid),
  .loc_ldvalid(i_loc_ldvalid),
  .is_peripheral(i_is_peripheral),
  .q_busy(i_q_busy),
  .cgm_queue_idle(i_cgm_queue_idle),
  .pcp_rd_rq(pcp_rd_rq),
  .pcp_wr_rq(pcp_wr_rq),
  .drd(i_drd),
  .dmp_dwr(i_dmp_dwr),
  .dmp_en3(i_dmp_en3),
  .dmp_addr(i_dmp_addr),
  .dmp_size(i_dmp_size),
  .dmp_sex(i_dmp_sex),
  .hold_loc(i_hold_loc),
  .is_code_ram(i_is_code_ram),
  .code_dmi_req(code_dmi_req),
  .code_dmi_addr(code_dmi_addr),
  .code_dmi_wdata(code_dmi_wdata),
  .code_dmi_wr(code_dmi_wr),
  .code_dmi_be(code_dmi_be),
  .arc_start_a(arc_start_a),
  .debug_if_a(i_debug_if_a),
  .halt(halt),
  .xstep(xstep),
  .misaligned_err(i_misaligned_err),
  .code_ram_addr(code_ram_addr),
  .code_ram_wdata(code_ram_wdata),
  .code_ram_wr(code_ram_wr),
  .code_ram_be(code_ram_be),
  .code_ram_ck_en(code_ram_ck_en),
  .en(i_en),
  .wd_clear(wd_clear),
  .ck_disable(ck_disable),
  .ck_dmp_gated(ck_dmp_gated),
  .en_debug_r(en_debug_r),
  .en3(i_en3),
  .lpending(i_lpending),
  .mload(i_mload),
  .mstore(i_mstore),
  .nocache(i_nocache),
  .sex(i_sex),
  .size(i_size),
  .dc_disable_r(i_dc_disable_r),
  .max_one_lpend(i_max_one_lpend),
  .mc_addr(i_mc_addr),
  .dwr(i_dwr),
  .hold_host(hold_host),
  .code_drd(i_code_drd),
  .code_ldvalid_r(i_code_ldvalid_r),
  .code_dmi_rdata(code_dmi_rdata),
  .noaccess(noaccess),
  .en_misaligned(i_en_misaligned),
  .reset_applied_r(reset_applied_r),
  .power_toggle(power_toggle),
  .lram_base(i_lram_base),
  .pc_sel_r(pc_sel_r),
  .h_datar(h_datar)
);


// Instantiation of module dmp
dmp idmp(
  .clk_ungated(clk_ungated),
  .ldst_dout(ldst_dout),
  .en(i_en),
  .rst_a(rst_a),
  .test_mode(test_mode),
  .clk_dmp(clk_dmp),
  .q_cmdack(q_cmdack),
  .q_rdata(q_rdata),
  .q_reop(q_reop),
  .q_rspval(q_rspval),
  .en3(i_en3),
  .lpending(i_lpending),
  .mload(i_mload),
  .mstore(i_mstore),
  .nocache(i_nocache),
  .sex(i_sex),
  .size(i_size),
  .dc_disable_r(i_dc_disable_r),
  .max_one_lpend(i_max_one_lpend),
  .pcp_rd_rq(pcp_rd_rq),
  .pcp_wr_rq(pcp_wr_rq),
  .mc_addr(i_mc_addr),
  .dwr(i_dwr),
  .code_dmi_req(code_dmi_req),
  .code_drd(i_code_drd),
  .code_ldvalid_r(i_code_ldvalid_r),
  .en_misaligned(i_en_misaligned),
  .lram_base(i_lram_base),
  .ldst_dmi_req(ldst_dmi_req),
  .pcp_addr(pcp_addr),
  .pcp_d_wr(pcp_d_wr),
  .ldst_dmi_addr(ldst_dmi_addr),
  .ldst_dmi_wdata(ldst_dmi_wdata),
  .ldst_dmi_wr(ldst_dmi_wr),
  .ldst_dmi_be(ldst_dmi_be),
  .ldst_addr(ldst_addr),
  .ldst_din(ldst_din),
  .ldst_mask(ldst_mask),
  .ldst_wren(ldst_wren),
  .ldst_ck_en(ldst_ck_en),
  .q_address(q_address),
  .q_be(q_be),
  .q_cmd(q_cmd),
  .q_cmdval(q_cmdval),
  .q_eop(q_eop),
  .q_rspack(q_rspack),
  .q_wdata(q_wdata),
  .q_plen(q_plen),
  .q_buffer(q_buffer),
  .q_cache(q_cache),
  .q_mode(q_mode),
  .q_priv(q_priv),
  .ldvalid(i_ldvalid),
  .sync_queue_idle(i_sync_queue_idle),
  .debug_if_r(i_debug_if_r),
  .dmp_mload(i_dmp_mload),
  .dmp_mstore(i_dmp_mstore),
  .is_local_ram(i_is_local_ram),
  .mwait(i_mwait),
  .dmp_holdup12(i_dmp_holdup12),
  .misaligned_int(i_misaligned_int),
  .q_ldvalid(i_q_ldvalid),
  .loc_ldvalid(i_loc_ldvalid),
  .is_peripheral(i_is_peripheral),
  .q_busy(i_q_busy),
  .cgm_queue_idle(i_cgm_queue_idle),
  .drd(i_drd),
  .dmp_dwr(i_dmp_dwr),
  .dmp_en3(i_dmp_en3),
  .dmp_addr(i_dmp_addr),
  .dmp_size(i_dmp_size),
  .dmp_sex(i_dmp_sex),
  .hold_loc(i_hold_loc),
  .is_code_ram(i_is_code_ram),
  .debug_if_a(i_debug_if_a),
  .misaligned_err(i_misaligned_err),
  .pcp_d_rd(pcp_d_rd),
  .pcp_ack(pcp_ack),
  .pcp_dlat(pcp_dlat),
  .pcp_dak(pcp_dak),
  .ldst_dmi_rdata(ldst_dmi_rdata)
);


// Output drives
assign en                     = i_en;

endmodule


