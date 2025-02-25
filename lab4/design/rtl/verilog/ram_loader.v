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
// If you want to load the code RAM and/or LD/ST RAM by an on-chip
// module then this mechanism should be implemented in this module. One
// example of this is a boot loader, i.e. a module that loads a RAM 
// directly after reset. If you wish to implement a boot loader then 
// make sure that the request signal from this module (either 
// code_dmi_req or ldst_dmi_req) is set on the cycle after reset. This 
// guarantees that the RAM will be loaded before the processor or the 
// debug port can access it.
// 
// ======================= Inputs to this block ======================--
//
// clk_in         Global ungated clock.
//
// rst_n_a        Global Reset (active low).
//
// code_dmi_rdata Read data from the code RAM Direct Memory Interface.
//
// ldst_dmi_rdata Read data from the LD/ST RAM Direct Memory Interface.
//
// ====================== Outputs from this block ====================--
//
// code_dmi_req   Memory request to the code RAM. When set this module
//                has immediate direct access to the code RAM. The
//                other code RAM interfaces (instruction fetch and data
//                memory pipeline) are held off, as they have lower
//                priority. During a single access, several reads and
//                writes can be performed. Access ends when
//                code_dmi_req is again set low.
//
// code_dmi_addr  The address for the code RAM Direct Memory Interface.
//
// code_dmi_wdata The write data bus for the code RAM Direct Memory
//                Interface.
//
// code_dmi_wr    The write enable for the code RAM Direct Memory
//                Interface. Set means write and clear means read.
//
// code_dmi_be    The byte enables on the code RAM Direct Memory
//                Interface. There are four byte enables, one for each
//                byte lane. The byte enable bus is little endian.
//                Byte enables are only used during write operations.
//                During read operations the whole longword always
//                returns.
//

// ldst_dmi_req   The memory request to the LD/ST RAM. When set the RAM
//                loader has immediate direct access to the LD/ST RAM.
//                The other interface to the LD/ST RAM (the data memory
//                pipeline interface) is held off, as it has lower
//                priority. During a single access several reads and
//                writes can be performed. Access ends when this signal
//                is again set low.
//
// ldst_dmi_addr  The address signal for the LD/ST RAM Direct Memory
//                Interface.
//
// ldst_dmi_wdata The write data bus for the LD/ST RAM Direct Memory
//                Interface.
//
// ldst_dmi_wr    The write enable for the LD/ST RAM Direct Memory
//                Interface. Set means write and clear means read.
//
// ldst_dmi_be    The byte enables on the LD/ST RAM Direct Memory
//                Interface. There are four byte enables, one for each
//                byte lane. The byte enable bus is little endian.
//                Byte enables are only used during write operations.
//                During read operations the whole longword always
//                returns.
//
// ===================================================================--
//
module ram_loader (clk_in,
  rst_n_a,

  code_dmi_rdata,
  code_dmi_req,
  code_dmi_addr,
  code_dmi_wdata,
  code_dmi_wr,
  code_dmi_be,
  ldst_dmi_rdata,
  ldst_dmi_req,
  ldst_dmi_addr,
  ldst_dmi_wdata,
  ldst_dmi_wr,
  ldst_dmi_be,

  en);

`include "arcutil_pkg_defines.v"
`include "extutil.v"
`include "che_util.v"
`include "xdefs.v"

input   clk_in; 
input   rst_n_a; 

// Global halt signal
//
input   en; 

// ICCM RAM DMI interface
// 
input  [31:0] code_dmi_rdata ;
// 
output code_dmi_req;
output [31:0] code_dmi_addr;
output [31:0] code_dmi_wdata;
output code_dmi_wr;
output [3:0] code_dmi_be;

// DCCM RAM DMI interface
//
input   [31:0] ldst_dmi_rdata;
//
output  ldst_dmi_req;
output  [31:0] ldst_dmi_addr;
output  [31:0] ldst_dmi_wdata;
output  ldst_dmi_wr;
output  [3:0] ldst_dmi_be;


assign code_dmi_req   = 1'b 0;
assign code_dmi_wr    = 1'b 0;
assign code_dmi_addr  = {(32){1'b 0}};
assign code_dmi_wdata = {(32){1'b 0}};
assign code_dmi_be    = {4{1'b 0}};


//  DCCM RAM DMI interface
// 
assign ldst_dmi_req   = 1'b 0;
assign ldst_dmi_wr    = 1'b 0;
assign ldst_dmi_addr  = {32{1'b 0}};
assign ldst_dmi_wdata = {32{1'b 0}};
assign ldst_dmi_be    = {4 {1'b 0}};

endmodule
