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
module ibus_cksyn (
    clk_ungated,
    clk_system,
    rst_a,
    sync
    );

input  clk_ungated; 
input  clk_system; 
input  rst_a;
output sync; 
wire   sync; 
wire clk_ext = clk_system;

// ============================================================================
// SIGNAL DECLARATIONS 
// ============================================================================

wire    toggle; 

// ============================================================================
// Architecture
// ============================================================================

//  System Clock toggle logic ----------------------------------------------

ibus_cksyn_sys icksyn_sys (
          .clk_ext (clk_ext),
          .rst_a   (rst_a),
          .toggle  (toggle)
    );

//  Main Clock domain sync generation unit ---------------------------------

ibus_cksyn_main icksyn_main (
          .clk_ungated (clk_ungated),
          .rst_a       (rst_a),
          .toggle      (toggle),
          .sync        (sync)
    );

endmodule // module ibus_cksyn

