// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 2003-2007 ARC International (Unpublished)
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
// ARC Product:  ARC MSS v1.7.12
// File version:  MSS IP Library version 1.7.12, file revision 
// ARC Chip ID:  0
//
// Description:
// 

`define false 1'b 0
`define FALSE 1'b 0
`define true 1'b 1
`define TRUE 1'b 1

module syncsram_wd(
  ck,
  ce_n,	// low-active chip-enable
  we_n, // low-active write-enable (vs read)
  bw_n, // low-active byte-enables for write
  addr,
  din,
  dout
  );

// These are the default memory parameters that will often be overwritten by the module
// in which sycsram_wd is instantiated.
//
parameter INIT_FILE = "init_mem.hex";
parameter CLEAR_ON_POWER_UP = `TRUE;     // If TRUE, RAM is initialized with zeroes at start of simulation.
parameter DOWNLOAD_ON_POWER_UP = `TRUE;  // If TRUE, RAM is downloaded at start of simulation (after clear).
parameter BASE_ADDRESS = 32'h00000000;   // Tells at what address this ram starts at, in multiples of DATA_WIDTH.
parameter MEMORY_SIZE = 512*1024;        // Number of memory units each DATA_WIDTH in size.
parameter ADDRESS_WIDTH = 32;            // Address bus width.
parameter MEMORY_MODEL_NUM = 0;          // Identifies which ARC memory model this RAM model is associated  .

parameter DATA_WIDTH = 64;
parameter DATA_MSB = DATA_WIDTH-1;
parameter BWE_WIDTH = 8;
parameter BWE_MSB = BWE_WIDTH-1;
parameter options = 0
                  ;
   
input  ck, ce_n, we_n;
input  [BWE_MSB:0]  bw_n;
input  [31:0] addr;
input  [DATA_MSB:0] din;
output [DATA_MSB:0] dout;
reg    [DATA_MSB:0] dout;


`ifdef TTVTOC
 always @(posedge ck)
`else   
 initial
 `endif
 begin
  $ssramwd (
    "init_mem.hex",
    CLEAR_ON_POWER_UP,
    DOWNLOAD_ON_POWER_UP,
    BASE_ADDRESS,
    MEMORY_SIZE,
    ADDRESS_WIDTH,
    MEMORY_MODEL_NUM,
    ck,
    ce_n,
    we_n,
    bw_n,
    addr,
    din,
    dout,
    options
   );
 end

endmodule
