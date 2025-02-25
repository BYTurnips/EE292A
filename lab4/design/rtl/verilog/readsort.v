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
// L indicates a latched signal and U indicates a signal produced by
// logic.
// 
// ======================== Inputs to this block ========================--
// 
//  addr             Load/store address connected to the DMP sub-modules
//                   (e.g. the load/store queue) and the peripherals
//
//  size             Size of Transfer, connected to the DMP-submodules
//                   (e.g. the load/store queue).
//                              00 => long
//                              01 => byte
//                              10 => word
//                              11 => undefined.
// 
//  sex              Sign extend signal connected to the DMP-submodules
//                   (e.g. the load/store queue)
// 
//  d_in             U Read Data. This 32-bit data is valid on the cycle 
//                   when ldst_dlat is set to '1'.
// 
// ====================== Outputs from this block =======================--
// 
//  d_out            Load data return bus from the load/store queue.
// 
// ======================================================================--
//
module readsort (d_in,
                 addr,
                 size,
                 sex,

                 d_out);

`include "arcutil.v"

   input   [31:0] d_in; 
   input   [1:0]  addr; 
   input   [1:0]  size; 
   input          sex; 

   output  [31:0] d_out; 

   wire    [31:0] d_out; 

   wire    [31:0] i_longword_a; 
   wire    [15:0] i_word_a; 
   wire    [7:0]  i_byte_a; 
   reg     [31:0] i_sxtl_a; 
   reg     [31:0] i_extl_a; 

   //  Select which part of the longword is used.
   //
   assign      i_longword_a = d_in[31:0]; 

 //Little-endian byte ordering
   assign      i_word_a = 
               (addr[1] == 1'b 1) ?
               i_longword_a[31:16] : i_longword_a[15:0]; 

   assign      i_byte_a = 
               (addr[0] == 1'b 1) ? 
               i_word_a[15:8] : i_word_a[7:0]; 

   // Sign extended read data formatting
   always @(
            size
            or i_byte_a
            or i_word_a
            or i_longword_a
            )
      begin : i_sxtl_a_mux_PROC
         case(size)
           LDST_LWORD : i_sxtl_a = i_longword_a;
           LDST_BYTE  : i_sxtl_a = {{24{i_byte_a[7]}}, i_byte_a};
           default  : i_sxtl_a = {{16{i_word_a[15]}},i_word_a};
         endcase // case(size)
      end // block: i_sxtl_a_mux_PROC

   // Zero extended read data formatting
   always @(
            size
            or i_byte_a
            or i_word_a
            or i_longword_a
            )
      begin : i_extl_a_mux_PROC
         case(size)
           LDST_LWORD : i_extl_a = i_longword_a;
           LDST_BYTE  : i_extl_a = {{24{1'b 0}},i_byte_a};
           default  : i_extl_a = {{16{1'b 0}},i_word_a};
         endcase // case(size)
      end // block: i_extl_a_mux_PROC
            
   // Finally select whether results is sign extended or not.
   //   
   assign      d_out = 
               (sex == 1'b 1) ? 
               i_sxtl_a : i_extl_a;
   
endmodule

