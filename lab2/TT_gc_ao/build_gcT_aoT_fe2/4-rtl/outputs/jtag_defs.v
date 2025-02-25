// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 2004-2012 ARC International (Unpublished)
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
//-----------------------------------------------------------------------
// JTAG Port constant definitions
// =====================================
//
// This file contains the macro definitions used by the JTAG port.
//
//  the following section contains constant definitions for cycle delays
//  used by the JTAG accessing procedures.
`define FOR_ONE_CYCLE 1     //  wait for one jtag clock cycles
`define FOR_TWO_CYCLES 2    //  wait for two jtag clock cycles
`define FOR_THREE_CYCLES 3  //  wait for three jtag clock cycles
`define FOR_FOUR_CYCLES 4   //  wait for four jtag clock cycles
`define FOR_FIVE_CYCLES 5   //  wait for five jtag clock cycles

//  The following section contains constant definitions for the flags bits
//  that are used to control the TAP controller.
`define JF_RESET_TAP_CT 1     //  flag to reset the tap controller
`define JF_TLR_WRITE_IR 2     //  flag to write IR from the reset state
`define JF_TLR_WRITE_DR 4     //  flag to write DR from the reset state
`define JF_SDS_WRITE_IR 8     //  flag to write IR from Select-DR-Scan
`define JF_SDS_WRITE_DR 16    //  flag to write DR from Select-DR-Scan
`define JF_END_RUNTESTIDLE 32 //  flag to force the TAP to the IDLE state
`define JF_END_BYPASS_IDLE 64 //  flag to force the TAP to Select-DR-Scan
`define JF_STEP_TMS_HIGH 128  //  flag to step the TAP controller on TMS = 1
`define JF_STEP_TMS_LOW 256   //  flag to step the TAP controller on TMS = 0
`define JF_CAPTURE_TDO 512    //  unused  

//  These define the JTAG "instructions"
`define JTAG_BSR_REG 4'h0
`define JTAG_EXTEST_REG 4'h1
`define JTAG_UNUSED_REG0 4'h2
`define JTAG_UNUSED_REG1 4'h3
`define JTAG_UNUSED_REG2 4'h4
`define JTAG_UNUSED_REG3 4'h5
`define JTAG_UNUSED_REG4 4'h6
`define JTAG_UNUSED_REG5 4'h7
`define JTAG_STATUS_REG 4'h8
`define JTAG_TRANSACTION_CMD_REG 4'h9
`define JTAG_ADDRESS_REG 4'hA
`define JTAG_DATA_REG 4'hB
`define JTAG_IDCODE_REG 4'hC
`define JTAG_UNUSED_REG6 4'hD
`define JTAG_UNUSED_REG7 4'hE
`define JTAG_BYPASS_REG 4'hF

//  These are the lengths of the registers
`define JTAG_INSTRUCTION_REG_LEN 4

`define JTAG_BSR_REG_LEN 32
`define JTAG_STATUS_REG_LEN 7
`define JTAG_TRANSACTION_CMD_REG_LEN 4
`define JTAG_ADDRESS_REG_LEN 32
`define JTAG_DATA_REG_LEN 32
`define JTAG_IDCODE_REG_LEN 32
`define JTAG_BYPASS_REG_LEN 1

//  These are the status register bits
`define JTAG_STATUS_STALLED 0
`define JTAG_STATUS_FAILURE 1
`define JTAG_STATUS_READY 2
`define JTAG_STATUS_PC_SEL 3

//  These are constants for the transaction command register
`define CMD_WRITE_CORE 4'h1
`define CMD_READ_CORE 4'h5
`define CMD_WRITE_AUX 4'h2
`define CMD_READ_AUX 4'h6
`define CMD_WRITE_MEM 4'h0
`define CMD_READ_MEM 4'h4
`define CMD_WRITE_MADI 4'h7
`define CMD_READ_MADI 4'h8
`define CMD_NOP 4'h3

//  These are the expected values of the register upon initialization
`define JTAG_STATUS_REG_INIT 4'b1100 // pc | rd | ~fl | ~st
`define JTAG_TRANSACTION_CMD_REG_INIT `CMD_NOP
`define JTAG_ADDRESS_REG_INIT 32'h0000_0000
`define JTAG_DATA_REG_INIT 32'h0000_0000

// The following constants are used to identify the JTAG model version as
// well as the ARC manufacturing code and the procesor number This is the
// IDCODE value, broken into fields
// As this file is constant, the values for ARC_TYPE and JTAG_VERSION
// aren't supplied.  If you are a client of this file, you must provide them.
// For ARC-specific code they are found inserted in extutil.v.
// JTAG_VERSION is constant across all cores so is provided here.
`define JTAG_VERSION 4'b0010	// JTAG port version
`define ARC_TYPE `ARC_TYPE_ARC600
`define ARC_TYPE_A4 6'b00_0000      // code for ARCtangent-A4
`define ARC_TYPE_A5 6'b00_0001      // code for ARCtangent-A5
`define ARC_TYPE_ARC600 6'b00_0010  // code for ARC 600
`define ARC_TYPE_ARC700 6'b00_0011  // code for ARC 700
`define ARC_JEDEC_CODE 11'b0100_101_1000 // JEDEC code 0x58, bank 5; ARC's
`define JTAG_IDCODE_REG_INIT {`JTAG_VERSION, `TWO_ZEROS, `ARCNUM, `ARC_TYPE, `ARC_JEDEC_CODE, 1'b1}

`define UNUSED_JEDEC_CODE 11'b0000_111_1111 // JEDEC code guaranteed unused
`define DISCOVER_IDCODE { 20'h0_0000, `UNUSED_JEDEC_CODE, 1'b1 }

//  For maximum simulation speed, set these to half the system clock speed
`define TCK_CLOCK_PERIOD 100
`define DELAY_ON_TDO (`TCK_CLOCK_PERIOD / 4)
`define TCK_HALF_PERIOD (`TCK_CLOCK_PERIOD / 2)
`define TCK_HALF_PERIOD_TDO (`TCK_CLOCK_PERIOD / 2 - `DELAY_ON_TDO)

//  BVCI command constants
`define BVCI_CMD_NOP 2'b00
`define BVCI_CMD_READ 2'b01
`define BVCI_CMD_WRITE 2'b10
`define BVCI_CMD_LOCKED_READ 2'b11

//  These constants define the addresses to which the module will respond
//  on the BVCI interface. BASE_ADDRESS is the constant to change in order
//  to make the whole module respond at a different set of addresses.
`define BASE_ADDRESS 32'hffff0000
`define ADDR_SIZE 5 //  # of reg selector bits
`define BASE_ADDR `BASE_ADDRESS >> `ADDR_SIZE

//  Individual register addresses, offset from BASE_ADDRESS. These
//  represent longword addresses, so the two least-significant bits are
//  assumed to be zero.
`define STATUS_R_ADDR 3'b000
`define DO_CMD_ADDR 3'b000
`define COMMAND_R_ADDR 3'b001
`define ADDRESS_R_ADDR 3'b010
`define DATA_R_ADDR 3'b011
`define RESET_ADDR 3'b100

//  the following constants are used to increment the Address register
//  (used for down/uploading streams of data to/from memory or the ARC
//  registers).
`define MEM_OFFSET 32'h00000004
`define REG_OFFSET 32'h00000001

//  The following constants define the lower 2 bits of the Transaction
//  Command register. These bits are used to define the type of transaction
//  access that is required. Currently there are only three types of
//  transactions that can be performed, an access to memory or an access to
//  the ARC`s auxiliary or core register space.
`define CMD_MEM 2'b00  //  memory
`define CMD_CORE 2'b01 //  core regs
`define CMD_AUX 2'b10  //  aux regs

//  The following constants define the upper 2 bits of the command register.
//  The two bits (1 bit really) define whether a read or write type
//  transaction is to be performed.
`define CMD_READ 2'b01
//`define CMD_WRITE 2'b00

//  The following constants define the actual transactions that the module
//  can perform. There are a total of 6 commands that can be executed.
`define CMD_RD_MEM 4'b0100      //  read lword from memory
`define CMD_WR_MEM 4'b0000      //  write lword to memory
`define CMD_RD_AUX 4'b0110      //  read lword from auxiliary
`define CMD_WR_AUX 4'b0010      //  write lword to auxiliary
`define CMD_RD_CORE 4'b0101     //  read lword from core
`define CMD_WR_CORE 4'b0001     //  write lword to core
`define CMD_RD_MADI 4'b1000     //  read lword from madi (deprecated)
`define CMD_WR_MADI 4'b0111     //  write lword to madi (deprecated)
`define CMD_RESET_VALUE 4'b0011 //  reset value

// This defines whether or not the address increments after a successful
// transaction, as it does on the A3 through ARC 600, or does not, as is
// the case with versions of ARC 700 before r3.
`define HAS_ADDRESS_AUTO_INCREMENT 1'b0

//  The following constants define the instruction codes for all internal
//  data registers. These codes should be written into the instruction
//  register in order to access the required data register. The codes for
//  EXTEST and SAMPLE are instructions that are reserved for use with
//  a Boundary Scan Register.
`define IR_EXTEST 4'b0000   //  Reserved for a BSR
`define IR_SAMPLE 4'b0001   //  Reserved for a BSR
`define IR_UNUSED0 4'b0010  //  Unused, acts as bypass
`define IR_UNUSED1 4'b0011  //  Unused, acts as bypass
`define IR_UNUSED2 4'b0100  //  Unused, acts as bypass
`define IR_UNUSED3 4'b0101  //  Unused, acts as bypass
`define IR_UNUSED4 4'b0110  //  Unused, acts as bypass
`define IR_UNUSED5 4'b0111  //  Unused, acts as bypass
`define IR_STATUS 4'b1000   //  The Status register (4 bits)
`define IR_COMMAND 4'b1001  //  The Command register (4 bits)
`define IR_ADDRESS 4'b1010  //  The Address register (32 bits)
`define IR_DATA 4'b1011     //  The Data register (32 bits)
`define IR_IDCODE 4'b1100   //  The IDCODE register (32 bits)
`define IR_UNUSED6 4'b1101  //  Unused, acts as bypass
`define IR_UNUSED7 4'b1110  //  Unused, acts as bypass
`define IR_BYPASS 4'b1111   //  Bypass (1 bit register)

`define IR_INIT 4'b0001     //  IR always set to this in Capture-IR, thus
                            //  allowing a stuck-at fault to be detected
                            //  per the JTAG spec

//   The following constants are used to select bit fields from the shift
//   register.  These constants are used when updating a data register,
//   since all the data registers are not the same bit width as the shift
//   register.  These constants have been included to improve readability.
`define SREG_SIZE 6'b 100000 // Shift register is 32 bits wide for most things
`define SREG_MSB (`SREG_SIZE - 1'b 1)
`define JTAG_CMD_SIZE 3'b 100 // Command regs are 4-bits wide
`define JTAG_CMD_MSB (`JTAG_CMD_SIZE - 1'b 1)
`define JTAG_STATUS_SIZE 3'b 111 // status regs are 6 or 7 bits wide
`define JTAG_STATUS_MSB (`JTAG_STATUS_SIZE - 1'b 1)

// Max number of JTAG controllers we support in a chain
`define MAX_PROCESSORS 32

//  The following types are enumurated for the state machine of the debug
//  port. Refer to the appropriate section for an in-depth explanation of
//  these states.
// TYPE fsm_state_tsm:
`define S_RST       0
`define S_IDLE      1
`define S_MR_RQ     2
`define S_MR_WAIT   3
`define S_MW_RQ     4
`define S_MW_WAIT   5
`define S_ARC_READ  6
`define S_ARC_READ2 7
`define S_AR_STALL  8
`define S_ARC_WRITE 9
`define S_AW_STALL 10
`define S_WAIT_H   11
//-----------------------------------------------------------------------

