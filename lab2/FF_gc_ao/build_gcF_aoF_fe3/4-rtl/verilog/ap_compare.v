// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 2004-2012 ARC International (Unpublished)
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
module ap_compare (
    clk_debug,
    en_debug_r, 
    rst_a, 
    p2_currentpc_r, 
    kill_p2_a,
    p2_iw_r,        
    mc_addr, 
    dwr, 
    drd, 
    aux_addr, 
    aux_dataw, 
    aux_datar, 
    ap_param0, 
    ap_param1, 
    en,
    p2iv, 
    mload, 
    mstore, 
    ldvalid, 
    aux_read_core_a, 
    aux_write_core_a, 
    ap_param0_read, 
    ap_param0_write, 
    ap_param1_read, 
    ap_param1_write, 
    ap_control_r, 
    ap_value_r, 
    ap_mask_r, 
    p2b_jmp_holdup_a,       
    ap_hit_a, 
    ap_hit_value_a);

`include "arcutil_pkg_defines.v"
`include "arcutil.v"
`include "extutil.v"
`include "xdefs.v"

   // Global system signals 
   //
   // System clock
   input                        clk_debug;
   
   // enable Debug
   input                        en_debug_r;
   
   // System reset
   input                        rst_a;
   
   // Actionpoint targets
   // architectural PC
   // pre-aligner instruction word
   input    [PC_MSB:0]          p2_currentpc_r;
   
   // core control signals
   input                        kill_p2_a;
   
   // jmp stall in stage 2b
   input                        p2b_jmp_holdup_a;

   input    [INSTR_UBND:0]      p2_iw_r; 
   // mem access addr
   input    [DATAWORD_MSB:0]    mc_addr; 
   // mem access write data
   input    [DATAWORD_MSB:0]    dwr; 
   // mem access read data
   input    [DATAWORD_MSB:0]    drd; 
   // aux access addr
   input    [DATAWORD_MSB:0]    aux_addr; 
   // aux access write data
   input    [DATAWORD_MSB:0]    aux_dataw; 
   // aux access read data
   input    [DATAWORD_MSB:0]    aux_datar; 
   // external parameter 0
   input    [DATAWORD_MSB:0]    ap_param0; 
   // external parameter 1
   input    [DATAWORD_MSB:0]    ap_param1; 
   // Actionpoint qualifiers
   //
   // global qualifier
   input                        en;
   // for p2_currentpc_r
   input                        p2iv; 
   // for mc_addr
   input                        mload; 
   // for mc_addr, dwr
   input                        mstore; 
   // for drd
   input                        ldvalid; 
   // for aux_addr, aux_datar
   input                        aux_read_core_a; 
   // for aux_addr, aux_dataw
   input                        aux_write_core_a; 
   // for ap_param0
   input                        ap_param0_read; 
   // for ap_param0
   input                        ap_param0_write; 
   // for ap_param1
   input                        ap_param1_read; 
   // for ap_param1
   input                        ap_param1_write; 
   // Control bits for this actionpoint
   input    [AP_AC_SIZE-1:0]    ap_control_r; 
   // Compare bits for this actionpoint
   input    [31:0]              ap_value_r; 
   // Mask bits for this actionpoint
   input    [31:0]              ap_mask_r; 
   
   // Indicates an actionpoint hit
   output                       ap_hit_a; 
   // Indicates what value caused hit
   output   [31:0]              ap_hit_value_a; 

   wire                         ap_hit_a;
   wire     [31:0]              ap_hit_value_a;

   // Main mux selector and actions from control register
   wire     [2:0]               i_target_sel_a; 
   wire                         i_read_check_a;
   wire                         i_write_check_a;
   wire                         i_invert_range_a;
   wire                         i_ld_ret_sr_en_a;
   
   // The output of the main mux
   reg      [31:0]              i_target_a; 
   // The qualifier for the selected target
   reg                          i_target_qual_a; 
   //
   // Signals to decouple aux targets by one cycle to
   // prevent timing loops
   reg      [31:0]              i_aux_target_nxt;
   reg                          i_aux_target_qual_nxt;
   reg      [31:0]              i_aux_target_r;
   reg                          i_aux_target_qual_r;

   reg      [31:0]              i_ldst_target_nxt;
   reg                          i_ldst_target_qual_nxt;   
   reg      [31:0]              i_ldst_target_r;
   reg                          i_ldst_target_qual_r;

   assign i_target_sel_a      = ap_control_r[2:0] ;
   assign i_write_check_a     = ap_control_r[4] ;
   assign i_read_check_a      = ap_control_r[5] ;
   assign i_invert_range_a    = ap_control_r[6];

   assign i_ld_ret_sr_en_a    = (i_target_sel_a == 3'b011 &
                                 i_read_check_a == 1'b1) 
//                 |
//                 i_aux_target_qual_r == 1'b1                                 
                                 ? 1'b1: 1'b0;
                                                
// The main mux that selects and qualifies the target
   always @(i_target_sel_a or p2_iw_r or p2_currentpc_r or p2iv or mc_addr or 
            mload or i_read_check_a or mstore or i_write_check_a or dwr or drd or 
            aux_addr or aux_read_core_a or aux_write_core_a or aux_dataw or kill_p2_a or 
            aux_datar or ap_param0 or ap_param0_read or ap_param0_write or 
            ap_param1 or ap_param1_read or ap_param1_write or ldvalid or  p2b_jmp_holdup_a or 
            i_aux_target_qual_r or i_aux_target_r or i_ldst_target_r or i_ldst_target_qual_r)
   begin : sel_PROC
    // Assign the defaults for the aux delay registers but not
    // in the min_features case because we are only monitoring
    // aux_addr which doesn't case a timing loop
    i_aux_target_nxt = 32'h00000000;
    i_aux_target_qual_nxt = 1'b0;

    i_ldst_target_nxt = 32'b00000000;
    i_ldst_target_qual_nxt = 1'b0;
      
      // select the target that is to be used in the comparison
      // not quite a simple mux because checking for read or write implies
      // different buses when talking about data
      i_target_a = p2_currentpc_r;
      i_target_qual_a = 1'b0;
      case (i_target_sel_a)
         3'b000 :
                  begin
                     // ifetch address
                     i_target_a = p2_currentpc_r ; 
                     i_target_qual_a = p2iv & i_read_check_a & ~kill_p2_a & ~p2b_jmp_holdup_a; 
                  end
//         3'b001 :
//                  begin
//                     // ifetch data (instruction)
//                     i_target_a = p2_iw_r ; 
//                     i_target_qual_a = p2iv & i_read_check_a & ~kill_p2_a & ~p2b_jmp_holdup_a; 
//                  end
         3'b010 :
                  begin
                     // LD/ST address
                     i_ldst_target_nxt = mc_addr; 
                     i_ldst_target_qual_nxt = (mload & i_read_check_a) | (mstore & i_write_check_a) ; 
                  end
//         3'b011 :
//                  begin
//                     // LD/ST data
//                     // when both read and write selected for data, 
//                     //write has priority
//                     if ((i_write_check_a == 1'b1) & mstore)
//                        i_ldst_target_nxt = dwr ;
//                     else
//                        i_ldst_target_nxt = drd ;
//                     i_ldst_target_qual_nxt = (ldvalid & i_read_check_a) |
//                                              (mstore & i_write_check_a) ; 
//                  end
         3'b100 :
                  begin
                     // Aux reg address
                     i_aux_target_nxt = aux_addr ; 
                     i_aux_target_qual_nxt = (aux_read_core_a & i_read_check_a)| 
                     (aux_write_core_a & i_write_check_a) ; 
                  end
//         3'b101 :
//                  begin
//                     // Aux reg data
//                     // when both read and write selected for data, 
//                     // write has priority
//                     if ((i_write_check_a == 1'b1) & aux_write_core_a)
//                        i_aux_target_nxt = aux_dataw ;
//                     else
//                        i_aux_target_nxt = aux_datar ;
//                        i_aux_target_qual_nxt = (aux_write_core_a & i_write_check_a) |
//                                                (aux_read_core_a & i_read_check_a);
//                  end
//         3'b110 :
//                  begin
//                     // Extern param 0
//                     i_target_a = ap_param0 ; 
//                     i_target_qual_a = (ap_param0_read & i_read_check_a) | 
//                     (ap_param0_write & i_write_check_a) ; 
//                  end
         default :
                                  begin
//                     // Extern param 1
//                     i_target_a = ap_param1 ; 
//                     i_target_qual_a = (ap_param1_read & i_read_check_a) | 
//                     (ap_param1_write & i_write_check_a) ;    
                                  end
      endcase 


      // Aux stuff has to be delayed by one cycle to avoid timing loops
      // (because an actionpoint hit modifies the H flag in DEBUG which feeds
      // through to aux_datar). If there was an aux hit last cycle then use that
      // target value.

      if (i_aux_target_qual_r == 1'b1)
      begin
         i_target_a = i_aux_target_r;
         i_target_qual_a = 1'b1;
      end
      else if (i_ldst_target_qual_r == 1'b1)
      begin
         i_target_a = i_ldst_target_r;
         i_target_qual_a = 1'b1;
      end      
      
   end 

      always @(posedge clk_debug or posedge rst_a)
      begin : ap_ldst_sync_PROC
              if (rst_a == 1'b1)
              begin
                  i_ldst_target_r <= {AP_AMV_SIZE{1'b0}};
                  i_ldst_target_qual_r <= 1'b0;
              end
              else
              begin
                  i_ldst_target_r <= i_ldst_target_nxt;
                  i_ldst_target_qual_r <= i_ldst_target_qual_nxt;
              end
      end
		   
      always @(posedge clk_debug or posedge rst_a)
      begin : ap_aux_sync_PROC
                if (rst_a == 1'b1)
                begin
                    i_aux_target_r <= {AP_AMV_SIZE{1'b0}};
                    i_aux_target_qual_r <= 1'b0;
                end
                else
                begin
                    i_aux_target_r <= i_aux_target_nxt;
                    i_aux_target_qual_r <= i_aux_target_qual_nxt;
                end
      end

   // combine hit signals
   assign ap_hit_a = (en | i_ld_ret_sr_en_a | (~i_target_sel_a[2] & ~i_target_sel_a[1])) & en_debug_r &
                       (i_target_qual_a & (i_invert_range_a ^ (&(~((i_target_a | ap_mask_r) ^ (ap_value_r | ap_mask_r)))))) ;
                       
   assign ap_hit_value_a = i_target_a;

                         
endmodule
