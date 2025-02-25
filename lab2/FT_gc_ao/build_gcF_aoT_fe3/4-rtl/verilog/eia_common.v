// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 2002-2012 ARC International (Unpublished)
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
// 
module eia_common(
   clk,
   rst_a,
                       
//Other input signals available from the core can be inserted here:      
            
   en,
   s1en,
   s2en,
   s1bus,
   s2bus,
   en2,
   mload2b,
   mstore2b,
   p2opcode,
   p2subopcode,
   p2subopcode2_r,
   p2_a_field_r,
   p2_b_field_r,
   p2_c_field_r,
   p2iv,
   p2cc,
   p2conditional,
   p2sleep_inst,
   p2setflags,
   p2st,
   p2format,
   p2bch,
   p2dop32_inst,
   p2sop32_inst,
   p2zop32_inst,
   p2dop16_inst,
   p2sop16_inst,
   p2zop16_inst,
   en2b,
   p2b_iv,
   p2b_conditional,
   p2b_cc,
   p2b_dop32_inst,
   p2b_sop32_inst,
   p2b_zop32_inst,
   p2b_dop16_inst,
   p2b_sop16_inst,
   p2b_zop16_inst,
   p2b_opcode,
   p2b_subopcode,
   p2b_a_field_r,
   p2b_b_field_r,
   p2b_c_field_r,
   en3,
   p3iv,
   p3opcode,
   p3subopcode,
   p3subopcode2_r,
   p3a_field_r,
   p3b_field_r,
   p3c_field_r,
   p3cc,
   p3condtrue,
   p3destlimm,
   p3format,
   p3setflags,
   x_idecode3,
   p3wb_en,
   p3wba,
   p3lr,
   p3sr,
   p3dop32_inst,
   p3sop32_inst,
   p3zop32_inst,
   p3dop16_inst,
   p3sop16_inst,
   p3zop16_inst,
   aluflags_r,
   ext_s1val,
   ext_s2val,
   aux_addr,
   aux_dataw,
   aux_write,
   aux_read,
   h_addr,
   h_dataw,
   h_write,
   h_read,
   aux_access,
   s1a,
   s2a,
   fs2a,
   wba,
   wbdata,
   wben,
   core_access,
   dest,
   desten,
   sc_reg1,
   sc_reg2,
   p3_xmultic_nwb,
   ap_param0,
   ap_param0_read,
   ap_param0_write,
   ap_param1,
   ap_param1_read,
   ap_param1_write,
   uxdrx_reg,
   uxreg_hit,
   ux_da_am,
   ux_dar,
   uxivic,
   uxhold_host,
   uxnoaccess,
   ux2data_2_pc,
   ux1data,
   ux2data,
   ux_p2nosc1,
   ux_p2nosc2,
   uxp2bccmatch,
   uxp2ccmatch,
   uxp3ccmatch,
   uxholdup2,
   uxholdup2b,
   uxholdup3,
   ux_isop_decode2,
   ux_idop_decode2,
   ux_izop_decode2,
   uxnwb,
   uxp2idest,
   uxsetflags,
   xflags_r,
   ux_flgen,
   ux_multic_wba,
   ux_multic_wben,
   ux_multic_busy,
   ux_p1_rev_src,
   ux_p2_bfield_wb_a,
   ux_p2_jump_decode,
   ux_snglec_wben,
   uxresult,
   uxflags,
   dummy);

`include "arcutil_pkg_defines.v"
`include "arcutil.v"
`include "asmutil.v"
`include "extutil.v"
`include "che_util.v"
`include "xdefs.v"
`include "uxdefs.v"

// Extra include files required for extensions are inserted here.

input          clk; 
input          rst_a; 

//other input signals available from the core can be inserted here:      

input          en; 
input          s1en; 
input          s2en; 
input   [31:0] s1bus; 
input   [31:0] s2bus; 
//signals for alu and condition code extension:
input          en2; 
input          mload2b; 
input          mstore2b; 
input   [4:0]  p2opcode; 
input   [5:0]  p2subopcode; 
input   [4:0]  p2subopcode2_r; 
input   [5:0]  p2_a_field_r; 
input   [5:0]  p2_b_field_r; 
input   [5:0]  p2_c_field_r; 
input          p2iv; 
input   [3:0]  p2cc; 
input          p2conditional; 
input          p2sleep_inst; 
input          p2setflags; 
input          p2st; 
input   [1:0]  p2format; 
input          p2bch; 
input          p2dop32_inst; 
input          p2sop32_inst; 
input          p2zop32_inst; 
input          p2dop16_inst; 
input          p2sop16_inst; 
input          p2zop16_inst;
input          en2b; 
input          p2b_iv; 
input          p2b_conditional; 
input   [3:0]  p2b_cc;
input          p2b_dop32_inst;
input          p2b_sop32_inst;
input          p2b_zop32_inst;
input          p2b_dop16_inst;
input          p2b_sop16_inst;
input          p2b_zop16_inst;
input   [4:0]  p2b_opcode; 
input   [5:0]  p2b_subopcode; 
input   [5:0]  p2b_a_field_r; 
input   [5:0]  p2b_b_field_r; 
input   [5:0]  p2b_c_field_r; 
input          en3; 
input          p3iv; 
input   [4:0]  p3opcode; 
input   [5:0]  p3subopcode; 
input   [4:0]  p3subopcode2_r; 
input   [5:0]  p3a_field_r; 
input   [5:0]  p3b_field_r; 
input   [5:0]  p3c_field_r; 
input   [3:0]  p3cc; 
input          p3condtrue; 
input          p3destlimm; 
input   [1:0]  p3format; 
input          p3setflags; 
input          x_idecode3; 
input          p3wb_en; 
input   [5:0]  p3wba; 
input          p3lr; 
input          p3sr; 
input          p3dop32_inst; 
input          p3sop32_inst; 
input          p3zop32_inst; 
input          p3dop16_inst; 
input          p3sop16_inst; 
input          p3zop16_inst; 
input   [3:0]  aluflags_r; 
input   [31:0] ext_s1val; 
input   [31:0] ext_s2val;
//signals for xauxregs extension:
input   [31:0] aux_addr; 
input   [31:0] aux_dataw; 
input          aux_write; 
input          aux_read; 
input   [31:0] h_addr; 
input   [31:0] h_dataw; 
input          h_write; 
input          h_read; 
input          aux_access; 
//signals for xcoreregs extension:
input   [5:0]  s1a; 
input   [5:0]  s2a; 
input   [5:0]  fs2a; 
input   [5:0]  wba; 
input   [31:0] wbdata; 
input          wben; 
input          core_access; 
input   [5:0]  dest; 
input          desten; 
input          sc_reg1; 
input          sc_reg2; 
//signals for multi-cycle extension:
input          p3_xmultic_nwb; 

output  [31:0] ap_param0;
output         ap_param0_read;
output         ap_param0_write;
output  [31:0] ap_param1;
output         ap_param1_read;
output         ap_param1_write;

//output for xauxregs extension:
output  [31:0] uxdrx_reg; 
output         uxreg_hit; 
output         ux_da_am; 
output  [31:0] ux_dar; 
output         uxhold_host; 
output         uxnoaccess;
// output signals for xcoreregs extension:
output  [31:0] ux2data_2_pc; 
output  [31:0] ux1data; 
output  [31:0] ux2data; 
output         ux_p2nosc1; 
output         ux_p2nosc2;
// output signals for condition code extension:
output         uxp2ccmatch; 
output         uxp2bccmatch; 
output         uxp3ccmatch;
// output signals for stage 2 instruction decoding:
output         ux_isop_decode2; 
output         ux_idop_decode2; 
output         ux_izop_decode2;
// output signals for pipeline control:
output         uxholdup2; 
output         uxholdup2b; 
output         uxholdup3; 
// output signals for result write back control:
output         uxnwb; 
output         uxp2idest; 
output         uxsetflags; 
output         ux_flgen; 
output  [5:0]  ux_multic_wba; 
output         ux_multic_wben; 
output         ux_multic_busy; 
output         ux_p1_rev_src; 
output         ux_p2_bfield_wb_a; 
output         ux_p2_jump_decode; 
output         ux_snglec_wben; 
// output signal for alu extension results:
output  [31:0] uxresult; 
output  [3:0]  uxflags;
output  [3:0]  xflags_r;
// special instruction control signals:
output         uxivic; 
output                   dummy;
   
wire    [31:0] uxdrx_reg; 
wire           uxreg_hit; 
wire           ux_da_am; 
wire    [31:0] ux_dar; 
wire           uxivic; 
wire           uxhold_host; 
wire           uxnoaccess;
wire    [31:0] ux2data_2_pc; 
wire    [31:0] ux1data; 
wire    [31:0] ux2data; 
wire           ux_p2nosc1; 
wire           ux_p2nosc2;
wire           uxp2ccmatch; 
wire           uxp2bccmatch; 
wire           uxp3ccmatch;
wire           uxholdup2; 
wire           uxholdup2b; 
wire           uxholdup3; 
wire           uxnwb; 
wire           uxp2idest; 
wire           uxsetflags;   
wire           ux_flgen; 
wire           ux_isop_decode2; 
wire           ux_idop_decode2; 
wire           ux_izop_decode2;
wire           ux_p1_rev_src; 
wire    [5:0]  ux_multic_wba; 
wire           ux_multic_wben; 
wire           ux_multic_busy; 
wire           ux_p2_bfield_wb_a; 
wire           ux_p2_jump_decode; 
wire           ux_snglec_wben;
wire    [31:0] uxresult; 
wire    [3:0]  uxflags; 

wire           i_p3_xmultic_nwb;
assign         i_p3_xmultic_nwb = 
                                  p3_xmultic_nwb;

wire           dummy;

assign dummy = 1'b0;

//=================== X flags ========================================--
// The X flags are 4 bits shared between all EIA extensions, they may be
// set by EIA extension instructions with the .f assembler notation.
wire    [3:0]  i_xflags_a;
wire           i_xflags_hit_a;
wire    [3:0]  i_xflags_nxt;
reg     [3:0]  xflags_r;
wire           i_xflags_en_a;

assign i_xflags_a = 
                    4'h0;

assign i_xflags_hit_a = (aux_addr == AUX_EIA_FLAGS);
  
assign i_xflags_nxt = (i_xflags_hit_a && aux_write)
                         ? aux_dataw[3:0]
                         : i_xflags_a;

assign i_xflags_en_a = (i_xflags_hit_a && aux_write) | ux_flgen;

// Xflags register.
always @(posedge clk or posedge rst_a)
begin : xflags_sync_PROC
  if (rst_a) begin
    xflags_r <= 0;
    end
  else begin
    if (i_xflags_en_a) begin
      xflags_r <= i_xflags_nxt;
      end
    end
end


//=================== Actionpoints external parameters ===============--
// These signals can be connected to any external parameters
// to be monitored. _read and _write are qualifiers which affect
// which actionpoints mode would need to be set to trigger.
assign    ap_param0       = AP_TEST_PATTERN0;
assign    ap_param0_read  = 1'b1;
assign    ap_param0_write = 1'b1;
assign    ap_param1       = AP_TEST_PATTERN1;
assign    ap_param1_read  = 1'b1;
assign    ap_param1_write = 1'b1;

   
// ====================== Extension ALU Functionality =================--
      
//  ALU result selection 
assign uxresult = 
                           {32{1'b 0}};
 
assign uxflags =
                           {4{1'b 0}};
   
// ============= Extension Auxiliary Register Functionality ===========--
// Extension auxiliar register result selection:
assign uxdrx_reg = 
       ({28'h0000000, {4{i_xflags_hit_a}} & xflags_r});
   
assign uxreg_hit = 
                           i_xflags_hit_a;
   
// Dual access
assign ux_da_am = 
                           1'b 0;
   
assign ux_dar = 
                           {32{1'b 0}};
   
assign uxhold_host = 
                           1'b 0;
   
assign uxnoaccess = 
                           1'b 0;
   
assign uxivic = 
                           1'b 0;

// ============== Extension Core Register Functionality ===============--
// Core register result selection:
assign ux2data_2_pc = 
                           {32{1'b 0}};
   
assign ux1data = 
                           {32{1'b 0}};
   
assign ux2data = 
                           {32{1'b 0}};
   
// Extension core registers shortcut control
assign ux_p2nosc1 = 
                           1'b 0;
   
assign ux_p2nosc2 = 
                           1'b 0;
   
// ================ Extension Control Logic Functionality==============--
//  Pipeline stage 2 extension instruction decode
   
assign ux_idop_decode2 =
                           1'b 0;

   
assign ux_isop_decode2 =
                           1'b 0;

   
assign ux_izop_decode2 =
                           1'b 0;

// ======================= Condition Code Control =====================--
assign uxp2ccmatch = 
                           1'b 0;

assign uxp2bccmatch = 
                           1'b 0;

assign uxp3ccmatch = 
                           1'b 0;

// ===================== Pipeline Stall Conditions ====================--
   
assign uxholdup2 = 
                           1'b 0;
   
assign uxholdup2b = 
                           1'b 0;
   
assign uxholdup3 = 
                           1'b 0;

   
// ===================== Result Write Back Control ====================--
   
assign ux_snglec_wben = 
                           1'b 0;
   
assign ux_multic_wben = 
                           1'b 0;
   
assign ux_multic_busy = 
                           1'b 0;
   
assign ux_multic_wba = 
                           {6{1'b 0}};
   

assign ux_p2_bfield_wb_a = 
                           1'b 0;
   
assign uxnwb = 
                           1'b 0;

assign uxp2idest = 
                           1'b 0;

assign ux_flgen =
                           1'b 0;
   
// ================= Special Instruction Control Logic ================--
   
assign ux_p2_jump_decode = 
                           1'b 0;
   
assign ux_p1_rev_src = 
                           1'b 0;
    
assign uxsetflags = 
                           1'b 0;
   
   
// Extension Instantiations:

// ====================================================================--

endmodule // module eia_common
