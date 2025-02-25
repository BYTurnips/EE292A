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
// This file contains logic for Program counter generation logic.
// This file does not include the flags - these are combined at
// the level above in order to produce the full 32-bit word seen
// by the ARC600 & the host.
//
//=========================== Inputs to this block ===========================--
//
// clk                             Core Clock
// 
// rst_a                           System Reset (Active high)
//
// aligner_do_pc_plus_8            This signal is true when an instruction
//                                 stream consists of word aligned 32-bit
//                                 instructions. As can be seen at time T the
//                                 16-bit instruction at address n is presented
//                                 (the high part of the next longword is stored
//                                 in the buffer). At T+1 the current PC is n+2.
//                                 The data requested (at time T) and returned
//                                 from memory at time T+1 is the longword at
//                                 n+4 (and therefore the half word at n+6 is
//                                 buffered).  To be able to present the
//                                 complete 32-bit instruction at n+6 the memory
//                                 address must be set to n+8, which is the
//                                 longword aligned version of PC+8 ( (n+2)+8 =
//                                 (n+10)&&0xfffffffc = n+8). This process will
//                                 continue until a 16-bit instruction or a jcc
//                                 /brcc/bcc instruction is encountered.
//                               
//                               
//                                         ////////////////////////////////
//                                         |              |               |
//                                    n    |    16-bit    |    32-bit_a0  |
//                                         |              |               |
//                                         ////////////////////////////////
//                                         |              |               |
//                                    n+4  |   32-bit_b0  |    32-bit_a1  |
//                                         |              |               |
//                                         ////////////////////////////////
//                                         |              |               |
//                                    n+8  |   32-bit_b1  |    32-bit_a2  |
//                                         |              |               |
//                                         ////////////////////////////////
//                                         |              |               |
//                                    n+12 |   32-bit_b2  |    xxxxxxx    |
//                                         |              |               |
//                                         ////////////////////////////////
//                               
//                               
// aligner_pc_enable                This signal is true when the instruction
//                                  aligner needs to fetch the longword from the
//                                  pc+4 address to be able to reconstruct a
//                                  word aligned 32-bit instruction or limm. if
//                                  a jcc/brcc/bcc as a word aligned target
//                                  which is also a 32-bit instruction the
//                                  aligner is unable to present the instruction
//                                  immediatly.  The aligner must stall stage 1
//                                  (this is done by forcing ivalid_aligned to
//                                  false) and request the n+4 longword. When
//                                  the n+4 longword is returned the aligner can
//                                  construct the complete instruction from the
//                                  buffered high word at address n+2 and the
//                                  low word at address n+4.
//                               
//                                       ////////////////////////////////
//                                       |              |               |
//                                  n    |    xxxxxx    |    32-bit_a0  |
//                                       |              |               |
//                                       ////////////////////////////////
//                                       |              |               |
//                                  n+4  |   32-bit_b0  |    xxxxxxxxx  |
//                                       |              |               |
//                                       ////////////////////////////////
//                               
// awake_a                          This signal allows the PC signal sent to
//                                  the cache to be synchronized with the
//                                  internally stored PC when re-awakening from
//                                  reset or a cache invalidate.
//                                 
// en2                              Pipeline stage 2 enable. When this signal is
//                                  true, the instruction in stage 2 can pass
//                                  into stage 2B at the end of the cycle. When
//                                  it is false, it will hold up stage 2 and
//                                  stage 1 (pcen).
//                                 
// en2b                             Pipeline stage 2B enable. When this signal
//                                  is true, the instruction in stage 2b can
//                                  pass into stage 3 at the end of the cycle.
//                                  When it is false, it will hold up stage 2B,
//                                  stage 2 and stage 1 (pcen).
//                                 
// en3                              Pipeline stage 3 enable. When this signal is
//                                  true, the instruction in stage 3 can pass
//                                  into stage 4 at the end of the cycle. When
//                                  it is false, it will probably hold upstage
//                                  1, 2 and 2b (pcen, en2), along with stage 3.
//                                 
// h_dataw [31:0]                   Host Write Data. Data to be written from the
//                                  host.
//                                 
// h_pcwr                           From aux_regs. This signal is set true when
//                                  the host is attempting to write to the pc/
//                                  status register, and the machine is stopped.
//                                  It is used to trigger an instruction fetch
//                                  when the PC is written when the machine is
//                                  stopped. This is necessary to ensure the
//                                  correct instruction is executed when the
//                                  machine is restarted. It is also used to
//                                  latch the new PC value.
//                                 
// h_pcwr32                         From aux_regs. This signal is set true when
//                                  the host is attempting to write to the
//                                  32-bit pc register, and the machine is
//                                  stopped. It is used to trigger an
//                                  instruction fetch when the PC is written
//                                  when the machine is stopped. This is
//                                  necessary to ensure the correct instruction
//                                  is executed when the machine is restarted.
//                                 
// int_vec  [PC_MSB:0]              This is the interrupt vector supplied to the 
//                                  program counter. Each interrupt line has a
//                                  different vector associated with it. It is
//                                  latched into the PC at the end of the cycle
//                                  when p2int is true.
//                                 
// ivalid                           Qualifying signal for p1iw[31:0]. When it is
//                                  low, this indicates that the m/c has not
//                                  been able to fetch the requested opcode, and
//                                  that the program counter should not be
//                                  incremented. The pipeline might be stalled,
//                                  depending upon whether the instruction in
//                                  stage 2 needs to look at the instruction in
//                                  stage 1. When it is true, the instruction is
//                                  clocked into pipeline stage 2 provided that
//                                  the pipeline is able to move on.
//                                  
// ivalid_aligned                   This signal is true when the ivalid signal
//                                  from the ifetch interface is true except
//                                  when the aligner need to get the next
//                                  longword to be able to reconstruct the
//                                  current instruction. See explanation of
//                                  aligner_pc_enable.
//                                 
// 
// loopstart_r [PC_MSB:0]           Zero delay loop start address.
//                                 
// p1inst_16                        This signal is true when the instrucion
//                                  forwarded is a 16-bit type.
//                                 
// p2_jblcc_a                       True when stage 2 contains a valid jump&link
//                                  or branch & link instruction
//                                 
// p2_abs_neg_a                     Stage 2 abs and negs instruction decode
//                                 
// p2_brcc_instr_a                  Stage 2 compare&branch instruction decode.
//                                 
// p2_dorel                         True when a relative branch (not jump) is
//                                  going to happen. Relates to the instruction
//                                  in stage 2. Includes p2iv.
//                                 
// p2_iw_r [INSTR_UBND:0]           Stage 2 instruction word. 
//                                 
// p2_not_a                         True when stage 2 has decoded a NOT
//                                  instruction.
//                                 
// p2_s1a [5:0]                     Stage 2 source 1 register address field.
//                                 
// p2_s1en                          Stage 2 source 1 register address field
//                                  enable.
//                                 
// p2b_dojcc                        True when a jump is going to happen.
//                                  Relates to the instruction in stage 2b.
//                                  Includes p2b_iv.
//       
// p2b_shimm_data [12:0]            This bus carries the short immediate data
//                                  encoded on the instruction word. It is used
//                                  by coreregs when one of the source (s1a/
//                                  fs2a) registers being referenced is one of
//                                  the short immediate registers.It always
//                                  provides the region of the instruction where
//                                  the short immediate data would be found,
//                                  regardless of whether short immediate data
//                                  is being used.
//                                 
// p2b_shimm_s1_a                   operand 1 requires the short immediate data
//                                  carried in p2b_shimm_data
//                                 
// p2delay_slot                     Stage 2 instruction has a delay slot. This
//                                  signal is set true when the instruction in
//                                  stage 2 uses a delay slot.  This signal does
//                                  not have an information about the delay slot
//                                  instruction itself.
//                                 
// p2int                            From int_unit. This signal indicates that an
//                                  interrupt jump instruction (fantasy
//                                  instruction) is currently in stage 2. This
//                                  signal has a number of consequences
//                                  throughout the system, causing the interrupt
//                                  vector (int_vec) to be put into the PC, and
//                                  causing the old PC to be placed into the
//                                  pipeline in order to be stored into the
//                                  appropriate interrupt link register.
//                                  Note that p2int and p2iv are mutually
//                                  exclusive.
//                                 
// p2limm                           Indicates that the instruction in stage 2
//                                  will use long immediate data.
//                                 
// p2lr                             This is true when p2opcode = oldo, and 
//                                  p2iw(13) = '1', which indicates that the
//                                  instruction is the auxiliary register load
//                                  instruction LR, not a memory load LD
//                                  instruction. This signal is used by coreregs
//                                  to switch the currentpc_r bus onto the
//                                  source2 bus (which is then passed through
//                                  the same logic as the interrupt link
//                                  register) in order to get the correct value
//                                  of PC when it is read by an LR instruction.
//                                  Does not include p2iv.
//                                 
// p2offset [targz:0]               This is the 24-bit relative address from the
//                                  instruction in stage 2. It is sign-extended
//                                  and added to the stage 2 program counter
//                                  when a branch is to take place.
//                                 
// p4_docmprel                      Stage 4 control transfer is in progress
//                                  during the cycle.
//                                 
// pcen                             Program counter enable. When this signal is
//                                  true, the PC will change at the end of the
//                                  cycle, indicating that the memory controller
//                                  needs to do a fetch on the next cycle using
//                                  the address which will appear on currentpc,
//                                  which is supplied from aux_regs.
//                                  This signal is affected by interrupt logic
//                                  and all the other pipeline stage enables
//                                 
// pcen_niv                         Same as above but with the ivalid_aligned
//                                  qualification
//                                 
// fs2a[5:0]                        from rctl. The source 2 register address
//                                  live and direct from the stage 2B latches.
//                                  It is muxed with the host address to allow
//                                  host accesses to registers when the ARC 600
//                                  is stopped, before being output on s1a[5:0].
//                                 
// p2_dopred                        Stage 2 changed PC to PC+branch offset due
//                                  to compare & branch prediction.
// p2_dopred_nds                    Same as above except on true when the
//                                  compare&branch has a no delay slot.
//                                 
// do_loop_a                        From loopcnt. This signals that a ZD loop
//                                  loopback will happen when en1 is true.
//                                 
// p2b_dopred_ds                    Stage 2b contains a compare&branch that has
//                                  been predicited taken. The branch also has a
//                                  delay slot.
//
// step                             From debug. Do a single step on the next cycle, if
//                                  the ARC is stopped.
//
// inst_step                        When this signal is set at the same time as the step
//                                  signal is set a single instruction step occurs. Only
//                                  one instruction is fetched and allowed to complete.
//
//========================== Output from this block ==========================--
//
// currentpc_nxt  [PC_MSB:PC_LSB]   This bus containts the next program counter
//                                  value to be written to the architectual
//                                  program counter register.
//                                 
// currentpc_r  [PC_MSB:0]          This bus is the current value of the
//                                  architectual program counter register.
//                                 
// misaligned_target                This signal is true when bit 1 of the
//                                  program counter register is set. It
//                                  signifies that the the current address is
//                                  a word address.
//                                 
// pc_is_linear_r                   This signal is only true when the program
//                                  counter has moved lineraly from it's last
//                                  address to the courrent address.  This
//                                  signal is also cleared when a host access
//                                  has modified the program counter.
//                                 
// next_pc  [PC_MSB:0]              This is the next address the machine
//                                  requires from the instruction cache system
//                                 
// running_pc  [PC_MSB:0]           This is the next program counter when the
//                                  machine is in free running mode.  This
//                                  signal is used by the multi-way instruction
//                                  cache to save power. This is achieved by not
//                                  enabling the tag or data rams if the same
//                                  cache line is being accessed.
//                                 
// last_pc_plus_len  [PC_MSB:0]     This bus contains the registered (in to
//                                  stage 2B) value of the program counter plus
//                                  the length of the current instruction.
//                                 
// p2_pc_r  [PC_MSB:0]              The program counter value for the
//                                  instruction in stage 2.
//                                 
// p2b_pc_r   [PC_MSB:0]            The program counter value for the
//                                  instruction in stage 2b.
//                                 
// p2_target  [PC_MSB:0]            This is the target address for the
//                                  branch/loop instruction in stage2.
//                                 
// p2_s1val_tmp_r  [PC_MSB:0]       This bus is used in cr_int. This signal is
//                                  used to early generate some of the values to
//                                  be placed on the source 1 in the next stage.
//                                  This has been done for static timing reasons.
//                                 
// pcounter_jmp_restart_r           This signal is true when a delayed control
//                                  transfer is pending.  If a control transfer
//                                  is resolved and the Instruction cache system
//                                  is busy fetching i.e. there is no
//                                  instruction in stage 1 ivalid_aligned = '0'
//                                  then the cache cannot accept any more
//                                  fetches.  This is reconised and this bit is
//                                  set, when the cache becomes free the machine
//                                  will do the program counter update.
//
//============================================================================--
//
module pcounter  (clk,
              rst_a,
              aligner_do_pc_plus_8,
              aligner_pc_enable,
              awake_a,
              en2,
              en2b,
              en3,
              h_dataw,
              h_pcwr,
              h_pcwr32,
              int_vec,
              ivalid,
              ivalid_aligned,
              loopstart_r,
              p1inst_16,
              p2_jblcc_a,
              p2_abs_neg_a,
              p2_brcc_instr_a,
              p2_dorel,
              p2_iw_r,
              p2_not_a,
              p2_s1a,
              p2_s1en,
              p2b_dojcc,
              p2b_shimm_data,
              p2b_shimm_s2_a,
              p2delay_slot,
              p2int,
              p2limm,
              p2lr,
              p2offset,
              p4_docmprel,
              pcen,
              pcen_niv,
              fs2a,
              p2_dopred,
              p2_dopred_nds,
              p2b_dopred_ds,
              do_loop_a,
              qd_b,
              x2data_2_pc,
	      step,
	      inst_step, 

              currentpc_nxt,
              currentpc_r,
              misaligned_target,
              pc_is_linear_r,
              next_pc,
              running_pc,
              last_pc_plus_len,
              p2_pc_r,
              p2b_pc_r,
              p2_target,
              p2_s1val_tmp_r,
              pcounter_jmp_restart_r,
              pcounter_jmp_restart_a);
   
`include "arcutil_pkg_defines.v" 
`include "arcutil.v" 
`include "extutil.v" 

   input                  clk; //  core clock
   input                  rst_a; //  system reset
   input                  aligner_do_pc_plus_8; 
   input                  aligner_pc_enable; 
   input                  awake_a; 
   input                  en2; 
   input                  en2b; 
   input                  en3; 
   input [31:0]           h_dataw; 
   input                  h_pcwr; 
   input                  h_pcwr32; 
   input [PC_MSB:0]       int_vec; 
   input                  ivalid; 
   input                  ivalid_aligned; 
   input [PC_MSB:0]       loopstart_r; 
   input                  p1inst_16; 
   input                  p2_jblcc_a; 
   input                  p2_abs_neg_a; 
   input                  p2_brcc_instr_a; 
   input                  p2_dorel; 
   input [INSTR_UBND:0]   p2_iw_r; 
   input                  p2_not_a; 
   input [5:0]            p2_s1a; 
   input                  p2_s1en; 
   input                  p2b_dojcc; 
   input [12:0]           p2b_shimm_data; 
   input                  p2b_shimm_s2_a; 
   input                  p2delay_slot; 
   input                  p2int; 
   input                  p2limm; 
   input                  p2lr; 
   input [TARGSZ:0]       p2offset; 
   input                  p4_docmprel; 
   input                  pcen; 
   input                  pcen_niv; 
   input [5:0]            fs2a; 
   input                  p2_dopred; 
   input                  p2_dopred_nds; 
   input                  p2b_dopred_ds;
   input                  do_loop_a; 
   input [31:0]           qd_b;
   input [31:0]           x2data_2_pc; 
   input                  step;
   input                  inst_step;

   output [PC_MSB:PC_LSB]  currentpc_nxt; 
   output [PC_MSB:0]       currentpc_r; 
   output                  misaligned_target; 
   output                  pc_is_linear_r;
   output [PC_MSB:0]       next_pc; 
   output [PC_MSB:0]       running_pc; 
   output [PC_MSB:0]       last_pc_plus_len; 
   output [PC_MSB:0]       p2_pc_r; 
   output [PC_MSB:0]       p2b_pc_r; 
   output [PC_MSB:0]       p2_target; 
   output [DATAWORD_MSB:0] p2_s1val_tmp_r; 
   output                  pcounter_jmp_restart_r; 
   output                  pcounter_jmp_restart_a; 
   wire   [PC_MSB:PC_LSB]  currentpc_nxt; 
   wire   [PC_MSB:0]       currentpc_r; 
   wire                    misaligned_target; 
   wire                    pc_is_linear_r;
   wire   [PC_MSB:0]       next_pc; 
   wire   [PC_MSB:0]       running_pc; 
   wire   [PC_MSB:0]       last_pc_plus_len; 
   wire   [PC_MSB:0]       p2_pc_r; 
   wire   [PC_MSB:0]       p2b_pc_r; 
   wire   [PC_MSB:0]       p2_target; 
   wire   [DATAWORD_MSB:0] p2_s1val_tmp_r; 
   wire                    pcounter_jmp_restart_r; 
   wire                    pcounter_jmp_restart_a; 
   wire   [2:0]            i_bottom_bits_plus_1_a; 
   wire   [2:0]            i_bottom_bits_plus_2_a; 
   wire   [PC_MSB:PC_LSB]  i_core_pc_a; 
   wire   [PC_MSB:PC_LSB]  i_ctrl_trfer_pc_a; 
   wire                    i_ctrl_trfer_pc_flg_a;
   wire                    i_ctrl_trfer_pc_flg_nlp_a; 
   wire [PC_MSB:PC_LSB]    i_currentpc_nxt; 
   reg  [PC_MSB:PC_LSB]    i_currentpc_r; 
   wire [PC_MSB:PC_LSB + 1] i_currentpc_to_cache_nxt; 
   reg  [PC_MSB:PC_LSB + 1] i_currentpc_to_cache_r; 
   reg                     i_do_restart_r; 
   reg                     i_do_restart_nxt;
   wire   [PC_MSB:PC_LSB]  i_hwrite_a; 
   wire                    i_jcc_s2a_eq_core_reg_a; 
   wire                    i_jcc_s2a_eq_limm_a; 
   wire                    i_jcc_s2a_eq_pc_a; 
   wire                    i_jcc_s2a_eq_xcore_reg_a; 
   wire                    i_misalign_target_a; 
   wire   [PC_MSB:3]       i_no_ripple_val_a; 
   wire                    i_p2_ctrl_trfer_a; 
   wire   [PC_MSB:PC_LSB]  i_p2_ctrl_trfer_pc_a; 
   wire                    i_p2_do_rel_a; 
   reg    [PC_MSB:PC_LSB]  i_p2_pc_r; 
   wire   [PC_MSB:PC_LSB]  i_p2_pc_tmp; 
   reg    [PC_MSB:LONGWORD_LSB] i_p2b_pc_r; 
   wire                    i_p2b_ctrl_trfer_a; 
   wire   [PC_MSB:PC_LSB]  i_p2b_ctrl_trfer_pc_a; 
   wire   [DATAWORD_MSB:0] i_p2_s1val_tmp_nxt; 
   reg    [DATAWORD_MSB:0] i_p2_s1val_tmp_r; 
   reg    [PC_MSB:PC_LSB]  i_p3_target_buffer_r; 
   reg    [PC_MSB:PC_LSB]  i_p4_target_buffer_r; 
   wire   [PC_MSB:PC_LSB]  i_pc_or_hwrite_a; 
   wire   [PC_MSB:PC_LSB]  i_pc_plus_2_a; 
   wire   [PC_MSB:PC_LSB]  i_pc_plus_4_a; 
   wire   [PC_MSB:PC_LSB]  i_pc_plus_8_a; 
   wire   [PC_MSB:PC_LSB]  i_pc_plus_inst_length_a; 
   reg    [PC_MSB:PC_LSB]  i_last_pc_plus_len_r;   
   wire                    i_pcounter_pcen_a; 
   wire                    i_pcounter_pcen_n_a; 
   reg                     i_pc_is_linear_r; 
   reg    [PC_MSB:PC_LSB]  i_restart_addr_r; 
   wire   [PC_MSB:3]       i_ripple_val_a; 
   reg    [PC_MSB:PC_LSB]  i_running_a; 
   wire   [2:0]            i_running_sel_a; 
   wire                    i_s1_sel_currentpc_a; 
   wire                    i_s1_sel_pc_a; 
   wire   [PC_MSB:PC_LSB]  i_sext_p2offset_a; 
   wire   [DATAWORD_MSB:0] i_shimm_sext_a; 
   wire   [PC_MSB:PC_LSB]  i_stopped_a; 
   wire   [PC_MSB:PC_LSB]  i_stopped_path1_a; 
   wire   [PC_MSB:PC_LSB]  i_stopped_path2_a; 
   wire   [PC_MSB:PC_LSB]  i_target_buffer_nxt; 
   wire   [PC_MSB:PC_LSB + 1]  i_target_buffer_tmp; 
   wire                    i_aligner_pc_en_iv_a; 
   wire                    i_aligner_pc_en_iv_n_a; 
   wire                    i_s1_sel_target_addr_a; 
   wire                    i_s1_sel_p2_pc_a; 
 
//------------------------------------------------------------------------------
// Stage 2 source 1 early generate.
//------------------------------------------------------------------------------
//
// This signal is used to ease the timing on the generation of source 1 operand
// value in the next stage.  Rather that having to mux in all the signals and
// values below in the next stage they are done here, registered and muxed in as
// one in the next stage.
//
   // Decode of the stage 2 source 1 register address field.  This signal is
   // true when the current stage 2 source 1 address field is r63 or current PC.
   //
   assign i_s1_sel_currentpc_a = ((p2_s1a == RCURRENTPC) & (p2_s1en == 1'b 1)) ?
          1'b 1 : 
          1'b 0; 


   // Decode used to select the program counter of the instruction in stage 2 on
   // to the bus.
   //
   assign i_s1_sel_pc_a = (p2lr          | 
                           p2_dopred_nds | 
                           p2_jblcc_a &
                           (~p2delay_slot) & 
                           (~p2limm)); 

   // Decode for the target address for the branch/loop insturtcion
   // 
   assign i_s1_sel_target_addr_a = ((~p2_dopred) & p2_brcc_instr_a); 

   // Select the current architectual program counter.
   //   
   assign i_s1_sel_p2_pc_a = (p2int | i_s1_sel_currentpc_a); 
   

   // When reading from r63 the result should be longword aligned
   //
   assign i_p2_pc_tmp = ({i_p2_pc_r[PC_MSB:LONGWORD_LSB],
                         (i_p2_pc_r[PC_LSB] & 
                         (~i_s1_sel_currentpc_a))});
   
   // Mux all results together.
   //   
   assign i_p2_s1val_tmp_nxt = (({i_p2_pc_tmp, ONE_ZERO})         &
                                ({(PC_SIZE){i_s1_sel_p2_pc_a}})       |
                        
                                ({i_target_buffer_nxt, ONE_ZERO}) &
                                ({(PC_SIZE){i_s1_sel_target_addr_a}}) |
                        
                                ({i_currentpc_r, ONE_ZERO})       &
                                ({(PC_SIZE){i_s1_sel_pc_a}})          |
                        
                                THIRTY_TWO_ONES                 &
                                ({(PC_SIZE){p2_not_a}})               |
                        
                                THIRTY_TWO_ZERO                 &
                                ({(PC_SIZE){p2_abs_neg_a}})); 
  
   // Add the offset to the last PC_value+instruction_length to get the branch
   // target address.
   //
   // Adding the offset to the current program counter value has certain
   // related to loops - breakpoints (branches) cannot be placed in the last
   // instruction position in a loop, for example. In addition, branches cannot
   // be executed as the delay slot of another branch - this is not such a big
   // problem however.
   //
   // Sign extend value from branch.
   //
   assign    i_sext_p2offset_a = {{(PC_MSB - TARGSZ){p2offset[TARGSZ]}}, p2offset};

//------------------------------------------------------------------------------
// Target Adder
//------------------------------------------------------------------------------
//
   // Instatiation of adder for target address calculation
   //
   assign     i_target_buffer_tmp = i_sext_p2offset_a[PC_MSB:LONGWORD_LSB] + (i_p2_pc_r[PC_MSB:LONGWORD_LSB]);


   assign  i_target_buffer_nxt = {i_target_buffer_tmp,
                                  i_sext_p2offset_a[PC_LSB]};


   // Address and data storage registers
   //
   always @(posedge clk or posedge rst_a)
    begin : p2_pc_PROC
      if (rst_a == 1'b 1)
        begin
          i_p2_pc_r            <= {(PC_MSB - PC_LSB + 1){1'b 0}};   
          i_p2b_pc_r           <= {(PC_MSB - LONGWORD_LSB + 1){1'b 0}};   
          i_p2_s1val_tmp_r     <= {(DATAWORD_WIDTH){1'b 0}};   
          i_p3_target_buffer_r <= {(PC_MSB - PC_LSB + 1){1'b 0}};   
          i_p4_target_buffer_r <= {(PC_MSB - PC_LSB + 1){1'b 0}};   
          i_last_pc_plus_len_r <= {(PC_MSB - PC_LSB + 1){1'b 0}};   
        end
      else
        begin
          //  Update the previous PC value when we update the current PC
          //  value.
          // 
          if (pcen == 1'b 1)
            begin
              i_p2_pc_r            <= i_currentpc_r[PC_MSB:PC_LSB];   
              i_last_pc_plus_len_r <= i_pc_plus_inst_length_a;   
            end

          if (en2 == 1'b 1)
            begin
              i_p2_s1val_tmp_r <= i_p2_s1val_tmp_nxt;

              // Move the program counter value for the instruction entering
              // stage 2b along with it.
              //
              i_p2b_pc_r <= i_p2_pc_r[PC_MSB:LONGWORD_LSB];   
            end

          // The processor will wait for it's delay slot so we can get it the
          // correct address of the instruction after the delay slot. (because
          // it knows the length of the delay slot).
          //
          if (en2b == 1'b 1)
            begin
              if (p2b_dopred_ds == 1'b 1)
               begin
                  i_p3_target_buffer_r <= i_last_pc_plus_len_r;   
               end
              else
               begin
                  i_p3_target_buffer_r <= i_p2_s1val_tmp_r[PC_MSB:PC_LSB];   
               end
            end
          if (en3 == 1'b 1)
            begin
              i_p4_target_buffer_r <= i_p3_target_buffer_r;   
            end
        end
    end 
   

//------------------------------------------------------------------------------
//  Current PC + 2/4/8
//------------------------------------------------------------------------------
//
   // The purpose of the following logic is to allow pc+2,pc+4,pc+8 to
   // be generated every cycle.
   // 
   assign i_no_ripple_val_a = i_currentpc_r[PC_MSB:3]; 

   //  29-bit half-adder
   //
   assign i_ripple_val_a = i_currentpc_r[PC_MSB:3] + 1'b 1; 

   //  Three bit half-adder
   //
   assign i_bottom_bits_plus_1_a = {ONE_ZERO, i_currentpc_r[2:PC_LSB]} + 1'b 1; 

   //  Three-bit half-adder
   //
   assign i_bottom_bits_plus_2_a = i_bottom_bits_plus_1_a + 1'b 1; 

   //  29-bit mux
   //
   assign i_pc_plus_2_a[PC_MSB:3] = (i_bottom_bits_plus_1_a[2] == 1'b 0) ?
          i_no_ripple_val_a : 
          i_ripple_val_a; 

   assign i_pc_plus_2_a[2:PC_LSB] = i_bottom_bits_plus_1_a[PC_LSB:0]; 

   //  29-bit mux
   //
   assign i_pc_plus_4_a[PC_MSB:3] = (i_bottom_bits_plus_2_a[2] == 1'b 0) ?
          i_no_ripple_val_a : 
          i_ripple_val_a;
   
//------------------------------------------------------------------------------
// PC plus 4
//------------------------------------------------------------------------------

   assign i_pc_plus_4_a[2:PC_LSB] = i_bottom_bits_plus_2_a[PC_LSB:0]; 
 
//------------------------------------------------------------------------------
// PC plus 8
//------------------------------------------------------------------------------
 
   assign i_pc_plus_8_a = {i_ripple_val_a, i_currentpc_r[2:PC_LSB]};

//------------------------------------------------------------------------------
// Current program counter plus the instruction length
//------------------------------------------------------------------------------
//   
   assign i_pc_plus_inst_length_a = (p1inst_16 == 1'b 1) ? i_pc_plus_2_a : 
          i_pc_plus_4_a; 

//------------------------------------------------------------------------------
//  Stage 2 Program counter values
//------------------------------------------------------------------------------
//
   assign i_p2_do_rel_a = (p2_dorel | p2_dopred);
   
   assign i_p2_ctrl_trfer_a = (p2int | i_p2_do_rel_a); 

   // AND-OR mux
   //
   assign i_p2_ctrl_trfer_pc_a = (int_vec[PC_MSB:PC_LSB] &
                                  ({(PC_MSB){p2int}}) 
                                                           | 
                                  i_target_buffer_nxt    &
                                  ({(PC_MSB){i_p2_do_rel_a}})); 

//------------------------------------------------------------------------------
// Stage 2B Program counter values
//------------------------------------------------------------------------------
//
   // Sign-extend the short immediate data to 32 bits
   //
   assign i_shimm_sext_a = {{(NINETEEN){p2b_shimm_data[SHIMM_MSB]}}, 
                            p2b_shimm_data[SHIMM_MSB:0]}; 

   assign i_jcc_s2a_eq_limm_a = ((fs2a == RLIMM) & (~p2b_shimm_s2_a)) ? 1'b 1 : 
          1'b 0; 

   assign i_jcc_s2a_eq_core_reg_a = ((~fs2a[OPERAND_MSB]) & (~p2b_shimm_s2_a)); 

   assign i_jcc_s2a_eq_pc_a = ((fs2a == RCURRENTPC) & (~p2b_shimm_s2_a)) ? 1'b 1 : 
          1'b 0; 

   assign i_jcc_s2a_eq_xcore_reg_a = (~(i_jcc_s2a_eq_core_reg_a | 
                                       p2b_shimm_s2_a          | 
                                       i_jcc_s2a_eq_limm_a     | 
                                       i_jcc_s2a_eq_pc_a)); 

   assign i_p2b_ctrl_trfer_a = p2b_dojcc; 

   // Stage 2b jumps can reference both registers and short/long immediate data.
   //  
   assign i_p2b_ctrl_trfer_pc_a = (i_shimm_sext_a[PC_MSB:PC_LSB] &
                                   ({(PC_MSB){p2b_shimm_s2_a}})          | 
                           
                                   qd_b[PC_MSB:PC_LSB]           &
                                   ({(PC_MSB){i_jcc_s2a_eq_core_reg_a}}) | 
                           
                                   p2_iw_r[PC_MSB:PC_LSB]        &
                                   ({(PC_MSB){i_jcc_s2a_eq_limm_a}})     | 
                           
                                   i_p2_pc_r                     &
                                   ({(PC_MSB){i_jcc_s2a_eq_pc_a}})       | 
                           
                                   x2data_2_pc[PC_MSB:PC_LSB]    &
                                   ({(PC_MSB){i_jcc_s2a_eq_xcore_reg_a}})); 


//------------------------------------------------------------------------------
// Control transfer request
//------------------------------------------------------------------------------
//
   // This signal is true when a control transfer is in the pipeline (except
   // zero-delay loops).
   //
   assign i_ctrl_trfer_pc_flg_nlp_a = (i_do_restart_r           | 
                                       i_p2b_ctrl_trfer_a       | 
                                       i_p2_ctrl_trfer_a        |
                                       p4_docmprel);

   // This signal includes the zero delay loops.
   //
   assign i_ctrl_trfer_pc_flg_a = (i_ctrl_trfer_pc_flg_nlp_a |
                                   do_loop_a);
   

//------------------------------------------------------------------------------
// Select control transfer next program counter value.
//------------------------------------------------------------------------------
//
   // Select the highest priority (i.e. the control transfer futherest down the
   // pipeline) control transfer.
   //
   // The priorites are as follows:
   //
   // (1) Compare & branch
   // (2) Jumps
   // (3) Branches and Interrupts
   // (4) delayed control transfer
   // (5) Zero delay loops
   //  
   // This priority encoder is coded in this way for static timing reasons.
   //
   assign i_ctrl_trfer_pc_a = ((i_p2_ctrl_trfer_a == 1'b 1) & 
                               ((i_p2b_ctrl_trfer_a | p4_docmprel) == 1'b 0)) ?
        i_p2_ctrl_trfer_pc_a : 
                              (p4_docmprel == 1'b 1) ? 
        i_p4_target_buffer_r : 
                              (i_p2b_ctrl_trfer_a == 1'b 1) ? 
        i_p2b_ctrl_trfer_pc_a : 
                              (i_do_restart_r == 1'b 1) ? 
        i_restart_addr_r : 
        // Loops are detected in stage 1
        //
        loopstart_r[PC_MSB:PC_LSB]; 

//------------------------------------------------------------------------------
// Select the correct PC
//------------------------------------------------------------------------------
//
   // If a control transfer is present then select it's PC else move the PC on
   // linearsly.
   //
   assign i_core_pc_a = (i_ctrl_trfer_pc_flg_a == 1'b 1) ? i_ctrl_trfer_pc_a : 
          i_pc_plus_inst_length_a; 


//------------------------------------------------------------------------------
// Host write logic
//------------------------------------------------------------------------------
// Program counter cannot be written to by the host when ARC600 is running. The
// enable signal pcen cannot be true when ARC is halted.
// 
   // Break instruction decode included here since it is typically a critical
   // path from the cache data RAM.
   //
   assign i_hwrite_a = (h_pcwr == 1'b 1) ?
          {SIX_ZERO, h_dataw[OLD_PC_MSB:0], ONE_ZERO} : 
          h_dataw[PC_MSB:PC_LSB]; 

   assign i_pc_or_hwrite_a = ((h_pcwr | h_pcwr32) == 1'b 1) ?  i_hwrite_a : 
          i_currentpc_r[PC_MSB:PC_LSB]; 

//------------------------------------------------------------------------------
// Select host or core PC
//------------------------------------------------------------------------------
//
   // This is the PC of the instruction in stage one rather than the address
   // presented to the instruction fetch interface since some aligning is
   // performed before the instruction is received.
   //
   assign i_currentpc_nxt = (i_pcounter_pcen_a == 1'b 1) ? 
          i_core_pc_a : 
          i_pc_or_hwrite_a; 

//------------------------------------------------------------------------------
// program counter registers
//------------------------------------------------------------------------------
//
   always @(posedge clk or posedge rst_a)
    begin : pc_reg_sync_PROC
      if (rst_a == 1'b 1)
        begin
          
          // The latches which make up the PC are defined below. The reset
          // vector (`IVECTOR0) is automatically loaded into the register when rst_a
          // is true.
          //
          i_currentpc_r          <= `IVECTOR0_PC;   
          i_currentpc_to_cache_r <= `IVECTOR0_PC1;   
          i_pc_is_linear_r       <= 1'b 0;   
        end
      else
        begin

          if ((h_pcwr | h_pcwr32) == 1'b 1)
            begin
              i_pc_is_linear_r <= 1'b 0;
            end
          else
            if (pcen == 1'b 1 | (step & inst_step))
             begin
               i_pc_is_linear_r <= (~i_ctrl_trfer_pc_flg_nlp_a);   
             end

          i_currentpc_r <= i_currentpc_nxt;   
          i_currentpc_to_cache_r <= i_currentpc_to_cache_nxt;   
        end
    end

   //  The current PC of a word aligned instruction.
   //  

   assign i_misalign_target_a = 
   
   
   i_currentpc_r[PC_LSB];

//------------------------------------------------------------------------------
// Delayed control transfer logic
//------------------------------------------------------------------------------
//
// To allow control transfer instructions to move freely down the pipeline
// without the need to stall them in their resolution stage whilst the cache
// becomes free this logic is required.  The logic detects when both a control
// transfer (except loops) and the cache is busy (ivalid_aligned = '0').  The
// address for the control transfer is stored for use when the cache becomes
// free.  When it does the address is fetched and the machine continues in
// normal running mode.
//

always @( pcen or i_p2b_ctrl_trfer_a or en2b or i_p2_ctrl_trfer_a or en2
          or p4_docmprel or ivalid_aligned or i_do_restart_r )
  begin
    if( pcen == 1'b1 )
      i_do_restart_nxt = 1'b0;
    else if(((i_p2b_ctrl_trfer_a & en2b | 
               i_p2_ctrl_trfer_a & en2 | 
               p4_docmprel) == 1'b 1) & (ivalid_aligned == 1'b 0))
      i_do_restart_nxt = 1'b1;
    else
      i_do_restart_nxt = i_do_restart_r;
  end

always @( posedge clk or posedge rst_a )
  begin
    if( rst_a == 1'b1 )  i_do_restart_r <= 1'b0;
    else                 i_do_restart_r <= i_do_restart_nxt;      
  end

   always @(posedge clk or posedge rst_a)
    begin : restart_PROC
      if (rst_a == 1'b 1)
        begin
          i_restart_addr_r <= {(PC_MSB - PC_LSB + 1){1'b 0}};   
        end
      else
        begin
          if ((((i_p2b_ctrl_trfer_a & en2b) | 
             (i_p2_ctrl_trfer_a & en2) | 
             p4_docmprel) == 1'b 1) & (ivalid_aligned == 1'b 0) &
              (pcen == 1'b0))
            begin
              i_restart_addr_r <= i_ctrl_trfer_pc_a;   
            end
        end
    end

//------------------------------------------------------------------------------
// PC value to cache system Revised PC Muxer
//------------------------------------------------------------------------------
//
// This Muxer has been entirely rewritten based on an analysis of which program
// counter values are required under which circumstances. After this analysis,
// optimizations have been applied to balance the mux logic to reduce the
// critical paths related to signals from the incoming instruction (i.e.
// p1inst_16, BRK decode, p1iw_aligned_a etc). Signals from the p2limm decode
// are also fairly late arriving it seems.
// 
// I$ invalidate
//
// When the instruction cache is invalidated, the 16-bit instruction buffer in
// the aligner block is cleared.
// 
// As a consequence, a new instruction fetch is issued from the core to restart
// instruction fetching at the current program counter. This is required since
// any ifetch which was issued simultaneously with the ivic would be ignored by
// the instruction cache.
//
// The PC-value-to-cache signal is resynchronized to the architectural PC on
// reset and on restart after ivic, using the awake_a signal. 
// 
// The first ifetch that is actually used is the first one AFTER the ivic. When
// the processor is running this will be on the cycle immediately after ivic,
// but when it is halted, the first ifetch will be when the processor is
// restarted.
//
   assign i_aligner_pc_en_iv_a = (aligner_pc_enable & ivalid); 
  
   assign i_aligner_pc_en_iv_n_a = ((~aligner_pc_enable) | (~ivalid)); 

   assign i_stopped_a = (i_stopped_path1_a &
                         ({(PC_MSB){i_aligner_pc_en_iv_a}}) |
     
                        i_stopped_path2_a &
                        ({(PC_MSB){i_aligner_pc_en_iv_n_a}})); 

   assign i_stopped_path1_a = ((h_pcwr | h_pcwr32) == 1'b 1) ?
          i_hwrite_a : 
                               (awake_a == 1'b 1) ?
          i_currentpc_r : 
          i_pc_plus_4_a; 

   assign i_stopped_path2_a = ((h_pcwr | h_pcwr32) == 1'b 1) ?
          i_hwrite_a : 
                               (awake_a == 1'b 1) ?
          i_currentpc_r : 
          {i_currentpc_to_cache_r, ONE_ZERO}; 

   assign i_running_sel_a = {i_ctrl_trfer_pc_flg_a, awake_a,
                             aligner_do_pc_plus_8};
   
   always @(i_ctrl_trfer_pc_a or i_currentpc_r or i_pc_plus_4_a or
            i_pc_plus_8_a or i_running_sel_a)
    begin : running_PROC
      case (i_running_sel_a)
        
        //  Misaligned linear instruction fetch.
        // 
        3'b 001:
         begin
            i_running_a = i_pc_plus_8_a;
         end

        //  Non-linear instruction fetch.
        // 
        3'b 101,
        3'b 100:
            begin
               i_running_a = i_ctrl_trfer_pc_a;
            end

        //  Aligned linear instruction fetch or misaligned instruction
        //  fetch with cache invalidate.
        //
        3'b 000:
         begin
            i_running_a = i_pc_plus_4_a;
         end

        //  Awaking after a reset or ivic
        // 
        default:
         begin
            i_running_a = i_currentpc_r;   
         end
      endcase
    end

   //  This pcen signal provides a minor speed-up.
   // 
   // 
   //  Note that with the revised PC muxer, aligner_pc_enable does not
   //  included ivalid - which is fine here since this decode is only
   //  true when ivalid = '1'. 
   // 
   assign i_pcounter_pcen_a = (pcen_niv & ivalid & (~aligner_pc_enable));
   
   assign i_pcounter_pcen_n_a = ((~pcen_niv) | (~ivalid) | aligner_pc_enable); 

   //  Next program counter value to the cache system. This takes into
   //  account the adjustments required for misaligned instruction
   //  accesses.
   // 
   assign i_currentpc_to_cache_nxt = (i_running_a[PC_MSB:2] &
                                      ({(PC_MSB-PC_LSB){i_pcounter_pcen_a}}) 
                                     | 
                                      i_stopped_a[PC_MSB:2] &
                                      ({(PC_MSB-PC_LSB){i_pcounter_pcen_n_a}}));

//------------------------------------------------------------------------------
// Output Drives
//------------------------------------------------------------------------------
// 
   //  Drive outputs from internal signals
   //
   assign currentpc_nxt = i_currentpc_nxt; 
   assign currentpc_r = {i_currentpc_r, ONE_ZERO}; 
   assign last_pc_plus_len = {i_last_pc_plus_len_r, ONE_ZERO}; 
   assign misaligned_target = i_misalign_target_a; 
   assign next_pc = {i_currentpc_to_cache_nxt, TWO_ZERO}; 
   assign p2_pc_r = {i_p2_pc_r, ONE_ZERO}; 
   assign p2b_pc_r = {i_p2b_pc_r, TWO_ZERO}; 
   assign p2_s1val_tmp_r = i_p2_s1val_tmp_r; 
   assign p2_target = {i_target_buffer_nxt, ONE_ZERO}; 
   assign pc_is_linear_r = i_pc_is_linear_r; 
   assign pcounter_jmp_restart_r = i_do_restart_r; 
   assign pcounter_jmp_restart_a = i_do_restart_nxt;
   assign running_pc = {i_running_a, ONE_ZERO}; 

endmodule // module pcounter
