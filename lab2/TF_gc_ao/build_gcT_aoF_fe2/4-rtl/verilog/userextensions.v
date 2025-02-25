// *SYNOPSYS CONFIDENTIAL*
//
// This is an unpublished, proprietary work of Synopsys, Inc., and is fully 
// protected under copyright and trade secret laws.  You may not view, use, 
// disclose, copy, or distribute this file or any information contained herein 
// except pursuant to a valid written license from Synopsys.


// This file is generated automatically by 'veriloggen'.




module userextensions(en,
                      rst_a,
                      clk,
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
                      ux_flgen,
                      ux_multic_wba,
                      ux_multic_wben,
                      ux_multic_busy,
                      ux_p1_rev_src,
                      ux_p2_bfield_wb_a,
                      ux_p2_jump_decode,
                      ux_snglec_wben,
                      uxresult,
                      uxflags);


// Includes found automatically in dependent files.
`include "arcutil_pkg_defines.v"
`include "arcutil.v"
`include "asmutil.v"
`include "extutil.v"
`include "che_util.v"
`include "xdefs.v"
`include "uxdefs.v"


input  en;
input  rst_a;
input  clk;
input  s1en;
input  s2en;
input  [31:0]  s1bus;
input  [31:0]  s2bus;
input  en2;
input  mload2b;
input  mstore2b;
input  [4:0]  p2opcode;
input  [5:0]  p2subopcode;
input  [4:0]  p2subopcode2_r;
input  [5:0]  p2_a_field_r;
input  [5:0]  p2_b_field_r;
input  [5:0]  p2_c_field_r;
input  p2iv;
input  [3:0]  p2cc;
input  p2conditional;
input  p2sleep_inst;
input  p2setflags;
input  p2st;
input  [1:0]  p2format;
input  p2bch;
input  p2dop32_inst;
input  p2sop32_inst;
input  p2zop32_inst;
input  p2dop16_inst;
input  p2sop16_inst;
input  p2zop16_inst;
input  en2b;
input  p2b_iv;
input  p2b_conditional;
input  [3:0]  p2b_cc;
input  p2b_dop32_inst;
input  p2b_sop32_inst;
input  p2b_zop32_inst;
input  p2b_dop16_inst;
input  p2b_sop16_inst;
input  p2b_zop16_inst;
input  [4:0]  p2b_opcode;
input  [5:0]  p2b_subopcode;
input  [5:0]  p2b_a_field_r;
input  [5:0]  p2b_b_field_r;
input  [5:0]  p2b_c_field_r;
input  en3;
input  p3iv;
input  [4:0]  p3opcode;
input  [5:0]  p3subopcode;
input  [4:0]  p3subopcode2_r;
input  [5:0]  p3a_field_r;
input  [5:0]  p3b_field_r;
input  [5:0]  p3c_field_r;
input  [3:0]  p3cc;
input  p3condtrue;
input  p3destlimm;
input  [1:0]  p3format;
input  p3setflags;
input  x_idecode3;
input  p3wb_en;
input  [5:0]  p3wba;
input  p3lr;
input  p3sr;
input  p3dop32_inst;
input  p3sop32_inst;
input  p3zop32_inst;
input  p3dop16_inst;
input  p3sop16_inst;
input  p3zop16_inst;
input  [3:0]  aluflags_r;
input  [31:0]  ext_s1val;
input  [31:0]  ext_s2val;
input  [31:0]  aux_addr;
input  [31:0]  aux_dataw;
input  aux_write;
input  aux_read;
input  [31:0]  h_addr;
input  [31:0]  h_dataw;
input  h_write;
input  h_read;
input  aux_access;
input  [5:0]  s1a;
input  [5:0]  s2a;
input  [5:0]  fs2a;
input  [5:0]  wba;
input  [31:0]  wbdata;
input  wben;
input  core_access;
input  [5:0]  dest;
input  desten;
input  sc_reg1;
input  sc_reg2;
input  p3_xmultic_nwb;
output [31:0]  ap_param0;
output ap_param0_read;
output ap_param0_write;
output [31:0]  ap_param1;
output ap_param1_read;
output ap_param1_write;
output [31:0]  uxdrx_reg;
output uxreg_hit;
output ux_da_am;
output [31:0]  ux_dar;
output uxivic;
output uxhold_host;
output uxnoaccess;
output [31:0]  ux2data_2_pc;
output [31:0]  ux1data;
output [31:0]  ux2data;
output ux_p2nosc1;
output ux_p2nosc2;
output uxp2bccmatch;
output uxp2ccmatch;
output uxp3ccmatch;
output uxholdup2;
output uxholdup2b;
output uxholdup3;
output ux_isop_decode2;
output ux_idop_decode2;
output ux_izop_decode2;
output uxnwb;
output uxp2idest;
output uxsetflags;
output ux_flgen;
output [5:0]  ux_multic_wba;
output ux_multic_wben;
output ux_multic_busy;
output ux_p1_rev_src;
output ux_p2_bfield_wb_a;
output ux_p2_jump_decode;
output ux_snglec_wben;
output [31:0]  uxresult;
output [3:0]  uxflags;

wire en;
wire rst_a;
wire clk;
wire s1en;
wire s2en;
wire  [31:0] s1bus;
wire  [31:0] s2bus;
wire en2;
wire mload2b;
wire mstore2b;
wire  [4:0] p2opcode;
wire  [5:0] p2subopcode;
wire  [4:0] p2subopcode2_r;
wire  [5:0] p2_a_field_r;
wire  [5:0] p2_b_field_r;
wire  [5:0] p2_c_field_r;
wire p2iv;
wire  [3:0] p2cc;
wire p2conditional;
wire p2sleep_inst;
wire p2setflags;
wire p2st;
wire  [1:0] p2format;
wire p2bch;
wire p2dop32_inst;
wire p2sop32_inst;
wire p2zop32_inst;
wire p2dop16_inst;
wire p2sop16_inst;
wire p2zop16_inst;
wire en2b;
wire p2b_iv;
wire p2b_conditional;
wire  [3:0] p2b_cc;
wire p2b_dop32_inst;
wire p2b_sop32_inst;
wire p2b_zop32_inst;
wire p2b_dop16_inst;
wire p2b_sop16_inst;
wire p2b_zop16_inst;
wire  [4:0] p2b_opcode;
wire  [5:0] p2b_subopcode;
wire  [5:0] p2b_a_field_r;
wire  [5:0] p2b_b_field_r;
wire  [5:0] p2b_c_field_r;
wire en3;
wire p3iv;
wire  [4:0] p3opcode;
wire  [5:0] p3subopcode;
wire  [4:0] p3subopcode2_r;
wire  [5:0] p3a_field_r;
wire  [5:0] p3b_field_r;
wire  [5:0] p3c_field_r;
wire  [3:0] p3cc;
wire p3condtrue;
wire p3destlimm;
wire  [1:0] p3format;
wire p3setflags;
wire x_idecode3;
wire p3wb_en;
wire  [5:0] p3wba;
wire p3lr;
wire p3sr;
wire p3dop32_inst;
wire p3sop32_inst;
wire p3zop32_inst;
wire p3dop16_inst;
wire p3sop16_inst;
wire p3zop16_inst;
wire  [3:0] aluflags_r;
wire  [31:0] ext_s1val;
wire  [31:0] ext_s2val;
wire  [31:0] aux_addr;
wire  [31:0] aux_dataw;
wire aux_write;
wire aux_read;
wire  [31:0] h_addr;
wire  [31:0] h_dataw;
wire h_write;
wire h_read;
wire aux_access;
wire  [5:0] s1a;
wire  [5:0] s2a;
wire  [5:0] fs2a;
wire  [5:0] wba;
wire  [31:0] wbdata;
wire wben;
wire core_access;
wire  [5:0] dest;
wire desten;
wire sc_reg1;
wire sc_reg2;
wire p3_xmultic_nwb;
wire  [31:0] ap_param0;
wire ap_param0_read;
wire ap_param0_write;
wire  [31:0] ap_param1;
wire ap_param1_read;
wire ap_param1_write;
wire  [31:0] uxdrx_reg;
wire uxreg_hit;
wire ux_da_am;
wire  [31:0] ux_dar;
wire uxivic;
wire uxhold_host;
wire uxnoaccess;
wire  [31:0] ux2data_2_pc;
wire  [31:0] ux1data;
wire  [31:0] ux2data;
wire ux_p2nosc1;
wire ux_p2nosc2;
wire uxp2bccmatch;
wire uxp2ccmatch;
wire uxp3ccmatch;
wire uxholdup2;
wire uxholdup2b;
wire uxholdup3;
wire ux_isop_decode2;
wire ux_idop_decode2;
wire ux_izop_decode2;
wire uxnwb;
wire uxp2idest;
wire uxsetflags;
wire ux_flgen;
wire  [5:0] ux_multic_wba;
wire ux_multic_wben;
wire ux_multic_busy;
wire ux_p1_rev_src;
wire ux_p2_bfield_wb_a;
wire ux_p2_jump_decode;
wire ux_snglec_wben;
wire  [31:0] uxresult;
wire  [3:0] uxflags;


// Intermediate signals


// Dummy signals for 'unconnected' ports
// (doing this, rather than leaving them genuinely unconnected, stops
//  simulators emitting pointless warnings)
wire  [3:0] u_unconnected_0;
wire u_unconnected_1;


// Instantiation of module eia_common
eia_common ieia_common(
  .clk(clk),
  .rst_a(rst_a),
  .en(en),
  .s1en(s1en),
  .s2en(s2en),
  .s1bus(s1bus),
  .s2bus(s2bus),
  .en2(en2),
  .mload2b(mload2b),
  .mstore2b(mstore2b),
  .p2opcode(p2opcode),
  .p2subopcode(p2subopcode),
  .p2subopcode2_r(p2subopcode2_r),
  .p2_a_field_r(p2_a_field_r),
  .p2_b_field_r(p2_b_field_r),
  .p2_c_field_r(p2_c_field_r),
  .p2iv(p2iv),
  .p2cc(p2cc),
  .p2conditional(p2conditional),
  .p2sleep_inst(p2sleep_inst),
  .p2setflags(p2setflags),
  .p2st(p2st),
  .p2format(p2format),
  .p2bch(p2bch),
  .p2dop32_inst(p2dop32_inst),
  .p2sop32_inst(p2sop32_inst),
  .p2zop32_inst(p2zop32_inst),
  .p2dop16_inst(p2dop16_inst),
  .p2sop16_inst(p2sop16_inst),
  .p2zop16_inst(p2zop16_inst),
  .en2b(en2b),
  .p2b_iv(p2b_iv),
  .p2b_conditional(p2b_conditional),
  .p2b_cc(p2b_cc),
  .p2b_dop32_inst(p2b_dop32_inst),
  .p2b_sop32_inst(p2b_sop32_inst),
  .p2b_zop32_inst(p2b_zop32_inst),
  .p2b_dop16_inst(p2b_dop16_inst),
  .p2b_sop16_inst(p2b_sop16_inst),
  .p2b_zop16_inst(p2b_zop16_inst),
  .p2b_opcode(p2b_opcode),
  .p2b_subopcode(p2b_subopcode),
  .p2b_a_field_r(p2b_a_field_r),
  .p2b_b_field_r(p2b_b_field_r),
  .p2b_c_field_r(p2b_c_field_r),
  .en3(en3),
  .p3iv(p3iv),
  .p3opcode(p3opcode),
  .p3subopcode(p3subopcode),
  .p3subopcode2_r(p3subopcode2_r),
  .p3a_field_r(p3a_field_r),
  .p3b_field_r(p3b_field_r),
  .p3c_field_r(p3c_field_r),
  .p3cc(p3cc),
  .p3condtrue(p3condtrue),
  .p3destlimm(p3destlimm),
  .p3format(p3format),
  .p3setflags(p3setflags),
  .x_idecode3(x_idecode3),
  .p3wb_en(p3wb_en),
  .p3wba(p3wba),
  .p3lr(p3lr),
  .p3sr(p3sr),
  .p3dop32_inst(p3dop32_inst),
  .p3sop32_inst(p3sop32_inst),
  .p3zop32_inst(p3zop32_inst),
  .p3dop16_inst(p3dop16_inst),
  .p3sop16_inst(p3sop16_inst),
  .p3zop16_inst(p3zop16_inst),
  .aluflags_r(aluflags_r),
  .ext_s1val(ext_s1val),
  .ext_s2val(ext_s2val),
  .aux_addr(aux_addr),
  .aux_dataw(aux_dataw),
  .aux_write(aux_write),
  .aux_read(aux_read),
  .h_addr(h_addr),
  .h_dataw(h_dataw),
  .h_write(h_write),
  .h_read(h_read),
  .aux_access(aux_access),
  .s1a(s1a),
  .s2a(s2a),
  .fs2a(fs2a),
  .wba(wba),
  .wbdata(wbdata),
  .wben(wben),
  .core_access(core_access),
  .dest(dest),
  .desten(desten),
  .sc_reg1(sc_reg1),
  .sc_reg2(sc_reg2),
  .p3_xmultic_nwb(p3_xmultic_nwb),
  .ap_param0(ap_param0),
  .ap_param0_read(ap_param0_read),
  .ap_param0_write(ap_param0_write),
  .ap_param1(ap_param1),
  .ap_param1_read(ap_param1_read),
  .ap_param1_write(ap_param1_write),
  .uxdrx_reg(uxdrx_reg),
  .uxreg_hit(uxreg_hit),
  .ux_da_am(ux_da_am),
  .ux_dar(ux_dar),
  .uxivic(uxivic),
  .uxhold_host(uxhold_host),
  .uxnoaccess(uxnoaccess),
  .ux2data_2_pc(ux2data_2_pc),
  .ux1data(ux1data),
  .ux2data(ux2data),
  .ux_p2nosc1(ux_p2nosc1),
  .ux_p2nosc2(ux_p2nosc2),
  .uxp2bccmatch(uxp2bccmatch),
  .uxp2ccmatch(uxp2ccmatch),
  .uxp3ccmatch(uxp3ccmatch),
  .uxholdup2(uxholdup2),
  .uxholdup2b(uxholdup2b),
  .uxholdup3(uxholdup3),
  .ux_isop_decode2(ux_isop_decode2),
  .ux_idop_decode2(ux_idop_decode2),
  .ux_izop_decode2(ux_izop_decode2),
  .uxnwb(uxnwb),
  .uxp2idest(uxp2idest),
  .uxsetflags(uxsetflags),
  .xflags_r(u_unconnected_0),
  .ux_flgen(ux_flgen),
  .ux_multic_wba(ux_multic_wba),
  .ux_multic_wben(ux_multic_wben),
  .ux_multic_busy(ux_multic_busy),
  .ux_p1_rev_src(ux_p1_rev_src),
  .ux_p2_bfield_wb_a(ux_p2_bfield_wb_a),
  .ux_p2_jump_decode(ux_p2_jump_decode),
  .ux_snglec_wben(ux_snglec_wben),
  .uxresult(uxresult),
  .uxflags(uxflags),
  .dummy(u_unconnected_1)
);


// Output drives

endmodule


