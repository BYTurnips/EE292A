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
// Auxiliary Timer Counter
// 
// ======================= Inputs to this block =======================--
// 
//  aux_write - write strobe for aux register access
//  aux_addr - address for aux register access
//  aux_dataw - data for aux register access
// 
// ====================== Output from this block ======================--
// 
//  timer_r - current timer count value
//  tlimit_r - wrap around limit for the timer
//  timer_pirq_r - flag to indicate a pending interrupt by the timer
//  tcontrol_r - when set enables generation of interrupt
//  timer_mode_r - when set enables cycle count when ARC not halted
//  l_irq_3 - timer interrupt signal
//  timer_clr_r - timer watchdog reset signal
//  twatchdog_r - when set enables generation of watchdog reset
//
// ====================================================================--
//
module timer0 (clk_ungated,
	       rst_a, 
               en,
               aux_write,
               aux_addr,
               aux_dataw,
               timer_r,
               tlimit_r,
               timer_pirq_r,
               tcontrol_r,
               timer_mode_r,
               l_irq_3,
               timer_clr_r,
               twatchdog_r);

`include "arcutil_pkg_defines.v" 
`include "extutil.v" 
`include "xdefs.v"

   input   clk_ungated; 
   input rst_a;
   input   en; 
   input   aux_write; 
   input   [31:0] aux_addr; 
   input   [31:0] aux_dataw; 

   output  [TIMER_MSB:0] timer_r; 
   output  [TIMER_MSB:0] tlimit_r;
   output  timer_pirq_r; 
   output  tcontrol_r; 
   output  timer_mode_r; 
   output  l_irq_3; 
   output  timer_clr_r; 
   output  twatchdog_r; 


   wire    [TIMER_MSB:0] timer_r; 
   wire    [TIMER_MSB:0] tlimit_r;
   wire    timer_pirq_r; 
   wire    tcontrol_r; 
   wire    timer_mode_r; 
   reg     l_irq_3; 
   reg     timer_clr_r; 
   wire    twatchdog_r; 

   wire    [TIMER_MSB:0] i_timer_plus1_a; 
   reg     [TIMER_MSB:0] i_timer_r; 
   reg     [TIMER_MSB:0] i_tlimit_r; 
   reg     i_timer_mode_r; 
   reg     i_timer_pirq_r; 
   reg     i_tcontrol_r; 
   reg     i_twatchdog_r; 


   //  A simple incrementer whose output is latched into the count register
   //  according to the timer mode at every cycle. Note the adder is 1 bit
   //  longer than the maximum range of the timer.
   // 
   assign i_timer_plus1_a = i_timer_r + 1'b 1; 

always @(posedge clk_ungated or posedge rst_a)
   begin : timer_PROC
   if (rst_a == 1'b1) 
         begin
         // if reset is asserted then clear the timer count register and the control
         // flip-flops. The limit register is set to 0x00ffffff for backward 
         // compatibility with the 24 bit timer and both the interrupt and watchdog 
         // signals are cleared as well
         //
         i_timer_r       <= {(TIMER_WIDTH){1'b 0}};
         i_tlimit_r      <= 32'b 00000000111111111111111111111111;
         i_timer_pirq_r  <= 1'b 0;
         i_tcontrol_r    <= 1'b 0;
         i_timer_mode_r  <= 1'b 0;
         i_twatchdog_r   <= 1'b 0;
         l_irq_3 <= 1'b 0;
         timer_clr_r     <= 1'b 0;
         end
      else
         begin
         // If there is a write to the count value then update the internal count
         // else check if the timer count has reached the limit value, if so then
         // clear the timer count register and generate either the watchdog or
         // interrupt signals. Note that there is no need to generate the 
         // interrupt signal if the watchdog signal is to be asserted else check
         // if we are we are free running mode or in not free running mode and not 
         // halted - if so then the timer can take the incremented value from the 
         // adder.
         //
         if (auxdc(aux_addr, aux_timer) == 1'b 1 & aux_write == 1'b 1)
            begin
            i_timer_r <= aux_dataw[TIMER_WIDTH - 1:0];
            end
         else if (i_timer_r == i_tlimit_r)
            begin
            i_timer_r <= {(TIMER_WIDTH){1'b 0}};
            if (i_twatchdog_r == 1'b 1)
               begin
               timer_clr_r <= 1'b 1;
               end
            else if (i_tcontrol_r == 1'b 1 )
               begin
               l_irq_3 <= 1'b 1;
               i_timer_pirq_r  <= 1'b 1;
               end
            end
         else if (i_timer_mode_r == 1'b 0 | (i_timer_mode_r & en) == 1'b 1 )
            begin
            i_timer_r <= i_timer_plus1_a;
            end

         // If there is a write to the timer control register then first remove
         // any pending interrupts (that is how interrupts are cleared). Note
         // that there is no need to remove the watchdog reset since a reset
         // automatically update the timer. Next register the new value by
         // updating the control flipflops. If the write is to the limit register
         // then update the internal limit register
         //
         if (auxdc(aux_addr, aux_tcontrol) == 1'b 1 & aux_write == 1'b 1)
            begin
            l_irq_3 <= 1'b 0;
            i_timer_pirq_r  <= 1'b 0;
            i_tcontrol_r    <= aux_dataw[0];
            i_timer_mode_r  <= aux_dataw[1];
            i_twatchdog_r   <= aux_dataw[2];
            end
         else if (auxdc(aux_addr, aux_tlimit) == 1'b 1 & aux_write == 1'b 1 )
            begin
            i_tlimit_r <= aux_dataw;
            end
         else
            i_tlimit_r <= i_tlimit_r;
      end
   end

   //  update the output signals according to internal signal
   // 
   assign timer_r      = i_timer_r; 
   assign tlimit_r     = i_tlimit_r; 
   assign timer_mode_r = i_timer_mode_r; 
   assign timer_pirq_r = i_timer_pirq_r; 
   assign tcontrol_r   = i_tcontrol_r; 
   assign twatchdog_r  = i_twatchdog_r; 

endmodule // module timer0

