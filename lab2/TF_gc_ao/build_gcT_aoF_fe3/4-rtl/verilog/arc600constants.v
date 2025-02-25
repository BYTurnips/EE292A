// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 2007-2012 ARC International (Unpublished)
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
// functions for the ARC 600. 
// These values do not change no matter how you configure the ARC 600.
//
//

`define false 1'b 0
`define FALSE 1'b 0
`define true  1'b 1
`define TRUE  1'b 1

`define ISA32_WIDTH        32 //  long word width

// ARCompact ISA Definitions
//
`define INSTR_MSB            5'b 11111
`define INSTR_LSB            5'b 11011

// Fields in the Debug Register
//
`define DEBUG_S_STEP_MSB     1'b 0     // single step bit position.
`define DEBUG_F_HALT_MSB     1'b 1     // force halt bit position.
`define DEBUG_A_HALT_MSB     2'b 10    // actionhalt bit position.
`define DEBUG_I_STEP_MSB     4'b 1011  // single instruction step bit position
`define DEBUG_RESET_MSB      5'b 10110 // reset applied bit position
`define DEBUG_SLEEP_MSB      5'b 10111 // sleep flag
`define DEBUG_EN_DEBUG_MSB   5'b 11000 // enable debug flag
`define DEBUG_AMC_LSB        5'b 11001 // actionpoint memory client
                                       // lower bit position.
`define DEBUG_EXT_HALT       5'b 11010 // external halt, controlled by MCD module
`define DB_DOMAIN_HALT_RESERVED 5'b 11011 // Reserved for arc700 Domain Halt.
`define DEBUG_AMC_MSB        5'b 11100 // actionpoint memory client
                                       // higher bit position.
`define DEBUG_B_HALT_MSB     5'b 11101 // breakhalt bit position.
`define DEBUG_S_HALT_MSB     5'b 11110 // self-halt bit position
`define DEBUG_LOOP_MSB       5'b 11111 // lpending position

// Width of loop count register
//
`define LOOPWORD_MSB         5'b 11110
`define LOOPWORD_MSB_1       5'b 11101

// Status32 register bit fields

`define STATUS32_EN_MSB      1'b 0     // halt status bit position.
`define STATUS32_E1_MSB      1'b 1     // interrupt e1 bit position.
`define STATUS32_E2_MSB      2'b 10    // interrupt e2 bit position.
`define STATUS32_V_MSB       4'b 1000  // overflow flag position.
`define STATUS32_C_MSB       4'b 1001  // carry flag position.
`define STATUS32_N_MSB       4'b 1010  // sign flag position.
`define STATUS32_Z_MSB       4'b 1011  // zero flag position.

//  The interrupt vectors as 11-bit offsets:
// 
`define IVECTOR_OFS0         10'h 000  //  0x00
`define IVECTOR_OFS1         10'h 008  //  0x08 
`define IVECTOR_OFS2         10'h 010  //  0x10
`define IVECTOR_OFS3         10'h 018  //  0x18
`define IVECTOR_OFS4         10'h 020  //  0x20 
`define IVECTOR_OFS5         10'h 028  //  0x28 
`define IVECTOR_OFS6         10'h 030  //  0x30 
`define IVECTOR_OFS7         10'h 038  //  0x38 
`define IVECTOR_OFS8         10'h 040  //  0x40
`define IVECTOR_OFS9         10'h 048  //  0x48
`define IVECTOR_OFS10        10'h 050  //  0x50
`define IVECTOR_OFS11        10'h 058  //  0x58
`define IVECTOR_OFS12        10'h 060  //  0x60
`define IVECTOR_OFS13        10'h 068  //  0x68
`define IVECTOR_OFS14        10'h 070  //  0x70
`define IVECTOR_OFS15        10'h 078  //  0x78
`define IVECTOR_OFS16        10'h 080  //  0x80
`define IVECTOR_OFS17        10'h 088  //  0x88
`define IVECTOR_OFS18        10'h 090  //  0x90
`define IVECTOR_OFS19        10'h 098  //  0x98
`define IVECTOR_OFS20        10'h 0a0  //  0xa0
`define IVECTOR_OFS21        10'h 0a8  //  0xa8
`define IVECTOR_OFS22        10'h 0b0  //  0xb0
`define IVECTOR_OFS23        10'h 0b8  //  0xb8
`define IVECTOR_OFS24        10'h 0c0  //  0xc0
`define IVECTOR_OFS25        10'h 0c8  //  0xc8
`define IVECTOR_OFS26        10'h 0d0  //  0xd0
`define IVECTOR_OFS27        10'h 0d8  //  0xd8
`define IVECTOR_OFS28        10'h 0e0  //  0xe0
`define IVECTOR_OFS29        10'h 0e8  //  0xe8
`define IVECTOR_OFS30        10'h 0f0  //  0xf0
`define IVECTOR_OFS31        10'h 0f8  //  0xf8

`define INT_BASE_LSB         4'b 1010
`define INT_BASE_LSB_1       (`INT_BASE_LSB - 1'b 1)

// Define 32-bit Address Width
//
`define ADDRESS_WIDTH        6'b 100000
`define ADDRESS_MSB          (`ADDRESS_WIDTH - 1'b 1)

// ICCM FSM State Definitions
`define ICCM_IDLE            2'b 00
`define ICCM_ACTIVE          2'b 01
`define ICCM_HOLD            2'b 10
`define ICCM_STALL           2'b 11

// ICCM RAM Loader
`define NB_WRITE             4'b 1010  // 10 address
        
// ICCM  RAM Loader FSM states
`define ICCM_DMI_IDLE        2'b 00
`define ICCM_DMI_WRITE       2'b 01
`define ICCM_DMI_INC_ADDR    2'b 10
`define ICCM_DMI_DEASSERT    2'b 11

// MPU Offset Addressing
`define MPU_OFFSET_LSB     4'b 1101
`define MPU_ADDRESS_WIDTH  5'b 10011
`define MPU_ADDRESS_MSB    (`MPU_ADDRESS_WIDTH - 1'b 1)

// 32-bit constant values
// ======================

`define LZWORD             32'bZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ
`define LXWORD             32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
`define ZERO               32'b00000000000000000000000000000000
`define MINUS_ONE          32'b11111111111111111111111111111111
`define FOUR               32'b00000000000000000000000000000100
`define MINUS_FOUR         32'b11111111111111111111111111111100
// Nobody uses:
// `define ONE                32'b00000000000000000000000000000001
`define PLUS_ONE           32'b00000000000000000000000000000001
`define LOOPWORD_ONE       31'b0000000000000000000000000000001
`define LOOPWORD_TWO       31'b0000000000000000000000000000010

`define ONE_ZERO            1'b0
`define TWO_ZEROS           2'b00
`define THREE_ZEROS         3'b000
`define FOUR_ZEROS          4'b0000
`define FIVE_ZEROS          5'b00000
`define SIX_ZEROS           6'b000000
`define SEVEN_ZEROS         7'b0000000
`define EIGHT_ZEROS         8'b00000000
`define NINE_ZEROS          9'b000000000
`define TEN_ZEROS          10'b0000000000
`define ELEVEN_ZEROS       11'b00000000000
`define TWELVE_ZEROS       12'b000000000000
`define THIRTEEN_ZEROS     13'b0000000000000
`define FOURTEEN_ZEROS     14'b00000000000000
`define FIFTEEN_ZEROS      15'b000000000000000
`define SIXTEEN_ZEROS      16'b0000000000000000
`define SEVENTEEN_ZEROS    17'b00000000000000000
`define EIGHTEEN_ZEROS     18'b000000000000000000
`define NINETEEN_ZEROS     19'b0000000000000000000
`define TWENTY_ZEROS       20'b00000000000000000000
`define TWENTY_ONE_ZEROS   21'b000000000000000000000
`define TWENTY_TWO_ZEROS   22'b0000000000000000000000
`define TWENTY_THREE_ZEROS 23'b00000000000000000000000
`define TWENTY_FOUR_ZEROS  24'b000000000000000000000000
`define TWENTY_FIVE_ZEROS  25'b0000000000000000000000000
`define TWENTY_SIX_ZEROS   26'b00000000000000000000000000
`define TWENTY_SEVEN_ZEROS 27'b000000000000000000000000000
`define TWENTY_EIGHT_ZEROS 28'b0000000000000000000000000000
`define TWENTY_NINE_ZEROS  29'b00000000000000000000000000000
`define THIRTY_ZEROS       30'b000000000000000000000000000000
`define THIRTY_ONE_ZEROS   31'b0000000000000000000000000000000
`define THIRTY_TWO_ZEROS   32'b00000000000000000000000000000000

// Additional defines are inserted below.
//
// DDR2 controller  defines
// ac_ddr2_controller defines

`define LOCIF_DATA_WIDTH 128
`define LOCIF_MASK_WIDTH 16
`define LOCIF_ADDR_WIDTH 31
`define LOCIF_CMD_WIDTH 3
`define BVCI_DATA_WIDTH 64
`define BVCI_BE_WIDTH 8
`define BVCI_BE_HFWIDTH (`BVCI_BE_WIDTH/2)
`define CMD_FIFO_WIDTH  (2+`BVCI_PLEN_WIDTH+`BVCI_CMD_WIDTH+`BVCI_ADDR_WIDTH)
`define WR_FIFO_WIDTH  (1+`BVCI_BE_WIDTH+`BVCI_DATA_WIDTH)
`define WR_FIFO_PTR 4
`define RD_FIFO_WIDTH 64
`define RD_FIFO_PTR 4
`define FIFO_DEPTH 8
`define BVCI_ADDR_WIDTH 32
`define BVCI_ADDR_3LSB 3
//`define BVCI_CMD_WIDTH 2
`define BVCI_PLEN_WIDTH 9

`define STATE_WIDTH 2
`define COUNT_WIDTH 6
`define CMD_COUNT_WIDTH 5
`define ALIEN_16BYTE  4

// ac_ddr2_bridge defines

`define BYTED 8
`define BEN_ZERO 12
//`define RD_FIFO_WIDTH 64
`define DATA_HOLD_REG_WT 146

`define E_FIFO_FWD_MSB 31
`define E_FIFO_SWD_LSB 32
`define E_FIFO_SWD_MSB 63
`define E_FIFO_FBE_LSB 128
`define E_FIFO_FBE_MSB 131
`define E_FIFO_SBE_LSB 132
`define E_FIFO_SBE_MSB 135
`define E_FIFO_EOP 144

`define O_FIFO_FWD_LSB 64
`define O_FIFO_FWD_MSB 95
`define O_FIFO_SWD_LSB 96
`define O_FIFO_SWD_MSB 127
`define O_FIFO_FBE_LSB 136
`define O_FIFO_FBE_MSB 139
`define O_FIFO_SBE_LSB 140
`define O_FIFO_SBE_MSB 143
`define O_FIFO_EOP 145
//`define ADDR_WIDTH 32
`define BE_WIDTH 4
`define CMD_WIDTH 2
`define PLEN_WIDTH 9
`define STATE 3
// No one uses:
// `define CNT_WIDTH 8
`define WFIFO_NO_FILL_WT 4
`define RFIFO_NO_FILL_WT 4
`define RESPFIFO_NO_FILL_WT 3
`define RESP_FIFO_WIDTH 20
`define STATE_MACHINE 2
`define READ_HOLD_REG_WT 128
`define NINE 9
`define RSP_STATE 2
`define SIXB 6
`define FIVE 5
`define FOUR1 4
`define THREE 3
`define TWOB 2
`define BVCI_WIDTH 32




