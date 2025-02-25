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
// This file contains all the constant declarations for opcodes
// (single or dual operand user extension instructions) , addresses
// of extension registers (core or auxiliary) used by the extension
// instructions, and user extended condition codes. User defined
// constants.
// 

//==================== EXTENSION INSTRUCTION CODES ===================//

// The opcode for a dual operand instruction is 5-bit wide, however the 
// spaces for extension instructions are from 16 to 32 and subject to 
// availability due to the limited slots. Opcode of "00011" is used to
// indicate a single operand instruction, and the operand2 field is used
// to identify the instruction. Free slots from 9 to 64 are available to
// the users.

// Standard Opcodes:

// Single Operand:

// Zero Operand:

//==================== EXTENSION CONDITION CODES =====================//
//
// Condition code is 4-bit wide, hence 16 slots are available to users
//

//=================== EXTENSION CORE REGISTERS =======================//
//
// This section contains the addresses of extension core registers
//

//================ EXTENSION AUXILIARY REGISTERS =====================//
//
// This section contains the addresses of extension auxiliary registers
//

//======================= MISCELLANEOUS ==============================//
//
// This section contains extra constant decalarations used by extension
// instructions
//

