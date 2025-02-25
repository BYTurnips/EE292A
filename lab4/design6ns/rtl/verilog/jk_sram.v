// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 1996-2008 ARC International (Unpublished)
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
// A generic module for a typical SRAM with complete timing
// parameters.
//

`include "board_pkg_defines.v"
`include "arc600constants.v"

module jk_sram (
    nCE,  // low-active Chip-Enable of the SRAM device
    nOE,  // low-active Output-Enable of the SRAM device
    nWE,  // low-active Write-Enable of the SRAM device
    A,    // address bus of the SRAM device
    D,    // bidirectional data bus to/from the SRAM device
    CE2   // high-active Chip-Enable of the SRAM device
);

`include "ext_msb.v"

input        nCE;
input        nOE;
input [3:0]  nWE;
input [EXT_A_MSB:2] A;
inout [31:0] D;
input        CE2;

reg   [31:0] D_out;

parameter INIT_FILE = "init_mem.hex";                                           
parameter CLEAR_ON_POWER_UP = `TRUE;          //if TRUE, RAM is initialized with zeroes at start of simulation
parameter DOWNLOAD_ON_POWER_UP = `TRUE;       //if TRUE, RAM is downloaded at start of simulation 
parameter MEMORY_SIZE = 4194304;           //number of memory words
parameter ADDRESS_WIDTH = 22;                 //Address bus width
parameter MEMORY_MODEL_NUM = 0;               //Identifies which ARC memory model this RAM model is associated  
parameter BASE_ADDRESS = 32'h 00000000;       //tells at what address this ram starts at
parameter options = 0 + 8;  // Configure SRAM's hex-reader in little-endian mode.


`ifndef TTVTOC
reg  [3:0] inWE;
`endif

`ifdef TTVTOC
always @(*)
`else
initial
`endif
begin
$jk_sram
(
    "init_mem.hex",        // download_filename
    CLEAR_ON_POWER_UP,     // clear_on_power_up    -- if TRUE, RAM is initialized with zeroes at start of simulation
                           //                         Clearing of RAM is carried out before download takes place
    DOWNLOAD_ON_POWER_UP,  // download_on_power_up -- if TRUE, RAM is downloaded at start of simulation
    BASE_ADDRESS,
    MEMORY_SIZE,
    ADDRESS_WIDTH,
    MEMORY_MODEL_NUM,
    nCE,
    nOE,
`ifdef TTVTOC    
    nWE,
`else
    inWE,
`endif        
    A,
    D,
    CE2,
    D_out,
    options
);
end

`ifndef TTVTOC
always @(nWE)
begin
       #(0.1) inWE = nWE;
       #(0.1) inWE = 4'b1111; 
end
`endif


assign D = (nOE == 1'b 0) ? D_out : 32'b z;

endmodule
