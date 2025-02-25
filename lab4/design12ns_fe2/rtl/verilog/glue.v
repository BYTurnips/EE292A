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
// Test chip simulation component.
// 
//

`include "board_pkg_defines.v"

module glue (
   // Clock/Reset outputs for simulation
   //
   xck_x1,
   del_xck_x1,
   xck_system,
   del_xck_system,
   xck_phi2,
   xxclr,
   xck_x4,

   // Additional Signals
   //
   ejtag_rtck,
   ejtag_trst_n,


   // external start pin
   //
   xctrl_cpu_start,

   // Signal for forcing the Single Step test.
   //
   no_step_test,

   // Signal for forcing the PC test.
   //
   do_pc_test,

   // Production test mode signal
   //
   test_mode);

`include "arc600constants.v"
// `include "arcutil.v"
// `include "extutil.v"
`include "clock_defs.v"

input   xck_x1; 
input   xck_system;
input   xxclr; 

output  del_xck_x1;
output  del_xck_system;
output  xck_phi2; 
output  xck_x4; 
output   xctrl_cpu_start;

//  Additional Signals
// 
input   ejtag_rtck; // So re-timed TCK gets pulled out
output  ejtag_trst_n;
wire    ejtag_trst_n;

//  Signal for forcing the Single Step test.
// 
output  no_step_test;
 
//  Signal for forcing the PC test.
// 
output  do_pc_test;
 
//  Production test mode signal
// 
output  test_mode;
 
//  Clock/Reset outputs for simulation
// 
wire    del_xck_x1;
wire    del_xck_system;
wire    xck_phi2; 
wire    xck_x4; 
wire   xctrl_cpu_start;

//  Signal for forcing the Single Step test.
//
wire    no_step_test; 

//  Signal for forcing the PC test.
// 
wire    do_pc_test;
 
//  Production test mode signal
// 
wire    test_mode; 

wire    i_clk; 
wire    i_clk_system;
wire    i_rst_a; 

reg     i_clkx4; 
reg     i_clk_phi2; 




assign i_clk = xck_x1; 
assign i_clk_system = xck_system;
assign i_rst_a = xxclr;


//  Generate a continuous clock with the period defined by the
//  constant clock_period in extutil.v.
//
initial 
   begin
   i_clk_phi2 = 1'b 1;        
   end

initial 
   begin
   i_clkx4 = 1'b 0;        
   end

/*
// This computation is extracted from extutil.v & the IP integration
// code, as the extutil.v is not appropriate here because it contains 
// lots of things particular to the configuration of the 600.

`define clock_period %-printf("%1.2f", [1000/clockSpeed])-%

// Average clock insertion delay. This is always 0, except for
// backannotated gate-level simulations where a real clock tree
// is present. In this case this parameter has to be manually
// changed to reflet the average clock insertion delay for
// the ARC core. This is used to adjust the clock into testbench
// modules where no clock tree is present.
// Note: it seems that this needs to be changed only for AHB builds.
//
parameter avg_ck_insertion_delay = 0;
*/

// IN_TEST_MODE, according to the IP configuration, is always 0,
// and is not used.
parameter IN_TEST_MODE = 0;

`ifdef TTVTOC
`else
//  This drives the latch implementation of the
//  synthesised register file.
// 
//  phase 2 clock lags main clock by 90 degrees.
// 
always @ (i_clk)
         #(clock_period / 4.00) i_clk_phi2 = i_clk; 

//  4 times the frequency of Main clock
// 
always
         #(clock_period / 8.00) i_clkx4 = ~i_clkx4; 
`endif

// =============================== Output Drives ============================--
//
assign no_step_test = 1'b 1;        //  Single Step Test disabled
assign do_pc_test   = 1'b 0;        //  PC Test disabled
assign test_mode    = IN_TEST_MODE; //  Production Test Mode
assign   xctrl_cpu_start = 1'b0;      //  External start (starts core from halt) 

`ifdef TTVTOC
assign del_xck_x1     = i_clk;
assign del_xck_system = i_clk_system;
`else
assign #avg_ck_insertion_delay del_xck_x1 = i_clk;
assign #avg_ck_insertion_delay del_xck_system = i_clk_system;
assign xck_phi2     = i_clk_phi2; 
assign xck_x4       = i_clkx4; 
`endif

assign ejtag_trst_n = i_rst_a;

endmodule // module glue
