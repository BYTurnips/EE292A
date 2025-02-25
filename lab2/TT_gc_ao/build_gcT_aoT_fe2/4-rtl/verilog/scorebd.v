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
// The scoreboard functionality of the Load Scoreboard Unit (LSU).
// 
// ========================= Inputs to this block =====================--
//
//   s1a[]           Source 1 register address from stage 2. 
//                   Used for scoreboarding.
// 
//   s2a[]           Source 2 register address from stage 2.
//                   Used for scoreboarding.
// 
//   dest[]          Destination register address from stage 2
//                   Used for scoreboarding.
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
//   mload2b         Stage 2B contains a valid load instruction.
//                   Used by the scoreboard unit.
// 
//   en2b            Indicates that stage 2b is ready to move on.
//                   Used by the scoreboard to load up dest addr values.
// 
//   ldvalid         Indicates that there is a returning load. This
//                   signal is not set during debug access, because in
//                   that case the LSU is not used.
// 
//   q_ldvalid       Indicates that the load/store queue wishes to
//                   perform a writeback on the next cycle. 
//                   Writeback will be performed on behalf of the
//                   delayed load. The register address for writeback is
//                   provided on regadr[] and comes from the scoreboard
//                   unit. The amount of time required between this
//                   signal becoming valid and the end of the cycle will
//                   depend on the number of multiplexers in ALU which
//                   need to be switched to get everything lined up for
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
//   mload           Indicates that pipeline stage 3 contains a load
//                   (LD) instruction.
// 
//   nocache         Indicates that the load (LD) or store (ST)
//                   instruction in pipeline stage 3 has the .DI
//                   extension enabled. This extension to LD/ST
//                   instructions can be used by the programmer/compiler
//                   to indicate that this memory request should not be
//                   serviced by the data cache.
// 
//   dc_disable_r    When the data cache is selected this auxiliary
//                   register is available. When it is set the data cache
//                   is disabled.
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
//   holdup12        Holds stages 1 and 2. The scoreboard uses this when
//                   the scoreboard is full or there is a scoreboard and
//                   register address hit. It is produced from s1a, s2a,
//                   dest, s1en, s2en, desten and the scoreboarding
//                   mechanism.
// 
//   empty_a         Indicates that the scoreboard is empty and there
//                   are no pending loads.
// 
//   max_one_lpend   Indicates that the LSU contains zero or one pending
//                   load. It is generated from the inverse of the
//                   status flag of the second fifo item in the LSU. If
//                   the second fifo item is empty, then the LSU cannot
//                   contain more than at most one pending load. This
//                   signal is used by the DMP control logic.
// 
//   regadr          Register address to be used for writes initiated by
//                   a load valid signal when a delayed load is
//                   completing.
// 
// ====================================================================--
//
module scorebd (clk,
                rst_a,
                s1a,
                s2a,
                dest,
                s1en,
                s2en,
                desten,
                mload2b,
                en2,
                en3,
                mload,
                nocache,
                dc_disable_r,
                kill_last,
                is_local_ram,
                is_peripheral,
                ldvalid,
                q_ldvalid,
                loc_ldvalid,

                regadr,
                holdup12,
                max_one_lpend,
                regadr_eq_src1,
                regadr_eq_src2,
                empty_a);

`include "arcutil_pkg_defines.v"
`include "arcutil.v" 

input   clk; 
input   rst_a; 
input   [OPERAND_MSB:0] s1a; 
input   [OPERAND_MSB:0] s2a; 
input   [OPERAND_MSB:0] dest; 
input   s1en; 
input   s2en; 
input   desten; 
input   mload2b; 
input   en2; 
input   en3; 
input   mload; 
input   nocache; 
input   dc_disable_r; 
input   kill_last; 
input   is_local_ram; 
input   is_peripheral;
 
input   ldvalid; 
input   q_ldvalid; 
input   loc_ldvalid; 

output   [OPERAND_MSB:0] regadr; 
output   holdup12; 
output   max_one_lpend; 
output   regadr_eq_src1; 
output   regadr_eq_src2; 
output   empty_a; 

wire    [OPERAND_MSB:0] regadr; 
wire    holdup12; 
wire    max_one_lpend; 
wire    regadr_eq_src1; 
wire    regadr_eq_src2; 
wire    empty_a; 
wire    i_add_a; 
wire    i_add_path_a; 
wire    i_pop_a; 
wire    [1:0] i_pathadd_a; 
wire    [1:0] i_pathpop_a; 
wire    i_full_r; 
wire    i_matchup_a; 
wire    i_freeslot_a; 

scorfifo U_scorfifo (.clk(clk),
                     .rst_a(rst_a),
                     .add(i_add_a),
                     .add_path(i_add_path_a),
                     .pop_a(i_pop_a),
                     .s1a(s1a),
                     .s2a(s2a),
                     .dest(dest),
                     .pathadd_a(i_pathadd_a),
                     .pathpop_a(i_pathpop_a),
                     .s1en(s1en),
                     .s2en(s2en),
                     .desten(desten),
                     .kill_last(kill_last),

                     .matchup_a(i_matchup_a),
                     .full_r(i_full_r),
                     .empty_a(empty_a),
                     .max_one_lpend(max_one_lpend),
                     .front_src1_match(regadr_eq_src1),
                     .front_src2_match(regadr_eq_src2),
                     .front(regadr));

assign i_add_a = ((mload2b      == 1'b 1) &&
                  (en2          == 1'b 1) && 
                  (i_freeslot_a == 1'b 1))   ?
       1'b 1 : 
       1'b 0;

// -------------------------------------------------------------------
//  Adding return address to the lsu fifo
// -------------------------------------------------------------------
// 
//  Always add when a load is in pipeline stage 2 and the fifo is not
//  full
// 
//  ...and if we allow load shortcutting:
// 
//     if fifo is full and a load is in stage2 and any load valid
//     signal is true then it is okay to add, since we will be
//     simultaneously popping as a result of ldvalid.
// 
// -------------------------------------------------------------------
//  Adding path to the LSU FIFO
// -------------------------------------------------------------------
// 
//  Always add the path in pipeline stage 3, when there is a load
//  instruction (mload = '1'), which is allowed to move on
//  (en3 = '1'). The path that is added depends on a couple of
//  qualifiers. The path is set to (in priority order):
// 
//     1. To the constant LD_PERIPH if is_peripheral is set.
// 
//     2. To the constant LD_RAM if is_local_ram is set.
// 
//     3. To the constant LD_QUEUE if the data cache is disabled
//        (dc_disable_r = '0') or the .DI extension has been used
//        on the LD/ST instruction to indicate that the instruction
//        should not be serviced by the data cache.
// 
//     4. If all 3 conditions above are false the path is set to
//        the data cache, i.e. to the constant LD_CACHE.
// 
//  The constants are defined in the include file arcutil.
//

assign i_add_path_a = ((mload == 1'b 1) && (en3 == 1'b 1)) ?
       1'b 1 : 
       1'b 0; 
       
assign i_pathadd_a = 
                     (is_peripheral == 1'b 1) ? LD_PERIPH : 
                     (is_local_ram == 1'b 1) ? LD_RAM : 
                     (dc_disable_r == 1'b 0) && (nocache == 1'b 0) ? LD_CACHE : 
       LD_QUEUE;

// -------------------------------------------------------------------
//  Popping return address from the LSU FIFO
// -------------------------------------------------------------------
//
//  Always pop when a delayed load comes back in pipeline stage 3, so
//  that the return address is available in pipeline stage 4.
//
//  The LSU FIFO is not a true FIFO, but a queue of a kind called
//  "balking form". Basically it is a FIFO that permits an item to be
//  removed from a location other than the front of the FIFO. Which
//  location that is being popped depends on from which path the load
//  returns. If the load returns from for example the data cache, the
//  FIFO item is popped that is closest to the the front of the FIFO
//  and that has the same path type (i.e. data cache in this
//  example). If the LSU FIFO only contains one path type, it acts
//  exactly as a FIFO.
// 
//  Loads can return from different paths at the same time, but only
//  one can be serviced at the time. The Load Return Arbitrator in
//  the DMP takes care of arbitrating between the returning loads.
//  The only thing the LSU needs to do is to make the return address
//  available for the returning load from the memory path with the
//  highest priority. The bus i_pathpop_a is set to the path type of the
//  load return with the highest priority. The bus i_pathpop_a is set
//  in priority order as follows (the constants are defined in
//  arcutil.v):
// 
//          1.To the constant LD_QUEUE (load/store queue) if a load
//            returns from the load/store queue (q_ldvalid = '1')
//
//          2.To the constant LD_CACHE (data cache) if a load returns
//            from the data cache (dc_ldvalid_r = '1').
//
//          3.To the constant LD_RAM (LD/ST RAM) if a load returns
//            from the load/store RAM (loc_ldvalid = '1').
//
//          4.To the constant LD_PERIPH (peripheral) if a load
//            returns from a peripheral (p_ldvalid = '1').
//
//          5.To the constant LD_QUEUE (load/store queue) if no load
//            returns at all.
//
assign i_pop_a = ldvalid; 
assign i_pathpop_a = 
                     (q_ldvalid == 1'b 1) ? LD_QUEUE : 
                     (loc_ldvalid == 1'b 1) ? LD_RAM : 
       LD_QUEUE;

// -------------------------------------------------------------------
//  Stall stage 2 under the following conditions:
// -------------------------------------------------------------------
// 
//  i.  There is a match between a source register in stage 2 and a
//      pending load.
// 
//       i_matchup_a == 1'b 1
//  
//  ii. The fifo is full, and we don't have a returning load - which
//      will clear a slot. A returning load clearing a slot can only
//      happen when we allow load shortcutting, since in the
//      always-stalls case, stage 3 is stalled by ldvalid, so we do
//      not need to include it here.
// 
//       (mload2b == 1'b 1 & i_freeslot_a == 1'b 0)
// 
//  What will happen in the case when an instruction in stage 2 is
//  waiting on a load to return? The FIFO now has a mode which will
//  prevent 'matchup' from being set if a returning load will write
//  the register which would otherwise cause a stall.
//  
//  The case would be :  ldvalid == 1'b 1
//                       regadr == s1a | regadr == s2a |
//                       regadr == dest
//                       (s1en == 1'b 1), (s2en == 1'b 1),
//                       (desten == 1'b 1) valid as appropriate
//                       (-> scorfifo s1match1/s2match1/destmatch1
//                       true, pop == 1'b 1)
// 
//  The case of instructions dependent on loads to non-shortcuttable
//  registers (e.g. loopcount) is handled by the ihp2_ld_nsc signal
//  in rctl.v. Essentially an additional pipeline stage 2 stall is
//  generated when a load is returning to a non-shortcuttable
//  register, and there is a read dependent upon this load.
// 
assign holdup12 = (((mload2b      == 1'b 1) &&
                    (i_freeslot_a == 1'b 0)) || 
                   (i_matchup_a  == 1'b 1)) ?
       1'b 1 : 
       1'b 0;

//  This signal is true when a free slot is, or is becoming available
//  in the fifo. Either the fifo already has a free slot, or a
//  returning load may cause a slot to become free, in the case where
//  the load queue is already full.
// 
assign i_freeslot_a = ((i_full_r == 1'b 0) || (i_pop_a == 1'b 1)) ?
       1'b 1 : 
       1'b 0; 

endmodule // module scorebd

