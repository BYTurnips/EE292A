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
// This file contains the placeholder for the extension control logic.
//
// 
// This file is extension RISC control unit for :
//       Single-cycle Barrel Shifter Instructions
//       Small Score Boarded Multiply Instruction, Revision info. :  600 Architecture IP Library version 4.9.7, file revision  $Date$
//       Normalise Instruction  
//       Swap Instruction, Revision info. :  600 Architecture IP Library version 4.9.7, file revision  $Date$
// 
// 
// ========================== Inputs to this block ==========================--
// 
// ------------------------- Stage 2 - Operand fetch --------------------------
// 
//  s1en            U This signal is used to indicate to the LSU that
//                  the instruction in pipeline stage 2 will use the
//                  data from the register specified by s1a[5:0]. If
//                  the signal is not true, the LSU will ignore
//                  s1a[5:0]. This signal includes p2iv as part of its
//                  decode.
// 
//  s2en            U This signal is used to indicate to the LSU that
//                  the instruction in pipeline stage 2 will use the
//                  data from the register specified by fs2a[5:0]. If the
//                  signal is not true, the LSU will ignore fs2a[5:0]. 
//                  This signal includes p2iv as part of its decode.
// 
//  en2             U Pipeline stage 2 enable. When this signal is true,
//                  the instruction in stage 2 can pass into stage 3 at
//                  the end of the cycle. When it is false, it will hold
//                  up stage 2 and stage 1 (pcen).
//
//  dmp_holdup12    U From the debug access unit in the Data Memory
//                  Pipeline (DMP). If the debug interface is accessing
//                  the load/store memory space then this signal is set.
//                  If there is a load (LD) or store (ST) in pipeline
//                  stage 2 when dmp_holdup12 is set then pipeline stages
//                  1-2 are stalled. The reason for stalling is that the
//                  DMP is busy servicing data memory accesses from the
//                  debug interface. However if the pipeline is free from
//                  LD/ST instructions it will continue to flow even if
//                  dmp_holdup12 is set. This signal is only used in a
//                  build with memory subsystem.
//
// mload2b           U This signal indicates to the LSU that there is a valid
//                  load instruction in stage 2. It is produced from a decode
//                  of p2opcode[4:0], p2subopcode[5:0] and the p2iv signal.
//  
// mstore2b          U This signal indicates to the actionpoint mechanism when
//                  selected that there is a valid store instruction in stage
//                  2. It is produced from a decode of p2opcode[4:0],
//                  p2subopcode[5:0] and the p2iv signal.
//  
// p2_b_field_r     This is the source B address field for 32-bit
//                  instructions.
// 
// p2_c_field_r     Instruction C field. This bus carries the region of 
//                  the instruction which contains the operand C field.
//
// p2conditional    This signal is set to true when a conditionally
//                  executed instruction is detected in stage two.
//
// p2opcode[4:0]    L Opcode word. This bus contains the instruction word
//                  which is being executed by stage 2. It must be qualified
//                  by p2iv.
//
// p2iv             L Opcode valid. This signal is used to indicate that the 
//                  opcode in pipeline stage 2 is a valid instruction. The
//                  instruction may not be valid if a junk instruction has
//                  been allowed to come into the pipeline in order to allow
//                  the pipeline to continue running when an instruction 
//                  cannot be fetched by the memory controller.
//
//  s1a[5:0]        L Source 1 register address. This is the B field from
//                  the instruction word, sent to the core registers (via
//                  hostif) and the LSU. It is qualified for LSU use by
//                  s1en.
// 
//  fs2a[5:0]       L Source 2 register address. This is the C field from
//                  the instruction word, sent to the core registers and 
//                  the LSU. It is qualified for LSU use by s2en.
// 
//  p2cc[3:0]       L This bus contains the region of the instruction 
//                  which contains the four-bit condition code field. It
//                  is sent to the extension condition code test logic
//                  which provides in return a signal (xp2ccmatch) which
//                  indicates whether it considers the condition to be
//                  true. The ARC decides whether to use the internal
//                  condition-true signal or the signal provided by
//                  extensions depending on the fifth bit of the
//                  instruction. This is handled within rctl.
// 
// ----------------------------- Stage 3 - ALU --------------------------------
// 
//  p3a_field_r     Instruction A field. This bus carries the region of 
//                  the instruction which contains the operand
//                  destination field in stage 3. 
//
//  p3b_field_r     Instruction B field. This bus carries the region of 
//                  the instruction which contains the source one operand
//                  field in stage 3. 
//
//  p3c_field_r     Instruction C field. This bus carries the region of 
//                  the instruction which contains the operand C field.
//
//  p3condtrue      U This signal is produced from the result of the
//                  internal stage 3 condition code unit or from an
//                  extension cc unit (if implemented). A bit (bit 5) in
//                  the instruction selects between the internal and
//                  extension cc unit results. In addition, this signal
//                  is set true if the instruction is using short
//                  immediate data.
//                  For extensions use it should always be qualified
//                  with an instruction decode and p3iv. 
//   
//  p3iv            L Opcode valid. This signal is used to indicate 
//                  that the opcode in pipeline stage 3 is a valid
//                  instruction. The instruction may not be valid if a
//                  junk instruction has been allowed to come into the
//                  pipeline in order to allow the pipeline to continue
//                  running when an instruction cannot be fetched by the
//                  memory controller, or when an instruction has been
//                  killed.
//                  It should be noted that it is possible for a stall 
//                  condition to occur in stage 2 whilst stage 3
//                  completes. This will mean that a 'bubble' will be
//                  introduced to the pipeline. State machines should
//                  always bear in mind that if an instruction moves out
//                  of stage 3, this does not always mean that a new
//                  instruction will come into stage 3.
// 
//  en3             U Pipeline stage 3 enable. When this signal is true,
//                  the instruction in stage 3 can pass into stage 4 at
//                  the end of the cycle. When it is false, it will
//                  probably hold up stage 1 and 2 (pcen, en2), along
//                  with stage 3.
// 
//  aluflags_r[3:0] L Direct from the latches, the Z N C V flags supplied
//                  to the ALU in stage 3.
// 
//  p3cc[3:0]       L This bus contains the region of the instruction 
//                  which contains the four-bit condition code field. It
//                  is sent with the alu flags to the extension condition 
//                  code test logic which provides in return a signal
//                  (xp3ccmatch) which indicates whether it considers the
//                  condition to be true. The ARC decides whether to use
//                  the internal condition-true signal or the signal
//                  provided by extensions depending on the fifth bit of 
//                  the instruction. This is handled within rctl.
// 
// p3minoropcode    Minor opcode (sub-sub-opcode) of instruction in
//                  stage 3.
//
// p3opcode[4:0]    Opcode word. This bus contains the instruction word
//                  which is being executed by stage 3. It must be
//                  qualified by p3iv.
//
// p3setflags       This signal is used by regular alu-type instructions
//                  and the jump instruction to control whether the
//                  supplied flags get stored. It is produced from the
//                  set-flags bit in the instruction word, but if that
//                  field is not present in the instruction then it will
//                  come from the set-flag modes implied by the
//                  instruction itself, i.e. TST, RCMP or CMP.
//                  Does not include p3iv.
//
// p3subopcode      Sub-opcode word (for 32-bit instruction).
//
// p3subopcode1_r   Sub-opcode word (for 16-bit instruction).
//
// p3subopcode2_r   Sub-opcode word (for 16-bit instruction).
//
// p3_xmultic_nwb   Multi-cycle Extension write-back not allowed. When
//                  this signal is asserted no multi-cycle extension is
//                  allowed to write back. If this signal and
//                  x_multic_wben is true then the multi-cycle extension
//                  pipeline must stall.
//
//========================= Output from this block ==========================--
//
// x_idecode2       To rctl module. This signal will be true when the
//                  extension logic detects an extension instruction in
//                  stage 2 and is produced from p2opcode[4:0].
//                  It is used in conjunction with internal decode
//                  signals to produce illegal-instruction interrupts.
//
// x_idop_decode2   This signal is asserted by 'xrctl' when the extension
//                  instruction in stage 2 is dual operand.
//
// x_isop_decode2   This signal is asserted by 'xrctl' when the extension
//                  instruction in stage 2 is single operand.
//
// x_p1_rev_src     This comes from 'xrctl' and when asserted causes the
//                  the source fields to be reversed.
//
// x_p2_jump_decode This signal is asserted for extension jump
//                  instructions.
//
// x_p2nosc1        To rctl module. Indicates that the register
//                  referenced by s1a[5:0] is not available for
//                  shortcutting. This signal should only be set true
//                  when the register in question is an extension core
//                  register. This signal is ignored unless constant
//                  XT_COREREG is set true.
//
// x_p2nosc2        To rctl module. Indicates that the register
//                  referenced by fs2a[5:0] is not available for
//                  shortcutting. This signal should only be set true
//                  when the register in question is an extension core
//                  register. This signal is ignored unless constant
//                  XT_COREREG is set true.
//
// x_p2shimm_a      To rctl module. Indicates that a short immediate
//                  is used for instruction in stage 2.
//
// xholdup2         To rctl module. This signal is used to hold up
//                  pipeline stages 1 and 2 (pcen, en1 and en2) when 
//                  extension logic requires that stage 2 be held up.
//                  For example, a core register is being used as a
//                  window into SRAM, and the SRAM is not available on
//                  this cycle, as a write is taking place from stage 4,
//                  the writeback stage. Hence stage 2 must be held to
//                  allow the write to complete before the load can
//                  happen. Stages 3 and 4 will continue running.
//
// xp2ccmatch       This signal is provided by an extension condition-
//                  code unit which takes the condition code field from
//                  the instruction (at stage 2), and the alu flags
//                  (from stage 3) performs some operation on them and
//                  produces this condition true signal. Another bit in
//                  the instruction word indicates to the ARC whether it
//                  should use the internal condition-true signal or
//                  this one provided by the extension logic. This
//                  technique will allow extra branch/jump conditions to
//                  be added which may be specific to different
//                  implementations of the ARC.
//
// xp2idest         To rctl module. This signal is used to indicate
//                  that the instruction in stage 2 will not actually
//                  write back to the register specifed in the A field.
//                  This is used with extension instructions which write
//                  to FifOs using the destination register to carry the
//                  co-pro register number. It has the effect of
//                  preventing the scoreboard unit from looking at the
//                  destination register by clearing the desten signal.
//                  It will only take effect when the top bit of the
//                  instruction opcode field is set, indicating that it
//                  is an extension instruction.
//
// x_flgen          Extension basecase flag update. This signal is true
//                  when any extension wants to update the basecase
//                  flags.
//
// x_multic_wba     Multi-cycle extension writeback address. This signal
//                  is the writeback address for the instruction
//                  asserting the x_multic_wben signal.
//
// x_multic_wben    Multi-cycle extension writeback enable. This signal
//                  is true when the multi-cycle instruction wants to
//                  write-back. It should have been qualified with p3iv,
//                  and p3condtrue and the extension  opcode. If any
//                  other instruction requires a write back at the same
//                  time this signal is true the ARCompact pipeline will
//                  stall and the multi-cycle extension will write back.
//
// x_snglec_wben    Single-cycle extension writeback enable. This signal
//                  is true when the multi-cycle instruction wants to
//                  write-back. It should have been qualified with p3iv,
//                  and p3condtrue and the extension  opcode. If any
//                  other instruction requires a write back at the same
//                  time this signal is true the ARCompact pipeline will
//                  stall and the multi-cycle extension will write back.
//
// ==========================================================================--
//
module xrctl (clk,
              rst_a,
              en,
              s1en,
              s2en,
   code_stall_ldst,
              mulatwork_r,
              ivalid_aligned,
              en2,
              p2_a_field_r,
              p2_b_field_r,
              p2_c_field_r,
              p2bch,
              p2cc,
              p2conditional,
              p2format,
              p2iv,
              p2minoropcode,  
              p2opcode,
              p2sleep_inst,
              p2setflags,
              p2st,
              p2subopcode,
              p2subopcode1_r,
              p2subopcode2_r,
              p2subopcode3_r,
              p2subopcode4_r,
              p2subopcode5_r,
              p2subopcode6_r,
              p2subopcode7_r,
              en2b,
              mload2b,
              mstore2b,
              p2bint,
              p2b_a_field_r,
              p2b_b_field_r,
              p2b_c_field_r,
              p2b_bch,
              p2b_cc,
              p2b_conditional,
              p2b_format,
              p2b_iv,
              p2b_minoropcode,
              p2b_opcode,
              p2b_setflags,
              p2b_st,
              p2b_subopcode,
              p2b_subopcode1_r,
              p2b_subopcode2_r,
              p2b_subopcode3_r,
              p2b_subopcode4_r,
              p2b_subopcode5_r,
              p2b_subopcode6_r,
              p2b_subopcode7_r,
              dmp_holdup12,
              fs2a,
              s1a,
              s1bus,
              s2bus,
              sc_reg1,
              sc_reg2,
              ext_s2val,
              s2val,
              p3a_field_r,
              p3b_field_r,
              p3c_field_r,
              p3condtrue,
              p3format,  
              p3iv,
              p3destlimm,
              p3minoropcode,  
              p3opcode,
              p3setflags,
              p3subopcode,
              p3subopcode1_r,
              p3subopcode2_r,
              p3subopcode3_r,
              p3wb_en,
              p3wba,
              en3,
              p3cc,
              dest,
              desten,
              aluflags_r,
              p3lr,
              p3sr,
              aux_addr,
              kill_p1_a,
              kill_p2_a,
              kill_p2b_a,
              kill_p3_a,
              p3_xmultic_nwb,
              ux_p2nosc1,
              ux_p2nosc2,
              uxp2ccmatch,
              uxp2bccmatch,
              uxp3ccmatch,
              uxholdup2,
              uxholdup2b,
              uxholdup3,
              uxnwb,
              uxp2idest,
              uxsetflags,
              ux_isop_decode2,
              ux_idop_decode2,
              ux_izop_decode2,
              ux_flgen,
              ux_p1_rev_src,
              ux_multic_wba,
              ux_multic_wben,
              ux_multic_busy,
              ux_p2_bfield_wb_a,
              ux_p2_jump_decode,
              ux_snglec_wben,

              barrel_type_r,
              x_p3_brl_decode_16_r,
              x_p3_brl_decode_32_r,
              x_p3_norm_decode_r,
              x_p3_snorm_decode_r,
              x_p3_swap_decode_r,
              p2dop32_inst,
              p2sop32_inst,
              p2zop32_inst,
              p2dop16_inst,
              p2sop16_inst,
              p2zop16_inst,
              p2b_dop32_inst,
              p2b_sop32_inst,
              p2b_zop32_inst,
              p2b_dop16_inst,
              p2b_sop16_inst,
              p2b_zop16_inst,
              p3dop32_inst,
              p3sop32_inst,
              p3zop32_inst,
              p3dop16_inst,
              p3sop16_inst,
              p3zop16_inst,
              x_p1_rev_src,
              xholdup2,
              xholdup2b,
              xp2idest,
              x_flgen,
              x_idecode2,
              x_idecode2b,
              x_isop_decode2,
              x_idop_decode2,
              x_izop_decode2,
              x_multic_wba,
              x_multic_wben,
              x_multic_busy,
              x_p2_bfield_wb_a,
              xp2ccmatch,
              xp2bccmatch,
              x_p2nosc1,
              x_p2nosc2,
              x_p2shimm_a,
              x_p2_jump_decode,
              x_p2b_jump_decode,
              x_snglec_wben,
              xsetflags,
              xp3ccmatch,
              xholdup3,
              x_idecode3,
              x_set_sflag,
              xnwb);

`include "arcutil_pkg_defines.v" 
`include "arcutil.v"        
`include "asmutil.v"
`include "extutil.v"         
`include "xdefs.v"       
//Extra include files required for extensions are inserted here.

   input         clk;  // system clock
   input         rst_a; //  system reset
   input         en;  //  system go
   input         s1en; 
   input         s2en;
   
   //Signals required for extensions are inserted here. The automatic
   //hierarchy generation system can be used to create the structural
   //HDL to tie all the components together, provided that certain
   //naming and usage rules are followed. Please see the document
   //'Automatic Hierarchy Generator' - $ARCHOME/arc/docs/hiergen.pdf
   
   input   code_stall_ldst; 
   input         mulatwork_r;
   input         ivalid_aligned;
   input         en2;
   input   [5:0] p2_a_field_r; 
   input   [5:0] p2_b_field_r;
   input   [5:0] p2_c_field_r;
   input         p2bch;
   input   [3:0] p2cc; 
   input         p2conditional;
   input   [1:0] p2format; 
   input         p2iv; 
   input   [5:0] p2minoropcode; 
   input   [4:0] p2opcode; 
   input         p2sleep_inst;
   input         p2setflags;
   input         p2st;
   input   [5:0] p2subopcode; 
   input   [1:0] p2subopcode1_r; 
   input   [4:0] p2subopcode2_r; 
   input   [2:0] p2subopcode3_r; 
   input         p2subopcode4_r; 
   input   [1:0] p2subopcode5_r; 
   input   [2:0] p2subopcode6_r; 
   input   [1:0] p2subopcode7_r; 
   input         en2b;
   input         mload2b;
   input         mstore2b;   
   input         p2bint;
   input   [5:0] p2b_a_field_r;
   input   [5:0] p2b_b_field_r;
   input   [5:0] p2b_c_field_r;
   input         p2b_bch;   
   input   [3:0] p2b_cc;   
   input         p2b_conditional;   
   input   [1:0] p2b_format;   
   input         p2b_iv;   
   input  [5:0]  p2b_minoropcode;   
   input  [4:0]  p2b_opcode;   
   input         p2b_setflags;   
   input         p2b_st;   
   input   [5:0] p2b_subopcode;   
   input   [1:0] p2b_subopcode1_r;   
   input   [4:0] p2b_subopcode2_r;   
   input   [2:0] p2b_subopcode3_r;   
   input         p2b_subopcode4_r;   
   input   [1:0] p2b_subopcode5_r;   
   input   [2:0] p2b_subopcode6_r;   
   input   [1:0] p2b_subopcode7_r;
   input         dmp_holdup12;
   input   [5:0] fs2a;
   input   [5:0] s1a; 
   input  [31:0] s1bus; 
   input  [31:0] s2bus;
   input         sc_reg1;
   input         sc_reg2;
   input  [31:0] ext_s2val;
   input  [31:0] s2val;
   input   [5:0] p3a_field_r; 
   input   [5:0] p3b_field_r;
   input   [5:0] p3c_field_r;
   input         p3condtrue; 
   input   [1:0] p3format; 
   input         p3iv;
   input         p3destlimm;
   input   [5:0] p3minoropcode; 
   input   [4:0] p3opcode; 
   input         p3setflags; 
   input   [5:0] p3subopcode; 
   input   [1:0] p3subopcode1_r; 
   input   [4:0] p3subopcode2_r; 
   input   [2:0] p3subopcode3_r; 
   input         p3wb_en;
   input   [5:0] p3wba;
   input         en3;
   input   [3:0] p3cc;
   input   [5:0] dest;
   input         desten;
   input   [3:0] aluflags_r;
   input         p3lr;
   input         p3sr;
   input [31:0]  aux_addr;
   input         kill_p1_a;
   input         kill_p2_a;
   input         kill_p2b_a;
   input         kill_p3_a;
   input         p3_xmultic_nwb;
   input         ux_p2nosc1;
   input         ux_p2nosc2;
   input         uxp2ccmatch;
   input         uxp2bccmatch;
   input         uxp3ccmatch;
   input         uxholdup2;
   input         uxholdup2b;
   input         uxholdup3;
   input         uxnwb;
   input         uxp2idest;
   input         uxsetflags;
   input         ux_isop_decode2;
   input         ux_idop_decode2;
   input         ux_izop_decode2;
   input         ux_flgen;
   input         ux_p1_rev_src;
   input   [5:0] ux_multic_wba;
   input         ux_multic_wben;
   input         ux_multic_busy;
   input         ux_p2_bfield_wb_a;
   input         ux_p2_jump_decode;
   input         ux_snglec_wben;

   //Signals required for extensions are inserted here. The automatic
   //hierarchy generation system can be used to create the structural
   //HDL to tie all the components together, provided that certain
   //naming and usage rules are followed. Please see the document
   //'Automatic Hierarchy Generator' - $ARCHOME/arc/docs/hiergen.pdf
   
      output  [1:0] barrel_type_r;
   output        x_p3_brl_decode_16_r;
   output        x_p3_brl_decode_32_r;  
   output        x_p3_norm_decode_r;
   output        x_p3_snorm_decode_r;
   output        x_p3_swap_decode_r;

   output        p2dop32_inst;
   output        p2sop32_inst;
   output        p2zop32_inst;
   output        p2dop16_inst;
   output        p2sop16_inst;
   output        p2zop16_inst;
   output        p2b_dop32_inst;
   output        p2b_sop32_inst;
   output        p2b_zop32_inst;
   output        p2b_dop16_inst;
   output        p2b_sop16_inst;
   output        p2b_zop16_inst;
   output        p3dop32_inst;
   output        p3sop32_inst;
   output        p3zop32_inst;
   output        p3dop16_inst;
   output        p3sop16_inst;
   output        p3zop16_inst;

   output        x_p1_rev_src;
   output        xholdup2; 
   output        xholdup2b; 
   output        xp2idest; 
   output        x_flgen; 
   output        x_idecode2; 
   output        x_idecode2b; 
   output        x_isop_decode2; 
   output        x_idop_decode2; 
   output        x_izop_decode2; 
   output  [5:0] x_multic_wba;
   output        x_multic_wben;
   output        x_multic_busy;
                 
   output        x_p2_bfield_wb_a; 
   output        xp2ccmatch;
   output        xp2bccmatch;
   output        x_p2nosc1; 
   output        x_p2nosc2;
   output        x_p2shimm_a; 
   output        x_p2_jump_decode;
   output        x_p2b_jump_decode;
   output        x_snglec_wben;
   output        xsetflags; 
   output        xp3ccmatch; 
   output        xholdup3; 
   output        x_idecode3;
   output        x_set_sflag; 
   output        xnwb;
    
      reg     [1:0] barrel_type_r;
   reg           x_p3_brl_decode_16_r;  
   reg           x_p3_brl_decode_32_r; 
   wire          x_p3_norm_decode_r;
   wire          x_p3_snorm_decode_r;
// SWAP
   wire          x_p3_swap_decode_r;
   wire          x_p1_rev_src; 
   wire          xholdup2; 
   wire          xholdup2b; 
   wire          xp2idest; 
   wire          x_flgen; 
   wire          x_idecode2; 
   wire          x_isop_decode2; 
   wire          x_idop_decode2; 
   wire          x_izop_decode2; 
   wire    [5:0] x_multic_wba;
   wire          x_multic_wben;
   wire          x_p2_bfield_wb_a; 
   wire          xp2ccmatch; 
   wire          xp2bccmatch;
   wire          x_p2nosc1; 
   wire          x_p2nosc2; 
   wire          x_p2shimm_a; 
   wire          x_p2_jump_decode; 
   wire          x_snglec_wben;
   wire          xsetflags; 
   wire          xp3ccmatch; 
   wire          xholdup3; 
   wire          x_idecode3;
   wire          x_set_sflag; 
   wire          xnwb; 
   wire          idmp_stall12;
   wire          i_snglec_wben;
   wire          ix_idecode2; 
   reg           ix_idecode2b_r; 
   reg           ix_idecode3_r;
   wire          ix_idop_decode2; 
   wire          ix_isop_decode2; 
   wire          ix_izop_decode2;
   wire          i_x_p2shimm_decode_a;
   wire          ix_multic_wben;
   wire          ix_wb_en;

   wire          i_dop_inst;
   wire          i_sop_inst;
   wire          i_zop_inst;
   reg           i_p2dop32_inst;
   reg           i_p2sop32_inst;
   reg           i_p2zop32_inst;
   reg           i_p2dop16_inst;
   reg           i_p2sop16_inst;
   reg           i_p2zop16_inst;
   reg           i_p2b_dop32_inst;
   reg           i_p2b_sop32_inst;
   reg           i_p2b_zop32_inst;
   reg           i_p2b_dop16_inst;
   reg           i_p2b_sop16_inst;
   reg           i_p2b_zop16_inst;
   reg           i_p3dop32_inst;
   reg           i_p3sop32_inst;
   reg           i_p3zop32_inst;
   reg           i_p3dop16_inst;
   reg           i_p3sop16_inst;
   reg           i_p3zop16_inst;

// Signal declarations for extensions to be added.
   wire    [1:0] i_barrel_type_nxt;
   wire          i_p2_ext16_brl_u3_a; 
   wire          i_p2_ext16_brl_u5_a; 
   wire          i_p2_ext_brl_decode_16_a; 
   wire          i_p2_ext_brl_decode_32_a; 
   wire          i_p2_fmt_cond_reg_a; 
   wire          i_p2_fmt_s12_a; 
   wire          i_p2_op_16_alu_gen_a; 
   wire          i_p2_op_16_ssub_a;

   reg           i_p2b_ext_brl_decode_16_r;
   reg           i_p2b_ext_brl_decode_32_r;
   wire          i_p3_barrel_decode_nxt;
   reg           i_p3_barrel_decode_r;
   wire          i_p3_barrel_decode_iv_a;

   wire          i_barrel_type_sel0_a;
   wire          i_barrel_type_sel1_a;
   wire          i_barrel_type_sel2_a;
   wire          i_barrel_type_sel3_a;
// Multiply 32x32
   wire          i_s1mul_a;
   wire          i_s2mul_a;
   wire          i_p2_mul64_decode_32_a;
   wire          i_p2_mul64_decode_16_a;
   reg           i_p2b_mul64_decode_r;
   wire          i_p2b_mul64_decode_iv_a;
   wire          i_p3mul64_a;
// Normalise
//
wire             i_p2_norm_decode_a;
wire             i_p2b_norm_decode_a;
wire             i_p2b_snorm_decode_a;
reg              i_p3_norm_decode_r;
reg              i_p3_snorm_decode_r;
   wire          i_p2_swap_decode_a;
   wire          i_p2b_swap_decode_a;
   reg           i_p3_swap_decode_r;

// ===================== Extension core registers ====================--
// 
//  x_p2nosc1/x_p2nosc2 : Extension pipeline Stage 2 no shortcut on
//                        source 1/2
// 
//  These signals are set true to tell the RISC control unit that the
//  register in the source 1 (x_p2nosc1) or source 2 (x_p2nosc2) fields
//  are not allowed to take advantage of the shortcut mechanism.
//  Shortcutting would normally take place if the register on s1a or fs2a
//  matched the destination register of an instruction in stage 3
//  writing a result. 
// 
//  Shortcutting should be disabled when extension core registers have
//  been added which do not support write-through, or if the value which
//  would be read from the register is not always the value which is
//  written into it. Registers such as control registers with read-only 
//  or write-only bits, or registers less than 32 bits would all fall
//  into this latter category.
// 
//  In this case, write-through means that the value being written to a
//  register (by stage 4) is available be read by stage 2 during the
//  write cycle. If flip-flops are used for registers, then special
//  logic must be implemented to provide write-through operation.
//  
//  This signal should only be set true when the register in question is
//  an extension core register. This signal is ignored if constant
//  XT_COREREG is set false in the include file extutil.
// 
//  All unused extension core register slots should be prevented from
//  shortcutting. This statement only disables shortcutting when an
//  extensions core register slot is accessed. The signal is true when 
//  loopcount is accessed, but this has shortcutting disabled already,
//  so it is not a problem.
//
   assign x_p2nosc1 = 
// Example :       s1a == my_shortcuttable_ext_core_reg ? 1'b 0 :
//
                   ux_p2nosc1; 
//
   assign x_p2nosc2 = 
// Example :       fs2a == my_shortcuttable_ext_core_reg ? 1'b 0 :
//
                   ux_p2nosc2;

//======================== Instruction Decode ========================-- 
//
// Stage 2.
//
//  x_idecode2 : Extension instruction decoded in stage 2
//
//  This signal should be set true when an extension instruction is
//  detected in stage 2. For regular extensions instructions, this is
//  done by decoding p2opcode[4:0]. Single operand extension instructions
//  are detected by decoding the subopcode field p2minoropcode[5:0].
//
//  If an instruction in stage 2 is valid (p2iv=1) and its opcode does
//  not correspond to a basecase instruction, the RISC control unit will
//  generate an illegal instruction interrupt unless x_idecode2 is set
//  true to 'claim' the instruction in stage 2.
//
//  The x_idecode2 signal must be latched by the extensions logic when
//  the instruction is allowed to pass into stage 3, in other words,
//  when en2=1. The latched result is x_idecode3.
//
//  To add a new instruction decode, add a condition to x_idecode2 for a
//  regular extension instruction, or to x_isop_decode2 for single-
//  operand instructions.
//
//  This signal is ignored if the constant XT_ALUOP is set false in the
//  include file extutil.
//
// Dual-operand extension instruction decode 
//
   assign ix_idop_decode2 =
//
// Example :         p2opcode == OP_FMT2 &
//                   p2subopcode == my_extension
//                                                             ? 1'b 1 :
//
//  Extension instruction decodes inserted here
                             i_p2_ext_brl_decode_16_a |
                             i_p2_ext_brl_decode_32_a |
                            i_p2_mul64_decode_32_a |
                            i_p2_mul64_decode_16_a |
                          ux_idop_decode2; 

// Single-operand extension instruction decode
//
   assign ix_isop_decode2 =
//
//  Example :            p2opcode == OP_FMT2 &
//                       p2subopcode == my_sop_field
//                       p2minoropcode == my_sop_extension
//                                                             ? 1'b 1 :
// 
// Extension single-operand instructions inserted here.
                            i_p2_norm_decode_a |
                         i_p2_swap_decode_a |
                         ux_isop_decode2; 

// Zero-operand extension instruction decode
//
   assign ix_izop_decode2 =
                         ux_izop_decode2; 

//  Combine regular and single-operand instruction decodes.
// 
   assign ix_idecode2 = ix_idop_decode2 | ix_isop_decode2 | ix_izop_decode2; 
   assign x_idecode2 = ix_idecode2; 
   assign x_isop_decode2 = ix_isop_decode2; 
   assign x_izop_decode2 = ix_izop_decode2; 
   assign x_idop_decode2 = ix_idop_decode2; 

   assign p2sop32_inst = i_p2sop32_inst; 
   assign p2zop32_inst = i_p2zop32_inst; 
   assign p2dop32_inst = i_p2dop32_inst; 
   assign p2sop16_inst = i_p2sop16_inst; 
   assign p2zop16_inst = i_p2zop16_inst; 
   assign p2dop16_inst = i_p2dop16_inst; 

// decode for 32-bits dual, single, and zero operand extension instructions
always @(p2iv or p2opcode or p2subopcode or p2minoropcode)
  begin : P2INST32_ASYNC_PROC
     i_p2zop32_inst = 1'b0;
     i_p2sop32_inst = 1'b0;
     i_p2dop32_inst = 1'b0;
  if (p2iv==1)
    begin
       if ((p2opcode==OP_FMT4) || (p2opcode==OP_FMT3))
         begin
            if (p2subopcode==SO_SOP)
              begin
                 if (p2minoropcode==MO_ZOP)
                   begin
                      //a valid 32-bits zero operand extension instruction enters into stage-2
                      i_p2zop32_inst = 1'b1;
                   end
                 else
                   begin
                      //a valid 32-bits single operand extension instruction enters into stage-2
                      i_p2sop32_inst = 1'b1;
                   end
              end
            else
              begin
                 //a valid 32-bits dual operand extension instruction enters into stage-2
                 i_p2dop32_inst = 1'b1;
              end
         end
    end
  end
                 
// decode for 16-bits dual, single, and zero operand extension instructions
always @(p2iv or p2opcode or p2subopcode2_r or p2subopcode3_r)
  begin : P2INST16_ASYNC_PROC
     i_p2zop16_inst = 1'b0;
     i_p2sop16_inst = 1'b0;
     i_p2dop16_inst = 1'b0;
     if (p2iv==1'b1)
       begin
          if ((p2opcode==OP_16_FMT3) || (p2opcode==OP_16_FMT4))
            begin
               if (p2subopcode2_r==SO16_SOP)
                 begin
                    if (p2subopcode3_r==SO16_SOP_ZOP)
                      begin
                         //a valid 16-bits zero operand extension instruction enters into stage-2
                         i_p2zop16_inst = 1'b1;
                      end
                    else
                      begin
                         //a valid 16-bits single operand extension instruction enters into stage-2
                         i_p2sop16_inst = 1'b1;
                      end
                 end
               else
                 begin
                    //a valid 16-bits dual operand extension instruction enters into stage-2
                    i_p2dop16_inst = 1'b1;
                 end
            end
       end
  end
     
//==================== Register File Access Stage ====================-- 
//
//   
   assign p2b_sop32_inst = i_p2b_sop32_inst; 
   assign p2b_zop32_inst = i_p2b_zop32_inst; 
   assign p2b_dop32_inst = i_p2b_dop32_inst; 
   assign p2b_sop16_inst = i_p2b_sop16_inst; 
   assign p2b_zop16_inst = i_p2b_zop16_inst; 
   assign p2b_dop16_inst = i_p2b_dop16_inst; 

// decode for 32-bits dual, single, and zero operand extension instructions
always @(p2b_iv or p2b_opcode or p2b_subopcode or p2b_minoropcode)
  begin : P2B_INST32_ASYNC_PROC
     i_p2b_zop32_inst = 1'b0;
     i_p2b_sop32_inst = 1'b0;
     i_p2b_dop32_inst = 1'b0;
  if (p2b_iv==1)
    begin
       if ((p2b_opcode==OP_FMT4) || (p2b_opcode==OP_FMT3))
         begin
            if (p2b_subopcode==SO_SOP)
              begin
                 if (p2b_minoropcode==MO_ZOP)
                   begin
                      //a valid 32-bits zero operand extension instruction enters into stage-2
                      i_p2b_zop32_inst = 1'b1;
                   end
                 else
                   begin
                      //a valid 32-bits single operand extension instruction enters into stage-2
                      i_p2b_sop32_inst = 1'b1;
                   end
              end
            else
              begin
                 //a valid 32-bits dual operand extension instruction enters into stage-2
                 i_p2b_dop32_inst = 1'b1;
              end
         end
    end
  end
                 
// decode for 16-bits dual, single, and zero operand extension instructions
always @(p2b_iv or p2b_opcode or p2b_subopcode2_r or p2b_subopcode3_r)
  begin : P2B_INST16_ASYNC_PROC
     i_p2b_zop16_inst = 1'b0;
     i_p2b_sop16_inst = 1'b0;
     i_p2b_dop16_inst = 1'b0;
     if (p2b_iv==1'b1)
       begin
          if ((p2b_opcode==OP_16_FMT3) || (p2b_opcode==OP_16_FMT4))
            begin
               if (p2b_subopcode2_r==SO16_SOP)
                 begin
                    if (p2b_subopcode3_r==SO16_SOP_ZOP)
                      begin
                         //a valid 16-bits zero operand extension instruction enters into stage-2
                         i_p2b_zop16_inst = 1'b1;
                      end
                    else
                      begin
                         //a valid 16-bits single operand extension instruction enters into stage-2
                         i_p2b_sop16_inst = 1'b1;
                      end
                 end
               else
                 begin
                    //a valid 16-bits dual operand extension instruction enters into stage-2
                    i_p2b_dop16_inst = 1'b1;
                 end
            end
       end
  end
     
//===================== sshimm and ushimm  Decode =====================--
//
//
// i_x_p2shimm_decode_a : Decoding of shimm type instruction in stage 2
//                        This signal is used to reduce logic as many extensions
//                        will use this signal.
    
   assign i_x_p2shimm_decode_a = ((p2format == FMT_U6)  |
                                  (p2format == FMT_S12) |
                                  ((p2format == FMT_COND_U6) &
                                   (p2_a_field_r[AOP_UBND] == 1'b 1))) ? 1'b 1 : 1'b 0;
                               
// x_p2shimm_a : Extension instruction in stage 2 is using the shimm
//               field.
//
   assign x_p2shimm_a =
                        //32-bit types
                        ((i_p2_ext_brl_decode_32_a == 1'b 1) &
                         (i_x_p2shimm_decode_a == 1'b 1 )) |
                        //16-bit types
                        (i_p2_ext16_brl_u3_a == 1'b 1) | 
                        (i_p2_ext16_brl_u5_a == 1'b 1) |
                        (i_p2_mul64_decode_32_a & i_x_p2shimm_decode_a) |
                        (i_p2_norm_decode_a & i_x_p2shimm_decode_a) |
                     (i_p2_swap_decode_a & i_x_p2shimm_decode_a) |
       (ux_idop_decode2 | 
        ux_isop_decode2 | 
        ux_izop_decode2) & 
       i_x_p2shimm_decode_a;

//======================= B-field Writeback Decode =========================--
//
// x_p2field_wben_a : Extension instruction in stage 2 is using the B-field
// as destination address for writeback.
//
   assign x_p2_bfield_wb_a =
                         (i_p2_ext_brl_decode_16_a &
                          (i_p2_op_16_alu_gen_a | i_p2_op_16_ssub_a)) | 
                         (i_p2_ext_brl_decode_32_a &
                          (i_p2_fmt_cond_reg_a | i_p2_fmt_s12_a))     | 
                            i_p2_norm_decode_a |
                         i_p2_swap_decode_a |
       ux_p2_bfield_wb_a;
  
// ======================== Instruction Execute =======================--
//
// 
//  Stage 3.
//  
//  x_idecode3 : Extension instruction decoded in stage 3.
// 
//  This signal is latched from x_idecode2, which is decoded from
//  p2opcode/p2subopcode at stage 2 (see above).
// 
//  It should be noted that if the instruction latches any data itself
//  in stage 3, then p3iv, p3condtrue and en3 should be combined to
//  generate the flip-flop enable signal. This will prevent junk data
//  being latched by stalled intructions, killed instructions or long 
//  immediate data words passing through the pipeline.
// 
//  When this signal is set true, the RISC control unit assumes that 
//  the instruction in stage 3 is a standard ALU-type extension
//  instruction unless any of the special control signals xnwb, 
//  x_p2shimm_a, xsetflags or xholdup3 are set to tell it
//  different.
// 
//  As the instruction is an extension, the RISC control unit will use
//  the 32-bit ALU result and flags provided by the extensions logic.
//  Instruction completion, writeback and flag setting are still
//  controlled by the RISC control unit, but when an extension
//  instruction is in stage 3, the values used will be provided by
//  extension logic and placed on the xresult and xflags buses.
// 
//  This signal is ignored if the constant XT_ALUOP is set false in the
//  include file extutil.
//
//  If extensions are being decoded onto x_idecode2, a flip-flop is
//  placed here to latch x_idecode2 on the clock edge, enabled by en2=1.
//  Otherwise x_idecode3 is set to zero.
//
// 


always @(posedge clk or posedge rst_a)
   begin : P2B_DECODE_PROC
   if (rst_a == 1'b 1)
      begin
      ix_idecode2b_r <= 1'b 0; 
      end
   else
      begin
      if (en2 == 1'b 1)
         begin
         ix_idecode2b_r <= ix_idecode2;    
         end
      end
   end

assign x_idecode2b = ix_idecode2b_r;

always @(posedge clk or posedge rst_a)
   begin : P3_DECODE_PROC
   if (rst_a == 1'b 1)
      begin
      ix_idecode3_r <= 1'b 0; 
      end
   else
      begin
      if (en2b == 1'b 1)
         begin
         ix_idecode3_r <= ix_idecode2b_r;    
         end
      end
   end

assign i_snglec_wben = ix_idecode3_r;

assign x_idecode3    = ix_idecode3_r;


// decode for 32-bits dual, single, and zero operand extension instructions

   assign p3dop32_inst = i_p3dop32_inst ;
   assign p3sop32_inst = i_p3sop32_inst ;
   assign p3zop32_inst = i_p3zop32_inst ;
   assign p3dop16_inst = i_p3dop16_inst ;
   assign p3sop16_inst = i_p3sop16_inst ;
   assign p3zop16_inst = i_p3zop16_inst ;

always @(p3iv or p3condtrue or p3opcode or p3subopcode or p3minoropcode)
  begin : P3INST32_ASYNC_PROC
     i_p3zop32_inst = 1'b0;
     i_p3sop32_inst = 1'b0;
     i_p3dop32_inst = 1'b0;
     if ((p3iv==1'b1) && (p3condtrue==1'b1))
       begin
          if ((p3opcode==OP_FMT3) || (p3opcode==OP_FMT4))
            begin
               if (p3subopcode==SO_SOP)
                 begin
                    if (p3minoropcode==MO_ZOP)
                      begin
                         //a valid 32-bits zero operand extension instruction enters into stage-3
                         i_p3zop32_inst = 1'b1;
                      end
                    else
                      begin
                         //a valid 32-bits single operand extension instruction enters into stage-3
                         i_p3sop32_inst = 1'b1;
                      end
                 end
               else
                 begin
                    //a valid 32-bits dual operand extension instruction enters into stage-3
                    i_p3dop32_inst = 1'b1;
                 end
            end
       end
  end

// decode for 16-bits dual, single, and zero operand extension instructions
always @(p3iv or p3opcode or p3subopcode2_r or p3subopcode3_r)
  begin : P3INST16_ASYNC_PROC
     i_p3zop16_inst = 1'b0;
     i_p3sop16_inst = 1'b0;
     i_p3dop16_inst = 1'b0;
     if (p3iv==1'b1)
       begin
          if ((p3opcode==OP_16_FMT3) || (p3opcode==OP_16_FMT4))
            begin
               if (p3subopcode2_r==SO16_SOP)
                 begin
                    if (p3subopcode3_r==SO16_SOP_ZOP)
                      begin
                         //a valid 16-bits zero operand extension instruction enters into stage-3
                         i_p3zop16_inst = 1'b1;
                      end
                    else
                      begin
                         //a valid 16-bits single operand extension instruction enters into stage-3
                         i_p3sop16_inst = 1'b1;
                      end
                 end
               else
                 begin
                    //a valid 16-bits dual operand extension instruction enters into stage-3
                    i_p3dop16_inst = 1'b1;
                 end
            end
       end
  end
   

   assign ix_wb_en   =
                    (i_p3_barrel_decode_r == 1'b 1) ?  i_snglec_wben :
                     (i_p3_norm_decode_r | i_p3_snorm_decode_r) == 1'b1 ?
                     i_snglec_wben :
                  (i_p3_swap_decode_r == 1'b1) ? i_snglec_wben :
       ux_snglec_wben;

   assign ix_multic_wben =
       ux_multic_wben;

// Multi-cycle extension writeback address. This signal is the writeback
// address for the instruction asserting the x_multic_wben signal.
//
   assign x_multic_wba =
       ux_multic_wba; 

// Multi-cycle extension instruction is busy.
// This is needed for instruction stepping.
   assign x_multic_busy =
                       ux_multic_busy;

// Multi-cycle extension writeback enable. This signal is true when the
// multi-cycle instruction wants to write-back.
//
   assign x_multic_wben = ix_multic_wben;

// The flag update signal for extensions should be qualified with p3iv
// and p3condtrue when the instruction is in stage 3.
//
   assign x_flgen = (ix_wb_en & p3setflags & en3 & p3condtrue & p3iv) |
                 (ux_flgen & (p3setflags | uxsetflags));

// Single-cycle extension writeback enable. This signal is true when the
// multi-cycle instruction wants to write-back.
//
   assign x_snglec_wben  = ix_wb_en & p3iv;

// ========================= Condition codes =========================--
//
//  xp2ccmatch/xp3ccmatch : Extension pipeline stage 2/3 condition code
//                          match
// 
//  In order to add extra condition codes to the ARC, two condition code
//  units are required - one for branches/jumps/loops in stage 2, and 
//  one for conditional instructions in stage 3.
// 
//  The function of an external condition code unit is to provide a 
//  number of true/false results - one for each extension condition. 
//  These extension condition codes do not have to be related to the ARC
//  ALU flags.
//   
//  Bit 5 of the instruction word indicates to this ARC whether it
//  should use the internal condition-true signal or this one provided
//  by the extension logic. Hence all extension condition codes are 0x10
//  -0x1f, and are defined here using only the lower four bits.
// 
//  A condition code might be defined which would be true when both an
//  external flag signal and the zero flag are set. This might be used 
//  in an algorithm to detect the presence of llamas in the upper
//  atmosphere.
// 
//  e.g. assign my_condition_true = external_flag & aluflags_r(A_Z_N);
//  
//   We can define two conditions, say, llamas and no_llamas, so we
//   may branch or jump on our newly defined condition being true or
//   false.
// 
//   The stage 2 condition code statement would look like this:
// 
// assign xp2ccmatch =  
//  Extension condition codes for stage 2 are inserted here.
// 
//                     p2cc == my_cc_llamas ? my_condition_true :
//                     p2cc == my_cc_no_llamas ? not(my_condition_true) :
//                     1'b 0;
// 
   assign xp2ccmatch = 
// Extension condition codes for stage 2 are inserted here.
    
                    uxp2ccmatch; 

   assign xp2bccmatch = 
// Extension condition codes for stage 2B are inserted here.
    
                    uxp2bccmatch; 

//  The stage 3 condition code statement would be identical, except that
//  it uses p3cc and produces xp3ccmatch.
//
// Extension condition codes for stage 3 are inserted here.
   assign xp3ccmatch =
    
                    uxp3ccmatch; 

// =================== Pipeline stall Conditions =====================--
// 
//  xholdup2 : Extension hold up stages 1 and 2.
// 
//  This signal is used to hold up pipeline stages 1 and 2, when 
//  extension logic requires that stage 2 be held up. Stages 3 and 4
//  will continue running if there are no other pipeline stall
//  conditions.
// 
//  The xholdup2 signal will typically be used to produce a stall if an 
//  extension register is not ready to provide information to an
//  instruction in stage 2. The register fetch logic in entity xcoreregs 
//  would produce a stall signal, which would be included here.
//  
//  Designers must be careful to ensure that the xholdup2 signal
//  arrives as early in the cycle as possible. It should be generated
//  from latched or early arriving signals - e.g. p2opcode, s1a, s1a,
//  s1en, s2en.
// 
//  It must not include any pipeline enable signals which it is used to
//  generate - ifetch, pcen, en1, en2, en3, aux_write, aux_read etc. -
//  or any signals generated from the above.
// 
//  This signal should be generated by ORing together multiple stall
//  signals.
// 
   assign xholdup2 =
// 
//  Example :      xcoreregs_stage2_stall |
// 
// Extension stage 2 stall conditions are inserted here.
                   uxholdup2; 

//  xholdup2b : Extension hold up stages 1, 2 and 2b..
//  This signal is used to hold up pipeline stages 1 and 2, when extension 
// logic requires that stage 2 be held up. Stages 3 and 4 will continue
// running if there are no other pipeline stall conditions.
//
//  The xholdup12 signal will typically be used to produce a stall if an 
// extension register is not ready to provide information to an instruction
// in stage 2. The register fetch logic in entity xcoreregs would produce 
// a stall signal, which would be included here.
// 
//  Designers must be careful to ensure that the xholdup2b signal arrives
// as early in the cycle as possible. It should be generated from latched
// or early arriving signals - e.g. p2b_opcode
//
//  It must not include any pipeline enable signals which it is used to
// generate - ifetch, pcen, en1, en2, en3, aux_write, aux_read etc. - or
// any signals generated from the above.
//
// This signal should be generated by ORing together multiple stall signals.
//    

   assign xholdup2b =
    //
    // Example :    xcoreregs_stage2_stall |
    //
//Extension stage 2 stall conditions are inserted here.
                    code_stall_ldst |
                      (mulatwork_r &
                       (i_s1mul_a |
                        i_s2mul_a |
                        i_p2b_mul64_decode_iv_a)) |
                   idmp_stall12 |
                    uxholdup2b;

//
// Note: That xholdup2b is true when the debug interface is accessing the
//       load/store memory space. Consequently the ARC cannot access the
//       load/store memory space. If there is a load (LD) or store (ST)
//       instruction in pipeline stage 2 then pipeline stages 1-2 needs
//       to be stalled (idmp_stall12 = '1').
//
//
//  xholdup3 : Extension hold up stage 3.
// 
//  The xholdup3 signal allows designers of extensions the ability to 
//  hold an instruction in stage 3. This might be used to wait for an 
//  operation which takes more than one cycle to complete - for example
//  a multi-cycle multiply function.
// 
//  When stage 3 is stalled, the operands being supplied on the stage 3
//  input latches (s1val, s2val, p3i, p3iv, etc.) will continue to be
//  valid until the instruction in stage 3 is allowed to complete.
// 
//  Under most circumstances, this signal will stall stages 1, 2 and 3.
//  It should be noted however that this stall signal will not
//  neccessarily stall stage 1. If stage 2 does not contain a valid
//  instruction, then the instruction being fetched in stage 1 may be
//  allowed to move into stage 2 in order to fill the blank slot.
// 
//  Designers must be careful to ensure that the xholdup3 signal
//  arrives as early in the cycle as possible. It should be generated
//  from latched or early arriving signals - e.g. p3i, p3iv, etc.
// 
//  It must not include any pipeline enable signals which it is used
//  to generate - ifetch, pcen, en1, en2, en3, aux_write, aux_read etc.
//  - or any signals generated from the above.
// 
//  This signal should be generated by ORing together multiple stall
//  signals.
// 
   assign xholdup3 =
// 
//  Example :       multi_cycle_instruction_stall |
//  
// Extension stage 3 stall conditions are inserted here.
                    uxholdup3; 

// ====================== Miscellaneous Logic ========================--
// 
//  This section of the file is for extra chunks of logic which do not
//  fit neatly into the various sections above - for example state 
//  machines to control extension functions and so on.
// 
//  Notes on design of extension instructions:
// 
//  State storage : See comments for signals p3condtrue, en3, p3iv.
//  If an extension instruction stores some state information - for
//  example an accumulator register in a multiply-accumulate function, 
//  then the designer must take steps to ensure the registers containing
//  the state are only updated when the instruction is allowed to
//  complete. As well as regular stall conditions, which should be
//  covered by the use of stage enable signals en2 and en3, the 
//  following conditions should be considered:
// 
//  Conditional instructions.
//  If an extension instruction stores data, and may be conditional, the
//  designer must decide if the data stored internally by the extension
//  is also to be subject to the true/false condition. If so, the data
//  latch- enable must include the stage 3 signal p3condtrue as well as
//  the usual p3iv, en3 and instruction decode signal.
// 
//  Stall conditions in different stages.
//  Designers implementing state machines which detect an instruction
//  both in stages 2 and 3 must be aware the cases when different
//  pipeline stages are enabled separately:
// 
//  Stage 1 and 2 stalled, stage 3 enabled : 
//  Caused by xholdup2 or scoreboard unit stall.
// 
//  Stage 1 enabled, stages 2 and 3 stalled : (e.g. xholdup3)
//  A new instruction is allowed to flow into stage 2 from stage 1, if
//  stage 2 does not contain a valid instruction. This situation would
//  be a concern if a system was implemented which detected an
//  instruction entering stage 2, and then caused some kind of stall at
//  stage 3 - in other words a heavily pipelined extension instruction.
//  Care must be taken to ensure the state machine does not get confused
//  by an instruction entering stage 2 whilst stage 3 is stalled.
//   
//
// Miscellaneous extension logic functions are inserted here.
// ======================== Barrel shifter Extension ========================--
//
//  Decode for 16-bit barrel shifting when employing 3-bit
//  unsigned shift value.
// 
  assign i_p2_ext16_brl_u3_a = (p2opcode == OP_16_ARITH) &
                            ((p2subopcode[SUBOPCODE_MSB_1:SUBOPCODE_MSB_2] ==
                            SO16_ASL) | 
                             (p2subopcode[SUBOPCODE_MSB_1:SUBOPCODE_MSB_2] ==
                            SO16_ASR)) ? 1'b 1 : 
         1'b 0;
   
  //  Decode for 16-bit barrel shifting when employing 5-bit
  //  unsigned shift value.
  // 
  assign i_p2_ext16_brl_u5_a =((p2opcode == OP_16_SSUB) &
                               ((p2subopcode3_r == SO16_ASL_U5) | 
                                (p2subopcode3_r == SO16_LSR_U5)  |
                                (p2subopcode3_r == SO16_ASR_U5)))? 1'b 1 : 
         1'b 0; 
  
  assign i_p2_ext_brl_decode_32_a =((p2opcode == OP_FMT2) &
                                    ((p2subopcode == MO_ASL_EXT) | 
                                     (p2subopcode == MO_LSR_EXT) |
                                     (p2subopcode == MO_ASR_EXT) | 
                                     (p2subopcode == MO_ROR_EXT))) ? 1'b 1 : 
         1'b 0;
  
  assign i_p2_ext_brl_decode_16_a = (p2opcode == OP_16_ALU_GEN) &
                                    ((p2subopcode[SUBOPCODE2_16_MSB:0] ==
                                    SO16_ASL_M) | 
                                     (p2subopcode[SUBOPCODE2_16_MSB:0] ==
                                    SO16_LSR_M) |
                                     (p2subopcode[SUBOPCODE2_16_MSB:0] ==
                                    SO16_ASR_M)) | 
                                    (i_p2_ext16_brl_u3_a == 1'b 1) |
                                    (i_p2_ext16_brl_u5_a == 1'b 1) ? 1'b 1 : 
         1'b 0;
  
  // Decode in stage 3 for all barrel shifter operations.
  //
  assign i_p3_barrel_decode_nxt = ((p2b_opcode == OP_16_ARITH) &
                                   ((p2b_subopcode[SUBOPCODE_MSB_1:
                                                SUBOPCODE_MSB_2] ==
                                  SO16_ASL) | 
                                    (p2b_subopcode[SUBOPCODE_MSB_1:
                                                SUBOPCODE_MSB_2] ==
                                  SO16_ASR)))                      |
                                ((p2b_opcode == OP_16_SSUB) &
                                 ((p2b_subopcode3_r == SO16_ASL_U5) | 
                                  (p2b_subopcode3_r == SO16_LSR_U5) |
                                  (p2b_subopcode3_r == SO16_ASR_U5))) |
                                ((p2b_opcode == OP_16_ALU_GEN) &
                                 ((p2b_subopcode[SUBOPCODE2_16_MSB:0] ==
                                  SO16_ASL_M) | 
                                  (p2b_subopcode[SUBOPCODE2_16_MSB:0] ==
                                  SO16_LSR_M) |
                                  (p2b_subopcode[SUBOPCODE2_16_MSB:0] ==
                                  SO16_ASR_M)))                    |
                                ((p2b_opcode == OP_FMT2) &
                                 ((p2b_subopcode == MO_ASL_EXT) | 
                                  (p2b_subopcode == MO_LSR_EXT) |
                                  (p2b_subopcode == MO_ASR_EXT) | 
                                  (p2b_subopcode == MO_ROR_EXT))) ?
         1'b 1 : 
         1'b 0;
  
  assign i_p2_fmt_cond_reg_a = (p2format == FMT_COND_REG) ? 1'b 1 : 1'b 0;
  
  assign i_p2_fmt_s12_a = (p2format == FMT_S12) ? 1'b 1 : 1'b 0;
  
  assign i_p2_op_16_alu_gen_a = (p2opcode == OP_16_ALU_GEN) ? 1'b 1 : 1'b 0;
  
  assign i_p2_op_16_ssub_a = (p2opcode == OP_16_SSUB) ? 1'b 1 : 1'b 0;
  
  assign i_barrel_type_sel0_a = (((p2b_opcode == OP_FMT2) &
                                  (p2b_subopcode == MO_ASL_EXT)) |
                                 ((p2b_opcode == OP_16_ARITH) &
                                  (p2b_subopcode1_r == SO16_ASL)) |
                                 ((p2b_opcode == OP_16_ALU_GEN) &
                                  (p2b_subopcode[SUBOPCODE2_16_MSB:0] == SO16_ASL_M)) |
                                 ((p2b_opcode == OP_16_SSUB) &
                                  (p2b_subopcode3_r == SO16_ASL_U5))) ? 1'b 1 : 
     1'b 0;

   assign i_barrel_type_sel1_a = (((p2b_opcode == OP_FMT2)    &
                                   (p2b_subopcode == MO_LSR_EXT))  |
                                  ((p2b_opcode == OP_16_ALU_GEN) &
                                   (p2b_subopcode[SUBOPCODE2_16_MSB:0] == SO16_LSR_M)) |
                                  ((p2b_opcode == OP_16_SSUB) &
                                   (p2b_subopcode3_r == SO16_LSR_U5))) ? 1'b 1 : 
     1'b 0;
   
   assign i_barrel_type_sel2_a = (((p2b_opcode == OP_FMT2)    &
                                   (p2b_subopcode == MO_ASR_EXT))  |
                                  ((p2b_opcode == OP_16_ARITH) &
                                   (p2b_subopcode1_r == SO16_ASR)) |
                                  ((p2b_opcode == OP_16_ALU_GEN) &
                                   (p2b_subopcode[SUBOPCODE2_16_MSB:0] == SO16_ASR_M)) |
                                  ((p2b_opcode == OP_16_SSUB) &
                                   (p2b_subopcode3_r == SO16_ASR_U5))) ? 1'b 1 : 
     1'b 0;

   assign i_barrel_type_sel3_a = (~(i_barrel_type_sel0_a |
                                    i_barrel_type_sel1_a |
                                    i_barrel_type_sel2_a));

   // Select the type of shift
   //
   assign i_barrel_type_nxt = (
                         (OP_ASL & {(2){i_barrel_type_sel0_a}})
                         |
                         (OP_LSR & {(2){i_barrel_type_sel1_a}})
                         |
                         (OP_ASR & {(2){i_barrel_type_sel2_a}})
                         |
                         (OP_ROR & {(2){i_barrel_type_sel3_a}})
                         );

  always @(posedge clk or posedge rst_a)
     begin : X_P3_BRL_DECODE_PROC
     if (rst_a == 1'b 1)
        begin
        //  asynchronous reset (active high)
        x_p3_brl_decode_16_r      <= 1'b 0;  
        x_p3_brl_decode_32_r      <= 1'b 0;  
        i_p2b_ext_brl_decode_16_r <= 1'b 0;
        i_p2b_ext_brl_decode_32_r <= 1'b 0;
        i_p3_barrel_decode_r      <= 1'b 0;
        barrel_type_r             <= 2'b 0;
        end
     else
        begin
        //  rising clock edge
        if (en2 == 1'b 1)
           begin
           i_p2b_ext_brl_decode_16_r <= i_p2_ext_brl_decode_16_a;   
           i_p2b_ext_brl_decode_32_r <= i_p2_ext_brl_decode_32_a;   
           end

        if (en2b == 1'b 1)
           begin
           i_p3_barrel_decode_r <= i_p3_barrel_decode_nxt;
           x_p3_brl_decode_16_r <= i_p2b_ext_brl_decode_16_r;
           x_p3_brl_decode_32_r <= i_p2b_ext_brl_decode_32_r;
           barrel_type_r        <= i_barrel_type_nxt;
           end 

        end
     end
  


// ======================= MUL64 decodes and control ========================--
//
assign i_p3mul64_a = ((p3opcode == OP_FMT2) &
                      ((p3subopcode == MO_MUL64) | (p3subopcode == MO_MULU64))) |
                     ((p3opcode == OP_16_ALU_GEN) &
                      (p3subopcode[SUBOPCODE2_16_MSB:0] == SO16_MUL64)) ?
       1'b1 :
       1'b0;

assign i_p2_mul64_decode_32_a = ((p2opcode == OP_FMT2) &
                                 ((p2subopcode == MO_MUL64) |
                                  (p2subopcode == MO_MULU64))) ?
       1'b1 :
       1'b0;

assign i_p2_mul64_decode_16_a = ((p2opcode == OP_16_ALU_GEN) &
                                 (p2subopcode[SUBOPCODE2_16_MSB:0]
                                 == SO16_MUL64)) ?
       1'b1 :
       1'b0;

// Register the multiplier decode from stage 2 to stage 2B
//
always @(posedge clk or posedge rst_a)
begin : REG_MUL_DECODE_PROC
   if (rst_a == 1'b1)
      i_p2b_mul64_decode_r <= 1'b0;
   else
   begin
      if (en2 == 1'b1)
         i_p2b_mul64_decode_r <= i_p2_mul64_decode_16_a |
                                 i_p2_mul64_decode_32_a;
   end
end

assign i_p2b_mul64_decode_iv_a = i_p2b_mul64_decode_r & p2b_iv;


// =========================== Multiply Scoreboard ==========================--
// 
// Stall stage 2 of the pipeline if an instruction is using the 
// multiply result registers.
// 
assign i_s1mul_a = (s1a == RMLO | s1a == rmmid | 
                    s1a == RMHI) ?
       s1en :
       1'b0;

assign i_s2mul_a = (fs2a == RMLO | fs2a == rmmid | 
                    fs2a == RMHI) ?
       s2en :
       1'b0;


// ======================== Normalise Extension =======================--
//
   assign i_p2_norm_decode_a =((p2opcode == OP_FMT2) &
                               (p2subopcode == SO_SOP) & 
                               ((p2minoropcode == SO_NORMW_EXT) |
                                (p2minoropcode == SO_NORM_EXT))) ? 1'b1 :
                                                                1'b0;

   assign i_p2b_norm_decode_a =((p2b_opcode == OP_FMT2) &
                                (p2b_subopcode == SO_SOP) & 
                                (p2b_minoropcode == SO_NORM_EXT)) ? 1'b1 :
                                                                 1'b0;

   assign i_p2b_snorm_decode_a =((p2b_opcode == OP_FMT2) &
                                 (p2b_subopcode == SO_SOP) &
                                 (p2b_minoropcode == SO_NORMW_EXT)) ? 1'b1 :
                                                                   1'b0;

   always @(posedge clk or posedge rst_a)
   begin : NORM_DEC_PROC
      if (rst_a == 1'b1)
      begin
         i_p3_norm_decode_r  <= 1'b0;
         i_p3_snorm_decode_r <= 1'b0;
      end
      else
      begin
         if (en2b == 1'b1)
         begin
            i_p3_norm_decode_r  <= i_p2b_norm_decode_a;
            i_p3_snorm_decode_r <= i_p2b_snorm_decode_a;
         end
      end
   end

   assign x_p3_norm_decode_r   = i_p3_norm_decode_r;
   assign x_p3_snorm_decode_r  = i_p3_snorm_decode_r;


// =========================== Swap Extension =========================--

   assign i_p2_swap_decode_a =((p2opcode == OP_FMT2) &
                               (p2subopcode == SO_SOP) & 
                               (p2minoropcode == SO_SWAP_EXT)) ?
                               1'b1 :
                               1'b0;

   assign i_p2b_swap_decode_a =((p2b_opcode == OP_FMT2) &
                                (p2b_subopcode == SO_SOP) &
                                (p2b_minoropcode == SO_SWAP_EXT)) ?
                                1'b1 :
                                1'b0;

   always @(posedge clk or posedge rst_a)
   begin : SWAP_DEC_PROC
      if (rst_a == 1'b1)
         i_p3_swap_decode_r <= 1'b0;
      else
      begin
         if (en2b == 1'b1)
            i_p3_swap_decode_r <= i_p2b_swap_decode_a;
      end
   end

   assign x_p3_swap_decode_r = i_p3_swap_decode_r;


// =================== Special case instructions =====================--

// x_set_sflag : Extenstion Stage 3 set Saturate flag.
//               This signal is set when an instruction in stage 3 is a
//               saturating type.  This signal in conjuction with the
//               xalu:x_s_flag will set the S bit in Aux. Ext. Reg. 41
   assign  x_set_sflag =
                          1'b 0;
// 
// x_p2_jump_decode : Extension Pipeline Stage 2 jump decode.
//
// ** For special case instruction encoding only! **
//
// A extention jump will use the ARC flags for in conditional execution.
//    
   assign x_p2_jump_decode =
                          ux_p2_jump_decode;

//
// x_p2b_jump_decode : Extension Pipeline Stage 2b jump decode
//
// ** For special case instruction encoding only! **
//
// A extention jump will use the ARC flags for in conditional execution
    
   assign x_p2b_jump_decode =
                           1'b0;

//
// x_p1_rev_src : Extension Pipeline Stage 1 reverse source field.
//
// ** For special case instruction encoding only! **
//
// This signal will cause the operands to be swapped.
//    
   assign x_p1_rev_src = 
       ux_p1_rev_src;
   
//  xp2idest : Extension Pipeline Stage 2 ignore destination field
// 
//  ** For special case instruction encoding only! **
// 
//  This signal is used to indicate that the instruction in stage 2 will
//  not write back to the register specified in the A field.
//  Setting the signal true has the effect of preventing the scoreboard
//  unit from checking the instruction's destination register for
//  clashes with pending loads. This signal will only take effect when 
//  the extension logic has 'claimed' the instruction by setting
//  x_idecode2.
// 
//  This signal would be used for special case instructions which do not
//  conform to normal extension instruction encoding rules, and use the 
//  destination field for some purpose other than specifying a register
//  to store the ALU result.
// 
//  It should be noted that if an instruction causes this signal to be 
//  asserted when it is in stage 2, the xnwb signal should be asserted 
//  when the instruction reaches stage 3, in order to prevent a
//  writeback to the register file.
// 
//  The signal should be held at zero for normal use.
//   
   assign xp2idest = 

       uxp2idest;

//  xsetflags : Extension force flag setting
// 
//  ** For special case instruction encoding only! **
// 
//  This signal allows extension logic to override the normal flag-
//  setting logic, and force the flags to be set from xflags[3:0]. This
//  signal is not qualified with x_idecode3 inside the ARC, so the
//  extension logic must not set this signal true unless x_idecode3 is
//  also true.
// 
//  This signal is ignored if the constant xt_aluflags_r is set false
//  inside the include file extutil.
// 
//  The signal should be held at zero for normal use.
//   
    assign xsetflags = 
        uxsetflags;

//  xnwb : Extension instruction no write back
// 
//  ** For special case instruction encoding only! **
// 
//   The decode unit sets this signal true to prevent the extension 
//  instruction in stage 3 from writing its result back to the register
//  file.
// 
//  The flag-setting logic is unaffected by this signal - hence the
//  programmer may set the flags using the .F mode on the extension
//  instruction. The flag values used come from the internal ALU.
// 
//  The xnwb signal has no effect when x_idecode3 is not asserted.
//  This signal is ignored if the XT_ALUOP constant is set false in the 
//  package include file extutil.
// 
//  The signal should be held at zero for normal use.
//   
   assign xnwb = 
                 i_p3mul64_a |
                 uxnwb; 

// idmp_stall12 : DMP stalling of pipeline stages 1-2
//
//
//  If the debug interface is accessing a Data Memory Pipeline (DMP)
//  sub-module (dmp_holdup12 = '1') then pipeline stage 2 must be
//  stalled if it contains a load or store instruction (mload2b = '1' or
//  mstore2b = '1'). The reason is that when the DMP is busy servicing
//  requests from the debug interface it cannot service requests from
//  the ARC pipeline at the same time. The signal dmp_stall12 is set
//  when pipeline stages 1-2 should be stalled. If the pipeline is free
//  from LD/ST instructions it will continue to flow even if
//  dmp_holdup12 is set. This signal is only used in a build with memory
//  subsystem.
//
   assign idmp_stall12 = ((dmp_holdup12) &
                          (mload2b | mstore2b)); 

//====================================================================--

endmodule // module xrctl

