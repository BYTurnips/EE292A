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
// Small, slow implementation of the adder, functionally compatible
// with and Kogge-stone parallel prefix adders. This is for A601.
//

module adder (A,
              B,
              Cin,

              Sum,
              Zout,
              Nout,
              Cout,
              Vout);
   
input    [31:0] A; 
input    [31:0] B; 
input    Cin; 

output   [31:0] Sum; 
output   Zout; 
output   Nout; 
output   Cout; 
output   Vout; 

//wire    [31:0] Sum_ncin; 
reg     [31:0] Sum; 
reg      Cout; 
wire     Zout; 
wire     Nout; 
wire     Vout; 

// -------------------------------------------
// ---------- 32bit Slow adder ---------------
// -------------------------------------------
//assign Sum_ncin = A + B ; // synopsys label add32_1

always @(A or B or Cin)
begin : add32_2_PROC
    /* synopsys resource a2:
       map_to_module = "DW01_add",
       implementation = "rpl",
       ops = "add32_2";
    */
      {Cout, Sum} = A + B + Cin ; // synopsys label add32_2
end


assign Nout = Sum[31]; 
assign Zout = (Sum == 32'h0);
assign Vout = (B[31] & A[31] & ~Sum[31]) | (~B[31] & ~A[31] & Sum[31]);

endmodule // module adder

