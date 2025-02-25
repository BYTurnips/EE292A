// *SYNOPSYS CONFIDENTIAL*
//
// This is an unpublished, proprietary work of Synopsys, Inc., and is fully 
// protected under copyright and trade secret laws.  You may not view, use, 
// disclose, copy, or distribute this file or any information contained herein 
// except pursuant to a valid written license from Synopsys.


// This file is generated automatically by 'veriloggen'.




module coreregs(en,
                rst_a,
                test_mode,
                clk,
                s1en,
                s2en,
                en2,
                mstore2b,
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
                ldvalid,
                p1int,
                p2int,
                p2bint,
                pcounter_jmp_restart_r,
                regadr,
                x_idecode2b,
                en1,
                pcen,
                p2_iw_r,
                p2_lp_instr,
                p2_s1a,
                p2_s2a,
                p2condtrue,
                p2b_abs_op,
                p2b_alu_op,
                p2b_arithiv,
                p2b_blcc_a,
                p2b_delay_slot,
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
                loopcount_hit_a,
                kill_p1_nlp_a,
                currentpc_r,
                pc_is_linear_r,
                last_pc_plus_len,
                p2b_pc_r,
                p2_target,
                p2_s1val_tmp_r,
                drd,
                p3res_sc,
                p3result,
                x1data,
                x2data,
                hold_host,
                cr_hostr,
                s1bus,
                s2bus,
                ext_s1val,
                ext_s2val,
                loop_kill_p1_a,
                loop_int_holdoff_a,
                loopend_hit_a,
                s2val,
                loopstart_r,
                do_loop_a,
                qd_b,
                s1val,
                s2val_inverted_r,
                dwr,
                h_rr_data,
                loopend_r,
                sr_xhold_host_a);


// Includes found automatically in dependent files.
`include "arcutil_pkg_defines.v"
`include "arcutil.v"
`include "extutil.v"


input  en;
input  rst_a;
input  test_mode;
input  clk;
input  s1en;
input  s2en;
input  en2;
input  mstore2b;
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
input  ldvalid;
input  p1int;
input  p2int;
input  p2bint;
input  pcounter_jmp_restart_r;
input  [5:0]  regadr;
input  x_idecode2b;
input  en1;
input  pcen;
input  [INSTR_UBND:0]  p2_iw_r;
input  p2_lp_instr;
input  [5:0]  p2_s1a;
input  [5:0]  p2_s2a;
input  p2condtrue;
input  p2b_abs_op;
input  [1:0]  p2b_alu_op;
input  p2b_arithiv;
input  p2b_blcc_a;
input  p2b_delay_slot;
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
input  loopcount_hit_a;
input  kill_p1_nlp_a;
input  [PC_MSB:0]  currentpc_r;
input  pc_is_linear_r;
input  [PC_MSB:0]  last_pc_plus_len;
input  [PC_MSB:0]  p2b_pc_r;
input  [PC_MSB:0]  p2_target;
input  [DATAWORD_MSB:0]  p2_s1val_tmp_r;
input  [31:0]  drd;
input  [31:0]  p3res_sc;
input  [31:0]  p3result;
input  [31:0]  x1data;
input  [31:0]  x2data;
input  hold_host;
input  cr_hostr;
output [31:0]  s1bus;
output [31:0]  s2bus;
output [31:0]  ext_s1val;
output [31:0]  ext_s2val;
output loop_kill_p1_a;
output loop_int_holdoff_a;
output loopend_hit_a;
output [31:0]  s2val;
output [PC_MSB:0]  loopstart_r;
output do_loop_a;
output [31:0]  qd_b;
output [31:0]  s1val;
output s2val_inverted_r;
output [31:0]  dwr;
output [31:0]  h_rr_data;
output [PC_MSB:0]  loopend_r;
output sr_xhold_host_a;

wire en;
wire rst_a;
wire test_mode;
wire clk;
wire s1en;
wire s2en;
wire en2;
wire mstore2b;
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
wire ldvalid;
wire p1int;
wire p2int;
wire p2bint;
wire pcounter_jmp_restart_r;
wire  [5:0] regadr;
wire x_idecode2b;
wire en1;
wire pcen;
wire  [INSTR_UBND:0] p2_iw_r;
wire p2_lp_instr;
wire  [5:0] p2_s1a;
wire  [5:0] p2_s2a;
wire p2condtrue;
wire p2b_abs_op;
wire  [1:0] p2b_alu_op;
wire p2b_arithiv;
wire p2b_blcc_a;
wire p2b_delay_slot;
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
wire loopcount_hit_a;
wire kill_p1_nlp_a;
wire  [PC_MSB:0] currentpc_r;
wire pc_is_linear_r;
wire  [PC_MSB:0] last_pc_plus_len;
wire  [PC_MSB:0] p2b_pc_r;
wire  [PC_MSB:0] p2_target;
wire  [DATAWORD_MSB:0] p2_s1val_tmp_r;
wire  [31:0] drd;
wire  [31:0] p3res_sc;
wire  [31:0] p3result;
wire  [31:0] x1data;
wire  [31:0] x2data;
wire hold_host;
wire cr_hostr;
wire  [31:0] s1bus;
wire  [31:0] s2bus;
wire  [31:0] ext_s1val;
wire  [31:0] ext_s2val;
wire loop_kill_p1_a;
wire loop_int_holdoff_a;
wire loopend_hit_a;
wire  [31:0] s2val;
wire  [PC_MSB:0] loopstart_r;
wire do_loop_a;
wire  [31:0] qd_b;
wire  [31:0] s1val;
wire s2val_inverted_r;
wire  [31:0] dwr;
wire  [31:0] h_rr_data;
wire  [PC_MSB:0] loopend_r;
wire sr_xhold_host_a;


// Intermediate signals
wire  [31:0] i_qd_b;
wire  [LOOPCNT_MSB:0] i_loopcount_r;
wire  [31:0] i_qd_a;
wire  [31:0] i_s3p_qa;
wire  [31:0] i_s3p_qb;
wire  [4:0] i_s3p_aw;
wire  [4:0] i_s3p_ara;
wire  [4:0] i_s3p_arb;
wire i_s3p_we;
wire i_ck_en_w;
wire i_ck_en_a;
wire i_ck_en_b;


// Dummy signals for 'unconnected' ports
// (doing this, rather than leaving them genuinely unconnected, stops
//  simulators emitting pointless warnings)
wire u_unconnected_0;
wire  [31:0] u_unconnected_1;
wire u_unconnected_2;
wire u_unconnected_3;


// Instantiation of module cr_int
cr_int icr_int(
  .clk(clk),
  .rst_a(rst_a),
  .currentpc_r(currentpc_r),
  .drd(drd),
  .en2b(en2b),
  .loopcount_r(i_loopcount_r),
  .mstore2b(mstore2b),
  .last_pc_plus_len(last_pc_plus_len),
  .p2_iw_r(p2_iw_r),
  .p2b_pc_r(p2b_pc_r),
  .p2_s1val_tmp_r(p2_s1val_tmp_r),
  .p2b_abs_op(p2b_abs_op),
  .p2b_alu_op(p2b_alu_op),
  .p2b_arithiv(p2b_arithiv),
  .p2b_delay_slot(p2b_delay_slot),
  .p2b_iv(p2b_iv),
  .p2b_jlcc_a(p2b_jlcc_a),
  .p2b_blcc_a(p2b_blcc_a),
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
  .p2bint(p2bint),
  .p3res_sc(p3res_sc),
  .qd_a(i_qd_a),
  .qd_b(i_qd_b),
  .s1a(s1a),
  .s1en(s1en),
  .s2a(s2a),
  .s2en(s2en),
  .sc_load1(sc_load1),
  .sc_load2(sc_load2),
  .sc_reg1(sc_reg1),
  .sc_reg2(sc_reg2),
  .wba(wba),
  .wben(wben),
  .x1data(x1data),
  .x2data(x2data),
  .x_idecode2b(x_idecode2b),
  .dwr(dwr),
  .ext_s1val(ext_s1val),
  .ext_s2val(ext_s2val),
  .h_rr_data(h_rr_data),
  .r_wben(u_unconnected_0),
  .s1bus(s1bus),
  .s1val(s1val),
  .s2bus(s2bus),
  .s2val(s2val),
  .s2val_inverted_r(s2val_inverted_r),
  .stval(u_unconnected_1)
);


// Instantiation of module loopcnt
loopcnt iloopcnt(
  .clk(clk),
  .rst_a(rst_a),
  .aux_addr(aux_addr),
  .aux_dataw(aux_dataw),
  .aux_write(aux_write),
  .currentpc_r(currentpc_r),
  .en1(en1),
  .en2(en2),
  .kill_p1_nlp_a(kill_p1_nlp_a),
  .loopcount_hit_a(loopcount_hit_a),
  .p1int(p1int),
  .p2_lp_instr(p2_lp_instr),
  .p2_target(p2_target),
  .p2condtrue(p2condtrue),
  .p2int(p2int),
  .p2iv(p2iv),
  .p3result(p3result),
  .pc_is_linear_r(pc_is_linear_r),
  .pcen(pcen),
  .pcounter_jmp_restart_r(pcounter_jmp_restart_r),
  .loop_int_holdoff_a(loop_int_holdoff_a),
  .do_loop_a(do_loop_a),
  .loop_kill_p1_a(loop_kill_p1_a),
  .loopcount_r(i_loopcount_r),
  .loopend_hit_a(loopend_hit_a),
  .loopend_r(loopend_r),
  .loopstart_r(loopstart_r)
);


// Instantiation of module sync_regs
sync_regs isync_regs(
  .clk(clk),
  .rst_a(rst_a),
  .en(en),
  .core_access(core_access),
  .hold_host(hold_host),
  .en2(en2),
  .fs2a(fs2a),
  .p2_s1a(p2_s1a),
  .p2_s2a(p2_s2a),
  .s1a(s1a),
  .h_addr(h_addr),
  .h_read(h_read),
  .wben(wben),
  .wbdata(wbdata),
  .wba(wba),
  .regadr(regadr),
  .ldvalid(ldvalid),
  .s3p_qa(i_s3p_qa),
  .s3p_qb(i_s3p_qb),
  .p2iv(p2iv),
  .cr_hostr(cr_hostr),
  .test_mode(test_mode),
  .sr_xhold_host_a(sr_xhold_host_a),
  .ldv_r0r31(u_unconnected_2),
  .qd_a(i_qd_a),
  .qd_b(i_qd_b),
  .s3p_aw(i_s3p_aw),
  .s3p_ara(i_s3p_ara),
  .s3p_arb(i_s3p_arb),
  .s3p_we(i_s3p_we),
  .ck_en_w(i_ck_en_w),
  .ck_en_w2(u_unconnected_3),
  .ck_en_a(i_ck_en_a),
  .ck_en_b(i_ck_en_b)
);


// Instantiation of module regfile_3p_wrap
regfile_3p_wrap iregfile_3p_wrap(
  .clk(clk),
  .s3p_aw(i_s3p_aw),
  .s3p_ara(i_s3p_ara),
  .s3p_arb(i_s3p_arb),
  .wbdata(wbdata),
  .s3p_we(i_s3p_we),
  .ck_en_w(i_ck_en_w),
  .ck_en_a(i_ck_en_a),
  .ck_en_b(i_ck_en_b),
  .s3p_qa(i_s3p_qa),
  .s3p_qb(i_s3p_qb)
);


// Output drives
assign qd_b                    = i_qd_b;

endmodule


