// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 1996-2012 ARC International (Unpublished)
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
// Clock generation module
// 
// All clock gating in the ARC600 is done in this module. If the
// clock gating has not been selected this module is empty.
//  
//======================= Inputs to this block =======================--
//
//  clk_in             U Core input clock
//
//  clk_system_in      U System input clock
// 
//  test_mode          U Production test mode signal, which is only enabled
//                     during ATPG generation and production test in the
//                     factory. It is always disabled during operation.
// 
//  en_debug_r         L This flag is the Enable Debug flag (ED), bit 24 in the
//                     DEBUG register. It enables the debug extensions when it
//                     is set. When it is cleared the debug extensions are
//                     switched off by gating the debug clock, but only if the
//                     option clock gating has been selected.
// 
//====================== Output from this block ======================--
//
//  clk                U The main clock of ARC. It is connected to all modules
//                     except those connected that clk_debug and clk_system are
//                     connected to.
// 
//  clk_debug          U The debug clock is only connected to the debug
//                     extensions.
// 
//  clk_ungated        U The internal core clock which is always the same as
//                     clk_in. It is never gated even if clock gating has been
//                     selected. It is connected to the modules that control the ARC
//                     interfaces, the timer(s) the interrupt unit, the clock control
//                     module, the CCM(s) and their respective logic (CCMs must be able
//                     to respond in a single cycle to DMI requests, even when
//                     the clock gating is active), and in general to all the
//                     modules that have to stay "awake", even when the clock is
//                     "sleeping".
//
//  clk_system         U The External System Clock, that can be set to 1:1,
//                     2:1, 3:1, 4:1 ratios to the main clock clk
//                     (see glue module). By default it is set to 2:1
//                     This clock goes to the ibus_cksyn_sys block, and,
//                     depending on the connection scheme, might go to some
//                     peripherals.
//
//====================================================================--
//
module ck_gen (
   clk_in,
   clk_system_in,
//   test_mode,

// Clock controls

   ck_disable,
   ck_dmp_gated,
   en_debug_r,

// Generated clocks

   clk,
   clk_debug,
   clk_dmp,
   clk_ungated,
   clk_system);

`include "arcutil_pkg_defines.v" 
`include "extutil.v" 

   input   clk_in; 
   input   clk_system_in;
//   input   test_mode; 
   input   ck_disable; 
   input   ck_dmp_gated;

   input   en_debug_r; 

   output  clk; 
   output  clk_debug; 
   output  clk_dmp;
   output  clk_ungated;
   output  clk_system; 

   wire    clk; 
   wire    clk_debug; 
   wire    clk_system; 

   wire    i_ck_enable_a; 
   wire    i_debug_enable_a; 
// leda NTL_CLK07 off
   wire    i_ck_dft_a;
   wire    i_ck_dmp_dft_a;
// leda NTL_CLK07 on
   wire    ck_enable;
   wire     i_ck_dmp_enable_a ;
 
  
// -------------------------------------------------------------------------
//  The clock gating option
// 
//  **NOTE : All gates in this module must be instantiated in replacement RTL before going to synthesis and layout.
//  The replacement wrapper is generated via the SEIF iplib component in conjunction with ASIC iplib since the integrated clock
// gating cell that is to be targeted is technology/library specific

//   Therefore, regard the HDL in this module as a behavioural model that can be used for simulation purposes.
//  The behaviour of the clock gating is such as to gate off in low state and must use a deglitching of the enable (see ARS2104847)
//   If this behavioural RTL would be directly synthesised, it will result in a discrete latch + AND gate
// Preference is to use SEIF flow to replace this code with equivalent where technology specific clock gate is instantiated. 

//  All clocks, with the exception of the system and ungated clock may be gated.
//  This is an option controlled by the constant CK_GATING in the file extutil.v.
// 
//  If clock gating is selected the clocks are low when disabled.  This is the convention for pos-edge triggered systems and is the only one supportable
//  across all Synopsys libraries
//   
//  If clock gating is not selected the clock tree is totally free of
//  gates. 
// 

// -------------------------------------------------------------------------
// 
//  Ungated clock
// 
   //  The ungated clock is never disabled even if clock gating has been
   //  selected, because it clocks the interfaces of the ARC which need to
   //  react immediately to incoming events. The following modules are
   //  connected to the ungated clock:
   // 
   //     Module          Possible events
   //     ------          ---------------
   //     1.io_flops      Latches IRQ and clear signals
   //     2.int_unit      Services interrupt requests
   //     3.host port     Services host accesses
   //     4.timer(s)      Generates interrupt requests after delay
   //     5.ck_ctrl       Generates ck_disable
   //     6.pdisp         Pipeline Display
   //     7.CCMs          DMI access
   //     8.Clock sync    Synch with system clock
   // 

   assign clk_system  = clk_system_in; 
   assign clk_ungated = clk_in;
   assign  ck_enable  = ~ck_disable; 

// -------------------------------------------------------------------------
// 
//  Main clock
// 
   //  Provided that clock gating has been selected the clock is gated if
   // 
   //    1. The ARC is halted or sleeping
   //    2. There are no loads pending
   //    3. The main memory is not being accessed
   //    4. The host is not accessing the ARC
   //    5. There are no interrupt requests
   //    6. The ARC is not in production test mode
   // 
   //  The signal ck_disable is generated in the clock control module (ck_ctrl).
   //  It is high when cases 1-5 are all true. Case 6 is controlled by the
   //  SCANENABLE signal but this signal only exists after netlist has been generated.
   // 
   assign i_ck_enable_a = ck_enable; 
   
   reg i_ck_enable_a_latched;

   always @*
   begin
     if (!clk_in)
     begin
       i_ck_enable_a_latched <= i_ck_enable_a;
     end

   end


   assign i_ck_dft_a = (clk_in & i_ck_enable_a_latched);
   

   assign clk = i_ck_dft_a;

//--------------------------------------------------------------------------
//
// DMP Clock
//
   // Provided that clock gating has been selected the clock is gated if:
   //
   //   1. The conditions for gating the main clock are true, OR
   //   2. The DMP is idle (even though the main clock is still running).
   //
   
   assign  i_ck_dmp_enable_a  = ~ck_dmp_gated & i_ck_enable_a ;
   
    reg i_ck_dmp_enable_a_latched;    
    always @*
    begin
      if (!clk_in)
      begin
    	i_ck_dmp_enable_a_latched <= i_ck_dmp_enable_a;
      end

    end

   assign i_ck_dmp_dft_a = (clk_in & i_ck_dmp_enable_a_latched );
   

   assign clk_dmp = i_ck_dmp_dft_a;

// -------------------------------------------------------------------------
//  Debug clock
// 
   //  Provided that clock gating has been selected the debug clock is gated if
   // 
   //    1. The ARC is not in production test mode (test_mode = '0')
   //    2. The Enable Debug flag in the debug register (bit 24) is
   //       cleared (en_debug_r = '0').
   // 
   assign i_debug_enable_a = en_debug_r; 

   reg i_debug_enable_a_latched ;
      
   always @*
   begin
     if (!clk_in)
     begin
       i_debug_enable_a_latched <= i_debug_enable_a;
     end

   end

   assign clk_debug = (clk_in & i_debug_enable_a_latched);
   

endmodule // module ck_gen

