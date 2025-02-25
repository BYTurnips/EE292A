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
// This is the Clock control module. This module generates the clock
// gating signals. If clock gating has not been selected this module
// is empty.
//
//======================= Inputs to this block =======================--
//
// clk_ungated        U The ungated core clock which is always the same as
//                    clk_in. It is never gated even if clock gating has
//                    been selected. It is connected to the modules that
//                    control the ARC interfaces, the timer and the
//                    clock control.
//
//  en                U Global enable signal
//
// ctrl_cpu_start_r   This signal comes from the 'ctrl_cpu_start' input
//                    and will start the ARC running when it is halted.
//
//  do_inst_step_r    This signal is set when the single step flag (SS)
//                    and the instruction step flag (IS) in the debug
//                    register has been written to simultaneously through
//                    the host interface. It indicates that an instruction
//                    step is being performed. When the instruction step
//                    has finished this signal goes low.
//
// sleeping_r2        This is the pipelined version of sleeping for use by
//                    clock gating. Sleep mode (zz) flag in the debug
//                    register (bit 23).
//
//  p123int           U Indicates that there is an interrupt in stage 1,
//                    2 or 3. This signal is used by the clock
//                    generation module. If the option clock gating was
//                    not chosen this signal is removed during synthesis.
//
// host_rw            U This signal is true when an host access occurs,
//                    that is either a write (h_write = '1') or a read
//                    (h_read = '1').
//
// p4_disable_r       L This signals to the ARC that the pipeline has
//                    been flushed due to a breakpoint or sleep
//                    instruction. If it was due to a breakpoint
//                    instruction the ARC is halted via the 'en' bit,
//                    and the AH bit is set to '1' in the debug
//                    register.
//
// mem_access         U This signal is true if the main memory is being
//                    accessed and false otherwise.
//
// lpending           U Indicates to ARC that there is at least one load
//                    pending. It is the inverse of the empty flag from
//                    the scoreboard.
//
// instr_pending_r    U This signal is true when an instruction fetch has
//                    been issued, and it has not yet completed. It is not
//                    true directly after a reset before the ARC has
//                    started, as no instruction fetch will have been
//                    issued.
//
// ic_busy            U No Invalidate Instruction Cache. This signal is set
//                    true by the I-Cache, to indicate that no instruction
//                    cache invalidate requests (ivic) are to be made as the
//                    cache is busy. It is set true during tag clearing and
//                    line loads from memory.
// 
// pcp_wr_rq          U Debug interface write request. This is produced by
//                    the debug interface (PC/JTAG port).
//
// pcp_rd_rq          U Debug interface read request. This is produced by
//                    the  debug interface (PC/JTAG port).
//
// dc_full_r          L Data Cache Buffer Full. This signal is set true when
//                    the data cache buffer is full.
//
// dc_all_busy        U Data Cache Busy. This signal is set true by
//                    the cache to indicate that it is busy.
//
// fl_busy_r          Flush Buffer Busy Indicator.
//
// bcu_act            L This signal indicates that a burst transfer is
//                    in progress. This signal only exists for xy-
//                    memory.
//
// xym_en_ck          L This signal is set when any of the XY memory
//                    dmi request lines are asserted.
//
// wd_clear           Set when a timer watchdog reset is in progress.
//
// mload2b            Set when a load is in pipeline stage 2b.
//
// mstore2b           Set when a store is in pipeline stage 2b.
//
// cgm_dcache_idle    From mwdc_state, set when Dcache is idle.
//
// cgm_queue_idle     From ldst_queue, set when queue is idle.
//
// cgm_cmd_access     From xaux_regs, set when a Dcache control
//                    register is being accessed.

// is_local_ram       This signal is true when the address (dmp_addr) is
//                    within the address ranges of either the code RAM or
//                    the LD/ST RAM.
//
// debug_if_r        Debug Memory Access. This is asserted true when a debug
//                   access to memory is in progress.

//
//======================== Output from this block ====================--
//
// ck_disable         L This is the disable signal that gates the clock
//                    ck if the ARC is ready to be temporarily shut
//                    down.
// 
// ck_gated           U This is the signal that indicates to the host
//                    interface that the ARC is shut down. Host accesses
//                    are held of in the host interface until the ARC
//                    has woken up.
//
// ck_dmp_gated       The DMP clock domain is gated when this is true.
//
//====================================================================--
//
module ck_ctrl (
   clk_ungated,
   rst_a,
   test_mode,
   ctrl_cpu_start_sync_r,
   do_inst_step_r,
   sleeping_r2,
   en,
   q_busy,
   p123int,
   host_rw,
   p4_disable_r,
   mem_access,
   lpending,
   instr_pending_r,
   ic_busy,
   wd_clear,
   mload2b,
   mstore2b,
   dmp_mload,
   dmp_mstore,
   is_local_ram,
   debug_if_r,
   cgm_queue_idle,
   ibus_busy,
   pcp_rd_rq,
   pcp_wr_rq,

   ctrl_cpu_start_r,
   ck_disable,
   ck_gated,
   ck_dmp_gated);

`include "arcutil_pkg_defines.v" 
`include "arcutil.v"

   input   clk_ungated; 
   input   rst_a; 
   input   test_mode; 
   input   ctrl_cpu_start_sync_r;
   input   do_inst_step_r;
   input   sleeping_r2; 
   input   en;
   input   q_busy; 
   input   p123int; 
   input   host_rw; 
   input   p4_disable_r; 
   input   is_local_ram;
   input   debug_if_r;
   input   mem_access; 
   input   lpending; 
   input   instr_pending_r; 
   input   ic_busy;
   input   wd_clear;
   input   mload2b;
   input   mstore2b;
   input   dmp_mload;
   input   dmp_mstore;
   input   cgm_queue_idle;
   input   ibus_busy;
   input   pcp_rd_rq; 
   input   pcp_wr_rq; 

   output   ctrl_cpu_start_r;
   output   ck_disable; 
   output   ck_gated; 
   output   ck_dmp_gated;

   wire     ctrl_cpu_start_r;
   wire     ck_disable; 
   wire     ck_gated; 
   wire     ck_dmp_gated;
   reg      i_ctrl_cpu_start_r;
   reg      ick_dmp_disable;
   reg      i_ck_disable_r;
   reg     [1:0] i_postrst_count_r;
   wire    i_justafter_rst;

    reg     i_pcp_rq_ongoing_r;

   // -------------------------------------------------------------------------
   //  Main clock gate (controls clk)
   // 
   //  Provided that clock gating has been selected (CK_GATING = '1') the
   //  clock is gated if:
   // 
   //    1.  The ARC is halted (en = '0') and the external start is low
   //        (ctrl_cpu_start_r = '0'), or is sleeping after the
   //        pipeline has been flushed (sleeping_r2 = '1' and
   //        p4_disable_r = '1') and there is no pending instruction step
   //        (do_inst_step_r = '0').
   //    2.  There are no loads pending (lpending = '0')
   //    3.  The main memory is not being accessed (mem_access = '0')
   //    4.  The host is not accessing the ARC (host_rw = '0)
   //    5.  There is no pending instruction fetch (instr_pending_r = '0').
   //    6.  The instruction cache is not busy (ic_busy = '0').
   //    7.  The data cache buffer is empty (dc_full_r = '0').
   //    8.  The data cache is not busy (dc_all_busy = '0').
   //    9.  The host is not requesting to read (pcp_rd_rq = '0').
   //    10. The host is not requesting to write (pcp_wr_rq = '0').
   //    11. The xymemory is not bursting (bcu_act = '0').
   //    12. There is not a DMI request to XY memory (xym_en_ck = '0').
   //    13. There are no interrupt requests to service (p123int = '0').
   //    14. There is not a watchdog timer reset in progress.
   //    15. The data cache flush buffer is not busy (fl_busy_r = '0').
   // 
   // -------------------------------------------------------------------------
   always @(posedge clk_ungated or posedge rst_a)
     begin : disable_sync_PROC
            
      if (rst_a == 1'b 1)
         begin
         i_ck_disable_r <= 1'b 0; 
         end
      else 
          begin
            if (((en == 1'b 0 && i_ctrl_cpu_start_r == 1'b0) ||
               (sleeping_r2 == 1'b 1 && p4_disable_r == 1'b 1 && do_inst_step_r == 1'b 0)) & 
               do_inst_step_r == 1'b 0 && 
               lpending == 1'b 0 && 
                mem_access == 1'b 0 && 
               host_rw == 1'b 0 && 
               instr_pending_r == 1'b 0 && 
               ic_busy == 1'b 0 && 
                ibus_busy == 1'b 0 &&
	       q_busy == 1'b0 &&
               pcp_wr_rq == 1'b 0 &&
               pcp_rd_rq == 1'b 0 &&
              i_pcp_rq_ongoing_r == 1'b 0 &&
               p123int == 1'b 0 &&
               wd_clear == 1'b0 &&
               i_justafter_rst == 1'b 0)
   
               begin
               i_ck_disable_r <= 1'b 1;   
               end
            else
               begin
               i_ck_disable_r <= 1'b 0;   
               end
            end
         end


   assign ck_disable = i_ck_disable_r; 

   // -------------------------------------------------------------------------
   //  DMP clock gate (controls clk_dmp)
   // 
   //  Provided that clock gating has been selected (CK_GATING = '1') the
   //  DMP clock is gated independantly of the main clock when:
   // 
   // 1. There are no ld / st instructions about to happen (mload2b==0 and mstore2b==0)
   // 2. There are no accesses to the Dcache control registers (cgm_cmd_access==0)
   // 3. The Dcache is idle (cgm_dcache_idle==1)
   // 4. The ldst_queue is idle (cgm_queue==1)
   // 5. The score board is empty (lpending == 0)
   // 6. It's not just after reset
   //
   // -------------------------------------------------------------------------
   always @(posedge clk_ungated or posedge rst_a)
     begin : dmp_disable_sync_PROC 
      if (rst_a == 1'b 1)
        begin
          ick_dmp_disable <= 1'b 0; 
        end
        else 
        begin
          if (
               host_rw   == 1'b 0 &&
               pcp_wr_rq == 1'b 0 &&
               pcp_rd_rq == 1'b 0 &&
               mload2b == 1'b 0 &&
                  mstore2b == 1'b 0 &&
               dmp_mload == 1'b 0 &&
                  dmp_mstore == 1'b 0 &&
              cgm_queue_idle == 1'b 1 &&
               lpending == 1'b 0 &&
                  i_justafter_rst == 1'b 0 
             )
          begin
            ick_dmp_disable <= 1'b 1;   
          end
          else
          begin
            ick_dmp_disable <= 1'b 0;   
          end
        end
     end 
   
   // -----------------------------------------------------------------
   // Running after hardware reset
   //
   // Immediately after a global hardware reset, clock gating must be 
   // prevented from occurring until the arc_start_a value has been 
   // evaluated. If arc_start_a (see flags module) is set to 1 then the
   // processor starts running immediately after hardware reset. If 
   // arc_start is cleared then the processor remains halted after 
   // hardware reset. It takes two clock cycles after hardware reset
   // to evaluate arc_start_a, during which clock gating is not allowed
   // to occur.
   //
   // -----------------------------------------------------------------
   
   always @(posedge clk_ungated or posedge rst_a)
     begin: holdoff_ckgating
   
     if (rst_a == 1'b 1)
        begin
        i_postrst_count_r <= 2'b 0;
         end
     else
        begin
           i_postrst_count_r[0] <= 1'b 1;
           i_postrst_count_r[1] <= i_postrst_count_r[0];
           end
   
     end
   
   assign i_justafter_rst = (i_postrst_count_r == 2'b 11) ? 1'b 0: 1'b 1;
      
   // indicates whether the address phase of debug access is ongoing
   //
   always @(posedge clk_ungated or posedge rst_a)
     begin: pcp_rq_ongoing_PROC
     
      if (rst_a == 1'b 1)
         begin
         i_pcp_rq_ongoing_r <= 1'b 0;
         end
      else
         begin
         if (((pcp_wr_rq == 1'b 1) | (pcp_rd_rq == 1'b 1)) &
               debug_if_r==1'b1 & is_local_ram==1'b0)
            i_pcp_rq_ongoing_r <= 1'b 1;
         else if (mem_access == 1'b 1)
            i_pcp_rq_ongoing_r <= 1'b 0;
         end
      end

   // -------------------------------------------------------------------------
   // Register the start pin and release it once the core is running.
   // This is essential since the start pin must also clear the H bit
   // which is on the gated clock domian.
   //
   // -------------------------------------------------------------------------

   always @(posedge clk_ungated or posedge rst_a)
      begin : startpin_PROC        
       if (rst_a == 1'b 1)
          begin
          i_ctrl_cpu_start_r <= 1'b 0; 
          end   
       else
         begin
	 if (ctrl_cpu_start_sync_r == 1'b1)
	   begin
	   i_ctrl_cpu_start_r <= 1'b1;
	   end
	 else
	   begin
	   if (en == 1'b1)
	     begin
	     i_ctrl_cpu_start_r <= 1'b0;
	     end
	   end
 	end
      end
     
   // -------------------------------------------------------------------------
   //  Clock gated signal
   // 
   //  This signals is high when the main clock is gated and the ARC is not
   //  in test mode. It is used in hostif.v to hold off the host.
   // 
   // -------------------------------------------------------------------------
   
   assign ck_gated = i_ck_disable_r & ~test_mode;

   // DMP clock gating signal
   //
   assign ck_dmp_gated = ick_dmp_disable;  

   // External start signal to 'H' bit
   //
   assign ctrl_cpu_start_r = i_ctrl_cpu_start_r;
 

     

endmodule
