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
// This file contains logic that allows the processor to perform
// all ALU operations and LD/ST accesses.
//
//=========================== Inputs to this block ===========================--
//
// clk                          System Clock
// 
// rst_a                        System Reset (Active high)
//
// aluflags_r       [3:0]       Architectual aritmetic flags ZNCV.
//                              The flags are updated at the end of stgae 3.
//
// e1flag_ r                    Interrupt mask level 1 bit.
//
// e2flag_r                     Interrupt mask Level 2 bit
//
// aux_datar        [31:0]      Auxiliary read data. This is the data that has
//                              been read from an auxiliary mapped register. 
//
// aux_pc32hit                  Auxiliary register access is to 32-bit PC
//                              register. Qualify with p3lr and route
//                              constructed link register as below.    
//
// aux_pchit                    Auxiliary register access is to 32-bit PC
//                              register. Qualify with p3lr and route
//                              constructed link register as below.
//
// cr_hostw                     The host data is routed to the output for writes
//                              to core registers.         
//
// drd              [31:0]      Returning load data from load store unit.
//
// h_dataw          [31:0]      Host data write data.  The host will place data
//                              on this bus that will be written to register in
//                              the machine.
//
// ldvalid_wb                   Returning load write-back. The load store unit
//                              has signaled that a returning load will write
//                              the data on drd[31:0] at the end of the cycle.
//
// p3_alu_absiv                 Indicates that an ABS instruction is in stage 3.
//
// p3_alu_arithiv               Indicates that an ALU instruction is in stage 3.
//
// p3_alu_flagiv                Indicates that a flag setting ALU instruction is
//                              in stage 3.
//
// p3_alu_logiciv               Indicates that a logic instruction is in stage
//                              3.
//
// p3_alu_minmaxiv              Indicates that a MIN/MAX instruction is in stage
//                              3.
//
// p3_alu_op [1:0]              Describes which ALU operation is in stage 3.
//
// p3_alu_snglopiv              Indicates that a single operand instruction is
//                              in stage 3.
//
// p3_bit_op_sel [1:0]          Indicates to the ALU which operation to complete
//                              for the compare&branch operations       
//
//
// p3awb_field_r    [1:0]       Indicates the write-back mode of the LD/ST
//                              instruction in stage 3.
//
// p3dolink                     This signal is true when a JLcc or BLcc
//                              instruction has been taken, indicating that the
//                              link register needs to be stored. It is used by
//                              ALU to switch the program counter value which
//                              has been passed down the pipeline onto the
//                              p3result bus. If this signal is to be used to
//                              give a fully qualified indication that a J/BLcc
//                              is in stage 3, it must be qualified with p3iv
//                              to take account of pipeline tearing between
//                              stages 2b and 3 which could cause the
//                              instruction in stage 3 to be repeated.              
//
// p3int                        From int_unit. This signal indicates that an
//                              interrupt jump instruction (fantasy instruction)
//                              is currently in stage 2. This signal has a
//                              number of consequences throughout the system,
//                              causing the interrupt vector (int_vec) to be put
//                              into the PC, and causing the old PC to be placed
//                              into the pipeline in order to be stored into the
//                              appropriate interrupt link register.
//                              Note that p3int and p3iv are mutually exclusive.
//
// p3lr                         This signal is used by hostif. It is produced
//                              from a decode of p3opcode, p3iw(13) (check for
//                              LR) and includes p3iv. Also used in extension
//                              logic for sepArate decoding of auxiliary
//                              accesses from host and ARC 600.            
//
// p3_max_instr                 Indicates that the instruction in stage 3 is a
//                              maximum.
//
// p3_min_instr                 Indicates that the instruction in stage 3 is a
//                              minimum.
//
// p3wb_en                      Stage 4 pipeline latch control. Controls
//                              transition of the data on the p3result[31:0]
//                              bus, and the corresponding register address from
//                              stage 3 to stage 4. As these buses carry data
//                              not only from instructions but from delayed load
//                              writebacks and host writes, they must be
//                              controlled separately from the instruction in
//                              stage 3. This is because if the instruction in
//                              stage 3 does not need to write a value back into
//                              a register, and a delayed load writeback is
//                              about to happen, the instruction is allowed to
//                              complete (i.e. set flags) whilst the data from
//                              the load is clocked into stage 4. If however the
//                              instruction in stage 3 DOES need to writeback to
//                              the register file when a delayed load or
//                              multicycle writeback is about to happen, then
//                              the instruction in stage 3 must be held up and
//                              not allowed to change the processor state,
//                              whilst the data from the delayed load is clocked
//                              into stage 4 from stage 3.
//                              *** Note that p3wb_en can be true even when the
//                              processor is halted, as delayed load writebacks
//                              and host writes use this signal in order to
//                              access the core registers. ***          
//
// s1val            [31:0]      Normal source 1 register.  This register is
//                              loaded with the operand data for basecase
//                              operations.  The value only changes when a valid
//                              basecase instruction is in stage 2b.
//
// s2val             [31:0]     Normal source 2 register.  This register is
//                              loaded with the operand data for basecase
//                              operations.  The value only changes when a valid
//                              basecase instruction is in stage 2b.
//
// x_multic_wben                From xrctl. Multi-cycle extension writeback
//                              enable. This signal is true when the multi-cycle
//                              instruction wants to write-back. It should have
//                              been qualified with p3iv, and p3condtrue and the
//                              extension  opcode. If any other instruction
//                              requires a write back at the same time this
//                              signal is true the ARC 600 pipeline will stall
//                              and the multi-cycle extension will write back.    
//
// xresult          [31:0]      Extension Result. The 32-bit result of an ALU
//                              operation is asserted here. 
//
// x_snglec_wben                Single-cycle extension writeback enable. This
//                              signal is true when the single cycle instruction
//                              wants to write-back. It should have been
//                              qualified with p3iv, and p3condtrue and the
//                              extension  opcode. If any other instruction
//                              requires a write back at the same time this
//                              signal is true the ARCompact pipeline will stall
//                              and the multi-cycle extension will write back.    
//
// s2val_inverted_r             This signal when set indicates that the value in
//                              the s2val register has been inverted for the
//                              current operation.
//
//========================== Output from this block ==========================--
//
// alurflags       [3:0]        New stage 3 ALU flags. Generated in this stage
//                              by the current instruction. At the end of the
//                              cycle this data will be latched into the
//                              aluflags_r register.
//
// br_flags_a      [3:0]        The flags generated by a compar&branch type
//                              instruction.
//
// mc_addr         [31:0]       The memory address to be sent to the load-store
//                              unit.
//
// p3res_sc        [31:0]       Stage 3 result for short-cutting back to stage
//                              2b
//
// p3result        [31:0]       Stage 3 result for writing back to register file
//
// p3result_nld    [31:0]       As above excluding the returning load path.
//
// wbdata          [31:0]       Stage 4 write data.
//
//============================================================================--
//
module bigalu (clk,
               rst_a,
               aluflags_r,
               e1flag_r,
               e2flag_r,
               aux_datar,
               aux_pc32hit,
               aux_pchit,
               cr_hostw,
               drd,
               h_dataw,
               ldvalid_wb,
               p3_alu_absiv,
               p3_alu_arithiv,
               p3_alu_logiciv,
               p3_alu_op,
               p3_alu_snglopiv,
               p3_shiftin_sel_r,
               p3_bit_op_sel,
               p3_sop_op_r,
               p3awb_field_r,
               p3dolink,
               p3int,
               p3lr,
               p3_min_instr,
               p3_max_instr,
               p3wb_en,
               s1val,
               s2val,
               x_multic_wben,
               xresult,
               x_snglec_wben,
               s2val_inverted_r,

               alurflags,
               br_flags_a,
               mc_addr,
               p3res_sc,
               p3result,
               p3result_nld,
               wbdata);

`include "arcutil_pkg_defines.v" 
`include "arcutil.v" 
`include "extutil.v" 

   input                          clk; 
   input                          rst_a; 
   input  [3:0]                   aluflags_r; 
   input                          e1flag_r; 
   input                          e2flag_r;
   input  [31:0]                  aux_datar; 
   input                          aux_pc32hit;
   input                          aux_pchit; 
   input                          cr_hostw; 
   input  [31:0]                  drd; 
   input  [31:0]                  h_dataw; 
   input                          ldvalid_wb; 
   input                          p3_alu_absiv;
   input                          p3_alu_arithiv;
   input                          p3_alu_logiciv;
   input  [1:0]                   p3_alu_op;
   input                          p3_alu_snglopiv;
   input  [1:0]                   p3_shiftin_sel_r;
   input  [1:0]                   p3_bit_op_sel;
   input  [2:0]                   p3_sop_op_r;
   input  [1:0]                   p3awb_field_r;
   input                          p3dolink; 
   input                          p3int; 
   input                          p3lr; 
   input                          p3_min_instr; 
   input                          p3_max_instr; 
   input                          p3wb_en; 
   input  [31:0]                  s1val; 
   input  [31:0]                  s2val; 
   input                          x_multic_wben; 
   input  [31:0]                  xresult; 
   input                          x_snglec_wben;
   input                          s2val_inverted_r; 

   output [3:0]                   alurflags; 
   output [3:0]                   br_flags_a; 
   output [31:0]                  mc_addr; 
   output [31:0]                  p3res_sc; 
   output [31:0]                  p3result; 
   output [31:0]                  p3result_nld; 
   output [31:0]                  wbdata; 

   wire [3:0]                     alurflags; 
   wire [31:0]                    p3res_sc;
   wire [31:0]                    p3result;
   wire [31:0]                    p3result_nld;
   wire [31:0]                    mc_addr; 
   wire [31:0]                    wbdata; 
   wire [3:0]                     br_flags_a; 

   reg                            i_adder_cin_a; 
   wire                           i_adder_neg_a; 
   wire                           i_adder_ovf_a; 
   wire                           i_adder_carry_a; 
   wire                           i_adder_cout_a; 
   wire   [DATAWORD_MSB:0]        i_adder_result_a; 
   wire   [DATAWORD_MSB:0]        i_adder_result_ncin_a; 
   wire                           i_adder_zero_a; 
   wire                           i_alu_c_flag_r; 
   wire                           i_alu_v_flag_r; 
   wire   [1:0]                   i_arith_c_flag_sel_a; 
   wire                           i_br_carry_a; 
   wire   [3:0]                   i_br_flags_a; 
   wire                           i_br_negative_a; 
   wire                           i_br_overflow_a; 
   wire                           i_br_zero_a; 
   wire                           i_do_pc32_a; 
   wire                           i_do_statreg_a; 
   wire   [1:0]                   i_flag_sel_a; 
   wire                           i_logic_zero_a; 
   reg    [DATAWORD_MSB:0]        i_logicres_a; 
   wire                           i_logicres_msb_a; 
   reg                            i_o_carry_a; 
   reg                            i_o_negative_a; 
   reg                            i_o_overflow_a; 
   reg                            i_o_zero_a; 
   wire                           i_p3_min_max_decode_a; 
   wire   [DATAWORD_MSB:0]        i_p3result_nld_a; 
   wire   [DATAWORD_MSB:0]        i_res_a; 
   reg                            i_s2_gt_s1_a; 
   reg                            i_s2_lt_s1_a; 
   reg    [DATAWORD_MSB:0]        i_s2val_logic_a; 
   reg    [DATAWORD_MSB:0]        i_s2val_mask_a; 
   wire                           i_s2val_msb_r; 
   reg    [DATAWORD_MSB:0]        i_s2val_one_bit_a; 
   reg                            i_shftin_a; 
   wire                           i_sngleopres_msb_a; 
   reg    [DATAWORD_MSB:0]        i_snglopres_a; 
   reg                            i_sop_carry_a; 
   reg                            i_sop_ovf_a; 
   wire                           i_sop_zero_a; 
   wire   [1:0]                   i_src_msbs_a; 
    wire   [DATAWORD_MSB:0]        i_statreg_a; 
   wire                           i_use_arith_a; 
   wire                           i_use_aux_a; 
   wire                           i_use_ext_a; 
   wire                           i_use_logic_a; 
   wire                           i_use_s1val_a; 
   wire                           i_use_s2val_a; 
   wire                           i_use_sop_a; 
   wire   [DATAWORD_MSB:0]        i_wbdata_nxt; 
   reg    [DATAWORD_MSB:0]        i_wbdata_r;
   wire                           i_min_max_c_flag_a;

  //Flag signal assignements
  //
  assign i_alu_c_flag_r = aluflags_r[A_C_N]; 
  assign i_alu_v_flag_r = aluflags_r[A_V_N]; 

//------------------------------------------------------------------------------
// Carry in bit.
//------------------------------------------------------------------------------
//
   // The carry in bit selection can be done here because the adder architecture
   // has been selected to allow the carry in to be non-timing critical 
   //  
   always @(i_alu_c_flag_r or p3_alu_absiv or p3_alu_op or s2val_inverted_r)
    begin : carry_bit_async_PROC
            case (p3_alu_op)
              
              // 
              //  s1 + (not s2 + 1) - i_carry
              // 
              SUBOP_ADC:
                begin
                   i_adder_cin_a = i_alu_c_flag_r;   //  s1 + s2 + i_carry
                end
              
              //  s1 + (not s2 + 1)
              // 
              SUBOP_SBC:
                begin
                   i_adder_cin_a = ~i_alu_c_flag_r;   
                end
              
              //  s1 + s2 (add, ldo, ldr, st)
              // 
              SUBOP_SUB:
                begin
                   i_adder_cin_a = 1'b 1;   
                end
              
              default:
                begin
                   if (p3_alu_absiv == 1'b 1)
                     begin
                        i_adder_cin_a = s2val_inverted_r;   
                     end
                   else
                     begin
                        i_adder_cin_a = 1'b 0;   
                     end
                end
            endcase
    end 

//------------------------------------------------------------------------------
// 32-bit Kogge-Stone Adder.
//------------------------------------------------------------------------------
// 
   adder U_adder (.A(s1val),
          .B(s2val),
          .Cin(i_adder_cin_a),
          .Sum(i_adder_result_a),
          .Zout(i_adder_zero_a),
          .Nout(i_adder_neg_a),
          .Cout(i_adder_cout_a),
          .Vout(i_adder_ovf_a));


   // The carry/borrow result. Inverted when a SUB .
   //
   assign i_adder_carry_a = i_adder_cout_a ^ s2val_inverted_r;


//---------------------------- Single Bit Operand ------------------------------
//
  // This logic is used to generate results for the BBITn,BTST,BSET,BXOR
  // instructions
  
   always @(s2val)
     begin : s2val_1bit_async_PROC
        case (s2val[4:0])
          5'b 00000 : i_s2val_one_bit_a = 32'b 00000000000000000000000000000001;   
          5'b 00001 : i_s2val_one_bit_a = 32'b 00000000000000000000000000000010;   
          5'b 00010 : i_s2val_one_bit_a = 32'b 00000000000000000000000000000100;
          5'b 00011 : i_s2val_one_bit_a = 32'b 00000000000000000000000000001000;
          5'b 00100 : i_s2val_one_bit_a = 32'b 00000000000000000000000000010000;
          5'b 00101 : i_s2val_one_bit_a = 32'b 00000000000000000000000000100000;
          5'b 00110 : i_s2val_one_bit_a = 32'b 00000000000000000000000001000000;
          5'b 00111 : i_s2val_one_bit_a = 32'b 00000000000000000000000010000000;
          5'b 01000 : i_s2val_one_bit_a = 32'b 00000000000000000000000100000000;
          5'b 01001 : i_s2val_one_bit_a = 32'b 00000000000000000000001000000000;
          5'b 01010 : i_s2val_one_bit_a = 32'b 00000000000000000000010000000000;
          5'b 01011 : i_s2val_one_bit_a = 32'b 00000000000000000000100000000000;
          5'b 01100 : i_s2val_one_bit_a = 32'b 00000000000000000001000000000000;
          5'b 01101 : i_s2val_one_bit_a = 32'b 00000000000000000010000000000000;
          5'b 01110 : i_s2val_one_bit_a = 32'b 00000000000000000100000000000000;
          5'b 01111 : i_s2val_one_bit_a = 32'b 00000000000000001000000000000000;
          5'b 10000 : i_s2val_one_bit_a = 32'b 00000000000000010000000000000000;
          5'b 10001 : i_s2val_one_bit_a = 32'b 00000000000000100000000000000000;
          5'b 10010 : i_s2val_one_bit_a = 32'b 00000000000001000000000000000000;
          5'b 10011 : i_s2val_one_bit_a = 32'b 00000000000010000000000000000000;
          5'b 10100 : i_s2val_one_bit_a = 32'b 00000000000100000000000000000000;
          5'b 10101 : i_s2val_one_bit_a = 32'b 00000000001000000000000000000000;
          5'b 10110 : i_s2val_one_bit_a = 32'b 00000000010000000000000000000000;
          5'b 10111 : i_s2val_one_bit_a = 32'b 00000000100000000000000000000000;
          5'b 11000 : i_s2val_one_bit_a = 32'b 00000001000000000000000000000000;
          5'b 11001 : i_s2val_one_bit_a = 32'b 00000010000000000000000000000000;
          5'b 11010 : i_s2val_one_bit_a = 32'b 00000100000000000000000000000000;
          5'b 11011 : i_s2val_one_bit_a = 32'b 00001000000000000000000000000000;
          5'b 11100 : i_s2val_one_bit_a = 32'b 00010000000000000000000000000000;
          5'b 11101 : i_s2val_one_bit_a = 32'b 00100000000000000000000000000000;
          5'b 11110 : i_s2val_one_bit_a = 32'b 01000000000000000000000000000000;
          default   : i_s2val_one_bit_a = 32'b 10000000000000000000000000000000;
        endcase
     end 

//-------------------------------- Mask Operand --------------------------------
// 
   always @(s2val)
     begin  :  s2val_mask_async_PROC
        case (s2val[4:0])
          5'b 00000 : i_s2val_mask_a = 32'b 00000000000000000000000000000001;
          5'b 00001 : i_s2val_mask_a = 32'b 00000000000000000000000000000011;
          5'b 00010 : i_s2val_mask_a = 32'b 00000000000000000000000000000111;
          5'b 00011 : i_s2val_mask_a = 32'b 00000000000000000000000000001111;
          5'b 00100 : i_s2val_mask_a = 32'b 00000000000000000000000000011111;
          5'b 00101 : i_s2val_mask_a = 32'b 00000000000000000000000000111111;
          5'b 00110 : i_s2val_mask_a = 32'b 00000000000000000000000001111111;
          5'b 00111 : i_s2val_mask_a = 32'b 00000000000000000000000011111111;
          5'b 01000 : i_s2val_mask_a = 32'b 00000000000000000000000111111111;
          5'b 01001 : i_s2val_mask_a = 32'b 00000000000000000000001111111111;
          5'b 01010 : i_s2val_mask_a = 32'b 00000000000000000000011111111111;
          5'b 01011 : i_s2val_mask_a = 32'b 00000000000000000000111111111111;
          5'b 01100 : i_s2val_mask_a = 32'b 00000000000000000001111111111111;
          5'b 01101 : i_s2val_mask_a = 32'b 00000000000000000011111111111111;
          5'b 01110 : i_s2val_mask_a = 32'b 00000000000000000111111111111111;
          5'b 01111 : i_s2val_mask_a = 32'b 00000000000000001111111111111111;
          5'b 10000 : i_s2val_mask_a = 32'b 00000000000000011111111111111111;
          5'b 10001 : i_s2val_mask_a = 32'b 00000000000000111111111111111111;
          5'b 10010 : i_s2val_mask_a = 32'b 00000000000001111111111111111111;
          5'b 10011 : i_s2val_mask_a = 32'b 00000000000011111111111111111111;
          5'b 10100 : i_s2val_mask_a = 32'b 00000000000111111111111111111111;
          5'b 10101 : i_s2val_mask_a = 32'b 00000000001111111111111111111111;
          5'b 10110 : i_s2val_mask_a = 32'b 00000000011111111111111111111111;
          5'b 10111 : i_s2val_mask_a = 32'b 00000000111111111111111111111111;
          5'b 11000 : i_s2val_mask_a = 32'b 00000001111111111111111111111111;
          5'b 11001 : i_s2val_mask_a = 32'b 00000011111111111111111111111111;
          5'b 11010 : i_s2val_mask_a = 32'b 00000111111111111111111111111111;
          5'b 11011 : i_s2val_mask_a = 32'b 00001111111111111111111111111111;
          5'b 11100 : i_s2val_mask_a = 32'b 00011111111111111111111111111111;
          5'b 11101 : i_s2val_mask_a = 32'b 00111111111111111111111111111111;
          5'b 11110 : i_s2val_mask_a = 32'b 01111111111111111111111111111111;
          default   : i_s2val_mask_a = 32'b 11111111111111111111111111111111;
        endcase
     end 

//----------------------------- Logic Operand Mux ------------------------------
// 
   // The following mux select between the input used to generate many logic
   // results. The results from above are used for the bit type instructions.
   // Other boolean logic instructions will use their actual operand data.
   //
   always @(i_s2val_mask_a or i_s2val_one_bit_a or p3_bit_op_sel or s2val)
     begin : s2val_p3sel_async_PROC
        case (p3_bit_op_sel)
          2'b 00  : i_s2val_logic_a = s2val;
          2'b 01  : i_s2val_logic_a = i_s2val_one_bit_a;
          default : i_s2val_logic_a = i_s2val_mask_a;
        endcase
     end 
   

//------------------------------ Logic Functions -------------------------------
// 
   // Select between the results of the various results that can be synthesised.
   //
   always @(i_s2val_logic_a or p3_alu_op or s1val)
     begin  : logic_res_async_PROC
        case (p3_alu_op)
          OP_AND  : i_logicres_a = s1val &  i_s2val_logic_a;
          OP_OR   : i_logicres_a = s1val |  i_s2val_logic_a;
          OP_XOR  : i_logicres_a = s1val ^  i_s2val_logic_a;
          default : i_logicres_a = s1val & ~i_s2val_logic_a;
        endcase
     end 

   assign i_logicres_msb_a = i_logicres_a[DATAWORD_MSB]; 

//------------------------- Single Operand Functions ---------------------------
// 
   assign i_s2val_msb_r = s2val[DATAWORD_MSB]; 

   // Select the correct data to be shifted in to form final result
   //
   always @(i_s2val_msb_r or i_alu_c_flag_r or p3_shiftin_sel_r or s2val)
     begin  :  shift_sel_async_PROC
        case (p3_shiftin_sel_r)
          2'b 01 : i_shftin_a = i_s2val_msb_r;
          2'b 10 : i_shftin_a = s2val[0];
          2'b 11 : i_shftin_a = i_alu_c_flag_r;
          default : i_shftin_a = 1'b 0;
        endcase
     end 
   
 
   // The signal operand shift and extend operations
   //
   always @(i_alu_c_flag_r or 
            i_alu_v_flag_r or 
            i_s2val_msb_r or 
            i_shftin_a or
            p3_sop_op_r or 
            s2val)
     begin : snglop_res_async_PROC

        i_sop_carry_a = i_alu_c_flag_r;   
        i_sop_ovf_a = i_alu_v_flag_r;   

        case (p3_sop_op_r)
          OP_RIGHT_SHIFT:
            begin
               i_snglopres_a = {i_shftin_a, s2val[DATAWORD_MSB:1]};   
               i_sop_carry_a = s2val[0];   
            end
          OP_LEFT_SHIFT:
            begin
               i_snglopres_a = {s2val[DATAWORD_MSB - 1:0], i_shftin_a};   
               i_sop_carry_a = i_s2val_msb_r;   
               i_sop_ovf_a = i_s2val_msb_r ^ s2val[DATAWORD_MSB - 1];   
            end
          OP_SEXB:  i_snglopres_a = {{(24){s2val[7]}}, s2val[7:0]};   
          OP_SEXW:i_snglopres_a = {{(16){s2val[15]}}, s2val[15:0]};   
          OP_EXTB:i_snglopres_a = {{(24){1'b 0}}, s2val[7:0]};   
          OP_EXTW:i_snglopres_a = {{(16){1'b 0}}, s2val[15:0]};   
          default:i_snglopres_a = ~s2val;   
        endcase
     end 

   assign i_sngleopres_msb_a = i_snglopres_a[DATAWORD_MSB]; 
 
   // Min/Max instruction result generation
   //  
   assign i_src_msbs_a = {s1val[DATAWORD_MSB], s2val[DATAWORD_MSB]}; 

   always @(i_adder_cout_a or i_adder_zero_a or i_src_msbs_a)
     begin : min_max_async_PROC
        case (i_src_msbs_a)
          2'b 01,
          2'b 10:
            begin
               i_s2_lt_s1_a = i_adder_cout_a & ~i_adder_zero_a;   
               i_s2_gt_s1_a = ~i_adder_cout_a;   
            end
          2'b 11:
            begin
               i_s2_lt_s1_a = 1'b 0;   
               i_s2_gt_s1_a = i_adder_cout_a;   
            end
          default:
            begin
               i_s2_lt_s1_a = ~i_adder_cout_a;   
               i_s2_gt_s1_a = 1'b 0;   
            end
        endcase
     end
   
//--------------------------- Resolve Flag Results -----------------------------
// 
   // Zero flag generation for logic type results.
   //   
   assign i_logic_zero_a = (i_logicres_a == 32'h 00000000) ? 1'b 1 :  1'b 0; 

   // Zero flag gneration of single operand instrucion.
   //                           
   assign i_sop_zero_a = (i_snglopres_a == 32'h 00000000) ? 1'b 1 :  1'b 0;


   // Individual flags for BRcc instructions.
   //
   // Zero flag
   //
   assign i_br_zero_a = (
                         // Adder used for BRcc
                         (i_adder_zero_a & p3_alu_arithiv)
                         |
                         // Logic used for BBITn
                         (i_logic_zero_a & p3_alu_logiciv));
 

   // Negative flag
   //
   assign i_br_negative_a = i_adder_neg_a; 

   // Carry flag
   //
   assign i_br_carry_a = i_adder_cout_a; 

   // Overflow flag
   //
   assign i_br_overflow_a = i_adder_ovf_a; 

   // Separate flags bus for BRcc instructions due to critical path
   // implications from this logic.
   // 
   assign i_br_flags_a = {i_br_zero_a, 
              i_br_negative_a, 
              i_br_carry_a,
              i_br_overflow_a}; 

   // The flag results for both the 16/32-bit instructions are selected.
   // based upon upon whether they are arithmetic, logical or barrel
   // shifts.
   // 
   assign i_p3_min_max_decode_a = (p3_min_instr | p3_max_instr); 

   assign i_flag_sel_a = {p3_alu_logiciv, (p3_alu_arithiv |
                                           i_p3_min_max_decode_a)}; 

   assign i_arith_c_flag_sel_a = {i_p3_min_max_decode_a,
                                  p3_alu_absiv};

   always @(i_adder_neg_a or i_adder_ovf_a or i_adder_carry_a or
            i_adder_zero_a or i_alu_c_flag_r or i_alu_v_flag_r or 
            i_arith_c_flag_sel_a or i_flag_sel_a or i_logic_zero_a or 
            i_logicres_msb_a or i_sngleopres_msb_a or i_sop_carry_a or 
            i_sop_ovf_a or i_sop_zero_a or
            s2val_inverted_r or i_min_max_c_flag_a)
     begin : dt_flags_async_PROC

        case (i_flag_sel_a)

          2'b 10:
            begin

               //  zero flag
               i_o_zero_a = i_logic_zero_a;   

               //  negative flag
               i_o_negative_a = i_logicres_msb_a;   

               //  carry flag : unchanged.
               i_o_carry_a = i_alu_c_flag_r;   

               //  overflow flag
               i_o_overflow_a = i_alu_v_flag_r;   
            end
          2'b 01:
            begin
               //  zero flag
               i_o_zero_a = i_adder_zero_a;   

               //  negative flag
               i_o_negative_a = i_adder_neg_a;   

               //  carry flag
               //
               case (i_arith_c_flag_sel_a)
                 2'b 10:
                   begin
                      i_o_carry_a = i_min_max_c_flag_a;   
                   end
                 2'b 01:
                   begin
                      i_o_carry_a = s2val_inverted_r;   
                   end
                 default:
                   begin
                      i_o_carry_a = i_adder_carry_a;   
                   end
               endcase 
               
               //  overflow flag
               i_o_overflow_a = i_adder_ovf_a;
            end

          default:
            begin
               //  zero flag
               i_o_zero_a = i_sop_zero_a;   

               //  negative flag
               i_o_negative_a = i_sngleopres_msb_a;   

               //  carry flag
               i_o_carry_a = i_sop_carry_a;   

               //  overflow flag
               i_o_overflow_a = i_sop_ovf_a;   
            end
        endcase
     end
   
   // Prelatched flags for all cases other than BRcc instructions. 
   // 
   assign alurflags = {i_o_zero_a, i_o_negative_a,
                       i_o_carry_a, i_o_overflow_a}; 

//----------------------------- Multiplex results ------------------------------
// 
   // Construction of the status register for int or blcc or aux_pchit, 
   // Note H isn't used. RCTL puts currentpc or nextpc on lower part of
   // s1val.
   // 
   assign i_statreg_a = {aluflags_r[A_Z_N], aluflags_r[A_N_N],
                         aluflags_r[A_C_N], aluflags_r[A_V_N], 
                         e2flag_r, e1flag_r, 1'b 0, 1'b 0, 
                         s1val[PC_MSB_A4:PC_LSB_A4]}; 

   //  Select status register.
   // 
   assign i_do_statreg_a = (aux_pchit & p3lr & ~i_use_ext_a); 

   // Select PC32 register.
   // 
   assign i_do_pc32_a = ((p3int | p3dolink | aux_pc32hit & p3lr) & 
                          ~i_use_ext_a); 

   // Use external result when on the extension writeback signal is true else
   // the ALU results are multiplexed instead. Note that XT_ALUOP and
   // xy_multic_op is a constant in extutil to disable this part of the
   // multiplexer if there are no external instructions.
   //
   assign i_use_ext_a = ((x_snglec_wben & XT_ALUOP)
                         | 
                         (x_multic_wben & XT_MULTIC_OP)); 

   // Arithmetic result - this is to be selected when an arithmetic instruction
   // is being executed, but not when p3lr is set, or if i_use_ext_a is true.
   // 
   assign i_use_arith_a = (p3_alu_arithiv & ~(i_use_ext_a |
                          p3_max_instr |
                          p3_min_instr)); 
   
   assign i_use_logic_a = (p3_alu_logiciv & ~i_use_ext_a); 
   
   assign i_use_sop_a = (p3_alu_snglopiv & ~i_use_ext_a); 
   
   assign i_use_aux_a = (p3lr & ~(i_do_statreg_a | 
                                 i_do_pc32_a | 
                                 i_use_ext_a)); 

   
   // This signal selects source 1 operand for a Min/Max operation when it is
   // smaller/greater than source 2 respectively.
   //
   assign i_use_s1val_a = (i_do_pc32_a                  |
                          (p3_max_instr                & 
                           i_s2_lt_s1_a                | 
                           p3_min_instr                & 
                           i_s2_gt_s1_a)               &
                           (~i_use_ext_a)); 

   // This signal selects source 2 operand for a Min/Max operation when it is
   // smaller/greater than source 1 respectively.
   // 
   assign i_min_max_c_flag_a = ((p3_max_instr  &
                                 (i_s2_gt_s1_a |
                                  i_adder_zero_a)) | 
                                (p3_min_instr &
                                 (i_s2_lt_s1_a |
                                  i_adder_zero_a)) );

   assign i_use_s2val_a      = (i_min_max_c_flag_a & ~i_use_ext_a);

//---------------------------- Lower Level Version -----------------------------
// 
   // This section builds an AND-OR multiplexer, for the ALU result since all of
   // the below conditions are mutually exclusive. 
   // 
   assign i_res_a = (aux_datar & {(DATAWORD_WIDTH){i_use_aux_a}} | 
                      
                     i_adder_result_a & {(DATAWORD_WIDTH){i_use_arith_a}} | 
                      
                     i_logicres_a & {(DATAWORD_WIDTH){i_use_logic_a}} | 
                     
                     i_snglopres_a & {(DATAWORD_WIDTH){i_use_sop_a}} | 
                     
                     s1val & {(DATAWORD_WIDTH){i_use_s1val_a}} | 
                     
                     ~s2val & {(DATAWORD_WIDTH){i_use_s2val_a}} | 
                     
                     i_statreg_a & {(DATAWORD_WIDTH){i_do_statreg_a}} | 
                     
                     xresult & {(DATAWORD_WIDTH){i_use_ext_a}}); 

//-------------------------------- LD/ST Adder ---------------------------------
// 
   // The result of the adder for use by the memory controller, The results of
   // adds for load/store operations still go to p3result for address
   // writeback.
   // 
   assign mc_addr = (p3awb_field_r == LDST_PRE_WB) ?  s1val : 
           i_adder_result_a;

   assign i_p3result_nld_a = (h_dataw & {(DATAWORD_WIDTH){cr_hostw}} |
                              
                              i_res_a & {(DATAWORD_WIDTH){~cr_hostw}}); 

   // Latch the stage 3 result to stage 4 for writeback. 
   // 
   assign i_wbdata_nxt = (drd & {(DATAWORD_WIDTH){(ldvalid_wb)}} | 
                          
                          h_dataw & {(DATAWORD_WIDTH){(cr_hostw & ~ldvalid_wb)}}             |
                          
                          i_res_a & {(DATAWORD_WIDTH){~(ldvalid_wb          |
                                                        cr_hostw)}});
   
   always @(posedge rst_a or posedge clk)
     begin : p4data_sync_PROC
        if (rst_a == 1'b 1)
          begin
             i_wbdata_r <= {(DATAWORD_WIDTH){1'b 0}};   
          end
        else
          begin
             if (p3wb_en == 1'b 1)
               begin
                  i_wbdata_r <= i_wbdata_nxt;   
               end
          end
     end

//----------------------------------- Output -----------------------------------
// 
   assign br_flags_a = i_br_flags_a; 
   assign p3result = i_wbdata_nxt; 
   assign p3result_nld = i_p3result_nld_a; 
   assign p3res_sc = i_res_a; 
   assign wbdata = i_wbdata_r; 

endmodule // module bigalu
