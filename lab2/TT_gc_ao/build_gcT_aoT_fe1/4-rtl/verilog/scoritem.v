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
// Single item for use in the structural queue mechanism.
// 
// ========================= Inputs to this block =====================--
// 
//   add         The address in dest is added to this item if there is
//               something in the item ahead (as indicated by
//               stateahead) and this one is empty.
// 
//   pop_a       The address from the item behind (itemin) is latched
//               into this item when this signal is high.
// 
//   itemin[]    This is the output of the item which is behind this
//               item.
// 
//   pathin[]    This is the path of the item which is behind this item.
// 
//   pc_in[]     This is the PC of the item which is behind this item.
// 
//   statein     This is the state of the item which is behind this item.
//               0 means item behind is empty, 1 means it contains an
//               address.
// 
//   statein2    This is the state of the item which is two items behind
//               this item. 0 means item behind is empty, 1 means it
//               contains an address.
// 
//   stateahead  State of the item ahead of this item.
//               0 means item ahead is empty, 1 means it contains an
//               address.
// 
//   s1a[]       Source 1 register address which is compared with
//               itemout_r.
// 
//   s2a[]       Source 2 register address which is compared with
//               itemout_r.
// 
//   dest[]      destination register address which is compared with
//               itemout_r.
// 
//   add_path    Indicates that the path type (pathadd_a) should be added
//               to the FIFO item at the end of the FIFO on the next
//               clock edge.
//   
//   pathadd_a     The path type that is to be added to the FIFO item at
//               the end of the FIFO on the next clock edge. It
//               describes which path (DMP sub-module or peripheral) that
//               is servicing an outstanding load.
// 
// ======================== Output from this block ====================--
// 
//   itemout_r   The register address that is latched in this item. Only
//               valid when stateout_r is 1.
// 
//   pathout_r   The path that is servicing the outstanding load
//               associated with the return address in itemout_r.
// 
//   stateout_r  Indicates that this item contains a valid register
//               address that is being used by the memory controller.
// 
//   s1match_a   indicates that the register address on s1a matches
//               itemout_r
// 
//   s2match_a   indicates that the register address on s2a matches
//               itemout_r
// 
//   destmatch_a indicates that the register address on dest matches
//               itemout_r
// 
// ====================================================================--
//
module scoritem (clk,
                 rst_a,
                 add,
                 add_path,
                 pop_a,
                 kill,
                 itemin,
                 statein,
                 statein2,
                 pathin,
                 stateahead,
                 s1a,
                 s2a,
                 dest,
                 pathadd_a,

                 itemout_r,
                 stateout_r,
                 pathout_r,
                 s1match_a,
                 s2match_a,
                 destmatch_a);

`include "arcutil_pkg_defines.v"
`include "arcutil.v"

input   clk; 
input   rst_a; 
input   add; 
input   add_path; 
input   pop_a; 
input   kill; 
input   [OPERAND_MSB:0] itemin; 
input   statein; 
input   statein2; 
input   [1:0] pathin; 
input   stateahead; 
input   [OPERAND_MSB:0] s1a; 
input   [OPERAND_MSB:0] s2a; 
input   [OPERAND_MSB:0] dest; 
input   [1:0] pathadd_a; 

output   [OPERAND_MSB:0] itemout_r; 
output   stateout_r; 
output   [1:0] pathout_r; 
output   s1match_a; 
output   s2match_a; 
output   destmatch_a; 

wire    [OPERAND_MSB:0] itemout_r; 
wire    stateout_r; 
wire    [1:0] pathout_r; 
wire    s1match_a; 
wire    s2match_a; 
wire    destmatch_a; 
wire    [OPERAND_MSB:0] i_item_nxt; 
reg     [OPERAND_MSB:0] i_item_r; 
wire    [1:0] i_path_nxt;
reg     [1:0] i_path_r; 
wire    i_state_nxt; 
reg     i_state_r;
 
//  Comparisons with s1, s2 and dest.
//
assign s1match_a = ((s1a == i_item_r) & (i_state_r == 1'b 1)) ? 1'b 1 : 
       1'b 0;
   
assign s2match_a = ((s2a == i_item_r) & (i_state_r == 1'b 1)) ? 1'b 1 : 
       1'b 0;
   
assign destmatch_a = ((dest == i_item_r) & (i_state_r == 1'b 1)) ? 1'b 1 :
       1'b 0; 

//  The actual item store
//
always @(posedge clk or posedge rst_a)
   begin : scorreg_sync_PROC
   if (rst_a == 1'b 1)
      begin
      i_item_r <= {(OPERAND_WIDTH){1'b 0}};        
      end
   else
      begin
      i_item_r <= i_item_nxt;        
      end
   end

//  state of item:   i_state_r '1' -> full or '0' -> empty
//     
always @(posedge clk or posedge rst_a)
   begin : statereg_sync_PROC
   if (rst_a == 1'b 1)
      begin
      i_state_r <= 1'b 0;        
      end
   else
      begin
      i_state_r <= i_state_nxt;        
      end
   end

//  Path type for item.
// 
//  It is a two bit wide value. Each code stands for a different
//  memory path, as defined in the package arcutil.
//
always @(posedge clk or posedge rst_a)
   begin : pathreg_sync_PROC
   if (rst_a == 1'b 1)
      begin
      i_path_r <= {(TWO){1'b 0}};        
      end
   else
      begin
      i_path_r <= i_path_nxt;        
      end
   end

// -------------------------------------------------------------------
//  Updating the state of this FIFO item
// -------------------------------------------------------------------
//  When the state of a FIFO item is set it means it contains data.
//  The updating mechanism has to take into account when a pop and add
//  happen at the same time and this item is the last one in the fifo.
//  There are four cases below:
//
//      1. If the item is killed due to a mispredicited compare and branch
//         then set the state to 0
//
//      2. Set the state to 1 of this FIFO item if a load is in
//         pipeline stage 2 (add = '1') and this item is empty
//         (i_state_r='0') and it is just after the last full item
//         (stateahead = '1') in the FIFO. Basically this means to
//         set the state of the first empty item to one.
// 
//      3. If a pop and add occurs at the same time the state should
//         be set to 1 if the item is full (i_state_r = '1') and the
//         item behind is empty (statein = '0'). Basically this means
//         to set the state of the last full item in the FIFO to one.
//         Because a pop occurs at the same time the last full item
//         will be empty at the end of the cycle. That is why the
//         state of the last full item is set to one.
// 
//      4. If only a pop happens this item is updated with the state
//         of the item behind it (statein) in the FIFO.
// 
//      5. If neither a pop nor an add is occuring the item keeps it
//         old state (i_state_r).
//
   
assign i_state_nxt = (kill       == 1'b 1)   ?
       1'b 0 :       ((add        == 1'b 1) &
                      (pop_a      == 1'b 0) & 
                      (i_state_r  == 1'b 0) &
                      (stateahead == 1'b 1))   ?
       1'b 1 : 
                     ((add        == 1'b 1) &
                      (pop_a      == 1'b 1) & 
                      (statein    == 1'b 0) &
                      (i_state_r  == 1'b 1))   ?
       1'b 1 : 
                     (pop_a      == 1'b 1)   ?
       statein : 
       i_state_r;

// -------------------------------------------------------------------
//  Updating the return address of this FIFO item
// -------------------------------------------------------------------
//  The updating mechanism has to take into account when a pop and add
//  happen at the same time and this item is the last one in the fifo.
//  There are four cases below:
//
//      1. If the item is killed due to a mispredicited compare and branch
//         then set the item to 0
//
//      2. Add destination address (dest) of a load in pipeline
//         stage 2 (add = '1') to this FIFO item if this item is empty
//         (i_state_r='0') and it is just after the last full item
//         (stateahead = '1') in the FIFO. Basically this means to
//         add it to the first empty item in the FIFO.
// 
//      3. If a pop and add occurs at the same time the destination
//         address (dest) should be added to this item if it is full
//         (i_state_r = '1') and the item behind is empty
//         (statein = '0'). Basically this means to add it to the
//         last full item in the FIFO. Because a pop occurs at the
//         same time the last full item will be empty at the end of
//         the cycle. That is why the destination address should be
//         added to the last full item.
// 
//      4. If a pop happens (pop = '1') this item is updated with the
//         content of the item behind it (itemin) in the FIFO.
// 
//      5. If neither a pop or an add is occuring the item keeps it
//         old content.
   
assign i_item_nxt = (kill       == 1'b 1)   ?
       SIX_ZERO :
                    ((add        == 1'b 1) &
                     (i_state_r  == 1'b 0) & 
                     (stateahead == 1'b 1))   ?
       dest : 
                    ((add        == 1'b 1) &
                     (pop_a      == 1'b 1) & 
                     (statein    == 1'b 0) &
                     (i_state_r  == 1'b 1))   ?
       dest : 
                    (pop_a      == 1'b 1)   ?
       itemin : 
       i_item_r;

// -------------------------------------------------------------------
//  Updating the path type of this FIFO item
// -------------------------------------------------------------------
//  The updating mechanism has to take into account when a pop and
//  path add happen at the same time and this item is the last one in
//  the fifo. There are four cases below:
// 
//      1. Add the path (pathadd_a) to this FIFO item if a load is in
//         pipeline stage 3 (add_path = '1') and this item is full
//         (i_state_r = '1') and the item behind is empty
//         (statein = '0'). Basically this means to add the path type
//         to the last full item in the FIFO. This is natural because
//         the last full FIFO item was added in pipeline stage 2, but
//         the path type is not added to the same item until pipeline
//         stage 3.
// 
//      2. If a pop and add occurs at the same time the path (pathadd_a)
//         should be added to this item if it is full
//         (i_state_r = '1') and the item two locations behind this
//         item is empty (statein2 = '0'). Basically this means to add
//         it to the second last full item in the FIFO. Because a pop
//         occurs at the same time the last full item will be empty at
//         the end of the cycle. That is why the path should be added
//         to the second last full item.
// 
//      3. If a pop happens (pop = '1') this item is updated with the
//         path type of the item behind it (pathin) in the FIFO.
// 
//      4. If neither a pop or an add is occuring the item keeps it
//         old path type (i_path_r).
//
assign i_path_nxt = ((add_path  == 1'b 1) &
                     (pop_a     == 1'b 0) & 
                     (statein   == 1'b 0) &
                     (i_state_r == 1'b 1))   ? pathadd_a : 
                    ((add_path  == 1'b 1) &
                     (pop_a     == 1'b 1) & 
                     (i_state_r == 1'b 1) &
                     (statein2  == 1'b 0))   ? pathadd_a : 
                    (pop_a     == 1'b 1)   ? pathin : 
                    i_path_r;

assign itemout_r  = i_item_r; 
assign stateout_r = i_state_r; 
assign pathout_r  = i_path_r; 

endmodule // module scoritem

