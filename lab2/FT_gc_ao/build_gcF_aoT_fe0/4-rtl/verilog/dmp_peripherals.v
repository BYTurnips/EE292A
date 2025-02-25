// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 2002-2012 ARC International (Unpublished)
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
// Placeholder for customer dmp peripheral add-ons.
// 
module dmp_peripherals (p_ldvalid,
                        p_drd,
                        p_stall);

output   p_ldvalid; 
output   [31:0] p_drd; 
output   p_stall; 
wire    p_ldvalid; 
wire    [31:0] p_drd; 
wire    p_stall; 

assign p_ldvalid = 1'b 0; 
assign p_drd = {32{1'b 0}}; 
assign p_stall = 1'b 0; 

endmodule // module dmp_peripherals

