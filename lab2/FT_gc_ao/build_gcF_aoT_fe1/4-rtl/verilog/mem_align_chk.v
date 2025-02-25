// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 2000-2008 ARC International (Unpublished)
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
// The memory alignment check module detects whether a non-naturall
// aligned load or store transaction from the ARC core has occured.
//
// L indicates a latched signal and U indicates a signal produced by
// logic.
// 
// ======================= Inputs to this block =======================--
// 
//  clk_dmp          DMP clock domain.
// 
//  rst_a            L Latched external reset signal. The rst_a signal is
//                   asynchronously applied and synchronously removed.
// 
//  en3              U Pipeline stage 3 enable. When this signal is true,
//                   the instruction in stage 3 can pass into stage 4 at
//                   the end of the cycle. When it is false, it will
//                   probably hold up stages one (pcen), two (en2), and
//                   three. It is also used to qualify mload & mstore.
// 
//  mc_addr[]        Load Store Address. The result of the adder unit. 
//                   This goes to LSU, to be latched by the memory
//                   controller. The address is valid when either mload 
//                   OR mstore is active.
// 
//  mload            U Load Data. This signal indicates to the LSU that
//                   there is a valid load instruction in stage 3. It is
//                   produced from a decode of p3i[4:0], p3iw(25) (to
//                   exclude LR) and the p3iv signal.
//  
//  mstore           U Store Data. This signal indicates to the LSU that
//                   there is a valid store instruction in stage 3. It is
//                   produced from a decode of p3i[4:0], p3iw(25) (to
//                   exclude SR) and the p3iv signal.
// 
//  size[1:0]        L Size of Transfer. This pair of signals are used to
//                   indicate to the LSU the size of the memory 
//                   transaction which is being requested by a LD or ST 
//                   instruction. It is produced during stage 2 and
//                   latched as the size information bits are encoded in 
//                   different places on the LD and ST instructions. It
//                   must be qualified by the mload/mstore signals as it
//                   does not include an opcode decode.
// 
//                   The encoding for the size of the transfer is as
//                   follows:
// 
//                       00 - Long word
//                       01 - byte
//                       10 - word
//                       11 - Reserved
//
//  en_misaligned    Enable the mis-alignment feature from the aux_regs.
//
// ====================== Outputs from this block =====================--
// 
//  misaligned_err   A single pulse asserted whenever a mis-aligned memory
//                   access to memory is detected
//
//  misaligned_int   A single pulse asserted whenever a mis-aligned memory
//                   access to memory is in detected and the feature is
//                   enabled.
//
// ====================================================================--
//
module mem_align_chk (clk_dmp,
   rst_a,
   en3,
   mc_addr,
   mload,
   mstore,
   size,
   en_misaligned,

   misaligned_int,
   misaligned_err);

`include "arcutil.v" 

input   clk_dmp; 
input   rst_a; 
input   en3; 
input   [31:0] mc_addr; 
input   mload; 
input   mstore; 
input   [1:0] size; 
input   en_misaligned; 

output   misaligned_int; 
output   misaligned_err; 

//  DMP interface
wire     i_misaligned_err_a; 
wire     i_misaligned_int_a; 

   // --------------------------------------------------------------
   //  Detect mis-aligned memory access from the ARC core
   // --------------------------------------------------------------
   //  during memory write or read (mload or mstore asserted during en3)
   //  the mc_addr bits are qualifed with the size bits to make sure
   //  word (16 bit) accesses are only to even addresses
   //  and dword (32 bit) access are only to quad address
   // 
   //  If a non-aligned access is detected, set the misaligned output bit

   assign i_misaligned_err_a = (mload || mstore) && en3 &&
                               (((size == LDST_LWORD) && (mc_addr[1:0] != 2'b00)) ||
                               ((size == LDST_WORD) && (mc_addr[0] != 1'b0)));

   //  Output signals used and generated in this module
   //

   assign misaligned_int  = i_misaligned_err_a && en_misaligned; 
   assign misaligned_err  = i_misaligned_err_a; 

endmodule

