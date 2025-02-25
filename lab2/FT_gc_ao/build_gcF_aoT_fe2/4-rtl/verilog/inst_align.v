// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 2001-2012 ARC International (Unpublished)
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
// Instruction Aligner. Aligns and formats 16 and 32-bit instructions.
// 
// ======================= Inputs to this block =======================--
// 
//  clk         Global Clock.
//   
//  RST_A       Global Reset (active high).
// 
//  p1iw[31:0]  The instruction word supplied by the memory
//              controller. It is considered to be valid when the
//              ivalid signal is true.
// 
//  ivalid      Qualifying signal for p1iw[31:0]. When it is low,
//              this indicates that the m/c has not been able to
//              fetch the requested opcode, and that the program
//              counter should not be incremented. The pipeline
//              might be stalled, depending upon whether the
//              instruction in stage 2 needs to look at the
//              instruction in stage 1.
//              When it is true, the instruction is clocked into 
//              pipeline stage 2 provided that the pipeline is able
//              to move on.
// 
//  en1         Stage 2 pipeline latch control. True when an
//              instruction is being latched into pipeline stage 2.
//              This signal will be low when ivalid_aligned = 0,
//              preventing junk instructions from being clocked into
//              the pipeline. Also means that interrupts do not
//              enter the pipe until a valid instruction is
//              available in stage 1.
// 
//  en2         Pipeline stage 2 enable. When this signal is true,
//              the instruction in stage 2 can pass into stage 3 at
//              the end of the cycle. When it is false, it will hold
//              up stage 2 and stage 1 (pcen).
// 
//  p2b_dojcc   True when a jump is going to happen.
//              Relates to the instruction in p2. Includes p2iv.
// 
//  p2_dorel    True when a relative branch (not jump) is going to
//              happen. Relates to the instruction in p2. Includes
//              p2iv.
//
//  p4_docmprel True when a relative compare branch (not jump) is going
//              to happen. Relates to the instruction in p2. Includes
//              p2iv.
// 
//  h_pcwr      True when the host writes to the PC register
// 
//  h_pcwr32    True when the host writes to the PC32 register
// 
//  h_status32  True when the host writes to the Status32 register
// 
//  loopend_hit_a
//              From to cr_int. This signal is set true when
//              pc_plus_len points to the loop end address. It is
//              used in conjuction with a number of other signals to
//              decrement the loop counter.
// 
//  misaligned_target
//              True when the current PC is word aligned
// 
//  do_inst_step_r
//              This signal is set when the single step flag (SS)
//              and the instruction step flag (IS) in the debug
//              register has been written to simultaneously through
//              the host interface. It indicates that an instruction
//              step is being performed. When the instruction step
//              has finished this signal goes low.
// 
//  ivic        Indicates that all values in the cache are to be 
//              invalidated. (it stands for InValidate Instruction
//              Cache). It is anticipated that this signal will be 
//              generated from a decode of an SR instruction.
//              Note that due to the pipelined nature of the ARC, up 
//              to three instructions could be issued following the 
//              SR which generates the ivic signal. Cache
//              invalidates must be supressed when a line is being
//              loaded from memory. This is done at the auxiliary
//              register which generates ivic.
// 
//  p2int       This signal indicates that an interrupt jump
//              instruction (fantasy instruction) is currently in
//              stage 2. This signal has a number of consequences
//              throughout the system, causing the interrupt vector
//              (int_vec) to be put into the PC, and causing the old
//              PC to be placed into the pipeline in order to be
//              stored into the appropriate interrupt link register.
//              Note that p2int and p2iv are mutually exclusive.
// 
//  pcen_niv    Version of pcen excluding ivalid_aligned decode.
// 
//  ifetch_aligned
//              This signal, from rctl in the ARC, indicates to
//              the cache controller that a new instruction is
//              required, and should be fetched from memory from
//              the address which will be clocked into
//              currentpc[25:2] at the end of the cycle. It
//              is also true for one cycle when the processor has
//              been started following a reset, in order to get the
//              ball rolling.
//               An instruction fetch will also be issued if the
//              host changes the program counter when the ARC is
//              halted, provided it is not directly after a reset.
//               The ifetch signal will never be set true whilst
//              the memory controller is in the process of doing an
//              instruction fetch, so it may be used by the memory
//              controller as an acknowledgement of instruction
//              receipt.
// 
//  p2limm      This signal indicates that the instruction in stage 2
//              is using a 32-Bit limm.  When this signal is true the
//              instruction word in stage 1 is limm data.
// 
// ====================== Output from this block ======================--
// 
//  p1inst_16   This signal is true when the instrucion forwarded is a
//              16-bit type.
// 
//  aligner_do_pc_plus_8
//             This signal is true when an instruction stream consists of
//             word aligned 32-bit instructions. As can be seen at time T
//             the 16-bit instruction at address n is presented (the high
//             part of the next longword is stored in the buffer). At T+1
//             the current PC is n+2. The data requested (at time T) and
//             returned from memory at time T+1 is the longword at
//             n+4 (and therefore the half word at n+6 is buffered).  To
//             be able to present the complete 32-bit instruction at n+6
//             the memory address must be set to n+8, which is the
//             longword aligned version of PC+8 ( (n+2)+8 =
//             (n+10)&&0xfffffffc = n+8).
//             This process will continue until a 16-bit instruction or
//             a jcc/brcc/bcc instruction is encountered.
// 
// 
//             --------------------------------
//             |              |               |
//        n    |    16-bit    |    32-bit_a0  |
//             |              |               |
//             --------------------------------
//             |              |               |
//        n+4  |   32-bit_b0  |    32-bit_a1  |
//             |              |               |
//             --------------------------------
//             |              |               |
//        n+8  |   32-bit_b1  |    32-bit_a2  |
//             |              |               |
//             --------------------------------
//             |              |               |
//        n+12 |   32-bit_b2  |    xxxxxxx    |
//             |              |               |
//             --------------------------------
// 
// 
//  aligner_pc_enable
//             This signal is true when the instruction aligner needs
//             fetch the longword from the pc+4 address to be able to
//             reconstruction a word aligned 32-bit instruction or
//             limm. if a jcc/brcc/bcc as a word aligned target which is
//             also a 32-bit instruction the aligner is unable to
//             present the instruction immediatly.  The aligner must
//             stall stage 1 (this is done by forcing ivalid_aligned to
//             false) and request the n+4 longword.  When the n+4
//             longword is returned the aligner can construct the
//             complete instruction from the buffered high word at
//             address n+2 and the low word at address n+4.
// 
//             --------------------------------
//             |              |               |
//        n    |    xxxxxx    |    32-bit_a0  |
//             |              |               |
//             --------------------------------
//             |              |               |
//        n+4  |   32-bit_b0  |    xxxxxxxxx  |
//             |              |               |
//             --------------------------------
//
//  ivalid_aligned
// 
//            This signal is true when the ivalid signal from the ifetch
//            interface is true except when the aligner need to get the
//            next longword to be able to reconstruct the current
//            instruction. See explanation of aligner_pc_enable.
// 
// 
//  p1iw_aligned_a
// 
//           This bus contains the current instruction word and is
//           qualified with ivalid_aligned.
// 
//  p1_limm_data
//
//           This is the unlatched 32-bit long immediate data value which
//           contains a long immediate dataword to be switched onto one
//           of the source operand buses.
//
// ----------------------------------------------------------------------
// 
// 
module inst_align (clk,
                   rst_a,
                   p4_docmprel,
                   p2b_dojcc,
                   p2_dorel,
                   p2_dopred,
                   do_loop_a,
                   do_inst_step_r,
                   en1,
                   en2,
                   en2b,
                   h_pcwr,
                   h_pcwr32,
                   h_status32,
                   ifetch_aligned,
                   ivalid,
                   ivic,
                   kill_tagged_p1,
                   misaligned_target,
                   p1iw,
                   pcounter_jmp_restart_r,
                   p2int,
                   p2limm,
                   pcen_niv,

                   ifetch,
                   ivalid_aligned,
                   p1inst_16,
                   p1iw_aligned_a,
                   aligner_do_pc_plus_8,
                   aligner_pc_enable);

`include "arcutil_pkg_defines.v" 
`include "arcutil.v"

input   clk; 
input   rst_a; 
input   p4_docmprel; 
input   p2b_dojcc; 
input   p2_dorel; 
input   p2_dopred;
input   do_loop_a;  
input   do_inst_step_r; 
input   en1; 
input   en2; 
input   en2b; 
input   h_pcwr; 
input   h_pcwr32; 
input   h_status32; 
input   ifetch_aligned; 
input   ivalid; 
input   ivic;
input   kill_tagged_p1; 
input   misaligned_target; 
input   [31:0] p1iw; 
input   pcounter_jmp_restart_r; 
input   p2int; 
input   p2limm; 
input   pcen_niv; 

output  ifetch; 
output  ivalid_aligned; 
output  p1inst_16; 
output  [DATAWORD_MSB:0] p1iw_aligned_a; 
output  aligner_do_pc_plus_8; 
output  aligner_pc_enable;

 
wire    ifetch; 
wire    ivalid_aligned; 
wire    p1inst_16; 
wire    [DATAWORD_MSB:0] p1iw_aligned_a; 
wire    aligner_do_pc_plus_8; 
wire    aligner_pc_enable; 

// --------------------------------------------------------------------
// Internal Signals
// --------------------------------------------------------------------
//

wire    [3:0] i_aligner_mux_ctrl_a; 
wire    i_buffer_invalid_a; 
wire    [16:0] i_buffer_nxt; 
reg     [16:0] i_buffer_r; 
wire    i_buffer_valid_a; 
reg     i_buffer_valid_r; 
reg     i_aligner_do_pc_plus_8_a; 
wire    i_gen_new_ifetch_a; 
wire    i_ifetch_a; 
reg     i_inst_is_16_bit_a; 
wire    i_instword_1_is_16_bit_a; 
wire    i_instword_2_is_16_bit_a; 
wire    i_ivalid_a; 
reg     [DATAWORD_MSB:0] i_p1iw_a; 
reg     [DATAWORD_MSB:0] i_p1iw_aligned_a;


//  rtl
// --------------------------------------------------------------------
// Endianness support
// --------------------------------------------------------------------

always @(p1iw)
   begin : endian_async_PROC

      // Little-endian swaps the 16-bit words in an instruction long-word
      i_p1iw_a = {p1iw[15:0], p1iw[DATAWORD_MSB:16]};  
   end
   
// --------------------------------------------------------------------
// Signal Assignments
// --------------------------------------------------------------------

// Is the first word a 16-bit instruction?
// All the 16-bit instructions reside in major opcode slots 0x0C to
// 0x1F. The 5-bit opcode sits at bit positions 31 downto 27.
//
assign i_instword_1_is_16_bit_a = i_p1iw_a[31] | (i_p1iw_a[30] & i_p1iw_a[29]);
// Is the second word a 16-Bit instruction?
// All the 16-bit instructions reside in major opcode slots 0x0C to
// 0x1F. The 5-bit opcode sits at bit positions 15 downto 11.
//
assign i_instword_2_is_16_bit_a = i_p1iw_a[15] | (i_p1iw_a[14] & i_p1iw_a[13]); 

// This signal informs the core that the instruction is of 16-bit type
//
assign p1inst_16 = i_inst_is_16_bit_a;
 
// I-cache interface control signals
//
assign ifetch = i_ifetch_a; 
assign ivalid_aligned = i_ivalid_a; 

// When the aligner is processing a stream of word aligned
// 32-bit instructions the aligner requires that the cache/memory
// returns the longword address directly after the current PC
//
assign aligner_do_pc_plus_8 = i_aligner_do_pc_plus_8_a;
 
//  Stage 1 instruction word
//
assign p1iw_aligned_a = i_p1iw_aligned_a;

// ---------------------------------------------------------------------
//  ALIGNER MUX Control
// ---------------------------------------------------------------------
//  All signals below are mutally exclusive
//
// Instruction longword has a 16-bit instruction in it's first word
// location.
//
assign i_aligner_mux_ctrl_a[0] = ((misaligned_target        == 1'b 0) &
                                  (i_instword_1_is_16_bit_a == 1'b 1) & 
                                  (p2limm                   == 1'b 0)) ?
       1'b 1 : 
       1'b 0;

// The buffer contains a 16-bit instruction and the pc is word aligned.
//
assign i_aligner_mux_ctrl_a[1] = ((misaligned_target == 1'b 1) &
                                  (i_buffer_valid_r  == 1'b 1) & 
                                  (i_buffer_r[16]    == 1'b 1) &
                                  (p2limm            == 1'b 0)) ? 1'b 1 : 
       1'b 0;
 
// The buffer contains half a longword (instruction or limm).
//
assign i_aligner_mux_ctrl_a[2] = ((misaligned_target == 1'b 1) &
                                  (i_buffer_valid_r  == 1'b 1) & 
                                  ((i_buffer_r[16]   == 1'b 0) |
                                   (p2limm           == 1'b 1))) ? 1'b 1 : 
       1'b 0;
 
// instruction longword has a 16-bit instruction in it's second word
// location.
//
assign i_aligner_mux_ctrl_a[3] =((misaligned_target        == 1'b 1) &
                                 (i_buffer_valid_r         == 1'b 0) & 
                                 (i_instword_2_is_16_bit_a == 1'b 1)) ?
       1'b 1 : 
       1'b 0; 

// The logic below detects when the aligner is required to fetch the
// second part of a longword which is located at the next longword
// address.
//
// The original ARC5 design did the following in the case of a
// misaligned Non-linear 32-bit access:
//
// When the initial request for the instruction is made, the buffer is
// invalidated since the instruction fetch is non-linear (a jump/branch
// or pc write etc).
// 
// When the first part of the instruction is supplied by the cache
// system, and the core is ready to accept it, the following condition 
// will be true:
//
// misaligned_target        = '1'  - last instruction fetch was
//                                    misaligned
// i_buffer_valid_r         = '0'  - no stored instruction parts
// i_instword_2_is_16_bit_a = '0'  - cache has the first part of a
//                                   32-bit op
// ivalid                   = '1'  - cache is supplying a valid
//                                   instruction
// pcen_niv            = '1'  - the core is running and ready to
//                                   accept the instruction
//
// Under these circumstances, the logic does the following:
//    a. it forces the ivalid signal low to supress the 32-bit
//       instruction 
//    b. it clocks the first part of the instruction into the buffer
//    c. it asks the cache system for the next instruction word
//
// The effect of including pcen_niv is that the second part of the
// instruction is only fetched once the core is ready to accept it.
// In an ideal world, the aligner would detect that the next part of the 
// instruction is required, and go off and get it without any reference
// to the core. This will firstly be more intuitive, and secondly will 
// allow the pcen_niv signal to be removed from the logic.
//
// Another change instituted in this file is to ensure that the buffer
// is allowed to update during an ifetch when the core is halted.
//
// Other changes are required in cr_int to ensure that the correct
// program counter is presented. The signal pcen_niv is also used 
// there to select the program counter value. Changes are required to
// ensure that the right PC value is selected when the core is halted
// and the PC is updated.
// 
assign i_gen_new_ifetch_a = ((misaligned_target        == 1'b 1) &
                             (kill_tagged_p1           == 1'b 0) &
                             (i_buffer_valid_r         == 1'b 0) & 
                             ((i_instword_2_is_16_bit_a == 1'b 0) |
                              (p2limm                   == 1'b 1)) &
                             (ivalid                   == 1'b 1)) ? 1'b 1 : 
       1'b 0;

// The signal going to cr_int (aligner_pc_enable) is used only when
// ivalid = '1' to qualify the PC update. Hence we can produce a version
// here which does not include ivalid, since it will be included later.
//
assign aligner_pc_enable = ((misaligned_target        == 1'b 1) &
                            (kill_tagged_p1           == 1'b 0) &
                            (i_buffer_valid_r         == 1'b 0) & 
                            ((i_instword_2_is_16_bit_a == 1'b 0) |
                             (p2limm                   == 1'b 1))) ? 1'b 1 : 
       1'b 0; 

// The above situation has been indentifed and now the aligner acts upon
// it by generating a new ifetch to the ifetch interface. The entire
// instruction will not be valid until both parts have been fetched.
//
assign i_ifetch_a = (i_gen_new_ifetch_a == 1'b 1) ? 1'b 1 : 
       ifetch_aligned;

assign i_ivalid_a = (i_gen_new_ifetch_a == 1'b 1) ? 1'b 0 : 
       ivalid; 

// ---------------------------------------------------------------------
//  Aligner Mux
// ---------------------------------------------------------------------
always @(i_aligner_mux_ctrl_a or i_buffer_r or i_p1iw_a)
   begin : aligner_async_PROC
   case (i_aligner_mux_ctrl_a)
   4'b 0001:
      begin
      // 16-bit instruction type
      i_inst_is_16_bit_a = 1'b 1;

      i_aligner_do_pc_plus_8_a = 1'b 0;
    
      //  16-bit instruction word
      i_p1iw_aligned_a = {i_p1iw_a[31:16],
                           //  Flag bit 
                           1'b 0,
                           //  B field MSBs
                           2'b 00, i_p1iw_a[26], 
                           //  C field
                           2'b 00, i_p1iw_a[23], i_p1iw_a[23:21],
                           // Padding;
                           6'b 000000};

      end

   4'b 0010:
      begin
      // 16-bit instruction type
      i_inst_is_16_bit_a = 1'b 1;

      i_aligner_do_pc_plus_8_a = 1'b 0;

      //  16-bit instruction word
      i_p1iw_aligned_a = {i_buffer_r[15:0],
                           //  Flag bit 
                           1'b 0,
                           //  B field MSBs
                           2'b 00, i_buffer_r[10], 
                           //  C field
                           2'b 00, i_buffer_r[7], i_buffer_r[7:5],
                           // Padding;
                           6'b 000000};

      end

   4'b 0100:
      begin
      // 32-bit instruction type        
      i_inst_is_16_bit_a = 1'b 0;

      i_aligner_do_pc_plus_8_a = 1'b 1;

      i_p1iw_aligned_a = {i_buffer_r[15:0], i_p1iw_a[31:16]};  

      end

   4'b 1000:
      begin
      // 16-bit instruction type
      i_inst_is_16_bit_a = 1'b 1;

      i_aligner_do_pc_plus_8_a = 1'b 0;
    
      //  16-bit instruction word
      i_p1iw_aligned_a = {i_p1iw_a[15:0],
                           // Flag bit 
                           1'b 0,
                           //  B field MSBs
                           2'b 00, i_p1iw_a[10], 
                           //  C field
                           2'b 00, i_p1iw_a[7], i_p1iw_a[7:5],
                           // Padding;
                           6'b 000000};
      end
   default:
      begin
      // 32-bit instruction type     
      i_inst_is_16_bit_a = 1'b 0;

      i_aligner_do_pc_plus_8_a = 1'b 0;

      i_p1iw_aligned_a = i_p1iw_a;

      end
   endcase
   end

// ---------------------------------------------------------------------
//  Buffer has valid data
// ---------------------------------------------------------------------
// Buffer valid does not indicate if the buffer contains a valid 16-bit
// instruction or half of a valid 32-bit instruction simply because this
// kind of information is not know until stage 2
//
// Buffer valid indicates that buffer contains something that can be
// used to construct a valid instruction word in stage 1.
//
// This is true when :- the longword from the cache is valid
// 
// The original signal for A5 looked like this:
//
//assign i_buffer_valid_a = ivalid &
//                          //  16-bit instruction in first part of
//                          // longword
//                          ((~misaligned_target &
//                            i_instword_1_is_16_bit_a |
//                          //  the pc value is word aligned
//                            misaligned_target) & 
//                          //  the current instruction will move into
//                          // stage2
//                         (en1 | i_gen_new_ifetch_a |
//                            do_inst_step_r)) &
//                          //  the pc is allowed to advance
//                          pcen_niv;
//
// However, to allow the buffer to update as soon as the data is 
// available from the cache (even when the core is halted), the
// qualifying signal pcen_niv has been removed from the
// i_gen_new_ifetch_a mode.
//
assign i_buffer_valid_a = ivalid &
                          (~kill_tagged_p1) &
                          // 16-bit instruction in first part of
                          // longword.
                          (((~misaligned_target) &
                            i_instword_1_is_16_bit_a |
                          // The pc value is word aligned.
                            misaligned_target) & 
                          // The current instruction will move into 
                          // stage 2..
                          (((en1 | do_inst_step_r) &
                          // The pc is allowed to advance.
                            pcen_niv) |
                          i_gen_new_ifetch_a));

// The buffer is no long valid if :-
assign i_buffer_invalid_a = (
                            //  A bra has occured in stage 2.
                            ((p2_dorel | p2_dopred) & en2 |
                            //  A jmp has occured in stage 2B.
                             (p2b_dojcc & en2b) |
                            //  Branch and compare in stage 4 has occured.
                             p4_docmprel | 
                            // An interrupt has occured in stage 2 and
                            // the buffer contents will not be needed as
                            // the interrupt will jump in stage 2.
                             (p2int & en2)) & 
                            // The above conditions need qualifing with
                            // ivalid because they don't actually happen
                            // in the current cycle if valid is not true
                            // (which indicates the cache can accept
                            // another ifetch).
                            (pcen_niv & ivalid) |
                            (pcounter_jmp_restart_r & ivalid) |
                            // The cache has been invalidated. 
                            ivic | 
                            // A write to the pc via the host. 
                            (h_pcwr | h_pcwr32) |
                            // The buffer contents are still need when the
                            // host restarts by clearing the halt bit.
                            (h_status32 & (~misaligned_target)) | 
                            // The buffer contents have been used.
                            i_buffer_r[16] & (~p2limm) &
                            // The current longword is an aligned 32-bit
                            // instruction or a limm.
                            misaligned_target & ifetch_aligned & en1 |
                            ((~i_instword_1_is_16_bit_a) | p2limm) & 
                            ~misaligned_target |
                            // Looping back during a zero overhead loop.
                            (do_loop_a & en1)); 

always @(posedge clk or posedge rst_a)
   begin : buffer_valid_sync_PROC
   if (rst_a == 1'b 1)
      begin
      //  asynchronous reset (active high)
      i_buffer_valid_r <= 1'b 0;    
      end
   else
      begin
      //  rising clock edge
      //
      // Buffer valid does not indicate if the buffer contains a valid
      // 16-bit instruction or half of a valid 32-bit instruction
      // simply because this kind of information is not know until stage
      //  2.
      // Buffer valid indicates that buffer contains something that can
      // be used to contruct a valid instruction word in stage 1.
      if (i_buffer_invalid_a == 1'b 1)
        begin
                   i_buffer_valid_r <= 1'b 0; 
        end
          else if (i_buffer_valid_a == 1'b 1)
        begin
           i_buffer_valid_r <= 1'b 1; 
        end

      end
   end

// ---------------------------------------------------------------------
// Instruction Word buffer
// ---------------------------------------------------------------------
//  The buffer is updated when either the instruction word from the
//  I-cache is valid and the instruction is allowed to advance or if
//  the target is wordaligned an is a 32-bit instruction.
//
assign i_buffer_nxt = ((i_buffer_valid_a == 1'b 1) &
                       (i_ifetch_a == 1'b 1)) ?
       //  Get a new buffer value when the aligner really
       //  needs one.
       //
       {i_instword_2_is_16_bit_a, 
        i_p1iw_a[15:0]} : 
       i_buffer_r;
 
always @(posedge clk or posedge rst_a)
   begin : instr_word_sync_PROC
   if (rst_a == 1'b 1)
      begin
      i_buffer_r <= {(SEVENTEEN){1'b 0}};    
      end
   else
      begin
      i_buffer_r <= i_buffer_nxt;   
      end
   end

// ---------------------------------------------------------------------
// THE END........
// ---------------------------------------------------------------------

endmodule // module inst_align

