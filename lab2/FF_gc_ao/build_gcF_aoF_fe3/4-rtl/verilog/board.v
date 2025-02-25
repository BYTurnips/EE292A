// *SYNOPSYS CONFIDENTIAL*
//
// This is an unpublished, proprietary work of Synopsys, Inc., and is fully 
// protected under copyright and trade secret laws.  You may not view, use, 
// disclose, copy, or distribute this file or any information contained herein 
// except pursuant to a valid written license from Synopsys.


// This file is generated automatically by 'veriloggen'.




// Includes found automatically in dependent files.
`include "board_pkg_defines.v"
`include "arc600constants.v"


module board(xen);


// Includes found automatically in dependent files.
`include "arcutil_pkg_defines.v"
`include "extutil.v"
`include "xdefs.v"
`include "che_util.v"
`include "arcutil.v"
`include "ext_msb.v"
`include "asmutil.v"
`include "uxdefs.v"
`include "arc600constants.v"
`include "clock_defs.v"
`include "jtag_defs.v"
`include "pdisp_pkg_defines.v"


output xen;

wire xen;


// Intermediate signals
wire i_xen;
wire i_test_mode;
wire i_xck_x1;
wire i_xck_system;
wire i_xxclr;
wire i_xctrl_cpu_start;
wire i_xxirq_n_4;
wire i_xxirq_n_5;
wire i_xxirq_n_6;
wire i_xxirq_n_7;
wire i_xxirq_n_8;
wire i_xxirq_n_9;
wire i_xxirq_n_10;
wire i_xxirq_n_11;
wire i_xxirq_n_12;
wire i_xxirq_n_13;
wire i_xxirq_n_14;
wire i_xxirq_n_15;
wire i_xxirq_n_16;
wire i_xxirq_n_17;
wire i_xxirq_n_18;
wire i_xxirq_n_19;
wire i_xhclk;
wire i_xhresetn;
wire i_xhgrant;
wire i_xhready;
wire  [1:0] i_xhresp;
wire  [31:0] i_xhrdata;
wire i_ejtag_tdi;
wire i_ejtag_tms;
wire i_ejtag_tck;
wire i_ejtag_trst_n;
wire i_xhbusreq;
wire  [1:0] i_xhtrans;
wire  [31:0] i_xhaddr;
wire i_xhwrite;
wire  [2:0] i_xhburst;
wire  [31:0] i_xhwdata;
wire  [2:0] i_xhsize;
wire i_xhlock;
wire  [3:0] i_xhprot;
wire i_ejtag_rtck;
wire i_ejtag_tdo;
wire i_del_xck_x1;
wire i_del_xck_system;
wire i_no_step_test;
wire i_do_pc_test;
wire  [EXT_A_MSB:2] i_xsram_a;
wire  [3:0] i_xsram_we_n;
wire i_xsram_oe_n;
wire  [31:0] i_xsram_d;
wire i_xsram_high_z;


// Dummy signals for 'unconnected' ports
// (doing this, rather than leaving them genuinely unconnected, stops
//  simulators emitting pointless warnings)
wire u_unconnected_0;
wire u_unconnected_1;
wire u_unconnected_2;
wire u_unconnected_3;


// Instantiation of module core_chip
core_chip icore_chip(
  .test_mode(i_test_mode),
  .xck_x1(i_xck_x1),
  .xck_system(i_xck_system),
  .xxclr(i_xxclr),
  .xctrl_cpu_start(i_xctrl_cpu_start),
  .xxirq_n_4(i_xxirq_n_4),
  .xxirq_n_5(i_xxirq_n_5),
  .xxirq_n_6(i_xxirq_n_6),
  .xxirq_n_7(i_xxirq_n_7),
  .xxirq_n_8(i_xxirq_n_8),
  .xxirq_n_9(i_xxirq_n_9),
  .xxirq_n_10(i_xxirq_n_10),
  .xxirq_n_11(i_xxirq_n_11),
  .xxirq_n_12(i_xxirq_n_12),
  .xxirq_n_13(i_xxirq_n_13),
  .xxirq_n_14(i_xxirq_n_14),
  .xxirq_n_15(i_xxirq_n_15),
  .xxirq_n_16(i_xxirq_n_16),
  .xxirq_n_17(i_xxirq_n_17),
  .xxirq_n_18(i_xxirq_n_18),
  .xxirq_n_19(i_xxirq_n_19),
  .xhclk(i_xhclk),
  .xhresetn(i_xhresetn),
  .xhgrant(i_xhgrant),
  .xhready(i_xhready),
  .xhresp(i_xhresp),
  .xhrdata(i_xhrdata),
  .ejtag_tdi(i_ejtag_tdi),
  .ejtag_tms(i_ejtag_tms),
  .ejtag_tck(i_ejtag_tck),
  .ejtag_trst_n(i_ejtag_trst_n),
  .xen(i_xen),
  .xhbusreq(i_xhbusreq),
  .xhtrans(i_xhtrans),
  .xhaddr(i_xhaddr),
  .xhwrite(i_xhwrite),
  .xhburst(i_xhburst),
  .xhwdata(i_xhwdata),
  .xhsize(i_xhsize),
  .xhlock(i_xhlock),
  .xhprot(i_xhprot),
  .ejtag_rtck(i_ejtag_rtck),
  .ejtag_tdo(i_ejtag_tdo)
);


// Instantiation of module glue
glue iglue(
  .xck_x1(i_xck_x1),
  .del_xck_x1(i_del_xck_x1),
  .xck_system(i_xck_system),
  .del_xck_system(i_del_xck_system),
  .xck_phi2(u_unconnected_0),
  .xxclr(i_xxclr),
  .xck_x4(u_unconnected_1),
  .ejtag_rtck(i_ejtag_rtck),
  .ejtag_trst_n(i_ejtag_trst_n),
  .xctrl_cpu_start(i_xctrl_cpu_start),
  .no_step_test(i_no_step_test),
  .do_pc_test(i_do_pc_test),
  .test_mode(i_test_mode)
);


// Instantiation of module clock_and_reset
clock_and_reset iclock_and_reset(
  .xck_x1(i_xck_x1),
  .xck_system(i_xck_system),
  .xhclk(i_xhclk),
  .xxclr(i_xxclr)
);


// Instantiation of module jtag_model
jtag_model ijtag_model(
  .ejtag_tck(i_ejtag_tck),
  .ejtag_tms(i_ejtag_tms),
  .ejtag_tdi(i_ejtag_tdi),
  .ejtag_tdo(i_ejtag_tdo),
  .ejtag_trst_n(i_ejtag_trst_n),
  .del_xck_x1(i_del_xck_x1),
  .xxclr(i_xxclr),
  .xxirq_n_4(i_xxirq_n_4),
  .xxirq_n_5(i_xxirq_n_5),
  .xxirq_n_6(i_xxirq_n_6),
  .xxirq_n_7(i_xxirq_n_7),
  .xxirq_n_8(i_xxirq_n_8),
  .xxirq_n_9(i_xxirq_n_9),
  .xxirq_n_10(i_xxirq_n_10),
  .xxirq_n_11(i_xxirq_n_11),
  .xxirq_n_12(i_xxirq_n_12),
  .xxirq_n_13(i_xxirq_n_13),
  .xxirq_n_14(i_xxirq_n_14),
  .xxirq_n_15(i_xxirq_n_15),
  .xxirq_n_16(i_xxirq_n_16),
  .xxirq_n_17(i_xxirq_n_17),
  .xxirq_n_18(i_xxirq_n_18),
  .xxirq_n_19(i_xxirq_n_19),
  .xen(i_xen),
  .xsram_a(i_xsram_a),
  .xsram_we_n(i_xsram_we_n),
  .xsram_oe_n(i_xsram_oe_n),
  .xsram_d(i_xsram_d),
  .xsram_wait_n(u_unconnected_2),
  .xsram_mrq_n(u_unconnected_3),
  .xsram_high_z(i_xsram_high_z),
  .no_step_test(i_no_step_test),
  .do_pc_test(i_do_pc_test)
);


// Instantiation of module ahb_slave_tb
ahb_slave_tb iahb_slave_tb(
  .xck_system(i_xck_system),
  .del_xck_system(i_del_xck_system),
  .xxclr(i_xxclr),
  .xhbusreq(i_xhbusreq),
  .xhtrans(i_xhtrans),
  .xhaddr(i_xhaddr),
  .xhwrite(i_xhwrite),
  .xhburst(i_xhburst),
  .xhwdata(i_xhwdata),
  .xhsize(i_xhsize),
  .xhlock(i_xhlock),
  .xhprot(i_xhprot),
  .xhclk(i_xhclk),
  .xhresetn(i_xhresetn),
  .xhgrant(i_xhgrant),
  .xhready(i_xhready),
  .xhresp(i_xhresp),
  .xhrdata(i_xhrdata),
  .xsram_a(i_xsram_a),
  .xsram_d(i_xsram_d),
  .xsram_we_n(i_xsram_we_n),
  .xsram_oe_n(i_xsram_oe_n)
);


// Instantiation of module sram_model
sram_model isram_model(
  .xxclr(i_xxclr),
  .xsram_a(i_xsram_a),
  .xsram_d(i_xsram_d),
  .xsram_we_n(i_xsram_we_n),
  .xsram_oe_n(i_xsram_oe_n),
  .xsram_high_z(i_xsram_high_z)
);


// Instantiation of module pdisp
//synopsys translate_off
pdisp ipdisp(
);
//synopsys translate_on


// Output drives
assign xen              = i_xen;

endmodule


