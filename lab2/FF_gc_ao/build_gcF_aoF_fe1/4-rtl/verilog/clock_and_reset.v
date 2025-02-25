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
// This is the System clock, CPU clock and reset generation for the ARC600.
// 
//
`include "board_pkg_defines.v"
`include "arc600constants.v"

module clock_and_reset (
   // Clock/Reset outputs for simulation
   //
   xck_x1,
   xck_system,
   xhclk,
   xxclr);

// `include "extutil.v"
`include "clock_defs.v"

output  xck_x1; 
output  xck_system;
output  xhclk;
output  xxclr; 

 
//  Clock/Reset outputs for simulation
// 
wire    xck_x1; 
wire    xck_system;
wire    xhclk;
wire    xxclr; 

reg     i_ck; 
reg     i_ck_system;
reg     i_clr; 


//  Generate a continuous clock with the period defined by the
//  constant clock_period in extutil.v.
//

initial 
   begin
   i_ck = 1'b 1;        
   end

initial
   begin
   i_ck_system = 1'b1;
   end

// Generate a continuous clock with the period defined by the
// constant clock_period in extutil.v.
//
always 
         #(clock_period / 2.00) i_ck = ~i_ck; 


always
    #(sys_clock_period / 2.00 ) i_ck_system = ~i_ck_system; // ck_system/ck 1:1 ratio

//  Generate  2us reset pulse on startup
// 
initial 
   begin : global_reset
   integer N;
   i_clr <= 1'b 0;        
   #( 2000 + clock_period - 2.00 ); 
   i_clr <= 1'b 1;        
   end

// =============================== Output Drives ============================--
//
assign xck_x1       = i_ck;
assign xck_system   = i_ck_system;
assign xhclk        = i_ck_system;
assign xxclr        = i_clr;

endmodule // module clock_and_reset

