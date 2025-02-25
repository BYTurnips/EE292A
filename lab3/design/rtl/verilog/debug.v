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
// Debug auxiliary register (including sleep mode flag)
//
// Note that this register is not dual-access, so the lpending flag can
// only be read by the host when the ARC is stopped.
//
//======================= Inputs to this block =======================--
//
// aux_dataw[31:0]  from hostif. This is the auxiliary register bus 
//                  write data value.
//
// h_a_write        from hostif. This signal indicates that a write
//                  from the host is being performed to
//                  the auxiliary register specified on aux_addr[31:0].
//
// aux_dbhit        is from auxregs, and is true when aux_addr =
//                  ax_debug.
//
// lpending         from lsu. Set true when one or more delayed loads
//                  are pending.
//
// actionhalt       from flags. Set true when ARC is stopped, when the
//                  halt was caused by an actionpoint being triggered by
//                  a valid event. This is a debug extension which can
//                  act as breakpoint and watchpoint. The actionpoints
//                  extension has to be selected for this flag.
//
// breakhalt_r      from flags. Set true when ARC is stopped, when the
//                  halt was caused by a BRK instruction at stage one of
//                  the pipeline. The pipeline is flushed before the ARC
//                  is properly halted.
//
// en_debug_r       This flag is the Enable Debug flag (ED) in the
//                  DEBUG register. It enables the debug extensions when
//                  it is set. When it is cleared the debug extensions
//                  are switched off by gating the debug clock, but only
//                  if the option clock gating has been selected.
//
// selfhalt_r       from flags. Set true when ARC is stopped, when the
//                  halt was caused by a FLAG instruction on the ARC.
//
// actionpt_status_r
//                  from debug_exts. This field shows which of the
//                  actionpoints were triggered in the OR-plane.The 
//                  actionpoints extension has to be selected for this
//                  field.
//
// xstep            from extensions. Single step on the next cycle if
//                  the ARC is stopped.
//
// p2sleep_inst     from rctl. This signal is set when a sleep
//                  instruction has been decoded in pipeline stage 2.
//
// starting         from flags. This signal indicates that the ARC is
//                  starting, i.e. en goes high. This wakes up the ARC
//                  from sleep mode.
//
// p1int            from int_unit. Indicates that an interrupt has been
//                  detected. This wakes up the ARC from sleep mode.
//
// en2              from rctl. Pipeline stage 2 enable. When this
//                  signal is true, the instruction in stage 2 can pass
//                  into stage 3 at the end of the cycle. When it is
//                  false, it will hold up stage 2 and stage 1.
//
//====================== Output from this block ======================--
//
// sleeping         This is the sleep mode flag ZZ in the debug register
//                  It stalls the pipeline when true.
//
// sleeping_r2      This is the pipelined version of sleeping for use by
//                  clock gating.
//
// debug_r[31:0]    The debug register when read from the aux register
//                  bus.
//
// step             To flags. Do a single step on the next cycle, if the
//                  ARC is stopped.
//
// inst_step        To flags. Do instruction step during single step. If
//                  cleared a cycle step occurs.
//
// reset_applied_r  This bit in the debug register is set to true when a
//                  a reset happens. The bit is read only from the
//                  processor side and the debugger clears this bit when
//                  it performs a read.
//
//====================================================================--
//
module debug (clk,
              rst_a,
              aux_dataw,
              h_a_write,
              aux_dbhit,
              actionpt_status_r,
              en_debug_r,
              actionhalt,
              lpending,
              breakhalt_r,
              selfhalt_r,
              xstep,
              p2sleep_inst,
              starting,
              p1int,
              inst_stepping,      
              en2,
              debug_r,
              sleeping,
              sleeping_r2,
              step,
              inst_step,
              reset_applied_r);

`include "arcutil_pkg_defines.v"
`include "arcutil.v"
`include "extutil.v"

input          clk; 
input          rst_a; 

//  Auxiliary register signals
input  [DATAWORD_MSB:0] aux_dataw; 
input          h_a_write; 
input          aux_dbhit; 

//  signals for inclusion in the debug register //
input   [NUM_APS - 1:0] actionpt_status_r; 
input          actionhalt; 
input          en_debug_r; 

input          inst_stepping;
input          lpending; 
input          breakhalt_r; 
input          selfhalt_r; 
input          xstep; 
input          p2sleep_inst; 
input          starting; 
input          p1int; 
input          en2; 

//  Output signals
output  [31:0] debug_r; 
output         sleeping; 
output         sleeping_r2;
output         step; 
output         inst_step; 
output         reset_applied_r;

reg     [31:0] debug_r; 
wire           sleeping; 
wire           sleeping_r2;
wire           step; 
wire           inst_step; 

//====================================================================--

wire           i_inst_step_a; 
wire           i_step_a; 
reg            i_sleeping_r; 
reg            i_sleeping_r2;
reg            i_reset_applied_r;
reg            i_external_halt_r;

   // Step:
   // 
   // This signal causes a single step to occur on the next cycle by
   // flags when the ARC is halted. When the DB_STEP bit in the debug
   // register is written with '1' via the auxiliary register bus, the
   // step signal is set true. Depending on the value of instruction
   // step, either an instruction step or a cycle step occurs.
   //
   assign i_step_a = ((aux_dbhit == 1'b 1) &&
                      (h_a_write == 1'b 1) && 
                      ((aux_dataw[`DEBUG_S_STEP_MSB] == 1'b 1) | 
                       (xstep     == 1'b 1))) ?
          ~aux_dataw[`DEBUG_RESET_MSB] : 
          1'b 0; 

   // Instruction Step:
   // 
   // When this signal is set at the same time as the step signal is set
   // a single instruction step occurs. Only one instruction is fetched
   // and allowed to complete.
   // 
   // If this signal is cleared when the step signal is set a single
   // cycle step occurs which means that the ARC is active during only
   // one clock cycle.
   // 
   // A single step generated from the extensions (xstep) can not be run
   // with instruction step.

   assign i_inst_step_a = ((aux_dbhit == 1'b 1)                    &&
                           (h_a_write == 1'b 1)                    && 
                           (aux_dataw[`DEBUG_I_STEP_MSB] == 1'b 1) && 
                           (xstep     == 1'b 0)) ?
          ~aux_dataw[`DEBUG_RESET_MSB] : 
          1'b 0; 
   
   //  Sleep mode:
   // 
   //  Sleep mode is a power saving mode, during which the pipeline is stalled,
   //  but not halted. When the sleep mode flag ZZ (i_sleeping_r) in the debug
   //  register is set the ARC enters sleep mode. This happens when
   //  a sleep instruction is detected in pipeline stage 2
   //  (p2sleep_inst = '1'). The ARC stays in sleep mode until an interrupt
   //  is requested (p1int = '1') or the ARC is restarted (starting = '1').
   //
   always @(posedge rst_a or posedge clk)
      begin : sleep_mode_sync_PROC
      if (rst_a == 1'b 1)
         begin
         i_sleeping_r  <= 1'b 0;  
         i_sleeping_r2 <= 1'b 0;
         end
      else
         begin
         if ((p1int == 1'b 1) | (starting == 1'b 1))
            begin
            i_sleeping_r <= 1'b 0;   
            end
         else if ((p2sleep_inst == 1'b 1) & (en2 == 1'b 1) & (inst_stepping==1'b0) )
            begin
            i_sleeping_r <= 1'b 1;   
            end

         // Pipeline the Sleep signal for clock gating when updating the E1 & E2
         // flags.
         //
         i_sleeping_r2 <= i_sleeping_r;

         end
      end

   //  Reset Applied:
   // 
   //  Reset Applied is set to true when a reset happens. The only operation
   //  that can clear this bit is a write to the debug register or read since
   //  the bit is a sticky bit.
   //
   always @(posedge rst_a or posedge clk)
      begin : reset_applied_sync_PROC
      if (rst_a == 1'b 1)
         begin
         i_reset_applied_r <= 1'b 1;  
         end
      else
         begin
         if ((h_a_write == 1'b 1) &&
             (aux_dbhit == 1'b 1))
            begin
            i_reset_applied_r <= aux_dataw[`DEBUG_RESET_MSB];   
            end
         end
      end


   //  Debug register read result : This defines where the various bits appear 
   //  in the auxiliary register.
   // 
   always @(lpending or selfhalt_r or breakhalt_r or actionhalt or 
            en_debug_r or actionpt_status_r or i_reset_applied_r or
            i_sleeping_r)

   begin : debug_async_PROC

   //  Default values

   debug_r[`DEBUG_AMC_MSB:`DEBUG_EN_DEBUG_MSB] = `FIVE_ZEROS;    
   debug_r[21:0] = `TWENTY_TWO_ZEROS;  

   //  This flag when true signifies a load is pending. 
   debug_r[`DEBUG_LOOP_MSB] = lpending;

   //  This flag when true signifies that the ARC has been halted 
   //  via a flag instruction. 
   debug_r[`DEBUG_S_HALT_MSB] = selfhalt_r; 

   //  This flag when true signifies that the ARC has been halted by a BRK
   //  instruction which was detected at stage one. 
   debug_r[`DEBUG_B_HALT_MSB] = breakhalt_r;    

   debug_r[`DEBUG_SLEEP_MSB] = i_sleeping_r;   
   debug_r[`DEBUG_RESET_MSB] = i_reset_applied_r;   

   //  This field provides the debugger with information for all
   //  the actionpoint valid signals. This shows which of the
   //  actionpoints was triggered.
   debug_r[`DEBUG_EN_DEBUG_MSB] = en_debug_r; 
   debug_r[`DEBUG_AP_MSB:`DEBUG_AP_LSB] = actionpt_status_r; 
   debug_r[`DEBUG_A_HALT_MSB] = actionhalt;    

   end

//============================ Output drives =========================--
//
   assign inst_step = i_inst_step_a; 
   assign reset_applied_r = i_reset_applied_r;
   assign sleeping = i_sleeping_r; 
   assign sleeping_r2 = i_sleeping_r2;
   assign step = i_step_a; 

endmodule // module debug

