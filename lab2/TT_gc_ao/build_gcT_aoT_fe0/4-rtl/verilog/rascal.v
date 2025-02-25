// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 2000-2012 ARC International (Unpublished)
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
// Rascal 'C' interface to Verilog
//
// This block instantiates the RASCAL Controller, which controls the
// simulator and the IOs of this module.
//
//======================= Inputs to this block =======================--
//
//  ra_ck           :1  Clock input to RASCAL controller, the
//                      controller synchronises to this clock.
//                      This clock can change it's source or
//                      frequency whenever desired.
//
//  ra_ack          :1  Acknowledges that either the data is valid
//                      for a read, or that data has been consumed
//                      for a write.
//
//  ra_rd_data      :32 Read data bus.
//
//  ra_fail         :1  Set if transaction request
//                      is invalid, or the transaction will
//                      not be able to complete.
//
//====================== Output from this block ======================--
//
//  ra_select       :2  Selects between a register access or
//                      a memory access or a madi access.
//
//  ra_read         :1  Set when a read request is required.
//                      (burst and addr must also be valid).
//
//  ra_write        :1  Set when a write request is required.
//                      (burst, addr and data must be valid).
//
//  ra_burst        :10 Burst size in lwords (max = 2kb). Must
//                      be valid when a read/write request is 
//                      valid  
//                      N.B This is just an initial guess at a 
//                      resonable size, it can be changed later
//                      if required. 
//          
//  ra_addr         :32 Base address (lword) of transfer request. Must be
//                      valid when read/write request is valid.
//
//  ra_wr_data      :32 Write data bus, stays valid until ra_ack
//                      is recieved.
//
//====================================================================--
//
module rascal (
   ra_ck,
   ra_ack,
   ra_rd_data,
   ra_fail,

   ra_select,
   ra_read,
   ra_write,
   ra_burst,
   ra_addr,
   ra_wr_data);

input   ra_ck; 
input   ra_ack; 
input   [31:0] ra_rd_data; 
input   [1:0] ra_fail; 

output  [1:0] ra_select; 
output  ra_read; 
output  ra_write; 
output  [9:0] ra_burst; 
output  [31:0] ra_addr; 
output  [31:0] ra_wr_data; 

reg  [1:0] ra_select; 
reg  ra_read; 
reg  ra_write; 
reg  [9:0] ra_burst; 
reg  [31:0] ra_addr; 
reg  [31:0] ra_wr_data; 

initial $rascal
(
    ra_ck,
    ra_ack,
    ra_rd_data,
    ra_fail,

    ra_select,
    ra_read,
    ra_write,
    ra_burst,
    ra_addr,
    ra_wr_data
);

endmodule // module rascal
