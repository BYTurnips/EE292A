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
// This file includes the file that contains the global defines which 
// specify field widths, bit positions, instruction encoding and global
// functions for the ARC 600, and has within it the fields that
// are different on a per-CPU basis.

`include "arc600constants.v"

// ARC basecase version number : used in the identity register --
// 
// 0x12 : ARCompact processor version 2.
// 0x13 : Barrel shifter is standard.
// 0x21 : ARC600 processor version 1.
// 0x22 : BCR space updated to include 0x60 -> 0x7F & 0xC0 -> 0xFF.
//        Returns zero for an aux read in BCR space when extension
//        is not present or location is unused.
// 0x23 : Updated the ISA so that 32-bit instructions now exist in
//        slot 0x00 to 0x0B.
// 0x24 : Added SYNC instruction and 'ctrl_cpu_start' pin to allow
//        the core to be started from halt.
// 
`define ARCVER             8'h 26

// Number of the processor.
//
`define ARCNUM             8'h 01

// Actionpoints in Debug Register
//
`define DEBUG_AP_LSB         3'b 11
`define DEBUG_AP_MSB         (8'h 2 + 2'b 10)
// Interrupt register bit fields
//
// The base address of the vector map is manually configurable here.
// By default it is 0x0 for backward compatibility but can be set to
// any memory address by the user.
// All the exception and interrupt vectors must be placed sequentially
// upwards from the base address.
//
// A different base address might be desirable for instance if the bottom
// of the memory address space maps to ROM. Note that the vector table
// for the basecase is from the range base+0x00 upto base+0x80 and the
// vector table for the extended interrupts is from the range base+0x00
// up to base+0x100. So if the vector map is placed near the upper limit
// of the memory range then sufficent space must be left for the table
// (i.e. [topAddress] - 0x80 for basecase and [TopAddress] - 0x100 for
// the extended system.
//
//  The interrupt vectors as 32-bit quantities:
// 
`define IVECTOR0             32'h 00000000  //  0x00
`define IVECTOR0_PC          31'h 00000000
`define IVECTOR0_PC1         30'h 00000000
`define IVECTOR1             32'h 00000008 + IVECTOR0 //  0x08 
`define IVECTOR2             32'h 00000010 + IVECTOR0 //  0x10
`define IVECTOR3             32'h 00000018 + IVECTOR0 //  0x18
`define IVECTOR4             32'h 00000020 + IVECTOR0 //  0x20 
`define IVECTOR5             32'h 00000028 + IVECTOR0 //  0x28 
`define IVECTOR6             32'h 00000030 + IVECTOR0 //  0x30 
`define IVECTOR7             32'h 00000038 + IVECTOR0 //  0x38 
`define IVECTOR8             32'h 00000040 + IVECTOR0 //  0x40
`define IVECTOR9             32'h 00000048 + IVECTOR0 //  0x48
`define IVECTOR10            32'h 00000050 + IVECTOR0 //  0x50
`define IVECTOR11            32'h 00000058 + IVECTOR0 //  0x58
`define IVECTOR12            32'h 00000060 + IVECTOR0 //  0x60
`define IVECTOR13            32'h 00000068 + IVECTOR0 //  0x68
`define IVECTOR14            32'h 00000070 + IVECTOR0 //  0x70
`define IVECTOR15            32'h 00000078 + IVECTOR0 //  0x78
`define IVECTOR16            32'h 00000080 + IVECTOR0 //  0x80
`define IVECTOR17            32'h 00000088 + IVECTOR0 //  0x88
`define IVECTOR18            32'h 00000090 + IVECTOR0 //  0x90
`define IVECTOR19            32'h 00000098 + IVECTOR0 //  0x98
`define IVECTOR20            32'h 000000a0 + IVECTOR0 //  0xa0
`define IVECTOR21            32'h 000000a8 + IVECTOR0 //  0xa8
`define IVECTOR22            32'h 000000b0 + IVECTOR0 //  0xb0
`define IVECTOR23            32'h 000000b8 + IVECTOR0 //  0xb8
`define IVECTOR24            32'h 000000c0 + IVECTOR0 //  0xc0
`define IVECTOR25            32'h 000000c8 + IVECTOR0 //  0xc8
`define IVECTOR26            32'h 000000d0 + IVECTOR0 //  0xd0
`define IVECTOR27            32'h 000000d8 + IVECTOR0 //  0xd8
`define IVECTOR28            32'h 000000e0 + IVECTOR0 //  0xe0
`define IVECTOR29            32'h 000000e8 + IVECTOR0 //  0xe8
`define IVECTOR30            32'h 000000f0 + IVECTOR0 //  0xf0
`define IVECTOR31            32'h 000000f8 + IVECTOR0 //  0xf8

`define LNGWD_BOUNDARY 2'b 00
`define WD_BOUNDARY0   2'b 00
`define WD_BOUNDARY1   2'b 10

