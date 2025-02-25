//`ifndef ARCUTIL_V
//`define ARCUTIL_V
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
// This file contains the global defines which specify field
// widths, bit positions, instruction encoding and global
// functions for the basecase ARC600.
//
//
// Field encoding on instructions:
// 
//   31      27          21         15         9                  0
//   ====I====+====A======+====B=====+====C=====+=======D==========
//    ,        ,           ,          ,          ,                , 
//    , i[4:0] | dest[5:0] | s1a[5:0] | s2a[5:0] |   shimm[8:0]   , 
//    ,        ,           ,          ,          ,                , 
//   ==============================================================
//                                              ,                 , 
//                                              , R R F C C C C C |
//                                              ,                 , 
//                                              ===================
// 
//  R = reserved, F = flag setting, C = condition code field
// 

// Definitions for the 32-bit Instruction Set Architecture
// =======================================================
//
parameter INSTR_UBND = 31; 
parameter INSTR_LBND = 27;
parameter MINOR_BR_UBND = 3;
parameter MINOR_BR_LBND = 0;
parameter MINOR_OP_UBND = 21;
parameter MINOR_OP_LBND = 16;
parameter AOP_UBND = 5;
parameter AOP_LBND = 0;
parameter BOP_LSB_UBND = 26;
parameter BOP_LSB_LBND = 24;
parameter BOP_MSB_UBND = 14;
parameter BOP_MSB_LBND = 12;
parameter COP_UBND = 11;
parameter COP_LBND = 6;
parameter TARG_MSB_UBND = 15;
parameter TARG_MSB_LBND = 6;
parameter TARG_LSB_UBND = 26;
parameter TARG_LSB_LBND = 17;
parameter SET_BLCC = 17;
parameter SET_FLG_POS = 15;
parameter SINGLE_OP_UBND = 21;
parameter SHIMM32_S8_MSB_POS = 15;
parameter SHIMM32_S8_LSB_UBND = 23;
parameter SHIMM32_S8_LSB_LBND = 16;
parameter SHIMM32_U6_UBND = 11;
parameter SHIMM32_U6_LBND = 6;
parameter LD_AWB_UBND = 10;
parameter LD_AWB_LBND = 9;
parameter CC_REG_FLAG = 5;
parameter DELAY_SLOT = 5;
parameter SHIMM32_S12_MSB_UBND = 5;
parameter SHIMM32_S12_MSB_LBND = 0;
parameter SHIMM32_S12_LSB_UBND = 11;
parameter SHIMM32_S12_LSB_LBND = 6;
parameter ST_AWB_UBND = 4;
parameter ST_AWB_LBND = 3;
parameter BR_FMT = 16;
parameter QQ_UBND = 4;
parameter QQ_LBND = 0;

// Definitions for the 16-bit Instruction Set Architecture
// =======================================================
//
parameter AOP_UBND16 = 18;
parameter AOP_LBND16 = 16;
parameter COP_UBND16 = 23;
parameter COP_LBND16 = 21;
parameter MINOR16_BR1_UBND = 26;
parameter MINOR16_BR1_LBND = 25;
parameter MINOR16_BR2_UBND = 24;
parameter MINOR16_BR2_LBND = 22;
parameter MINOR16_BR3_POS = 23;
parameter MINOR16_OP1_UBND = 20;
parameter MINOR16_OP1_LBND = 19;
parameter MINOR16_OP2_UBND = 20;
parameter MINOR16_OP2_LBND = 16;
parameter MINOR16_OP3_UBND = 23;
parameter MINOR16_OP3_LBND = 21;
parameter MINOR16_OP4_UBND = 26;
parameter MINOR16_OP4_LBND = 25;
parameter SHIMM16_S13_UBND = 26;
parameter SHIMM16_S13_LBND = 16;
parameter SHIMM16_U10_UBND = 23;
parameter SHIMM16_U10_LBND = 16;
parameter SHIMM16_S10_UBND = 24;
parameter SHIMM16_S10_LBND = 16;
parameter SHIMM16_S9_UBND = 24;
parameter SHIMM16_S9_LBND = 16;
parameter SHIMM16_S8_UBND = 22;
parameter SHIMM16_S8_LBND = 16;
parameter SHIMM16_S7_UBND = 21;
parameter SHIMM16_S7_LBND = 16;
parameter SHIMM16_U7_UBND = 22;
parameter SHIMM16_U7_LBND = 16;
parameter SHIMM16_U5_UBND = 20;
parameter SHIMM16_U5_LBND = 16;
parameter SHIMM16_U3_UBND = 18;
parameter SHIMM16_U3_LBND = 16;
parameter QQ16_UBND = 26;
parameter QQ16_LBND = 22;

// Width of Program counter
//
parameter PC_SIZE = 24;
parameter PC_MSB = PC_SIZE - 1;
parameter PC_LSB = 1;

// Width of loop count register
//
parameter LOOPCNT_SIZE = 8;
parameter LOOPCNT_MSB = LOOPCNT_SIZE - 1;
parameter LOOPCNT_LSB = 1;

// Data width upperbound
//
parameter DATAWORD_WIDTH = 32;
parameter DATAWORD_MSB = DATAWORD_WIDTH - 1;
parameter DATAWORD_MSB_1 = DATAWORD_MSB - 1;
parameter DATAWORD_MSB_2 = DATAWORD_MSB_1 - 1;
parameter DATAWORD_MSB_3 = DATAWORD_MSB_2 - 1;
parameter DATAWORD_MSB_4 = DATAWORD_MSB_3 - 1;
parameter WORD_WIDTH = 16;
parameter WORD_MSB = WORD_WIDTH-1;
parameter NEXTPC_LSB = 1;
parameter NEXTPC_LSB_1 = NEXTPC_LSB + 1;
parameter DW = DATAWORD_WIDTH - 1;

// Major opcode width
parameter OPCODE_WIDTH = 5;
parameter OPCODE_MSB = OPCODE_WIDTH - 1;
parameter OPCODE_MSB_1 = OPCODE_MSB - 1;

// Minor opcode width
parameter SUBOPCODE_WIDTH = 6;
parameter SUBOPCODE_MSB = SUBOPCODE_WIDTH - 1;
parameter SUBOPCODE_MSB_1 = SUBOPCODE_MSB - 1;
parameter SUBOPCODE_MSB_2 = SUBOPCODE_MSB_1 - 1;
parameter SUBOPCODE_LSB = 0;
parameter SUBOPCODE_LSB_1 = SUBOPCODE_LSB + 1;

// Operand width
parameter OPERAND_WIDTH = 6;
parameter OPERAND_MSB = OPERAND_WIDTH - 1;
parameter CORE_REG_MSB = 4;

// LD/ST Addressing writeback modes width
parameter LDST_AWB_WIDTH = 2;
parameter LDST_AWB_MSB = LDST_AWB_WIDTH - 1;

// Operand width 16-bit
parameter OPERAND16_WIDTH = 3;
parameter OPERAND16_MSB = OPERAND16_WIDTH - 1;

// Condition code width
parameter CONDITION_CODE_WIDTH = 5;
parameter CONDITION_CODE_MSB = CONDITION_CODE_WIDTH - 1;
parameter STD_COND_CODE_MSB = CONDITION_CODE_MSB - 1;
parameter STD_COND_CODE_MSB_1 = STD_COND_CODE_MSB - 1;

// Format width
parameter FORMAT_WIDTH = 2;
parameter FORMAT_MSB = FORMAT_WIDTH - 1;

// Flag width
parameter ALUFLAG_WIDTH = 4;
parameter ALUFLAG_MSB = ALUFLAG_WIDTH - 1;

// Short immediate width
parameter SHIMM_WIDTH = 13;
parameter SHIMM_MSB = SHIMM_WIDTH - 1;
parameter SHIMM_MSB_1 = SHIMM_MSB - 1;

// Short immediate width for branches
parameter TARGET_WIDTH = 24;
parameter TARGET_MSB = TARGET_WIDTH - 1;

// Sub-opcode width for major opcodes 0x0C, 0x0D, 0x0E
parameter SUBOPCODE1_16_WIDTH = 2;
parameter SUBOPCODE1_16_MSB = SUBOPCODE1_16_WIDTH - 1;

// Sub-opcode width for major opcodes 0x0F
parameter SUBOPCODE2_16_WIDTH = 5;
parameter SUBOPCODE2_16_MSB = SUBOPCODE2_16_WIDTH - 1;

// Sub-opcode width for major opcodes 0x17, 0x18, 0x1E
parameter SUBOPCODE3_16_WIDTH = 3;
parameter SUBOPCODE3_16_MSB = SUBOPCODE3_16_WIDTH - 1;

// Sub-opcode location for major opcodes 0x19, 0x1C, 0x1D
parameter SUBOPCODE_BIT = 23;
parameter SUBOPCODE4_16_WIDTH = 1;

parameter SOPWIDTH    = 3;
parameter SOPSIZE     = SOPWIDTH - 1;
parameter BARRELWIDTH = 2;
parameter BARRELSIZE  = BARRELWIDTH - 1;
parameter CCSIZ       = 3;    // int. cond bits - 1
parameter QQSIZ       = 4;    // condition code bits - 1
parameter TARGSZ      = 22;   // offset bits - 1
parameter SETFLGPOS   = 15;   // position of set flag bit
parameter AFLAGSZ     = 3;    // alu flag bits

parameter TARG_BR_MSB_POS  = 15;   // target adr for Brcc
parameter TARG_BR_LSB_UBND = 23;   // target adr for Bcc
parameter TARG_BR_LSB_LBND = 17;   // targubnd - tarsz
parameter TARG_BL_MSB_UBND = 3;    // target adr for BLcc
parameter TARG_BL_MSB_LBND = 0;    // targubnd - tarsz
parameter TARG_BL_MID_UBND = 15;   // target adr for BLcc
parameter TARG_BL_MID_LBND = 6;    // targubnd - tarsz
parameter TARG_BL_LSB_UBND = 26;   // target adr for BLcc
parameter TARG_BL_LSB_LBND = 18;   // targubnd - tarsz
parameter TARG_B_LSB_POS   = 17;   // targubnd - tarsz
parameter DEL_SLOT_MODE    = 5;    // delay slot ctrl
parameter QQUBND           = 4;    // cond code field
parameter QQLBND           = 0;    //
parameter CCXBPOS          = 4;    // extension bit
parameter CCUBND           = 3;    // internal cc field
parameter CCLBND           = 0;    // 

// Major Opcode encoding information for Tangent A5 processor.
//
 // branch
 parameter OP_BCC  = 5'b 00000;

 // branch&link
 parameter OP_BLCC = 5'b 00001;

 // load r+ofs
 parameter OP_LD   = 5'b 00010;

 // store r+ofs
 parameter OP_ST   = 5'b 00011;

 // format 1
 parameter OP_FMT1 = 5'b 00100;

 // format 2
 parameter OP_FMT2 = 5'b 00101;

 // format 3
 parameter OP_FMT3 = 5'b 00110;

 // format 4
 parameter OP_FMT4 = 5'b 00111;

 // 16-bit reserved slot
 parameter OP_16_FMT1    = 5'b 01000;

 // 16-bit reserved slot
 parameter OP_16_FMT2    = 5'b 01001;

 // 16-bit reserved slot
 parameter OP_16_FMT3    = 5'b 01010;

 // 16-bit reserved slot
 parameter OP_16_FMT4    = 5'b 01011;

 // 16-bit loads/adds
 parameter OP_16_LD_ADD  = 5'b 01100;

 // 16-bit arithmetic ops
 parameter OP_16_ARITH   = 5'b 01101;

 // 16-bit moves/adds
 parameter OP_16_MV_ADD  = 5'b 01110;

 // 16-bit general ops
 parameter OP_16_ALU_GEN = 5'b 01111;

 // 16-bit loads
 parameter OP_16_LD_U7   = 5'b 10000;

 // 16-bit loads
 parameter OP_16_LDB_U5  = 5'b 10001;

 // 16-bit loads
 parameter OP_16_LDW_U6  = 5'b 10010;

 // 16-bit loads
 parameter OP_16_LDWX_U6 = 5'b 10011;

 // 16-bit stores
 parameter OP_16_ST_U7   = 5'b 10100;

 // 16-bit stores
 parameter OP_16_STB_U5  = 5'b 10101;

 // 16-bit stores
 parameter OP_16_STW_U6  = 5'b 10110;

 // 16-bit shift/subtract
 parameter OP_16_SSUB    = 5'b 10111;

 // 16-bit SP related ops
 parameter OP_16_SP_REL  = 5'b 11000;

 // 16-bit GP related ops
 parameter OP_16_GP_REL  = 5'b 11001;

 // 16-bit PC based loads
 parameter OP_16_LD_PC   = 5'b 11010;

 // 16-bit mov
 parameter OP_16_MV      = 5'b 11011;

 // 16-bit add/compare
 parameter OP_16_ADDCMP  = 5'b 11100;

 // 16-bit compare/branch
 parameter OP_16_BRCC    = 5'b 11101;

 // 16-bit branch
 parameter OP_16_BCC     = 5'b 11110;

 // 16-bit branch/link
 parameter OP_16_BL      = 5'b 11111;

 // branch
 parameter OP_BCC_N  = 0;

 // branch&link
 parameter OP_BLCC_N = 1;

 // load r+ofs
 parameter OP_LD_N   = 2;

 // store r+ofs
 parameter OP_ST_N   = 3;

 // format 1
 parameter OP_FMT1_N = 4;

 // format 2
 parameter OP_FMT2_N = 5;

 // format 3
 parameter OP_FMT3_N = 6;

 // format 4
 parameter OP_FMT4_N = 7;

 // 16-bit reserved slot
 parameter OP_16_FMT1_N    = 8;

 // 16-bit reserved slot
 parameter OP_16_FMT2_N    = 9;

 // 16-bit reserved slot
 parameter OP_16_FMT3_N    = 10;

 // 16-bit reserved slot
 parameter OP_16_FMT4_N    = 11;

 // 16-bit loads/adds
 parameter OP_16_LD_ADD_N  = 12;

 // 16-bit arithmetic ops
 parameter OP_16_ARITH_N   = 13;

 // 16-bit moves/adds
 parameter OP_16_MV_ADD_N  = 14;

 // 16-bit general ops
 parameter OP_16_ALU_GEN_N = 15;

 // 16-bit loads
 parameter OP_16_LD_U7_N   = 16;

 // 16-bit loads
 parameter OP_16_LDB_U5_N  = 17;

 // 16-bit loads
 parameter OP_16_LDW_U6_N  = 18;

 // 16-bit loads
 parameter OP_16_LDWX_U6_N = 19;

 // 16-bit stores
 parameter OP_16_ST_U7_N   = 20;

 // 16-bit stores
 parameter OP_16_STB_U5_N  = 21;

 // 16-bit stores
 parameter OP_16_STW_U6_N  = 22;

 // 16-bit shift/subtract
 parameter OP_16_SSUB_N    = 23;

 // 16-bit SP related ops
 parameter OP_16_SP_REL_N  = 24;

 // 16-bit GP related ops
 parameter OP_16_GP_REL_N  = 25;

 // 16-bit PC based loads
 parameter OP_16_LD_PC_N   = 26;

 // 16-bit mov
 parameter OP_16_MV_N      = 27;

 // 16-bit add/compare
 parameter OP_16_ADDCMP_N  = 28;

 // 16-bit compare/branch
 parameter OP_16_BRCC_N    = 29;

 // 16-bit branch
 parameter OP_16_BCC_N     = 30;

 // 16-bit branch/link
 parameter OP_16_BL_N      = 31;

// Sub-opcode encodings for 32-bit basecase instructions.
// These are encoded using the I-field which is between bits [21:16].
//
 parameter SO_ADD      = 6'b 000000;
 parameter SO_ADC      = 6'b 000001;
 parameter SO_SUB      = 6'b 000010;
 parameter SO_SBC      = 6'b 000011;
 parameter SO_AND      = 6'b 000100;
 parameter SO_OR       = 6'b 000101;
 parameter SO_BIC      = 6'b 000110;
 parameter SO_XOR      = 6'b 000111;

// The SO_MAX instruction returns the maximum value of the two operands to the
// destination register. The zero and negative flag setting options are available
// to this instruction.
//
 parameter SO_MAX      = 6'b 001000;

// The SO_MIN instruction returns the minimum value of the two operands to the
// destination register. The zero and negative flag setting options are available
// to this instruction.
//
 parameter SO_MIN      = 6'b 001001; // min

 parameter SO_MOV      = 6'b 001010; // mov
 parameter SO_TST      = 6'b 001011; // tst
 parameter SO_CMP      = 6'b 001100; // cmp
 parameter SO_RCMP     = 6'b 001101; // rcmp
 parameter SO_RSUB     = 6'b 001110; // rsub
 parameter SO_BSET     = 6'b 001111; // bset
 parameter SO_BCLR     = 6'b 010000; // bclr
 parameter SO_BTST     = 6'b 010001; // btst
 parameter SO_BXOR     = 6'b 010010; // bxor
 parameter SO_BMSK     = 6'b 010011; // bmsk
 parameter SO_ADD1     = 6'b 010100; // add1
 parameter SO_ADD2     = 6'b 010101; // add2
 parameter SO_ADD3     = 6'b 010110; // add3
 parameter SO_SUB1     = 6'b 010111; // sub1
 parameter SO_SUB2     = 6'b 011000; // sub2
 parameter SO_SUB3     = 6'b 011001; // sub3

 parameter SO_J        = 6'b 100000; // jmp
 parameter SO_J_D      = 6'b 100001; // jmp.d
 parameter SO_JL       = 6'b 100010; // jl
 parameter SO_JL_D     = 6'b 100011; // jl.d
 parameter SO_LP       = 6'b 101000; // loop
 parameter SO_FLAG     = 6'b 101001; // flag
 parameter SO_LR       = 6'b 101010; // lr
 parameter SO_SR       = 6'b 101011; // sr
 parameter SO_SOP      = 6'b 101111; // SOPs
 parameter SO_LD       = 6'b 110000; // ld
 parameter SO_LD_X     = 6'b 110001; // ld.x
 parameter SO_LDB      = 6'b 110010; // ldb
 parameter SO_LDB_X    = 6'b 110011; // ldb.x
 parameter SO_LDW      = 6'b 110100; // ldw
 parameter SO_LDW_X    = 6'b 110101; // ldw.x

 parameter SO_BCC_BREQ = 6'b 100000; // 
 parameter SO_BCC_BRNE = 6'b 100001; // 
 parameter SO_BCC_BRLT = 6'b 100010; // 
 parameter SO_BCC_BRGE = 6'b 100011; // 
 parameter SO_BCC_BRLO = 6'b 100100; // 
 parameter SO_BCC_BRHS = 6'b 100101; // 
 parameter SO_BCC_BBIT0 = 6'b 101110; // 
 parameter SO_BCC_BBIT1 = 6'b 101111; // 

 parameter MO_ASL      = 6'b 000000; // asl
 parameter MO_ASR      = 6'b 000001; // asr
 parameter MO_LSR      = 6'b 000010; // lsr
 parameter MO_ROR      = 6'b 000011; // ror
 parameter MO_RRC      = 6'b 000100; // rrc
 parameter MO_SEXB     = 6'b 000101; // sexb
 parameter MO_SEXW     = 6'b 000110; // sexw
 parameter MO_EXTB     = 6'b 000111; // extb
 parameter MO_EXTW     = 6'b 001000; // extw
 parameter MO_ABS      = 6'b 001001; // abs
 parameter MO_NOT      = 6'b 001010; // not
 parameter MO_RLC      = 6'b 001011; // rlc

 parameter MO_ZOP      = 6'b 111111; // ZOPs

 // The sleep (sleep) instruction has the same single operand code. In order
 // to make it easier to read the sleep  instruction has its own constant even
 // though the single opcode is the same.
 //
 parameter ZO_SLEEP    = 6'b 000001; // sleep

 // The software interrupt (SWI) instruction has the same single operand code
 // as the SLEEP instruction.
 //
 parameter ZO_SWI      = 6'b 000010; // swi
 
 parameter ZO_SYNC     = 6'b 000011; // sync

 parameter SO_ADD_N      = 0;  // add
 parameter SO_ADC_N      = 1;  // adc
 parameter SO_SUB_N      = 2;  // sub
 parameter SO_SBC_N      = 3;  // sbc
 parameter SO_AND_N      = 4;  // and
 parameter SO_OR_N       = 5;  // or
 parameter SO_BIC_N      = 6;  // bic
 parameter SO_XOR_N      = 7;  // xor
 parameter SO_MAX_N      = 8;  // max
 parameter SO_MIN_N      = 9;  // min
 parameter SO_MOV_N      = 10; // mov
 parameter SO_TST_N      = 11; // tst
 parameter SO_CMP_N      = 12; // cmp
 parameter SO_RCMP_N     = 13; // rcmp
 parameter SO_RSUB_N     = 14; // rsub
 parameter SO_BSET_N     = 15; // bset
 parameter SO_BCLR_N     = 16; // bclr
 parameter SO_BTST_N     = 17; // btst
 parameter SO_BXOR_N     = 18; // bxor
 parameter SO_BMSK_N     = 19; // bmsk
 parameter SO_ADD1_N     = 20; // add1
 parameter SO_ADD2_N     = 21; // add2
 parameter SO_ADD3_N     = 22; // add3
 parameter SO_SUB1_N     = 23; // sub1
 parameter SO_SUB2_N     = 24; // sub2
 parameter SO_SUB3_N     = 25; // sub3

 parameter SO_J_N        = 32; // jmp
 parameter SO_J_D_N      = 33; // jmp.d
 parameter SO_JL_N       = 34; // jl
 parameter SO_JL_D_N     = 35; // jl.d
 parameter SO_LP_N       = 40; // loop
 parameter SO_FLAG_N     = 41; // flag
 parameter SO_LR_N       = 42; // lr
 parameter SO_SR_N       = 43; // sr
 parameter SO_SOP_N      = 47; // SOPs
 parameter SO_LD_N       = 48; // ld
 parameter SO_LD_X_N     = 49; // ld.x
 parameter SO_LDB_N      = 50; // ldb
 parameter SO_LDB_X_N    = 51; // ldb.x
 parameter SO_LDW_N      = 52; // ldw
 parameter SO_LDW_X_N    = 53; // ldw.x

 parameter MO_ASL_N      = 0;  // asl
 parameter MO_ASR_N      = 1;  // asr
 parameter MO_LSR_N      = 2;  // lsr
 parameter MO_ROR_N      = 3;  // ror
 parameter MO_RRC_N      = 4;  // rrc
 parameter MO_SEXB_N     = 5;  // sexb
 parameter MO_SEXW_N     = 6;  // sexw
 parameter MO_EXTB_N     = 7;  // extb
 parameter MO_EXTW_N     = 8;  // extw
 parameter MO_ABS_N      = 9;  // abs
 parameter MO_NOT_N      = 10; // not
 parameter MO_RLC_N      = 11; // rlc

 parameter MO_ZOP_N      = 63; // ZOPs
 parameter ZO_SLEEP_N    = 1;  // sleep
 parameter ZO_SWI_N      = 2;  // swi

// Sub-opcode encodings for 32-bit extension instructions.
//
 parameter SO_ASL        = 6'b 000000; // asl
 parameter SO_LSR        = 6'b 000001; // lsr
 parameter SO_ASR        = 6'b 000010; // asr
 parameter SO_ROR        = 6'b 000011; // ror
 parameter MO_MUL64      = 6'b 000100; // mul
 parameter MO_MULU64     = 6'b 000101; // mulu
 parameter MO_ADDS       = 6'b 000110; 
 parameter MO_SUBS       = 6'b 000111; 
 parameter MO_DIVAW      = 6'b 001000; 
 
 parameter MO_ASLS       = 6'b 001010; 
 parameter MO_ASRS       = 6'b 001011; 
 parameter MO_MULDW      = 6'b 001100; 
 parameter MO_MULUDW     = 6'b 001101; 
 parameter MO_MULRDW     = 6'b 001110; 
  
 parameter MO_MACDW      = 6'b 010000; 
 parameter MO_MACUDW     = 6'b 010001; 
 parameter MO_MACRDW     = 6'b 010010; 
 
 parameter MO_MSUBDW     = 6'b 010100; 
 parameter MO_MULT       = 6'b 011000; 
 parameter MO_MULUT      = 6'b 011001; 
 parameter MO_MULRT      = 6'b 011010; 
 parameter MO_MACT       = 6'b 011100; 
 parameter MO_MACUT      = 6'b 011101; 
 parameter MO_MACRT      = 6'b 011110; 
 parameter MO_MSUBT      = 6'b 100000; 
 parameter MO_CMACRDW    = 6'b 100110; 
 parameter MO_ADDSDW     = 6'b 101000; 
 parameter MO_SUBSDW     = 6'b 101001; 
 parameter MO_CRC        = 6'b 101100; 

 parameter SO_MPYW      = 6'b011110;
 parameter SO_MPYUW     = 6'b011111;

 parameter SO_SWAP      = 6'b000000; 
 parameter SO_NORM      = 6'b000001; 
 parameter SO_SAT16     = 6'b000010; 
 parameter SO_RND16     = 6'b000011; 
 parameter SO_ABSSW     = 6'b000100; 
 parameter SO_ABSS      = 6'b000101; 
 parameter SO_NEGSW     = 6'b000110; 
 parameter SO_NEGS      = 6'b000111; 
 parameter SO_NORMW     = 6'b001000; 
 //Reserved
 parameter SO_VBFDW     = 6'b001010; 
 parameter SO_FBFDW     = 6'b001011; 
 parameter SO_FBFT      = 6'b001100; 
 parameter SO_ABSSDW    = 6'b001101; 
 parameter SO_NEGSDW    = 6'b001110; 

// Barrel shifter extension
//
 parameter MULTIBIT_ASL  = 2'b 00; // asl
 parameter MULTIBIT_LSR  = 2'b 01; // lsr
 parameter MULTIBIT_ASR  = 2'b 10; // asr
 parameter MULTIBIT_ROR  = 2'b 11; // ror

// Formats for 32-bit instructions
//
// The formats for 32-bit instructions is defined by a 2-bit vector as
// follows.
//
// [1] Register + register
// [2] Register + unsigned 6-bit immediate
// [3] Register + signed 12-bit immediate
// [4] Conditional register
// [5] Conditional register + unsigned 6-bit immediate
//
 parameter FMT_REG       = 2'b 00; // 
 parameter FMT_U6        = 2'b 01; // 
 parameter FMT_S12       = 2'b 10; // 
 parameter FMT_COND_REG  = 2'b 11; // 
 parameter FMT_COND_U6   = 2'b 11; // 

// The formats for 32-bit branch instructions is defined by a 2-bit
// vector as follows.
//
 parameter FMT_BL        = 2'b 00; // 
 parameter FMT_BLCC      = 2'b 10; // 

// Sub-opcode encodings for 16-bit instructions.
//
 // For Major Opcode 0x0C the subopcodes are defined as follows:
 //
 // load reg + reg
 parameter SO16_LD      = 2'b 00; // 

 // load byte
 parameter SO16_LDB     = 2'b 01; // 

 // load word
 parameter SO16_LDW     = 2'b 10; // 

 // add reg + reg
 parameter SO16_ADD     = 2'b 11; // 

 // For Major Opcode 0x0D the subopcodes are defined as follows:
 //
 // add reg + u3
 parameter SO16_ADD_U3  = 2'b 00; // 

 // sub reg - u3
 parameter SO16_SUB_U3  = 2'b 01; // 

 // asl
 parameter SO16_ASL     = 2'b 10; // 

 // asr
 parameter SO16_ASR     = 2'b 11; // 

 // For Major Opcode 0x0E the subopcodes are defined as follows:
 //
 // add reg + hi-reg
 parameter SO16_ADD_HI  = 2'b 00; // 

 // mov from hi-reg
 parameter SO16_MOV_HI1 = 2'b 01; // 

 // compare
 parameter SO16_CMP     = 2'b 10; // 

 // mov to hi-reg
 parameter SO16_MOV_HI2 = 2'b 11; // 

 // For Major Opcode 0x0F the subopcodes are defined as follows:
 //
 // single operand subopcode slot
 parameter SO16_SOP     = 5'b 00000; // 

 // sub reg - reg
 parameter SO16_SUB_REG = 5'b 00010; // 

 // and reg with reg
 parameter SO16_AND     = 5'b 00100; // 

 // or reg with reg
 parameter SO16_OR      = 5'b 00101; // 

 // bic reg with reg
 parameter SO16_BIC     = 5'b 00110; // 

 // xor reg with reg
 parameter SO16_XOR     = 5'b 00111; // 

 // test reg with reg
 parameter SO16_TST     = 5'b 01011; // 

 // mul64 reg with reg
 parameter SO16_MUL64   = 5'b 01100; // 

 // sign extend byte
 parameter SO16_SEXB    = 5'b 01101; // 

 // sign extend word
 parameter SO16_SEXW    = 5'b 01110; // 

 // zero extend byte
 parameter SO16_EXTB    = 5'b 01111; // 

 // zero extend word
 parameter SO16_EXTW    = 5'b 10000; // 

 // absolute value
 parameter SO16_ABS     = 5'b 10001; // 

 // invert value
 parameter SO16_NOT     = 5'b 10010; // 

 // negate value
 parameter SO16_NEG     = 5'b 10011; // 

 // add with reg + (reg << 1)
 parameter SO16_ADD1    = 5'b 10100; // 

 // add with reg + (reg << 2)
 parameter SO16_ADD2    = 5'b 10101; // 

 // add with reg + (reg << 3)
 parameter SO16_ADD3    = 5'b 10110; // 

 // multiple arithmetic shifts left
 parameter SO16_ASL_M   = 5'b 11000; // 

 // multiple logical shifts right
 parameter SO16_LSR_M   = 5'b 11001; // 

 // single arithmetic shifts right
 parameter SO16_ASR_M   = 5'b 11010; // 

 // single arithmetic shifts left
 parameter SO16_ASL_1   = 5'b 11011; // 

 // single arithmetic shifts right
 parameter SO16_ASR_1   = 5'b 11100; // 

 // single arithmetic shifts left
 parameter SO16_LSR_1   = 5'b 11101; // 

 // unused slot
 parameter SO16_UNUSED  = 5'b 11110; // 

 // The breakpoint (brk) instruction is used for debugging purposes and it  
 // stops the ARC from incrementing the PC at the point it has been inserted  
 // although earlier instructions are executed and the pipeline is  
 // automatically flushed.
 //
 parameter SO16_BRK     = 5'b 11111; // 


 // Single operand instructions (Major Opcode 0x0F, Subopcode 0x1F)
 //
 // jump to PC
 parameter SO16_SOP_J   = 3'b 000; // 

 // jump to PC
 parameter SO16_SOP_JD  = 3'b 001; // 

 // jump to PC
 parameter SO16_SOP_JL  = 3'b 010; // 

 // jump to PC
 parameter SO16_SOP_JLD = 3'b 011; // 

 // jump to PC
 parameter SO16_SOP_SUB = 3'b 110; // 

 // jump to PC
 parameter SO16_SOP_ZOP = 3'b 111; // 

 // Zero operand instructions (Major Opcode 0x0F, Subopcode 0x1F,
 // Sub-subopcode 0x07)
 //
 // no operation
 parameter SO16_ZOP_NOP = 3'b 000; // 

 // jump using blink register
 parameter SO16_ZOP_JEQ = 3'b 100; // 

 // jump using blink register
 parameter SO16_ZOP_JNE = 3'b 101; // 

 // jump using blink register
 parameter SO16_ZOP_J   = 3'b 110; // 

 // jump using blink register
 parameter SO16_ZOP_JD  = 3'b 111; // 


 // For Major Opcode 0x17 the subopcodes are defined as follows:
 //
 // multiple arithmetic shifts left
 parameter SO16_ASL_U5  = 3'b 000; // 

 // multiple logical shifts right
 parameter SO16_LSR_U5  = 3'b 001; // 

 // multiple arithmetic shifts right
 parameter SO16_ASR_U5  = 3'b 010; // 

 // subtract reg - u5
 parameter SO16_SUB_U5  = 3'b 011; // 

 // bit set
 parameter SO16_BSET_U5 = 3'b 100; // 

 // bit clear
 parameter SO16_BCLR_U5 = 3'b 101; // 

 // bit mask
 parameter SO16_BMSK_U5 = 3'b 110; // 

 // bit test
 parameter SO16_BTST_U5 = 3'b 111; // 

 // For Major Opcode 0x18 the subopcodes are defined as follows:
 //
 // load from address SP + u7
 parameter SO16_LD_SP   = 3'b 000; // 

 // load byte from address SP + u7
 parameter SO16_LDB_SP  = 3'b 001; // 

 // store to address SP + u7
 parameter SO16_ST_SP   = 3'b 010; // 

 // store byte to address SP + u7
 parameter SO16_STB_SP  = 3'b 011; // 

 // add SP + u7
 parameter SO16_ADD_SP  = 3'b 100; // 

 // add SP +/- u7
 parameter SO16_SUB_SP  = 3'b 101; // 

 // pop register from stack
 parameter SO16_POP_U7  = 3'b 110; // 

 // push register to stack
 parameter SO16_PUSH_U7 = 3'b 111; // 

 // For Major Opcode 0x19 the subopcodes are defined as follows:
 //
 // load from address GP + s9
 parameter SO16_LD_GP   = 2'b 00; // 

 // load byte from address GP + s9
 parameter SO16_LDB_GP  = 2'b 01; // 

 // load word from address GP + s9
 parameter SO16_LDW_GP  = 2'b 10; // 

 // add GP + s9
 parameter SO16_ADD_GP  = 2'b 11; // 

 // For Major Opcode 0x1C the subopcodes are defined as follows:
 //
 // add reg + u7
 parameter SO16_ADD_U7  = 1'b 0; // 

 // compare reg with u7
 parameter SO16_CMP_U7  = 1'b 1; // 

 // For Major Opcode 0x1D the subopcodes are defined as follows:
 //
 // branch if reg = 0
 parameter SO16_BREQ_S8  = 1'b 0; // 

 // branch if reg /= 0
 parameter SO16_BRNE_S8  = 1'b 1; // 


 // For Major Opcode 0x1E the subopcodes are defined as follows:
 //
 // branch always
 parameter SO16_B_S9     = 2'b 00; // 

 // branch if equal
 parameter SO16_BEQ_S9   = 2'b 01; // 

 // branch if not equal
 parameter SO16_BNE_S9   = 2'b 10; // 

 // branch conditonally
 parameter SO16_BCC_S9   = 2'b 11; // 


 // Branch table (Major Opcode 0x1E, Subopcode 0x3)
 //
 // branch greater than
 parameter SO16_BGT      = 3'b 000; // 

 // branch greater than or equal to
 parameter SO16_BGE      = 3'b 001; // 

 // branch less than
 parameter SO16_BLT      = 3'b 010; // 

 // branch less than or equal to
 parameter SO16_BLE      = 3'b 011; // 

 // branch higher than
 parameter SO16_BHI      = 3'b 100; // 

 // branch higher than or same
 parameter SO16_BHS      = 3'b 101; // 

 // branch lower than
 parameter SO16_BLO      = 3'b 110; // 

 // branch lower than or same
 parameter SO16_BLS      = 3'b 111; // 

// Mode Bits for SP relative instructions
 parameter SP_MODE_1     = 16; // PUSH/POP
 parameter SP_MODE_2     = 20; // Blink or B-field


//  Positions in the FLAG instruction operand field, of the status register
//  bits to be set by the FLAG instruction, as integers:

parameter F_Z_N  = 11; //   Z  zero flag
parameter F_N_N  = 10; //   N  sign flag
parameter F_C_N  = 9;  //   C  carry flag
parameter F_V_N  = 8;  //   V  overflow flag
parameter F_E2_N = 2;  //   E2 level 2 interrupt enable
parameter F_E1_N = 1;  //   E1 level 1 interrupt enable
parameter F_H_N  = 0;  //   H  run flag

//  Positions in the status register of the status bits, as integers:

parameter SR_Z_N  = 31;  //   Z  zero flag
parameter SR_N_N  = 30;  //   N  sign flag
parameter SR_C_N  = 29;  //   C  carry flag
parameter SR_V_N  = 28;  //   V  overflow flag
parameter SR_E2_N = 27;  //   E2 level 2 interrupt enable
parameter SR_E1_N = 26;  //   E1 level 1 interrupt enable
parameter SR_H_N  = 25;  //   H  run flag

//  Positions in the aluflags[] bus of the ALU status bits, as integers

parameter A_Z_N = 3; //   Z  zero flag
parameter A_N_N = 2; //   N  sign flag
parameter A_C_N = 1; //   C  carry flag
parameter A_V_N = 0; //   V  overflow flag

// Employed by the stage 3 Arithmetic unit -
//
// flag instruction - does not use arithmetic results -
//
 parameter OP_ADD        = 3'b 100; // add
 parameter OP_ADC        = 3'b 101; // adc
 parameter OP_SUB        = 3'b 110; // sub
 parameter OP_SBC        = 3'b 111; // sbc

 parameter SUBOP_ADD     = 2'b 00; // add
 parameter SUBOP_ADC     = 2'b 01; // adc
 parameter SUBOP_SUB     = 2'b 10; // sub
 parameter SUBOP_SBC     = 2'b 11; // sbc

 parameter OP_AND        = 2'b 00; // add
 parameter OP_OR         = 2'b 01; // adc
 parameter OP_BIC        = 2'b 10; // sub
 parameter OP_XOR        = 2'b 11; // sbc


//  Extra encoding information which is used in load and store instructions
//  it appears in different places in the instruction word depending upon
//  which instruction is being used:
// 
//  LDR - bottom 6 bits of the short immediate field
//  LDO - C field
//  LR  - C field
//  ST  - A field
//  SR  - A field
// 
//  ==5=4=3=2=1=0== R - Reserved
//,          ,      U - Auxiliary register operation    (LR & SR)
//, R U A Z Z X |   A - Address writeback               (LDR, LDO, ST)
//,          ,      Z - Two size bits  00 - longword    (LDR, LDO, ST)
//  ===============                    10 - word
//                                     01 - byte
//                  X - Sign extend                     (LDR, LDO)
// 
 // Don't cache loads & stores
 parameter DC_BYPASS     = 5; //

 // Auxiliary register access
 parameter LDST_ADDR_WB_UBND = 4; //

 // Address writeback bit
 parameter LDST_ADDR_WB_LBND = 3; //

 // Upper bound of size
 parameter LDST_SIZE_UBND = 2; //

 // Lower bound of size
 parameter LDST_SIZE_LBND = 1; //

 // Sign extend bit
 parameter LDST_SIGN_EXT  = 0; //

 // LDR boundary constants for extra encoding info

 parameter LDR_DC_BYPASS     = 15; //
 parameter LDR_ADDR_WB_UBND  = 23; //
 parameter LDR_ADDR_WB_LBND  = 22; //
 parameter LDR_SIZE_UBND     = 18; //
 parameter LDR_SIZE_LBND     = 17; //
 parameter LDR_SIGN_EXT      = 16; //

//  Sizes of loads and stores --

 parameter LDST_LWORD     = 2'b 00; 
 parameter LDST_WORD      = 2'b 10; 
 parameter LDST_BYTE      = 2'b 01;

//  Sizes of loads and stores as integers --

 parameter LS_LWORD_N     = 0; 
 parameter LS_WORD_N      = 2; 
 parameter LS_BYTE_N      = 1; 

// LD/ST writeback modes

 parameter LDST_NO_WB     = 2'b 00; 
 parameter LDST_POST_WB   = 2'b 01; 
 parameter LDST_PRE_WB    = 2'b 10; 
 parameter LDST_SC_NO_WB  = 2'b 11; 

// Branch on Compare Formats (BRcc)

 parameter BR_FMT_REG     = 1'b 0; 
 parameter BR_FMT_U6      = 1'b 1; 

//  Position of the extra encoding information for the different instructions
//  within the 32-bit instruction word at stage 2.

parameter MEMOP_ESZ = 5;         //  width of memory op extra encoding

parameter LDO_EUBND = COP_LBND + MEMOP_ESZ;   //  LDR : C field
parameter LDO_ELBND = COP_LBND;   // 
parameter ST_EUBND = AOP_LBND + MEMOP_ESZ;    //  ST  : A field
parameter ST_ELBND = AOP_LBND;    // 


// Barrel Shifter Encodings

 parameter OP_ASL        = 2'b 00; //
 parameter OP_LSR        = 2'b 01; //
 parameter OP_ASR        = 2'b 10; //
 parameter OP_ROR        = 2'b 11; //


// Single Operand Encodings

 parameter OP_RIGHT_SHIFT = 3'b 000; //
 parameter OP_LEFT_SHIFT  = 3'b 001; //
 parameter OP_SEXB        = 3'b 010; //
 parameter OP_SEXW        = 3'b 011; //
 parameter OP_EXTB        = 3'b 100; //
 parameter OP_EXTW        = 3'b 101; //
 parameter OP_NOT         = 3'b 110; //


//  Condition code fields:
// 
//  The ARC has a five-bit condition code field, four condition code field
//  bits and an extra bit which is used to switch to an alternative
//  condition calculation unit, provided as an extension. This will allow
//  program code to branch on conditions provided by extension logic.
//  The condition codes given below are four-bits each. The extra bit which
//  handles extension condition codes will be handled separately.

parameter CCAL  = 4'b 0000; //  always
parameter CCZ   = 4'b 0001; //  zero
parameter CCNZ  = 4'b 0010; //  non zero
parameter CCPL  = 4'b 0011; //  positive
parameter CCMI  = 4'b 0100; //  negative
parameter CCCS  = 4'b 0101; //  carry set
parameter CCCC  = 4'b 0110; //  carry clr
parameter CCVS  = 4'b 0111; //  ovflo set
parameter CCVC  = 4'b 1000; //  ovflo clr
parameter CCGT  = 4'b 1001; //  signed >
parameter CCGE  = 4'b 1010; //  signed >=
parameter CCLT  = 4'b 1011; //  signed <
parameter CCLE  = 4'b 1100; //  signed <=
parameter CCHI  = 4'b 1101; //  unsigned >
parameter CCLS  = 4'b 1110; //  unsigned <
parameter CCPNZ = 4'b 1111; //  pos non zero

parameter BR_CCEQ  = 4'b 0000; //  equal
parameter BR_CCNE  = 4'b 0001; //  not equal
parameter BR_CCLT  = 4'b 0010; //  less than
parameter BR_CCGE  = 4'b 0011; //  greater than or equal to
parameter BR_CCLO  = 4'b 0100; //  lower than
parameter BR_CCHS  = 4'b 0101; //  higher than
parameter BBIT0    = 4'b 1110; //  bit test zero
parameter BBIT1    = 4'b 1111; //  bit test one

parameter CCAL_16   = 2'b 00;  //  always
parameter CCZ_16    = 2'b 01;  //  zero
parameter CCNZ_16   = 2'b 10;  //  non zero
parameter CC_BCC_16 = 2'b 11;  //  conditional
parameter CCGT_16   = 3'b 000; //  signed >
parameter CCGE_16   = 3'b 001; //  signed >=
parameter CCLT_16   = 3'b 010; //  signed <
parameter CCLE_16   = 3'b 011; //  signed <=
parameter CCHI_16   = 3'b 100; //  unsigned >
parameter CCHS_16   = 3'b 101; //  unsigned
parameter CCLO_16   = 3'b 110; //  unsigned
parameter CCLS_16   = 3'b 111; //  unsigned <

//  condition codes defined as integers

parameter CCAL_N  = 0;  //  always
parameter CCZ_N   = 1;  //  zero
parameter CCNZ_N  = 2;  //  non zero
parameter CCPL_N  = 3;  //  positive
parameter CCMI_N  = 4;  //  negative
parameter CCCS_N  = 5;  //  carry set
parameter CCCC_N  = 6;  //  carry clr
parameter CCVS_N  = 7;  //  ovflo set
parameter CCVC_N  = 8;  //  ovflo clr
parameter CCGT_N  = 9;  //  signed >
parameter CCGE_N  = 10; //  signed >=
parameter CCLT_N  = 11; //  signed <
parameter CCLE_N  = 12; //  signed <=
parameter CCHI_N  = 13; //  unsigned >
parameter CCLS_N  = 14; //  unsigned <
parameter CCPNZ_N = 15; //  pos non zero

parameter CCAL_16_N   = 0;  //  always
parameter CCZ_16_N    = 1;  //  zero
parameter CCNZ_16_N   = 2;  //  non zero
parameter CC_BCC_16_N = 3;  //  conditional
parameter CCGT_16_N   = 0; //  signed >
parameter CCGE_16_N   = 1; //  signed >=
parameter CCLT_16_N   = 2; //  signed <
parameter CCLE_16_N   = 3; //  signed <=
parameter CCHI_16_N   = 4; //  unsigned >
parameter CCHS_16_N   = 5; //  unsigned
parameter CCLO_16_N   = 6; //  unsigned
parameter CCLS_16_N   = 7; //  unsigned <

//  delay slot execution modes as bit vectors

parameter DMND = 1'b 0; //  kill next when jumping
parameter DMD  = 1'b 1; //  execute next

//  delay slot execution modes as integers

parameter DMND_N = 0; //  kill next when jumping
parameter DMD_N  = 1; //  execute next

//  General purpose registers defined as vectors

parameter r0  = 6'b 000000; 
parameter r1  = 6'b 000001; 
parameter r2  = 6'b 000010; 
parameter r3  = 6'b 000011; 
parameter r4  = 6'b 000100; 
parameter r5  = 6'b 000101; 
parameter r6  = 6'b 000110; 
parameter r7  = 6'b 000111; 
parameter r8  = 6'b 001000; 
parameter r9  = 6'b 001001; 
parameter r10 = 6'b 001010; 
parameter r11 = 6'b 001011; 
parameter r12 = 6'b 001100; 
parameter r13 = 6'b 001101; 
parameter r14 = 6'b 001110; 
parameter r15 = 6'b 001111; 
parameter r16 = 6'b 010000; 
parameter r17 = 6'b 010001; 
parameter r18 = 6'b 010010; 
parameter r19 = 6'b 010011; 
parameter r20 = 6'b 010100; 
parameter r21 = 6'b 010101; 
parameter r22 = 6'b 010110; 
parameter r23 = 6'b 010111; 
parameter r24 = 6'b 011000; 
parameter r25 = 6'b 011001; 
parameter r26 = 6'b 011010; 
parameter r27 = 6'b 011011; 
parameter r28 = 6'b 011100; 
//  ilink1
parameter r29 = 6'b 011101; 
//  ilink2
parameter r30 = 6'b 011110; 
//  blink
parameter r31 = 6'b 011111;  

// Further register constants defined as vectors
//
parameter r32       = 6'b 100000;
parameter r33       = 6'b 100001;
parameter r34       = 6'b 100010;
parameter r35       = 6'b 100011;
parameter r36       = 6'b 100100;
parameter r37       = 6'b 100101;
parameter r38       = 6'b 100110;
parameter r39       = 6'b 100111;
parameter r40       = 6'b 101000;
parameter r41       = 6'b 101001;
parameter r42       = 6'b 101010;
parameter r43       = 6'b 101011;
parameter r44       = 6'b 101100;
parameter r45       = 6'b 101101;
parameter r46       = 6'b 101110;
parameter r47       = 6'b 101111;
parameter r48       = 6'b 110000;
parameter r49       = 6'b 110001;
parameter r50       = 6'b 110010;
parameter r51       = 6'b 110011;
parameter r52       = 6'b 110100;
parameter r53       = 6'b 110101;
parameter r54       = 6'b 110110;
parameter r55       = 6'b 110111;
parameter r56       = 6'b 111000;
parameter r57       = 6'b 111001;
parameter r58       = 6'b 111010;
parameter r59       = 6'b 111011;
parameter r60       = 6'b 111100;
parameter r61       = 6'b 111101;
parameter r62       = 6'b 111110;
parameter r63       = 6'b 111111;

// The special purpose core registers

parameter RGLOBALPTR   = 6'b 011010;  
parameter RSTACKPTR    = 6'b 011100;  
parameter RILINK1      = 6'b 011101;  
parameter RILINK2      = 6'b 011110;  
parameter RBLINK       = 6'b 011111;  
parameter RLCNT        = 6'b 111100;  
parameter RLIMM        = 6'b 111110;  
parameter RCURRENTPC   = 6'b 111111;  

//  The special purpose core registers defined as integers

parameter RGLOBALPTR_N = 26; //  global pointer   / r26
parameter RSTACKPTR_N  = 28; //  stack pointer    / r28
parameter RILINK1_N    = 29; //  interrupt link 1 / r29
parameter RILINK2_N    = 30; //  interrupt link 2 / r30
parameter RBLINK_N     = 31; //  branch link      / r31

parameter RLCNT_N      = 60; //  loop count
parameter RLIMM_N      = 62; //  long immediate
parameter RCURRENTPC_N = 63; //  PC


//  The auxiliary registers defined as integers

parameter AX_PC_N          = 0;  //  pc/status register
parameter AX_SEM_N         = 1;  //  semaphore register
parameter AX_LSTART_N      = 2;  //  loop start register
parameter AX_LEND_N        = 3;  //  loop end register
parameter AX_ID_N          = 4;  //  identity register
parameter AX_DEBUG_N       = 5;  //  debug register
parameter AX_PC32_N        = 6;  //  32-bit pc register
parameter AX_STATUS32_N    = 10; //  32-bit status register
parameter AX_STATUS32_L1_N = 11; //  32-bit l1 status reg
parameter AX_STATUS32_L2_N = 12; //  32-bit l2 status reg

//  Debug register bit fields

parameter DB_STEP_N      = 0;  // single step bit position.
parameter DB_HALT_N      = 1;  // force halt bit position.
parameter DB_AHALT_N     = 2;  // actionhalt bit position.
parameter DB_INST_STEP_N = 11; // single instruction step bit position.
parameter DB_SLEEP_N     = 23; // sleep flag
parameter DB_DEBUG_N     = 24; // enable debug flag
parameter DB_AMC_LO_N    = 25; // actionpoint memory client
                               // lower bit position.
parameter DB_EXT_HALT    = 26; // external halt 
parameter DB_DOMAIN_HALT_RESERVED = 27; // Reserved for certain ARC700 systems. 
			       // In extending an ARC600, do not use.
parameter DB_AMC_HI_N    = 28; // actionpoint memory client
                               // higher bit position.
parameter DB_BHALT_N     = 29; // breakhalt bit position.
parameter DB_SHALT_N     = 30; // self-halt bit position
parameter DB_LP_N        = 31; // lpending position

// Status32 register bit fields

parameter STATUS32_EN_N   = 0;  // halt status bit position.
parameter STATUS32_E1_N   = 1;  // interrupt e1 bit position.
parameter STATUS32_E2_N   = 2;  // interrupt e2 bit position.
parameter STATUS32_V_N    = 8;  // overflow flag position.
parameter STATUS32_C_N    = 9;  // carry flag position.
parameter STATUS32_N_N    = 10; // sign flag position.
parameter STATUS32_Z_N    = 11; // zero flag position.

parameter AX_ST32_E1_N    = 0; // interrupt e1 bit position.
parameter AX_ST32_E2_N    = 1; // interrupt e2 bit position.
parameter AX_ST32_V_N     = 2; // overflow flag position.
parameter AX_ST32_C_N     = 3; // carry flag position.
parameter AX_ST32_N_N     = 4; // sign flag position.
parameter AX_ST32_Z_N     = 5; // zero flag position.



//  bit fields as vectors --

parameter DB_STEP = 32'h 00000001; 

//  The number of semaphore bits in the semaphore register -1

parameter SEMSZ = 3; //  four bits in the semaphore register

// Width of adder in bigalu

parameter ADDER_WIDTH = 34;
parameter ADDER_MSB   = ADDER_WIDTH - 1;
parameter ADDER_LSB   = 1;

// Register File Set-up
// ====================
// Constant to enable usage of the 4-port register file option - this
// allows a fast path for returning loads via an extra port on the
// register file.
//
parameter RCTL_4P_REG_FILE = 1'b0; 

// Constant to enable usage of 16-entry register file
//
parameter RF_32_ENTRY = 1'b 0;


//  Various CONSTANTs + types
// ==========================

parameter NEXTPC_PLUS_4  = 32'b 0000000000000000000000000000010;
parameter NEXTPC_PLUS_8  = 32'b 0000000000000000000000000000100; 
parameter MINUS_4        = 13'b 1111111111100;
parameter PLUS_4         = 13'b 0000000000100;

// boundaries for LD/ST accesses -

parameter BYTE_LSB       = 0;
parameter WORD_LSB       = 1;
parameter LONGWORD_LSB   = 2;
parameter OLD_PC_MSB     = 23;
parameter PC_MSB_A4      = 25;
parameter PC_LSB_A4      = 2;

parameter ONE_ONE         = 1'b 1;
parameter THIRTY_TWO_ONES = 32'b 11111111111111111111111111111111;

// Zeroing constants

parameter ONE_ZERO         = 1'b 0;
parameter TWO_ZERO         = 2'b 0;
parameter THREE_ZERO       = 3'b 0;
parameter FOUR_ZERO        = 4'b 0;
parameter FIVE_ZERO        = 5'b 0;
parameter SIX_ZERO         = 6'b 0;
parameter SEVEN_ZERO       = 7'b 0;
parameter EIGHT_ZERO       = 8'b 0;
parameter NINE_ZERO        = 9'b 0;
parameter TEN_ZERO         = 10'b 0;
parameter ELEVEN_ZERO      = 11'b 0;
parameter TWELVE_ZERO      = 12'b 0;
parameter THIRTEEN_ZERO    = 13'b 0;
parameter FOURTEEN_ZERO    = 14'b 0;
parameter FIFTEEN_ZERO     = 15'b 0;
parameter SIXTEEN_ZERO     = 16'b 0;
parameter SEVENTEEN_ZERO   = 17'b 0;
parameter EIGHTEEN_ZERO    = 18'b 0;
parameter NINETEEN_ZERO    = 19'b 0;
parameter TWENTY_ZERO      = 20'b 0;
parameter TWENTYONE_ZERO   = 21'b 0;
parameter TWENTYTWO_ZERO   = 22'b 0;
parameter TWENTYTHREE_ZERO = 23'b 0;
parameter TWENTYFOUR_ZERO  = 24'b 0;
parameter TWENTYFIVE_ZERO  = 25'b 0;
parameter TWENTYSIX_ZERO   = 26'b 0;
parameter TWENTYSEVEN_ZERO = 27'b 0;
parameter TWENTYEIGHT_ZERO = 28'b 0;
parameter TWENTYNINE_ZERO  = 29'b 0;
parameter THIRTY_ZERO      = 30'b 0;
parameter THIRTYONE_ZERO   = 31'b 0;
parameter THIRTY_TWO_ZERO  = 32'b 0;

// Load data return paths. These constants are used in the LSU.

parameter LD_QUEUE  = 2'b 00;
parameter LD_CACHE  = 2'b 01;
parameter LD_RAM    = 2'b 10;
parameter LD_PERIPH = 2'b 11;
 
parameter BURST_LONGW = 8'b 00000011;

// Address decode of the two least significant bits of the address

parameter BYTE0 = 2'b 00;
parameter BYTE1 = 2'b 01;
parameter BYTE2 = 2'b 10;
parameter BYTE3 = 2'b 11;

//additional parameters
parameter TWO          = 2;
parameter THREE        = 3;
parameter FOUR         = 4;
parameter FIVE         = 5;
parameter SIX          = 6;
parameter EIGHT        = 8;
parameter TWELVE       = 12;
parameter THIRTEEN     = 13;
parameter FIFTEEN      = 15;
parameter SIXTEEN      = 16;
parameter SEVENTEEN    = 17;
parameter EIGHTEEN     = 18;
parameter NINETEEN     = 19;
parameter TWENTY_FOUR  = 24;
parameter TWENTY_EIGHT = 28;
parameter THIRTY_ONE   = 31;
parameter THIRTY_TWO   = 32;
parameter FOURTY       = 40;
parameter SIXTY_FOUR   = 64;
parameter SIXTY_FIVE   = 65;

//29'b parameters
parameter THENTYNINE_ZERO        = 29'b 00000000000000000000000000000; 
parameter TWENTYNINE_ONE         = 29'b 00000000000000000000000000001;
parameter TWENTYNINE_TWO         = 29'b 00000000000000000000000000010;
parameter TWENTYNINE_THREE       = 29'b 00000000000000000000000000100;
parameter TWENTYNINE_FOUR        = 29'b 00000000000000000000000001000;
parameter TWENTYNINE_FIVE        = 29'b 00000000000000000000000010000; 
parameter TWENTYNINE_SIX         = 29'b 00000000000000000000000100000; 
parameter TWENTYNINE_SEVEN       = 29'b 00000000000000000000001000000; 
parameter TWENTYNINE_EIGHT       = 29'b 00000000000000000000010000000; 
parameter TWENTYNINE_NINE        = 29'b 00000000000000000000100000000;
parameter TWENTYNINE_TEN         = 29'b 00000000000000000001000000000;
parameter TWENTYNINE_ELEVEN      = 29'b 00000000000000000010000000000;
parameter TWENTYNINE_TWELVE      = 29'b 00000000000000000100000000000;
parameter TWENTYNINE_THIRTEEN    = 29'b 00000000000000001000000000000;
parameter TWENTYNINE_FOURTEEN    = 29'b 00000000000000010000000000000;
parameter TWENTYNINE_FIFTEEN     = 29'b 00000000000000100000000000000;
parameter TWENTYNINE_SIXTEEN     = 29'b 00000000000001000000000000000;
parameter TWENTYNINE_SEVENTEEN   = 29'b 00000000000010000000000000000;
parameter TWENTYNINE_EIGHTEEN    = 29'b 00000000000100000000000000000; 
parameter TWENTYNINE_NINETEEN    = 29'b 00000000001000000000000000000; 
parameter TWENTYNINE_TWENTY      = 29'b 00000000010000000000000000000;
parameter TWENTYNINE_TWENTYONE   = 29'b 00000000100000000000000000000; 
parameter TWENTYNINE_TWENTYTWO   = 29'b 00000001000000000000000000000;
parameter TWENTYNINE_TWENTYTHREE = 29'b 00000010000000000000000000000;
parameter TWENTYNINE_TWENTYFOUR  = 29'b 00000100000000000000000000000;
parameter TWENTYNINE_TWENTYFIVE  = 29'b 00001000000000000000000000000;
parameter TWENTYNINE_TWENTYSIX   = 29'b 00010000000000000000000000000;
parameter TWENTYNINE_TWENTYSEVEN = 29'b 00100000000000000000000000000;
parameter TWENTYNINE_TWENTYEIGHT = 29'b 01000000000000000000000000000;
parameter TWENTYNINE_TWENTYNINE  = 29'b 10000000000000000000000000000; 


//
// mask settings

parameter BYTE0_MASK = 4'b 0001;
parameter BYTE1_MASK = 4'b 0010;
parameter BYTE2_MASK = 4'b 0100;
parameter BYTE3_MASK = 4'b 1000;
parameter WORD0_MASK = 4'b 0011;
parameter WORD1_MASK = 4'b 1100;
parameter LONG_MASK  = 4'b 1111;

    // Determines whether the core register for a source operand can be
    // shortcut to the ALU stage.
    //
    function f_shcut;

        input [OPERAND_MSB:0] reg_no;

        begin
           case (reg_no) 
              6'h00,
              6'h01,
              6'h02,
              6'h03 :   f_shcut = 1'b1;

              6'h04,
              6'h05,
              6'h06,
              6'h07,
              6'h08,
              6'h09 :   f_shcut = RF_32_ENTRY;

              6'h0a,
              6'h0b,
              6'h0c,
              6'h0d,
              6'h0e,
              6'h0f :   f_shcut = 1'b1;

              6'h10,
              6'h11,
              6'h12,
              6'h13,
              6'h14,
              6'h15,
              6'h16,
              6'h17,
              6'h18,
              6'h19 :   f_shcut = RF_32_ENTRY;
                
              6'h1a,
              6'h1b,
              6'h1c,
              6'h1d,
              6'h1e,
              6'h1f :   f_shcut = 1'b1;

              RLCNT, RLIMM, RCURRENTPC:
                        f_shcut = 1'b0;

              default : f_shcut = 1'b1; 

           endcase
        end
    endfunction

    // Function that takes a register number and is set to true when it
    // determines that it exists in the general purpose register set.
    //
    function rf_reg;

        input    [OPERAND_MSB:0] reg_no;

        begin
           case (reg_no) 
              6'h00,
              6'h01,
              6'h02,
              6'h03 :   rf_reg = 1'b1;

              6'h04,
              6'h05,
              6'h06,
              6'h07,
              6'h08,
              6'h09 :   rf_reg = RF_32_ENTRY;

              6'h0a,
              6'h0b,
              6'h0c,
              6'h0d,
              6'h0e,
              6'h0f :   rf_reg = 1'b1;

              6'h10,
              6'h11,
              6'h12,
              6'h13,
              6'h14,
              6'h15,
              6'h16,
              6'h17,
              6'h18,
              6'h19 :   rf_reg = RF_32_ENTRY;
                
              6'h1a,
              6'h1b,
              6'h1c,
              6'h1d,
              6'h1e,
              6'h1f :   rf_reg = 1'b1;

              default : rf_reg = 1'b0; // no write
           endcase
        end
    endfunction

    // Function that takes a register number and transposes the number if
    // a 16-entry register file is in use. Unused registers are moved to 
    // the upper range
    //
    function  [OPERAND_MSB:0] rf_addr;
        input [OPERAND_MSB:0] reg_no;
        begin
 
                  // 16-entry version
                  //
                  case (reg_no) 

              6'h00 : rf_addr = 6'h00;
              6'h01 : rf_addr = 6'h01;
              6'h02 : rf_addr = 6'h08;
              6'h03 : rf_addr = 6'h09;

              6'h04 : rf_addr = 6'h14;
              6'h05 : rf_addr = 6'h15;
              6'h06 : rf_addr = 6'h15;
              6'h07 : rf_addr = 6'h17;
              6'h08 : rf_addr = 6'h18;
              6'h09 : rf_addr = 6'h19;

              6'h0a : rf_addr = 6'h0a;
              6'h0b : rf_addr = 6'h0b;
              6'h0c : rf_addr = 6'h0c;
              6'h0d : rf_addr = 6'h0d;
              6'h0e : rf_addr = 6'h0e;
              6'h0f : rf_addr = 6'h0f;

              6'h10 : rf_addr = 6'h10;
              6'h11 : rf_addr = 6'h11;
              6'h12 : rf_addr = 6'h12;
              6'h13 : rf_addr = 6'h13;
              6'h14 : rf_addr = 6'h14;
              6'h15 : rf_addr = 6'h15;
              6'h16 : rf_addr = 6'h16;
              6'h17 : rf_addr = 6'h17;
              6'h18 : rf_addr = 6'h18;
              6'h19 : rf_addr = 6'h19;
                
              6'h1a : rf_addr = 6'h02; 
              6'h1b : rf_addr = 6'h03; 
              6'h1c : rf_addr = 6'h04; 
              6'h1d : rf_addr = 6'h05; 
              6'h1e : rf_addr = 6'h06; 
              6'h1f : rf_addr = 6'h07; 

           endcase

        end
    endfunction

// This function returns a '1' if the instruction in question uses the
// register requested by the destination field.
// This applies to all internal instructions except branches, jump,
// and the store instruction when there is no writeback.
//
function  f_desten;

input   [OPCODE_MSB:0]        main_op;
input   [SUBOPCODE_MSB:0]     sub_op;
input   [SUBOPCODE_MSB_1:0]   sub_op2;
input   [SUBOPCODE3_16_MSB:0] sub_op3;
input   [LDST_AWB_MSB:0]      awb;
input   [SUBOPCODE_MSB:0]     a_field;
input   [OPERAND16_MSB:0]     c_field;

reg     result;

begin
   begin

   case (main_op) 

   OP_BLCC:
   begin
      result = 1'b 0;        
   end

   OP_LD:
   begin
      result = 1'b 1;
   end

   OP_ST:
   begin
      if ((awb == LDST_POST_WB) | (awb == LDST_PRE_WB))
      begin
         result = 1'b 1;
      end
      else
      begin
         result = 1'b 0;
      end
   end

   OP_FMT1:
   begin
      case (sub_op)

         SO_ADD, SO_ADC, SO_SUB, SO_SBC,
         SO_AND, SO_OR , SO_BIC, SO_XOR,
         SO_MAX, SO_MIN, SO_LD, SO_LR,
         SO_LDB, SO_LDB_X, SO_LDW, SO_LDW_X,
                 SO_BSET, SO_BCLR, SO_BMSK, SO_ADD1, 
                 SO_ADD2, SO_ADD3, SO_SUB1, SO_SUB2, 
                 SO_SUB3, SO_BXOR, SO_MOV, SO_RSUB:
         begin
            result = 1'b 1;
         end

         SO_SOP:
         begin
            if (a_field == MO_ZOP)
            begin
               result = 1'b 0;
            end

            else
            begin
               result = 1'b 1;
            end
         end

         default:
         begin
            result = 1'b 0;        
         end
      endcase
   end

   OP_16_LD_ADD, OP_16_ARITH, OP_16_LD_U7,
   OP_16_LDB_U5, OP_16_LDW_U6, OP_16_LDWX_U6,
   OP_16_SSUB, OP_16_GP_REL, OP_16_LD_PC,
   OP_16_MV, OP_16_BL:
   begin
      result = 1'b 1;
   end

   OP_16_MV_ADD:
   begin
      if ((sub_op2[SUBOPCODE_MSB_1 :
                   SUBOPCODE_MSB_2] == SO16_ADD_HI)  | 
          (sub_op2[SUBOPCODE_MSB_1 :
                   SUBOPCODE_MSB_2] == SO16_MOV_HI1) | 
          (sub_op2[SUBOPCODE_MSB_1 :
                   SUBOPCODE_MSB_2] == SO16_MOV_HI2))
      begin
         result = 1'b 1;
      end

      else
      begin
         result = 1'b 0;
      end
   end

   OP_16_ALU_GEN:
   begin
      case (sub_op2)

         SO16_SUB_REG, SO16_AND, SO16_OR, SO16_BIC,
         SO16_XOR, SO16_SEXB, SO16_SEXW, SO16_EXTB,
         SO16_EXTW, SO16_ABS, SO16_NOT, SO16_NEG,
         SO16_ADD1, SO16_ADD2, SO16_ADD3, SO16_ASL_M,
         SO16_LSR_M, SO16_ASR_M, SO16_ASL_1, SO16_ASR_1,
         SO16_LSR_1:
         begin
            result = 1'b 1;
         end
         SO16_SOP:
         begin
            case (c_field) 

               SO16_SOP_JL, SO16_SOP_JLD, SO16_SOP_SUB:
               begin
                 result = 1'b 1;        
               end

               default:
               begin
                 result = 1'b 0;        
               end

            endcase
         end
         default:
         begin
            result = 1'b 0;        
         end
      endcase
   end

   OP_16_SP_REL:
   begin
      case (sub_op3) 

         SO16_LD_SP, SO16_LDB_SP, SO16_ADD_SP,
         SO16_SUB_SP, SO16_POP_U7, SO16_PUSH_U7:
         begin
            result = 1'b 1;
         end

         default:
         begin
            result = 1'b 0;        
         end

      endcase
   end

   OP_16_ADDCMP:
   begin
      if (sub_op3[SUBOPCODE3_16_MSB] == 1'b 0)
      begin
         result = 1'b 1;
      end
      else
      begin
         result = 1'b 0;
      end
   end

   default:
   begin
      result = 1'b 0;
   end

   endcase

   f_desten = result;
   end
end
endfunction

// This function returns a '1' if the instruction in question is not allowed
// to set the flags. i.e. load/stores and branch/jumps. (jcc.f is handled
// separately in flags).
//
function  f_no_fset;

input   [OPCODE_MSB:0]        main_op;
input   [SUBOPCODE_MSB:0]     sub_op;
input   [SUBOPCODE3_16_MSB:0] sub_op2;
input   [OPERAND_MSB:0]       c_field;
input   [FORMAT_MSB:0]        format;

reg     result;

begin
   begin
   case (main_op) 
   OP_BCC, OP_BLCC, OP_LD, OP_ST:
   begin
      result = 1'b 1;
   end

   OP_FMT1:
   begin
      case (sub_op) 

         SO_JL, SO_JL_D, SO_LDW, SO_LDW_X,
         SO_LP, SO_LR, SO_SR, SO_LD, SO_LDB,
         SO_LDB_X, SO_FLAG:
         begin
            result = 1'b 1;
         end

         SO_J, SO_J_D:
         begin
            if (((c_field == RILINK1) | (c_field == RILINK2)) &
                (format == FMT_REG))
            begin
               result = 1'b 1;
            end

            else
            begin
               result = 1'b 0;
            end
         end

         default:
         begin
            result = 1'b 0;        
         end
      endcase
   end

   OP_16_LD_ADD, OP_16_ARITH, OP_16_LD_U7,
   OP_16_LDB_U5, OP_16_LDW_U6, OP_16_LDWX_U6, 
   OP_16_ST_U7, OP_16_STB_U5, OP_16_STW_U6,
   OP_16_SP_REL, OP_16_GP_REL, OP_16_LD_PC,
   OP_16_MV, OP_16_BRCC, OP_16_BCC, OP_16_BL:
   begin
      result = 1'b 1;
   end

   OP_16_MV_ADD:
   begin
      if (sub_op[SUBOPCODE_MSB_1 : SUBOPCODE_MSB_2] == SO16_CMP)
      begin
         result = 1'b 0;
      end

      else
      begin
         result = 1'b 1;
      end
   end

   OP_16_ALU_GEN:
   begin
      case (sub_op[SUBOPCODE_MSB_1 : 0]) 

         SO16_TST:
         begin
            result = 1'b 0;
         end

         SO16_SOP:
         begin
            if (sub_op2 == SO16_SOP_SUB)
            begin
              result = 1'b 0;
            end

            else
            begin
              result = 1'b 1;
            end
         end

         default:
         begin
            result = 1'b 1;        
         end
      endcase
   end

   OP_16_SSUB:
   begin
      if (sub_op2 == SO16_BTST_U5)
      begin
         result = 1'b 0;
      end

      else
      begin
         result = 1'b 1;
      end
   end

   OP_16_ADDCMP:
   begin
      if (sub_op2[SUBOPCODE3_16_MSB] == SO16_ADD_U7)
      begin
         result = 1'b 1;
      end

      else
      begin
         result = 1'b 0;
      end
   end

   default:
      begin
      result = 1'b 0;
      end

   endcase

   f_no_fset = result;

   end
end
endfunction
// `endif
