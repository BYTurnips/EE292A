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
// This file contains the status register flag bits including the
// global run signal, en.
//
//
// Bit positions in the program counter/status register:
//
//              +-31----30----29----28-----27-----26----25--+
//              |     |     |     |     |      |      |     |
//              |  Z  |  N  |  C  |  V  |  E2  |  E1  |  H  |
//              |     |     |     |     |      |      |     |
//              +-------------------------------------------+
//
//
//
// Bit positions in the status32 register:
//
//       +-11---10---09---08---07---06---05---04---03---02---01---0-+
//       |    |    |    |    |    |    |    |    |    |    |    |   |
//       | Z  | N  | C  | V  | Rd | Rd | Rd | Rd | Rd | E2 | E1 | H |
//       |    |    |    |    |    |    |    |    |    |    |    |   |
//       +----------------------------------------------------------+
//
//
//======================= Inputs to this block =======================--
//
// clk              Global Clock.
//  
// rst_a            Global Reset (active high).
//
// arc_start_a      This signal defines whether the ARC starts running
//                  on reset, or goes into a halted state. When it is
//                  set to '1' the ARC will start running code from the
//                  reset vector onwards after a reset. It should be
//                  fixed at '1' for start-on-reset or at '0' for
//                  halt-on-reset.
//
// ctrl_cpu_start_r This signal comes from the 'ctrl_cpu_start' input
//                  and will start the ARC running when it is halted.
//
// step             From debug. Do a single step on the next cycle, if
//                  the ARC is stopped.
//
// inst_step        When this signal is set at the same time as the step
//                  signal is set a single instruction step occurs. Only
//                  one instruction is fetched and allowed to complete.
//
// halt             From top level. When this signal is set true, the
//                  ARC will stop running on the next cycle.
//
// aux_dataw[31:0]  from hostif. This is the auxiliary register bus 
//                  write data value.
//
// aux_write        from hostif. This signal indicates that a write
//                  (either from the ARC or host) is being performed to
//                  the auxiliary register specified on aux_addr[31:0].
//
// h_dataw[31:0]    from mc/host. Data from the host to be stored into
//                  registers in the ARC/extensions.
//
// h_write          from mc/host. When it is true, this signal indicates
//                  that a host write is taking place.
//
// h_pchit          This is from auxregs, and is true when h_addr =
//                  ax_pc and aux_access = '1'.
//
// h_status32hit
//                  This is from auxregs, and is true when h_addr =
//                  ax_status32 and aux_access = '1'.
//
// h_dbhit          This is from auxregs, and is true when h_addr =
//                  ax_debug and aux_access = '1'.
//
// xflags[3:0]      from extensions. This contains alu result flags from
//                  the extension alu(s). It is loaded into the flags
//                  when there is an extension instruction at stage 3
//                  which wants to set the flags, provided that the
//                  appropriate pipeline enables are also true.
//                  In addition, the xsetflags signal can be used to
//                  force the flags to be loaded from xflags[].
//  
// x_flgen          Extension basecase flag update. This signal is true
//                  when any extension wants to update the basecase
//                  flags.
//
// xsetflags        from extensions. Load xflags[3:0] into aluflags_r_r
//                  at the end of the cycle, provided that extension-
//                  alu-flag-setting has been globally enabled in
//                  extutil, and that the enable for pipeline stage 3
//                  is valid, and the instruction in stage 3 is an
//                  extension instruction (x_idecode3 is true). This
//                  allows the extensions to override the normal flag
//                  -setting logic in rctl.
//
//  x_idecode3      From extensions. This signal will be true when the
//                  extension logic detects an extension instruction in
//                  stage 3. It is latched from x_idecode2 by the
//                  extensions when en2 is true at the end of a cycle.
//                  It is used to correctly generate p3condtrue,
//                  p3setflags, and to detect (along with xnwb) when a
//                  register writeback will take place.
//
// actionpt_hit_a   From debug_exts. This signal is the output of the
//                  OR-plane for the actionpoint debug hardware. When it
//                  is '1' it signifies that a valid condition has been
//                  detected, and the ARC should be halted. This is part
//                  of the actionpoint extension.
//
// p4_disable_r     From rctl module. This signals to the ARC that the
//                  pipeline has been flushed due to a breakpoint or
//                  sleep instruction. If it was due to a breakpoint
//                  instruction the ARC is halted via the 'en' bit, and
//                  the AH bit is set to '1' in the debug register.
//
// brk_inst_a       From rctl. This signals to the ARC that a
//                  breakpoint instruction has been detected in stage
//                  one of the pipeline. Hence, the halt bit in the flag
//                  register has to be updated in addition to the BH bit
//                  in the debug register. The pipeline is stalled when
//                  this signal is set to '1'.
//
//                  Note: The pipeline is flushed of instructions when
//                  the breakpoint instruction is detected, and it is
//                  important to disable each stage explicity. A normal
//                  instruction in stage one will mean that instructions
//                  in stage two, three and four will be allowed to
//                  complete. However, for an instruction in stage one 
//                  which is in the delay slot of a branch, loop or jump
//                  instruction means that stage two has to be stalled 
//                  as well. Therefore, only stages three and four will
//                  be allowed to complete.
//
// debug_if_r       Debug Memory Access. This is asserted true when a debug
//                  access to memory is in progress.
//
// p2b_opcode[4:0]  From rctl. Pipeline stage 2 instruction opcode word.
//
// p2b_iv           from rctl module, this signal indicates that the
//                  instruction opcode supplied in p2b_opcode is valid,
//                  as we allow blank slots to flow through the
//                  pipeline under certain conditions, and we don't
//                  want these phantom instructions to affect the state
//                  of the processor.
//
// p2int            from rctl, indicates that stage 2 contains an
//                  interrupt jump instruction, and that the pc should 
//                  be loaded with the address from the interrupt vector
//                  bus int_vec[31:0].
//
//
// instr_pending_r  This signal is true when an instruction fetch has
//                  been issued, and it has not yet completed. It is
//                  not true directly after a reset before the ARC has
//                  started, as no instruction fetch will have been
//                  issued. It is used to hold off host writes to the
//                  program counter when the ARC is halted, as these
//                  accesses will trigger an instruction fetch. Used
//                  here to prevent the PC from being updated when a
//                  host access is being held off.
//
// p2b_condtrue     from rctl, indicates that the instruction in stage 2
//                  has a branch/jump condition which is true, hence the
//                  jump will be taken provided that pcen is true.
//
// p2b_setflags     from rctl, this is the .F bit from the instruction
//                  word in stage 2. It is used to determine whether the
//                  flags should be loaded at the same time as the pc
//                  when doing a Jcc instruction.
//
// p2bint           Indicates that an interrupt-op instruction is in
//                  stage 2B. 
// 
// p3ilev1          from rctl, this is used in conjunction with p3int to 
//                  indicate which level of interrupt is being
//                  processed, and hence which of the interrupt mask
//                  bits should be cleared. It comes from bit 7 of the
//                  jump instruction word, which is set when a level1
//                  (lowest level) interrupt is being processed.
//
// p3int            from rctl, indicates that stage 3 contains an
//                  interrupt jump instruction, and that the appropriate
//                  interrupt mask bits should be cleared.
//
// p3iv             from rctl, this signal indicates that the
//                  instruction opcode supplied in p3opcode is valid,
//                  as we allow blank slots to flow through the
//                  pipeline under certain conditions, and we don't want
//                  these phantom instructions to affect the state of
//                  the processor.
//
// p3condtrue       from rctl. This signal is used in flags to control
//                  loading of flags with regular conditional
//                  instructions (ie not jumps/branches/loops etc). It
//                  is set according to whether the condition specified
//                  in the instruction's cc field is true, but if the
//                  instruction does not have a cc field (e.g. short
//                  immediate data) then it is always true.
//
// p3_docmprel_a    A mispredicted BRcc of BBITx has been taken by the ARC
//                  processor in stage 3. The corrective action will be taken
//                  in stage 4 where the correct PC will be presented at the
//                  instruction fetch interface.
//
// pcounter_jmp_restart_a    This signal is true when a delayed control
//                           transfer is pending.  If a control transfer
//                           is resolved and the Instruction cache system
//                           is busy fetching i.e. there is no
//                           instruction in stage 1 ivalid_aligned = '0'
//                           then the cache cannot accept any more
//                           fetches.  This is reconised and this bit is
//                           set, when the cache becomes free the machine
//                           will do the program counter update.
//
// p3setflags       from rctl. This signal is used by regular alu-type
//                  instructions and the jump instruction to control
//                  whether the supplied flags get stored. It is
//                  produced from the set-flags bit in the instruction
//                  word, but if that field is not present in the
//                  instruction (e.g. short immediate data is being
//                  used) then it will either come from the set-flag
//                  modes implied by which short immediate data register
//                  is used, or it will be set false if the instruction
//                  does not affect the flags.
//
// en3              from rctl, this is the stage 3->4 pipeline enable.
//
// s2val[31:0]      Stage 3 operand B value (latched by stage 2,
//                  including any shortcuts which may be appropriate).
//
// alurflags[3:0]   from the ALU. These signals are the flags produced
//                  by the ARC's alu after doing the calculations
//                  required by the instruction currently in stage 3.
//
// stop_step        This signal is set when the single instruction step
//                  has finished.
//
//====================== Output from this block ======================--
//
// aluflags_r       To the ALU. Direct from the latches, the Z N C V
//                  flags supplied to the ALU in stage 3.
//
// e1flag_r         Direct from the latch, the interrupt level 1 mask
//                  bit.
//
// e2flag_r         Direct from the latch, the interrupt level 2 mask
//                  bit.
//
// en_r             The global run bit.
//
// starting         This signal indicates that the ARC is starting, i.e.
//                  en goes high. It is used in debug to clear the sleep
//                  mode flag (bit 23) in the debug register on restart.
//
// selfhalt_r       Direct from the latch, this signal is set when the
//                  ARC is stopped, to show whether the ARC halted
//                  itself by using the FLAG instruction. It can be read
//                  from the debug register. The purpose is to handle
//                  the case when a 'stop' FLAG instruction is being
//                  single-stepped.
//
// actionhalt       From flags. This signal is set true when the
//                  actionpoint (if selected) has been triggered by a
//                  valid condition. The ARC pipeline is halted and
//                  flushed when this signal is '1'.
//
//                  Note: The pipeline is flushed of instructions when
//                  the breakpoint instruction is detected, and it is
//                  important to disable each stage explicity. A normal
//                  instruction in stage one will mean that instructions
//                  in stage two, three and four will be allowed to
//                  complete. However, for an instruction in stage one 
//                  which is in the delay slot of a branch, loop or jump 
//                  instruction means that stage two has to be stalled 
//                  as well. Therefore, only stages three and four will
//                  be allowed to complete.
//
// breakhalt_r      To debug. This signal is set true when the
//                  breakpoint (BRK) instruction has been detected in 
//                  stage one of the pipeline. The ARC pipeline is
//                  halted and flushed when this signal is '1'.
//
//                  Note: The pipeline is flushed of instructions when
//                  the breakpoint instruction is detected, and it is
//                  important to disable each stage explicity. A normal
//                  instruction in stage one will mean that instructions
//                  in stage two, three and four will be allowed to
//                  complete. However, for an instruction in stage one
//                  which is in the delay slot of a branch, loop or jump
//                  instruction means that stage two has to be stalled
//                  as well. Therefore, only stages three and four will
//                  be allowed to complete.
//
// do_inst_step_r   This signal is set when the single step flag (SS)
//                  and the instruction step flag (IS) in the debug
//                  register has been written to simultaneously through
//                  the host interface. It indicates that an instruction
//                  step is being performed. When the instruction step
//                  has finished this signal goes low.
//
//====================================================================--
//
module flags (clk,
              rst_a,
              actionpt_hit_a,
                actionpt_pc_brk_a,
              ctrl_cpu_start_r,
              arc_start_a,
              halt,
              step,
              inst_step,
              aux_dataw,
              aux_l1_wr,
              aux_l2_wr,
              h_dataw,
              h_write,
              h_pchit,
              h_dbhit,
              h_l1_wr,
              h_l2_wr,
              h_pcwr,
              h_status32hit,
              h_status32wr,
              xflags,
              x_flgen,
              xsetflags,
              x_idecode3,
              xcache_hold_host,
              brk_inst_a,
              en2b,
              fs2a,
              instr_pending_r,
              p1int,
              p2int,
              p2b_opcode,
              p2b_subopcode,
              p2b_iv,
              p2b_condtrue,
              p2b_setflags,
              p2bint,
              p4_disable_r,
              p3_flag_instr,
	      p3_sync_instr,
              p3iv,
              p3condtrue,
              p3_docmprel_a,
              p3setflags,
              p3int,
              p3ilev1,
              p3wba,
              en3,
              sleeping,
              s2val,
              alurflags,
              stop_step,
              debug_if_r,
              debug_if_a,	      
              x_multic_busy,
              pcounter_jmp_restart_a,

              aluflags_nxt,
              aluflags_r,
              do_inst_step_r,
              en_r,
              e1flag_r,
              e2flag_r,
              hold_host_intrpt_a,
              hold_host_multic_a,
              host_write_en_n_a,
              status32_l1_r,
              status32_l2_r,
              starting,
              breakhalt_r,
              actionhalt,
              selfhalt_r);

`include "arcutil_pkg_defines.v"
`include "arcutil.v"
`include "extutil.v"

   input                   clk; //  system clock
   input                   rst_a; //  system reset
   input                   actionpt_hit_a; 
   input                   actionpt_pc_brk_a;
   input                   ctrl_cpu_start_r;
   input                   arc_start_a; 
   input                   halt; 
   input                   step; 
   input                   inst_step; 
   input [DATAWORD_MSB:0]  aux_dataw; 
   input                   aux_l1_wr; 
   input                   aux_l2_wr; 
   input [DATAWORD_MSB:0]  h_dataw; 
   input                   h_write; 
   input                   h_pchit; 
   input                   h_dbhit; 
   input                   h_l1_wr; 
   input                   h_l2_wr; 
   input                   h_pcwr; 
   input                   h_status32hit; 
   input                   h_status32wr; 
   input  [3:0]            xflags; 
   input                   x_flgen; 
   input                   xsetflags; 
   input                   x_idecode3; 
   input                   xcache_hold_host; 
   input                   brk_inst_a; 
   input                   en2b; 
   input  [5:0]            fs2a; 
   input                   instr_pending_r; 
   input                   p1int;
   input                   p2int;
   input  [4:0]            p2b_opcode; 
   input  [5:0]            p2b_subopcode; 
   input                   p2b_iv; 
   input                   p2b_condtrue; 
   input                   p2b_setflags; 
   input                   p2bint;
   input                   p4_disable_r; 
   input                   p3_flag_instr;
   input                   p3_sync_instr; 
   input                   p3iv; 
   input                   p3condtrue; 
   input                   p3_docmprel_a; 
   input                   p3setflags; 
   input                   p3int; 
   input                   p3ilev1; 
   input  [5:0]            p3wba; 
   input                   en3; 
   input                   sleeping;
   input  [DATAWORD_MSB:0] s2val; 
   input  [3:0]            alurflags; 
   input                   stop_step; 
   input                   debug_if_r;
   input                   debug_if_a;   
   input                   x_multic_busy;
   input                   pcounter_jmp_restart_a;

   output [3:0]            aluflags_nxt; 
   output [3:0]            aluflags_r; 
   output                  do_inst_step_r; 
   output                  en_r; //  system go
   output                  e1flag_r; 
   output                  e2flag_r;
   output                  hold_host_intrpt_a;
   output                  hold_host_multic_a;
   output                  host_write_en_n_a;
   output [DATAWORD_MSB:0] status32_l1_r; 
   output [DATAWORD_MSB:0] status32_l2_r; 
   output                  starting; 
   output                  breakhalt_r; 
   output                  actionhalt; 
   output                  selfhalt_r; 

   wire   [3:0]            aluflags_nxt; 
   wire   [3:0]            aluflags_r; 
   wire                    do_inst_step_r; 
   wire                    en_r; 
   wire                    e1flag_r; 
   wire                    e2flag_r; 
   wire   [DATAWORD_MSB:0] status32_l1_r; 
   wire   [DATAWORD_MSB:0] status32_l2_r; 
   
   //  signals from debug extensions (debug_exts)
   wire                    starting;
   wire                    breakhalt_r; 
   wire                    actionhalt; 
   wire                    selfhalt_r; 

   //====================================================================--

   reg                     i_actionhalt_nxt; 
   reg                     i_actionhalt_r;
   wire   [3:0]            i_aluflags_nxt; 
   reg    [3:0]            i_aluflags_r; 
   wire                    i_alurload_a; 
   wire                    i_breakhalt_nxt; 
   reg                     i_breakhalt_r;
   reg                     i_do_inst_step_r;
   wire                    i_dostep_nxt; 
   reg                     i_dostep_r; 
   wire                    i_e1flag_nxt; 
   reg                     i_e1flag_r; 
   wire                    i_e2flag_nxt; 
   reg                     i_e2flag_r; 
   wire                    i_en_nxt; 
   reg                     i_en_r; 
   wire                    i_extload_a; 
   wire                    i_h_db_halt_a; 
   wire                    i_h_en_write_a; 
   wire                    i_h_en_write32_a; 
   wire                    i_hold_host_intrpt_a;
   wire                    i_hold_host_multic_a;
   wire                    i_hostwrite_a; 
   wire                    i_hostwrite32_a;
   wire                    i_host_write_en_a;
   wire                    i_host_write_en_n_a;
   wire                    i_dojcc_a; 
   wire                    i_doflag_a; 
   wire                    i_doint_a; 
   wire                    i_no_flag_change_a;
   wire                    i_one_a; 
   wire                    i_postrst_a; 
   wire                    i_p3do_ilink1_nxt;
   reg                     i_p3do_ilink1_r;
   wire                    i_p3do_ilink2_nxt;
   reg                     i_p3do_ilink2_r;
   wire                    i_p3_ext_flagset_a; 
   wire                    i_p3xaluop_a; 
   reg                     i_r1q_r; 
   reg                     i_r2q_r; 
   wire                    i_selfhalt_nxt; 
   reg                     i_selfhalt_r; 
   wire   [DATAWORD_MSB:0] i_status32_l1_r;
   wire   [DATAWORD_MSB:0] i_status32_l2_r;
   wire   [AX_ST32_Z_N:0]  i_status_l1_nxt;
   reg    [AX_ST32_Z_N:0]  i_status_l1_r;
   wire   [AX_ST32_Z_N:0]  i_status_l2_nxt;
   reg    [AX_ST32_Z_N:0]  i_status_l2_r;
   wire                    i_starting_a;
   wire                    i_valid_en_write_a;
   wire                    i_intrpt_a;
   wire                    i_ctrl_cpu_start_a;
   reg                     i_cpu_start_r;
   wire                    i_cpu_start_a;
   wire                    i_debug_access_a;   

   // Constant tied high.
   //
   assign i_one_a = 1'b 1; 

   //  The flags are loaded by the jump instruction (at stage 2) when the
   //  PC is being loaded, but only if the .F option is used, thus setting
   //  p2b_setflags.
   //
   assign i_dojcc_a = ((p2b_opcode == OP_FMT1)      &
                       ((p2b_subopcode == SO_J) |
                        (p2b_subopcode == SO_J_D))    &
                        ((p2b_condtrue & p2b_iv) ==  1'b 1) &
                        ((p2b_setflags & en2b) == 1'b 1)) ?  1'b 1 : 
          1'b 0; 

   //  Here we set the flags from jump at stage 3, rather than stage 2.
   //  This allows JLcc.f to operate correctly, storing the present 
   //  flags, and restoring the flag values from the jump value.
   // 
   assign i_p3do_ilink1_nxt = ((i_dojcc_a == 1'b 1) &&
                               (fs2a == RILINK1)) ? 1'b 1 :
          1'b 0;

   assign i_p3do_ilink2_nxt = ((i_dojcc_a == 1'b 1) &&
                               (fs2a == RILINK2)) ?  1'b 1 :
          1'b 0;


   always @(posedge clk or posedge rst_a)
     begin : p3ilink_sync_PROC
        if (rst_a == 1'b 1)
          begin
             i_p3do_ilink1_r <= 1'b 0; 
             i_p3do_ilink2_r <= 1'b 0; 
          end
        else
          begin
             // Latch i_p3do_ilinkX_nxt into stage 3 if stage 2 enabled.
             // 
             if (en2b == 1'b 1)
               begin
                  i_p3do_ilink1_r <= i_p3do_ilink1_nxt;  
                  i_p3do_ilink2_r <= i_p3do_ilink2_nxt;  
               end
          end
     end

   //  Status register flag bits, ** including the global run signal en **
   //
   // Bit positions in the program counter/status register:
   //
   //              +-31----30----29----28-----27-----26----25--+
   //              |     |     |     |     |      |      |     |
   //              |  Z  |  N  |  C  |  V  |  E2  |  E1  |  H  |
   //              |     |     |     |     |      |      |     |
   //              +-------------------------------------------+
   //
   //
   //
   // Bit positions in the status32 register:
   //
   //       +-11---10---09---08---07---06---05---04---03---02---01---0-+
   //       |    |    |    |    |    |    |    |    |    |    |    |   |
   //       | Z  | N  | C  | V  | Rd | Rd | Rd | Rd | Rd | E2 | E1 | H |
   //       |    |    |    |    |    |    |    |    |    |    |    |   |
   //       +----------------------------------------------------------+
   //
   //
   //  Load flags (alu & interrupt mask flags) from the host register bus
   //  (i.e. from host) when h_addr=ax_pc and it's a write, and the ARC is
   //  stopped. ** Note that the H bit (en) is not loaded from the aux
   //  register bus, but directly from the host interface bus, as it can be
   //  written when the ARC is running. **
   //  .. and don't update when there is an instruction fetch pending, and
   //  the ARC is stopped, as the host write will be held off with hold_host.
   // 
   //  This signal uses the h_pcwr signal from aux_regs.v, which includes
   //  the stall condition xcache_hold_host - in order to prevent the flags 
   //  from updating before a cache-generated host stall has been removed.
   //
   assign i_hostwrite_a = h_pcwr; 
   assign i_hostwrite32_a = h_status32wr; 

   //  Load flags from xflags[3:0] when the extensions force us to
   //  (xsetflags), the risc control unit says we can (en3) and when the
   //  designer of the extensions has allowed forced flag setting to be
   //  performed (XT_ALUFLAGS), and when the instruction in stage 3 is an
   //  extension instruction, or when a regular extension ALU instruction
   //  is being executed, and p3setflags is true.
   //
   //  ** Note that XT_ALUFLAGS is a constant set in extutil **
   //
   //  Determine whether stage 3 contains a valid extension instruction.
   //
   assign i_p3xaluop_a = (x_flgen & XT_ALUOP); 

   //  Determine whether there is a flag-set request.
   //
   assign i_p3_ext_flagset_a = (xsetflags & XT_ALUFLAGS | p3setflags); 

   //  Calculate whether we want to set flags from xflags[3:0].
   //
   assign i_extload_a = (i_p3xaluop_a & i_p3_ext_flagset_a) ;
   

   //  Load the ALU result flags when: a) the instruction's condition was
   //                                     true
   //                             and  b) flag-setting was requested
   //                                     somehow
   //                             and  c) the cycle is being allowed to
   //                                     complete
   //                             and  d) not an extension instruction.
   // 
   //                             and  e) not a Jcc.f [ilinkX].
   //
   //                             and  f) not a flag instruction.
   //
   //                             and  g) not a sync instruction.
   //
   //                             and  h) not a host write
   //
   assign i_alurload_a = (en3 & 
                          p3condtrue & 
                          p3setflags & 
                          p3iv & 
                          (~x_idecode3) &
                          (~i_p3do_ilink1_r) &
                          (~i_p3do_ilink2_r) &
                          (~p3_flag_instr) &
			  (~p3_sync_instr) & 
                          (~i_hostwrite_a) &
                          (~i_hostwrite32_a))   ;
   
   //  Load the ALU flags from the stage 3 operand b (s2val) bus when it's
   //  a valid FLAG instruction and when any condition is true (p3condtrue).
   // 
   //  The aluflags_r and interrupt mask bits are not set when the H bit is
   //  being set. (This allows for starting and stopping the ARC using the
   //  FLAG instruction without messing up the rest of the flags).
   //
   assign i_doflag_a = (p3_flag_instr & p3iv & p3condtrue & en3); 

   //   Clear one or both of the interrupt mask bits at the same time as the 
   //   PC is being loaded with the interrupt vector.
   //
   assign i_doint_a = (p3int & en3);
   
   
   assign i_no_flag_change_a = ~(i_hostwrite_a     |
                                 i_hostwrite32_a   |
                                 i_p3do_ilink1_r   |
                                 i_p3do_ilink2_r   |
                                 i_extload_a       |
                                 (i_doflag_a
                                  &
                                  (~s2val[F_H_N])) |
                                 i_alurload_a);
   
   //  Make the new values for Z N C V //
   //
   assign i_aluflags_nxt = ((h_dataw[31:28] & {(FOUR){i_hostwrite_a}})
                            |
                            (h_dataw[STATUS32_Z_N:
                                    STATUS32_V_N] & {(FOUR){i_hostwrite32_a}}) 
                            | 
                            (i_status_l1_r[AX_ST32_Z_N:
                                          AX_ST32_V_N] & {(FOUR){i_p3do_ilink1_r}})
                            |
                            (i_status_l2_r[AX_ST32_Z_N:
                                          AX_ST32_V_N] & {(FOUR){i_p3do_ilink2_r}}) 
                            | 
                            (xflags & {(FOUR){i_extload_a}}) 
                            |
                            (s2val[F_Z_N:F_V_N] & {(FOUR){(i_doflag_a &
                                                       ~s2val[F_H_N])}} )
                            |
                            (alurflags & {(FOUR){i_alurload_a}}) 
                            |
                            (i_aluflags_r &  {(FOUR){i_no_flag_change_a}})); 

   //  Make the new value for the interrupt level 1 mask bit //
   // 
   assign i_e1flag_nxt = ((i_p3do_ilink1_r & en3) == 1'b 1)     ?
          i_status_l1_r[AX_ST32_E1_N] : 
                         ((i_p3do_ilink2_r & en3) == 1'b 1)     ?
          i_status_l2_r[AX_ST32_E1_N] : 
                         (i_hostwrite_a          == 1'b 1)    ?
          h_dataw[SR_E1_N] : 
                         (i_hostwrite32_a        == 1'b 1)    ?
          h_dataw[STATUS32_E1_N] : 
                         (i_doint_a              == 1'b 1)    ?
          1'b 0 : 
                         ((i_doflag_a             == 1'b 1) &&
                          (s2val[F_H_N]           == 1'b 0) &&
                          (en3                    == 1'b 1))    ?
          s2val[F_E1_N] : 
                          ((sleeping              == 1'b 1) &&
                           (en3                   == 1'b1))     ?
          (s2val[0] | i_e1flag_r) :
          i_e1flag_r; 


   //  Make the new value for the interrupt level 2 mask bit //
   //  ** Note that a level 1 interrupt (p3ilev1 = '1') does not clear the
   //     e2 bit **
   //
   assign i_e2flag_nxt = ((i_p3do_ilink1_r & en3) == 1'b 1)    ?
          i_status_l1_r[AX_ST32_E2_N] :
                         ((i_p3do_ilink2_r & en3) == 1'b 1)    ?
          i_status_l2_r[AX_ST32_E2_N] : 
                         (i_hostwrite_a          == 1'b 1)   ?
          h_dataw[SR_E2_N] : 
                         (i_hostwrite32_a        == 1'b 1)   ?
          h_dataw[STATUS32_E2_N] : 
                         ((i_doint_a              == 1'b 1) &&
                          ((~p3ilev1)             == 1'b 1))   ?
          1'b 0 : 
                         ((i_doflag_a             == 1'b 1) &&
                          (s2val[F_H_N]           == 1'b 0) && 
                          (en3                    == 1'b 1))   ?
          s2val[F_E2_N] : 
                          ((sleeping              == 1'b 1) &&
                           (en3                   == 1'b1))    ?
          (s2val[1] | i_e2flag_r) :
          i_e2flag_r; 


   //======================== en Generation Logic =======================--
   // 
   //  Produce a signal which is true during the cycle following a reset.
   //  This signal is used to load the required value into en to allow the
   //  ARC to start running after a reset.
   // 
   //  Two latches are used here so that i_postrst_a is true for a whole
   //  cycle, and to reduce the possibility of metastable states due to the 
   //  likely asynchronous nature of the reset line.
   // 
   always @(posedge rst_a or posedge clk)
     begin : r1l_sync_PROC
        if (rst_a == 1'b 1)
          begin
             i_r1q_r <= 1'b 0; 
          end
        else
          begin
             i_r1q_r <= i_one_a;   
          end
     end

   always @(posedge rst_a or posedge clk)
     begin : r2l_sync_PROC
        if (rst_a == 1'b 1)
          begin
             i_r2q_r <= 1'b 0; 
          end
        else
          begin
             i_r2q_r <= i_r1q_r;   
          end
     end

   assign i_postrst_a = (i_r1q_r & (~i_r2q_r)); 


   //  Single stepping functions.
   // 
   //  Step only when the ARC is stopped, and stop again on the following
   //  cycle provided that the host has not modified the en bit.
   // 
   //  *** Note that if an instruction which writes '0' to the H bit is
   //  executed, it will be ignored, and the processor will go back into the
   //  halted state.
   // 
   assign i_dostep_nxt = (step & ~i_en_r); 

   always @(posedge rst_a or posedge clk)
     begin : step_sync_PROC
        if (rst_a == 1'b 1)
          begin
             i_dostep_r <= 1'b 0;  
          end
        else
          begin
             i_dostep_r <= i_dostep_nxt;   
          end
     end

   //  If the Instruction Step flag (IS) in the debug register is written to
   //  as the same time as the Single Step flag (SS) an instruction step
   //  will be performed.
   //
   always @(posedge rst_a or posedge clk)
     begin : inst_step_sync_PROC
        if (rst_a == 1'b 1)
          begin
             i_do_inst_step_r <= 1'b 0;    
          end
        else
          begin
             if ((step      == 1'b 1) &&
                 (i_en_r    == 1'b 0) &&
                 (inst_step == 1'b 1))
               begin
                  i_do_inst_step_r <= 1'b 1; 
               end
             else if (stop_step == 1'b 1)
               begin
                  i_do_inst_step_r <= 1'b 0; 
               end
          end
     end

   // There is an interrupt in the processor pipeline.
   //
   assign i_intrpt_a = p1int | p2int | p2bint | p3int;

   assign i_valid_en_write_a = h_write &
                               (~xcache_hold_host) & 
                               (~(instr_pending_r & ~i_en_r)) &
                               (~(i_intrpt_a & i_en_r)) &
                               (~x_multic_busy);


   //  The halt bit can be loaded at any time by the host processor
   // 
   //  Now includes xcache_hold_host signal to ensure that host pc/status
   //  writes can be stalled by the instruction cache system. It also checks
   //  for interrupts when the processor is running.
   // 
   assign i_h_en_write_a = ((h_pchit            == 1'b 1) &&
                            (i_valid_en_write_a == 1'b 1)) ?  1'b 1 : 
          1'b 0; 

   assign i_h_en_write32_a = ((h_status32hit      == 1'b 1) &&
                              (i_valid_en_write_a == 1'b 1)) ? 1'b 1 : 
          1'b 0; 

   // Clear the actionpoint halt when restarting the processor.
   //
   assign i_host_write_en_a = (i_h_en_write_a &
                              (~h_dataw[SR_H_N]) &
                              (~debug_if_r)) |
                              (i_h_en_write32_a & 
                              (~h_dataw[STATUS32_EN_N]) & 
                              (~debug_if_r));

   // The host is held off when any of the following are true:
   //
   // [1] The host is halting the processor by writing to the STATUS register
   //     when a multi-cylce operation is in progress.
   //
   // [2] The host is halting the processor by writing to the STATUS32 register
   //     when a multi-cylce operation is in progress.
   //
   // [1] The host is halting the processor by writing to the DEBUG register
   //     when a multi-cylce operation is in progress.
   //
   assign i_hold_host_multic_a = (i_h_en_write_a &
                                  h_dataw[SR_H_N] &
                                  x_multic_busy) |
                                 (i_h_en_write32_a & 
                                  h_dataw[STATUS32_EN_N] & 
                                  x_multic_busy) |
                                 (h_dbhit &
                                  h_write & 
                                  h_dataw[DB_HALT_N] &
                                  i_en_r  &
                                  x_multic_busy);

   assign i_hold_host_intrpt_a = ((i_h_en_write_a &
                                   h_dataw[SR_H_N] &
                                   i_intrpt_a) |
                                  (i_h_en_write32_a & 
                                   h_dataw[STATUS32_EN_N] & 
                                   i_intrpt_a) |
                                  (h_dbhit &
                                   h_write & 
                                   h_dataw[DB_HALT_N] &
                                   i_en_r  &
                                   i_intrpt_a));

   assign i_host_write_en_n_a = ((i_h_en_write_a &
                                  (~h_dataw[SR_H_N]) &
                                  debug_if_r) |
                                 (i_h_en_write32_a & 
                                  (~h_dataw[STATUS32_EN_N]) & 
                                  debug_if_r));

   //  The ARC can be halted whilst it is running by writing bit 1 of the
   //  debug register with '1'.  There are cases where it can be held off:
   // 
   // [1] Provided a BRcc/BBITx has not been mispredicted.
   //
   // [2] The debug register will not be halted when a multi-cycle instruction
   //     is in progress since it will be held off until it is completed.
   //
   // [3] There is an interrupt being serviced in the pipeline.
   //
   // [4] Processor is not halted if a delayed control transfer is pending
   //
   // This only works from the host port, hence the ARC cannot be halted
   // by writing to the debug register with an SR.
   // 
   assign i_h_db_halt_a = ((h_dbhit             == 1'b 1) &&
                           (h_write             == 1'b 1) &&
                           (h_dataw[DB_HALT_N]  == 1'b 1) &&
                           (i_en_r              == 1'b 1) &&
                           (p3_docmprel_a       == 1'b 0) &&
                           (pcounter_jmp_restart_a == 1'b0) &&
                           (x_multic_busy       == 1'b 0)) ?
        (~i_intrpt_a) : 
          1'b 0; 

   //  Make new value for the en bit.
   // 
   //  Note that the 'H' bit in the status register is the complement of the
   //  en signal, so writing '1' to the status register halts the ARC.
   // 
   //  Note that en is set to i_dostep_nxt when i_dostep_r = '1'. This will
   //  allow multiple host writes to the 'step' bit in the debug register to
   //  do many single step operations. The FLAG instruction is the lowest
   //  priority to prevent a single step of an ordinary FLAG instruction 
   //  (which sets the H bit to 0) from allowing the ARC to start
   //  free-running.
   // 
   //  Note that a host write to the 'H' bit has a higher priority than the
   //  the step line. This must be taken into consideration if the xstep
   //  external-step line is being used, as this could be true at the same
   //  time as a host write was taking place, whereas the host could not
   //  write both to the debug register (step) and to the pc (H) at the
   //  same time.
   // 
   //   The debug register can be written whilst the ARC is running.
   //
   assign i_en_nxt =  (i_ctrl_cpu_start_a == 1'b1 ||
                       i_cpu_start_a == 1'b1) ?
          1'b1 :
                      ((halt              == 1'b 1) ||
                       (i_h_db_halt_a     == 1'b 1))   ?
          1'b 0 : 
                      (i_postrst_a       == 1'b 1)   ?
          arc_start_a : 
                      ((i_h_en_write_a    == 1'b 1) &&
                       (debug_if_r        == 1'b 0))   ?
          (~h_dataw[SR_H_N]) : 
                      ((i_h_en_write32_a  == 1'b 1) &&
                       (debug_if_r        == 1'b 0))   ?
          (~h_dataw[STATUS32_EN_N]) : 
                      ((i_dostep_r        == 1'b 1) &&
                       (i_do_inst_step_r  == 1'b 0))   ?
          i_dostep_nxt : 
                      (i_do_inst_step_r  == 1'b 1)   ?
          (~stop_step) : 
                      (((i_actionhalt_nxt == 1'b 1)  ||
                        (actionpt_pc_brk_a == 1'b 1)  ||                 
                        (brk_inst_a       == 1'b 1)) && 
                       (p4_disable_r     == 1'b 1))  ?
          1'b 0 : 
                      ((i_doflag_a        == 1'b 1) &&
                       (en3               == 1'b 1))   ?
          (~s2val[F_H_N]) : 
           i_en_r | step; 


   //============================ Latch for en ==========================--
   //
   // Update the Processor running 'en' bit.
   //
   always @(posedge rst_a or posedge clk)
     begin : en_sync_PROC
        if (rst_a == 1'b 1)
          begin
             i_en_r <= 1'b0;
          end
        else
          begin
             i_en_r <= i_en_nxt; 
          end
     end

   // Used for delaying the starting of the processor if a debug operation is
   // taking place.
   //
   always @(posedge rst_a or posedge clk)
     begin : cpu_start_PROC
        if (rst_a == 1'b 1)
          begin
	     i_cpu_start_r <= 1'b0;
          end
        else
          begin
	  
	     if (ctrl_cpu_start_r==1'b1 & i_en_r==1'b0 & 
	         i_debug_access_a==1'b1 & i_cpu_start_r==1'b0)
	         i_cpu_start_r <= 1'b1;
             else if (i_cpu_start_a==1'b1) 
	         i_cpu_start_r <= 1'b0;
			  
          end
     end
            
   // External start signal will force the ARC to run when set
   // as long as ARC is currently halted.
   //
   assign i_ctrl_cpu_start_a = (i_en_r == 1'b0) ? (ctrl_cpu_start_r & ~i_debug_access_a) : 1'b0;
   
   // for delayed start when the a debug operation was in progress
   //
   assign i_cpu_start_a = i_cpu_start_r & ~debug_if_r;   
   
   // determine whether a debug access is taking place
   //
   assign i_debug_access_a = debug_if_r | debug_if_a;

   //  Starting signal
   // 
   //  This signal is set true when the ARC is starting
   //
   assign i_starting_a = ((i_en_nxt == 1'b 1) && (i_en_r == 1'b 0)) ?
          1'b 1 : 
          1'b 0; 

   //  Selfhalt signal. 
   //  
   //  This signal is set true when the FLAG instruction was used to stop the
   //  ARC. It is cleared whenever the ARC is allowed to execute another 
   //  instruction.
   //
   assign i_selfhalt_nxt = ((s2val[F_H_N]  == 1'b 1) &&
                            (i_doflag_a    == 1'b 1) &&
                            (en3           == 1'b 1)) ?
          1'b 1 : 
                           (i_en_nxt      == 1'b 0) ?
          i_selfhalt_r : 
          1'b 0; 

   // Update the Self halt flag register.
   //
   always @(posedge rst_a or posedge clk)
     begin : selfhalt_sync_PROC
        if (rst_a == 1'b 1)
          begin
             i_selfhalt_r <= 1'b 0;    
          end
        else
          begin
             i_selfhalt_r <= i_selfhalt_nxt;   
          end
     end

   //  Breakpoint Instruction halt signal. 
   //  
   //  This signal is set true when the breakpoint instruction is detected in 
   //  stage 1 of the pipeline. It is cleared whenever the ARC is allowed
   //  to execute another instruction.
   //
   assign i_breakhalt_nxt = (brk_inst_a   == 1'b 1) ?
          1'b 1 : 
                            (i_en_nxt     == 1'b 0) ?
          i_breakhalt_r : 
          1'b 0; 


   // Update the Break halt flag register.
   //
   always @(posedge rst_a or posedge clk)
     begin : bpt_sync_PROC
        if (rst_a == 1'b 1)
          begin
             i_breakhalt_r <= 1'b 0;   
          end
        else
          begin
             i_breakhalt_r <= i_breakhalt_nxt; 
          end
     end

   //  Actionpoint halt signal. 
   //  
   //  This signal is set true when the output of the OR-plane for the 
   //  Actionpoint is set to '1' thus halting the ARC. It is cleared 
   //  whenever the ARC is allowed to execute another instruction.
   //
   always @(actionpt_hit_a or 
            i_dostep_r or
            i_dostep_nxt or 
            i_actionhalt_r or 
            i_host_write_en_a)
     begin : apt_comb_async_PROC
        if (i_host_write_en_a == 1'b 1)
          begin
             i_actionhalt_nxt = 1'b 0; 
          end
        else if (i_dostep_r == 1'b 1 )
          begin
              i_actionhalt_nxt = i_dostep_nxt;  
          end
        else if (actionpt_hit_a == 1'b 1 )
          begin
             i_actionhalt_nxt = 1'b 1; 
          end
        else
          begin
             i_actionhalt_nxt = i_actionhalt_r;    
          end
     end

   // Update the Actionpoint Halt flag register.
   //
   always @(posedge clk or posedge rst_a)
     begin : apt_sync_PROC
        if (rst_a == 1'b 1)
          begin
             i_actionhalt_r <= 1'b 0;   
          end
        else
          begin
             i_actionhalt_r <= i_actionhalt_nxt; 
          end
     end

   //  The ALU flag register, and both interrupt mask bits.
   // 
   //  ** Note that the e1 and e2 interrupt mask bits are both cleared on
   //     reset, this disabling interrupts in the inital state. **
   //
   // Update the Arithmetic ZNCV flag register.
   //
   always @(posedge clk or posedge rst_a)
     begin : alu_flags_sync_PROC
        if (rst_a == 1'b 1)
          begin
             i_aluflags_r <= {(FOUR){1'b 0}}; 
          end
        else
          begin
             i_aluflags_r <= i_aluflags_nxt;   

          end
     end

   // Update the Level 1 Interrupt Enable E1 flag register.
   //
   always @(posedge rst_a or posedge clk)
     begin : e1bit_sync_PROC
        if (rst_a == 1'b 1)
          begin
             i_e1flag_r <= 1'b 0;  
          end
        else
          begin
             i_e1flag_r <= i_e1flag_nxt;   
          end
     end

   // Update the Level 2 Interrupt Enable E2 flag register.
   //
   always @(posedge rst_a or posedge clk)
     begin : e2bit_sync_PROC
        if (rst_a == 1'b 1)
          begin
             i_e2flag_r <= 1'b 0;  
          end
        else
          begin
             i_e2flag_r <= i_e2flag_nxt;   
          end
     end


   //======================= Latch for Status L1/L2 =====================--
   //
   // The Level 1 interrupt status register is updated under the
   // following conditions:
   //
   // [1] when an interrupt reaches stage 3 and the writeback matches
   //     the inlink1 address in the register file,
   // [2] the host writes to the L1 status register,
   // [3] the processor writes to the L1 status register.
   //
   assign i_status_l1_nxt = ((p3wba == RILINK1) &&
                             (p3int == 1'b 1))        ?
          {i_aluflags_r, i_e2flag_r, i_e1flag_r} :
                            (aux_l1_wr == 1'b 1)    ?
          {aux_dataw[STATUS32_Z_N : STATUS32_V_N],
           aux_dataw[STATUS32_E2_N : STATUS32_E1_N]} :
                            (h_l1_wr == 1'b 1)      ?
          {h_dataw[STATUS32_Z_N : STATUS32_V_N],
           h_dataw[STATUS32_E2_N : STATUS32_E1_N]} :
          i_status_l1_r;


   // The Level 2 interrupt status register is updated under the
   // following conditions:
   //
   // [1] when an interrupt reaches stage 3 and the writeback matches
   //     the inlink2 address in the register file,
   // [2] the host writes to the L2 status register,
   // [3] the processor writes to the L2 status register.
   //
   assign i_status_l2_nxt = ((p3wba == RILINK2) &&  
                             (p3int == 1'b 1))     ?
          {i_aluflags_r, i_e2flag_r, i_e1flag_r} :
                            (aux_l2_wr == 1'b 1) ?
          {aux_dataw[STATUS32_Z_N : STATUS32_V_N],
           aux_dataw[STATUS32_E2_N : STATUS32_E1_N]} :
                            (h_l2_wr == 1'b 1)   ?
          {h_dataw[STATUS32_Z_N : STATUS32_V_N],
           h_dataw[STATUS32_E2_N : STATUS32_E1_N]} :
          i_status_l2_r;

   // Update the Level 1/Level 2 Status registers.
   //
   always @(posedge rst_a or posedge clk)
     begin : status_l1_l2_sync_PROC
        if (rst_a == 1'b 1)
          begin
             i_status_l1_r <= {(SIX){1'b 0}};    
             i_status_l2_r <= {(SIX){1'b 0}};    
          end
        else
          begin
             i_status_l1_r <= i_status_l1_nxt; 
             i_status_l2_r <= i_status_l2_nxt; 
          end
     end

   assign i_status32_l1_r = {TWENTY_ZERO,
                             i_status_l1_r[AX_ST32_Z_N : AX_ST32_V_N],
                             FIVE_ZERO,
                             i_status_l1_r[AX_ST32_E2_N : AX_ST32_E1_N],
                             ONE_ZERO};

   assign i_status32_l2_r = {TWENTY_ZERO,
                             i_status_l2_r[AX_ST32_Z_N : AX_ST32_V_N],
                             FIVE_ZERO,
                             i_status_l2_r[AX_ST32_E2_N : AX_ST32_E1_N],
                             ONE_ZERO};

   //============================ Output drives =========================--
   //
   assign actionhalt     = i_actionhalt_nxt; 
   assign aluflags_nxt       = i_aluflags_nxt; 
   assign aluflags_r         = i_aluflags_r; 
   assign breakhalt_r        = i_breakhalt_r; 
   assign do_inst_step_r     = i_do_inst_step_r; 
   assign e1flag_r           = i_e1flag_r; 
   assign e2flag_r           = i_e2flag_r; 
   assign en_r               = i_en_r; 
   assign hold_host_intrpt_a = i_hold_host_intrpt_a;
   assign hold_host_multic_a = i_hold_host_multic_a;
   assign host_write_en_n_a  = i_host_write_en_n_a;
   assign selfhalt_r         = i_selfhalt_r; 
   assign starting           = i_starting_a; 
   assign status32_l1_r      = i_status32_l1_r; 
   assign status32_l2_r      = i_status32_l2_r; 

endmodule // module flags
