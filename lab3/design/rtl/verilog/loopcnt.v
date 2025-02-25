// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 1998-2012 ARC International (Unpublished)
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
// This file contains logic that allows the processor to perform a zero
// overhead loop.
//
//======================= Inputs to this block =======================--
//
// clk              Global Clock.
//  
// rst_a            Global Reset (active high).
//
//
// loopcount_hit_a  From cr_int. Set true when a register write to the
//                  loopcount register is required. Decoded from wba
//                  and wben, and hence takes into account delayed load
//                  writes and host writes.
//
// loopend_hit_a    From cr_int. This signal is set true when
//                  i_pc_plus_inst_len points to the loop end address.
//                  It is used in conjuction with a number of other
//                  signals to decrement the loop counter.
//
// p2int            This signal indicates that an interrupt jump
//                  instruction (fantasy instruction) is currently in
//                  stage 2. This signal has a number of consequences
//                  throughout the system, causing the interrupt vector
//                  (int_vec[31:1]) to be put into the PC, and causing
//                  the old PC to be placed into the pipeline in order
//                  to be stored into the appropriate interrupt link
//                  register.
//                  Note that p2int and p2iv are mutually exclusive.
//                  Used here to prevent the loopcounter from being
//                  updated if a loop-end instruction is interrupted.
//                  (Note that pcen is true when p2int = '1', in order
//                  to load the interrupt vector).
//
// p2killnext_a     True when the instruction in stage 2 is a branch
//                  /jump type operation which will kill the following
//                  delay slot instruction. The following operation will
//                  be marked invalid when it is passed from stage 1
//                  into stage 2.
//
// pcen_niv      ** Version of pcen without ivalid_aligned decode
//                  Comment for pcen:
//                  U Program counter enable. When this signal is true,
//                  the PC will change at the end of the cycle,
//                  indicating that the memory controller needs to do
//                  perform a fetch on the next cycle using the address
//                  which will appear on currentpc[], which is supplied
//                  from aux_regs.
//                  This signal is affected by interrupt logic and all
//                  the other pipeline stage enables.
//                  It is used here to ensure that the loopcount
//                  register is only decremented when the pc can be
//                  updated, hence taking stalls into account.
//
//====================== Output from this block ======================--
//
// loopcount_r      This is the 32-bit value, zero-extended from
//                  loopcount_msb. It is put onto the source register
//                  buses by coreregs at the appropriate times.
//
//====================================================================--
//
module loopcnt (clk, 
                rst_a, 
                aux_addr, 
                aux_dataw, 
                aux_write, 
                currentpc_r,
                en1, 
                en2, 
                kill_p1_nlp_a, 
                loopcount_hit_a, 
                p1int, 
                p2_lp_instr, 
                p2_target, 
                p2condtrue, 
                p2int, 
                p2iv, 
                p3result, 
                pc_is_linear_r, 
                pcen, 
                pcounter_jmp_restart_r, 

                loop_int_holdoff_a, 
                do_loop_a, 
                loop_kill_p1_a, 
                loopcount_r, 
                loopend_hit_a, 
                loopend_r,
                loopstart_r);

`include "arcutil_pkg_defines.v"
`include "arcutil.v" 
`include "extutil.v"

   input                     clk; 
   input                     rst_a; 
   input [31:0]              aux_addr; 
   input [31:0]              aux_dataw; 
   input                     aux_write; 
   input [PC_MSB:0]          currentpc_r; 
   input                     en1; 
   input                     en2; 
   input                     kill_p1_nlp_a; 
   input                     loopcount_hit_a; 
   input                     p1int; 
   input                     p2_lp_instr; 
   input [PC_MSB:0]          p2_target;
   input                     p2condtrue; 
   input                     p2int; 
   input                     p2iv; 
   input [31:0]              p3result; 
   input                     pc_is_linear_r; 
   input                     pcen; 
   input                     pcounter_jmp_restart_r; 

   output                    loop_int_holdoff_a; 
   output                    do_loop_a; 
   output                    loop_kill_p1_a; 
   output [LOOPCNT_MSB:0]    loopcount_r; 
   output                    loopend_hit_a; 
   output [PC_MSB:0]         loopend_r; 
   output [PC_MSB:0]         loopstart_r; 

   wire                      do_loop_a;
   wire                      loop_int_holdoff_a;
   wire                      loop_kill_p1_a;
   wire                      loopend_hit_a;
   wire [LOOPCNT_MSB:0]      loopcount_r;
   wire [PC_MSB:0]           loopend_r;
   wire [PC_MSB:0]           loopstart_r;
   
   
   reg [LOOPCNT_MSB:0]       i_lp_cnt_r; 
   reg [PC_MSB:0]     i_lp_end_r; 
   reg [PC_MSB:0]     i_lp_start_r;
   
   wire                      i_cpc_eq_lp_end_a; 
   wire                      i_cpc_eq_lpend_minus2_a; 
   wire                      i_cpc_eq_lpend_minus4_a; 
   wire                      i_do_loop_a; 
   wire                      i_last_lp_instr_32_nxt; 
   reg                       i_last_lp_instr_32_r; 
   wire                      i_ld_lp_end_a; 
   wire                      i_ld_lpstart_a; 
   wire                      i_lp_cnt_dec_a; 
   wire                      i_lp_cnt_ne_one_a; 
   wire                      i_lp_cnt_ne_zero_a; 
   wire                      i_lp_end_hit_a; 
   wire                      i_lp_instr_a; 
   wire                      i_lp_over_run_action_a; 
   wire                      i_lp_over_run_detect_a; 
   wire [LOOPCNT_MSB:0]      i_lp_cnt_minus_1_a; 
   wire [LOOPCNT_MSB:0]      i_lp_cnt_nxt; 
   wire [PC_MSB:0]         i_lp_end_minus_2_a; 
   wire [PC_MSB:0]         i_lp_end_minus_4_a; 
   wire [LOOPCNT_MSB:0]      i_one_a; 
   wire [LOOPCNT_MSB:0]      i_zero_a; 
   wire [PC_MSB:0]    i_lp_end_nxt; 
   wire [PC_MSB:0]    i_lp_start_nxt; 
   wire [PC_MSB:0]    i_lp_end_decr_2_a;   
   wire [PC_MSB:0]    i_lp_end_decr_4_a;   

      
//------------------------------------------------------------------------------
// Loop end  detection
//------------------------------------------------------------------------------

   // Case 1 : The last instruction in the loop is a 32-bit type
   //
   // First time around the loop the "i_lp_over_run_detect_a" will trigger  
   //
   // On the second and all subsquent interations when the PC is equal to
   // lpend-4 the loop will trigger.
   //
   // Case 2 : The last instruction in loop is 16-bit type
   //
   // The "i_last_lp_instr_32_r" will never be set in this case because
   // the "i_cpc_eq_lpend_minus2_a" signal will be true before the
   // "i_lp_over_run_detect_a" is triggered.
   
   assign i_lp_end_hit_a = (((i_cpc_eq_lpend_minus2_a == 1'b1) & 
                              (i_last_lp_instr_32_r == 1'b0)) 
                              | 
                             ((i_cpc_eq_lpend_minus4_a == 1'b1) & 
                              (i_last_lp_instr_32_r == 1'b1)) 
                              | 
                             (i_lp_over_run_detect_a == 1'b1)) ? 1'b1 : 1'b0;


   // The following logic is used to detect the end of loop when the last
   // instruction is a 32-bit type. This is used when both word aligned and
   // longword aligned loops are used.
   // On the first interation of the loop the loopend is hit using the
   // "i_cpc_eq_lp_end_a" signal.  However this section of code will be hit
   // again when the loop has finished, to prevent the loop from triggering
   // the "i_lp_cnt_ne_zero_a" is included because on the last interation the
   // loopcount will be zero. We also need to make sure that the pc has arived
   // at the loopend linearly. The "pc_is_linear_r" signal is cleared on all
   // host writes to the PC and control instrucution to prevent this from
   // happening.
   //
   assign  i_cpc_eq_lp_end_a = (currentpc_r[PC_MSB:PC_LSB] == i_lp_end_r) ?
           1'b1 : 
           1'b0 ; 
      
   // There is a loop over run when :
   //
   // [1] The end of the loop is detected in stage 2.
   //
   // [2] The loop count value is not zero.
   //
   // [3] The program counter has moved lineraly from it's last address to the
   //     courrent address.  This signal is also cleared when a host access has
   //     modified the program counter
   //
   assign  i_lp_over_run_detect_a = (i_cpc_eq_lp_end_a &
                                     i_lp_cnt_ne_zero_a & 
                                     pc_is_linear_r);
   
   // An action is taken when a loop over run is detected when :
   //
   // [1] There is a loop over run.
   //
   // [2] The loop count value is not zero.
   //
   // [3] The instruction in stage 2 is not an interrupt.
   //
   // [4] There is no control transfer instruction to be resolved when the
   //     instruction cache cannot accept another fetch request.
   //
   assign  i_lp_over_run_action_a = (i_lp_over_run_detect_a &
                                     i_lp_cnt_ne_one_a &
                                    (~p2int) &
                                    (~pcounter_jmp_restart_r)) ;
 
 

   assign i_last_lp_instr_32_nxt = ((i_lp_instr_a | i_ld_lp_end_a) ==
                                       1'b1) ?
          1'b0 : 
                                      ((i_lp_over_run_action_a & en1) ==
                                       1'b1) ?
          1'b1 : 
          i_last_lp_instr_32_r ;
   
   always @(posedge clk or posedge rst_a)
   begin : lst_instr_32_sync_PROC
      if (rst_a == 1'b1)
         i_last_lp_instr_32_r <= 1'b0 ; 
      else
         i_last_lp_instr_32_r <= i_last_lp_instr_32_nxt ; 
   end 

   
   // Do a loop iteration when we have reached the end, if the count
   // value is not one. 
   //
   // [1] The end of the loop is detected.
   //
   // [2] The instruction in stage 1 is not killed (does not include loop
   //     overrun kill).
   //
   // [3] There are no interrupts in stage 1 or 2.
   //
   // [4] The loop count value is not equal to one.
   //
   assign i_do_loop_a = i_lp_end_hit_a         & 
                       (~kill_p1_nlp_a)          & 
                       (~(p1int | p2int))        &
                       (~pcounter_jmp_restart_r) & 
                        i_lp_cnt_ne_one_a ; 

//------------------------------------------------------------------------------
//  LOOP COUNT
//------------------------------------------------------------------------------

   // The loop is decremented when:
   //
   // [1] The end of the loop is detected.
   //
   // [2] The loop is not to be killed in stage 1 due to loop over-run.
   //
   // [3] There are no interrupts in stage 1 or 2.
   //
   // [4] There is no control transfer instruction to be resolved when the
   //     instruction cache cannot accept another fetch request.
   //
   // [5] The program counter is enabled.
   //
   assign i_lp_cnt_dec_a = (i_lp_end_hit_a         & 
                           (~kill_p1_nlp_a)          & 
                           (~(p1int | p2int))        & 
                           (~pcounter_jmp_restart_r) & 
                            pcen) ;
 
   // Generate value to be latched into the loop counter at the end of
   // the cycle.
   //
   // Note that if the lpcnt register is being written at the same
   // time as a loop is trying to decrement the counter, then the
   // register write will win, and the decremented counter value will be
   // ignored.
   //
   assign i_lp_cnt_nxt = (loopcount_hit_a == 1'b1) ? p3result : 
                                 (i_lp_cnt_dec_a ==  1'b1) ? i_lp_cnt_minus_1_a : 
          i_lp_cnt_r ; 

   // Latch the next value into the loop counter.
   //
   always @(posedge clk or posedge rst_a)
   begin : loopcnt_sync_PROC
      if (rst_a == 1'b1)
         i_lp_cnt_r <= {(THIRTY_TWO){1'b0}} ; 
      else
         i_lp_cnt_r <= i_lp_cnt_nxt ; 
   end 

   // Set lpcnt_eq_one true when the result is equal to one.
   //
   assign i_one_a = {{(THIRTY_ONE){1'b0}}, 1'b 1} ;
   
   assign i_lp_cnt_ne_one_a = (i_lp_cnt_r != i_one_a) ? 1'b1 : 1'b0 ;
 
   assign i_zero_a = {(THIRTY_TWO){1'b0}} ; 

   assign i_lp_cnt_ne_zero_a = (i_lp_cnt_r != i_zero_a) ? 1'b1 : 1'b0 ;
   
//=============================== Decrementer ================================--
//
   // Generate the decremented lpcnt value.
   //
   // 
   dec32 U_dec32 (.a (i_lp_cnt_r),
                  .q (i_lp_cnt_minus_1_a));
   
   // When a loop instruction is in stage 2 and the condition is true,
   // and stage 2 is being allowed to complete, the loopstart_r and
   // loopend_r registers are loaded.
   //
   assign i_lp_instr_a = (p2_lp_instr & p2condtrue & p2iv & en2) ;
   
   // The loopstart_r & loopend_r registers can alos be loaded by the ARC
   // (SR) or by the host.
   //   
   assign i_ld_lpstart_a = auxdc(aux_addr, AX_LSTART_N) & aux_write ;
   
   assign i_ld_lp_end_a = auxdc(aux_addr, AX_LEND_N) & aux_write ;
   
   // The loop start value comes either from currentpc_r (the instruction 
   // immmediately following the loop instruction) or via the auxiliary
   // register bus from either the SR instruction or from the host.
   // The loop end value comes either from target[31:1] (the destination
   // of the branch implied within the loop instruction, or from the
   // auxiliary register bus as for loopstart_r
   //
   // ** Note that for loopstart_r & loopend_r the address is taken from
   //    31:0 of the auxiliary  write data, in the same way as the PC is
   //    loaded by the host and by the Jcc instruction **
   //
   assign i_lp_start_nxt = (i_lp_instr_a == 1'b1) ? 
                                                    currentpc_r[PC_MSB:PC_LSB] :
                           (i_ld_lpstart_a == 1'b1) ? 
                            aux_dataw[PC_MSB:PC_LSB] :
          i_lp_start_r ;
   
   assign i_lp_end_nxt = (i_lp_instr_a == 1'b1) ? 
                                                   p2_target[PC_MSB:PC_LSB] :
                         (i_ld_lp_end_a == 1'b1) ? aux_dataw[PC_MSB:PC_LSB] : 
          i_lp_end_r ; 

   // The actual registers themselves --
   //
   always @(posedge clk or posedge rst_a)
   begin : loop_addr_sync_PROC
      if (rst_a == 1'b1)
      begin
         i_lp_start_r <= `THIRTY_ONE_ZEROS ; 
         i_lp_end_r   <= `THIRTY_ONE_ZEROS ; 
      end
      else
      begin
         i_lp_start_r <= i_lp_start_nxt ; 
         i_lp_end_r   <= i_lp_end_nxt ; 
      end 
   end // block: loop_addr_sync_PROC
   
   // Decrementers  
   assign i_lp_end_decr_2_a  = i_lp_end_r - `LOOPWORD_ONE;
   assign i_lp_end_decr_4_a  = i_lp_end_r - `LOOPWORD_TWO;
   assign i_lp_end_minus_2_a = {i_lp_end_decr_2_a, 1'b0} ;
   assign i_lp_end_minus_4_a = {i_lp_end_decr_4_a, 1'b0} ;

   assign i_cpc_eq_lpend_minus2_a = (currentpc_r == i_lp_end_minus_2_a) ?
          1'b 1 :
          1'b 0 ;
 
   assign i_cpc_eq_lpend_minus4_a = (currentpc_r == i_lp_end_minus_4_a) ?
          1'b 1 : 
          1'b 0 ;
   
   
   //============================ Output Drives =============================--
   //
   assign do_loop_a = i_do_loop_a ; 
   assign loop_kill_p1_a = i_lp_over_run_action_a;
   assign loopcount_r = i_lp_cnt_r ; 
   assign loopend_hit_a = i_lp_end_hit_a ; 
   assign loopend_r = {i_lp_end_r, `ONE_ZERO} ; 
   assign loopstart_r = {i_lp_start_r, `ONE_ZERO} ; 
   assign loop_int_holdoff_a = i_lp_over_run_action_a ;
   
endmodule
