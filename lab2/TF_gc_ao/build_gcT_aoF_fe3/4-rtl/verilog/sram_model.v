// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 1995-2012 ARC International (Unpublished)
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
// Currently arranged to deal with bi-directionaL signals.
// 
`include "arc600constants.v"
module sram_model (xxclr,

                   xsram_a,
                   xsram_d,
                   xsram_we_n,
                   xsram_oe_n,

                   xsram_high_z);

`include "ext_msb.v"
parameter THIRTY_TWO = 32;
parameter FOUR = 4;

input               xxclr; 

inout [EXT_A_MSB:2] xsram_a;   
inout [31:0]        xsram_d;
inout [3:0]         xsram_we_n;
inout               xsram_oe_n;

output              xsram_high_z; 

wire  [EXT_A_MSB:2] xsram_a; 
wire  [31:0]        xsram_d; 
wire  [3:0]         xsram_we_n; 
wire                xsram_oe_n; 
reg                 xsram_high_z; 
wire  [EXT_A_MSB:2] i_a; 
wire                logic0; 
wire                logic1; 
reg                 decode; 
wire                isram_oe_n; 
wire  [3:0]         isram_we_n; 


reg                 high_z_proc_i_xsram_high_z; 
integer             i; 
integer             decode_proc_i;
   
// =============================================================================

   assign logic0 = 1'b 0; 
   assign logic1 = 1'b 1; 

   assign xsram_d = {(THIRTY_TWO){1'b z}}; 
   assign xsram_a = {(EXT_A_MSB - 1){1'b z}}; 
   assign xsram_we_n = {(FOUR){1'b z}}; 
   assign xsram_oe_n = 1'b Z; 

   //  Set xsram_high_z signal to '1' when all sram signals go high
   //  impedance, i. e. 'Z'.
   // 
   always @(xsram_d or xsram_a or xsram_we_n or xsram_oe_n)
   begin : high_z_PROC
   high_z_proc_i_xsram_high_z = 1'b 1;  

   if (xsram_d == 32'b ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ)
      begin
      if (xsram_we_n == 4'b ZZZZ & xsram_oe_n == 1'b Z)
         begin

         for (i = EXT_A_MSB; i >= 2; i = i - 1)
            begin
            if (xsram_a[i] != 1'b Z)
               begin
                  high_z_proc_i_xsram_high_z = 1'b 0;   
               end
            end
         end
      else
         begin
            high_z_proc_i_xsram_high_z = 1'b 0; 
         end
      end
   else
      begin
         high_z_proc_i_xsram_high_z = 1'b 0;    
      end
      
      xsram_high_z <= high_z_proc_i_xsram_high_z;   
   end

   // Prevent the inputs to the RAM from going to X or Z during the reset
   // period.
   // 
   // And emulate pullups on the signals to prevent Z's from causing errors.
   // 
   // 
   assign isram_oe_n = xxclr == 1'b 0 ? 1'b 1 : 
          xsram_oe_n === 1'b Z ? 1'b 1 : 
          xsram_oe_n; 

   assign isram_we_n[3] = xxclr == 1'b 0 ? 1'b 1 : 
          xsram_we_n[3] === 1'b Z ? 1'b 1 : 
          xsram_we_n[3]; 

   assign isram_we_n[2] = xxclr == 1'b 0 ? 1'b 1 : 
          xsram_we_n[2] === 1'b Z ? 1'b 1 : 
          xsram_we_n[2]; 

   assign isram_we_n[1] = xxclr == 1'b 0 ? 1'b 1 : 
          xsram_we_n[1] === 1'b Z ? 1'b 1 : 
          xsram_we_n[1]; 

   assign isram_we_n[0] = xxclr == 1'b 0 ? 1'b 1 : 
          xsram_we_n[0] === 1'b Z ? 1'b 1 : 
          xsram_we_n[0]; 

   //  Cast address i_a
   // 
   assign i_a = xsram_a;

// =============================================================================

//  Instantiate 32-bit wide RAM with byte write enables --
// 
jk_sram  ram_32bit (
          .nCE(logic0),
          .nOE(isram_oe_n),
          .nWE(isram_we_n),
          .A(i_a),
          .D(xsram_d),
          .CE2(logic1));

// =============================================================================

endmodule

