// *SYNOPSYS CONFIDENTIAL*
//
// This is an unpublished, proprietary work of Synopsys, Inc., and is fully 
// protected under copyright and trade secret laws.  You may not view, use, 
// disclose, copy, or distribute this file or any information contained herein 
// except pursuant to a valid written license from Synopsys.


// This file is generated automatically by 'veriloggen'.




module alu(rst_a,
           clk,
           en2b,
           p2b_iv,
           p2b_opcode,
           p2b_subopcode,
           en3,
           p3iv,
           p3opcode,
           p3subopcode,
           p3subopcode2_r,
           p3a_field_r,
           p3b_field_r,
           p3c_field_r,
           p3condtrue,
           x_idecode3,
           p3wb_en,
           p3lr,
           aluflags_r,
           ext_s1val,
           ext_s2val,
           aux_dataw,
           h_dataw,
           uxsetflags,
           uxresult,
           uxflags,
           cr_hostw,
           p3int,
           x_multic_wben,
           x_snglec_wben,
           ldvalid_wb,
           p3_alu_absiv,
           p3_alu_arithiv,
           p3_alu_logiciv,
           p3_alu_op,
           p3_alu_snglopiv,
           p3_bit_op_sel,
           p3_max_instr,
           p3_min_instr,
           p3_shiftin_sel_r,
           p3_sop_op_r,
           p3awb_field_r,
           p3dolink,
           p3minoropcode,
           p3subopcode3_r,
           p3subopcode4_r,
           p3subopcode5_r,
           p3subopcode6_r,
           p3subopcode7_r,
           s2val,
           barrel_type_r,
           x_p3_brl_decode_16_r,
           x_p3_brl_decode_32_r,
           x_p3_norm_decode_r,
           x_p3_snorm_decode_r,
           x_p3_swap_decode_r,
           e1flag_r,
           e2flag_r,
           aux_datar,
           aux_pc32hit,
           aux_pchit,
           drd,
           s1val,
           s2val_inverted_r,
           aux_st_mulhi_a,
           wbdata,
           br_flags_a,
           mulatwork_r,
           alurflags,
           mc_addr,
           p3res_sc,
           p3result,
           lmulres_r,
           x_s_flag,
           xflags);


// Includes found automatically in dependent files.
`include "arcutil_pkg_defines.v"
`include "arcutil.v"
`include "extutil.v"
`include "asmutil.v"
`include "xdefs.v"


input  rst_a;
input  clk;
input  en2b;
input  p2b_iv;
input  [4:0]  p2b_opcode;
input  [5:0]  p2b_subopcode;
input  en3;
input  p3iv;
input  [4:0]  p3opcode;
input  [5:0]  p3subopcode;
input  [4:0]  p3subopcode2_r;
input  [5:0]  p3a_field_r;
input  [5:0]  p3b_field_r;
input  [5:0]  p3c_field_r;
input  p3condtrue;
input  x_idecode3;
input  p3wb_en;
input  p3lr;
input  [3:0]  aluflags_r;
input  [31:0]  ext_s1val;
input  [31:0]  ext_s2val;
input  [31:0]  aux_dataw;
input  [31:0]  h_dataw;
input  uxsetflags;
input  [31:0]  uxresult;
input  [3:0]  uxflags;
input  cr_hostw;
input  p3int;
input  x_multic_wben;
input  x_snglec_wben;
input  ldvalid_wb;
input  p3_alu_absiv;
input  p3_alu_arithiv;
input  p3_alu_logiciv;
input  [1:0]  p3_alu_op;
input  p3_alu_snglopiv;
input  [1:0]  p3_bit_op_sel;
input  p3_max_instr;
input  p3_min_instr;
input  [1:0]  p3_shiftin_sel_r;
input  [2:0]  p3_sop_op_r;
input  [1:0]  p3awb_field_r;
input  p3dolink;
input  [5:0]  p3minoropcode;
input  [2:0]  p3subopcode3_r;
input  p3subopcode4_r;
input  [1:0]  p3subopcode5_r;
input  [2:0]  p3subopcode6_r;
input  [1:0]  p3subopcode7_r;
input  [31:0]  s2val;
input  [1:0]  barrel_type_r;
input  x_p3_brl_decode_16_r;
input  x_p3_brl_decode_32_r;
input  x_p3_norm_decode_r;
input  x_p3_snorm_decode_r;
input  x_p3_swap_decode_r;
input  e1flag_r;
input  e2flag_r;
input  [31:0]  aux_datar;
input  aux_pc32hit;
input  aux_pchit;
input  [31:0]  drd;
input  [31:0]  s1val;
input  s2val_inverted_r;
input  aux_st_mulhi_a;
output [31:0]  wbdata;
output [3:0]  br_flags_a;
output mulatwork_r;
output [3:0]  alurflags;
output [31:0]  mc_addr;
output [31:0]  p3res_sc;
output [31:0]  p3result;
output [63:0]  lmulres_r;
output [1:0]  x_s_flag;
output [3:0]  xflags;

wire rst_a;
wire clk;
wire en2b;
wire p2b_iv;
wire  [4:0] p2b_opcode;
wire  [5:0] p2b_subopcode;
wire en3;
wire p3iv;
wire  [4:0] p3opcode;
wire  [5:0] p3subopcode;
wire  [4:0] p3subopcode2_r;
wire  [5:0] p3a_field_r;
wire  [5:0] p3b_field_r;
wire  [5:0] p3c_field_r;
wire p3condtrue;
wire x_idecode3;
wire p3wb_en;
wire p3lr;
wire  [3:0] aluflags_r;
wire  [31:0] ext_s1val;
wire  [31:0] ext_s2val;
wire  [31:0] aux_dataw;
wire  [31:0] h_dataw;
wire uxsetflags;
wire  [31:0] uxresult;
wire  [3:0] uxflags;
wire cr_hostw;
wire p3int;
wire x_multic_wben;
wire x_snglec_wben;
wire ldvalid_wb;
wire p3_alu_absiv;
wire p3_alu_arithiv;
wire p3_alu_logiciv;
wire  [1:0] p3_alu_op;
wire p3_alu_snglopiv;
wire  [1:0] p3_bit_op_sel;
wire p3_max_instr;
wire p3_min_instr;
wire  [1:0] p3_shiftin_sel_r;
wire  [2:0] p3_sop_op_r;
wire  [1:0] p3awb_field_r;
wire p3dolink;
wire  [5:0] p3minoropcode;
wire  [2:0] p3subopcode3_r;
wire p3subopcode4_r;
wire  [1:0] p3subopcode5_r;
wire  [2:0] p3subopcode6_r;
wire  [1:0] p3subopcode7_r;
wire  [31:0] s2val;
wire  [1:0] barrel_type_r;
wire x_p3_brl_decode_16_r;
wire x_p3_brl_decode_32_r;
wire x_p3_norm_decode_r;
wire x_p3_snorm_decode_r;
wire x_p3_swap_decode_r;
wire e1flag_r;
wire e2flag_r;
wire  [31:0] aux_datar;
wire aux_pc32hit;
wire aux_pchit;
wire  [31:0] drd;
wire  [31:0] s1val;
wire s2val_inverted_r;
wire aux_st_mulhi_a;
wire  [31:0] wbdata;
wire  [3:0] br_flags_a;
wire mulatwork_r;
wire  [3:0] alurflags;
wire  [31:0] mc_addr;
wire  [31:0] p3res_sc;
wire  [31:0] p3result;
wire  [63:0] lmulres_r;
wire  [1:0] x_s_flag;
wire  [3:0] xflags;


// Intermediate signals
wire  [31:0] i_xresult;


// Dummy signals for 'unconnected' ports
// (doing this, rather than leaving them genuinely unconnected, stops
//  simulators emitting pointless warnings)
wire  [31:0] u_unconnected_0;
wire u_unconnected_1;


// Instantiation of module bigalu
bigalu ibigalu(
  .clk(clk),
  .rst_a(rst_a),
  .aluflags_r(aluflags_r),
  .e1flag_r(e1flag_r),
  .e2flag_r(e2flag_r),
  .aux_datar(aux_datar),
  .aux_pc32hit(aux_pc32hit),
  .aux_pchit(aux_pchit),
  .cr_hostw(cr_hostw),
  .drd(drd),
  .h_dataw(h_dataw),
  .ldvalid_wb(ldvalid_wb),
  .p3_alu_absiv(p3_alu_absiv),
  .p3_alu_arithiv(p3_alu_arithiv),
  .p3_alu_logiciv(p3_alu_logiciv),
  .p3_alu_op(p3_alu_op),
  .p3_alu_snglopiv(p3_alu_snglopiv),
  .p3_shiftin_sel_r(p3_shiftin_sel_r),
  .p3_bit_op_sel(p3_bit_op_sel),
  .p3_sop_op_r(p3_sop_op_r),
  .p3awb_field_r(p3awb_field_r),
  .p3dolink(p3dolink),
  .p3int(p3int),
  .p3lr(p3lr),
  .p3_min_instr(p3_min_instr),
  .p3_max_instr(p3_max_instr),
  .p3wb_en(p3wb_en),
  .s1val(s1val),
  .s2val(s2val),
  .x_multic_wben(x_multic_wben),
  .xresult(i_xresult),
  .x_snglec_wben(x_snglec_wben),
  .s2val_inverted_r(s2val_inverted_r),
  .alurflags(alurflags),
  .br_flags_a(br_flags_a),
  .mc_addr(mc_addr),
  .p3res_sc(p3res_sc),
  .p3result(p3result),
  .p3result_nld(u_unconnected_0),
  .wbdata(wbdata)
);


// Instantiation of module xalu
xalu ixalu(
  .clk(clk),
  .rst_a(rst_a),
  .p3iv(p3iv),
  .aluflags_r(aluflags_r),
  .p3opcode(p3opcode),
  .p3subopcode(p3subopcode),
  .p3subopcode2_r(p3subopcode2_r),
  .p3a_field_r(p3a_field_r),
  .p3b_field_r(p3b_field_r),
  .p3c_field_r(p3c_field_r),
  .p3subopcode3_r(p3subopcode3_r),
  .p3subopcode4_r(p3subopcode4_r),
  .p3subopcode5_r(p3subopcode5_r),
  .p3subopcode6_r(p3subopcode6_r),
  .p3subopcode7_r(p3subopcode7_r),
  .p3minoropcode(p3minoropcode),
  .p3condtrue(p3condtrue),
  .en3(en3),
  .ext_s1val(ext_s1val),
  .ext_s2val(ext_s2val),
  .s1val(s1val),
  .s2val(s2val),
  .aux_dataw(aux_dataw),
  .x_idecode3(x_idecode3),
  .x_multic_wben(x_multic_wben),
  .x_snglec_wben(x_snglec_wben),
  .uxsetflags(uxsetflags),
  .uxresult(uxresult),
  .uxflags(uxflags),
  .barrel_type_r(barrel_type_r),
  .x_p3_brl_decode_16_r(x_p3_brl_decode_16_r),
  .x_p3_brl_decode_32_r(x_p3_brl_decode_32_r),
  .p2b_opcode(p2b_opcode),
  .p2b_subopcode(p2b_subopcode),
  .p2b_iv(p2b_iv),
  .en2b(en2b),
  .aux_st_mulhi_a(aux_st_mulhi_a),
  .x_p3_norm_decode_r(x_p3_norm_decode_r),
  .x_p3_snorm_decode_r(x_p3_snorm_decode_r),
  .x_p3_swap_decode_r(x_p3_swap_decode_r),
  .mulatwork_r(mulatwork_r),
  .lmul_en(u_unconnected_1),
  .lmulres_r(lmulres_r),
  .x_s_flag(x_s_flag),
  .xflags(xflags),
  .xresult(i_xresult)
);


// Output drives

endmodule


