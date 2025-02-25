// *SYNOPSYS CONFIDENTIAL*
//
// This is an unpublished, proprietary work of Synopsys, Inc., and is fully 
// protected under copyright and trade secret laws.  You may not view, use, 
// disclose, copy, or distribute this file or any information contained herein 
// except pursuant to a valid written license from Synopsys.


// This file is generated automatically by 'veriloggen'.




module core_sys(rst_n_a,
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
                arc_start_a,
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
                power_toggle,
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
input  arc_start_a;
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
output power_toggle;
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
wire arc_start_a;
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
wire power_toggle;
wire jtag_tdo;
wire jtag_tdo_zen_n;


// Intermediate signals
wire i_en;
wire i_code_dmi_req;
wire  [31:0] i_code_dmi_addr;
wire  [31:0] i_code_dmi_wdata;
wire i_code_dmi_wr;
wire  [3:0] i_code_dmi_be;
wire i_ldst_dmi_req;
wire  [31:0] i_ldst_dmi_addr;
wire  [31:0] i_ldst_dmi_wdata;
wire i_ldst_dmi_wr;
wire  [3:0] i_ldst_dmi_be;
wire  [31:0] i_code_dmi_rdata;
wire  [31:0] i_ldst_dmi_rdata;


// Dummy signals for 'unconnected' ports
// (doing this, rather than leaving them genuinely unconnected, stops
//  simulators emitting pointless warnings)


// Instantiation of module cpu_isle
cpu_isle icpu_isle(
  .rst_n_a(rst_n_a),
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
  .jtag_tck(jtag_tck),
  .jtag_trst_n(jtag_trst_n),
  .test_mode(test_mode),
  .clk_in(clk_in),
  .clk_system_in(clk_system_in),
  .hclk(hclk),
  .hresetn(hresetn),
  .hgrant(hgrant),
  .hready(hready),
  .hresp(hresp),
  .hrdata(hrdata),
  .code_dmi_req(i_code_dmi_req),
  .code_dmi_addr(i_code_dmi_addr),
  .code_dmi_wdata(i_code_dmi_wdata),
  .code_dmi_wr(i_code_dmi_wr),
  .code_dmi_be(i_code_dmi_be),
  .arc_start_a(arc_start_a),
  .ldst_dmi_req(i_ldst_dmi_req),
  .ldst_dmi_addr(i_ldst_dmi_addr),
  .ldst_dmi_wdata(i_ldst_dmi_wdata),
  .ldst_dmi_wr(i_ldst_dmi_wr),
  .ldst_dmi_be(i_ldst_dmi_be),
  .jtag_tdi(jtag_tdi),
  .jtag_tms(jtag_tms),
  .jtag_bsr_tdo(jtag_bsr_tdo),
  .en(i_en),
  .hbusreq(hbusreq),
  .hlock(hlock),
  .htrans(htrans),
  .haddr(haddr),
  .hwrite(hwrite),
  .hsize(hsize),
  .hburst(hburst),
  .hprot(hprot),
  .hwdata(hwdata),
  .code_dmi_rdata(i_code_dmi_rdata),
  .power_toggle(power_toggle),
  .ldst_dmi_rdata(i_ldst_dmi_rdata),
  .jtag_tdo(jtag_tdo),
  .jtag_tdo_zen_n(jtag_tdo_zen_n)
);


// Instantiation of module ram_loader
ram_loader iram_loader(
  .clk_in(clk_in),
  .rst_n_a(rst_n_a),
  .code_dmi_rdata(i_code_dmi_rdata),
  .code_dmi_req(i_code_dmi_req),
  .code_dmi_addr(i_code_dmi_addr),
  .code_dmi_wdata(i_code_dmi_wdata),
  .code_dmi_wr(i_code_dmi_wr),
  .code_dmi_be(i_code_dmi_be),
  .ldst_dmi_rdata(i_ldst_dmi_rdata),
  .ldst_dmi_req(i_ldst_dmi_req),
  .ldst_dmi_addr(i_ldst_dmi_addr),
  .ldst_dmi_wdata(i_ldst_dmi_wdata),
  .ldst_dmi_wr(i_ldst_dmi_wr),
  .ldst_dmi_be(i_ldst_dmi_be),
  .en(i_en)
);


// Output drives
assign en              = i_en;

endmodule


