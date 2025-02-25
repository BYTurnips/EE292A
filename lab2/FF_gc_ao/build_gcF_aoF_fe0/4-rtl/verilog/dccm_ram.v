// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 1996-2012 ARC International (Unpublished)
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
// LD/ST RAM wrapper.
// 
// The fake RAM model used here has 4 byte enables. If byte 
// enables do not exist in your chosen technology, replace the 
// fake RAM model with four separate RAM's.
// 

module dccm_ram (clk_ungated,
                 ldst_addr,
                 ldst_din,
                 ldst_mask,
                 ldst_wren,
                 ldst_ck_en,

                 ldst_dout);

`include "arcutil_pkg_defines.v"
`include "extutil.v"
`include "xdefs.v"

input   clk_ungated; 
input   [LDST_A_MSB:0] ldst_addr; 
input   [31:0] ldst_din; 
input   [3:0] ldst_mask; 
input   ldst_wren; 
input   ldst_ck_en; 
output  [31:0] ldst_dout; 

wire    [31:0] ldst_dout;
wire    [LDST_A_MSB:0] i_address;
wire    [31:0] i_wr_data; 
wire    [31:0] i_rd_data; 
reg     [3:0] i_wren; 
wire    [3:0] i_mask; 
reg     [3:0] i_ck_en; 

//  Assign byte enables, address and write data
// 
assign i_mask    = ldst_mask;
assign i_address = ldst_addr; 
assign i_wr_data = ldst_din; 

//  Assign read data output
// 
assign ldst_dout = i_rd_data; 

//  Generate individual clock enable and write enable pins for
//  each byte.
// 
always @(i_mask or ldst_wren or ldst_ck_en)
   begin

   if (i_mask[0] == 1'b 1)
      begin
      i_wren[0]  = ldst_wren;   
      i_ck_en[0] = ldst_ck_en; 
      end
   else
      begin
      i_wren[0]  = ~LDST_WR_ACTIVE;  
      i_ck_en[0] = ~LDST_CK_EN_ACTIVE; 
      end

   if (i_mask[1] == 1'b 1)
      begin
      i_wren[1]  = ldst_wren;   
      i_ck_en[1] = ldst_ck_en; 
      end
   else
      begin
      i_wren[1]  = ~LDST_WR_ACTIVE; 
      i_ck_en[1] = ~LDST_CK_EN_ACTIVE; 
      end

   if (i_mask[2] == 1'b 1)
      begin
      i_wren[2]  = ldst_wren;   
      i_ck_en[2] = ldst_ck_en; 
      end
   else
      begin
      i_wren[2]  = ~LDST_WR_ACTIVE; 
      i_ck_en[2] = ~LDST_CK_EN_ACTIVE; 
      end

   if (i_mask[3] == 1'b 1)
      begin
      i_wren[3]  = ldst_wren;   
      i_ck_en[3] = ldst_ck_en; 
      end
   else
      begin
      i_wren[3]  = ~LDST_WR_ACTIVE; 
      i_ck_en[3] = ~LDST_CK_EN_ACTIVE; 
      end
   end

//  Instantiation of RAM
// 
//  Note that the fake RAM cells have
// 
//       * No capacitance
//       * Infinite drive capacity
// 
//  and hence timings should be taken with a pinch of salt.
// 
//  The clock enable signal turns off the RAM ports when they are not
//  in use to save power. Depending on technology, this may cause 
//  time delays on the critical path. If this is the case and this is
//  not acceptable, don't connect this signal to the instantiation 
//  of the real RAM.
// 
//  If the input signals we and ck_en, of the real RAM, are not active
//  low, as they are for the fake RAM, do not insert an inverter! 
//  Instead, change the RAM constants in extutil.
// 


fake_dccm U_fake_dccm (.clk(clk_ungated),
                      .address(i_address),
                      .wr_data(i_wr_data),
                      .we(i_wren),
                      .ck_en(i_ck_en),
                      .rd_data(i_rd_data));


endmodule

