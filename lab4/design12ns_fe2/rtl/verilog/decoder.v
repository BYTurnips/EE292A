// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 2001-2012 ARC International (Unpublished)
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
// This module decodes the address (dmp_addr) of the memory request
// and indicates which of the following modules that should service 
// that request:
// 
//    [1] LD/ST queue or data cache (mapped to the same address space)
//    [2] Peripherals
//    [3] DCCM RAM
//    [4] ICCM RAM
// 
// All of these modules are optional, but each build needs either a 
// LD/ST queue and/or a LD/ST RAM. Each build must also have either a 
// code RAM or an instruction cache (but not both).
//
// ======================= Inputs to this block ======================--
//
// dmp_addr         The load/store address is connected to the DMP
//                  sub-modules, the peripherals and the code RAM. This
//                  address can come from either the ARC pipeline or the
//                  debug interface depending on which module requests
//                  access to memory.
//
// lram_base        Base address for the LD/ST RAM. The address of a
//                  memory request (dmp_addr) is compared to this
//                  auxiliary register (lram_base) in order to generate
//                  the signal is_ldst_ram.
//
// ====================== Outputs from this block ====================--
//
// is_ldst_ram      This signal is true when the address (dmp_addr) is
//                  within the address range of the load/store RAM.
//
// is_code_ram      This signal is true when the address (dmp_addr) is
//                  within the address range of the code RAM.
//
// is_local_ram     This signal is true when the address (dmp_addr) is
//                  within the address ranges of either the code RAM or
//                  the LD/ST RAM.
//
// ===================================================================--
//
module decoder (dmp_addr,
    lram_base,


   is_ldst_ram,
   is_code_ram,
   is_local_ramx,
   is_local_ramy,
   is_local_ram,
   is_peripheral);

`include "arcutil_pkg_defines.v"
`include "arcutil.v"
`include "extutil.v"
`include "xdefs.v"
`include "ext_msb.v"

input   [31:0] dmp_addr;
input   [EXT_A_MSB:LDST_A_MSB+3] lram_base;


// Address range matches

output  is_ldst_ram;
output  is_code_ram; 
output  is_local_ramx;
output  is_local_ramy; 
output  is_local_ram; 
output  is_peripheral; 

wire    is_ldst_ram; 
wire    is_code_ram; 
wire    is_local_ramx; 
wire    is_local_ramy;
wire    is_local_ram; 
wire    is_peripheral; 

wire    i_is_ldst_ram; 
wire    i_is_code_ram;
wire    i_is_local_ramx; 
wire    i_is_local_ramy;

// ========================= is_ldst_ram =========================--
// 
//  This signal is set when the address (dmp_addr) is within the
//  address range of the LD/ST RAM. If there is no LD/ST RAM in the
//  build then this signal is always false (i.e. cleared).
// 
//  Support for XY Memory
//  
assign i_is_local_ramx = 
                         1'b 0;
                     
assign i_is_local_ramy = 
                         1'b 0;
                     
//  Support for DCCM
//
assign i_is_ldst_ram = 
                      (dmp_addr[EXT_A_MSB:LDST_A_MSB + 3] == lram_base) ?
       1'b 1 : 
      1'b 0;


assign is_ldst_ram   = i_is_ldst_ram; 
assign is_local_ramx = i_is_local_ramx; 
assign is_local_ramy = i_is_local_ramy; 

// ========================= is_code_ram =========================--
// 
//  This signal is set when the address (dmp_addr) is within the
//  address range of the code RAM. If there is no code in the
//  build then this signal is always false (i.e. cleared).
// 
assign i_is_code_ram = ~dmp_addr[EXT_A_MSB];

assign is_code_ram = i_is_code_ram;

// ========================= is_local_ram =========================--
// 
//  This signal is set when the address (dmp_addr) is within the
//  address ranges of either the LD/ST RAM or the code RAM. If none 
//  of these RAM's exist in this build then this signal is always 
//  false (i.e. cleared).
// 
assign is_local_ram = i_is_ldst_ram   |
                      i_is_code_ram   |
                      i_is_local_ramx |
                      i_is_local_ramy;

// ========================= is_peripheral =======================--
// 
//  The signal is_peripheral is set when the memory address (dmp_addr)
//  is within the address range of the peripherals. When this signal
//  is set only a peripheral should service the request.
//
assign is_peripheral = 

1'b 0; 


endmodule 
