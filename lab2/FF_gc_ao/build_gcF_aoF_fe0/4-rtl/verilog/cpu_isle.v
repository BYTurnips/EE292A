// *SYNOPSYS CONFIDENTIAL*
//
// This is an unpublished, proprietary work of Synopsys, Inc., and is fully 
// protected under copyright and trade secret laws.  You may not view, use, 
// disclose, copy, or distribute this file or any information contained herein 
// except pursuant to a valid written license from Synopsys.


// This file is generated automatically by 'veriloggen'.




module cpu_isle(rst_n_a,
                ctrl_cpu_start,
                xirq_n_4,
                xirq_n_5,
                xirq_n_6,
                xirq_n_7,
                xirq_n_8,
                xirq_n_9,
                xirq_n_10,
                xirq_n_11,
                xirq_n_12,
                xirq_n_13,
                xirq_n_14,
                xirq_n_15,
                xirq_n_16,
                xirq_n_17,
                xirq_n_18,
                xirq_n_19,
                jtag_tck,
                jtag_trst_n,
                test_mode,
                clk_in,
                clk_system_in,
                hclk,
                hresetn,
                hgrant,
                hready,
                hresp,
                hrdata,
                code_dmi_req,
                code_dmi_addr,
                code_dmi_wdata,
                code_dmi_wr,
                code_dmi_be,
                arc_start_a,
                ldst_dmi_req,
                ldst_dmi_addr,
                ldst_dmi_wdata,
                ldst_dmi_wr,
                ldst_dmi_be,
                jtag_tdi,
                jtag_tms,
                jtag_bsr_tdo,
                en,
                hbusreq,
                hlock,
                htrans,
                haddr,
                hwrite,
                hsize,
                hburst,
                hprot,
                hwdata,
                code_dmi_rdata,
                power_toggle,
                ldst_dmi_rdata,
                jtag_tdo,
                jtag_tdo_zen_n);


// Includes found automatically in dependent files.
`include "arcutil_pkg_defines.v"
`include "extutil.v"
`include "xdefs.v"
`include "che_util.v"
`include "arcutil.v"
`include "ext_msb.v"
`include "asmutil.v"
`include "uxdefs.v"


input  rst_n_a;
input  ctrl_cpu_start;
input  xirq_n_4;
input  xirq_n_5;
input  xirq_n_6;
input  xirq_n_7;
input  xirq_n_8;
input  xirq_n_9;
input  xirq_n_10;
input  xirq_n_11;
input  xirq_n_12;
input  xirq_n_13;
input  xirq_n_14;
input  xirq_n_15;
input  xirq_n_16;
input  xirq_n_17;
input  xirq_n_18;
input  xirq_n_19;
input  jtag_tck;
input  jtag_trst_n;
input  test_mode;
input  clk_in;
input  clk_system_in;
input  hclk;
input  hresetn;
input  hgrant;
input  hready;
input  [1:0]  hresp;
input  [31:0]  hrdata;
input  code_dmi_req;
input  [31:0]  code_dmi_addr;
input  [31:0]  code_dmi_wdata;
input  code_dmi_wr;
input  [3:0]  code_dmi_be;
input  arc_start_a;
input  ldst_dmi_req;
input  [31:0]  ldst_dmi_addr;
input  [31:0]  ldst_dmi_wdata;
input  ldst_dmi_wr;
input  [3:0]  ldst_dmi_be;
input  jtag_tdi;
input  jtag_tms;
input  jtag_bsr_tdo;
output en;
output hbusreq;
output hlock;
output [1:0]  htrans;
output [31:0]  haddr;
output hwrite;
output [2:0]  hsize;
output [2:0]  hburst;
output [3:0]  hprot;
output [31:0]  hwdata;
output [31:0]  code_dmi_rdata;
output power_toggle;
output [31:0]  ldst_dmi_rdata;
output jtag_tdo;
output jtag_tdo_zen_n;

wire rst_n_a;
wire ctrl_cpu_start;
wire xirq_n_4;
wire xirq_n_5;
wire xirq_n_6;
wire xirq_n_7;
wire xirq_n_8;
wire xirq_n_9;
wire xirq_n_10;
wire xirq_n_11;
wire xirq_n_12;
wire xirq_n_13;
wire xirq_n_14;
wire xirq_n_15;
wire xirq_n_16;
wire xirq_n_17;
wire xirq_n_18;
wire xirq_n_19;
wire jtag_tck;
wire jtag_trst_n;
wire test_mode;
wire clk_in;
wire clk_system_in;
wire hclk;
wire hresetn;
wire hgrant;
wire hready;
wire  [1:0] hresp;
wire  [31:0] hrdata;
wire code_dmi_req;
wire  [31:0] code_dmi_addr;
wire  [31:0] code_dmi_wdata;
wire code_dmi_wr;
wire  [3:0] code_dmi_be;
wire arc_start_a;
wire ldst_dmi_req;
wire  [31:0] ldst_dmi_addr;
wire  [31:0] ldst_dmi_wdata;
wire ldst_dmi_wr;
wire  [3:0] ldst_dmi_be;
wire jtag_tdi;
wire jtag_tms;
wire jtag_bsr_tdo;
wire en;
wire hbusreq;
wire hlock;
wire  [1:0] htrans;
wire  [31:0] haddr;
wire hwrite;
wire  [2:0] hsize;
wire  [2:0] hburst;
wire  [3:0] hprot;
wire  [31:0] hwdata;
wire  [31:0] code_dmi_rdata;
wire power_toggle;
wire  [31:0] ldst_dmi_rdata;
wire jtag_tdo;
wire jtag_tdo_zen_n;


// Intermediate signals
wire i_en;
wire i_clk_ungated;
wire  [LDST_A_MSB:0] i_ldst_addr;
wire  [31:0] i_ldst_din;
wire  [3:0] i_ldst_mask;
wire i_ldst_wren;
wire i_ldst_ck_en;
wire  [CODE_RAM_ADDR_MSB-CODE_RAM_ADDR_LSB:0] i_code_ram_addr;
wire  [31:0] i_code_ram_wdata;
wire i_code_ram_wr;
wire  [3:0] i_code_ram_be;
wire i_code_ram_ck_en;
wire  [31:0] i_ldst_dout;
wire  [31:0] i_code_ram_rdata;
wire i_rst_a;
wire i_wd_clear;
wire i_ctrl_cpu_start_sync_r;
wire i_l_irq_4;
wire i_l_irq_5;
wire i_l_irq_6;
wire i_l_irq_7;
wire i_l_irq_8;
wire i_l_irq_9;
wire i_l_irq_10;
wire i_l_irq_11;
wire i_l_irq_12;
wire i_l_irq_13;
wire i_l_irq_14;
wire i_l_irq_15;
wire i_l_irq_16;
wire i_l_irq_17;
wire i_l_irq_18;
wire i_l_irq_19;
wire i_jtag_trst_a;
wire i_ck_disable;
wire i_ck_dmp_gated;
wire i_en_debug_r;
wire i_clk;
wire i_clk_debug;
wire i_clk_dmp;
wire i_clk_system;
wire i_sync;
wire i_ibus_busy;
wire  [EXT_A_MSB:0] i_q_address;
wire  [3:0] i_q_be;
wire  [1:0] i_q_cmd;
wire i_q_cmdval;
wire i_q_eop;
wire i_q_rspack;
wire  [31:0] i_q_wdata;
wire  [8:0] i_q_plen;
wire i_q_buffer;
wire i_q_cache;
wire i_q_mode;
wire i_q_priv;
wire i_q_cmdack;
wire  [31:0] i_q_rdata;
wire i_q_reop;
wire i_q_rspval;
wire i_mem_access;
wire i_memory_error;
wire  [31:0] i_h_addr;
wire  [31:0] i_h_dataw;
wire i_h_write;
wire i_h_read;
wire i_aux_access;
wire i_core_access;
wire i_pcp_rd_rq;
wire i_pcp_wr_rq;
wire i_halt;
wire i_xstep;
wire  [EXT_A_MSB:0] i_pcp_addr;
wire  [31:0] i_pcp_d_wr;
wire i_hold_host;
wire i_noaccess;
wire i_reset_applied_r;
wire i_pc_sel_r;
wire  [31:0] i_h_datar;
wire  [31:0] i_pcp_d_rd;
wire i_pcp_ack;
wire i_pcp_dlat;
wire i_pcp_dak;


// Dummy signals for 'unconnected' ports
// (doing this, rather than leaving them genuinely unconnected, stops
//  simulators emitting pointless warnings)
wire u_unconnected_0;
wire u_unconnected_1;
wire u_unconnected_2;
wire  [7:0] u_unconnected_3;
wire  [3:0] u_unconnected_4;
wire u_unconnected_5;
wire u_unconnected_6;
wire u_unconnected_7;
wire u_unconnected_8;
wire u_unconnected_9;


// Instantiation of module arc_ram
arc_ram iarc_ram(
  .clk_ungated(i_clk_ungated),
  .ldst_addr(i_ldst_addr),
  .ldst_din(i_ldst_din),
  .ldst_mask(i_ldst_mask),
  .ldst_wren(i_ldst_wren),
  .ldst_ck_en(i_ldst_ck_en),
  .code_ram_addr(i_code_ram_addr),
  .code_ram_wdata(i_code_ram_wdata),
  .code_ram_wr(i_code_ram_wr),
  .code_ram_be(i_code_ram_be),
  .code_ram_ck_en(i_code_ram_ck_en),
  .ldst_dout(i_ldst_dout),
  .code_ram_rdata(i_code_ram_rdata)
);


// Instantiation of module io_flops
io_flops iio_flops(
  .clk_ungated(i_clk_ungated),
  .rst_n_a(rst_n_a),
  .en(i_en),
  .rst_a(i_rst_a),
  .wd_clear(i_wd_clear),
  .ctrl_cpu_start_sync_r(i_ctrl_cpu_start_sync_r),
  .ctrl_cpu_start(ctrl_cpu_start),
  .xirq_n_4(xirq_n_4),
  .xirq_n_5(xirq_n_5),
  .xirq_n_6(xirq_n_6),
  .xirq_n_7(xirq_n_7),
  .xirq_n_8(xirq_n_8),
  .xirq_n_9(xirq_n_9),
  .xirq_n_10(xirq_n_10),
  .xirq_n_11(xirq_n_11),
  .xirq_n_12(xirq_n_12),
  .xirq_n_13(xirq_n_13),
  .xirq_n_14(xirq_n_14),
  .xirq_n_15(xirq_n_15),
  .xirq_n_16(xirq_n_16),
  .xirq_n_17(xirq_n_17),
  .xirq_n_18(xirq_n_18),
  .xirq_n_19(xirq_n_19),
  .l_irq_4(i_l_irq_4),
  .l_irq_5(i_l_irq_5),
  .l_irq_6(i_l_irq_6),
  .l_irq_7(i_l_irq_7),
  .l_irq_8(i_l_irq_8),
  .l_irq_9(i_l_irq_9),
  .l_irq_10(i_l_irq_10),
  .l_irq_11(i_l_irq_11),
  .l_irq_12(i_l_irq_12),
  .l_irq_13(i_l_irq_13),
  .l_irq_14(i_l_irq_14),
  .l_irq_15(i_l_irq_15),
  .l_irq_16(i_l_irq_16),
  .l_irq_17(i_l_irq_17),
  .l_irq_18(i_l_irq_18),
  .l_irq_19(i_l_irq_19),
  .jtag_tck(jtag_tck),
  .jtag_trst_n(jtag_trst_n),
  .jtag_trst_a(i_jtag_trst_a),
  .test_mode(test_mode)
);


// Instantiation of module ck_gen
ck_gen ick_gen(
  .clk_in(clk_in),
  .clk_system_in(clk_system_in),
  .ck_disable(i_ck_disable),
  .ck_dmp_gated(i_ck_dmp_gated),
  .en_debug_r(i_en_debug_r),
  .clk(i_clk),
  .clk_debug(i_clk_debug),
  .clk_dmp(i_clk_dmp),
  .clk_ungated(i_clk_ungated),
  .clk_system(i_clk_system)
);


// Instantiation of module ibus
ibus iibus(
  .clk(i_clk),
  .clk_ungated(i_clk_ungated),
  .clk_system(i_clk_system),
  .rst_a(i_rst_a),
  .sync(i_sync),
  .ibus_busy(i_ibus_busy),
  .q_address(i_q_address),
  .q_be(i_q_be),
  .q_cmd(i_q_cmd),
  .q_cmdval(i_q_cmdval),
  .q_eop(i_q_eop),
  .q_rspack(i_q_rspack),
  .q_wdata(i_q_wdata),
  .q_plen(i_q_plen),
  .q_buffer(i_q_buffer),
  .q_cache(i_q_cache),
  .q_mode(i_q_mode),
  .q_priv(i_q_priv),
  .q_cmdack(i_q_cmdack),
  .q_rdata(i_q_rdata),
  .q_reop(i_q_reop),
  .q_rspval(i_q_rspval),
  .hclk(hclk),
  .hresetn(hresetn),
  .hgrant(hgrant),
  .hready(hready),
  .hresp(hresp),
  .hrdata(hrdata),
  .hbusreq(hbusreq),
  .hlock(hlock),
  .htrans(htrans),
  .haddr(haddr),
  .hwrite(hwrite),
  .hsize(hsize),
  .hburst(hburst),
  .hprot(hprot),
  .hwdata(hwdata),
  .mem_access(i_mem_access),
  .memory_error(i_memory_error),
  .ext_bus_error(u_unconnected_0)
);


// Instantiation of module arc600
arc600 iarc600(
  .clk_ungated(i_clk_ungated),
  .ldst_dout(i_ldst_dout),
  .code_ram_rdata(i_code_ram_rdata),
  .rst_a(i_rst_a),
  .ctrl_cpu_start_sync_r(i_ctrl_cpu_start_sync_r),
  .l_irq_4(i_l_irq_4),
  .l_irq_5(i_l_irq_5),
  .l_irq_6(i_l_irq_6),
  .l_irq_7(i_l_irq_7),
  .l_irq_8(i_l_irq_8),
  .l_irq_9(i_l_irq_9),
  .l_irq_10(i_l_irq_10),
  .l_irq_11(i_l_irq_11),
  .l_irq_12(i_l_irq_12),
  .l_irq_13(i_l_irq_13),
  .l_irq_14(i_l_irq_14),
  .l_irq_15(i_l_irq_15),
  .l_irq_16(i_l_irq_16),
  .l_irq_17(i_l_irq_17),
  .l_irq_18(i_l_irq_18),
  .l_irq_19(i_l_irq_19),
  .test_mode(test_mode),
  .clk(i_clk),
  .clk_debug(i_clk_debug),
  .clk_dmp(i_clk_dmp),
  .ibus_busy(i_ibus_busy),
  .q_cmdack(i_q_cmdack),
  .q_rdata(i_q_rdata),
  .q_reop(i_q_reop),
  .q_rspval(i_q_rspval),
  .mem_access(i_mem_access),
  .memory_error(i_memory_error),
  .h_addr(i_h_addr),
  .h_dataw(i_h_dataw),
  .h_write(i_h_write),
  .h_read(i_h_read),
  .aux_access(i_aux_access),
  .core_access(i_core_access),
  .pcp_rd_rq(i_pcp_rd_rq),
  .pcp_wr_rq(i_pcp_wr_rq),
  .code_dmi_req(code_dmi_req),
  .code_dmi_addr(code_dmi_addr),
  .code_dmi_wdata(code_dmi_wdata),
  .code_dmi_wr(code_dmi_wr),
  .code_dmi_be(code_dmi_be),
  .arc_start_a(arc_start_a),
  .halt(i_halt),
  .xstep(i_xstep),
  .ldst_dmi_req(ldst_dmi_req),
  .pcp_addr(i_pcp_addr),
  .pcp_d_wr(i_pcp_d_wr),
  .ldst_dmi_addr(ldst_dmi_addr),
  .ldst_dmi_wdata(ldst_dmi_wdata),
  .ldst_dmi_wr(ldst_dmi_wr),
  .ldst_dmi_be(ldst_dmi_be),
  .ldst_addr(i_ldst_addr),
  .ldst_din(i_ldst_din),
  .ldst_mask(i_ldst_mask),
  .ldst_wren(i_ldst_wren),
  .ldst_ck_en(i_ldst_ck_en),
  .code_ram_addr(i_code_ram_addr),
  .code_ram_wdata(i_code_ram_wdata),
  .code_ram_wr(i_code_ram_wr),
  .code_ram_be(i_code_ram_be),
  .code_ram_ck_en(i_code_ram_ck_en),
  .en(i_en),
  .wd_clear(i_wd_clear),
  .ck_disable(i_ck_disable),
  .ck_dmp_gated(i_ck_dmp_gated),
  .en_debug_r(i_en_debug_r),
  .q_address(i_q_address),
  .q_be(i_q_be),
  .q_cmd(i_q_cmd),
  .q_cmdval(i_q_cmdval),
  .q_eop(i_q_eop),
  .q_rspack(i_q_rspack),
  .q_wdata(i_q_wdata),
  .q_plen(i_q_plen),
  .q_buffer(i_q_buffer),
  .q_cache(i_q_cache),
  .q_mode(i_q_mode),
  .q_priv(i_q_priv),
  .hold_host(i_hold_host),
  .code_dmi_rdata(code_dmi_rdata),
  .noaccess(i_noaccess),
  .reset_applied_r(i_reset_applied_r),
  .power_toggle(power_toggle),
  .pc_sel_r(i_pc_sel_r),
  .h_datar(i_h_datar),
  .pcp_d_rd(i_pcp_d_rd),
  .pcp_ack(i_pcp_ack),
  .pcp_dlat(i_pcp_dlat),
  .pcp_dak(i_pcp_dak),
  .ldst_dmi_rdata(ldst_dmi_rdata)
);


// Instantiation of module ibus_cksyn
ibus_cksyn iibus_cksyn(
  .clk_ungated(i_clk_ungated),
  .clk_system(i_clk_system),
  .rst_a(i_rst_a),
  .sync(i_sync)
);


// Instantiation of module jtag_port
jtag_port ijtag_port(
  .clk_ungated(i_clk_ungated),
  .jtag_tck(jtag_tck),
  .jtag_trst_a(i_jtag_trst_a),
  .rst_a(i_rst_a),
  .test_mode(test_mode),
  .en(i_en),
  .reset_applied_r(i_reset_applied_r),
  .h_datar(i_h_datar),
  .noaccess(i_noaccess),
  .hold_host(i_hold_host),
  .pcp_d_rd(i_pcp_d_rd),
  .pcp_ack(i_pcp_ack),
  .pcp_dlat(i_pcp_dlat),
  .pcp_dak(i_pcp_dak),
  .pc_sel_r(i_pc_sel_r),
  .jtag_tdi(jtag_tdi),
  .jtag_tms(jtag_tms),
  .jtag_bsr_tdo(jtag_bsr_tdo),
  .jtag_busy(u_unconnected_1),
  .h_addr(i_h_addr),
  .h_dataw(i_h_dataw),
  .h_write(i_h_write),
  .h_read(i_h_read),
  .aux_access(i_aux_access),
  .core_access(i_core_access),
  .madi_access(u_unconnected_2),
  .halt(i_halt),
  .xstep(i_xstep),
  .pcp_wr_rq(i_pcp_wr_rq),
  .pcp_rd_rq(i_pcp_rd_rq),
  .pcp_addr(i_pcp_addr),
  .pcp_brst(u_unconnected_3),
  .pcp_mask(u_unconnected_4),
  .pcp_d_wr(i_pcp_d_wr),
  .jtag_tdo(jtag_tdo),
  .jtag_tdo_zen_n(jtag_tdo_zen_n),
  .jtag_extest_mode(u_unconnected_5),
  .jtag_sample_mode(u_unconnected_6),
  .updatedr_en(u_unconnected_7),
  .capturedr_en(u_unconnected_8),
  .shiftdr_en(u_unconnected_9)
);


// Output drives
assign en                     = i_en;

endmodule


