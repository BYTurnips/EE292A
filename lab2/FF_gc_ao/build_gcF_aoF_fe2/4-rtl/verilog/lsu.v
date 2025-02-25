// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 1999-2012 ARC International (Unpublished)
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
// This is the top level of the Load Scoreboard Unit.
// 
// This unit scoreboards the loads to allow out of order load
// return between different data memory pipeline (DMP) sub-
// modules and peripherals. Two loads can return out of order
// if they go through different DMP sub-modules or peripherals.
// However, they return in order if they are serviced by the same
// sub-module. The peripherals count as one sub-module for the
// LSU, so two loads serviced by two different peripherals
// return in order. However one load to a DMP sub-module and
// one load to a peripheral can return out of order.
//  
// ========================= Inputs to this block =====================--
// 
//   s1a             Source 1 register address from stage 2. 
//                   Used for scoreboarding.
// 
//   fs2a            Source 2 register address from stage 2.
//                   Used for scoreboarding.
// 
//   dest            Destination register address from stage 2.
//                   Used for scoreboarding.
// 
//   mload2b         Stage 2B contains a valid load instruction.
//                   Used by the scoreboard unit.
// 
//   s1en            Source 1 address is valid.
//                   Used by the scoreboard unit for scoreboard hit.
// 
//   s2en            Source 2 address is valid.
//                   Used by the scoreboard unit for scoreboard hit.
// 
//   desten          Destination address is valid.
//                   Used by the scoreboard unit for scoreboard hit.
// 
//   en2b            Indicates that stage 2b is ready to move on.
//                   Used by the scoreboard to load up dest addr values.
// 
//   ldvalid         Indicates that there is a returning load. This
//                   signal is not set during debug access, because in
//                   that case the LSU is not used. 
// 
//   q_ldvalid       Indicates that the load/store queue wishes to
//                   perform a writeback on the next cycle. Writeback
//                   will be performed on behalf of the delayed load.
//                   The register address for writeback is provided on
//                   regadr[] and comes from the scoreboard unit. The
//                   amount of time required between this signal
//                   becoming valid and the end of the cycle will depend
//                   on the number of multiplexers in ALU which need to
//                   be switched to get everything lined up for
//                   writeback.
// 
//   dc_ldvalid_r    Indicates that the data cache wishes to perform a
//                   writeback on the next cycle.
// 
//   loc_ldvalid     Indicates that the local RAM wishes to perform a
//                   writeback on the next cycle.
// 
//   p_ldvalid       Indicates that the peripherals wishes to perform a
//                   writeback on the next cycle.
//         
//   en3             Indicates that pipeline stage 3 is ready to move on.
// 
//   mload           Indicates that pipeline stage 3 contains a load (LD)
//                   instruction.
// 
//   nocache         Indicates that the load (LD) or store (ST)
//                   instruction in pipeline stage 3 has the .DI
//                   extension enabled. This extension to LD/ST
//                   instructions can be used by the programmer/
//                   compiler to indicate that this memory request should
//                   not be serviced by the data cache.
// 
//   dc_disable_r    When the data cache is selected this auxiliary
//                   register is available. When it is set the data
//                   cache is disabled. If there is no data cache in the
//                   build then this signal is always set.
//
//   kill_last       True when a mispredicted compare & branch needs to
//                   remove an item from the load-store queue.
//         
//   is_local_ram    Indicates that the address of a load (LD) or store
//                   (ST) request in pipeline stage 3 is within the
//                   boundaries of the Load/Store RAM (also called "local
//                   RAM"). The request will consequently be serviced by
//                   the Load/Store RAM.
// 
//   is_peripheral   Indicates that the address of a load (LD) or store
//                   (ST) request in pipeline stage 3 is within the
//                   boundaries of the peripherals. The request will
//                   consequently be serviced by a peripheral.
//
   
// ======================== Output from this block ====================--
// 
//   holdup2b        Holds stage2b. The scoreboard uses this when
//                   the scoreboard is full or there is a scoreboard and
//                   register address hit. It is produced from s1a, fs2a,
//                   dest, s1en, s2en, desten and the scoreboarding
//                   mechanism.
// 
//   lpending        Indicates to ARC that there is at least one load
//                   pending. It is the inverse of the empty flag from
//                   the scoreboard.
// 
//   max_one_lpend   Indicates that the LSU contains zero or one pending
//                   load. It is generated from the inverse of the
//                   status flag of the second fifo item in the LSU. If
//                   the second fifo item is empty, then the LSU cannot
//                   contain more than at most one pending load. This
//                   signal is used by the DMP control logic.
// 
//   regadr          The register address which is to be used for a load
//                   writeback when ldvalid is true.
//
//
// regadr_eq_src1   U True when load return register address matches source 1
//                  of the instruction in stage2b
//
// regadr_eq_src2   U True when load return register address matches source 2
//                  of the instruction in stage2b
//
// ====================================================================--
//
module lsu (clk,
            rst_a,
            ldvalid,
            q_ldvalid,
            loc_ldvalid,
                is_local_ram,
                is_peripheral,
            s1a,
            fs2a,
            dest,
            mload2b,
            s1en,
            s2en,
            desten,
            en2b,
            kill_last,
            en3,
            mload,
            nocache,
            dc_disable_r,

            regadr,
            regadr_eq_src1,
            regadr_eq_src2,
            holdup2b,
            max_one_lpend,
            lpending);

`include "arcutil_pkg_defines.v"
`include "arcutil.v"    

input   clk; 
input   rst_a; 
input   ldvalid;
input   q_ldvalid; 
input   loc_ldvalid; 
input   is_local_ram; 
input   is_peripheral;
 
input   [5:0] s1a; 
input   [5:0] fs2a; 
input   [5:0] dest; 
input   mload2b; 
input   s1en; 
input   s2en; 
input   desten; 
input   en2b;
input   kill_last;   
input   en3; 
input   mload; 
input   nocache; 
input   dc_disable_r; 

output  [5:0] regadr; 
output  regadr_eq_src1; 
output  regadr_eq_src2; 
output  holdup2b; 
output  max_one_lpend; 
output  lpending; 

wire    [5:0] regadr; 
wire    regadr_eq_src1; 
wire    regadr_eq_src2; 
wire    holdup2b; 
wire    max_one_lpend; 
wire    lpending; 
wire    i_empty_a; 

scorebd U_scoreboard(
                   .clk(clk),
                   .rst_a(rst_a),
                   .s1a(s1a),
                   .s2a(fs2a),
                   .dest(dest),
                   .s1en(s1en),
                   .s2en(s2en),
                   .desten(desten),
                   .mload2b(mload2b),
                   .en2(en2b),
                   .ldvalid(ldvalid),
                   .q_ldvalid(q_ldvalid),
                   .loc_ldvalid(loc_ldvalid),
                   .en3(en3),
                   .mload(mload),
                   .nocache(nocache),
                   .dc_disable_r(dc_disable_r),
                   .kill_last(kill_last),
                   .is_local_ram(is_local_ram),
                   .is_peripheral(is_peripheral),

                   .regadr(regadr),
                   .regadr_eq_src1(regadr_eq_src1),
                   .regadr_eq_src2(regadr_eq_src2),
                   .holdup12(holdup2b),
                   .max_one_lpend(max_one_lpend),
                   .empty_a(i_empty_a));

//  Load pending signal to be used by ARC as a bit of the debug
//  register.
// 
assign lpending = ~i_empty_a;


endmodule // module lsu

