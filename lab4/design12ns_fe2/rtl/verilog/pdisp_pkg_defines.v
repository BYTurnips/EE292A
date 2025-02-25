// `ifndef PDISP_PKG_DEFINES_V
// `define PDISP_PKG_DEFINES_V
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
// All the functions that are employed by pdisp.v are included in
// the file below.
//

//synopsys translate_off
//
//  These values are used by pdisp.v for displaying information on the
//  command line with regards to the state of the ARC core.
// 
//  When this is set to '1' the pdisp.v only displays when there is
//  a state change.
// 
`define PDISP_CHGONLY 1'b 1 

//  When this is set to '1' the pdisp.v will display the nearest
//  label to the PC with its offset value.
// 
`define PDISP_LABEL 1'b 1

// A constant value used by PDISP to stipulates the  maximum length of
// a label in characters 
//
`define MAX_LABEL_LEN 500

//  A constant value used by PDISP to stipulate what size the arrays are which
//  store the label data.
// 
`define NO_OF_LABELS 100000 

//  When this is set to '1' then pdisp.v is enabled and displays the 
//  the current state of the ARC pipeline.
// 
`define PDISP_USE 1'b 1

// When this is set to '1' then pdisp.v performs X-checking. It is
// always enabled except for core verification builds.
// 
`define PDISP_XCHECK 1'b 1

// Predefined Suffix values
//
`define STRING_LENGTH  4'h d

// PDISP Display Information
// -------------------------
//
// Below are functions for pdisp.v's implementation. 
// Flagdisp is a function written for a verilog pdisp.
// This has also been added below. 

// Displays condition code flags
    function [31:0] flagdisp;
       input    [3:0]  aluflags; 
 
       reg      [31:0] flags_s; 

       begin
           begin
           flags_s [31:0] = "    "; 

              if (aluflags[A_Z_N] == 1'b 1)
              begin
                 flags_s[31:24] = "Z"; 
              end
              else
              ;

              if (aluflags[A_N_N] == 1'b 1)
              begin
                 flags_s[23:16] = "N"; 
              end
              else
              ;

              if (aluflags[A_C_N] == 1'b 1)
              begin
                 flags_s[15:8] = "C";  
              end
              else
              ;

              if (aluflags[A_V_N] == 1'b 1)
              begin
                 flags_s[7:0] = "V";   
              end
              else
              ;

              flagdisp  = flags_s ;
           end
       end
    endfunction // flagdisp
//////////////////////////////////////////////////////////////////////////////

    function [8:1] nibble2hex;
       input   nibble;
       integer nibble;
       begin
           case (nibble[3:0])
             4'b0000 : nibble2hex = "0";
             4'b0001 : nibble2hex = "1";
             4'b0010 : nibble2hex = "2";
             4'b0011 : nibble2hex = "3";
             4'b0100 : nibble2hex = "4";
             4'b0101 : nibble2hex = "5";
             4'b0110 : nibble2hex = "6";
             4'b0111 : nibble2hex = "7";
             4'b1000 : nibble2hex = "8";
             4'b1001 : nibble2hex = "9";
             4'b1010 : nibble2hex = "A";
             4'b1011 : nibble2hex = "B";
             4'b1100 : nibble2hex = "C";
             4'b1101 : nibble2hex = "D";
             4'b1110 : nibble2hex = "E";
             4'b1111 : nibble2hex = "F";
             default : nibble2hex = "x";
           endcase
       end
    endfunction // nibble2hex

    function [(2*8):1] byte2hex;
      input   bbyte;
      integer bbyte;
     
      begin
         byte2hex = {nibble2hex(bbyte >> 4),nibble2hex(bbyte[3:0])};
      end
    endfunction // byte2hex
                  
    function [(4*8):1] word2hex;
      input word;
      integer word;   
      begin
         word2hex = {byte2hex(word >> 8),byte2hex(word[7:0])};
      end
    endfunction // word2hex

    function [(4*8):1] stripzeros;

        input           inp;
   
        reg   [(4*8):1] inp;

        begin
      
           if ((inp & 32'hffffff00) == 32'h30303000)
              stripzeros = inp & 32'h000000ff;
           else
              if ((inp & 32'hffff0000) == 32'h30300000)
                 stripzeros = inp & 32'h0000ffff;
              else
                 if ((inp & 32'hff000000) == 32'h30000000)
                    stripzeros = inp & 32'h00ffffff;
        end
    endfunction // stripzeros

    function [(8*8):1] int2hex;

        input iint;

        integer iint;
        reg [(4*8):1] word0, word1;

        begin
          // The code below will only display
          // the offset with the preceeding "0"
          // stripped off.
          // Note : h30 is the ascii "0".
          //
          word0 =  stripzeros(word2hex(iint >> 16));

          if (word0 == "0") word0 = 0;
             word1 =  stripzeros(word2hex(iint[15:0]));

          int2hex = {word0,word1};

       end 
   endfunction // int2hex


function [(8*8):1] int2hexns;
   input iint;
   integer iint;
   
   begin
  
      int2hexns = {word2hex(iint[31:16]),word2hex(iint[15:0])};

   end 
endfunction // int2hex
    

function [(`MAX_LABEL_LEN+13)*8:1] label_output;
   input             [`MAX_LABEL_LEN*8:1] nearest_label; 
   input             offset; 
   input             en; 
   input             en1; 
   input             pc_valid; 
   input             ivalid; 
  
   integer           offset;
   
   // The string the information returned is stored
   //
   reg [(`MAX_LABEL_LEN+13)*8:1]         label_info;

   begin      
      //  Initialise string with spaces. It's 113 long to take into account
      //  added characters "[+offset(10)]"
      label_info = 0;
     
      //  If the current pc value is valid then proceed with label matching.
      // 
       if ((pc_valid == 1'b 1 & ivalid == 1'b 1) & (nearest_label != 0))
         begin
            
            //  Parenthesise Label match if the ARC has halted.
            // 
            if (en == 1'b 0)
               begin
                  label_info = {"[",nearest_label,"+0x",int2hex(offset),"]"};   
               end
            //  Parenthesise Label match if the ARC has stalled.
            // 
            else if (en1 == 1'b 0 )
               begin
                  label_info = {"(",nearest_label,"+0x",int2hex(offset),")"};
               end
            //  Do not parenthesise Label match if the ARC has not stalled or 
            //  halted.
            //
            else
               begin
                  label_info = {" ",nearest_label,"+0x",int2hex(offset)," "};
               end  
            
            label_output = label_info;
         end
      else
         begin
            label_output = 0;
         end
   end
endfunction // label_output
/////////////////////////////////////////////////////////////////////////////////////

// Used to display exceptions

function [((4*8)-1):0] xinfo;
input   [31:0] p1iw; 
input   [3:0] ivalid; 
input   [3:0] irq3; 
input   [3:0] irq4; 
input   [3:0] irq5; 
input   [3:0] irq6; 
input   [3:0] irq7;
input   [3:0] irq8; 
input   [3:0] irq9; 
input   [3:0] irq10;  
input   [3:0] irq11;  
input   [3:0] irq12;
input   [3:0] irq13;
input   [3:0] irq14;
input   [3:0] irq15;
input   [3:0] irq16;
input   [3:0] irq17;
input   [3:0] irq18;
input   [3:0] irq19;
input   [3:0] irq20;
input   [3:0] irq21;
input   [3:0] irq22;
input   [3:0] irq23;      
input   [3:0] irq24;
input   [3:0] irq25;
input   [3:0] irq26;
input   [3:0] irq27;
input   [3:0] irq28;
input   [3:0] irq29;      
input   [3:0] irq30;
input   [3:0] irq31;

input   [3:0] mem_err; 

reg     [3:0]  op ;  
reg            dmode ;  
reg     [1:0]  branch; 

begin
   begin
   op = p1iw[`INSTR_MSB:`INSTR_LSB];    
   dmode = p1iw[DEL_SLOT_MODE]; 
   branch = op == OP_BCC  | op == OP_BLCC | 
            op == OP_FMT1;  

   if (mem_err == 1'b 1)
      xinfo = "mem ";
   else if (irq3 == 1'b 1 )
      xinfo = "irq3";
   else if (irq4 == 1'b 1 )
      xinfo = "irq4";
   else if (irq5 == 1'b 1 )
      xinfo = "irq5";
   else if (irq6 == 1'b 1 )
      xinfo = "irq6";
   else if (irq7 == 1'b 1 )
      xinfo = "irq7";
   else if (irq8 == 1'b 1 )
      xinfo = "irq8";
   else if (irq9 == 1'b 1 )
      xinfo = "irq9";
   else if (irq10 == 1'b 1 )
      xinfo = "irq10";
   else if (irq11 == 1'b 1 )
      xinfo = "irq11";
   else if (irq12 == 1'b 1 )
      xinfo = "irq12";
   else if (irq13 == 1'b 1 )
      xinfo = "irq13";
   else if (irq14 == 1'b 1 )
      xinfo = "irq14";
   else if (irq15 == 1'b 1 )
      xinfo = "irq15";
   else if (irq16 == 1'b 1 )
      xinfo = "irq16";
   else if (irq17 == 1'b 1 )
      xinfo = "irq17";
   else if (irq18 == 1'b 1 )
      xinfo = "irq18";
   else if (irq19 == 1'b 1 )
      xinfo = "irq19";
   else if (irq20 == 1'b 1 )
      xinfo = "irq20";
   else if (irq21 == 1'b 1 )
      xinfo = "irq21";
   else if (irq22 == 1'b 1 )
      xinfo = "irq22";
   else if (irq23 == 1'b 1 )
      xinfo = "irq23";
   else if (irq24 == 1'b 1 )
      xinfo = "irq24";
   else if (irq25 == 1'b 1 )
      xinfo = "irq25";
   else if (irq26 == 1'b 1 )
      xinfo = "irq26";
   else if (irq27 == 1'b 1 )
      xinfo = "irq27";
   else if (irq28 == 1'b 1 )
      xinfo = "irq28";
   else if (irq29 == 1'b 1 )
      xinfo = "irq29";
   else if (irq30 == 1'b 1 )
      xinfo = "irq30";
   else if (irq31 == 1'b 1 )
      xinfo = "irq31";
   else
      xinfo = "    ";
   end
end
endfunction


function [((4*8)-1):0] xinfo2;
input   [31:0] p1iw; 
input   [3:0] ivalid; 
input   [3:0] irq3; 
input   [3:0] irq4; 
input   [3:0] irq5; 
input   [3:0] irq6; 
input   [3:0] irq7;
input   [3:0] irq8; 
input   [3:0] irq9; 
input   [3:0] irq10;  
input   [3:0] irq11;  
input   [3:0] irq12;
input   [3:0] irq13;
input   [3:0] irq14;
input   [3:0] irq15;
input   [3:0] irq16;
input   [3:0] irq17;
input   [3:0] irq18;
input   [3:0] irq19;
input   [3:0] irq20;
input   [3:0] irq21;
input   [3:0] irq22;
input   [3:0] irq23;      
input   [3:0] irq24;
input   [3:0] irq25;
input   [3:0] irq26;
input   [3:0] irq27;
input   [3:0] irq28;
input   [3:0] irq29;      
input   [3:0] irq30;
input   [3:0] irq31;

input   [3:0] mem_err; 

reg     [3:0]  op ;  
reg            dmode ;  
reg     [1:0]  branch; 

begin
   begin
   op = p1iw[`INSTR_MSB:`INSTR_LSB];    
   dmode = p1iw[DEL_SLOT_MODE]; 
   branch = op == OP_BCC | op == OP_BLCC | 
            op == OP_FMT1;

   if (branch == 1'b 1)
      begin
      if (dmode == DMND)
         begin
         end    

      end   

   if (mem_err == 1'b 1)
      xinfo2 = "mem ";
   else if (irq3 == 1'b 1 )
      xinfo2 = "irq3";
   else if (irq4 == 1'b 1 )
      xinfo2 = "irq4";
   else if (irq5 == 1'b 1 )
      xinfo2 = "irq5";
   else if (irq6 == 1'b 1 )
      xinfo2 = "irq6";
   else if (irq7 == 1'b 1 )
      xinfo2 = "irq7";
   else if (irq8 == 1'b 1 )
      xinfo2 = "irq8";
   else if (irq9 == 1'b 1 )
      xinfo2 = "irq9";
   else if (irq10 == 1'b 1 )
      xinfo2 = "irq10";
   else if (irq11 == 1'b 1 )
      xinfo2 = "irq11";
   else if (irq12 == 1'b 1 )
      xinfo2 = "irq12";
   else if (irq13 == 1'b 1 )
      xinfo2 = "irq13";
   else if (irq14 == 1'b 1 )
      xinfo2 = "irq14";
   else if (irq15 == 1'b 1 )
      xinfo2 = "irq15";
   else if (irq16 == 1'b 1 )
      xinfo2 = "irq16";
   else if (irq17 == 1'b 1 )
      xinfo2 = "irq17";
   else if (irq18 == 1'b 1 )
      xinfo2 = "irq18";
   else if (irq19 == 1'b 1 )
      xinfo2 = "irq19";
   else if (irq20 == 1'b 1 )
      xinfo2 = "irq20";
   else if (irq21 == 1'b 1 )
      xinfo2 = "irq21";
   else if (irq22 == 1'b 1 )
      xinfo2 = "irq22";
   else if (irq23 == 1'b 1 )
      xinfo2 = "irq23";
   else if (irq24 == 1'b 1 )
      xinfo2 = "irq24";
   else if (irq25 == 1'b 1 )
      xinfo2 = "irq25";
   else if (irq26 == 1'b 1 )
      xinfo2 = "irq26";
   else if (irq27 == 1'b 1 )
      xinfo2 = "irq27";
   else if (irq28 == 1'b 1 )
      xinfo2 = "irq28";
   else if (irq29 == 1'b 1 )
      xinfo2 = "irq29";
   else if (irq30 == 1'b 1 )
      xinfo2 = "irq30";
   else if (irq31 == 1'b 1 )
      xinfo2 = "irq31";
   else if ((branch == 1'b 1) & (dmode == DMND))
      xinfo2 = " nd ";
   else if ((branch == 1'b 1) & (dmode == DMD))
      xinfo2 = "  d ";
   else
      xinfo2 = "    ";
   end
end
endfunction

// Shows Returning loads and register writebacks

function  [((24*8)-1):0] ldop;
          
          input   [OPERAND_MSB:0] reg_sel;
          input   ld;
          input   [DW:0] data;

          begin

                 ldop = 0;
                         
                 if (ld == 1'b 1)
                   ldop = {"ld : " , reg2str(reg_sel) , " <- ", "0x",int2hexns(data)};
                 else
                   ldop = "--                       ";
                 
          end
endfunction          


function  [((35*8*2)-1):0] wbop; // needs 4 characters
          input   auxw;
          input   [DW:0] aux_addr;
          input   [DW:0] aux_data;
          input   st;
          input   [DW:0] st_addr;
          input   [DW:0] st_data;
          input   brcc;
          input   xen;
          input   en;
          input   [OPERAND_MSB:0] reg_sel;
          input   ld;
          input   [DW:0] data;
          

          begin

                 wbop = 0;
                                  
                 if (brcc == 1'b 1)
                   begin

                        if (ld == 1'b 1)
                                begin
				  if (st == 1'b 0)
                                   wbop = {"br ld  : " , reg2str(reg_sel) , "      <- ", "0x",int2hexns(data)};
				   else 
				   wbop = {"br ld  : " , reg2str(reg_sel) , "      <- ", "0x",int2hexns(data), " | st  : " ,"0x", int2hexns(st_addr) , " <- ","0x",int2hexns(st_data)};
                                end
                          else if (xen == 1'b 1 )
                                begin
                                   wbop = {"br xwb : " , reg2str(reg_sel) , "      <- ","0x", int2hexns(data)};
                                end
                          else if (en == 1'b 1 )
                                begin
                                   wbop = {"br wb  : " , reg2str(reg_sel) , "      <- ","0x", int2hexns(data)};
                                end
                          else if (auxw == 1'b 1 )
                                begin
                                   wbop = {"br sr  : " ,"0x", int2hexns(aux_addr) , " <- ","0x", int2hexns(aux_data)};
                                end
                          else if (st == 1'b 1)
                                begin
                                   wbop = {"br st  : " ,"0x", int2hexns(st_addr) , " <- ","0x",int2hexns(st_data)};
                                end
                          else
                                begin
                                   wbop = "br --                            ";
                                end
                          
                   end
                 else
                   begin
                          if (ld == 1'b 1)
                                begin
				  if (st == 1'b 0)
                                   wbop = {"-- ld  : " , reg2str(reg_sel) , "      <- ", "0x",int2hexns(data)};
				   else 
				   wbop = {"-- ld  : " , reg2str(reg_sel) , "      <- ", "0x",int2hexns(data), " | st  : " ,"0x", int2hexns(st_addr) , " <- ","0x",int2hexns(st_data)};
                                end
                          else if (xen == 1'b 1 )
                                begin
                                   wbop = {"-- xwb : " , reg2str(reg_sel) , "      <- ","0x", int2hexns(data)};
                                end
                          else if (en == 1'b 1 )
                                begin
                                   wbop = {"-- wb  : " , reg2str(reg_sel) , "      <- ","0x", int2hexns(data)};
                                end
                          else if (auxw == 1'b 1 )
                                begin
                                   wbop = {"-- sr  : " ,"0x", int2hexns(aux_addr) , " <- ","0x", int2hexns(aux_data)};
                                end
                          else if (st == 1'b 1)
                                begin
                                   wbop = {"-- st  : " ,"0x", int2hexns(st_addr) , " <- ","0x",int2hexns(st_data)};
                                end
                          else
                                begin
                                   wbop = "-- --                            ";
                                end
                          
                   end
          end
endfunction

// Convert a register number to text

function [((5*8)-1):0]  reg2str;
  input [OPERAND_MSB:0]  reg_sel;
begin

   case(reg_sel)
   r0:  reg2str = "r0   ";
   r1:  reg2str = "r1   ";
   r2:  reg2str = "r2   ";
   r3:  reg2str = "r3   ";
   r4:  reg2str = "r4   ";
   r5:  reg2str = "r5   ";
   r6:  reg2str = "r6   ";
   r7:  reg2str = "r7   ";
   r8:  reg2str = "r8   ";
   r9:  reg2str = "r9   ";
   r10: reg2str = "r10  ";
   r11: reg2str = "r11  ";
   r12: reg2str = "r12  ";
   r13: reg2str = "r13  ";
   r14: reg2str = "r14  ";
   r15: reg2str = "r15  ";
   r16: reg2str = "r16  ";
   r17: reg2str = "r17  ";
   r18: reg2str = "r18  ";
   r19: reg2str = "r19  ";
   r20: reg2str = "r20  ";
   r21: reg2str = "r21  ";
   r22: reg2str = "r22  ";
   r23: reg2str = "r23  ";
   r24: reg2str = "r24  ";
   r25: reg2str = "r25  ";
   r26: reg2str = "r26  ";
   r27: reg2str = "r27  ";
   r28: reg2str = "r28  ";
   r29: reg2str = "r29  ";
   r30: reg2str = "r30  ";
   r31: reg2str = "r31  ";

   r32: reg2str = "r32  ";
   r33: reg2str = "r33  ";
   r34: reg2str = "r34  ";
   r35: reg2str = "r35  ";
   r36: reg2str = "r36  ";
   r37: reg2str = "r37  ";
   r38: reg2str = "r38  ";
   r39: reg2str = "r39  ";
   r40: reg2str = "r40  ";
   r41: reg2str = "r41  ";
   r42: reg2str = "r42  ";
   r43: reg2str = "r43  ";
   r44: reg2str = "r44  ";
   r45: reg2str = "r45  ";
   r46: reg2str = "r46  ";
   r47: reg2str = "r47  ";
   r48: reg2str = "r48  ";
   r49: reg2str = "r49  ";
   r50: reg2str = "r50  ";
   r51: reg2str = "r51  ";
   r52: reg2str = "r52  ";
   r53: reg2str = "r53  ";
   r54: reg2str = "r54  ";
   r55: reg2str = "r55  ";
   r56: reg2str = "r56  ";
   r57: reg2str = "r57  ";
   r58: reg2str = "r58  ";
   r59: reg2str = "r59  ";

   RLCNT:   reg2str = "lpcnt";               // r60
   r61:     reg2str = "#rsvd";               // r61
   RLIMM:   reg2str = "#limm";               // r62
   RCURRENTPC: reg2str = "#pcl ";            // r63

   default: reg2str = "???";
   endcase
end
endfunction

// Shows Pipeline stalls and halts

function  [(((`STRING_LENGTH+2)*8)-1):0] pipeoperation;
input  go;
input [((`STRING_LENGTH*8)-1):0] dis;
input iv;
input en;
input iint;  

reg [((`STRING_LENGTH*8)-1):0] os;

begin
  if (iint==1)
    os = "interrupt ---";
  else if (iv==0)
    os = "-------------";
  else
    os = dis;

  if (!go)
    pipeoperation = {"[", os, "]"};
  else if (!en)
    pipeoperation = {"(", os, ")"};
  else
    pipeoperation = {" ", os, " "};

end
endfunction

// Disassembly of ARC basecase and extension instructions

task disass;
input [31:0] inst_ip;
output [((`STRING_LENGTH*8)-1):0] result;
output flag;

reg [4:0] op_code;
reg [((`STRING_LENGTH*8)-1):0] instruction;
reg [5:0] subop;
reg [1:0] subop2;
reg [4:0] subop3;
reg [2:0] subop4;
reg [1:0] subop5;
reg       subop6;
reg [2:0] subop7;
reg [3:0] br_cond_code;
reg [5:0] minorop;
reg [5:0] afield;
reg [5:0] bfield;
reg [2:0] bfield16;
reg [5:0] cfield;
reg [2:0] cfield16;
reg [5:0] hifield;
reg [1:0] ldr_mode;
reg [4:0] cond_code;
reg [((3*8)-1):0] cond_code_txt;  // 3 characters max
reg [((4*8)-1):0] br_code_txt;    // 4 characters max
reg setflags;
reg nullify_inst;
reg [((3*8)-1):0] delay_slot_txt;  // 3 characters

reg [1:0] aa_field;
reg [1:0] size_field;
reg x_bit;
reg di_bit;

begin

op_code  = inst_ip[`INSTR_MSB:`INSTR_LSB];
subop    = inst_ip[MINOR_OP_UBND:MINOR_OP_LBND];
subop2   = inst_ip[MINOR16_OP1_UBND:MINOR16_OP1_LBND];
subop3   = inst_ip[MINOR16_OP2_UBND:MINOR16_OP2_LBND];
subop4   = inst_ip[MINOR16_OP3_UBND:MINOR16_OP3_LBND];
subop5   = inst_ip[MINOR16_OP4_UBND:MINOR16_OP4_LBND];
subop6   = inst_ip[MINOR16_OP3_UBND];
subop7   = inst_ip[MINOR16_BR2_UBND:MINOR16_BR2_LBND];
minorop  = inst_ip[AOP_UBND:AOP_LBND];
afield   = inst_ip[AOP_UBND:AOP_LBND];
bfield   = {inst_ip[BOP_MSB_UBND:BOP_MSB_LBND],
            inst_ip[BOP_LSB_UBND:BOP_LSB_LBND]};
bfield16 = inst_ip[BOP_LSB_UBND:BOP_LSB_LBND];
cfield   = inst_ip[COP_UBND:COP_LBND];
cfield16 = inst_ip[COP_UBND16:COP_LBND16];
hifield  = {inst_ip[AOP_UBND16:AOP_LBND16],
            inst_ip[COP_UBND16:COP_LBND16]};
ldr_mode = inst_ip[LDR_ADDR_WB_UBND:LDR_ADDR_WB_LBND];
setflags = inst_ip[SET_FLG_POS];
br_cond_code = inst_ip[MINOR_BR_UBND:MINOR_BR_LBND];
cond_code    = inst_ip[QQ_UBND:QQ_LBND];
nullify_inst = inst_ip[DELAY_SLOT];

// add text for condition codes

// Basecase instructions first

// Doing first level disassembly on basecase

   case (op_code)
   5'h00: instruction = "OP_BCC       ";
   5'h01: instruction = "OP_BLCC      ";
   5'h02: instruction = "OP_LD        ";
   5'h03: instruction = "OP_ST        ";
   5'h04: instruction = "OP_FMT1      ";
   5'h05: instruction = "OP_FMT2      ";
   5'h06: instruction = "OP_FMT3      ";
   5'h07: instruction = "OP_FMT4      ";
   5'h08: instruction = "OP_16_FMT1   ";
   5'h09: instruction = "OP_16_FMT2   ";
   5'h0a: instruction = "OP_16_FMT3   ";
   5'h0b: instruction = "OP_16_FMT4   ";
   5'h0c: instruction = "OP_16_LD_ADD ";
   5'h0d: instruction = "OP_16_ARITH  ";
   5'h0e: instruction = "OP_16_MV_ADD ";
   5'h0f: instruction = "OP_16_ALU_GEN";
   5'h10: instruction = "OP_16_LD_U7  ";
   5'h11: instruction = "OP_16_LDB_U5 ";
   5'h12: instruction = "OP_16_LDW_U6 ";
   5'h13: instruction = "OP_16_LDWX_U6";
   5'h14: instruction = "OP_16_ST_U7  ";
   5'h15: instruction = "OP_16_STB_U5 ";
   5'h16: instruction = "OP_16_STW_U6 ";
   5'h17: instruction = "OP_16_SSUB   ";
   5'h18: instruction = "OP_16_SP_REL ";
   5'h19: instruction = "OP_16_GP_REL ";
   5'h1a: instruction = "OP_16_LD_PC  ";
   5'h1b: instruction = "OP_16_MV     ";
   5'h1c: instruction = "OP_16_ADDCMP ";
   5'h1d: instruction = "OP_16_BRCC   ";
   5'h1e: instruction = "OP_16_BCC    ";
   5'h1f: instruction = "OP_16_BL     ";
   default: instruction = "unknown      ";
   endcase

// Coping with 16-bit instructions

  case (instruction)
   "OP_16_BL     ": instruction = "bl_s         ";
   "OP_16_BCC    ": if (subop5 == SO16_B_S9)
                      instruction = "b_s s9       ";
                   else if (subop5 == SO16_BEQ_S9)
                      instruction = "beq_s s9     ";
                   else if (subop5 == SO16_BNE_S9)
                      instruction = "bne_s s9     ";
                   else
                      begin
                      case (subop7)
                      SO16_BGT: instruction = "bgt_s s7     ";
                      SO16_BGE: instruction = "bge_s s7     ";
                      SO16_BLT: instruction = "blt_s s7     ";
                      SO16_BLE: instruction = "ble_s s7     ";
                      SO16_BHI: instruction = "bhi_s s7     ";
                      SO16_BHS: instruction = "bhs_s s7     ";
                      SO16_BLO: instruction = "blo_s s7     ";
                      default:  instruction = "bls_s s7     ";
                      endcase
                      end
   "OP_16_BRCC   ": if (subop6 == SO16_BREQ_S8)
                      instruction = "breq_s s8    ";
                   else
                      instruction = "brne_s s8    ";

   "OP_16_ADDCMP ": if (subop6 == SO16_ADD_U7)
                      instruction = "add_s u7     ";
                   else
                      instruction = "cmp_s u7     ";

   "OP_16_MV     ": instruction = "mov_s u8     ";
   "OP_16_LD_PC  ": instruction = "ld_s [pcl]   ";
   "OP_16_GP_REL ": if (subop5 == SO16_ADD_GP)
                      instruction = "add_s [gp]   ";
                   else if (subop5 == SO16_LD_GP)
                      instruction = "ld_s [gp]    ";
                   else if (subop5 == SO16_LDB_GP)
                      instruction = "ldb_s [gp]   ";
                   else
                      instruction = "ldw_s [gp]   ";
   "OP_16_SSUB   ": if (subop4 == SO16_ASL_U5)
                      instruction = "asl_s u5     ";
                   else if (subop4 == SO16_LSR_U5)
                      instruction = "lsr_s u5     ";
                   else if (subop4 == SO16_ASR_U5)
                      instruction = "asr_s u5     ";
                   else if (subop4 == SO16_SUB_U5)
                      instruction = "sub_s u5     ";
                   else if (subop4 == SO16_BSET_U5)
                      instruction = "bset_s u5    ";
                   else if (subop4 == SO16_BCLR_U5)
                      instruction = "bclr_s u5    ";
                   else if (subop4 == SO16_BMSK_U5)
                      instruction = "bmsk_s u5    ";
                   else
                      instruction = "btst_s u5    ";
   "OP_16_SP_REL ": if (subop4 == SO16_LD_SP)
                      instruction = "ld_s [sp]    ";
                   else if (subop4 == SO16_LDB_SP)
                      instruction = "ldb_s [sp]   ";
                   else if (subop4 == SO16_ST_SP)
                      instruction = "st_s [sp]    ";
                   else if (subop4 == SO16_STB_SP)
                      instruction = "stb_s [sp]   ";
                   else if (subop4 == SO16_ADD_SP)
                      instruction = "add_s sp     ";
                   else if (subop4 == SO16_SUB_SP)
                      instruction = "add/sub_s sp ";
                   else if (subop4 == SO16_POP_U7)
                      instruction = "pop_s        ";
                   else
                      instruction = "push_s       ";
   "OP_16_STW_U6 ": instruction = "stw_s [u6]   ";
   "OP_16_STB_U5 ": instruction = "stb_s [u5]   ";
   "OP_16_ST_U7  ": instruction = "st_s  [u7]   ";
   "OP_16_LDWX_U6": instruction = "ldw_s.x [u6] ";
   "OP_16_LDW_U6 ": instruction = "ldw_s [u6]   ";
   "OP_16_LDB_U5 ": instruction = "ldb_s [u5]   ";
   "OP_16_LD_U7  ": instruction = "ld_s [u7]    ";
   "OP_16_ALU_GEN":
                   case (subop3)
                   SO16_SOP:
                      begin
                      case (cfield16)
                      SO16_SOP_J:   instruction = "j_s          ";
                      SO16_SOP_JD:  instruction = "j.d_s        ";
                      SO16_SOP_JL:  instruction = "jl_s         ";
                      SO16_SOP_JLD: instruction = "jl_s.d       ";
                      SO16_SOP_SUB: instruction = "sub_s.ne     ";
                      SO16_SOP_ZOP:
                         begin
                         case (bfield16)
                         SO16_ZOP_NOP: instruction = "nop_s        ";
                         SO16_ZOP_JEQ: instruction = "jeq_s        ";
                         SO16_ZOP_JNE: instruction = "jne_s        ";
                         SO16_ZOP_J:   instruction = "j_s [bink]   ";
                         SO16_ZOP_JD:  instruction = "j_s.d [bink] ";
                         default:      instruction = "unknown      ";
                         endcase
                         end
                      default: instruction = "unknown      ";
                      endcase
                      end
                   SO16_SUB_REG: instruction = "sub_s b,b,c  ";
                   SO16_AND: instruction     = "and_s b,b,c  ";
                   SO16_OR:  instruction     = "or_s  b,b,c  ";
                   SO16_BIC: instruction     = "bic_s b,b,c  ";
                   SO16_XOR: instruction     = "xor_s b,b,c  ";
                   SO16_TST: instruction     = "tst_s b,b,c  ";
                   SO16_MUL64: instruction   = "mul64_s 0,b,c";
                   SO16_SEXB: instruction    = "sexb_s b,c   ";
                   SO16_SEXW: instruction    = "sexw_s b,c   ";
                   SO16_EXTB: instruction    = "extb_s b,c   ";
                   SO16_EXTW: instruction    = "extw_s b,c   ";
                   SO16_ABS: instruction     = "abs_s  b,c   ";
                   SO16_NOT: instruction     = "not_s  b,c   ";
                   SO16_NEG: instruction     = "neg_s  b,c   ";
                   SO16_ADD1: instruction    = "add1_s b     ";
                   SO16_ADD2: instruction    = "add2_s b     ";
                   SO16_ADD3: instruction    = "add3_s b     ";
                   SO16_ASL_M: instruction   = "asl_s  b,b,c ";
                   SO16_LSR_M: instruction   = "lsr_s  b,b,c ";
                   SO16_ASR_M: instruction   = "asr_s  b,b,c ";
                   SO16_ASL_1: instruction   = "asl_s  b,c   ";
                   SO16_ASR_1: instruction   = "asr_s  b,c   ";
                   SO16_LSR_1: instruction   = "lsr_s  b,c   ";
                   SO16_BRK: instruction = "brk_s        ";
                   default:  instruction = "unknown      ";
                   endcase
   "OP_16_MV_ADD ":
                begin
                   if (subop2 == SO16_ADD_HI)
                      instruction = "add_s hi     ";
                   else if (subop2 == SO16_MOV_HI1)
                      instruction = "mov_s hi     ";
                   else if (subop2 == SO16_MOV_HI2)
                      instruction = "mov_s b      ";
                   else
                      instruction = "cmp_s hi     ";

                end

   "OP_16_ARITH  ": if (subop2 == SO16_ADD_U3)
                      instruction = "add_s u3     ";
                   else if (subop2 == SO16_SUB_U3)
                      instruction = "sub_s u3     ";
                   else if (subop2 == SO16_ASL)
                      instruction = "asl_s u3     ";
                   else
                      instruction = "asr_s u3     ";
   "OP_16_LD_ADD ": if (subop2 == SO16_LD)
                      instruction = "ld_s [b,c]   ";
                   else if (subop2 == SO16_LDB)
                      instruction = "ldb_s [b,c]  ";
                   else if (subop2 == SO16_LDW)
                      instruction = "ldw_s [b,c]  ";
                   else
                      instruction = "add_s b,c    ";
  endcase

// Checking whether ld instruction uses a shimm or limm to determine
// bit positions for a, zz and x.
case (instruction)
  "OP_LD        ": 
                 begin
                    di_bit = inst_ip[11];
                    aa_field = inst_ip[10:9];
                    size_field = inst_ip[8:7];
                    x_bit = inst_ip[6];
                 end

  "OP_ST        ": 
                 begin
                    di_bit = inst_ip[5];
                    aa_field = inst_ip[4:3];
                    size_field = inst_ip[2:1];
                    x_bit = inst_ip[0];
                 end
 
  default: 
                 begin
                    di_bit = inst_ip[15];
                    aa_field = inst_ip[23:22];
                    size_field = inst_ip[18:17];
                    x_bit = inst_ip[16];
                 end
 
 endcase

// Determine if ld instruction is actually ld, ldw or ldb
if (instruction == "OP_LD        ")
  begin
    case (size_field)
      2'b00: instruction = "ld           ";
      2'b01: instruction = "ldb          ";
      2'b10: instruction = "ldw          ";
      default: instruction = "ld?          ";
    endcase
  end

// Determine if st instruction is actually st, stw or stb
if (instruction == "OP_ST        ")
  begin
    case (size_field)
      2'b00: instruction = "st           ";
      2'b01: instruction = "stb          ";
      2'b10: instruction = "stw          ";
      default: instruction = "st?          ";
    endcase
  end

// ld and st instructions have operands encoded in the instruction
// and therefore are treated separately
// 
case (instruction)

    "ld           ":
       if ((aa_field == 2'b 00) && (x_bit == 0) && (di_bit == 0))
          instruction = "ld           ";
       else
       if ((aa_field == 2'b 00) && (x_bit == 0) && (di_bit != 0))
          instruction = "ld.di        ";
       else
       if ((aa_field == 2'b 01) && (x_bit == 0) && (di_bit == 0))
          instruction = "ld.aw        ";
       else
       if ((aa_field == 2'b 01) && (x_bit == 0) && (di_bit != 0))
          instruction = "ld.aw.di     ";
       else
       if ((aa_field == 2'b 10) && (x_bit == 0) && (di_bit == 0))
          instruction = "ld.ab        ";
       else
       if ((aa_field == 2'b 10) && (x_bit == 0) && (di_bit != 0))
          instruction = "ld.ab.di     ";
       else
       if ((aa_field == 2'b 11) && (x_bit == 0) && (di_bit == 0))
          instruction = "ld.as        ";
       else
       if ((aa_field == 2'b 11) && (x_bit == 0) && (di_bit != 0))
          instruction = "ld.as.di     ";
       else
       if (x_bit != 0)
          instruction = "unknown      ";

    "ldb          ":
       if ((aa_field == 2'b 00) && (x_bit == 0) && (di_bit == 0))
          instruction = "ldb          ";
       else
       if ((aa_field == 2'b 00) && (x_bit == 0) && (di_bit != 0))
          instruction = "ldb.di       ";
       else
       if ((aa_field == 2'b 00) && (x_bit != 0) && (di_bit == 0))
          instruction = "ldb.x        ";
       else
       if ((aa_field == 2'b 00) && (x_bit != 0) && (di_bit != 0))
          instruction = "ldb.x.di     ";
       else
       if ((aa_field == 2'b 01) && (x_bit == 0) && (di_bit == 0))
          instruction = "ldb.aw       ";
       else
       if ((aa_field == 2'b 01) && (x_bit == 0) && (di_bit != 0))
          instruction = "ldb.aw.di    ";
       else
       if ((aa_field == 2'b 01) && (x_bit != 0) && (di_bit == 0))
          instruction = "ldb.x.aw     ";
       else
       if ((aa_field == 2'b 01) && (x_bit != 0) && (di_bit != 0))
          instruction = "ldb.x.aw.di  ";
       else
       if ((aa_field == 2'b 10) && (x_bit == 0) && (di_bit == 0))
          instruction = "ldb.ab       ";
       else
       if ((aa_field == 2'b 10) && (x_bit == 0) && (di_bit != 0))
          instruction = "ldb.ab.di    ";
       else
       if ((aa_field == 2'b 10) && (x_bit != 0) && (di_bit == 0))
          instruction = "ldb.x.ab     ";
       else
       if ((aa_field == 2'b 10) && (x_bit != 0) && (di_bit != 0))
          instruction = "ldb.x.ab.di  ";
       else
       if ((aa_field == 2'b 11) && (x_bit == 0) && (di_bit == 0))
          instruction = "ldb.as       ";
       else
       if ((aa_field == 2'b 11) && (x_bit == 0) && (di_bit != 0))
          instruction = "ldb.as.di    ";
       else
       if ((aa_field == 2'b 11) && (x_bit != 0) && (di_bit == 0))
          instruction = "ldb.x.as     ";
       else
       if ((aa_field == 2'b 11) && (x_bit != 0) && (di_bit != 0))
          instruction = "ldb.x.as.di  ";

    "ldw          ":
       if ((aa_field == 2'b 00) && (x_bit == 0) && (di_bit == 0))
          instruction = "ldw          ";
       else
       if ((aa_field == 2'b 00) && (x_bit == 0) && (di_bit != 0))
          instruction = "ldw.di       ";
       else
       if ((aa_field == 2'b 00) && (x_bit != 0) && (di_bit == 0))
          instruction = "ldw.x        ";
       else
       if ((aa_field == 2'b 00) && (x_bit != 0) && (di_bit != 0))
          instruction = "ldw.x.di     ";
       else
       if ((aa_field == 2'b 01) && (x_bit == 0) && (di_bit == 0))
          instruction = "ldw.aw       ";
       else
       if ((aa_field == 2'b 01) && (x_bit == 0) && (di_bit != 0))
          instruction = "ldw.aw.di    ";
       else
       if ((aa_field == 2'b 01) && (x_bit != 0) && (di_bit == 0))
          instruction = "ldw.x.aw     ";
       else
       if ((aa_field == 2'b 01) && (x_bit != 0) && (di_bit != 0))
          instruction = "ldw.x.aw.di  ";
       else
       if ((aa_field == 2'b 10) && (x_bit == 0) && (di_bit == 0))
          instruction = "ldw.ab       ";
       else
       if ((aa_field == 2'b 10) && (x_bit == 0) && (di_bit != 0))
          instruction = "ldw.ab.di    ";
       else
       if ((aa_field == 2'b 10) && (x_bit != 0) && (di_bit == 0))
          instruction = "ldw.x.ab     ";
       else
       if ((aa_field == 2'b 10) && (x_bit != 0) && (di_bit != 0))
          instruction = "ldw.x.ab.di  ";
       else
       if ((aa_field == 2'b 11) && (x_bit == 0) && (di_bit == 0))
          instruction = "ldw.as       ";
       else
       if ((aa_field == 2'b 11) && (x_bit == 0) && (di_bit != 0))
          instruction = "ldw.as.di    ";
       else
       if ((aa_field == 2'b 11) && (x_bit != 0) && (di_bit == 0))
          instruction = "ldw.x.as     ";
       else
       if ((aa_field == 2'b 11) && (x_bit != 0) && (di_bit != 0))
          instruction = "ldw.x.as.di  ";

    "ld?          ":
       if ((aa_field == 2'b 00) && (x_bit == 0) && (di_bit == 0))
          instruction = "ld?          ";
       else
       if ((aa_field == 2'b 00) && (x_bit == 0) && (di_bit != 0))
          instruction = "ld?.di       ";
       else
       if ((aa_field == 2'b 00) && (x_bit != 0) && (di_bit == 0))
          instruction = "ld?.x        ";
       else
       if ((aa_field == 2'b 00) && (x_bit != 0) && (di_bit != 0))
          instruction = "ld?.x.di     ";
       else
       if ((aa_field == 2'b 01) && (x_bit == 0) && (di_bit == 0))
          instruction = "ld?.aw       ";
       else
       if ((aa_field == 2'b 01) && (x_bit == 0) && (di_bit != 0))
          instruction = "ld?.aw.di    ";
       else
       if ((aa_field == 2'b 01) && (x_bit != 0) && (di_bit == 0))
          instruction = "ld?.x.aw     ";
       else
       if ((aa_field == 2'b 01) && (x_bit != 0) && (di_bit != 0))
          instruction = "ld?.x.aw.di  ";
       else
       if ((aa_field == 2'b 10) && (x_bit == 0) && (di_bit == 0))
          instruction = "ld?.ab       ";
       else
       if ((aa_field == 2'b 10) && (x_bit == 0) && (di_bit != 0))
          instruction = "ld?.ab.di    ";
       else
       if ((aa_field == 2'b 10) && (x_bit != 0) && (di_bit == 0))
          instruction = "ld?.x.ab     ";
       else
       if ((aa_field == 2'b 10) && (x_bit != 0) && (di_bit != 0))
          instruction = "ld?.x.ab.di  ";
       else
       if ((aa_field == 2'b 11) && (x_bit == 0) && (di_bit == 0))
          instruction = "ld?.as       ";
       else
       if ((aa_field == 2'b 11) && (x_bit == 0) && (di_bit != 0))
          instruction = "ld?.as.di    ";
       else
       if ((aa_field == 2'b 11) && (x_bit != 0) && (di_bit == 0))
          instruction = "ld?.x.as     ";
       else
       if ((aa_field == 2'b 11) && (x_bit != 0) && (di_bit != 0))
          instruction = "ld?.x.as.di  ";

    "st           ":
       if ((aa_field == 2'b 00) && (di_bit == 0))
          instruction = "st           ";
       else
       if ((aa_field == 2'b 00) && (di_bit != 0))
          instruction = "st.di        ";
       else
       if ((aa_field == 2'b 01) && (di_bit == 0))
          instruction = "st.aw        ";
       else
       if ((aa_field == 2'b 01) && (di_bit != 0))
          instruction = "st.aw.di     ";
       else
       if ((aa_field == 2'b 10) && (di_bit == 0))
          instruction = "st.ab        ";
       else
       if ((aa_field == 2'b 10) && (di_bit != 0))
          instruction = "st.ab.di     ";
       else
       if ((aa_field == 2'b 11) && (di_bit == 0))
          instruction = "st.as        ";
       else
       if ((aa_field == 2'b 11) && (di_bit != 0))
          instruction = "st.as.di     ";

    "stb          ":
       if ((aa_field == 2'b 00) && (di_bit == 0))
          instruction = "stb          ";
       else
       if ((aa_field == 2'b 00) && (di_bit != 0))
          instruction = "stb.di       ";
       else
       if ((aa_field == 2'b 01) && (di_bit == 0))
          instruction = "stb.aw       ";
       else
       if ((aa_field == 2'b 01) && (di_bit != 0))
          instruction = "stb.aw.di    ";
       else
       if ((aa_field == 2'b 10) && (di_bit == 0))
          instruction = "stb.ab       ";
       else
       if ((aa_field == 2'b 10) && (di_bit != 0))
          instruction = "stb.ab.di    ";
       else
       if ((aa_field == 2'b 11) && (di_bit == 0))
          instruction = "stb.as       ";
       else
       if ((aa_field == 2'b 11) && (di_bit != 0))
          instruction = "stb.as.di    ";

    "stw          ":
       if ((aa_field == 2'b 00) && (di_bit == 0))
          instruction = "stw          ";
       else
       if ((aa_field == 2'b 00) && (di_bit != 0))
          instruction = "stw.di       ";
       else
       if ((aa_field == 2'b 01) && (di_bit == 0))
          instruction = "stw.aw       ";
       else
       if ((aa_field == 2'b 01) && (di_bit != 0))
          instruction = "stw.aw.di    ";
       else
       if ((aa_field == 2'b 10) && (di_bit == 0))
          instruction = "stw.ab       ";
       else
       if ((aa_field == 2'b 10) && (di_bit != 0))
          instruction = "stw.ab.di    ";
       else
       if ((aa_field == 2'b 11) && (di_bit == 0))
          instruction = "stw.as       ";
       else
       if ((aa_field == 2'b 11) && (di_bit != 0))
          instruction = "stw.as.di    ";

    "st?          ":
       if ((aa_field == 2'b 00) && (di_bit == 0))
          instruction = "st?          ";
       else
       if ((aa_field == 2'b 00) && (di_bit != 0))
          instruction = "st?.di       ";
       else
       if ((aa_field == 2'b 01) && (di_bit == 0))
          instruction = "st?.aw       ";
       else
       if ((aa_field == 2'b 01) && (di_bit != 0))
          instruction = "st?.aw.di    ";
       else
       if ((aa_field == 2'b 10) && (di_bit == 0))
          instruction = "st?.ab       ";
       else
       if ((aa_field == 2'b 10) && (di_bit != 0))
          instruction = "st?.ab.di    ";
       else
       if ((aa_field == 2'b 11) && (di_bit == 0))
          instruction = "st?.as       ";
       else
       if ((aa_field == 2'b 11) && (di_bit != 0))
          instruction = "st?.as.di    ";
endcase

// Condition Codes 
case (cond_code)
  5'h01: cond_code_txt   = "eq "; // Basecase condition codes
  5'h02: cond_code_txt   = "ne ";
  5'h03: cond_code_txt   = "p  ";
  5'h04: cond_code_txt   = "n  ";
  5'h05: cond_code_txt   = "cs ";
  5'h06: cond_code_txt   = "cc ";
  5'h07: cond_code_txt   = "vs ";
  5'h08: cond_code_txt   = "vc ";
  5'h09: cond_code_txt   = "gt ";
  5'h0a: cond_code_txt   = "ge ";
  5'h0b: cond_code_txt   = "lt ";
  5'h0c: cond_code_txt   = "le ";
  5'h0d: cond_code_txt   = "hi ";
  5'h0e: cond_code_txt   = "ls ";
  5'h0f: cond_code_txt   = "pnz";


  5'h10: if (USE_XMAC == 1)
           cond_code_txt = "s  ";  // extension condition codes
         else
           cond_code_txt = "ss ";
  5'h11: if (USE_XMAC == 1)
           cond_code_txt = "sc "; 
         else
           cond_code_txt = "sc ";
  5'h12: if (USE_XMAC == 1)
           cond_code_txt = "as "; 
         else
           cond_code_txt = "mh ";
  5'h13: if (USE_XMAC == 1)
           cond_code_txt = "asc"; 
         else
           cond_code_txt = "ml ";
  5'h18: cond_code_txt   = "az ";
  5'h19: cond_code_txt   = "azc";
  5'h1A: cond_code_txt   = "an ";
  5'h1B: cond_code_txt   = "ap ";
  5'h1C: cond_code_txt   = "ps ";
  5'h1D: cond_code_txt   = "psc";
  default: cond_code_txt = "qq?";

 endcase

case (br_cond_code)
  4'h 0: br_code_txt   = "req "; // Basecase condition codes
  4'h 1: br_code_txt   = "rne ";
  4'h 2: br_code_txt   = "rlt ";
  4'h 3: br_code_txt   = "rge ";
  4'h 4: br_code_txt   = "rlo ";
  4'h 5: br_code_txt   = "rhs ";
  4'h e: br_code_txt   = "bit0";
  4'h f: br_code_txt   = "bit1";
  default: br_code_txt = "qq??";

 endcase

// Nullify Instruction modes for branch instructions
if (nullify_inst == 1'b 0)
   begin
   delay_slot_txt = ".nd";
   end
else
   begin
   delay_slot_txt = ".d ";
   end

// b, bl and br instructions have operands encoded in instruction
// and therefore are treated separately

case (instruction)
    "OP_BCC       ":
       if (inst_ip[16] == 1'b 0)
       begin
          if ((nullify_inst != 1'b 0) && (cond_code == 0))
             instruction = {"b", delay_slot_txt, " s21     "};
          else
          if ((nullify_inst != 1'b 0) && (cond_code !=0))
             instruction = {"b", cond_code_txt, delay_slot_txt, " s21  "};
          else
          if ((nullify_inst == 0) && (cond_code !=0))
             instruction = {"b", cond_code_txt, " s21     "}; 
       end
       else
       begin
          if (nullify_inst != 1'b 0)
             instruction = {"b", delay_slot_txt, " s25     "};
          else
          if (nullify_inst == 0)
             instruction = "b s25        "; 
       end

    "OP_BLCC      ":
       if ((inst_ip[16] == 1'b 0) && (inst_ip[17] == 1'b 0))
       begin
          if ((nullify_inst != 1'b 0) && (cond_code == 0))
             instruction = {"bl", delay_slot_txt, " s22    "};
          else
          if ((nullify_inst != 1'b 0) && (cond_code !=0))
             instruction = {"bl", cond_code_txt, delay_slot_txt, " s22 "};
          else
          if ((nullify_inst == 0) && (cond_code !=0))
             instruction = {"bl", cond_code_txt, " s22    "};
       end
       else
       if ((inst_ip[16] == 1'b 0) && (inst_ip[17] == 1'b 1))
       begin
          if (nullify_inst != 1'b 0)
             instruction = {"bl", delay_slot_txt, " s25    "};
          else
          if (nullify_inst == 0)
             instruction = "bl s25       "; 
       end
       else
       begin
          if (nullify_inst != 1'b 0)
             instruction = {"b", br_code_txt, delay_slot_txt, " s9  "};
          else
          if (nullify_inst == 0)
             instruction = {"b", br_code_txt, " s9     "};
       end

endcase


// Instruction suffixes for basecase start here - just going through
// the subopcodes chronologically.
//

case (instruction)

   "OP_FMT1      ": 
      case (subop)
         SO_MPYW :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "mpyw.f       ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"mpyw.", cond_code_txt, ".f   "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"mpyw.", cond_code_txt, "     "};
           else
               instruction = "mpyw         ";

         SO_MPYUW :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "mpyuw.f      ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"mpyuw.", cond_code_txt, ".f  "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"mpyuw.", cond_code_txt, "    "};
           else
               instruction = "mpyuw        ";

         SO_ADD :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "add.f        ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"add.", cond_code_txt, ".f    "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"add.", cond_code_txt, "      "};

           else
               instruction = "add          ";

         SO_ADC :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "adc.f        ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"adc.", cond_code_txt, ".f    "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"adc.", cond_code_txt, "      "};
           else
               instruction = "adc          ";


         SO_SUB :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "sub.f        ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"sub.", cond_code_txt, ".f    "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"sub.", cond_code_txt, "      "};
           else
               instruction = "sub          ";


         SO_SBC :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "sbc.f        ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"sbc.", cond_code_txt, ".f    "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"sbc.", cond_code_txt, "      "};
           else
               instruction = "sbc          ";


         SO_AND :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "and.f        ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"and.", cond_code_txt, ".f    "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"and.", cond_code_txt, "      "};
           else
               instruction = "and          ";


         SO_OR :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "or.f         ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"or.", cond_code_txt, ".f     "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"or.", cond_code_txt, "       "};
           else
               instruction = "or           ";


         SO_BIC :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "bic.f        ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"bic.", cond_code_txt, ".f    "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"bic.", cond_code_txt, "      "};
           else
               instruction = "bic          ";


         SO_XOR :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "xor.f        ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"xor.", cond_code_txt, ".f    "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"xor.", cond_code_txt, "      "};
           else
               instruction = "xor          ";


         SO_MAX :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "max.f        ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"max.", cond_code_txt, ".f    "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"max.", cond_code_txt, "      "};
           else
               instruction = "max          ";


         SO_MIN :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "min.f        ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"min.", cond_code_txt, ".f    "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"min.", cond_code_txt, "      "};
           else
               instruction = "min          ";


         SO_MOV :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "mov.f        ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"mov.", cond_code_txt, ".f    "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"mov.", cond_code_txt, "      "};
            else
              if (setflags  == 0      &&
                  cond_code == 0      && 
                  ldr_mode  == FMT_U6 && 
                  afield    == 0      &&
                  bfield    == RLIMM  &&
                  cfield    == 0)
               instruction = "nop          ";
              else
               instruction = "mov          ";


         SO_TST :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "tst.f        ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"tst.", cond_code_txt, ".f    "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"tst.", cond_code_txt, "      "};
           else
               instruction = "tst          ";


         SO_CMP :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "cmp.f        ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"cmp.", cond_code_txt, ".f    "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"cmp.", cond_code_txt, "      "};
           else
               instruction = "cmp          ";


         SO_RCMP :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "rcmp.f       ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"rcmp.", cond_code_txt, ".f   "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"rcmp.", cond_code_txt, "     "};
           else
               instruction = "rcmp         ";


         SO_RSUB :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "rsub.f       ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"rsub.", cond_code_txt, ".f   "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"rsub.", cond_code_txt, "     "};
           else
               instruction = "rsub         ";


         SO_BSET :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "bset.f       ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"bset.", cond_code_txt, ".f   "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"bset.", cond_code_txt, "     "};
           else
               instruction = "bset         ";


         SO_BCLR :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "bclr.f       ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"bclr.", cond_code_txt, ".f   "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"bclr.", cond_code_txt, "     "};
           else
               instruction = "bclr         ";


         SO_BTST :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "btst.f       ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"btst.", cond_code_txt, ".f   "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"btst.", cond_code_txt, "     "};
           else
               instruction = "btst         ";


         SO_BXOR :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "bxor.f       ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"bxor.", cond_code_txt, ".f   "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"bxor.", cond_code_txt, "     "};
           else
               instruction = "bxor         ";


         SO_BMSK :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "bmsk.f       ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"bmsk.", cond_code_txt, ".f   "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"bmsk.", cond_code_txt, "     "};
           else
               instruction = "bmsk         ";


         SO_ADD1 :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "add1.f       ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"add1.", cond_code_txt, ".f   "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"add1.", cond_code_txt, "     "};
           else
               instruction = "add1         ";


         SO_ADD2 :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "add2.f       ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"add2.", cond_code_txt, ".f   "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"add2.", cond_code_txt, "     "};
           else
               instruction = "add2         ";


         SO_ADD3 :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "add3.f       ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"add3.", cond_code_txt, ".f   "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"add3.", cond_code_txt, "     "};
           else
               instruction = "add3         ";


         SO_SUB1 :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "sub1.f       ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"sub1.", cond_code_txt, ".f   "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"sub1.", cond_code_txt, "     "};
           else
               instruction = "sub1         ";


         SO_SUB2 :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "sub2.f       ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"sub2.", cond_code_txt, ".f   "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"sub2.", cond_code_txt, "     "};
           else
               instruction = "sub2         ";


         SO_SUB3 :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "sub3.f       ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"sub3.", cond_code_txt, ".f   "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"sub3.", cond_code_txt, "     "};
           else
               instruction = "sub3         ";


         SO_J :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "j.f          ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"j", cond_code_txt, ".f       "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"j", cond_code_txt, "         "};
           else
               instruction = "j            ";

         SO_J_D :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "j.d.f        ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"j", cond_code_txt, ".d.f     "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"j", cond_code_txt, ".d       "};
           else
               instruction = "j.d          ";

         SO_JL :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "jl.f         ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"jl", cond_code_txt, ".f      "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"jl", cond_code_txt, "        "};
           else
               instruction = "jl           ";

         SO_JL_D :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "jl.d.f       ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"jl", cond_code_txt, ".d.f    "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"jl", cond_code_txt, ".d      "};
           else
               instruction = "jl.d         ";

         SO_LP :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "lp.f         ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"lp", cond_code_txt, ".f      "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"lp", cond_code_txt, "        "};
           else
               instruction = "lp           ";

         SO_FLAG :
            if ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG))
               instruction = "flag         ";
           else
            // total no. of characters is 13, hence spaces
            if (cond_code != 0 && ldr_mode == FMT_COND_REG)
               instruction = {"flag.", cond_code_txt, "     "};

         SO_LR : instruction = "lr           ";

         SO_SR : instruction = "sr           ";

         SO_SOP :
            case (afield)
               MO_ASL : 
                  if ((setflags != 0) &&
                      ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                       (ldr_mode != FMT_COND_REG)))
                     instruction = "asl.f        ";
                  else
                  // total no. of characters is 13, hence spaces
                  if ((setflags != 0) &&
                      (cond_code != 0 && ldr_mode == FMT_COND_REG))
                     instruction = {"asl.", cond_code_txt, ".f    "};
                  else
                  // total no. of characters is 13, hence spaces
                  if ((setflags == 0) &&
                      (cond_code != 0 && ldr_mode == FMT_COND_REG))
                     instruction = {"asl.", cond_code_txt, "      "};
                  else
                     instruction = "asl          ";


               MO_ASR : 
                  if ((setflags != 0) &&
                      ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                       (ldr_mode != FMT_COND_REG)))
                     instruction = "asr.f        ";
                  else
                  // total no. of characters is 13, hence spaces
                  if ((setflags != 0) &&
                      (cond_code != 0 && ldr_mode == FMT_COND_REG))
                     instruction = {"asr.", cond_code_txt, ".f    "};
                  else
                  // total no. of characters is 13, hence spaces
                  if ((setflags == 0) &&
                      (cond_code != 0 && ldr_mode == FMT_COND_REG))
                     instruction = {"asr.", cond_code_txt, "      "};
                  else
                     instruction = "asr          ";

               MO_LSR : 
                  if ((setflags != 0) &&
                      ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                       (ldr_mode != FMT_COND_REG)))
                     instruction = "lsr.f        ";
                  else
                  // total no. of characters is 13, hence spaces
                  if ((setflags != 0) &&
                      (cond_code != 0 && ldr_mode == FMT_COND_REG))
                     instruction = {"lsr.", cond_code_txt, ".f    "};
                  else
                  // total no. of characters is 13, hence spaces
                  if ((setflags == 0) &&
                      (cond_code != 0 && ldr_mode == FMT_COND_REG))
                     instruction = {"lsr.", cond_code_txt, "      "};
                  else
                     instruction = "lsr          ";

               MO_ROR : 
                  if ((setflags != 0) &&
                      ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                       (ldr_mode != FMT_COND_REG)))
                     instruction = "ror.f        ";
                  else
                  // total no. of characters is 13, hence spaces
                  if ((setflags != 0) &&
                      (cond_code != 0 && ldr_mode == FMT_COND_REG))
                     instruction = {"ror.", cond_code_txt, ".f    "};
                  else
                  // total no. of characters is 13, hence spaces
                  if ((setflags == 0) &&
                      (cond_code != 0 && ldr_mode == FMT_COND_REG))
                     instruction = {"ror.", cond_code_txt, "      "};
                  else
                     instruction = "ror          ";

               MO_RRC : 
                  if ((setflags != 0) &&
                      ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                       (ldr_mode != FMT_COND_REG)))
                     instruction = "rrc.f        ";
                  else
                  // total no. of characters is 13, hence spaces
                  if ((setflags != 0) &&
                      (cond_code != 0 && ldr_mode == FMT_COND_REG))
                     instruction = {"rrc.", cond_code_txt, ".f    "};
                  else
                  // total no. of characters is 13, hence spaces
                  if ((setflags == 0) &&
                      (cond_code != 0 && ldr_mode == FMT_COND_REG))
                     instruction = {"rrc.", cond_code_txt, "      "};
                  else
                     instruction = "rrc          ";

               MO_SEXB : 
                  if ((setflags != 0) &&
                      ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                       (ldr_mode != FMT_COND_REG)))
                     instruction = "sexb.f       ";
                  else
                  // total no. of characters is 13, hence spaces
                  if ((setflags != 0) &&
                      (cond_code != 0 && ldr_mode == FMT_COND_REG))
                     instruction = {"sexb.", cond_code_txt, ".f   "};
                  else
                  // total no. of characters is 13, hence spaces
                  if ((setflags == 0) &&
                      (cond_code != 0 && ldr_mode == FMT_COND_REG))
                     instruction = {"sexb.", cond_code_txt, "     "};
                  else
                     instruction = "sexb         ";

               MO_SEXW : 
                  if ((setflags != 0) &&
                      ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                       (ldr_mode != FMT_COND_REG)))
                     instruction = "sexw.f       ";
                  else
                  // total no. of characters is 13, hence spaces
                  if ((setflags != 0) &&
                      (cond_code != 0 && ldr_mode == FMT_COND_REG))
                     instruction = {"sexw.", cond_code_txt, ".f   "};
                  else
                  // total no. of characters is 13, hence spaces
                  if ((setflags == 0) &&
                      (cond_code != 0 && ldr_mode == FMT_COND_REG))
                     instruction = {"sexw.", cond_code_txt, "     "};
                  else
                     instruction = "sexw         ";

               MO_EXTB : 
                  if ((setflags != 0) &&
                      ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                       (ldr_mode != FMT_COND_REG)))
                     instruction = "extb.f       ";
                  else
                  // total no. of characters is 13, hence spaces
                  if ((setflags != 0) &&
                      (cond_code != 0 && ldr_mode == FMT_COND_REG))
                     instruction = {"extb.", cond_code_txt, ".f   "};
                  else
                  // total no. of characters is 13, hence spaces
                  if ((setflags == 0) &&
                      (cond_code != 0 && ldr_mode == FMT_COND_REG))
                     instruction = {"extb.", cond_code_txt, "     "};
                  else
                     instruction = "extb         ";

               MO_EXTW : 
                  if ((setflags != 0) &&
                      ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                       (ldr_mode != FMT_COND_REG)))
                     instruction = "extw.f       ";
                  else
                  // total no. of characters is 13, hence spaces
                  if ((setflags != 0) &&
                      (cond_code != 0 && ldr_mode == FMT_COND_REG))
                     instruction = {"extw.", cond_code_txt, ".f   "};
                  else
                  // total no. of characters is 13, hence spaces
                  if ((setflags == 0) &&
                      (cond_code != 0 && ldr_mode == FMT_COND_REG))
                     instruction = {"extw.", cond_code_txt, "     "};
                  else
                     instruction = "extw         ";

               MO_ABS : 
                  if ((setflags != 0) &&
                      ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                       (ldr_mode != FMT_COND_REG)))
                     instruction = "abs.f        ";
                  else
                  // total no. of characters is 13, hence spaces
                  if ((setflags != 0) &&
                      (cond_code != 0 && ldr_mode == FMT_COND_REG))
                     instruction = {"abs.", cond_code_txt, ".f    "};
                  else
                  // total no. of characters is 13, hence spaces
                  if ((setflags == 0) &&
                      (cond_code != 0 && ldr_mode == FMT_COND_REG))
                     instruction = {"abs.", cond_code_txt, "      "};
                  else
                     instruction = "abs          ";

               MO_NOT : 
                  if ((setflags != 0) &&
                      ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                       (ldr_mode != FMT_COND_REG)))
                     instruction = "not.f        ";
                  else
                  // total no. of characters is 13, hence spaces
                  if ((setflags != 0) &&
                      (cond_code != 0 && ldr_mode == FMT_COND_REG))
                     instruction = {"not.", cond_code_txt, ".f    "};
                  else
                  // total no. of characters is 13, hence spaces
                  if ((setflags == 0) &&
                      (cond_code != 0 && ldr_mode == FMT_COND_REG))
                     instruction = {"not.", cond_code_txt, "      "};
                  else
                     instruction = "not          ";

               MO_RLC : 
                  if ((setflags != 0) &&
                      ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                       (ldr_mode != FMT_COND_REG)))
                     instruction = "rlc.f        ";
                  else
                  // total no. of characters is 13, hence spaces
                  if ((setflags != 0) &&
                      (cond_code != 0 && ldr_mode == FMT_COND_REG))
                     instruction = {"rlc.", cond_code_txt, ".f    "};
                  else
                  // total no. of characters is 13, hence spaces
                  if ((setflags == 0) &&
                      (cond_code != 0 && ldr_mode == FMT_COND_REG))
                     instruction = {"rlc.", cond_code_txt, "      "};
                  else
                     instruction = "rlc          ";

               MO_ZOP : 
                  case (bfield)
                     ZO_SLEEP : instruction = "sleep        ";
                     ZO_SWI   : instruction = "swi          ";
                     ZO_SYNC  : instruction = "sync         ";
                     default  : instruction = "unknown      ";
                  endcase

               default : instruction = "unknown      ";

            endcase

         SO_LD :
            if ((aa_field == 2'b 00) && (di_bit == 0))
               instruction = "ld           ";
            else
            if ((aa_field == 2'b 01) && (di_bit == 0))
               instruction = "ld.aw        ";
            else
            if ((aa_field == 2'b 10) && (di_bit == 0))
               instruction = "ld.ab        ";
            else
            if ((aa_field == 2'b 11) && (di_bit == 0))
               instruction = "ld.as        ";
            else
            if ((aa_field == 2'b 00) && (di_bit != 0))
               instruction = "ld.di        ";
            else
            if ((aa_field == 2'b 01) && (di_bit != 0))
               instruction = "ld.aw.di     ";
            else
            if ((aa_field == 2'b 10) && (di_bit != 0))
               instruction = "ld.ab.di     ";
            else
            if ((aa_field == 2'b 11) && (di_bit != 0))
               instruction = "ld.as.di     ";

         SO_LD_X :
            if ((aa_field == 2'b 00) && (di_bit == 0))
               instruction = "ld.x         ";
            else
            if ((aa_field == 2'b 01) && (di_bit == 0))
               instruction = "ld.x.aw      ";
            else
            if ((aa_field == 2'b 10) && (di_bit == 0))
               instruction = "ld.x.ab      ";
            else
            if ((aa_field == 2'b 11) && (di_bit == 0))
               instruction = "ld.x.as      ";
            else
            if ((aa_field == 2'b 00) && (di_bit != 0))
               instruction = "ld.x.di      ";
            else
            if ((aa_field == 2'b 01) && (di_bit != 0))
               instruction = "ld.x.aw.di   ";
            else
            if ((aa_field == 2'b 10) && (di_bit != 0))
               instruction = "ld.x.ab.di   ";
            else
            if ((aa_field == 2'b 11) && (di_bit != 0))
               instruction = "ld.x.as.di   ";

         SO_LDB :
            if ((aa_field == 2'b 00) && (di_bit == 0))
               instruction = "ldb          ";
            else
            if ((aa_field == 2'b 01) && (di_bit == 0))
               instruction = "ldb.aw       ";
            else
            if ((aa_field == 2'b 10) && (di_bit == 0))
               instruction = "ldb.ab       ";
            else
            if ((aa_field == 2'b 11) && (di_bit == 0))
               instruction = "ldb.as       ";
            else
            if ((aa_field == 2'b 00) && (di_bit != 0))
               instruction = "ldb.di       ";
            else
            if ((aa_field == 2'b 01) && (di_bit != 0))
               instruction = "ldb.aw.di    ";
            else
            if ((aa_field == 2'b 10) && (di_bit != 0))
               instruction = "ldb.ab.di    ";
            else
            if ((aa_field == 2'b 11) && (di_bit != 0))
               instruction = "ldb.as.di    ";

         SO_LDB_X :
            if ((aa_field == 2'b 00) && (di_bit == 0))
               instruction = "ldb.x        ";
            else
            if ((aa_field == 2'b 01) && (di_bit == 0))
               instruction = "ldb.x.aw     ";
            else
            if ((aa_field == 2'b 10) && (di_bit == 0))
               instruction = "ldb.x.ab     ";
            else
            if ((aa_field == 2'b 11) && (di_bit == 0))
               instruction = "ldb.x.as     ";
            else
            if ((aa_field == 2'b 00) && (di_bit != 0))
               instruction = "ldb.x.di     ";
            else
            if ((aa_field == 2'b 01) && (di_bit != 0))
               instruction = "ldb.x.aw.di  ";
            else
            if ((aa_field == 2'b 10) && (di_bit != 0))
               instruction = "ldb.x.ab.di  ";
            else
            if ((aa_field == 2'b 11) && (di_bit != 0))
               instruction = "ldb.x.as.di  ";

         SO_LDW :
            if ((aa_field == 2'b 00) && (di_bit == 0))
               instruction = "ldw          ";
            else
            if ((aa_field == 2'b 01) && (di_bit == 0))
               instruction = "ldw.aw       ";
            else
            if ((aa_field == 2'b 10) && (di_bit == 0))
               instruction = "ldw.ab       ";
            else
            if ((aa_field == 2'b 11) && (di_bit == 0))
               instruction = "ldw.as       ";
            else
            if ((aa_field == 2'b 00) && (di_bit != 0))
               instruction = "ldw.di       ";
            else
            if ((aa_field == 2'b 01) && (di_bit != 0))
               instruction = "ldw.aw.di    ";
            else
            if ((aa_field == 2'b 10) && (di_bit != 0))
               instruction = "ldw.ab.di    ";
            else
            if ((aa_field == 2'b 11) && (di_bit != 0))
               instruction = "ldw.as.di    ";


         SO_LDW_X :
            if ((aa_field == 2'b 00) && (di_bit == 0))
               instruction = "ldw.x        ";
            else
            if ((aa_field == 2'b 01) && (di_bit == 0))
               instruction = "ldw.x.aw     ";
            else
            if ((aa_field == 2'b 10) && (di_bit == 0))
               instruction = "ldw.x.ab     ";
            else
            if ((aa_field == 2'b 11) && (di_bit == 0))
               instruction = "ldw.x.as     ";
            else
            if ((aa_field == 2'b 00) && (di_bit != 0))
               instruction = "ldw.x.di     ";
            else
            if ((aa_field == 2'b 01) && (di_bit != 0))
               instruction = "ldw.x.aw.di  ";
            else
            if ((aa_field == 2'b 10) && (di_bit != 0))
               instruction = "ldw.x.ab.di  ";
            else
            if ((aa_field == 2'b 11) && (di_bit != 0))
               instruction = "ldw.x.as.di  ";

         default : instruction = "unknown      ";

      endcase   

endcase 
        
// Adding Extension Instructions, Separate from basecase in case of
// conflicts eg lsl, asl
// Instruction suffixes for basecase start here - just going through
// the subopcodes chronologically.
//

case (instruction)

   "OP_FMT2      ": 
      case (subop)
         MO_ASL_EXT :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "asl.f        ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"asl.", cond_code_txt, ".f    "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"asl.", cond_code_txt, "      "};
           else
               instruction = "asl          ";

         MO_LSR_EXT :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "lsr.f        ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"lsr.", cond_code_txt, ".f    "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"lsr.", cond_code_txt, "      "};
           else
               instruction = "lsr          ";

         MO_ASR_EXT :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "asr.f        ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"asr.", cond_code_txt, ".f    "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"asr.", cond_code_txt, "      "};
           else
               instruction = "asr          ";
        
         MO_ASRS :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "asrs.f       ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"asrs.", cond_code_txt, ".f   "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"asrs.", cond_code_txt, "     "};
           else
               instruction = "asrs         ";

         MO_ASLS :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "asls.f       ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"asls.", cond_code_txt, ".f   "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"asls.", cond_code_txt, "     "};
           else
               instruction = "asls         ";
        
         MO_ROR_EXT :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "ror.f        ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"ror.", cond_code_txt, ".f    "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"ror.", cond_code_txt, "      "};
           else
               instruction = "ror          ";

         MO_MUL64 :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "mul64.f      ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"mul64.", cond_code_txt, ".f  "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"mul64.", cond_code_txt, "    "};
           else
               instruction = "mul64        ";

         MO_MULU64 :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "mulu64.f     ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"mulu64.", cond_code_txt, ".f "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"mulu64.", cond_code_txt, "   "};
           else
               instruction = "mulu64       ";

        MO_ADDS :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "adds.f       ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"adds.", cond_code_txt, ".f   "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"adds.", cond_code_txt, "     "};
           else
               instruction = "adds         ";

        MO_SUBS :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "subs.f       ";
           else
             // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"subs.", cond_code_txt, ".f   "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"subs.", cond_code_txt, "     "};
           else
               instruction = "subs         ";
                
        MO_ADDSDW :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "addsdw.f     ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"addsdw.", cond_code_txt, ".f "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"addsdw.", cond_code_txt, "   "};
           else
               instruction = "addsdw       ";

        MO_SUBSDW :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "subsdw.f     ";
           else
             // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"subsdw.", cond_code_txt, ".f "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"subsdw.", cond_code_txt, "   "};
           else
               instruction = "subsdw       ";

        MO_CRC :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "crc.f        ";
           else
             // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"crc.", cond_code_txt, ".f    "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"crc.", cond_code_txt, "      "};
           else
               instruction = "crc          ";                

        MO_DIVAW :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "divaw.f      ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"divaw.", cond_code_txt, ".f  "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"divaw.", cond_code_txt, "    "};
           else
               instruction = "divaw        ";
                

        MO_MULRT  :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "mulrt.f      ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"mulrt.", cond_code_txt, ".f  "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"mulrt.", cond_code_txt, "   "};
           else
               instruction = "mulrt        ";
                
                
        MO_MULUT :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "mulut.f      ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"mulut.", cond_code_txt, ".f "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"mulut.", cond_code_txt, "   "};
           else
               instruction = "mulut        ";

        MO_MULT :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "mult.f       ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"mult.", cond_code_txt, ".f   "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"mult.", cond_code_txt, "    "};
           else
               instruction = "mult         ";
        
        MO_MACT :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "mact.f       ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"mact.", cond_code_txt, ".f   "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"mact.", cond_code_txt, "     "};
           else
               instruction = "mact         ";
                
        MO_MACRT :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "macrt.f      ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"macrt.", cond_code_txt, ".f  "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"macrt.", cond_code_txt, "    "};
           else
               instruction = "macrt        ";
                
        MO_MACUT :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "macut.f      ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"macut.", cond_code_txt, ".f  "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"macut.", cond_code_txt, "    "};
           else
               instruction = "macut        ";

        MO_MSUBT  :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "msubt.f      ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"msubt.", cond_code_txt, ".f  "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"msubt.", cond_code_txt, "    "};
           else
               instruction = "msubt        ";

                
        MO_MULRDW :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "mulrdw.f     ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"mulrdw.", cond_code_txt, ".f "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"mulrdw.", cond_code_txt, "   "};
           else
               instruction = "mulrdw       ";
                
                
        MO_MULUDW :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "muludw.f     ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"muludw.", cond_code_txt, ".f "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"muludw.", cond_code_txt, "   "};
           else
               instruction = "muludw       ";

        MO_MULDW :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "muldw.f      ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"muldw.", cond_code_txt, ".f  "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"muldw.", cond_code_txt, "    "};
          else
               instruction = "muldw        ";
        
        MO_MACDW :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "macdw.f      ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"macdw.", cond_code_txt, ".f  "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"macdw.", cond_code_txt, "    "};
           else
               instruction = "macdw        ";
                
        MO_MACRDW :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "macrdw.f      ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"macrdw.", cond_code_txt, ".f  "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"macrdw.", cond_code_txt, "    "};
           else
               instruction = "macrdw       ";
                
        MO_CMACRDW :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "cmacrdw.f    ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"cmacrdw.", cond_code_txt, ".f "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"cmacrdw.", cond_code_txt, "   "};
           else
               instruction = "cmacrdw      ";
                
        MO_MACUDW :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "macudw.f     ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"macudw.", cond_code_txt, ".f "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"macudw.", cond_code_txt, "   "};
           else
               instruction = "macudw       ";

        MO_MSUBDW :
            if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
               instruction = "msubdw.f     ";
           else
            // total no. of characters is 13, hence spaces
            if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"msubdw.", cond_code_txt, ".f  "};
           else
            // total no. of characters is 13, hence spaces
            if ((setflags == 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
               instruction = {"msubdw.", cond_code_txt, "    "};
           else
               instruction = "msubdw       ";
        
         SO_SOP :
            case (afield)
               SO_SWAP : 
               if ((setflags != 0) &&
                   ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                    (ldr_mode != FMT_COND_REG)))
                  instruction = "swap.f       ";
               else
               // total no. of characters is 13, hence spaces
               if ((setflags != 0) &&
                   (cond_code != 0 && ldr_mode == FMT_COND_REG))
                  instruction = {"swap.", cond_code_txt, ".f   "};
               else
               // total no. of characters is 13, hence spaces
               if ((setflags == 0) &&
                   (cond_code != 0 && ldr_mode == FMT_COND_REG))
                  instruction = {"swap.", cond_code_txt, "     "};
               else
                  instruction = "swap         ";

            SO_NORM :
               if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
                  instruction = "norm.f       ";
               else
               // total no. of characters is 13, hence spaces
               if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
                  instruction = {"norm.", cond_code_txt, ".f   "};
               else
               // total no. of characters is 13, hence spaces
               if ((setflags == 0) &&
                   (cond_code != 0 && ldr_mode == FMT_COND_REG))
                  instruction = {"norm.", cond_code_txt, "     "};
               else
                  instruction = "norm         ";


             SO_NORMW :
               if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
                  instruction = "normw.f      ";
               else
               // total no. of characters is 13, hence spaces
               if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
                  instruction = {"normw.", cond_code_txt, ".f  "};
               else
               // total no. of characters is 13, hence spaces
               if ((setflags == 0) &&
                   (cond_code != 0 && ldr_mode == FMT_COND_REG))
                  instruction = {"normw.", cond_code_txt, "    "};
               else
                  instruction = "normw        ";
 
           SO_NEGS :
                if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
                  instruction = "negs.f       ";
               else
               // total no. of characters is 13, hence spaces
               if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
                  instruction = {"negs.", cond_code_txt, ".f   "};
               else
               // total no. of characters is 13, hence spaces
               if ((setflags == 0) &&
                   (cond_code != 0 && ldr_mode == FMT_COND_REG))
                  instruction = {"negs.", cond_code_txt, "     "};
               else
                  instruction = "negs         ";

             SO_NEGSW :
               if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
                  instruction = "negsw.f      ";
               else
               // total no. of characters is 13, hence spaces
               if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
                  instruction = {"negsw.", cond_code_txt, ".f  "};
               else
               // total no. of characters is 13, hence spaces
               if ((setflags == 0) &&
                   (cond_code != 0 && ldr_mode == FMT_COND_REG))
                  instruction = {"negsw.", cond_code_txt, "    "};
               else
                  instruction = "negsw        ";
 
            SO_ABSS :
                if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
                  instruction = "abss.f       ";
               else
               // total no. of characters is 13, hence spaces
               if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
                  instruction = {"abss.", cond_code_txt, ".f   "};
               else
               // total no. of characters is 13, hence spaces
               if ((setflags == 0) &&
                   (cond_code != 0 && ldr_mode == FMT_COND_REG))
                  instruction = {"abss.", cond_code_txt, "     "};
               else
                  instruction = "abss         ";

             SO_ABSSW :
               if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
                  instruction = "abbsw.f      ";
               else
               // total no. of characters is 13, hence spaces
               if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
                  instruction = {"abbsw.", cond_code_txt, ".f  "};
               else
               // total no. of characters is 13, hence spaces
               if ((setflags == 0) &&
                   (cond_code != 0 && ldr_mode == FMT_COND_REG))
                  instruction = {"abbsw.", cond_code_txt, "    "};
               else
                  instruction = "abbsw        ";
 
 
             SO_SAT16 :
                if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
                  instruction = "sat16.f     ";
               else
               // total no. of characters is 13, hence spaces
               if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
                  instruction = {"sat16.", cond_code_txt, ".f "};
               else
               // total no. of characters is 13, hence spaces
               if ((setflags == 0) &&
                   (cond_code != 0 && ldr_mode == FMT_COND_REG))
                  instruction = {"sat16.", cond_code_txt, "   "};
               else
                  instruction = "sat16       ";

             SO_RND16 :
               if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
                  instruction = "rnd16.f      ";
               else
               // total no. of characters is 13, hence spaces
               if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
                  instruction = {"rnd16.", cond_code_txt, ".f  "};
               else
               // total no. of characters is 13, hence spaces
               if ((setflags == 0) &&
                   (cond_code != 0 && ldr_mode == FMT_COND_REG))
                  instruction = {"rnd16.", cond_code_txt, "    "};
               else
                  instruction = "rnd16        ";
 
             SO_VBFDW :
               if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
                  instruction = "vbfdw.f     ";
               else
               // total no. of characters is 13, hence spaces
               if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
                  instruction = {"vbfdw.", cond_code_txt, ".f "};
               else
               // total no. of characters is 13, hence spaces
               if ((setflags == 0) &&
                   (cond_code != 0 && ldr_mode == FMT_COND_REG))
                  instruction = {"vbfdw.", cond_code_txt, "   "};
               else
                  instruction = "vbfdw       ";
                           
             SO_FBFDW :
               if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
                  instruction = "fbfdw.f      ";
               else
               // total no. of characters is 13, hence spaces
               if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
                  instruction = {"fbfdw.", cond_code_txt, ".f  "};
               else
               // total no. of characters is 13, hence spaces
               if ((setflags == 0) &&
                   (cond_code != 0 && ldr_mode == FMT_COND_REG))
                  instruction = {"fbfdw.", cond_code_txt, "    "};
               else
                  instruction = "fbfdw        ";        
                   
             SO_FBFT :
               if ((setflags != 0) &&
                ((cond_code == 0 && ldr_mode == FMT_COND_REG) ||
                 (ldr_mode != FMT_COND_REG)))
                  instruction = "fbft.f       ";
               else
               // total no. of characters is 13, hence spaces
               if ((setflags != 0) &&
                (cond_code != 0 && ldr_mode == FMT_COND_REG))
                  instruction = {"fbft.", cond_code_txt, ".f   "};
               else
               // total no. of characters is 13, hence spaces
               if ((setflags == 0) &&
                   (cond_code != 0 && ldr_mode == FMT_COND_REG))
                  instruction = {"fbft.", cond_code_txt, "     "};
               else
                  instruction = "fbft         ";
              
               MO_ZOP : 
                  case (bfield)
                     default  : instruction = "unknown      ";
                  endcase

               default : instruction = "unknown      ";

            endcase 

         default : instruction = "unknown      ";

      endcase

          "OP_FMT3      ": 
          
              case (subop)


                         SO_SOP :
                    case (afield)
           
                                        MO_ZOP : 
                                  case (bfield)
                                                default  : instruction = "unknown      ";
                                        endcase                        

                                default  : instruction = "unknown      ";
                        endcase

                      default  : instruction = "unknown      ";
        endcase

          "OP_FMT4      ": 
          
              case (subop)
                         SO_SOP :
                    case (afield)
           
                                MO_ZOP : 
                          case (bfield)
                        default  : instruction = "unknown      ";
                        endcase                        

                default  : instruction = "unknown      ";
                endcase
                     
                default  : instruction = "unknown      ";
       endcase


endcase 

// checking for LIMM and that instruction is not b, bl or lp (which
// may have r62 by co-incidence in b or c field) 

   case (instruction)

    "OP_BLCC      " :
       if (inst_ip[16] == 1'b 0)
       begin
          flag = 0;
       end
       else
       begin
          if (bfield == 6'b 111110 ||
              (cfield == 6'b 111110 &&
               inst_ip[4] == 1'b 0))
             flag = 1;
          else
             flag = 0;
       end

    "OP_LD        ": 
       begin
          if (bfield == 6'b 111110)
             flag = 1;
          else
             flag = 0;
       end

    "OP_ST        ": 
       begin
          if (bfield == 6'b 111110 ||
              cfield == 6'b 111110)
             flag = 1;
          else
             flag = 0;
       end

    "OP_FMT1      " :
       if ((bfield == 6'b 111110) ||
           ((cfield == 6'b 111110) &&
             (ldr_mode == FMT_REG ||
              ldr_mode == FMT_COND_REG))) 
          flag = 1;
       else
          flag = 0;
    "OP_FMT2      " :
       if ((bfield == 6'b 111110) ||
           ((cfield == 6'b 111110) &&
             (ldr_mode == FMT_REG ||
              ldr_mode == FMT_COND_REG))) 
          flag = 1;
       else
          flag = 0;
    "OP_16_MV_ADD " :
          if (hifield == 6'b 111110)
             flag = 1;
          else
             flag = 0;
   default: flag = 0;
   endcase

  result = instruction; 
 end
endtask

//synopsys translate_on
// `endif
