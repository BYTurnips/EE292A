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
module ibus_cksyn_sys (
  clk_ext,
  rst_a,
  toggle
);

input   clk_ext; 
input   rst_a; 
output  toggle; 

wire    toggle; 

//  ============================================================================
//  SIGNAL DECLARATIONS 
//  ============================================================================

reg     toggle_int_r; 

//  ============================================================================
//  ARCHITECTURE
//  ============================================================================

always @(posedge clk_ext or posedge rst_a)
begin : TOG_PROC
  if (rst_a == 1'b1)
  begin
    toggle_int_r <= 1'b0;   
  end
  else
  begin
    toggle_int_r <= ~toggle_int_r;   
  end
end

assign toggle = toggle_int_r; 

endmodule // module ibus_cksyn_sys

