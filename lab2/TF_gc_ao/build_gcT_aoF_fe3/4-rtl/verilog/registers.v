// *SYNOPSYS CONFIDENTIAL*
//
// This is an unpublished, proprietary work of Synopsys, Inc., and is fully 
// protected under copyright and trade secret laws.  You may not view, use, 
// disclose, copy, or distribute this file or any information contained herein 
// except pursuant to a valid written license from Synopsys.


// This file is generated automatically by 'veriloggen'.




module registers(clk_ungated,
                 code_ram_rdata,
                 en,
                 rst_a,
                 test_mode,
                 ck_disable,
                 clk,
                 s1en,
                 s2en,
                 en2,
                 mstore2b,
                 p2opcode,
                 p2subopcode,
                 p2iv,
                 en2b,
                 p2b_iv,
                 aux_addr,
                 aux_dataw,
                 aux_write,
                 h_addr,
                 h_read,
                 s1a,
                 s2a,
                 fs2a,
                 wba,
                 wbdata,
                 wben,
                 core_access,
                 sc_reg1,
                 sc_reg2,
                 ux2data_2_pc,
                 ux1data,
                 ux2data,
                 do_inst_step_r,
                 h_pcwr,
                 h_pcwr32,
                 ivic,
                 ldvalid,
                 dmp_mload,
                 dmp_mstore,
                 p1int,
                 p2int,
                 p2bint,
                 pcounter_jmp_restart_r,
                 regadr,
                 x_idecode2b,
                 en1,
                 ifetch_aligned,
                 pcen,
                 pcen_niv,
                 p2_dopred,
                 p2_dorel,
                 p2_iw_r,
                 p2_lp_instr,
                 p2_s1a,
                 p2_s2a,
                 p2condtrue,
                 p2limm,
                 p2minoropcode,
                 p2subopcode3_r,
                 p2subopcode4_r,
                 p2subopcode5_r,
                 p2subopcode6_r,
                 p2subopcode7_r,
                 p2b_abs_op,
                 p2b_alu_op,
                 p2b_arithiv,
                 p2b_blcc_a,
                 p2b_delay_slot,
                 p2b_dojcc,
                 p2b_jlcc_a,
                 p2b_limm,
                 p2b_lr,
                 p2b_neg_op,
                 p2b_not_op,
                 p2b_shift_by_one_a,
                 p2b_shift_by_three_a,
                 p2b_shift_by_two_a,
                 p2b_shift_by_zero_a,
                 p2b_shimm_data,
                 p2b_shimm_s1_a,
                 p2b_shimm_s2_a,
                 sc_load1,
                 sc_load2,
                 p4_docmprel,
                 loopcount_hit_a,
                 kill_p1_nlp_a,
                 kill_tagged_p1,
                 currentpc_r,
                 misaligned_target,
                 pc_is_linear_r,
                 next_pc,
                 last_pc_plus_len,
                 p2b_pc_r,
                 p2_target,
                 p2_s1val_tmp_r,
                 drd,
                 p3res_sc,
                 p3result,
                 lmulres_r,
                 hold_host,
                 cr_hostr,
                 h_status32,
                 dmp_dwr,
                 dmp_en3,
                 dmp_addr,
                 dmp_size,
                 dmp_sex,
                 hold_loc,
                 is_code_ram,
                 code_dmi_req,
                 code_dmi_addr,
                 code_dmi_wdata,
                 code_dmi_wr,
                 code_dmi_be,
                 code_ram_addr,
                 code_ram_wdata,
                 code_ram_wr,
                 code_ram_be,
                 code_ram_ck_en,
                 s1bus,
                 s2bus,
                 ext_s1val,
                 ext_s2val,
                 ivalid_aligned,
                 loop_kill_p1_a,
                 loop_int_holdoff_a,
                 loopend_hit_a,
                 p1iw_aligned_a,
                 code_stall_ldst,
                 s2val,
                 ic_busy,
                 aligner_do_pc_plus_8,
                 aligner_pc_enable,
                 ivalid,
                 loopstart_r,
                 p1inst_16,
                 do_loop_a,
                 qd_b,
                 x2data_2_pc,
                 s1val,
                 s2val_inverted_r,
                 dwr,
                 h_rr_data,
                 loopend_r,
                 sr_xhold_host_a,
                 p1iw,
                 code_drd,
                 code_ldvalid_r,
                 code_dmi_rdata);


// Includes found automatically in dependent files.
`include "arcutil_pkg_defines.v"
`include "arcutil.v"
`include "extutil.v"
`include "xdefs.v"


input  clk_ungated;
input  [31:0]  code_ram_rdata;
input  en;
input  rst_a;
input  test_mode;
input  ck_disable;
input  clk;
input  s1en;
input  s2en;
input  en2;
input  mstore2b;
input  [4:0]  p2opcode;
input  [5:0]  p2subopcode;
input  p2iv;
input  en2b;
input  p2b_iv;
input  [31:0]  aux_addr;
input  [31:0]  aux_dataw;
input  aux_write;
input  [31:0]  h_addr;
input  h_read;
input  [5:0]  s1a;
input  [5:0]  s2a;
input  [5:0]  fs2a;
input  [5:0]  wba;
input  [31:0]  wbdata;
input  wben;
input  core_access;
input  sc_reg1;
input  sc_reg2;
input  [31:0]  ux2data_2_pc;
input  [31:0]  ux1data;
input  [31:0]  ux2data;
input  do_inst_step_r;
input  h_pcwr;
input  h_pcwr32;
input  ivic;
input  ldvalid;
input  dmp_mload;
input  dmp_mstore;
input  p1int;
input  p2int;
input  p2bint;
input  pcounter_jmp_restart_r;
input  [5:0]  regadr;
input  x_idecode2b;
input  en1;
input  ifetch_aligned;
input  pcen;
input  pcen_niv;
input  p2_dopred;
input  p2_dorel;
input  [INSTR_UBND:0]  p2_iw_r;
input  p2_lp_instr;
input  [5:0]  p2_s1a;
input  [5:0]  p2_s2a;
input  p2condtrue;
input  p2limm;
input  [5:0]  p2minoropcode;
input  [2:0]  p2subopcode3_r;
input  p2subopcode4_r;
input  [1:0]  p2subopcode5_r;
input  [2:0]  p2subopcode6_r;
input  [1:0]  p2subopcode7_r;
input  p2b_abs_op;
input  [1:0]  p2b_alu_op;
input  p2b_arithiv;
input  p2b_blcc_a;
input  p2b_delay_slot;
input  p2b_dojcc;
input  p2b_jlcc_a;
input  p2b_limm;
input  p2b_lr;
input  p2b_neg_op;
input  p2b_not_op;
input  p2b_shift_by_one_a;
input  p2b_shift_by_three_a;
input  p2b_shift_by_two_a;
input  p2b_shift_by_zero_a;
input  [12:0]  p2b_shimm_data;
input  p2b_shimm_s1_a;
input  p2b_shimm_s2_a;
input  sc_load1;
input  sc_load2;
input  p4_docmprel;
input  loopcount_hit_a;
input  kill_p1_nlp_a;
input  kill_tagged_p1;
input  [PC_MSB:0]  currentpc_r;
input  misaligned_target;
input  pc_is_linear_r;
input  [PC_MSB:0]  next_pc;
input  [PC_MSB:0]  last_pc_plus_len;
input  [PC_MSB:0]  p2b_pc_r;
input  [PC_MSB:0]  p2_target;
input  [DATAWORD_MSB:0]  p2_s1val_tmp_r;
input  [31:0]  drd;
input  [31:0]  p3res_sc;
input  [31:0]  p3result;
input  [63:0]  lmulres_r;
input  hold_host;
input  cr_hostr;
input  h_status32;
input  [31:0]  dmp_dwr;
input  dmp_en3;
input  [31:0]  dmp_addr;
input  [1:0]  dmp_size;
input  dmp_sex;
input  hold_loc;
input  is_code_ram;
input  code_dmi_req;
input  [31:0]  code_dmi_addr;
input  [31:0]  code_dmi_wdata;
input  code_dmi_wr;
input  [3:0]  code_dmi_be;
output [CODE_RAM_ADDR_MSB-CODE_RAM_ADDR_LSB:0]  code_ram_addr;
output [31:0]  code_ram_wdata;
output code_ram_wr;
output [3:0]  code_ram_be;
output code_ram_ck_en;
output [31:0]  s1bus;
output [31:0]  s2bus;
output [31:0]  ext_s1val;
output [31:0]  ext_s2val;
output ivalid_aligned;
output loop_kill_p1_a;
output loop_int_holdoff_a;
output loopend_hit_a;
output [DATAWORD_MSB:0]  p1iw_aligned_a;
output code_stall_ldst;
output [31:0]  s2val;
output ic_busy;
output aligner_do_pc_plus_8;
output aligner_pc_enable;
output ivalid;
output [PC_MSB:0]  loopstart_r;
output p1inst_16;
output do_loop_a;
output [31:0]  qd_b;
output [31:0]  x2data_2_pc;
output [31:0]  s1val;
output s2val_inverted_r;
output [31:0]  dwr;
output [31:0]  h_rr_data;
output [PC_MSB:0]  loopend_r;
output sr_xhold_host_a;
output [31:0]  p1iw;
output [31:0]  code_drd;
output code_ldvalid_r;
output [31:0]  code_dmi_rdata;

wire clk_ungated;
wire  [31:0] code_ram_rdata;
wire en;
wire rst_a;
wire test_mode;
wire ck_disable;
wire clk;
wire s1en;
wire s2en;
wire en2;
wire mstore2b;
wire  [4:0] p2opcode;
wire  [5:0] p2subopcode;
wire p2iv;
wire en2b;
wire p2b_iv;
wire  [31:0] aux_addr;
wire  [31:0] aux_dataw;
wire aux_write;
wire  [31:0] h_addr;
wire h_read;
wire  [5:0] s1a;
wire  [5:0] s2a;
wire  [5:0] fs2a;
wire  [5:0] wba;
wire  [31:0] wbdata;
wire wben;
wire core_access;
wire sc_reg1;
wire sc_reg2;
wire  [31:0] ux2data_2_pc;
wire  [31:0] ux1data;
wire  [31:0] ux2data;
wire do_inst_step_r;
wire h_pcwr;
wire h_pcwr32;
wire ivic;
wire ldvalid;
wire dmp_mload;
wire dmp_mstore;
wire p1int;
wire p2int;
wire p2bint;
wire pcounter_jmp_restart_r;
wire  [5:0] regadr;
wire x_idecode2b;
wire en1;
wire ifetch_aligned;
wire pcen;
wire pcen_niv;
wire p2_dopred;
wire p2_dorel;
wire  [INSTR_UBND:0] p2_iw_r;
wire p2_lp_instr;
wire  [5:0] p2_s1a;
wire  [5:0] p2_s2a;
wire p2condtrue;
wire p2limm;
wire  [5:0] p2minoropcode;
wire  [2:0] p2subopcode3_r;
wire p2subopcode4_r;
wire  [1:0] p2subopcode5_r;
wire  [2:0] p2subopcode6_r;
wire  [1:0] p2subopcode7_r;
wire p2b_abs_op;
wire  [1:0] p2b_alu_op;
wire p2b_arithiv;
wire p2b_blcc_a;
wire p2b_delay_slot;
wire p2b_dojcc;
wire p2b_jlcc_a;
wire p2b_limm;
wire p2b_lr;
wire p2b_neg_op;
wire p2b_not_op;
wire p2b_shift_by_one_a;
wire p2b_shift_by_three_a;
wire p2b_shift_by_two_a;
wire p2b_shift_by_zero_a;
wire  [12:0] p2b_shimm_data;
wire p2b_shimm_s1_a;
wire p2b_shimm_s2_a;
wire sc_load1;
wire sc_load2;
wire p4_docmprel;
wire loopcount_hit_a;
wire kill_p1_nlp_a;
wire kill_tagged_p1;
wire  [PC_MSB:0] currentpc_r;
wire misaligned_target;
wire pc_is_linear_r;
wire  [PC_MSB:0] next_pc;
wire  [PC_MSB:0] last_pc_plus_len;
wire  [PC_MSB:0] p2b_pc_r;
wire  [PC_MSB:0] p2_target;
wire  [DATAWORD_MSB:0] p2_s1val_tmp_r;
wire  [31:0] drd;
wire  [31:0] p3res_sc;
wire  [31:0] p3result;
wire  [63:0] lmulres_r;
wire hold_host;
wire cr_hostr;
wire h_status32;
wire  [31:0] dmp_dwr;
wire dmp_en3;
wire  [31:0] dmp_addr;
wire  [1:0] dmp_size;
wire dmp_sex;
wire hold_loc;
wire is_code_ram;
wire code_dmi_req;
wire  [31:0] code_dmi_addr;
wire  [31:0] code_dmi_wdata;
wire code_dmi_wr;
wire  [3:0] code_dmi_be;
wire  [CODE_RAM_ADDR_MSB-CODE_RAM_ADDR_LSB:0] code_ram_addr;
wire  [31:0] code_ram_wdata;
wire code_ram_wr;
wire  [3:0] code_ram_be;
wire code_ram_ck_en;
wire  [31:0] s1bus;
wire  [31:0] s2bus;
wire  [31:0] ext_s1val;
wire  [31:0] ext_s2val;
wire ivalid_aligned;
wire loop_kill_p1_a;
wire loop_int_holdoff_a;
wire loopend_hit_a;
wire  [DATAWORD_MSB:0] p1iw_aligned_a;
wire code_stall_ldst;
wire  [31:0] s2val;
wire ic_busy;
wire aligner_do_pc_plus_8;
wire aligner_pc_enable;
wire ivalid;
wire  [PC_MSB:0] loopstart_r;
wire p1inst_16;
wire do_loop_a;
wire  [31:0] qd_b;
wire  [31:0] x2data_2_pc;
wire  [31:0] s1val;
wire s2val_inverted_r;
wire  [31:0] dwr;
wire  [31:0] h_rr_data;
wire  [PC_MSB:0] loopend_r;
wire sr_xhold_host_a;
wire  [31:0] p1iw;
wire  [31:0] code_drd;
wire code_ldvalid_r;
wire  [31:0] code_dmi_rdata;


// Intermediate signals
wire i_ivalid;
wire i_do_loop_a;
wire  [31:0] i_p1iw;
wire  [31:0] i_x1data;
wire  [31:0] i_x2data;
wire i_ifetch;


// Dummy signals for 'unconnected' ports
// (doing this, rather than leaving them genuinely unconnected, stops
//  simulators emitting pointless warnings)


// Instantiation of module coreregs
coreregs icoreregs(
  .en(en),
  .rst_a(rst_a),
  .test_mode(test_mode),
  .clk(clk),
  .s1en(s1en),
  .s2en(s2en),
  .en2(en2),
  .mstore2b(mstore2b),
  .p2iv(p2iv),
  .en2b(en2b),
  .p2b_iv(p2b_iv),
  .aux_addr(aux_addr),
  .aux_dataw(aux_dataw),
  .aux_write(aux_write),
  .h_addr(h_addr),
  .h_read(h_read),
  .s1a(s1a),
  .s2a(s2a),
  .fs2a(fs2a),
  .wba(wba),
  .wbdata(wbdata),
  .wben(wben),
  .core_access(core_access),
  .sc_reg1(sc_reg1),
  .sc_reg2(sc_reg2),
  .ldvalid(ldvalid),
  .p1int(p1int),
  .p2int(p2int),
  .p2bint(p2bint),
  .pcounter_jmp_restart_r(pcounter_jmp_restart_r),
  .regadr(regadr),
  .x_idecode2b(x_idecode2b),
  .en1(en1),
  .pcen(pcen),
  .p2_iw_r(p2_iw_r),
  .p2_lp_instr(p2_lp_instr),
  .p2_s1a(p2_s1a),
  .p2_s2a(p2_s2a),
  .p2condtrue(p2condtrue),
  .p2b_abs_op(p2b_abs_op),
  .p2b_alu_op(p2b_alu_op),
  .p2b_arithiv(p2b_arithiv),
  .p2b_blcc_a(p2b_blcc_a),
  .p2b_delay_slot(p2b_delay_slot),
  .p2b_jlcc_a(p2b_jlcc_a),
  .p2b_limm(p2b_limm),
  .p2b_lr(p2b_lr),
  .p2b_neg_op(p2b_neg_op),
  .p2b_not_op(p2b_not_op),
  .p2b_shift_by_one_a(p2b_shift_by_one_a),
  .p2b_shift_by_three_a(p2b_shift_by_three_a),
  .p2b_shift_by_two_a(p2b_shift_by_two_a),
  .p2b_shift_by_zero_a(p2b_shift_by_zero_a),
  .p2b_shimm_data(p2b_shimm_data),
  .p2b_shimm_s1_a(p2b_shimm_s1_a),
  .p2b_shimm_s2_a(p2b_shimm_s2_a),
  .sc_load1(sc_load1),
  .sc_load2(sc_load2),
  .loopcount_hit_a(loopcount_hit_a),
  .kill_p1_nlp_a(kill_p1_nlp_a),
  .currentpc_r(currentpc_r),
  .pc_is_linear_r(pc_is_linear_r),
  .last_pc_plus_len(last_pc_plus_len),
  .p2b_pc_r(p2b_pc_r),
  .p2_target(p2_target),
  .p2_s1val_tmp_r(p2_s1val_tmp_r),
  .drd(drd),
  .p3res_sc(p3res_sc),
  .p3result(p3result),
  .x1data(i_x1data),
  .x2data(i_x2data),
  .hold_host(hold_host),
  .cr_hostr(cr_hostr),
  .s1bus(s1bus),
  .s2bus(s2bus),
  .ext_s1val(ext_s1val),
  .ext_s2val(ext_s2val),
  .loop_kill_p1_a(loop_kill_p1_a),
  .loop_int_holdoff_a(loop_int_holdoff_a),
  .loopend_hit_a(loopend_hit_a),
  .s2val(s2val),
  .loopstart_r(loopstart_r),
  .do_loop_a(i_do_loop_a),
  .qd_b(qd_b),
  .s1val(s1val),
  .s2val_inverted_r(s2val_inverted_r),
  .dwr(dwr),
  .h_rr_data(h_rr_data),
  .loopend_r(loopend_r),
  .sr_xhold_host_a(sr_xhold_host_a)
);


// Instantiation of module xcoreregs
xcoreregs ixcoreregs(
  .clk(clk),
  .rst_a(rst_a),
  .p2minoropcode(p2minoropcode),
  .p2opcode(p2opcode),
  .p2subopcode(p2subopcode),
  .p2subopcode3_r(p2subopcode3_r),
  .p2subopcode4_r(p2subopcode4_r),
  .p2subopcode5_r(p2subopcode5_r),
  .p2subopcode6_r(p2subopcode6_r),
  .p2subopcode7_r(p2subopcode7_r),
  .lmulres_r(lmulres_r),
  .s1a(s1a),
  .s2a(s2a),
  .wba(wba),
  .wbdata(wbdata),
  .wben(wben),
  .ux2data_2_pc(ux2data_2_pc),
  .ux1data(ux1data),
  .ux2data(ux2data),
  .x2data_2_pc(x2data_2_pc),
  .x1data(i_x1data),
  .x2data(i_x2data)
);


// Instantiation of module inst_align
inst_align iinst_align(
  .clk(clk),
  .rst_a(rst_a),
  .p4_docmprel(p4_docmprel),
  .p2b_dojcc(p2b_dojcc),
  .p2_dorel(p2_dorel),
  .p2_dopred(p2_dopred),
  .do_loop_a(i_do_loop_a),
  .do_inst_step_r(do_inst_step_r),
  .en1(en1),
  .en2(en2),
  .en2b(en2b),
  .h_pcwr(h_pcwr),
  .h_pcwr32(h_pcwr32),
  .h_status32(h_status32),
  .ifetch_aligned(ifetch_aligned),
  .ivalid(i_ivalid),
  .ivic(ivic),
  .kill_tagged_p1(kill_tagged_p1),
  .misaligned_target(misaligned_target),
  .p1iw(i_p1iw),
  .pcounter_jmp_restart_r(pcounter_jmp_restart_r),
  .p2int(p2int),
  .p2limm(p2limm),
  .pcen_niv(pcen_niv),
  .ifetch(i_ifetch),
  .ivalid_aligned(ivalid_aligned),
  .p1inst_16(p1inst_16),
  .p1iw_aligned_a(p1iw_aligned_a),
  .aligner_do_pc_plus_8(aligner_do_pc_plus_8),
  .aligner_pc_enable(aligner_pc_enable)
);


// Instantiation of module if_sys
if_sys iif_sys(
  .clk_ungated(clk_ungated),
  .code_ram_rdata(code_ram_rdata),
  .rst_a(rst_a),
  .test_mode(test_mode),
  .ck_disable(ck_disable),
  .ivic(ivic),
  .dmp_mload(dmp_mload),
  .dmp_mstore(dmp_mstore),
  .next_pc(next_pc),
  .ifetch(i_ifetch),
  .dmp_dwr(dmp_dwr),
  .dmp_en3(dmp_en3),
  .dmp_addr(dmp_addr),
  .dmp_size(dmp_size),
  .dmp_sex(dmp_sex),
  .hold_loc(hold_loc),
  .is_code_ram(is_code_ram),
  .code_dmi_req(code_dmi_req),
  .code_dmi_addr(code_dmi_addr),
  .code_dmi_wdata(code_dmi_wdata),
  .code_dmi_wr(code_dmi_wr),
  .code_dmi_be(code_dmi_be),
  .code_ram_addr(code_ram_addr),
  .code_ram_wdata(code_ram_wdata),
  .code_ram_wr(code_ram_wr),
  .code_ram_be(code_ram_be),
  .code_ram_ck_en(code_ram_ck_en),
  .code_stall_ldst(code_stall_ldst),
  .ic_busy(ic_busy),
  .ivalid(i_ivalid),
  .p1iw(i_p1iw),
  .code_drd(code_drd),
  .code_ldvalid_r(code_ldvalid_r),
  .code_dmi_rdata(code_dmi_rdata)
);


// Output drives
assign ivalid                  = i_ivalid;
assign do_loop_a               = i_do_loop_a;
assign p1iw                    = i_p1iw;

endmodule


