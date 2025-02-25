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
// The FIFO that is used in the scoreboard unit. This FIFO is not a true
// FIFO. Instead it is of a kind called "balking form" which means that
// the FIFO permits an item to be removed from a location other than the
// front of the FIFO.
// 
// ========================= Inputs to this block =====================--
// 
//   add             Indicates that the address on dest[] should be added
//                   to the fifo on next clk.
// 
//   pop_a           Indicates that the fifo will be shifted down on
//                   next clk. A new register address will appear on
//                   front[].
// 
//   s1a[]           Source 1 register address from stage 2. 
//                   Used for scoreboarding.
// 
//   s2a[]           Source 2 register address from stage 2.
//                   Used for scoreboarding.
// 
//   dest[]          Destination register address from stage 2.
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
//   add_path        Indicates that the path type (pathadd_a) should be
//                   added to the FIFO item at the end of the FIFO on
//                   the next clock edge.
//   
//   pathadd_a       The path type that is to be added to the FIFO item
//                   at the end of the FIFO on the next clock edge. It
//                   describes which path (DMP sub-module or peripheral)
//                   that is servicing an outstanding load.
// 
//   pathpop_a       The path from which the load returns. This FIFO item
//                   that is closest to the front of the FIFO and that
//                   matches this path type is the one that is popped.
//   
// ======================== Output from this block ====================--
// 
//   matchup_a       Indicates that a register address (s1a, s2a or dest)
//                   has matched up with a value in the fifo.
// 
//   full_r          Indicates that the fifo is full and cannot accept
//                   any more register address values.
// 
//   empty_a         Indicates that the fifo is empty and there are no
//                   loads waiting to complete.
// 
//   max_one_lpend   Indicates that the LSU contains zero or one pending
//                   load. It is generated from the inverse of the
//                   status flag of the second fifo item in the LSU. If
//                   the second fifo item is empty, then the LSU cannot
//                   contain more than at most one pending load. This
//                   signal is used by the DMP control logic.
// 
//   front[]         The register address at the front of the fifo. This
//                   is the value that is used by the load scoreboard
//                   unit for register writeback when a delayed load is
//                   completing.
// 
// ====================================================================--
//
module scorfifo (clk,
                 rst_a,
                 add,
                 add_path,
                 pop_a,
                 s1a,
                 s2a,
                 dest,
                 pathadd_a,
                 pathpop_a,
                 s1en,
                 s2en,
                 desten,
                 kill_last,

                 matchup_a,
                 full_r,
                 empty_a,
                 front_src1_match,
                 front_src2_match,
                 max_one_lpend,
                 front);

`include "arcutil_pkg_defines.v"
`include "arcutil.v" 

input    clk; 
input    rst_a; 
input    add; 
input    add_path; 
input    pop_a; 
input    [OPERAND_MSB:0] s1a; 
input    [OPERAND_MSB:0] s2a; 
input    [OPERAND_MSB:0] dest; 
input    [1:0] pathadd_a; 
input    [1:0] pathpop_a; 
input    s1en; 
input    s2en; 
input    desten; 
input    kill_last; 

output   matchup_a; 
output   full_r; 
output   empty_a; 
output   front_src1_match;   
output   front_src2_match;   
output   max_one_lpend;
output   [OPERAND_MSB:0] front; 

wire     matchup_a; 
wire     full_r; 
wire     empty_a; 
wire     max_one_lpend; 
wire     front_src1_match;   
wire     front_src2_match;   
wire     [OPERAND_MSB:0] front; 
wire     i_stateout0; 
wire     i_stateout1_r; 
wire     i_stateout4_r; 
wire     i_stateout5; //  input to tail of fifo
wire     i_stateout6; //  input to tail of fifo

//  source 1 adr match from each scoritem
wire     i_s1match1_a; 
wire     i_s1match4_a; 

//  source 2 adr match from each scoritem
wire     i_s2match1_a; 
wire     i_s2match4_a; 

//  source 2 adr match from each scoritem
wire     i_destmatch1_a; 
wire     i_destmatch4_a; 

//  the values in each scoritem
wire     [OPERAND_MSB:0] i_item1_r; //  front
wire     [OPERAND_MSB:0] i_item4_r; //  tail
wire     [OPERAND_MSB:0] i_item5_r; 
wire     i_matchup234_a; 
wire     i_matchup1_a; 
wire     i_matchup2_a; 
wire     i_matchup3_a; 
wire     i_matchup4_a; 

//  pop command for each fifo element
wire     i_pop1_a; 
wire     i_pop4_a; 

//  kill command for each fifo element
wire     i_kill1_a; 
wire     i_kill4_a; 

//  last command for each fifo element
wire     i_last1_a; 
wire     i_last4_a; 

//  remove command for each fifo element
wire     i_remove1_a; 
wire     i_remove4_a; 

//  content of the path bits for each fifo element
wire     [1:0] i_pathout1_r; 
wire     [1:0] i_pathout4_r; 
wire     [1:0] i_pathout5; 

//   
//    -------     -------     -------     -------
//   |       |   |       |   |       |   |       |
//   | fnum4 |-> | fnum3 |-> | fnum2 |-> | fnum1 |-> front
//   |       |   |       |   |       |   |       |
//   |       |   |       |   |       |   |       |
//    -------     -------     -------     -------

//  input for tail of fifo
assign i_stateout0 = 1'b 1;
assign i_stateout5 = 1'b 0; 
assign i_stateout6 = 1'b 0; 

//  core register 0
assign i_item5_r = r0;

//  load returned from load/store queue
assign i_pathout5 = LD_QUEUE;

//  front of fifo
scoritem U_scoritem0 (
                  .clk(clk),
                  .rst_a(rst_a),
                  .add(add),
                  .add_path(add_path),
                  .pop_a(i_pop1_a),
                  .kill(i_kill1_a),
                  .itemin(i_item4_r),
                  .statein(i_stateout4_r),
                  .statein2(1'b0),
                  .pathin(i_pathout4_r),
                  .stateahead(i_stateout0),
                  .s1a(s1a),
                  .s2a(s2a),
                  .dest(dest),
                  .pathadd_a(pathadd_a),

                  .itemout_r(i_item1_r),
                  .stateout_r(i_stateout1_r),
                  .pathout_r(i_pathout1_r),
                  .s1match_a(i_s1match1_a),
                  .s2match_a(i_s2match1_a),
                  .destmatch_a(i_destmatch1_a));


//  tail of fifo
scoritem U_scoritem3 (
                  .clk(clk),
                  .rst_a(rst_a),
                  .add(add),
                  .add_path(add_path),
                  .pop_a(i_pop4_a),
                  .kill(i_kill4_a),
                  .itemin(i_item5_r),
                  .statein(i_stateout5),
                  .statein2(i_stateout6),
                  .pathin(i_pathout5),
                  .stateahead(i_stateout1_r),
                  .s1a(s1a),
                  .s2a(s2a),
                  .dest(dest),
                  .pathadd_a(pathadd_a),

                  .itemout_r(i_item4_r),
                  .stateout_r(i_stateout4_r),
                  .pathout_r(i_pathout4_r),
                  .s1match_a(i_s1match4_a),
                  .s2match_a(i_s2match4_a),
                  .destmatch_a(i_destmatch4_a));

// Since each scoritem doesn't take into account of the enable
// signals, do it here.
//
// 
// This is a very difficult statement to get 100% multiple
// sub-condition coverage.
// 
// assign i_matchup234_a =
// 
//    (((i_s1match2_a  | i_s1match3_a   | i_s1match4_a)   & s1en) |
//    ((i_s2match2_a   | i_s2match3_a   | i_s2match4_a)   & s2en) |
//    ((i_destmatch2_a | i_destmatch3_a | i_destmatch4_a) & desten));
// 
// Report a match for the first load in the queue. This is used to
// allow returning loads to be shortcut into stage 2.
// 
assign i_matchup1_a = (i_s1match1_a & s1en) | (i_s2match1_a & s2en) | 
                    (i_destmatch1_a & desten);

assign i_matchup2_a = 1'b0;
assign i_matchup3_a = 1'b0;

assign i_matchup4_a = (i_s1match4_a & s1en) | (i_s2match4_a & s2en) | 
                    (i_destmatch4_a & desten);

assign i_matchup234_a = (i_matchup2_a | i_matchup3_a | i_matchup4_a);
 
//  Report a match from the FIFO
// 
assign matchup_a = (i_matchup1_a               == 1'b 1)  &
                   (~(i_remove1_a              == 1'b 1)) |
                   (i_matchup4_a               == 1'b 1)  & 
                   (~(i_remove4_a              == 1'b 1)) ?
       1'b 1 : 
       1'b 0;
 
// The remove signals indicate if a FIFO item is popped from
// the scoreboard.
// 
assign i_remove1_a = ((pop_a        == 1'b 1) &
                      (i_pathout1_r == pathpop_a)) ?
       1'b 1 :
       1'b 0;

assign i_remove4_a = ((pop_a        == 1'b 1)   &
                      ((i_pathout1_r != pathpop_a)
       ))  ? 1'b 1 : 1'b 0;
 
assign i_last1_a = ((i_stateout4_r == 1'b 0) &
                    (i_stateout1_r == 1'b 1)) ?
           1'b 1 :
           1'b 0;
   
   
assign i_last4_a = (i_stateout4_r == 1'b 1) ?
           1'b 1 :
           1'b 0;

assign i_kill1_a = ((kill_last == 1'b 1) &
                    (i_last1_a   == 1'b 1)) |
                   ((kill_last == 1'b 1) &
                    (i_stateout4_r   == 1'b 1) &
                    (pop_a       == 1'b 1)) ?
           1'b 1 :
           1'b 0;


assign i_kill4_a = ((kill_last == 1'b 1) &
                    (i_last4_a   == 1'b 1) &
                    (pop_a       == 1'b 0)) ?
           1'b 1 :
           1'b 0;

//  Each FIFO item is controlled by its separate pop_a control signal
//  A FIFO items is popped if the requested path of the pop (pathpop_a)
//  matches the path bits (e.g. i_pathout1_r) of either the FIFO item
//  itself or any FIFO item ahead of it. The last FIFO item is always
//  popped independent of matches, because every pop always succeeds.
//  That is why i_pop4_a (pop control for last FIFO item) equals the
//  global pop signal.
//
assign i_pop1_a = ((pop_a        == 1'b 1) &
                   (i_pathout1_r == pathpop_a)) ? 1'b 1 : 
       1'b 0; 


assign i_pop4_a = (pop_a == 1'b 1) ? 1'b 1 : 
       1'b 0;

//  The bus "front" is set to the item that is popped. The FIFO item
//  that has matching path type with the returning load and that
//  is closest to the front is popped.
// 

assign front_src1_match = (i_pathout1_r == pathpop_a) ?
           (i_s1match1_a &  s1en) :
                                  (i_pathout4_r == pathpop_a) ?
           (i_s1match4_a &  s1en) :
           1'b 0;

assign front_src2_match = (i_pathout1_r == pathpop_a) ?
           (i_s2match1_a &  s2en) :
                                  (i_pathout4_r == pathpop_a) ?
           (i_s2match4_a &  s2en) :
           1'b 0;

assign front = (i_pathout1_r == pathpop_a) ? i_item1_r : 
               (i_pathout4_r == pathpop_a) ? i_item4_r : 
       i_item1_r;

//  The signal max_one_lpend indicates that the LSU contains zero or
//  one pending load. It is generated from the inverse of the status
//  flag of the second fifo item in the LSU. If the second fifo item
//  is empty, then the LSU cannot contain more than at most one
//  pending load. This signal is used by the DMP control logic.
// 
assign max_one_lpend = (~i_stateout4_r); 
assign empty_a = (~i_stateout1_r); 
assign full_r = i_stateout4_r; 

endmodule // module scorfifo

