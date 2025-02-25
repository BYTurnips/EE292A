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
// This file contains logic for core register internals block. This
// module handles the selection of values to be placed onto the source
// 1 and source 2 datapaths at stage 2. It also includes register
// shortcut datapaths. Shortcut control logic is contained in the rctl
// block.
// 
//=========================== Inputs to this block ===========================--
//
// clk                               System Clock
// 
// rst_a                             System Reset (Active high)
//
// currentpc_r      [PC_MSB:0]       This is the latched value of the PC which
//                                   is currently being used by stage 1 to fetch
//                                   the next instruction. 
//
// drd              [31:0]           Returning load data from the memory system.
//
// en2b                              Pipeline stage 2B enable. When this signal
//                                   is true, the instruction in stage 2b can
//                                   pass into stage 3 at the end of the cycle.
//                                   When it is false, it will hold up stage 2B
//                                   as well as stage 2 and stage 1 (pcen).                
//
// last_pc_plus_len [PC_MSB:0]       This bus contains the registered (in to
//                                   stage2b) value of the program counter plus
//                                   the length of the current instruction.
//
// loopcount_r      [LOOPCNT_MSB:0]  The loop count register.
//
// mstore2b                          This signal indicates to the actionpoint
//                                   mechanism when selected there is a valid
//                                   store instruction in stage 2b. It is
//                                   produced from decode of p2b_opcode,
//                                   p2b_subopcode and the p2b_iv signal.             
//
// p2_iw_r          [INSTR_UBND:0]   Stage 2 instruction word.    
//
// p2_s1val_tmp_r   [DATAWORD_MSB:0] This bus is used in cr_int. This signal is
//                                   used to early generate some of the values
//                                   to be placed on the source 1 in the next.
//                                   stage. This has been done for static timing
//                                   reasons.
//
//
// p2b_abs_op       [1:0]            Indicates that the instruction in stage 2B
//                                   is an ABS.
//
// p2b_arithiv                       Indicates that the ALU operation in stage
//                                   2B will be an arithmetic operation (as
//                                   opposed to logical, say)          
//
// p2b_blcc_a                        True when stage 2B contains a valid branch
//                                   & link instruction.
//
// p2b_delay_slot                    Stage 2B instruction has a delay slot. This
//                                   signal is set true when the instruction in
//                                   stage 2B uses a delay slot.  This signal
//                                   does not have an information about the
//                                   delay slot instruction itself.       
//
// p2b_iv                            Stage 2B instruction valid. This signal is
//                                   set true when the current instruction is
//                                   valid, i.e. not killed and actual
//                                   instruction data              
//
// p2b_jlcc_a                        Stage 2B contains a jump & link or branch &
//                                   link instructionn.
//
// p2b_limm                          Stage 2B contains an instruction that uses
//                                   long immediate data.             
//
// p2b_lr                            Stage 2B has a valid LR instruction in it.               
//
// p2b_neg_op                        Indicates that the instruction in stage 2B
//                                   is an NEG.           
//
// p2b_not_op                        Indicates that the instruction in stage 2B
//                                   is an logical NOT operation.
//
// p2b_pc_r         [PC_MSB:0]       The program counter value for the
//                                   instruction in stage 2B.
//
// p2b_shift_by_one_a                Used by shifting arith instructions (e.g.
//                                   ADD1) and by shifting LD/ST instructions
//                                   (e.g. LD.AS).
//                                
// p2b_shift_by_two_a                Used by shifting arith instructions (e.g.
//                                   ADD1) and by shifting LD/ST instructions
//                                   (e.g. LD.AS).
//                                
// p2b_shift_by_three_a              Used by shifting arith instructions (e.g.
//                                   ADD1) and by shifting LD/ST instructions
//                                   (e.g. LD.AS).
//                                
// p2b_shift_by_zero_a               Used by shifting arith instructions (e.g.
//                                   ADD1) and by shifting LD/ST instructions
//                                   (e.g. LD.AS).
//
// p2b_shimm_data  [12:0]            This bus carries the short immediate data
//                                   encoded on the instruction word. It is used
//                                   by coreregs when one of the source (s1a/
//                                   fs2a) registers being referenced is one of.
//                                   the short immediate registers It always
//                                   provides the region of the instruction
//                                   where the short immediate data would be
//                                   found, regardless of whether short
//                                   immediate data is being used.
//                             
// p2b_shimm_s1_a                    Operand 1 requires the short immediate data
//                                   carried in p2b_shimm_data
//                             
// p2b_shimm_s2_a                    Operand 2 requires the short immediate data
//                                   carried in p2b_shimm_data
//
// p2bint                            From int_unit. This signal indicates that
//                                   an interrupt jump instruction (fantasy
//                                   instruction) is currently in stage 2B. This
//                                   signal has a number of consequences
//                                   throughout the system, causing the
//                                   interrupt vector (int_vec) to be put into
//                                   the PC, and causing the old PC to be placed
//                                   into the pipeline in order to be stored
//                                   into the appropriate interrupt link
//                                   register.
//                                   Note that p2bint and p2b_iv are mutually
//                                   exclusive.
//
// p3res_sc         [31:0]           Equivalent to p3result but excluding the
//                                   returning load (drd) component.
//
// qd_a             [31:0]           Register file output 1.  This is the
//                                   contents of register specified in source 1
//                                   register field.
//
// qd_b             [31:0]           Register file output 2.  This is the
//                                   contents of register specified in source 2
//                                   register field.
//
// s1a              [5:0]            Source 1 register address. This is the B
//                                   field from the instruction word, sent to
//                                   the core registers and the LSU. 
// 
// s1en                              This signal is used to indicate that the
//                                   instruction in pipeline stage 2 will use
//                                   the data from the register specified by 
//                                   s1a[5:0]. This signal includes p2iv as
//                                   part of its decode.
//
// s2a              [5:0]            Source 2 register address. This is the C
//                                   field from the instruction word. This field
//                                   is also used by the host to read values
//                                   from the registers. 
//
// s2en                              This signal is used to indicate that the
//                                   instruction in pipeline stage 2 will use
//                                   the data from the register specified by 
//                                   s2a[5:0]. This signal includes p2iv as part
//                                   of its decode.               
//
//
// sc_load1                          This signal is set true when data from a
//                                   returning load is required to be shortcut
//                                   onto the stage 2B source 1 result bus. If
//                                   the 4-port register file is implemented,
//                                   the data used for the shortcut comes direct
//                                   from the memory system, this requiring an
//                                   additional input into the shortcut
//                                   multiplexer. Extension core registers can
//                                   have shortcutting banned if x_p2nosc1 is
//                                   set true at the appropriate time. Includes
//                                   both p2b_iv and p3iv.
//                                  
// sc_load2                          This signal is set true when data from a
//                                   returning load is required to be shortcut
//                                   onto the stage 2B source 2B result bus. If
//                                   the 4-port register file is implemented,
//                                   the data used for the shortcut comes direct
//                                   from the memory system, this requiring an
//                                   additional input into the shortcut muxer
//                                   Extension core registers can have
//                                   shortcutting banned if x_p2nosc2 is set
//                                   true at the appropriate time. Includes both
//                                   p2b_iv and p3iv.
//
// sc_reg1                           This signal is produced by the pipeline
//                                   control unit rctl, and is set true when an
//                                   instruction in stage 3 is going to generate
//                                   a write to the register being read by
//                                   source 1 of the instruction in stage 2B.
//                                   This is a source 1 shortcut. It is used by
//                                   the core register module to switch the
//                                   stage 3 result bus onto the stage 2B source 
//                                   1 result. Extension core registers can have
//                                   shortcutting banned if x_p2nosc1 is set
//                                   true at the appropriate time. Includes both
//                                   p2b_iv and p3iv.
//                                  
// sc_reg2                           This signal is produced by the pipeline
//                                   control unit rctl, and is set true when an
//                                   instruction in stage 3 is going to generate
//                                   a write to the register being read by
//                                   source 2B of the instruction in stage 2B.
//                                   This is a source 1 shortcut. It is used by
//                                   the core register module to switch the
//                                   stage 3 result bus onto the stage 2B source
//                                   2 result. Extension core registers can have
//                                   shortcutting banned if x_p2nosc2 is set
//                                   true at the appropriate time. Includes both
//                                   p2b_iv and p3iv.
//                                  
// wba [5:0]                         This bus carries the address of the
//                                   register to which the data on wbdata[31:0]
//                                   is to be written at the end of the cycle if
//                                   wben is true. It is produced during stage 3
//                                   and takes account of delayed load register
//                                   writeback (taking a value from the LSU),
//                                   LD/ST address writeback  (address from the 
//                                   B or C field), and normal ALU operation
//                                   destination addresses (instruction A
//                                   field).
//                                  
// wben                              This signal is the enable signal which
//                                   determines whether the data on wbdata[31:0] 
//                                   is written into the register file at stage
//                                   4. It is produced in stage 3 and takes into 
//                                   account delayed load writebacks, cancelled
//                                   instructions, and instructions which are
//                                   not to be executed due to the cc result
//                                   being false, amongst other things.                 
//
// x1data             [31:0]         Extension Source 1 Data. This is the source
//                                   1 data for alternatives not supported by
//                                   coreregs and the extension registers have
//                                   been enabled in extutil. It is forwarded
//                                   to cr_int, if a match is found for address
//                                   s1a[5:0].
//
// x2data              [31:0]        Extension Source 2 Data. This is the source
//                                   2 data for alternatives not supported by
//                                   coreregs and the extension registers have
//                                   been enabled in extutil. It is forwarded to
//                                   cr_int, if a match is found for address
//                                   s2a[5:0].
//
// x_idecode2b                       From xrctl. This signal will be true when
//                                   the extension logic detects an extension
//                                   instruction in stage 2B and is produced
//                                   from p2b_opcode[4:0] and the sub-opcodes.          
//
//========================== Output from this block ==========================--
//
// dwr               [31:0]           Data value to be stored to memory. It is
//                                    latched stval from the ARC interface. The
//                                    value is latched when en2b = '1' ie. the
//                                    pipeline is not stalled.
//
// ext_s1val         [31:0]           Extension source 1 register.  This
//                                    register is loaded with the operand data
//                                    for extensions.  The value only changes
//                                    when a valid extension instruction is in
//                                    stage 2b.
//
// ext_s2val         [31:0]           Extension source 2 register.  This
//                                    register is loaded with the operand data
//                                    for extensions.  The value only changes
//                                    when a valid extension instruction is in
//                                    stage 2b.
//
// h_rr_data         [31:0]           Data to the host port from register reads.
//                                    Also allows the debugger to read
//                                    p1iw_aligned_a[] for cache testing. Does
//                                    not include any returning load data, or
//                                    shortcuts from stage three instructions.
//
// r_wben                             Indicates that a write is to take place on
//                                    this cycle using the address on wba[] and
//                                    the data supplied on wbdata[]. It is
//                                    slightly different from the master
//                                    writeback enable signal, wben, since it
//                                    only applies to register file (r0-r31)
//                                    writes.             
//
// s1bus             [31:0]           This is the source1 bus which contains
//                                    register data, immediates, etc and short-
//                                    cut info. A pre-latch version of s1val in
//                                    fact.
//
// s1val             [31:0]           Normal source 1 register. This register
//                                    is loaded with the operand data for
//                                    basecase operations. The value only
//                                    changes when a valid basecase instruction
//                                    is in stage 2b.
//
// s2bus             [31:0]           Next normal 2 source register value.
//
// s2val             [31:0]           Normal source 2 register.  This
//                                    register is loaded with the operand data
//                                    for basecase operations.  The value only
//                                    changes when a valid basecase instruction
//                                    is in stage 2b.
//
// s2val_inverted_r                   This signal when set indicates that the
//                                    value in the s2val register has been
//                                    inverted for the current operation.
//
// stval             [31:0]           Data value to be stored to memory.
// 
//============================================================================--
//

module cr_int ( clk,             // system clock
                rst_a,           // system reset
                currentpc_r,
                drd,
                en2b,
                loopcount_r,
                mstore2b,
                last_pc_plus_len,
                p2_iw_r,
                p2b_pc_r,
                p2_s1val_tmp_r,
                p2b_abs_op,
                p2b_alu_op,
                p2b_arithiv,
                p2b_delay_slot,
                p2b_iv,
                p2b_jlcc_a,
                p2b_blcc_a,
                p2b_limm,
                p2b_lr,
                p2b_neg_op,
                p2b_not_op,
                p2b_shift_by_one_a,
                p2b_shift_by_three_a,
                p2b_shift_by_two_a,
                p2b_shift_by_zero_a,
                p2b_shimm_data,
                p2b_shimm_s1_a,
                p2b_shimm_s2_a,
                p2bint,
                p3res_sc,
                qd_a,
                qd_b,
                s1a,
                s1en,
                s2a,
                s2en,
                sc_load1,
                sc_load2,
                sc_reg1,
                sc_reg2,
                wba,
                wben,
                x1data,
                x2data,
                x_idecode2b,

                dwr,
                ext_s1val,
                ext_s2val,
                h_rr_data,
                r_wben,
                s1bus,
                s1val,
                s2bus,
                s2val,
                s2val_inverted_r,
                stval
                );

`include "arcutil_pkg_defines.v"
`include "arcutil.v"

   input                     clk;                     //  system clock
   input                     rst_a;                   //  system reset
   input  [PC_MSB:0]         currentpc_r; 
   input  [31:0]             drd; 
   input                     en2b; 
   input  [LOOPCNT_MSB:0]    loopcount_r; 
   input                     mstore2b; 
   input  [PC_MSB:0]         last_pc_plus_len; 
   input  [INSTR_UBND:0]     p2_iw_r; 
   input  [PC_MSB:0]         p2b_pc_r; 
   input  [DATAWORD_MSB:0]   p2_s1val_tmp_r; 
   input                     p2b_abs_op; 
   input  [1:0]              p2b_alu_op; 
   input                     p2b_arithiv; 
   input                     p2b_delay_slot; 
   input                     p2b_iv; 
   input                     p2b_jlcc_a; 
   input                     p2b_blcc_a; 
   input                     p2b_limm; 
   input                     p2b_lr; 
   input                     p2b_neg_op; 
   input                     p2b_not_op; 
   input                     p2b_shift_by_one_a; 
   input                     p2b_shift_by_three_a; 
   input                     p2b_shift_by_two_a; 
   input                     p2b_shift_by_zero_a; 
   input  [12:0]             p2b_shimm_data; 
   input                     p2b_shimm_s1_a; 
   input                     p2b_shimm_s2_a; 
   input                     p2bint; 
   input  [31:0]             p3res_sc; 
   input  [31:0]             qd_a; 
   input  [31:0]             qd_b; 
   input  [5:0]              s1a; 
   input                     s1en; 
   input  [5:0]              s2a; 
   input                     s2en; 
   input                     sc_load1; 
   input                     sc_load2; 
   input                     sc_reg1; 
   input                     sc_reg2; 
   input  [5:0]              wba; 
   input                     wben; 
   input  [31:0]             x1data; 
   input  [31:0]             x2data; 
   input                     x_idecode2b; 
   
   output [31:0]             dwr; 
   output [31:0]             ext_s1val; 
   output [31:0]             ext_s2val; 
   output [31:0]             h_rr_data; 
   output                    r_wben; 
   output [31:0]             s1bus; 
   output [31:0]             s1val; 
   output [31:0]             s2bus; 
   output [31:0]             s2val; 
   output                    s2val_inverted_r; 
   output [31:0]             stval; 

   wire   [31:0]             dwr; 
   wire   [31:0]             ext_s1val; 
   wire   [31:0]             ext_s2val; 
   wire   [31:0]             h_rr_data; 
   wire                      r_wben; 
   wire   [31:0]             s1bus; 
   wire   [31:0]             s1val; 
   wire   [31:0]             s2bus; 
   wire   [31:0]             s2val; 
   wire                      s2val_inverted_r; 
   wire   [31:0]             stval; 

//------------------------------------------------------------------------------
//  Local signals
//------------------------------------------------------------------------------

   wire                      i_basecase_reg1_en_a; 
   wire                      i_basecase_reg2_en_a; 
   reg   [DATAWORD_MSB:0]    i_ext_s1val_r; 
   reg   [DATAWORD_MSB:0]    i_ext_s2val_r; 
   wire                      i_extension_reg_en_a; 
   reg   [DATAWORD_MSB:0]    i_h_rr_data_a; 
   wire                      i_invert_s2val_a; 
   wire  [DATAWORD_MSB:0]    i_limm_data_r; 
   wire                      i_p2b_blcc_dslot_a; 
   wire                      i_p2b_blcc_no_dslot_a; 
   wire                      i_p2b_jlcc_dslot_a; 
   wire                      i_s1_sel_core_reg_a; 
   wire                      i_s1_sel_currentpc_a; 
   wire                      i_s1_sel_drd_a; 
   wire                      i_s1_sel_no_reg_a; 
   wire                      i_s1_sel_p2b_pc_s1val_a; 
   wire                      i_s1_sel_rlcnt_a; 
   wire                      i_s1_sel_rlimm_a; 
   wire                      i_s1_sel_sc_res_a; 
   wire                      i_s1_sel_shimm_a; 
   wire                      i_s1_sel_xdata_a; 
   wire  [DATAWORD_MSB:0]    i_s1val_nxt; 
   reg   [DATAWORD_MSB:0]    i_s1val_r; 
   wire                      i_s2_sel_core_reg_a; 
   wire                      i_s2_sel_drd_a; 
   wire                      i_s2_sel_eq_currentpc_a; 
   wire                      i_s2_sel_eq_rlcnt_a; 
   wire                      i_s2_sel_eq_rlimm_a; 
   wire                      i_s2_sel_no_reg_a; 
   wire                      i_s2_sel_sc_res_a; 
   wire                      i_s2_sel_shimm_a; 
   wire                      i_s2_sel_xdata_a; 
   wire  [DATAWORD_MSB:0]    i_s2_shift1_a; 
   wire  [DATAWORD_MSB:0]    i_s2_shift2_a; 
   wire  [DATAWORD_MSB:0]    i_s2_shift3_a; 
   reg                       i_s2val_inverted_r; 
   wire  [DATAWORD_MSB:0]    i_s2val_nxt; 
   reg   [DATAWORD_MSB:0]    i_s2val_r; 
   wire  [DATAWORD_MSB:0]    i_s2val_shift_a; 
   wire  [DATAWORD_MSB:0]    i_s2val_tmp; 
   wire  [DATAWORD_MSB:0]    i_shimm_sext_a; 
   wire                      i_st_sel_core_reg_a; 
   wire                      i_st_sel_drd_a; 
   wire                      i_st_sel_eq_currentpc_a; 
   wire                      i_st_sel_eq_rlcnt_a; 
   wire                      i_st_sel_eq_rlimm_a; 
   wire                      i_st_sel_no_reg_a; 
   wire                      i_st_sel_sc_res_a; 
   wire                      i_st_sel_xdata_a; 
   wire  [DATAWORD_MSB:0]    i_stval_nxt; 
   reg   [DATAWORD_MSB:0]    i_stval_r; 


//------------------------------------------------------------------------------
// Stage 2 Long/Short Immediates
//------------------------------------------------------------------------------
//
   // Long immediate data is latched into the stage 2 instruction word register
   // ready for use by the stage 2b source operand muxer.
   //
   assign i_limm_data_r = p2_iw_r; 

 
   // Sign-extend the short immediate data to 32 bits
   //
   assign i_shimm_sext_a = {{(DATAWORD_MSB - SHIMM_MSB)
                             {p2b_shimm_data[SHIMM_MSB]}},
                            p2b_shimm_data[SHIMM_MSB:0]};

//------------------------------------------------------------------------------
// Source 1 value
//------------------------------------------------------------------------------
//
// Mux together the various sources for source 1 operand.
//

   // Use the current PC (stage 1) for the return address for a jump & link
   // This value will be placed into the blink register.
   //
   assign i_p2b_jlcc_dslot_a  = (p2b_jlcc_a & (p2b_delay_slot | p2b_limm)); 
   
   // Use the address of the instruction that is stage 1 as the return address
   // for a branch with delay slot.  Currrent PC cannot be used as the branch
   // has already modified it to be the branch target. This value will be placed
   // into the blink register.
   //
   assign i_p2b_blcc_dslot_a  = (p2b_blcc_a & p2b_delay_slot); 

   // Use the PC of the instruction in stage 2 if a JLcc or Blcc is in stage 2b
   // and they have no delay slot or limm data. This value will be placed into
   // the BLINK register.
   //
   assign i_p2b_blcc_no_dslot_a  = ((p2b_blcc_a | p2b_jlcc_a) &
                                   (~p2b_delay_slot)           &
                                   (~p2b_limm)); 

   // Decode source 1 register address checking for r63 (current PC)
   //
   assign i_s1_sel_currentpc_a  = ((s1a == RCURRENTPC) & (s1en == 1'b1)) ?
          1'b1 :
          1'b0;

   // Select the results generated in the previous stage.
   //
   assign i_s1_sel_p2b_pc_s1val_a = (p2b_abs_op            |
                                     p2b_neg_op            |
                                     p2b_not_op            |
                                     i_p2b_blcc_no_dslot_a |
                                     i_s1_sel_currentpc_a  |
                                     p2bint                |
                                     p2b_lr) & ~(sc_load1 | sc_reg1);

   // Decode the source 1 address, checking for r62 (long immediate data).
   //
   assign i_s1_sel_rlimm_a  = ((s1a == RLIMM) & 
                               (s1en == 1'b1) & 
                               (i_s1_sel_no_reg_a == 1'b1))? 1'b1 : 1'b0; 
   
   // Decode the source 1 address, checking for r60 (loop count).
   //
   assign i_s1_sel_rlcnt_a  = ((s1a == RLCNT)&
                               (s1en == 1'b1)&
                               (i_s1_sel_no_reg_a == 1'b1))? 1'b1 : 1'b0;

   // Select the output of the register file.
   //
   assign i_s1_sel_core_reg_a  = ((~s1a[OPERAND_MSB])  & 
                                  (~p2b_shimm_s1_a)    & 
                                  s1en               & 
                                  i_s1_sel_no_reg_a);

   // This signal is used to enable various cones of logic so that they are only
   // asserted if the current instruction is on that uses the source 1 register
   // field or uses short immediate data
   //
   assign i_s1_sel_no_reg_a  = ~(i_s1_sel_drd_a          |
                                 p2b_jlcc_a              |
                                 p2b_blcc_a              |
                                 i_s1_sel_p2b_pc_s1val_a |
                                 i_s1_sel_sc_res_a);

   // Select short cut from a load.
   //
   assign i_s1_sel_drd_a  = sc_load1; 

   // Select short cut from a ALU.
   //
   assign i_s1_sel_sc_res_a = ((~sc_load1) & (~p2bint) & sc_reg1); 

   // Select short immediate value.
   //
   assign i_s1_sel_shimm_a = (p2b_shimm_s1_a & i_s1_sel_no_reg_a); 

   // Select extension core register value.
   //
   assign i_s1_sel_xdata_a = ~(i_s1_sel_drd_a          |
                               i_s1_sel_p2b_pc_s1val_a |
                               i_p2b_jlcc_dslot_a      |
                               i_s1_sel_sc_res_a       |
                               i_s1_sel_core_reg_a     |
                               i_s1_sel_rlimm_a        |
                               i_s1_sel_rlcnt_a        |
                               i_s1_sel_shimm_a) & s1en; 
   

   // Merge all results ready for registering into stage 3.
   //
   assign i_s1val_nxt =((drd         & {(THIRTY_TWO){i_s1_sel_drd_a}})      |
                    
                        (p3res_sc    & {(THIRTY_TWO){i_s1_sel_sc_res_a}})   |
                    
                        (currentpc_r & {(THIRTY_TWO){i_p2b_jlcc_dslot_a}})  |
                    
                   (last_pc_plus_len & {(THIRTY_TWO){i_p2b_blcc_dslot_a}})  |
                    
                   (p2_s1val_tmp_r & {(THIRTY_TWO){i_s1_sel_p2b_pc_s1val_a}}) |
                    
                   (i_shimm_sext_a & {(THIRTY_TWO){i_s1_sel_shimm_a}})        |
                    
                   (qd_a             & {(THIRTY_TWO){i_s1_sel_core_reg_a}})   |
                    
                   (loopcount_r      & {(THIRTY_TWO){i_s1_sel_rlcnt_a}})      |
                    
                          (i_limm_data_r & {(THIRTY_TWO){i_s1_sel_rlimm_a}}) |
                    
                          (x1data        & {(THIRTY_TWO){i_s1_sel_xdata_a}}));

//------------------------------------------------------------------------------
// Store value.  
//------------------------------------------------------------------------------   
//
// This the dataword to be stored to memory via a ST instruction

   assign i_st_sel_no_reg_a = ~(i_st_sel_drd_a | i_st_sel_sc_res_a); 

   // Decode source 2 address field, checking for r63 (program counter).
   //
   assign i_st_sel_eq_currentpc_a = ((s2a == RCURRENTPC) &
                                     (s2en == 1'b1)      &
                                     (i_st_sel_no_reg_a == 1'b1))? 1'b1 : 1'b0;

   // Decode source 2 register addres for r62 (long immediate data limm)
   //   
   assign i_st_sel_eq_rlimm_a  = ((s2a == RLIMM) &
                                  (s2en == 1'b1) &
                                  (i_st_sel_no_reg_a == 1'b1))? 1'b1 : 1'b0; 

   // Decode source 2 register addres for r60 (loop count)
   //   
   assign i_st_sel_eq_rlcnt_a = ((s2a == RLCNT) &
                                 (s2en == 1'b1) &
                                 (i_st_sel_no_reg_a == 1'b1))? 1'b1 : 1'b0;
   
   // Decode for detecting basecase register read.
   //
   assign i_st_sel_core_reg_a  = (~s2a[OPERAND_MSB] &
                                 s2en & i_st_sel_no_reg_a);

   // Decode short-cut from load returns
   //
   assign i_st_sel_drd_a  = sc_load2; 

   // Decodec Shortcut from ALU
   //
   assign i_st_sel_sc_res_a  = (sc_reg2 & ~sc_load2); 

   // Decode for extension core register values.
   //
   assign i_st_sel_xdata_a  = (~(i_st_sel_drd_a          |
                                i_st_sel_sc_res_a        |
                                i_st_sel_core_reg_a      |
                                i_st_sel_eq_currentpc_a  |
                                i_st_sel_eq_rlimm_a      |
                                i_st_sel_eq_rlcnt_a)) & s2en; 
   
   // Merge all values for the Store value
   //
   assign i_stval_nxt = ((drd           & {(THIRTY_TWO){i_st_sel_drd_a}})      |
                    
                         (p3res_sc      & {(THIRTY_TWO){i_st_sel_sc_res_a}})   |
                    
                         (qd_b          & {(THIRTY_TWO){i_st_sel_core_reg_a}}) |
                    
                         (loopcount_r   & {(THIRTY_TWO){i_st_sel_eq_rlcnt_a}}) |
                    
                         (i_limm_data_r & {(THIRTY_TWO){i_st_sel_eq_rlimm_a}}) |
                    
                         (p2b_pc_r  & {(THIRTY_TWO){i_st_sel_eq_currentpc_a}}) |
                    
                         (x2data        & {(THIRTY_TWO){i_st_sel_xdata_a}}));

//------------------------------------------------------------------------------
// Source 2 value
//------------------------------------------------------------------------------

   // This signal enables various logic cones to allow them to be asserted only
   // when the current instruction is using the source 2 register field and not
   // short immediated data or a short-cut from a returning load is occuring.
   //
   assign i_s2_sel_no_reg_a  = ~(p2b_shimm_s2_a    |
                                 i_s2_sel_sc_res_a |
                                 i_s2_sel_drd_a); 

   
   // Decode source 2 address field checking for r63 (current program counter)
   //
   assign i_s2_sel_eq_currentpc_a = ((s2a == RCURRENTPC)
                            & (s2en == 1'b1)
                            & (i_s2_sel_no_reg_a == 1'b1))? 1'b1 : 1'b0;

   // Decode source 2 address field checking for r62 (Limm)
   //
   assign i_s2_sel_eq_rlimm_a = ((s2a == RLIMM)
                         & (s2en == 1'b1)
                         & (i_s2_sel_no_reg_a == 1'b1))? 1'b1 : 1'b0;

   // Decode source 2 address field checking for r60 (Loop count)
   //
   assign i_s2_sel_eq_rlcnt_a = ((s2a == RLCNT)
                         & (s2en == 1'b 1)
                         & (i_s2_sel_no_reg_a == 1'b1))? 1'b1 : 1'b0;

   // Decode core basecase core register reads
   //    
   assign i_s2_sel_core_reg_a  = ( (~s2a[OPERAND_MSB]) &
                                 s2en              &
                                 i_s2_sel_no_reg_a );

   // Decode for short immediate data.
   //
   assign i_s2_sel_shimm_a  = ((~(i_s2_sel_sc_res_a | i_s2_sel_drd_a)) &
                              p2b_shimm_s2_a); 

   // Short cut on returning load
   //
   assign i_s2_sel_drd_a  = (sc_load2 & (~mstore2b)); 

   // Shortcut on ALU operation.
   //  
   assign i_s2_sel_sc_res_a = (sc_reg2 & (~(mstore2b | sc_load2))); 

   // Select extension register read value.
   //
   assign i_s2_sel_xdata_a  = (~(i_s2_sel_drd_a         |
                                i_s2_sel_sc_res_a       |
                                i_s2_sel_shimm_a        |
                                i_s2_sel_core_reg_a     |
                                i_s2_sel_eq_currentpc_a |
                                i_s2_sel_eq_rlimm_a     |
                                i_s2_sel_eq_rlcnt_a)) & s2en;
 

   // Merge all data values together. This is only a temperary value, source 2
   // still requires shifting and invertion.
   //                                    
   assign i_s2val_tmp = ((drd          & {(THIRTY_TWO){i_s2_sel_drd_a}})      |

                         (p3res_sc     & {(THIRTY_TWO){i_s2_sel_sc_res_a}})   |

                         (i_shimm_sext_a & {(THIRTY_TWO){i_s2_sel_shimm_a}})  |

                         (qd_b          & {(THIRTY_TWO){i_s2_sel_core_reg_a}}) |

                         (loopcount_r   & {(THIRTY_TWO){i_s2_sel_eq_rlcnt_a}}) |

                         (i_limm_data_r & {(THIRTY_TWO){i_s2_sel_eq_rlimm_a}}) |

                         (p2b_pc_r & {(THIRTY_TWO){i_s2_sel_eq_currentpc_a}}) |

                         (x2data   & {(THIRTY_TWO){i_s2_sel_xdata_a}}));




//------------------------------------------------------------------------------
// Shift Source 2 value
//------------------------------------------------------------------------------
//   
   assign i_s2_shift1_a    = {i_s2val_tmp[DATAWORD_MSB_1:0], ONE_ZERO}; 

   assign i_s2_shift2_a    = {i_s2val_tmp[DATAWORD_MSB_2:0], TWO_ZERO}; 

   assign i_s2_shift3_a    = {i_s2val_tmp[DATAWORD_MSB_3:0], THREE_ZERO}; 

   // The add1/add2/add3/sub1/sub2/sub3 instructions are supported below for
   // both 32/16 bit instructions.
   // 
   assign i_s2val_shift_a = ((i_s2val_tmp & {(THIRTY_TWO){p2b_shift_by_zero_a}})
                        |
                        (i_s2_shift1_a & {(THIRTY_TWO){p2b_shift_by_one_a}})
                        |
                        (i_s2_shift2_a & {(THIRTY_TWO){p2b_shift_by_two_a}})
                        |
                        (i_s2_shift3_a & {(THIRTY_TWO){p2b_shift_by_three_a}}));
                        
//------------------------------------------------------------------------------
// Invert source 2 value
//------------------------------------------------------------------------------
//
   // Invert source 2 when doing a subtract operation
   //                     
   assign i_invert_s2val_a =   ((p2b_alu_op[1] & p2b_arithiv) |
                                (i_s2val_tmp[DATAWORD_MSB] & p2b_abs_op)); 

   assign i_s2val_nxt  = i_s2val_shift_a ^ {(DATAWORD_WIDTH){i_invert_s2val_a}};


//------------------------------------------------------------------------------
// The Register File Connections
//------------------------------------------------------------------------------
//
   // Only enable writes to the register file when the address points to one of
   // the registers r0-r31.
   //
   assign r_wben = (wben & (~wba[OPERAND_MSB]));

//------------------------------------------------------------------------------
// Data gating signals to save power. 
//------------------------------------------------------------------------------
//
   // Only the relevent set of registers is enabled to prevent unnecassary
   // switching of logic. There is a large adder in the bascase alu that will
   // use an ammount of power.
   //
   // The source 1 operand register is only enabled if the current instruction
   // is a valid basecase instruction or an interrupt.
   //
   assign i_basecase_reg1_en_a = (en2b & ((p2b_iv & (~x_idecode2b))
                                 | 
                                 p2bint)); 
  
   // The source 2 operand register is only enabled if the current instruction
   // is a valid basecase instruction.
   //
   assign i_basecase_reg2_en_a = (en2b & p2b_iv & (~x_idecode2b)); 

   // The extension operand register is only enabled if the current instruction
   // is a valid extension instruction.
   //
   assign i_extension_reg_en_a = (en2b & p2b_iv & x_idecode2b); 

//------------------------------------------------------------------------------
//  Stage 2 Result Registers
//------------------------------------------------------------------------------
                        
   always @(posedge clk or posedge rst_a)
    begin : stage_2b_sync_PROC
      if (rst_a == 1'b 1)
        begin
          i_stval_r          <= {(DATAWORD_WIDTH){1'b 0}};
          i_s1val_r          <= {(DATAWORD_WIDTH){1'b 0}};
          i_s2val_r          <= {(DATAWORD_WIDTH){1'b 0}};
          i_ext_s2val_r      <= {(DATAWORD_WIDTH){1'b 0}};
          i_ext_s1val_r      <= {(DATAWORD_WIDTH){1'b 0}};
          i_s2val_inverted_r <= 1'b 0;   
        end
      else
        begin

          if ((en2b & p2b_iv) == 1'b1)
            begin

              // dwr latch
              i_stval_r <= i_stval_nxt;   

            end

          if (i_basecase_reg1_en_a == 1'b1)
            begin

              // Basecase s1val 
              i_s1val_r <= i_s1val_nxt;   

            end

          if (i_basecase_reg2_en_a == 1'b1)
            begin

              // Basecase s2val
              i_s2val_r <= i_s2val_nxt;   

              i_s2val_inverted_r <= i_invert_s2val_a;   

            end
          
          if (i_extension_reg_en_a == 1'b1)
            begin

              // Extensions s1val 
              i_ext_s1val_r <= i_s1val_nxt;   

              // Extensions s2val 
              i_ext_s2val_r <= i_s2val_tmp;   

            end

        end
    end


   //  This bus carries the register file read data to the host
   //  interface.
   // 
   //  There will be a functional difference to the extent that if the 
   //  processor is halted without the pipeline being flushed, and there
   //  is an instruction stopped at stage 3, then the value which is 
   //  ready to be written to the register file will not be returned to
   //  the debugger, but the value actually stored in the register file
   //  will be used instead.
   // 
   //  Note that the ability to read from p1iw_aligned_a has been retained
   //  so that it is possible to explicity determine the value being
   //  presented from the instruction cache.
   // 
   always @(currentpc_r
            or loopcount_r 
            or i_limm_data_r 
            or qd_b 
            or s2a
            or x2data)
    begin : host_access_async_PROC
      case (s2a)
        
        //  For the contents of the register file.
        r0,  r1,  r2,  r3,  r4,  r5,  r6,  r7,
        r8,  r9,  r10, r11, r12, r13, r14, r15,
        r16, r17, r18, r19, r20, r21, r22, r23,
        r24, r25, r26, r27, r28, r29, r30, r31:
         begin
            i_h_rr_data_a = qd_b;   
         end

        //  For the contents of the loopcount register.
        RLCNT:
         begin
            i_h_rr_data_a = loopcount_r;   
         end

        //  For long immediate data.
        RLIMM:
         begin
            i_h_rr_data_a = i_limm_data_r;   
         end

        //  For the instruction currently in stage 2.
        RCURRENTPC:
         begin
            i_h_rr_data_a = {currentpc_r[PC_MSB:PC_LSB + 1], TWO_ZERO};   
         end

        //  For extensions.
        default:
         begin
            i_h_rr_data_a = x2data;   
         end
      endcase
    end

//------------------------------------------------------------------------------
// Output Drives
//------------------------------------------------------------------------------
//
// Drive outputs from internal signals

   assign dwr              = i_stval_r; 
   assign ext_s1val        = i_ext_s1val_r; 
   assign ext_s2val        = i_ext_s2val_r; 
   assign h_rr_data        = i_h_rr_data_a; 
   assign s1bus            = i_s1val_nxt; 
   assign s1val            = i_s1val_r; 
   assign s2bus            = i_s2val_nxt; 
   assign s2val            = i_s2val_r; 
   assign s2val_inverted_r = i_s2val_inverted_r; 
   assign stval            = i_stval_nxt; 

endmodule // module cr_int

