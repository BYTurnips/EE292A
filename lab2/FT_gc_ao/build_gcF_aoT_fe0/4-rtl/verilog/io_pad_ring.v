// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 1995-2012 ARC International (Unpublished)
// All Rights Reserved.
//
// This document, material and/or software contains confidential
// and proprietary information of ARC International and is
// protected by copyright, trade secret and other state, federal,
// and international laws, and may be embodied in patents issued
// or pending.  Its receipt or possession does not convey any
// rights to use, reproduce, disclose its contents, or to
// manufacture, or sell anything it may describe.  Reverse
// engineering is prohibited, and reproduction, disclosure or use
// without specific written authorization of ARC International is
// strictly forbidden.  ARC and the ARC logotype are trademarks of
// ARC International.
// 
// ARC Product:  ARC 600 Architecture v4.9.7
// File version:  600 Architecture IP Library version 4.9.7, file revision 
// ARC Chip ID:  0
//
// Description:
//
// ARCAngel pads placeholder.
// 
`include "arc600constants.v"


module io_pad_ring (
   en,
   xck_x1,
   xck_system,
   xxclr,
   
   xctrl_cpu_start,


// Signals required for interrupts
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

   //AHB interface to/from the testbench
   xhbusreq,
   xhtrans,
   xhaddr,
   xhwrite,
   xhburst,
   xhwdata,
   xhsize,
   xhlock,
   xhprot,
   xhclk,
   xhresetn,
   xhgrant,
   xhready,
   xhresp,
   xhrdata,
   //AHB interface to/from the bridge
   hbusreq,
   htrans,
   haddr,
   hwrite,
   hburst,
   hwdata,
   hsize,
   hlock,
   hprot,
   hclk,
   hresetn,
   hgrant,
   hready,
   hresp,
   hrdata,
   ejtag_tdi,
   ejtag_tms,
   ejtag_tck,
   ejtag_rtck,
   ejtag_trst_n,
   jtag_tdo,
   jtag_tdo_zen_n,
   power_toggle,

   ejtag_tdo,
   jtag_bsr_tdo,
   jtag_tdi,
   jtag_tms,
   jtag_tck,
   jtag_trst_n,
   ctrl_cpu_start,
   arc_start_a,
   clk_in,
   clk_system_in,
   clk_sys,
   rst_n_a,
   xen);

// `include "extutil.v"	// Core-specific: can't include.
`include "asmutil.v"                  
// `include "xdefs.v" 	// Core-specific: can't include.

input   xck_x1; 
input   xck_system;
input   xxclr;
input   en;
input   xctrl_cpu_start;

output xirq_n_4;
output xirq_n_5;
output xirq_n_6;
output xirq_n_7;
output xirq_n_8;
output xirq_n_9;
output xirq_n_10;
output xirq_n_11;
output xirq_n_12;
output xirq_n_13;
output xirq_n_14;
output xirq_n_15;
output xirq_n_16;
output xirq_n_17;
output xirq_n_18;
output xirq_n_19;
input xxirq_n_4;
input xxirq_n_5;
input xxirq_n_6;
input xxirq_n_7;
input xxirq_n_8;
input xxirq_n_9;
input xxirq_n_10;
input xxirq_n_11;
input xxirq_n_12;
input xxirq_n_13;
input xxirq_n_14;
input xxirq_n_15;
input xxirq_n_16;
input xxirq_n_17;
input xxirq_n_18;
input xxirq_n_19;

input hbusreq; 
input [1:0] htrans; 
input [31:0] haddr; 
input hwrite; 
input [2:0] hburst; 
input [31:0] hwdata; 
input [2:0] hsize; 
input hlock; 
input [3:0] hprot; 
input xhclk; 
input xhresetn; 
input xhgrant; 
input xhready; 
input [1:0] xhresp; 
input [31:0] xhrdata;

output xhbusreq; 
output [1:0] xhtrans; 
output [31:0] xhaddr; 
output xhwrite; 
output [2:0] xhburst; 
output [31:0] xhwdata; 
output [2:0] xhsize; 
output xhlock; 
output [3:0] xhprot; 
output hclk; 
output hresetn; 
output hgrant; 
output hready; 
output [1:0] hresp; 
output [31:0] hrdata;
input   ejtag_tdi; 
input   ejtag_tms; 
input   ejtag_tck;
input   ejtag_trst_n;
// JTAG Comms Port Interface   
input   jtag_tdo;
input    jtag_tdo_zen_n;
// Signal for activiating monitoring of switching active for power meteric. 
// The power_toggle signal needs to set as input due synthesis 
// optimisation of the power register in xaux_reg.
input  power_toggle;

output   ejtag_tdo; 
// Boundary scan Register output signal to JTAG port.
// This can be used when boundary scan has been
// implemented.
output  jtag_bsr_tdo; 
output  jtag_tdi; 
output  jtag_tms; 
output  jtag_tck;
output  ejtag_rtck;
output  jtag_trst_n; 
   output ctrl_cpu_start;
   output arc_start_a;
output  clk_in; 
output  clk_system_in;
output  clk_sys;
output  rst_n_a; 
output  xen; 

// wire    ejtag_tdo; 
wire    jtag_bsr_tdo; 
wire    jtag_tdi; 
wire    jtag_tms; 
wire    jtag_tck; 
wire    ejtag_rtck;
wire    jtag_trst_n; 
wire    arc_start_a;
wire    clk_in; 
wire    clk_system_in;
wire    rst_n_a; 
wire    xen; 


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



wire clk_in_early;
wire i_clk_in;
wire i_rst_n_a; 
   

// synopsys translate_off
// synopsys translate_on


//  Input pads --

//  Main JTAG signals that are driven from the JTAG comms port.
// 
assign jtag_tdi     = ejtag_tdi; 
assign jtag_tms     = ejtag_tms; 
assign jtag_tck     = ejtag_tck; 
assign jtag_trst_n  = ejtag_trst_n; 


//  only insert the ones that have not been connected to peripherals

 assign xirq_n_4 = xxirq_n_4;
 assign xirq_n_5 = xxirq_n_5;
 assign xirq_n_6 = xxirq_n_6;
 assign xirq_n_7 = xxirq_n_7;
 assign xirq_n_8 = xxirq_n_8;
 assign xirq_n_9 = xxirq_n_9;
 assign xirq_n_10 = xxirq_n_10;
 assign xirq_n_11 = xxirq_n_11;
 assign xirq_n_12 = xxirq_n_12;
 assign xirq_n_13 = xxirq_n_13;
 assign xirq_n_14 = xxirq_n_14;
 assign xirq_n_15 = xxirq_n_15;
 assign xirq_n_16 = xxirq_n_16;
 assign xirq_n_17 = xxirq_n_17;
 assign xirq_n_18 = xxirq_n_18;
 assign xirq_n_19 = xxirq_n_19;




//  Output pads --

assign xen           = 
    en |
    0;
assign clk_system_in = xck_system;
assign clk_sys       = xck_system;

//  JTAG signal to Boundary scan register
// 
assign jtag_bsr_tdo = 1'b 0; 
assign ejtag_rtck   = ejtag_tck;  // Re-timed TCK

//  Tri-state pads --

//  The JTAG output signal that is transmitted to the JTAG 
//  host model.
// 
assign ejtag_tdo = jtag_tdo_zen_n == 1'b 1 ? jtag_tdo : 1'b Z; 




//  Bidirectional pads --


//  Clock --
// ck_x1_buffer : global port map(xck_x1, clk);

// The clk_in_early signal is an early version of the clock.
// It is a pre-global clk buffer cell.
//
assign clk_in_early = xck_system; 

assign i_clk_in    = xck_x1; 
assign clk_in      = i_clk_in;

assign xhbusreq = hbusreq;
assign xhtrans  = htrans;
assign xhaddr   = haddr;
assign xhwrite  = hwrite;
assign xhburst  = hburst;
assign xhwdata  = hwdata;
assign xhsize   = hsize;
assign xhlock   = hlock;
assign xhprot   = hprot;

assign hclk     = xhclk;
assign hresetn  = xhresetn;
assign hgrant   = xhgrant;
assign hready   = xhready;
assign hresp    = xhresp;
assign hrdata   = xhrdata;

//  Clear --

assign rst_n_a    = i_rst_n_a; 
assign i_rst_n_a  = xxclr; 


// The xctrl_cpu_start pin starts the core running from the 
// halted state when driven high for more than a clock cycle.
//
assign ctrl_cpu_start = 
       xctrl_cpu_start;

// The purpose of the arc_start_a signal defines whether the ARC
// starts running on reset, or goes into a halted state. When it is
// set to '1' the ARC will start running code from the reset vector 
// onwards after a reset. It should be fixed at 1' for start-on-reset
// or at '0' for halt-on-reset.
//
// Note if arc_start_a = '0' you will have to set the status register
// to the appropriate start address and clear the halt bit through the
// host interface before running the simulation.
// 
assign arc_start_a = 
		// Here we have to add cpu-specific PMU signal at the right place, so 
	// the PMU module can't just insert it!
       0;


endmodule // module io_pad_ring

