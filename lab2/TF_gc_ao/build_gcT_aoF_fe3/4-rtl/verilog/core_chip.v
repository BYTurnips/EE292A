// *SYNOPSYS CONFIDENTIAL*
//
// This is an unpublished, proprietary work of Synopsys, Inc., and is fully 
// protected under copyright and trade secret laws.  You may not view, use, 
// disclose, copy, or distribute this file or any information contained herein 
// except pursuant to a valid written license from Synopsys.


// This file is generated automatically by 'veriloggen'.




// Includes found automatically in dependent files.
`include "arc600constants.v"


module core_chip(test_mode,
                 xck_x1,
                 xck_system,
                 xxclr,
                 xctrl_cpu_start,
                 xxirq_n_4,
                 xxirq_n_5,
                 xxirq_n_6,
                 xxirq_n_7,
                 xxirq_n_8,
                 xxirq_n_9,
                 xxirq_n_10,
                 xxirq_n_11,
                 xxirq_n_12,
                 xxirq_n_13,
                 xxirq_n_14,
                 xxirq_n_15,
                 xxirq_n_16,
                 xxirq_n_17,
                 xxirq_n_18,
                 xxirq_n_19,
                 xhclk,
                 xhresetn,
                 xhgrant,
                 xhready,
                 xhresp,
                 xhrdata,
                 ejtag_tdi,
                 ejtag_tms,
                 ejtag_tck,
                 ejtag_trst_n,
                 xen,
                 xhbusreq,
                 xhtrans,
                 xhaddr,
                 xhwrite,
                 xhburst,
                 xhwdata,
                 xhsize,
                 xhlock,
                 xhprot,
                 ejtag_rtck,
                 ejtag_tdo);


// Includes found automatically in dependent files.
`include "arcutil_pkg_defines.v"
`include "extutil.v"
`include "xdefs.v"
`include "che_util.v"
`include "arcutil.v"
`include "ext_msb.v"
`include "asmutil.v"
`include "uxdefs.v"


input  test_mode;
input  xck_x1;
input  xck_system;
input  xxclr;
input  xctrl_cpu_start;
input  xxirq_n_4;
input  xxirq_n_5;
input  xxirq_n_6;
input  xxirq_n_7;
input  xxirq_n_8;
input  xxirq_n_9;
input  xxirq_n_10;
input  xxirq_n_11;
input  xxirq_n_12;
input  xxirq_n_13;
input  xxirq_n_14;
input  xxirq_n_15;
input  xxirq_n_16;
input  xxirq_n_17;
input  xxirq_n_18;
input  xxirq_n_19;
input  xhclk;
input  xhresetn;
input  xhgrant;
input  xhready;
input  [1:0]  xhresp;
input  [31:0]  xhrdata;
input  ejtag_tdi;
input  ejtag_tms;
input  ejtag_tck;
input  ejtag_trst_n;
output xen;
output xhbusreq;
output [1:0]  xhtrans;
output [31:0]  xhaddr;
output xhwrite;
output [2:0]  xhburst;
output [31:0]  xhwdata;
output [2:0]  xhsize;
output xhlock;
output [3:0]  xhprot;
output ejtag_rtck;
output ejtag_tdo;

wire test_mode;
wire xck_x1;
wire xck_system;
wire xxclr;
wire xctrl_cpu_start;
wire xxirq_n_4;
wire xxirq_n_5;
wire xxirq_n_6;
wire xxirq_n_7;
wire xxirq_n_8;
wire xxirq_n_9;
wire xxirq_n_10;
wire xxirq_n_11;
wire xxirq_n_12;
wire xxirq_n_13;
wire xxirq_n_14;
wire xxirq_n_15;
wire xxirq_n_16;
wire xxirq_n_17;
wire xxirq_n_18;
wire xxirq_n_19;
wire xhclk;
wire xhresetn;
wire xhgrant;
wire xhready;
wire  [1:0] xhresp;
wire  [31:0] xhrdata;
wire ejtag_tdi;
wire ejtag_tms;
wire ejtag_tck;
wire ejtag_trst_n;
wire xen;
wire xhbusreq;
wire  [1:0] xhtrans;
wire  [31:0] xhaddr;
wire xhwrite;
wire  [2:0] xhburst;
wire  [31:0] xhwdata;
wire  [2:0] xhsize;
wire xhlock;
wire  [3:0] xhprot;
wire ejtag_rtck;
wire ejtag_tdo;


// Intermediate signals
wire i_rst_n_a;
wire i_ctrl_cpu_start;
wire i_xirq_n_4;
wire i_xirq_n_5;
wire i_xirq_n_6;
wire i_xirq_n_7;
wire i_xirq_n_8;
wire i_xirq_n_9;
wire i_xirq_n_10;
wire i_xirq_n_11;
wire i_xirq_n_12;
wire i_xirq_n_13;
wire i_xirq_n_14;
wire i_xirq_n_15;
wire i_xirq_n_16;
wire i_xirq_n_17;
wire i_xirq_n_18;
wire i_xirq_n_19;
wire i_jtag_tck;
wire i_jtag_trst_n;
wire i_clk_in;
wire i_clk_system_in;
wire i_hclk;
wire i_hresetn;
wire i_hgrant;
wire i_hready;
wire  [1:0] i_hresp;
wire  [31:0] i_hrdata;
wire i_arc_start_a;
wire i_jtag_tdi;
wire i_jtag_tms;
wire i_jtag_bsr_tdo;
wire i_en;
wire i_hbusreq;
wire i_hlock;
wire  [1:0] i_htrans;
wire  [31:0] i_haddr;
wire i_hwrite;
wire  [2:0] i_hsize;
wire  [2:0] i_hburst;
wire  [3:0] i_hprot;
wire  [31:0] i_hwdata;
wire i_power_toggle;
wire i_jtag_tdo;
wire i_jtag_tdo_zen_n;


// Dummy signals for 'unconnected' ports
// (doing this, rather than leaving them genuinely unconnected, stops
//  simulators emitting pointless warnings)
wire u_unconnected_0;


// Instantiation of module core_sys
core_sys icore_sys(
  .rst_n_a(i_rst_n_a),
  .ctrl_cpu_start(i_ctrl_cpu_start),
  .xirq_n_4(i_xirq_n_4),
  .xirq_n_5(i_xirq_n_5),
  .xirq_n_6(i_xirq_n_6),
  .xirq_n_7(i_xirq_n_7),
  .xirq_n_8(i_xirq_n_8),
  .xirq_n_9(i_xirq_n_9),
  .xirq_n_10(i_xirq_n_10),
  .xirq_n_11(i_xirq_n_11),
  .xirq_n_12(i_xirq_n_12),
  .xirq_n_13(i_xirq_n_13),
  .xirq_n_14(i_xirq_n_14),
  .xirq_n_15(i_xirq_n_15),
  .xirq_n_16(i_xirq_n_16),
  .xirq_n_17(i_xirq_n_17),
  .xirq_n_18(i_xirq_n_18),
  .xirq_n_19(i_xirq_n_19),
  .jtag_tck(i_jtag_tck),
  .jtag_trst_n(i_jtag_trst_n),
  .test_mode(test_mode),
  .clk_in(i_clk_in),
  .clk_system_in(i_clk_system_in),
  .hclk(i_hclk),
  .hresetn(i_hresetn),
  .hgrant(i_hgrant),
  .hready(i_hready),
  .hresp(i_hresp),
  .hrdata(i_hrdata),
  .arc_start_a(i_arc_start_a),
  .jtag_tdi(i_jtag_tdi),
  .jtag_tms(i_jtag_tms),
  .jtag_bsr_tdo(i_jtag_bsr_tdo),
  .en(i_en),
  .hbusreq(i_hbusreq),
  .hlock(i_hlock),
  .htrans(i_htrans),
  .haddr(i_haddr),
  .hwrite(i_hwrite),
  .hsize(i_hsize),
  .hburst(i_hburst),
  .hprot(i_hprot),
  .hwdata(i_hwdata),
  .power_toggle(i_power_toggle),
  .jtag_tdo(i_jtag_tdo),
  .jtag_tdo_zen_n(i_jtag_tdo_zen_n)
);


// Instantiation of module io_pad_ring
io_pad_ring iio_pad_ring(
  .en(i_en),
  .xck_x1(xck_x1),
  .xck_system(xck_system),
  .xxclr(xxclr),
  .xctrl_cpu_start(xctrl_cpu_start),
  .xirq_n_4(i_xirq_n_4),
  .xirq_n_5(i_xirq_n_5),
  .xirq_n_6(i_xirq_n_6),
  .xirq_n_7(i_xirq_n_7),
  .xirq_n_8(i_xirq_n_8),
  .xirq_n_9(i_xirq_n_9),
  .xirq_n_10(i_xirq_n_10),
  .xirq_n_11(i_xirq_n_11),
  .xirq_n_12(i_xirq_n_12),
  .xirq_n_13(i_xirq_n_13),
  .xirq_n_14(i_xirq_n_14),
  .xirq_n_15(i_xirq_n_15),
  .xirq_n_16(i_xirq_n_16),
  .xirq_n_17(i_xirq_n_17),
  .xirq_n_18(i_xirq_n_18),
  .xirq_n_19(i_xirq_n_19),
  .xxirq_n_4(xxirq_n_4),
  .xxirq_n_5(xxirq_n_5),
  .xxirq_n_6(xxirq_n_6),
  .xxirq_n_7(xxirq_n_7),
  .xxirq_n_8(xxirq_n_8),
  .xxirq_n_9(xxirq_n_9),
  .xxirq_n_10(xxirq_n_10),
  .xxirq_n_11(xxirq_n_11),
  .xxirq_n_12(xxirq_n_12),
  .xxirq_n_13(xxirq_n_13),
  .xxirq_n_14(xxirq_n_14),
  .xxirq_n_15(xxirq_n_15),
  .xxirq_n_16(xxirq_n_16),
  .xxirq_n_17(xxirq_n_17),
  .xxirq_n_18(xxirq_n_18),
  .xxirq_n_19(xxirq_n_19),
  .xhbusreq(xhbusreq),
  .xhtrans(xhtrans),
  .xhaddr(xhaddr),
  .xhwrite(xhwrite),
  .xhburst(xhburst),
  .xhwdata(xhwdata),
  .xhsize(xhsize),
  .xhlock(xhlock),
  .xhprot(xhprot),
  .xhclk(xhclk),
  .xhresetn(xhresetn),
  .xhgrant(xhgrant),
  .xhready(xhready),
  .xhresp(xhresp),
  .xhrdata(xhrdata),
  .hbusreq(i_hbusreq),
  .htrans(i_htrans),
  .haddr(i_haddr),
  .hwrite(i_hwrite),
  .hburst(i_hburst),
  .hwdata(i_hwdata),
  .hsize(i_hsize),
  .hlock(i_hlock),
  .hprot(i_hprot),
  .hclk(i_hclk),
  .hresetn(i_hresetn),
  .hgrant(i_hgrant),
  .hready(i_hready),
  .hresp(i_hresp),
  .hrdata(i_hrdata),
  .ejtag_tdi(ejtag_tdi),
  .ejtag_tms(ejtag_tms),
  .ejtag_tck(ejtag_tck),
  .ejtag_rtck(ejtag_rtck),
  .ejtag_trst_n(ejtag_trst_n),
  .jtag_tdo(i_jtag_tdo),
  .jtag_tdo_zen_n(i_jtag_tdo_zen_n),
  .power_toggle(i_power_toggle),
  .ejtag_tdo(ejtag_tdo),
  .jtag_bsr_tdo(i_jtag_bsr_tdo),
  .jtag_tdi(i_jtag_tdi),
  .jtag_tms(i_jtag_tms),
  .jtag_tck(i_jtag_tck),
  .jtag_trst_n(i_jtag_trst_n),
  .ctrl_cpu_start(i_ctrl_cpu_start),
  .arc_start_a(i_arc_start_a),
  .clk_in(i_clk_in),
  .clk_system_in(i_clk_system_in),
  .clk_sys(u_unconnected_0),
  .rst_n_a(i_rst_n_a),
  .xen(xen)
);


// Output drives

endmodule


