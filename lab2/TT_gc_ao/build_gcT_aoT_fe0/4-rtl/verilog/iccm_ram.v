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
// The code RAM is instantiated in this file. It has 4 byte
// enables and and 4 clock enables. If your chosen RAM type does
// not have byte enables you need to instantiate 4 byte wide RAM's
// instead. If you only intend to access whole longwords in code
// RAM then byte enables are not necessary. If this is the case,
// it is sufficient to instantiate a single RAM without byte
// enables.
// 
module iccm_ram (
   clk_ungated,
   code_ram_addr,
   code_ram_wdata,
   code_ram_wr,
   code_ram_be,
   code_ram_ck_en,

   code_ram_rdata);

`include "arcutil_pkg_defines.v"
`include "extutil.v"
`include "che_util.v"

input   clk_ungated; 
input   [CODE_RAM_ADDR_MSB-CODE_RAM_ADDR_LSB:0] code_ram_addr; 
input   [31:0] code_ram_wdata; 
input   code_ram_wr; 
input   [3:0] code_ram_be; 
input   code_ram_ck_en; 
output  [31:0] code_ram_rdata;
 
wire    [31:0] code_ram_rdata; 
wire    [31:0] i_wdata; 
wire    [31:0] i_rdata; 
wire    [CODE_RAM_ADDR_MSB:CODE_RAM_ADDR_LSB] i_address; 
wire    [3:0] i_we; 
wire    [3:0] i_ck_en; 

//  Assign write data and address
// 
assign i_wdata   = code_ram_wdata; 
assign i_address = code_ram_addr; 

//  Write enables for each RAM (i.e. for each byte)
// 
assign i_we[3] = ((code_ram_wr == CODE_WR_ACTIVE) & 
                  (code_ram_be[3] == 1'b 1)) ? CODE_WR_ACTIVE : 
    CODE_RE_ACTIVE; 

assign i_we[2] = ((code_ram_wr == CODE_WR_ACTIVE) & 
                  (code_ram_be[2] == 1'b 1)) ? CODE_WR_ACTIVE : 
    CODE_RE_ACTIVE; 

assign i_we[1] = ((code_ram_wr == CODE_WR_ACTIVE) & 
                  (code_ram_be[1] == 1'b 1)) ? CODE_WR_ACTIVE : 
    CODE_RE_ACTIVE; 

assign i_we[0] = ((code_ram_wr == CODE_WR_ACTIVE) & 
                  (code_ram_be[0] == 1'b 1)) ? CODE_WR_ACTIVE : 
    CODE_RE_ACTIVE; 

//  Clock enables for each RAM (i.e. for each byte)
// 
assign i_ck_en[3] = ((code_ram_ck_en == CODE_CK_EN_ACTIVE) & 
                     (code_ram_be[3] == 1'b 1)) ? CODE_CK_EN_ACTIVE : 
    ~CODE_CK_EN_ACTIVE; 

assign i_ck_en[2] = ((code_ram_ck_en == CODE_CK_EN_ACTIVE) & 
                     (code_ram_be[2] == 1'b 1)) ? CODE_CK_EN_ACTIVE : 
    ~CODE_CK_EN_ACTIVE; 

assign i_ck_en[1] = ((code_ram_ck_en == CODE_CK_EN_ACTIVE) & 
                     (code_ram_be[1] == 1'b 1)) ? CODE_CK_EN_ACTIVE : 
    ~CODE_CK_EN_ACTIVE; 

assign i_ck_en[0] = ((code_ram_ck_en == CODE_CK_EN_ACTIVE) & 
                     (code_ram_be[0] == 1'b 1)) ? CODE_CK_EN_ACTIVE : 
    ~CODE_CK_EN_ACTIVE; 

assign code_ram_rdata = i_rdata; 

//  Instantiation of RAM
// 
//  Note that the fake RAM cells have
// 
//       * No capacitance
//       * Infinite drive capacity
// 
//  and hence timings should be taken with a pinch of salt.
// 
//  The clock enable signal turns off the RAM ports when not in use
//  to save power. Depending on technology, this may cause time 
//  delays on the critical path. If this is the case and this is not 
//  acceptable, don't connect this signal to the instantiation 
//  of the real RAM.
// 
//  If input signals, we and ck_en, of the real RAM are not active
//  low, as they are for the fake RAM, do not insert an inverter! 
//  Instead, change the code RAM constants in extutil.
// 


fake_iccm U_fake_iccm (.clk(clk_ungated),
                      .address(i_address),
                      .wr_data(i_wdata),
                      .we(i_we),
                      .ck_en(i_ck_en),
                      .rd_data(i_rdata));


endmodule

