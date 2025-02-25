// `ifndef XDEFS_V
// `define XDEFS_V
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
// This contains all the decodes for opcodes, addresses for the
// extensions in the ARC600. Type definitions are also included for
// extensions.
//
//========================== Ext. Constants ==========================--
//
// Define the long immeadiate register value as constant for use in
// extensions.

 parameter limm = 6'b 111110;

//======================== INSTRUCTION CODES =========================--
//
// Format of a Sub-Opcode (32-bit Opcode slot 0x5)
//
// The Sub-Opcode field is 6-bit number where the available slots are
// used to define the ARC extension instructions. These are then
// referenced in the xalu, xrctl and xaux_regs VHDL files (through
// "p2subopcode" and "p3subopcode") when detecting the current 
// instruction in the pipeline.
//
// There is also a second format for the Subopcode which denotes the
// extension as an integer rather than std_ulogic_vector. The naming
// convention for the extension instruction is modified by adding a "_n"
// to the end.
//
//
// Standard Opcodes:
//
// Standard Subopcodes:
//
// There are 4 variations to the Barrel Shifter extension.
//
// Barrel MO_ASL_EXT is an arithmetic shift left function which can 
// shift an operand (operand1) up to 32 places (operand2) and then place
// the result in the destination register.
//
// Barrel MO_LSR_EXT is a logical shift right function which can shift
// an operand (operand1) by number places specified in operand2 and then
// place the result in the destination register.
//
// Barrel MO_ASR_EXT is arithmetic shift right function which can shift 
// an operand (operand1) up to 32 places (operand2) and then place the
// result in the destination register. Note the destination register is
// sign extended.
//
// Barrel MO_ROR_EXT is a rotate right function which can shift an
// operand (operand1) up to 32 places (operand2) and then place the
// result in the destination register. 
//
// The zero and negative flag setting option are available to the barrel
// shift instructions.
//
 parameter MO_ASL_EXT = 6'b 000000; // Barrel ASL
 parameter MO_LSR_EXT = 6'b 000001; // Barrel LSR
 parameter MO_ASR_EXT = 6'b 000010; // Barrel ASR
 parameter MO_ROR_EXT = 6'b 000011; // Barrel ROR

// The 32 x 32 multiplier uses 2 instructions; one for signed and 
// unsigned multiplication. 
//
// MUL64 denotes the 32 x 32 signed multiplication. Since the output 
// from this extension is 64-bits wide the destination registers are 
// hardwired and not selectable so destination slot can be left empty.
// The low 32 bits are stored in MLO, the high 32 bits are stored in MHI
// and MMID is the core register for holding the middle 32 bits.
// 
// MULU64 denotes the 32 x 32 unsigned multiplication. The core registers
// for storing the results are the same as for the signed case. Note flag
// setting is not available for this extension. 
//
 // Signed multiply
 parameter MO_MUL64_EXT  = 6'b 000100;

 // Unsigned multiply
 parameter MO_MULU64_EXT = 6'b 000101;

 parameter MO_ADDS_EXT    = 6'b000110; 
 parameter MO_SUBS_EXT    = 6'b000111; 
 parameter MO_DIVAW_EXT   = 6'b001000; 
 
 parameter MO_ASLS_EXT    = 6'b001010; 
 parameter MO_ASRS_EXT    = 6'b001011;

 parameter MO_MULDW_EXT   = 6'b001100; 
 parameter MO_MULUDW_EXT  = 6'b001101; 
 parameter MO_MULRDW_EXT  = 6'b001110; 
  
 parameter MO_MACDW_EXT   = 6'b010000; 
 parameter MO_MACUDW_EXT  = 6'b010001; 
 parameter MO_MACRDW_EXT  = 6'b010010; 
 
 parameter MO_MSUBDW_EXT  = 6'b010100;
 
 parameter MO_MULT_EXT    = 6'b011000; 
 parameter MO_MULUT_EXT   = 6'b011001; 
 parameter MO_MULRT_EXT   = 6'b011010;

 parameter MO_MACT_EXT    = 6'b011100; 
 parameter MO_MACUT_EXT   = 6'b011101; 
 parameter MO_MACRT_EXT   = 6'b011110;
 
 parameter MO_MSUBT_EXT   = 6'b100000;
 
 parameter MO_CMACRDW_EXT = 6'b100110;

 parameter MO_ADDSDW_EXT  = 6'b101000; 
 parameter MO_SUBSDW_EXT  = 6'b101001;

 parameter MO_CRC_EXT     = 6'b101100; 

 parameter MO_ASL_EXT_N    = 0; // Barrel ASL
 parameter MO_LSR_EXT_N    = 1; // Barrel LSR
 parameter MO_ASR_EXT_N    = 2; // Barrel ASR
 parameter MO_ROR_EXT_N    = 3; // Barrel ROR

 parameter MO_MUL64_EXT_N  = 4; // Signed mult
 parameter MO_MULU64_EXT_N = 5; // Unsigned mult

 parameter MO_ADDS_EXT_N    = 6; 
 parameter MO_SUBS_EXT_N    = 7; 
 parameter MO_DIVA_EXT_N    = 8;
 
 parameter MO_ASLS_EXT_N    = 10; 
 parameter MO_ASRS_EXT_N    = 11; 
 parameter MO_MULDW_EXT_N   = 12; 
 parameter MO_MULUDW_EXT_N  = 13; 
 parameter MO_MULRDW_EXT_N  = 14;
 
 parameter MO_MACDW_EXT_N   = 16; 
 parameter MO_MACUDW_EXT_N  = 17; 
 parameter MO_MACRDW_EXT_N  = 18;
 
 parameter MO_MSUBDW_EXT_N  = 20;
 
 parameter MO_MULT_EXT_N    = 24; 
 parameter MO_MULUT_EXT_N   = 25; 
 parameter MO_MULRT_EXT_N   = 26;
 
 parameter MO_MACT_EXT_N    = 28; 
 parameter MO_MACUT_EXT_N   = 29; 
 parameter MO_MACRT_EXT_N   = 30;
 
 parameter MO_MSUBT_EXT_N   = 32; 

 parameter MO_CMACRDW_EXT_N = 38; 

 parameter MO_ADDSDW_EXT_N  = 40; 
 parameter MO_SUBSDW_EXT_N  = 41; 
 parameter MO_CRC_EXT_N     = 44; 

// Single Operands
// ---------------
//
// Format of a Single Operand Instruction
//
// The ARC also includes single operand instruction formats, i.e. flag
// instruction, and as a consequence there are spare slots which can be
// employed for use with extensions. 
//
// There is also a second format for the single operand instruction which
// denotes the extension as an integer rather than std_ulogic_vector. The
// naming convention for the extension instruction is modified by adding
// a "_n" to the end.
//
// As above but defined as integers.

 parameter SO_SWAP_EXT   = 6'b000000; 
 parameter SO_NORM_EXT   = 6'b000001; 
 parameter SO_SAT16_EXT  = 6'b000010; 
 parameter SO_RND16_EXT  = 6'b000011; 
 parameter SO_ABSSW_EXT  = 6'b000100; 
 parameter SO_ABSS_EXT   = 6'b000101; 
 parameter SO_NEGSW_EXT  = 6'b000110; 
 parameter SO_NEGS_EXT   = 6'b000111; 
 parameter SO_NORMW_EXT  = 6'b001000; 
 //Reserved Slot
 parameter SO_VBFDW_EXT  = 6'b001010; 
 parameter SO_FBFDW_EXT  = 6'b001011; 
 parameter SO_FBFT_EXT   = 6'b001100; 
 parameter SO_ABSSDW_EXT = 6'b001101; 
 parameter SO_NEGSDW_EXT = 6'b001110; 

 parameter SO_SWAP_EXT_N   = 0; 
 parameter SO_NORM_EXT_N   = 1; 
 parameter SO_SAT16_EXT_N  = 2; 
 parameter SO_RND16_EXT_N  = 3; 
 parameter SO_ABSSW_EXT_N  = 4; 
 parameter SO_ABSS_EXT_N   = 5; 
 parameter SO_NEGSW_EXT_N  = 6; 
 parameter SO_NEGS_EXT_N   = 7; 
 parameter SO_NORMW_EXT_N  = 8; 
 //Reserved Slot
 parameter SO_VBFDW_EXT_N  = 10; 
 parameter SO_FBFDW_EXT_N  = 11; 
 parameter SO_FBFT_EXT_N   = 12; 
 parameter SO_ABSSDW_EXT_N = 13; 
 parameter SO_NEGSDW_EXT_N = 14; 

//========================= CONDITION CODES ==========================--
//
// Format of Condition Codes
// -------------------------
//
// Condition codes in the ARC can be defined as 4-bit values, hence
// there are 16 spare slots which can be employed for use with 
// extensions. These are then referenced in the xalu, xrctl and
// xaux_regs HDL files (through "p2cc" and "p3cc") when detecting the
// current condition in the pipeline.
//  

 parameter XMAC_S         = 4'b 0000;
 parameter XMAC_NS        = 4'b 0001;
 parameter XMAC_AS        = 4'b 0010;
 parameter XMAC_NAS       = 4'b 0011;
 parameter XMAC_AZ        = 4'b 1000;
 parameter XMAC_NAZ       = 4'b 1001;
 parameter XMAC_AN        = 4'b 1010;
 parameter XMAC_NAN       = 4'b 1011;
 parameter XMAC_PS        = 4'b 1100;
 parameter XMAC_NPS       = 4'b 1101;


//===================== EXTENSION CORE REGISTERS =====================--
//
// Format of Ext. Core Register Constants
// --------------------------------------
//
// The ARC includes 32 x 32-bit core register file as standard, however,
// the address field for core register is 6-bits wide which means that
// an additional 32 core registerS can be defined.  
//
// These are then referenced in the xalu, xrctl and xaux_regs HDL files 
// (through "s1a", "s2a", "fs1a", and "wba" ) when detecting the address
// of core register.
//
// 32 x 32 Multiply extensions
//
// The 64-bit result of the 32 x 32 multiplication is stored in 3 core
// registers.
//
   // RMLO holds the lower 32-bits of the result.
   //
   // RMMID holds the middle 32-bits of the result.
   //
   // RMHI holds the upper 32-bits of the result.
   //
   parameter RMLO   = 6'b 111001; // r57
   parameter rmmid  = 6'b 111010; // r58
   parameter RMHI   = 6'b 111011; // r59

   //
   // XMAC extension core registers.
   //
   parameter ACC1 = 6'b111000; // r56
   parameter ACC2 = 6'b111001; // r57

//================== EXTENSION AUXILIARY REGISTERS ===================--
//
// Format of Ext. Auxiliary Register Constants
//
// The ARC includes 6 auxiliary registers as standard, however, the
// address limit for the auxiliary register space for extensions is
// 32-bits.  
//
// These are then referenced in the xalu, xrctl and xaux_regs HDL files 
// (through "drx_reg", "aux_addr" and "aux_dataw") when detecting the
// address of auxiliary register.
//
//
// The AUX_IVIC extension auxiliary register is a write-only register 
// which when a value is written to it clears the cache through the ivic
// (InValidate Instruction Cache) signal provided that no_ivic is not
// true which stalls this operation.
//
   parameter AUX_IVIC        = 8'h 10;
//
// The AUX_MULHI extension auxiliary register allows the detection of an
// auxiliary register write to the high part of the multiplier result,
// i.e. top 32-bits.
//
   parameter AUX_MULHI       = 8'h 12;

// Direct Mapped Cache Ext Auxiliary Registers 
// -------------------------------------------
//
// The Extension Auxiliary Registers for the Instruction Cache
//
// The AUX_CHE_MODE register is a 3-bit wide register which holds the
// mode of operation for the cache configuration :
//
// Bit 0 - Enable debug mode.
// Bit 1 - Enable cache bypass mode.
// Bit 2 - Enable for the code RAM.
// Bits 3 : 31 - UNUSED.
//
   parameter AUX_CHE_MODE    = 8'h 11;

// Auxiliary register for local RAM for LD/ST memory controller.
// -------------------------------------------------------------
//
// This is the control register which sets the base address for the
// local RAM block in ldst_queue.
//
  parameter AUX_LDST_RAM   = 8'h 18;
  
// EIA flags register
  parameter AUX_EIA_FLAGS = 11'h 44f;

// Maximum width of programmable cycle timer counter
//
// The width of the timer counter is set at 32-bits.
//
  parameter TIMER_WIDTH     = 32;
  parameter TIMER_MSB       = TIMER_WIDTH - 1;

// Host & Interrupt Registers 
// --------------------------
//
// The AUX_HINT extension register generates an interrupt when it is
// written (SR) to.
//
// this register is now redundant since any interrupt can be generated 
// using the AUX_IRQ_HINT register
//
// The AUX_PCPORT extension auxiliary register is a write only register
// which is set to '1' when a Sun // communications port is used, and to 
// '0' when a PC Parallel communications port is used (pc_port.v).
//  
  parameter AUX_H_INT      = 8'h 23;  // host interrupt generate
                                      // register
  parameter AUX_PCPORT     = 8'h 24;  // Unused lines on the PC port

  // Used for cross-core interrupts, if enabled.
  parameter AUX_INTER_CORE_INTERRUPT = 16'h 280;
  parameter AUX_INTER_CORE_ACK       = 16'h 282;

  // inter-core semaphore reg, if enabled.
  parameter AX_IPC_SEM_N     = 16'h 281; 

// The AUX_POWER extension auxiliary register is a write only register
// which used to select start/end of switching activity for gate-level 
// simulation power estimates.

  parameter AUX_POWER      = 16'h 500;  

// Interrupt Vector Base Address Register
// --------------------------------------
//
// The interrupt vector base address register is generated and is
// employed for handling interrupts and exceptions.
//
 parameter AUX_INT_VECTOR_BASE = 8'h 25;

// XMAC Extension Auxiliary Registers
// ----------------------------------
//
//
// These are in fact the AUX_MACMODE, AUX_XMAC0, AUX_XMAC1, and AUX_XMAC2
// registers.
//
  parameter AUX_MACMODE        = 8'h41; //      65


  parameter AUX_FBF_STORE_D16 = 8'h2F;


// DMP Peripheral Port
// -------------------
//
   parameter AUX_DMP_PERIPH_BASE = 8'h 4f;

// ARCangel Registers
// --------------------
//
   // LED's
   //
   parameter AUX_LED         = 8'h 52;

   // LCD registers
   //
   parameter AUX_LCD_INST    = 8'h 53;
   parameter aux_lcd_data    = 8'h 54;
   parameter AUX_LCD_STAT    = 8'h 55;

   // DIP Switches
   //
   parameter AUX_DIPSW       = 8'h 56;

   //
   // Configurable interrupt subsystem registers:
   //
   // 1) AUX_IRQ_LEV allows the interrupts to be programmed to be
   //    either level 1 or level 2
   // 2) AUX_IRQ_HINT enables the software to generate any interrupts
   // 3) AUX_IRQ_LV12 has 2 sticky bits that indicate if an interrupt
   //    level 1 or level 2 has been taken
   //
   parameter AUX_IRQ_LV12   = 8'h 43;
   parameter AUX_IRQ_LEV    = 16'h 200; // 16#200# 
   parameter AUX_IRQ_HINT   = 16'h 201; // 16#201# 

   // memory misaligned detection and capture registers
   parameter AUX_ALIGN_CTRL = 16'h 203;

   // system BCR for multi-core builds; present only if > 1 core.
   parameter AUX_SYSTEM_BUILD   = 16'h C2;

   // Buttons
   //
   parameter AUX_BUTTONS    = 8'h 57; // 16#57#;
   
//
// Build Configuration Ext Auxiliary Registers
// -------------------------------------------
//
    // These registers can be used by embedded software or host debug
    // software detect the configuration of the ARC hardware.
    //
    //
    // REGISTER LOCATIONS 0x60 -> 0x7f & 0xC0 -> 0xFF ARE RESERVED
    // FOR EXPANSION
    //
    parameter BCR_VERSION_BUILD = 8'h 60; // Aux register 96
    parameter RESERVED_61_BUILD = 8'h 61; // Aux register 97
    parameter CRC_BUILD         = 8'h 62; // Aux register 98
    parameter RESERVED_63_BUILD = 8'h 63; // Aux register 99
    parameter VBFDW_BUILD       = 8'h 64; // Aux register 100
    parameter EXT_ARITH_BUILD   = 8'h 65; // Aux register 101
    parameter DATASPACE_BUILD   = 8'h 66; // Aux register 102
    parameter MEMSUBSYS_BUILD   = 8'h 67; // Aux register 103
    parameter VECBASE_AC_BUILD  = 8'h 68; // Aux register 104
    parameter PERIPH_BUILD      = 8'h 69; // Aux register 105
    parameter RESERVED_6A_BUILD = 8'h 6a; // Aux register 106
    parameter UNUSED_6B_BUILD   = 8'h 6b; // Aux register 107
    parameter UNUSED_6C_BUILD   = 8'h 6c; // Aux register 108
    parameter MPU_BUILD         = 8'h 6d; // Aux register 109
    parameter RF_BUILD          = 8'h 6e; // Aux register 110
    parameter RESERVED_6F_BUILD = 8'h 6f; // Aux register 111
    parameter AA2_BUILD         = 8'h 70; // Aux register 112
    parameter UNUSED_71_BUILD   = 8'h 71; // Aux register 113
    parameter DCACHE_BUILD      = 8'h 72; // Aux register 114
    parameter MADI_BUILD        = 8'h 73; // Aux register 115
    parameter LDSTRAM_BUILD     = 8'h 74; // Aux register 116
    parameter TIMER_BUILD       = 8'h 75; // Aux register 117
    parameter AP_BUILD          = 8'h 76; // Aux register 118
    parameter CACHE_BUILD       = 8'h 77; // Aux register 119
    parameter ICCM_BUILD        = 8'h 78; // Aux register 120
    parameter DSPRAM_BUILD      = 8'h 79; // Aux register 121
    parameter MAC_BUILD         = 8'h 7a; // Aux register 122
    parameter MULTIPLY_BUILD    = 8'h 7b; // Aux register 123
    parameter SWAP_BUILD        = 8'h 7c; // Aux register 124
    parameter NORM_BUILD        = 8'h 7d; // Aux register 125
    parameter MINMAX_BUILD      = 8'h 7e; // Aux register 126
    parameter BARREL_BUILD      = 8'h 7f; // Aux register 127
    parameter RESERVED_C0_BUILD = 8'h c0; // Aux register 192
    parameter ARC600_BUILD      = 8'h c1; // Aux register 193
    parameter UNUSED_C2_BUILD   = 8'h c2; // Aux register 194
    parameter DMP_PP_BUILD      = 8'h c3; // Aux register 195
    parameter MCD_BUILD         = 8'h c4; // Aux register 196
    parameter UNUSED_C5_BUILD   = 8'h c5; // Aux register 197
    parameter UNUSED_C6_BUILD   = 8'h c6; // Aux register 198
    parameter UNUSED_C7_BUILD   = 8'h c7; // Aux register 199
    parameter UNUSED_C8_BUILD   = 8'h c8; // Aux register 200
    parameter UNUSED_C9_BUILD   = 8'h c9; // Aux register 201
    parameter UNUSED_CA_BUILD   = 8'h ca; // Aux register 202
    parameter UNUSED_CB_BUILD   = 8'h cb; // Aux register 203
    parameter UNUSED_CC_BUILD   = 8'h cc; // Aux register 204
    parameter UNUSED_CD_BUILD   = 8'h cd; // Aux register 205
    parameter UNUSED_CE_BUILD   = 8'h ce; // Aux register 206
    parameter UNUSED_CF_BUILD   = 8'h cf; // Aux register 207
    parameter UNUSED_D0_BUILD   = 8'h d0; // Aux register 208
    parameter UNUSED_D1_BUILD   = 8'h d1; // Aux register 209
    parameter UNUSED_D2_BUILD   = 8'h d2; // Aux register 210
    parameter UNUSED_D3_BUILD   = 8'h d3; // Aux register 211
    parameter UNUSED_D4_BUILD   = 8'h d4; // Aux register 212
    parameter UNUSED_D5_BUILD   = 8'h d5; // Aux register 213
    parameter UNUSED_D6_BUILD   = 8'h d6; // Aux register 214
    parameter UNUSED_D7_BUILD   = 8'h d7; // Aux register 215
    parameter UNUSED_D8_BUILD   = 8'h d8; // Aux register 216
    parameter UNUSED_D9_BUILD   = 8'h d9; // Aux register 217
    parameter UNUSED_DA_BUILD   = 8'h da; // Aux register 218
    parameter UNUSED_DB_BUILD   = 8'h db; // Aux register 219
    parameter UNUSED_DC_BUILD   = 8'h dc; // Aux register 220
    parameter UNUSED_DD_BUILD   = 8'h dd; // Aux register 221
    parameter UNUSED_DE_BUILD   = 8'h de; // Aux register 222
    parameter UNUSED_DF_BUILD   = 8'h df; // Aux register 223
    parameter UNUSED_E0_BUILD   = 8'h e0; // Aux register 224
    parameter UNUSED_E1_BUILD   = 8'h e1; // Aux register 225
    parameter UNUSED_E2_BUILD   = 8'h e2; // Aux register 226
    parameter UNUSED_E3_BUILD   = 8'h e3; // Aux register 227
    parameter UNUSED_E4_BUILD   = 8'h e4; // Aux register 228
    parameter UNUSED_E5_BUILD   = 8'h e5; // Aux register 229
    parameter UNUSED_E6_BUILD   = 8'h e6; // Aux register 230
    parameter UNUSED_E7_BUILD   = 8'h e7; // Aux register 231
    parameter UNUSED_E8_BUILD   = 8'h e8; // Aux register 232
    parameter UNUSED_E9_BUILD   = 8'h e9; // Aux register 233
    parameter UNUSED_EA_BUILD   = 8'h ea; // Aux register 234
    parameter UNUSED_EB_BUILD   = 8'h eb; // Aux register 235
    parameter UNUSED_EC_BUILD   = 8'h ec; // Aux register 236
    parameter UNUSED_ED_BUILD   = 8'h ed; // Aux register 237
    parameter UNUSED_EE_BUILD   = 8'h ee; // Aux register 238
    parameter UNUSED_EF_BUILD   = 8'h ef; // Aux register 239
    parameter UNUSED_F0_BUILD   = 8'h f0; // Aux register 240
    parameter UNUSED_F1_BUILD   = 8'h f1; // Aux register 241
    parameter UNUSED_F2_BUILD   = 8'h f2; // Aux register 242
    parameter UNUSED_F3_BUILD   = 8'h f3; // Aux register 243
    parameter UNUSED_F4_BUILD   = 8'h f4; // Aux register 244
    parameter UNUSED_F5_BUILD   = 8'h f5; // Aux register 245
    parameter UNUSED_F6_BUILD   = 8'h f6; // Aux register 246
    parameter PMU_BUILD         = 8'h f7; // Aux register 247
    parameter COPROC_BUILD      = 8'h f8; // Aux register 248
    parameter RESERVED_F9_BUILD = 8'h f9; // Aux register 249
    parameter RESERVED_FA_BUILD = 8'h fa; // Aux register 250
    parameter RESERVED_FB_BUILD = 8'h fb; // Aux register 251
    parameter RESERVED_FC_BUILD = 8'h fc; // Aux register 252
    parameter RESERVED_FD_BUILD = 8'h fd; // Aux register 253
    parameter IFETCHQUEUE_BUILD = 8'h fe; // Aux register 254
    parameter UNUSED_FF_BUILD   = 8'h ff; // Aux register 255

//========================== MISCELLANEOUS ===========================--
//
// Constants that are neither instruction slots, extension auxiliary
// registers or extension core registers should be defined below.
//
//
//----------------------- The LD/ST RAM --------------------------------
//
   // The address width of the DCCM RAM.
   // ldst_queue.v when selected. This means that LD/ST to memory 
   // between addresses 0 to 2 **(LDST_A_WIDTH) will be written to this
   // RAM and not to external memory. This provides a performance
   // improvement since the overhead of going off-chip for these memory 
   // accesses is reduced.
   //
   parameter   LDST_A_WIDTH  = 17;
   parameter   LDST_A_MSB    = LDST_A_WIDTH - 1;

   `define     ldst_cell_msb   LDST_A_MSB
   `define     ldst_cell_lsb   `ldst_cell_msb - 2
   `define     ldst_cell_addr_msb `ldst_cell_lsb - 1

   `define     ldst_ram0       3'b 000
   `define     ldst_ram1       3'b 001
   `define     ldst_ram2       3'b 010
   `define     ldst_ram3       3'b 011
   `define     ldst_ram4       3'b 100
   `define     ldst_ram5       3'b 101
   `define     ldst_ram6       3'b 110
   `define     ldst_ram7       3'b 111

// The Fast Multiplier
// -------------------
//
// The constant MUL_CYCLES is the number of clock cycles before the
// result from the multiplier is registered.
//    
    parameter MUL_CYCLES = 2'b11;

// Constants used by both the XY Memory and the XMACs
//---------------------------------------------------
//
// The constant MEMR_SZ defines the number of bits used to address
// the entire X and Y memory regions. The values of the constant is
// actually 1 value bigger due to the fact that in 16-bit mode we
// address twice as much data space as the standard 32-bit mode. 
// Refer to the DSP XY Memory manual for a more detailed
// explanation.
//
// The constant RAMA_SZ value defines the number of bits for the 
// 32-bit mode. This is required in order to address rams as 32-bit
// quantities, instead of 16-bit quantities. The constant is simply
// the value of the MEMR_SZ minus one.
//

    parameter MEMR_SZ          = 7;
    parameter RAMA_SZ          = MEMR_SZ-1;

//------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
//-- XMAC CONSTANTS
//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Common Constants
//-----------------------------------------------------------------------------

   parameter XM_GUARD_BIT_WIDTH = 8; 
   parameter XM_GUARD_BIT_MSB = XM_GUARD_BIT_WIDTH - 1; 

   //This is the ammount of extra stalls required by the dep_checker to allow
   //the xmac to write-back to xy memory and an intruction in stage2 to read
   //the correct value

   parameter XM_NO_OF_XYMEM_STALLS = 3; 
   parameter XM_NO_OF_XYMEM_STALLS_PLUS_1 = XM_NO_OF_XYMEM_STALLS + 1; 
   parameter XM_NO_OF_XYMEM_STALLS_MINUS_1 = XM_NO_OF_XYMEM_STALLS - 1; 

   // This is the imaginary MSB of the the 32-bit accumulator when in Sat32 mode
   parameter XM_ACC32_MSB = 31; 
   parameter XM_ACC32_MSB_PLUS_1 = XM_ACC32_MSB + 1;
   parameter XM_ACC32_MSB_PLUS_2 = XM_ACC32_MSB + 2; 

   parameter XM_NO_OF_CHANNELS = 2; 

   parameter XM_CHAN1 = 1; 
   parameter XM_CHAN2 = 2; 

   parameter DUAL = 1'b1; 

   parameter XM_SUB_BOTH_CHAN = 2'b11; 
   parameter XM_SUB_CHAN_2 = 2'b01; 
   parameter XM_SUB_NO_CHAN = 2'b00; 

   //By setting this variable to '1' you will get the
   //XMAC accumulator flags shown in pdisp
   parameter XMAC_PDISP_FLG = 1'b1; 
   
   //By setting this variable to '1' you will get the
   //XMAC accumulator contents shown in pdisp
   parameter XMAC_PDISP_ACCU = 1'b1; 
   
   // These constants define values for the register destination types.
   // No register defined in the destination field = '0'. An XMAC
   // extension core register defined in the destination field = '1'.
   //
   
   parameter NO_REG = 1'b0; 
   parameter CORE_REG = 1'b1; 
   
   // These constants define the bit positions of the 
   // flag and mode bits in the AUX_MACMODE register.
   parameter CA    = 0; 
   parameter CS    = 1; 
   parameter QA16  = 2; 
   parameter P16   = 3; 
   parameter ST2   = 4; 
   parameter PRS2  = 5; 
   parameter AN2   = 6; 
   parameter AZ2   = 7; 
   parameter ACS2  = 8; 
   parameter ST    = 9; 
   parameter PRS   = 10; 
   parameter AN    = 11; 
   parameter AZ    = 12; 
   parameter ACS   = 13; 
   parameter GM16  = 14; 
   parameter RM16  = 15; 
   parameter QA24  = 16; 
   parameter P24   = 17; 
   parameter RM24  = 18;
 
   // This defines the top bit of the AUX_MACMODE register.
   parameter MACMODE_MSB = 18; 

   
// The Build Configuration Registers
// ---------------------------------
//
// The constants for the build configuration register values are placed
// here.
//
// For those BCRs that are reserved or unused the default is set to zero
//
   parameter    UNUSED_BUILD_VALUE      = 32'b 00000000000000000000000000000000;
   parameter    RESERVED_BUILD_VALUE    = 32'b 00000000000000000000000000000000;

//
// The following comments are used in testing that these registers
// are functioning properly. The testcode must be able to detect which
// extensions are present and therefore check that the values read back
// from these registers are in fact correct.
//
// TEST BCR VERSION 00000000000000000000000000000010;
// TEST CRC 00000000000000000000000000000000;
// TEST VBFDW 00000000000000000000000000000000;
// TEST EXT_ARITH 00000000000000000000000000000000;
// TEST DATASPACE 00000000100000000000000000000000;
// TEST MEMSUBSYS 00000000000000000000000000000001;
// TEST IRQ 00000000000000000000000000000001
// TEST PERIPH 00000000000000000000000000000000
// TEST MPU 00000000000000000000000000000000
// TEST RF 00000000000000000000001000000001
// TEST DCACHE 00000000000000000000000000000000
// TEST MADI 00000000000000000000000000000000
// TEST LDSTRAM 00000000000000000000101100000010
// TEST TIMER 00000000000000000000000100000011
// TEST AP 00000000000000000000010000000100
// TEST CACHE 00000000000000000000000000000000
// TEST ICCM 00000000000000000000101100000010;
// TEST DSPRAM 00000000000000000000000000000000
// TEST MAC 00000000000000000000000000000000
// TEST MULTIPLY 00000000000000000000000000000100
// TEST SWAP 00000000000000000000000000000001
// TEST NORM 00000000000000000000000000000010
// TEST MINMAX 00000000000000000000000000000000
// TEST BARREL 00000000000000000000000000000010
// TEST IFETCHQUEUE 00000000000000000000000000000000;
// TEST COPROC 00000000000000000000000000000000;
// TEST PMU 00000000000000000000000000000000;

   parameter    ARC600_BUILD_VALUE      = 32'b 00000000000000100001001000000010;
   parameter    BCR_VERSION_BUILD_VALUE = 32'b 00000000000000000000000000000010;
   parameter    CRC_BUILD_VALUE         = 32'b 00000000000000000000000000000000;
   parameter    VBFDW_BUILD_VALUE       = 32'b 00000000000000000000000000000000;
   parameter    EXT_ARITH_BUILD_VALUE   = 32'b 00000000000000000000000000000000; 
   parameter    DATASPACE_BUILD_VALUE   = 32'b 00000000100000000000000000000000;
   parameter    MEMSUBSYS_BUILD_VALUE   = 32'b 00000000000000000000000000000001;
   parameter    VECBASE_AC_BUILD_VALUE  = 32'b 00000000000000000000000000000001;
   parameter    PERIPH_BUILD_VALUE      = 32'b 00000000000000000000000000000000;
   parameter    MPU_BUILD_VALUE         = 32'b 00000000000000000000000000000000;
   parameter    RF_BUILD_VALUE          = 32'b 00000000000000000000001000000001;
   parameter    DCACHE_BUILD_VALUE      = 32'b 00000000000000000000000000000000;
   parameter    MADI_BUILD_VALUE        = 32'b 00000000000000000000000000000000;
   parameter    LDSTRAM_BUILD_VALUE     = 32'b 00000000000000000000101100000010;
   parameter    TIMER_BUILD_VALUE       = 32'b 00000000000000000000000100000011;
   parameter    AP_BUILD_VALUE          = 32'b 00000000000000000000010000000100;
   parameter    CACHE_BUILD_VALUE       = 32'b 00000000000000000000000000000000;
   parameter    ICCM_BUILD_VALUE        = 32'b 00000000000000000000101100000010;
   parameter    DSPRAM_BUILD_VALUE      = 32'b 00000000000000000000000000000000;
   parameter    MAC_BUILD_VALUE         = 32'b 00000000000000000000000000000000;
   parameter    MULTIPLY_BUILD_VALUE    = 32'b 00000000000000000000000000000100;
   parameter    SWAP_BUILD_VALUE        = 32'b 00000000000000000000000000000001;
   parameter    NORM_BUILD_VALUE        = 32'b 00000000000000000000000000000010;
   parameter    MINMAX_BUILD_VALUE      = 32'b 00000000000000000000000000000000;
   parameter    BARREL_BUILD_VALUE      = 32'b 00000000000000000000000000000010;
   parameter    DMP_PP_BUILD_VALUE      = 32'b 00000000000000000000000000000000;
   parameter    IFETCHQUEUE_BUILD_VALUE = 32'b 00000000000000000000000000000000;
   parameter    COPROC_BUILD_VALUE      = 32'b 00000000000000000000000000000000;
   parameter    PMU_BUILD_VALUE         = 32'b 00000000000000000000000000000000;
   parameter    MCD_BUILD_VALUE         = 32'b 00000000000000000000000000000000;

// Actionpoint Auxiliary Registers 
// -------------------------------
//
// These auxiliary registers are used to program the actionpoint
// mechanism to perform non-intrusive debugging. The build configuration
// (AP_BUILD_VALUE) register informs the debugger of the debug
// extensions available in the system.
//
// Define the addresses of the auxiliary registers that the actionpoints mechanism
// uses.

   parameter aux_ap_amv0 = 12'h220; 
   parameter aux_ap_amm0 = 12'h221; 
   parameter aux_ap_ac0  = 12'h222; 
   parameter aux_ap_amv1 = 12'h223; 
   parameter aux_ap_amm1 = 12'h224; 
   parameter aux_ap_ac1  = 12'h225; 
   parameter aux_ap_amv2 = 12'h226; 
   parameter aux_ap_amm2 = 12'h227; 
   parameter aux_ap_ac2  = 12'h228; 
   parameter aux_ap_amv3 = 12'h229; 
   parameter aux_ap_amm3 = 12'h22a; 
   parameter aux_ap_ac3  = 12'h22b; 
   parameter aux_ap_amv4 = 12'h22c; 
   parameter aux_ap_amm4 = 12'h22d; 
   parameter aux_ap_ac4  = 12'h22e; 
   parameter aux_ap_amv5 = 12'h22f; 
   parameter aux_ap_amm5 = 12'h230; 
   parameter aux_ap_ac5  = 12'h231; 
   parameter aux_ap_amv6 = 12'h232; 
   parameter aux_ap_amm6 = 12'h233; 
   parameter aux_ap_ac6  = 12'h234; 
   parameter aux_ap_amv7 = 12'h235; 
   parameter aux_ap_amm7 = 12'h236; 
   parameter aux_ap_ac7  = 12'h237; 

// JTAG Port Parameters
// --------------------
//
// States defined for the JTAG Communications Port.
//
    // The following constants are used to increment the Address
    // register (used for down/uploading streams of data to/from memory
    // or the ARC registers).
    //
    parameter ADDRESS_OFFSET = 32'h 00000004; 
    parameter REGISTER_OFFSET = 32'h 00000001; 

    // The following constant is used to identify the JTAG model
    // version.
    //
    parameter JTAG_ID_NUM = 8'b 00000001; 

    //  The following constants define the instruction codes for all
    //  internal data registers. These codes should be written into the
    //  instruction reister in order to access the required data 
    //  register. The codes for EXTEST and SAMPLE are instructions that
    //  are reserved for use with a Boundary Scan Register.
    //
    parameter IR_BYPASS  = 4'b 1111; //  Bypass (1 bit register)
    parameter IR_EXTEST  = 4'b 0000; //  Reserved for a BSR
    parameter IR_SAMPLE  = 4'b 0001; //  Reserved for a BSR
    parameter IR_STATUS  = 4'b 1000; //  The Status register (32 bits)
    parameter IR_COMMAND = 4'b 1001; //  The Command register (4 bits)
    parameter IR_ADDRESS = 4'b 1010; //  The Address register (32 bits)
    parameter IR_DATA    = 4'b 1011; //  The Data register (32 bits)
    parameter IR_ARCNUM  = 4'b 1100; //  The ID ARCNUM register (8 bits) 

    // The following constants define the lower 2 bits of the
    // Transaction Command register. These bits are used to define the
    // type of transaction access that is required. Currently there are
    // only three types of transactions that can be performed, an access
    // to memory or an access to the ARC`s auxiliary or core register
    // space.
    //
    parameter CMD_MEM = 2'b 00; //  access the memory
    parameter CMD_CORE = 2'b 01; //  access the core registers
    parameter CMD_AUX = 2'b 10; //  access the auxiliary registers
    parameter CMD_MADI = 2'b 11; //  access the madi registers

    // The following constants define the upper 2 bits of the command
    // register. The two bits (1 bit really) define whether a read or
    // write type transaction is to be performed.
    //
    parameter CMD_READ = 2'b 01; //  perform a read transaction
    parameter CMD_WRITE = 2'b 00; //  perfotm a write transaction

    // The following constants define the actual transactions that the
    // JTAG module can perform. There are a total of 6 commands that
    // can be executed.
    //
    parameter CMD_RD_MEM = 4'b 0100; //  read lword from memory
    parameter CMD_WR_MEM = 4'b 0000; //  write lword to memory
    parameter CMD_RD_AUX = 4'b 0110; //  write lword to auxiliary
    parameter CMD_WR_AUX = 4'b 0010; //  read lword from auxiliary   
    parameter CMD_RD_CORE = 4'b 0101; //  read lword from core
    parameter CMD_WR_CORE = 4'b 0001; //  write lword to core
    parameter CMD_RD_MADI = 4'b 1000; //  read lword from madi
    parameter CMD_WR_MADI = 4'b 0111; //  write lword to madi
    parameter CMD_RESET_VALUE = 4'b 0011; //  reset value

    // The following constants are reset values for all the D-type
    // flip-flops.
    //
    parameter RESET_VALUE_32BIT = 32'h 00000000; 
    parameter RESET_VALUE_20BIT = 20'h 00000; 
    parameter RESET_VALUE_8BIT = 8'h 00; 
    parameter RESET_VALUE_4BIT = 4'h 0; 

    // The following constants are used to select bit fields from shift
    // register. These constants are used when updating a data register, 
    // since all the data registers are not the same bit width as the
    // shift register. These constants have been included to improve
    // readability.
    //
    parameter SREG_MAX = 31; //  bit 32 the top bit of the instruction
                             //  register
    parameter TARG_B31 = 31; //  bit 32 of the shift register
    parameter TARG_B28 = 28; //  bit 28 of the shift register
    parameter TARG_B24 = 24; //  bit 24 of the shift register
    parameter TARG_B23 = 23; //  bit 23 of the shift register
    parameter TARG_B4 = 4;   //  bit 4 of the shift register
    parameter TARG_B7 = 7;   //  bit 7 of the shift register
    parameter TARG_B3 = 3;   //  bit 3 of the shift register
    parameter TARG_B0 = 0;   //  bit 0 of the shift register

    // The following section is used to reference the lower four bits
    // of the Status register.
    //
    parameter STATUS_BIT0 = 0; //  bit 0 of the status register
    parameter STATUS_BIT1 = 1; //  bit 1 of the status register
    parameter STATUS_BIT2 = 2; //  bit 2 of the status register
    parameter STATUS_BIT3 = 3; //  bit 3 of the status register

// The following types are enumurated for the two state machines of the
// debug port. Refer to the appropriate section for an in depth
// explanation of these states.
//
    // TYPE fsm_state_tsm:
    //
    parameter FSM_STATE_TSM_S_RST = 4'b 0000;
    parameter FSM_STATE_TSM_S_IDLE = 4'b 0001;
    parameter FSM_STATE_TSM_S_MR_RQ = 4'b 0010;
    parameter FSM_STATE_TSM_S_MR_WAIT = 4'b 0011;
    parameter FSM_STATE_TSM_S_MW_RQ = 4'b 0100;
    parameter FSM_STATE_TSM_S_MW_WAIT = 4'b 0101;
    parameter FSM_STATE_TSM_S_ARC_READ = 4'b 0110;
    parameter FSM_STATE_TSM_S_ARC_READ2 = 4'b 0111;
    parameter FSM_STATE_TSM_S_AR_STALL = 4'b 1000;
    parameter FSM_STATE_TSM_S_ARC_WRITE = 4'b 1001;
    parameter FSM_STATE_TSM_S_AW_STALL = 4'b 1010;
    parameter FSM_STATE_TSM_S_WAIT_H = 4'b 1011;

    // TYPE fsm_state_sch:
    //
    parameter FSM_STATE_SCH_REQUEST_A_TRANSACTION = 2'b 00;
    parameter FSM_STATE_SCH_WAIT_UNTIL_RECEIVED = 2'b 01;
    parameter FSM_STATE_SCH_WAIT_UNTIL_ACK_LOW = 2'b 10;
    parameter FSM_STATE_SCH_ADDRESS_REG_UPDATE = 2'b 11;

// Timer0 Counter auxiliary registers
// ----------------------------------
//
// The AUX_TIMER register provides the current value of the timer
// counter.
//
// The AUX_TCONTROL extension register provides control over the
// operation of the counter. This is a 2-bit wide register which has the
// following functionality :
//
// Bit(0) - This sets the interrupt enable signal, hence an interrupt is
//          generated when the timer wraps around itself and this signal
//          is true.
// Bit(1) - This sets the timer mode so that when it is true the timer 
//          is only incremented when the ARC is running (en = '1'). When
//          false the timer is incremented every clock cycle.
//
  parameter aux_timer       = 8'h 21;  // timer/counter register
  parameter aux_tcontrol    = 8'h 22;  // timer/counter control register
  parameter aux_tlimit      = 8'h 23;  // timer0/limit register 

// `endif

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// AMBA defined signal constants for all initiators in an ARC system. Only the cacheable and
// bufferable characteristics of the interface can be changed by these parameters. Ensure you
// set the correct parameter for the correct initiator if you intend to change them.

   parameter    DCACHE_AHB_BUFFERABLE   =  1'b0;
   parameter    DCACHE_AHB_CACHEABLE    =  1'b1;

   parameter    ICACHE_AHB_BUFFERABLE   =  1'b0;
   parameter    ICACHE_AHB_CACHEABLE    =  1'b1;

   parameter    LDSTQ_AHB_BUFFERABLE    =  1'b0;
   parameter    LDSTQ_AHB_CACHEABLE     =  1'b0;

   parameter    IFQ_AHB_BUFFERABLE      =  1'b0;
   parameter    IFQ_AHB_CACHEABLE       =  1'b1;

   parameter    XY_AHB_BUFFERABLE       =  1'b0;
   parameter    XY_AHB_CACHEABLE        =  1'b0;
   
///////////////////////////////////////////////////////////////////////////////////////////////////

