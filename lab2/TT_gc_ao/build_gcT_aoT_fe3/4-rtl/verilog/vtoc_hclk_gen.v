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
// Generate hclk in the VTOC hierarchy for AHB builds.
//
module vtoc_hclk_gen (
  xck_system,
  xhclk
  );

`include "arcutil_pkg_defines.v"
`include "extutil.v"

input                xck_system;
output               xhclk;

wire                 xhclk;

// synopsys_translate_off

assign xhclk = xck_system;

// synopsys_translate_on

endmodule // module vtoc_hclk_gen

