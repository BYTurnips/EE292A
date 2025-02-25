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
// This file contains all the auxiliary registers and associated logic,
// including:
//
//            Program counter / Status registers
//            Loop start and loop end registers
//            Identity register
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
// ctrl_cpu_start_r This signal comes from the 'xctrl_cpu_start_r' input
//                  and will start the ARC running when it is halted.
//
// aux_addr[31:0]   from hostif. This is the auxiliary register bus 
//                  address value. Width of decode is set by AUXDECSZ. 
//
// aux_dataw[31:0]  from hostif. This is the auxiliary register bus 
//                  write data value.
//
// aux_write        from hostif. This signal indicates that a write
//                  (either from the ARC or host) is being performed to
//                  the auxiliary register specified on aux_addr[31:0].
//
// actionpt_status_r
//                  from debug_exts. This field shows which of the
//                  actionpoints were triggered in the OR-plane.The 
//                  actionpoints extension has to be selected for this
//                  field.
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
// currentpc_r      This is a latched result, which is passed to the 
//                  memory controller as being the address from which to
//                  fetch the next opcode.
//
// en2              from rctl, this is the stage 2->3 pipeline enable.
//
// debug_if_r       Debug Memory Access. This is asserted true when a debug
//                  access to memory is in progress.
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
// p1int            from int_unit. Indicates that an interrupt has been
//                  detected. This wakes up the ARC from sleep mode.
//
// p2int            Indicates that an interrupt-op instruction is in
//                  stage 2. This signal is used in coreregs.v to control
//                  the placing of the pc onto a source bus for writing
//                  back to the interrupt link registers, and by aux_regs
//                  to insert the interrupt vector int_vec[] into the
//                  program counter.
// 
// p2bint           Indicates that an interrupt-op instruction is in
//                  stage 2B. 
// 
// p3iv             from rctl, this signal indicates that the
//                  instruction opcode supplied in p3opcode is valid,
//                  as we allow blank slots to flow through the
//                  pipeline under certain conditions, and we don't
//                  want these phantom instructions to affect the
//                  state of the processor.
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
// p3int            from rctl, indicates that stage 3 contains an
//                  interrupt jump instruction, and that the appropriate
//                  interrupt mask bits should be cleared.
//
// p3ilev1          from rctl, this is used in conjunction with p3int to
//                  indicate which level of interrupt is being
//                  processed, and hence which of the interrupt mask
//                  bits should be cleared. It comes from bit 7 of the
//                  jump instruction word, which is set when a level1
//                  (lowest level) interrupt is being processed.
//
// en3              from rctl, this is the stage 3->4 pipeline enable.
//
// en_debug_r       This flag is the Enable Debug flag (ED), bit 24 in
//                  the DEBUG register. It enables the debug extensions
//                  when it is set. When it is cleared the debug
//                  extensions are switched off by gating the debug
//                  clock, but only if the option clock gating has been
//                  selected.
//
// s2val[31:0]      Stage 3 operand B value (latched by stage 2,
//                  including any shortcuts which may be appropriate).
//  
// alurflags[3:0]   from the ALU. These signals are the flags produced
//                  by the ARC's alu after doing the calculations
//                  required by the instruction currently in stage 3.
//
// lpending         from lsu. Set true when one or more delayed loads
//                  are pending.
//
// h_addr[31:0]     from mc/host. This is a 32-bit address (it may be
//                  smaller, but packed with zeroes) from the host which
//                  is used to access registers in the ARC in conjuction
//                  with aux_access and core_access. The width of the
//                  decode applied to this 32-bit quantity is defined by
//                  the AUXDECSZ constant, found in extutil. It is
//                  defined as being a 32-bit bus at this level to 
//                  maintain compatibility with the LR and SR
//                  instructions which can generate a 32-bit value for
//                  the address to be used for auxiliary register
//                  accesses.
//
// h_dataw[31:0]    from mc/host. Data from the host to be stored into
//                  registers in the ARC/extensions.
//
// h_write          from mc/host. When it is true, this signal indicates
//                  that a host write is taking place.
//
// aux_access       from mc/host. This signal is used to inform the ARC 
//                  that address supplied on h_addr[31:0] applies to
//                  the auxiliary register set. 
//
// xcache_hold_host from extensions. This signal is used in this block
//                  to allow an external cache system to hold off writes
//                  to the program counter whilst the cache is busy. It
//                  does this by detecting a PC write and asserting
//                  xcache_hold_host - thus holding the host device. It is
//                  used here to prevent a held off write to the program
//                  counter from being accepted by the core.
//
// drx_reg[31:0]    from extensions. This bus is used to provide data
//                  from registers implemented in extension logic. This
//                  will be ignored unless enabled using the XT_AUXREG
//                  constant in extutil.
//
// x_multic_busy    From xrctl. Multi-cycle extension is busy. This signal
//                  is true when the multicycle instruction that is currently
//                  being stepped is busy.  The signal will become false
//                  when the extension instruction is finished.
//
// xreg_hit         from extensions. This signal is used to indicate to
//                  the auxiliary register module that data is present
//                  on the drx_regs[31:0] bus, and should be driven onto
//                  aux_datar[].
//                  ** Note that existing auxiliary registers take
//                  priority if this signal is true when internal
//                  auxiliary registers are being accessed **
//
// x_da_am          from extensions. This signal is true when the
//                  address on h_addr[31:0] matches a dual access
//                  auxiliary registers provided by extension logic, and
//                  indicates that aux_regs should place the data on
//                  x_dar[] onto the aux_dar[] bus.
//
// x_dar[31:0]      from extensions. This is the host-side data from a
//                  dual access register provided by extension logic.
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
// xsetflags        from extensions. Load xflags[3:0] into aluflags_r
//                  at the end of the cycle, provided that extension-
//                  alu-flag-settdebug_exts.ving has been globally enabled in
//                  extutil, and that the enable for pipeline stage 3
//                  is valid, and the instruction in stage 3 is an
//                  extension instruction (x_idecode3 is true). This
//                  allows the extensions to override the normal flag
//                  -setting logic in rctl.
//
// x_idecode3       From extensions. This signal will be true when the
//                  extension logic detects an extension instruction in
//                  stage 3. It is latched from x_idecode2 by the
//                  extensions when en2 is true at the end of a cycle.
//                  It is used to correctly generate p3condtrue,
//                  p3setflags, and to detect (along with xnwb) when a
//                  register writeback will take place.
//
// halt             From top level. When this signal is set true, the
//                  ARC will stop running on the next cycle.
//
// id_arcnum[7:0]   This signal defines bits 15:8 of the ARC's identity
//                  register. It will be fixed at some value to allow
//                  different ARCs in a multiple ARC system to have a
//                  unique identity.
//
// loopend_r        Loop End Address Value.
//
// loopstart_r      Loop Start Address Value.
//
// xstep            from extensions. Single step on the next cycle if
//                  the ARC is stopped.
//
// p2sleep_inst     from rctl. This signal is true when a sleep
//                  instruction has been decoded in pipeline stage 2.
//                  When true the sleep mode flag ZZ (bit 23) in the
//                  debug register is set.
//
// stop_step        This signal is set when the single instruction step
//                  has finished.
//
// misaligned_err   LD/ST to a misaligned address detected
//
//====================== Output from this block ======================--
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
// aluflags_r       To the ALU. Direct from the latches, the Z N C V
//                  flags supplied to the ALU in stage 3.
//
// aux_datar[31:0]  to hostif. This is the data provided by the 
//                  auxiliary register set in response to a read. It
//                  does not include data from the pc/status register as
//                  these are handled in a special way. It also goes to
//                  the stage 3 alu multiplexer logic as it is used to
//                  load core registers as the result of an LR
//                  instruction.
//
// aux_dar[31:0]    to hostif. This is the data from the PC/status,
//                  semaphore and identity registers which can be read
//                  whilst the ARC is running, and hence does not go
//                  down the aux_datar[31:0] bus.
//
// aux_pchit        Set true when the auxiliary register address (from
//                  s2val when the ARC is running) matches the program 
//                  counter address. The decode takes account of the 
//                  constant in arcutil which determines the size of the
//                  auxiliary register decode.
//
// aux_pc32hit      Set true when the auxiliary register address (from
//                  s2val when the ARC is running) matches the 32-bit 
//                  program counter address. The decode takes account of
//                  the constant in arcutil which determines the size of
//                  the auxiliary register decode.
//
// da_auxam         to hostif. This signal is true when the address on
//                  the h_addr[31:0] matches one of the dual access
//                  auxiliary registers (pc/status, semaphore, and
//                  identity registers). (includes dual access
//                  registers provided by extensions).
//
// do_inst_step_r   This signal is set when the single step flag (SS)
//                  and the instruction step flag (IS) in the debug
//                  register has been written to simultaneously through
//                  the host interface. It indicates that an instruction
//                  step is being performed. When the instruction step
//                  has finished this signal goes low.
//
// e1flag_r         Direct from the latch, the interrupt level 1 mask
//                  bit.
//
// e2flag_r         Direct from the latch, the interrupt level 2 mask
//                  bit.
//
// en               The global run bit.
//
// en_debug_r       This flag is the Enable Debug flag (ED), bit 24 in
//                  the DEBUG register. It enables the debug extensions
//                  when it is set. When it is cleared the debug
//                  extensions are switched off by gating the debug
//                  clock, but only if the option clock gating has been
//                  selected.
//
// h_pcwr           To hostif. This signal is set true when the host is
//                  attempting to write to the pc/status register, and
//                  the ARC is stopped. It is used to trigger an
//                  instruction fetch when the PC is written when the
//                  ARC is stopped. This is necessary to ensure the
//                  correct instruction is executed when the ARC is
//                  restarted. It is also used to latch the new PC
//                  value.
//
// h_pcwr32         From aux_regs. This signal is set true when the host
//                  is attempting to write to the 32-bit pc register,
//                  and the ARC is stopped. It is used to trigger an
//                  instruction fetch when the PC is written when the
//                  ARC is stopped. This is necessary to ensure the
//                  correct instruction is executed when the ARC is
//                  restarted.
//
// sleeping         This is the sleep mode flag ZZ in the debug register
//                  (bit 23). It stalls the pipeline when true.
//
//====================================================================--
//
module aux_regs (clk,
                 rst_a,
                 ctrl_cpu_start_r,
                 arc_start_a,
                 aux_addr,
                 aux_dataw,
                 aux_write,
                 brk_inst_a,
                 stop_step,
                 currentpc_r,
                 en2,
                 fs2a,
                 instr_pending_r,
                 p2int,
                 en2b,
                 p2b_opcode,
                 p2b_subopcode,
                 p2b_iv,
                 p2b_condtrue,
                 p2b_setflags,
                 p1int,
                 p2bint,
                 p3iv,
                 p3condtrue,
                 p3_docmprel_a,
                 p3setflags,
                 p3int,
                 p3ilev1,
                 p3wba,
                 en3,
                 s2val,
                 alurflags,
                 p3_flag_instr,
		 p3_sync_instr,
                 debug_if_r,
                 debug_if_a,	 
                 lpending,
                 aux_access,
                 inst_stepping,
                 h_addr,
                 h_dataw,
                 h_write,
		 noaccess,
                 xcache_hold_host,
                 drx_reg,
                 id_arcnum,
                 xreg_hit,
                 x_da_am,
                 x_dar,
                 xflags,
                 x_flgen,
                 x_idecode3,
                 xsetflags,
                 actionpt_hit_a,
                 p4_disable_r,
                 actionpt_status_r,
                 en_debug_r,
                 actionpt_pc_brk_a,
                 p2sleep_inst,
                 halt,
                 xstep,
                 loopstart_r,
                 loopend_r,
                 x_multic_busy,
                 pcounter_jmp_restart_a,
                 misaligned_err,

                 en_misaligned,
                 en,
                 aux_datar,
                 aux_dar,
                 aux_pchit,
                 aux_pc32hit,
                 da_auxam,
                 do_inst_step_r,
                 h_pcwr,
                 h_pcwr32,
                 h_status32,
                 aluflags_nxt,
                 aluflags_r,
                 e1flag_r,
                 e2flag_r,
                 actionhalt,
                 hold_host_intrpt_a,
                 hold_host_multic_a,
                 host_write_en_n_a,
                 reset_applied_r,
                 sleeping_r2,
                 sleeping,
		 step,
		 inst_step);

`include "arcutil_pkg_defines.v"
`include "arcutil.v"
`include "extutil.v"
`include "xdefs.v"

input          clk;  //  system clock
input          rst_a; //  system reset
input          ctrl_cpu_start_r;
input          arc_start_a; 

// hostif connections to auxiliary registers

input   [31:0] aux_addr; 
input   [31:0] aux_dataw; 
input          aux_write; 

// connections to rctl stage 1

input          brk_inst_a; 
input          stop_step; 

//  connections to coreregs, stage 2

input   [PC_MSB:0] currentpc_r; 

//  connections to rctl, stage 2

input          en2; 
input   [5:0]  fs2a; 
input          instr_pending_r; 
input          p2int;

//  connections to rctl, stage 2B

input          en2b;
input   [4:0]  p2b_opcode; 
input   [5:0]  p2b_subopcode; 
input          p2b_iv; 
input          p2b_condtrue; 
input          p2b_setflags; 

// connections to interrupt unit
input          p1int; 
input          p2bint;

// connections to rctl and ALU, stage 3

input          p3iv; 
input          p3condtrue; 
input          p3_docmprel_a;
input          p3setflags; 
input          p3int; 
input          p3ilev1; 
input   [5:0]  p3wba; 
input          en3; 
input   [31:0] s2val;  
input   [3:0]  alurflags; 
input          p3_flag_instr; 
input          p3_sync_instr;

// Debug Memory Access

input          debug_if_r;
input          debug_if_a;

//  from lsu

input          lpending; 

//  Group Four : Host interface

input          aux_access; 
input   [31:0] h_addr; 
input   [31:0] h_dataw; 
input          h_write; 
input          noaccess;
input          xcache_hold_host; 

// Signals from extensions

input   [31:0] drx_reg; 
input   [7:0]  id_arcnum; 
input          xreg_hit; 
input          x_da_am; 
input   [31:0] x_dar; 
input   [3:0]  xflags; 
input          x_flgen; 
input          x_idecode3; 
input          xsetflags; 

// Debugging and sleep mode

input          inst_stepping;
input          actionpt_hit_a; 
input          p4_disable_r; 
input   [NUM_APS - 1:0] actionpt_status_r; 
input          en_debug_r; 
input          actionpt_pc_brk_a;
input          p2sleep_inst; 
input          halt; 
input          xstep; 

// LP_COUNT logic
   
input   [PC_MSB:0] loopstart_r; 
input   [PC_MSB:0] loopend_r; 

// Multi Cycle Instruction

input          x_multic_busy;

// Delayed control transfer is pending

input          pcounter_jmp_restart_a;

// Misaligned access error
input          misaligned_err;

//  system go

output         en_misaligned;
output         en;

// hostif connections to auxiliary registers

output  [31:0] aux_datar; 
output  [31:0] aux_dar; 
output         aux_pchit; 
output         aux_pc32hit; 
output         da_auxam; 

// connections to rctl stage 1

output          do_inst_step_r; 
output          h_pcwr; 
output          h_pcwr32; 
output          h_status32; 

// connections to rctl and ALU, stage 3

output  [3:0]  aluflags_nxt; 
output  [3:0]  aluflags_r; 
output         e1flag_r; 
output         e2flag_r; 

// Debugging and sleep mode

output         actionhalt; 
output         hold_host_intrpt_a;
output         hold_host_multic_a;
output         host_write_en_n_a;
output         reset_applied_r; 
output         sleeping_r2;
output         sleeping;
output         step;
output         inst_step;


wire           en; 
wire    [31:0] aux_datar; 
wire    [31:0] aux_dar; 
wire           aux_pchit; 
wire           aux_pc32hit; 
wire           h_status32; 

wire           da_auxam; 
wire           do_inst_step_r; 

wire           h_pcwr; 

wire    [3:0]  aluflags_r; 
wire           e1flag_r; 
wire           e2flag_r; 

wire           actionhalt; 
wire           sleeping; 
wire           sleeping_r2;

//===================================================================//

wire    i_en_r;                //  internal en signal
wire    i_actionhalt_a; 
wire    [3:0] i_aluflags_nxt; 
wire    [3:0] i_aluflags_r; 
wire    i_aux_l1_hit_a;        //  }
wire    i_aux_l2_hit_a;        //  }
wire    i_aux_l1_wr_a;         //  }
wire    i_aux_l2_wr_a;         //  }
wire    i_aux_pchit_a;         //  }
wire    i_aux_pc32hit_a;       //  }
wire    i_aux_status32hit_a;   //  }
wire    i_aux_lshit_a;         //   } decodes from aux_addr
wire    i_aux_lehit_a;         //   }
wire    i_aux_dbhit_a;         //  }
wire    i_aux_misalign_ctrl_a;
reg     [1:0] i_misalign_ctrl_r;
wire    i_breakhalt_r; 
wire    [DATAWORD_MSB:0] i_debug_r; 
wire    i_e1flag_r; 
wire    i_e2flag_r; 

wire	i_h_aux_write_always_a;
wire    i_h_aux_write_a; 
wire    i_h_dbhit_a;              //  } decodes from h_addr and
wire    i_h_idhit_a;              //  } aux_access.
wire    i_h_l1_hit_a;             //  }
wire    i_h_l2_hit_a;             //  }
wire    i_h_l1_wr_a;              //  }
wire    i_h_l2_wr_a;              //  }
wire    i_h_pchit_a;              //  }
wire    i_h_pchit32_a;            //  }
wire    i_h_pcwr_a; 
wire    i_h_pcwr32_a; 
wire    i_h_status32hit_a;        //  }
wire    i_h_status32wr_a;         //  }
wire    [DATAWORD_MSB:0] i_host_pc_r;       //  pc/status reg
wire    [DATAWORD_MSB:0] i_identity_r;       //  identity register
wire    i_inst_step; 
wire    i_selfhalt_r; 
wire    i_starting; 
wire    [11:0] i_status12_r; 
wire    [DATAWORD_MSB:0] i_status32_l1_r; 
wire    [DATAWORD_MSB:0] i_status32_l2_r; 
wire    [DATAWORD_MSB:0] i_status32_r; 
wire    i_step; 


   // Produce decodes for individual auxiliary registers from aux_addr
   // (uses special decode function which only decodes to AUXDECSZ 
   // width)
   //
   assign i_aux_dbhit_a       = auxdc(aux_addr, AX_DEBUG_N);
   assign i_aux_l1_hit_a      = auxdc(aux_addr, AX_STATUS32_L1_N); 
   assign i_aux_l2_hit_a      = auxdc(aux_addr, AX_STATUS32_L2_N); 
   assign i_aux_lshit_a       = auxdc(aux_addr, AX_LSTART_N); 
   assign i_aux_lehit_a       = auxdc(aux_addr, AX_LEND_N); 
   assign i_aux_pchit_a       = 1'b0; // this register has been removed from arcver 25 onward
   assign i_aux_pc32hit_a     = auxdc(aux_addr, AX_PC32_N); 
   assign i_aux_status32hit_a = auxdc(aux_addr, AX_STATUS32_N); 
   assign i_aux_misalign_ctrl_a = auxdc(aux_addr, AUX_ALIGN_CTRL);

   //  Produce decodes for individual auxiliary registers from h_addr
   //  (uses special decode function which only decodes to AUXDECSZ 
   // width)
   //
   // Valid host access allowed while running:
   assign i_h_aux_write_always_a   = h_write & aux_access & ~noaccess;
   // Valid host access, but processor must be halted:
   assign i_h_aux_write_a   = i_h_aux_write_always_a & ~i_en_r;
   assign i_h_dbhit_a       = aux_access & auxdc(h_addr, AX_DEBUG_N); 
   assign i_h_idhit_a       = aux_access & auxdc(h_addr, AX_ID_N); 
   assign i_h_l1_hit_a      = aux_access & auxdc(h_addr, AX_STATUS32_L1_N); 
   assign i_h_l2_hit_a      = aux_access & auxdc(h_addr, AX_STATUS32_L2_N); 
   assign i_h_pchit_a       = 1'b0; // this register has been removed from arcver 25 onward
   assign i_h_pchit32_a     = aux_access & auxdc(h_addr, AX_PC32_N);
   assign i_h_status32hit_a = aux_access & auxdc(h_addr, AX_STATUS32_N);

   //  Here we generate the master signal which controls external load
   //  of the program counter. It is set true when a host interface 
   //  write to PC/status register is received, except:
   // 
   //  i. an instruction fetch is pending - and therefore any writes 
   //     will be held off by hold_host logic in the hostif module. 
   //     (instr_pending_r)
   // 
   //  ii. an external instruction cache system has detected a write 
   //      to the program counter which needs to be held off. This is
   //      achieved by setting the xcache_hold_host signal. It is included 
   //      here to prevent the ARC from changing the PC and 
   //      generating an ifetch before the external cache system is 
   //      ready.
   // 
   assign i_h_pcwr_a   = (i_h_pchit_a & i_h_aux_write_a & 
                         ~instr_pending_r & ~xcache_hold_host);

   assign i_h_pcwr32_a = (i_h_pchit32_a & i_h_aux_write_a & 
                         ~instr_pending_r & ~xcache_hold_host); 

   assign i_h_status32wr_a = (i_h_status32hit_a & i_h_aux_write_a & 
                         ~instr_pending_r & ~xcache_hold_host); 

   assign i_h_l1_wr_a  = (i_h_l1_hit_a & i_h_aux_write_a &
                         ~instr_pending_r & ~xcache_hold_host); 

   assign i_h_l2_wr_a  = (i_h_l2_hit_a & i_h_aux_write_a &
                         ~instr_pending_r & ~xcache_hold_host);

   // The signals below flag that the processor wishes to write to the
   // Status32 L1/L2 registers.
   //
   assign i_aux_l1_wr_a = i_aux_l1_hit_a & aux_write;
   assign i_aux_l2_wr_a = i_aux_l2_hit_a & aux_write;


// Misaligned Control Register

  always @(posedge clk or posedge rst_a)
  begin
    if (rst_a == 1'b 1)
    begin
      i_misalign_ctrl_r <= 2'b00;
    end
    else if (i_aux_misalign_ctrl_a && aux_write)
    begin
        i_misalign_ctrl_r[0] <= aux_dataw[0];
        i_misalign_ctrl_r[1] <= aux_dataw[31] ? 1'b 0 : i_misalign_ctrl_r[1];
    end
    else if (misaligned_err)
    begin
        i_misalign_ctrl_r[1] <= 1'b 1;
    end
  end


//===================== Component Instantiations =====================--
//
flags U_flags (

          .clk(clk),
          .rst_a(rst_a),

          .actionpt_hit_a(actionpt_hit_a),
            .actionpt_pc_brk_a(actionpt_pc_brk_a),
          .ctrl_cpu_start_r(ctrl_cpu_start_r),
          .arc_start_a(arc_start_a),
          .halt(halt),
          .step(i_step),
          .inst_step(i_inst_step),

          .aux_dataw(aux_dataw),
          .aux_l1_wr(i_aux_l1_wr_a),
          .aux_l2_wr(i_aux_l2_wr_a),

          .h_dataw(h_dataw),
          .h_write(h_write),
          .h_pchit(i_h_pchit_a),
          .h_dbhit(i_h_dbhit_a),
          .h_l1_wr(i_h_l1_wr_a),
          .h_l2_wr(i_h_l2_wr_a),
          .h_pcwr(i_h_pcwr_a),
          .h_status32hit(i_h_status32hit_a),
          .h_status32wr(i_h_status32wr_a),

          .xflags(xflags),
          .x_flgen(x_flgen),
          .xsetflags(xsetflags),
          .x_idecode3(x_idecode3),
          .xcache_hold_host(xcache_hold_host),
          .brk_inst_a(brk_inst_a),

          .en2b(en2b),
          .fs2a(fs2a),
          .instr_pending_r(instr_pending_r),
          .p1int(p1int),
          .p2int(p2int),
          .p2b_opcode(p2b_opcode),
          .p2b_subopcode(p2b_subopcode),
          .p2b_iv(p2b_iv),
          .p2b_condtrue(p2b_condtrue),
          .p2b_setflags(p2b_setflags),
          .p2bint(p2bint),

          .p4_disable_r(p4_disable_r),
          .p3_flag_instr(p3_flag_instr),
	  .p3_sync_instr(p3_sync_instr),
          .p3iv(p3iv),
          .p3condtrue(p3condtrue),
          .p3_docmprel_a(p3_docmprel_a),
          .p3setflags(p3setflags),
          .p3int(p3int),
          .p3ilev1(p3ilev1),
          .p3wba(p3wba),
          .en3(en3),
          .sleeping(sleeping),
          .s2val(s2val),
          .alurflags(alurflags),
          .stop_step(stop_step),
          .debug_if_r(debug_if_r),
          .debug_if_a(debug_if_a),
          .x_multic_busy(x_multic_busy),
          .pcounter_jmp_restart_a(pcounter_jmp_restart_a),

          .aluflags_nxt(i_aluflags_nxt),
          .aluflags_r(i_aluflags_r),
          .do_inst_step_r(do_inst_step_r),
          .en_r(i_en_r),
          .e1flag_r(i_e1flag_r),
          .e2flag_r(i_e2flag_r),
          .hold_host_intrpt_a(hold_host_intrpt_a),
          .hold_host_multic_a(hold_host_multic_a),
          .host_write_en_n_a(host_write_en_n_a),
          .status32_l1_r(i_status32_l1_r),
          .status32_l2_r(i_status32_l2_r),
          .starting(i_starting),
          .breakhalt_r(i_breakhalt_r),
          .actionhalt(i_actionhalt_a),
          .selfhalt_r(i_selfhalt_r));


debug U_debug (   

          .clk(clk),
          .rst_a(rst_a),

          .aux_dataw(aux_dataw),
          .h_a_write(i_h_aux_write_a),
          .aux_dbhit(i_aux_dbhit_a),
          .actionpt_status_r(actionpt_status_r),
          .actionhalt(i_actionhalt_a),
          .en_debug_r(en_debug_r),
          .lpending(lpending),
          .breakhalt_r(i_breakhalt_r),
	  .inst_stepping(inst_stepping),
          .selfhalt_r(i_selfhalt_r),
          .xstep(xstep),
          .p2sleep_inst(p2sleep_inst),
          .starting(i_starting),
          .p1int(p1int),
          .en2(en2),

          .debug_r(i_debug_r),
          .sleeping(sleeping),
          .sleeping_r2(sleeping_r2),
          .step(i_step),
          .inst_step(i_inst_step),
          .reset_applied_r(reset_applied_r));

//  This signal informs the control unit that the actionpoint system 
//  has been triggered by a valid condition, and that the ARC should 
//  be halted.
//  The debug register is also updated.

   assign actionhalt = i_actionhalt_a;

//  The ARC's identity register is a fixed quantity, and can be read 
//  from both the ARC and the host simultaneously. It is produced from
//  constants in arcutil and extutil.

   assign i_identity_r = {`MANCODE, `MANVER, id_arcnum, `ARCVER}; 

//  Produce the 32-bit word supplied to the host when it asks for the 
//  pc/status register.

   assign i_host_pc_r = 32'h0; // this register has been removed from arcver 25 onward

// Produce the 32-bit word supplied to the host when it asks for the  
// status32 register.
//
   assign i_status12_r = {i_aluflags_r, FIVE_ZERO, i_e2flag_r,
                          i_e1flag_r, (~i_en_r)};

   assign i_status32_r = {TWENTY_ZERO, i_status12_r};


//  Select the data value to be driven onto the aux_datar[31:0] bus
//  (*** Note that the pc/status register is never driven onto this
//   bus).
// 
//  (*** also note that drx_reg is only used when constant 
//   XT_AUXREG = '1' - this is defined in extutil).
// 
   assign aux_datar = 
	  (i_aux_lshit_a       == 1'b 1) ? loopstart_r : 
	  (i_aux_lehit_a       == 1'b 1) ? loopend_r : 
	  (i_aux_dbhit_a       == 1'b 1) ? i_debug_r : 
	  (i_aux_status32hit_a == 1'b 1) ? i_status32_r : 
	  (i_aux_l1_hit_a      == 1'b 1) ? i_status32_l1_r : 
	  (i_aux_l2_hit_a      == 1'b 1) ? i_status32_l2_r : 
          (i_aux_misalign_ctrl_a == 1'b 1) ? {i_misalign_ctrl_r[1], {30{1'b0}}, i_misalign_ctrl_r[0]} :
	  ((xreg_hit            == 1'b 1) & (XT_AUXREG  == 1'b 1)) ? drx_reg : 
          i_identity_r; 

//  Select the data value to be supplied to the host when it reads 
//  dual-access registers (pc/status, semaphore register, i_identity_r 
//  register).
// 
   assign aux_dar = 
	(i_h_pchit_a         == 1'b 1) ? i_host_pc_r : 
	(i_h_pchit32_a       == 1'b 1) ? currentpc_r : 
	((x_da_am             == 1'b 1) & (XT_AUXDAR  == 1'b 1)) ? x_dar : 
	(i_h_dbhit_a         == 1'b 1) ? i_debug_r :
	(i_h_status32hit_a   == 1'b 1) ? i_status32_r : 
	(i_h_l1_hit_a        == 1'b 1) ? i_status32_l1_r : 
	(i_h_l2_hit_a        == 1'b 1) ? i_status32_l2_r :
          i_identity_r; 

//  This signal is true when h_addr,aux_access point to a dual-access
//  register (includes registers provided by extensions)

   assign da_auxam = i_h_pchit_a       | 
                     i_h_pchit32_a     | 
                     i_h_dbhit_a       | 
                     i_h_status32hit_a | 
                     i_h_l1_hit_a      | 
                     i_h_l2_hit_a      | 
                     i_h_idhit_a       | 
                     (x_da_am   &
                      XT_AUXDAR &
                      aux_access); 

//========================== Output Drives ===========================--
//
//  ** This includes the global enable signal en. **

   assign en_misaligned = i_misalign_ctrl_r[0];
   assign en           = i_en_r; 
   assign aluflags_nxt = i_aluflags_nxt; 
   assign aluflags_r   = i_aluflags_r; 
   assign e1flag_r     = i_e1flag_r; 
   assign e2flag_r     = i_e2flag_r; 
   assign aux_pchit    = i_aux_pchit_a; 
   assign aux_pc32hit  = i_aux_pc32hit_a; 
   
   assign h_pcwr       = i_h_pcwr_a; 
   assign h_pcwr32     = i_h_pcwr32_a; 
   assign h_status32   = i_h_status32wr_a; 
   assign step         = i_step;
   assign inst_step    = i_inst_step;

endmodule // module aux_regs

