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
// This file is an empty extension core register block.
//       Small Score Boarded Multiply Instruction, Revision info. :  600 Architecture IP Library version 4.9.7, file revision  $Date$
// 
//
//========================== Inputs to this block =========================--
//
//
// s1a[5:0]         U Source 1 register address from stage 2 of the pipeline.
//                  This is the B field from the instruction word, sent from 
//                  the rctl via hostif.v.
//
// s2a[5:0]         L Source 2 register address from stage 2 of the pipeline.
//                  This is the C field from the instruction word, sent from
//                  rctl.v. 
//
// wba[5:0]         L Write Back Address. This is the address of the register
//                  to be loaded with wbdata[31:0] at the end of the cycle if
//                  wben is high. This is used to for all register writebacks
//                  whether from the LSU, ALU, or the host.
//
// wbdata[]         L Write Back Data. This is the data from the writeback 
//                  stage which is to be written into the register file, into
//                  the address specified by wba[5:0] at the end of the cycle
//                  when wben is true. 
//
// wben             L Write Back Enable. This signal is the enable signal 
//                  which determines whether the data on wbdata[] is written
//                  into the register file at stage 4. This occurs at the end
//                  of the cycle. Note that stage 4 (writeback) is never held
//                  up, so when wben is true on a particular cycle a writeback
//                  must take place regardless of anything else.
//                  This produced in stage 3 and takes into account delayed
//                  load writebacks, cancelled instructions, and instructions
//                  which are not to be executed due to the CC result being
//                  false, amongst other things.
//
//======================== Outputs from this block ========================--
// 
// x1data[]         U Extension Source 1 Data. This is the source 1 data for
//                  alternatives not supported by coreregs and the extension
//                  registers have been enabled in extutil.v. It is
//                  forwarded to cr_int, if a match is found for address
//                  s1a[5:0].
//
// x2data_2_pc[31:0]
//                  U Extension Source 1 Data for program counter.
//                  Normally this will be identical to x1data[31:0]. It was
//                  required to prevent the slow write-through data from
//                  being used for Jcc [Rn] or JLcc [Rn]. Hence when such
//                  an extension exists, the x1data[] bus gets the stored
//                  register value or the writethrough data, but this
//                  signal only gets the stored register data, and a stall
//                  is generated if a writethrough would otherwise be
//                  required.
//
// x2data[]         U Extension Source 2 Data. This is the source 2 data for
//                  alternatives not supported by coreregs and the extension
//                  registers have been enabled in extutil.v. It is
//                  forwarded to cr_int, if a match is found for address
//                  s2a[5:0].
// 
//==========================================================================--
//
module xcoreregs (clk,
                  rst_a,
                  p2minoropcode,  
                  p2opcode,
                  p2subopcode,
                  p2subopcode3_r,
                  p2subopcode4_r,
                  p2subopcode5_r,
                  p2subopcode6_r,
                  p2subopcode7_r,
                  lmulres_r,
                  s1a,
                  s2a,
                  wba,
                  wbdata,
                  wben,
                  ux2data_2_pc,
                  ux1data,
                  ux2data,

                  x2data_2_pc,
                  x1data,
                  x2data);

`include "arcutil_pkg_defines.v" 
`include "arcutil.v"         
`include "extutil.v"         
`include "xdefs.v"       
// Extra include files required for extensions are inserted here.

   input          clk;  //  system clock
   input          rst_a; //  system reset
   input   [5:0]  p2minoropcode; 
   input   [4:0]  p2opcode; 
   input   [5:0]  p2subopcode; 
   input   [2:0]  p2subopcode3_r; 
   input          p2subopcode4_r; 
   input   [1:0]  p2subopcode5_r; 
   input   [2:0]  p2subopcode6_r; 
   input   [1:0]  p2subopcode7_r; 
//      <add extra signals as appropriate>
//
//  Signals required for extensions are inserted here. The automatic
//  hierarchy generation system can be used to create the structural
//  HDL to tie all the components together, provided that certain
//  naming and usage rules are followed. Please see the document
//  'Automatic Hierarchy Generator' - $ARCHOME/arc/docs/hiergen.pdf
// 

   input   [63:0] lmulres_r; 
   input   [5:0]  s1a; 
   input   [5:0]  s2a; 
   input   [5:0]  wba; 
   input   [31:0] wbdata; 
   input          wben;
   input   [31:0] ux2data_2_pc;
   input   [31:0] ux1data;
   input   [31:0] ux2data;
   
//      <add extra signals as appropriate>
//
//  Signals required for extensions are inserted here. The automatic
//  hierarchy generation system can be used to create the structural
//  HDL to tie all the components together, provided that certain
//  naming and usage rules are followed. Please see the document
//  'Automatic Hierarchy Generator' - $ARCHOME/arc/docs/hiergen.pdf
// 
   output  [31:0] x2data_2_pc; 
   output  [31:0] x1data; 
   output  [31:0] x2data; 

   reg     [31:0] x2data_2_pc;
   reg     [31:0] x1data; 
   reg     [31:0] x2data; 

// Signal declarations for extensions to be added.


// =========================== Ext. Register Logic ==========================--
// 
//  This section of the file is for adding core register extensions to which 
//  you can write to or for some other purpose.
// 
//  For Example, an extension core register, i.e. ext_write_register, at
//  address 56 (more usually defined in xdefs.v with a meaningful name),
//  would be written to in the following manner.
// 
// always @(posedge clk_debug or posedge rst_a)
//    begin : clocked_PROC
//    if (rst_a == 1'b 1)
//       begin
//       ext_write_register <= 1'b 0;   
//       end
// 
//    else
//       begin
// 
//       //  Write can only take place when the enable is true.
//       // 
//       if (wben == 1'b 0 & wba == 6'b 111000)
//          begin
//          ext_write_register <= wbdata;   
//          end
//       end
//    end
//
// Miscellaneous extension logic functions are inserted here.

// ===================  Core register result selection ===================--
// 
// The data from the extension core registers is selected using a
// multiplexer which uses the s1a (s2a) field as the index. Hence, a
// matching address for either of address busses will set the appropriate
// value on the x1data (or x2data) bus.
// 
// The x1data/x2data values are passed to the ALU (stage 3) via the cr_int.v 
// module. 
// 
// An example which has an extension core register address
// "one_ext_core_addr" linked to a value generated by the ALU would
// necessitate a declaration of the signal in the PORT description, i.e. 
// alu_register_value. This would normally be a 32-bit wide bus, though any 
// bus width can be defined as long as only 32-bits are passed to
// x1data/x2data.
// 
//
// Core register result selection for extension source 1 field which is used
// for any jump indirect through a register.
//
// e.g Jcc  [Rn]    where cc is a condition code
//     JLcc [Rn]    instructions with .f are included
//                  all delay slot modes are included 
//
// Normally, this signal should get the exact same data as x1data. The only
// exception to this rule would be where the extensions designer has found
// that a problem exists with late-arriving data on x1data which may cause
// a static timing path such as:
//
//  (some logic) -> x1data -> next_pc -> icache RAM
//
// x1data goes to two places:
//
//  1. Through the reg read multiplexers to the flip-flop at the end of the
//     stage. (shorter path)
//
//  2. To the jump instruction (the only instruction to use register data at
//     stage 2). The jump-through-a-register path essentially adds more
//     levels of muxing in order to create the next_pc signal - which then
//     typically goes onto a RAM cell which is likely to have a larger setup
//     time than a regular flip-flop. (longer path)
// 
// The x2data_2_pc signal gives the extension designer the opportunity to
// supply the late-arriving register data onto the x1data signal, and to
// supply different data onto x2data_2_pc - typically this would be a
// latched copy of the late arriving data with shorter static timing path.
//
// A stall would have to be generated to hold the Jump until the x1data
// register bus contains the correct value. This stall would typically
// detect that a jump indirect (Jcc [Rn]) was using an affected extensions
// core register (where x1data and x2data_2_pc signal differ).
//
// If you are unsure, make x2data_2_pc the same as x1data under all
// conditions, and everything will be fine - this is the normal case!
//
always @(s2a or ux2data_2_pc
         or lmulres_r
        )
   begin : x2data_2_pc_async_PROC
   case (s2a) 

//
//  Example : one_ext_core_addr: x2data_2_pc = alu_register_value;
//
//Extension core register address decodes inserted here
   RMLO:  x2data_2_pc = lmulres_r[31:0];        
   rmmid: x2data_2_pc = lmulres_r[47:16];        
   RMHI:  x2data_2_pc = lmulres_r[63:32];        

   default:
      begin
      x2data_2_pc = ux2data_2_pc;  
      end
   endcase
   end

    
// Core register result selection for extension source 1 field
//
always @(s1a or ux1data
         or lmulres_r
        )
   begin : x1data_async_PROC
   case (s1a) 

//
//  Example : one_ext_core_addr: x1data = alu_register_value;
//
//Extension core register address decodes inserted here
   RMLO:
      begin
      x1data = lmulres_r[31:0];        
      end
   rmmid:
      begin
      x1data = lmulres_r[47:16];        
      end
   RMHI:
      begin
      x1data = lmulres_r[63:32];        
      end
   default:
      begin
      x1data = ux1data;    
      end
   endcase
   end

//Core register result selection for extension source 2 field
//
always @(s2a or ux2data
         or lmulres_r
        )
   begin : x2data_async_PROC
   case (s2a) 

//
//  Example : one_ext_core_addr: x2data = alu_register_value;
//
//Extension core register address decodes inserted here
   RMLO:
      begin
      x2data = lmulres_r[31:0];        
      end
   rmmid:
      begin
      x2data = lmulres_r[47:16];        
      end
   RMHI:
      begin
      x2data = lmulres_r[63:32];        
      end
   default:
      begin
      x2data = ux2data;    
      end
   endcase
   end


endmodule // module xcoreregs

