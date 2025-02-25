// *SYNOPSYS CONFIDENTIAL*
//
// This is an unpublished, proprietary work of Synopsys, Inc., and is fully 
// protected under copyright and trade secret laws.  You may not view, use, 
// disclose, copy, or distribute this file or any information contained herein 
// except pursuant to a valid written license from Synopsys.


// This file is generated automatically by 'veriloggen'.




module control(clk_ungated,
               en,
               rst_a,
               wd_clear,
               ctrl_cpu_start_sync_r,
               test_mode,
               clk,
               ibus_busy,
               mem_access,
               memory_error,
               s1bus,
               s2bus,
               aluflags_r,
               ext_s2val,
               aux_addr,
               aux_dataw,
               aux_write,
               h_addr,
               h_dataw,
               h_write,
               aux_access,
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
               actionhalt,
               actionpt_swi_a,
               actionpt_pc_brk_a,
               p2_ap_stall_a,
               br_flags_a,
               cr_hostw,
               do_inst_step_r,
               h_pcwr,
               h_pcwr32,
               h_regadr,
               ivalid_aligned,
               ivic,
               ldvalid,
               loop_kill_p1_a,
               loop_int_holdoff_a,
               loopend_hit_a,
               sync_queue_idle,
               debug_if_r,
               dmp_mload,
               dmp_mstore,
               is_local_ram,
               mwait,
               p1iw_aligned_a,
               sleeping,
               sleeping_r2,
               code_stall_ldst,
               mulatwork_r,
               dmp_holdup12,
               s2val,
               irq,
               int_vector_base_r,
               misaligned_int,
               e1flag_r,
               e2flag_r,
               q_ldvalid,
               loc_ldvalid,
               is_peripheral,
               dc_disable_r,
               q_busy,
               host_rw,
               ic_busy,
               cgm_queue_idle,
               pcp_rd_rq,
               pcp_wr_rq,
               aligner_do_pc_plus_8,
               aligner_pc_enable,
               ivalid,
               loopstart_r,
               p1inst_16,
               do_loop_a,
               qd_b,
               x2data_2_pc,
               step,
               inst_step,
               ck_disable,
               ck_dmp_gated,
               s1en,
               s2en,
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
               s1a,
               fs2a,
               wba,
               wben,
               dest,
               desten,
               sc_reg1,
               sc_reg2,
               p3_xmultic_nwb,
               lpending,
               p1int,
               p2int,
               p2bint,
               p3int,
               pcounter_jmp_restart_r,
               regadr,
               x_idecode2b,
               x_multic_busy,
               x_multic_wben,
               x_snglec_wben,
               en1,
               ifetch_aligned,
               inst_stepping,
               instr_pending_r,
               pcen,
               pcen_niv,
               brk_inst_a,
               p2_brcc_instr_a,
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
               p2b_condtrue,
               p2b_delay_slot,
               p2b_dojcc,
               p2b_jlcc_a,
               p2b_limm,
               p2b_lr,
               p2b_neg_op,
               p2b_not_op,
               p2b_setflags,
               p2b_shift_by_one_a,
               p2b_shift_by_three_a,
               p2b_shift_by_two_a,
               p2b_shift_by_zero_a,
               p2b_shimm_data,
               p2b_shimm_s1_a,
               p2b_shimm_s2_a,
               p2b_jmp_holdup_a,
               en3_niv_a,
               ldvalid_wb,
               mload,
               mstore,
               nocache,
               p3_alu_absiv,
               p3_alu_arithiv,
               p3_alu_logiciv,
               p3_alu_op,
               p3_alu_snglopiv,
               p3_bit_op_sel,
               p3_brcc_instr_a,
               p3_docmprel_a,
               p3_flag_instr,
               p3_sync_instr,
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
               sc_load1,
               sc_load2,
               sex,
               size,
               p4_docmprel,
               loopcount_hit_a,
               p4_disable_r,
               kill_p1_nlp_a,
               kill_p2_a,
               kill_tagged_p1,
               stop_step,
               barrel_type_r,
               x_p3_brl_decode_16_r,
               x_p3_brl_decode_32_r,
               x_p3_norm_decode_r,
               x_p3_snorm_decode_r,
               x_p3_swap_decode_r,
               x_flgen,
               xsetflags,
               x_set_sflag,
               p3ilev1,
               aux_lv12,
               aux_hint,
               aux_lev,
               max_one_lpend,
               ctrl_cpu_start_r,
               ck_gated,
               currentpc_r,
               misaligned_target,
               pc_is_linear_r,
               next_pc,
               last_pc_plus_len,
               p2b_pc_r,
               p2_target,
               p2_s1val_tmp_r,
               pcounter_jmp_restart_a);


// Includes found automatically in dependent files.
`include "arcutil_pkg_defines.v"
`include "arcutil.v"
`include "extutil.v"
`include "asmutil.v"
`include "xdefs.v"


input  clk_ungated;
input  en;
input  rst_a;
input  wd_clear;
input  ctrl_cpu_start_sync_r;
input  test_mode;
input  clk;
input  ibus_busy;
input  mem_access;
input  memory_error;
input  [31:0]  s1bus;
input  [31:0]  s2bus;
input  [3:0]  aluflags_r;
input  [31:0]  ext_s2val;
input  [31:0]  aux_addr;
input  [31:0]  aux_dataw;
input  aux_write;
input  [31:0]  h_addr;
input  [31:0]  h_dataw;
input  h_write;
input  aux_access;
input  ux_p2nosc1;
input  ux_p2nosc2;
input  uxp2bccmatch;
input  uxp2ccmatch;
input  uxp3ccmatch;
input  uxholdup2;
input  uxholdup2b;
input  uxholdup3;
input  ux_isop_decode2;
input  ux_idop_decode2;
input  ux_izop_decode2;
input  uxnwb;
input  uxp2idest;
input  uxsetflags;
input  ux_flgen;
input  [5:0]  ux_multic_wba;
input  ux_multic_wben;
input  ux_multic_busy;
input  ux_p1_rev_src;
input  ux_p2_bfield_wb_a;
input  ux_p2_jump_decode;
input  ux_snglec_wben;
input  actionhalt;
input  actionpt_swi_a;
input  actionpt_pc_brk_a;
input  p2_ap_stall_a;
input  [3:0]  br_flags_a;
input  cr_hostw;
input  do_inst_step_r;
input  h_pcwr;
input  h_pcwr32;
input  [5:0]  h_regadr;
input  ivalid_aligned;
input  ivic;
input  ldvalid;
input  loop_kill_p1_a;
input  loop_int_holdoff_a;
input  loopend_hit_a;
input  sync_queue_idle;
input  debug_if_r;
input  dmp_mload;
input  dmp_mstore;
input  is_local_ram;
input  mwait;
input  [DATAWORD_MSB:0]  p1iw_aligned_a;
input  sleeping;
input  sleeping_r2;
input  code_stall_ldst;
input  mulatwork_r;
input  dmp_holdup12;
input  [31:0]  s2val;
input  [31:3]  irq;
input  [PC_MSB:`INT_BASE_LSB]  int_vector_base_r;
input  misaligned_int;
input  e1flag_r;
input  e2flag_r;
input  q_ldvalid;
input  loc_ldvalid;
input  is_peripheral;
input  dc_disable_r;
input  q_busy;
input  host_rw;
input  ic_busy;
input  cgm_queue_idle;
input  pcp_rd_rq;
input  pcp_wr_rq;
input  aligner_do_pc_plus_8;
input  aligner_pc_enable;
input  ivalid;
input  [PC_MSB:0]  loopstart_r;
input  p1inst_16;
input  do_loop_a;
input  [31:0]  qd_b;
input  [31:0]  x2data_2_pc;
input  step;
input  inst_step;
output ck_disable;
output ck_dmp_gated;
output s1en;
output s2en;
output en2;
output mload2b;
output mstore2b;
output [4:0]  p2opcode;
output [5:0]  p2subopcode;
output [4:0]  p2subopcode2_r;
output [5:0]  p2_a_field_r;
output [5:0]  p2_b_field_r;
output [5:0]  p2_c_field_r;
output p2iv;
output [3:0]  p2cc;
output p2conditional;
output p2sleep_inst;
output p2setflags;
output p2st;
output [1:0]  p2format;
output p2bch;
output p2dop32_inst;
output p2sop32_inst;
output p2zop32_inst;
output p2dop16_inst;
output p2sop16_inst;
output p2zop16_inst;
output en2b;
output p2b_iv;
output p2b_conditional;
output [3:0]  p2b_cc;
output p2b_dop32_inst;
output p2b_sop32_inst;
output p2b_zop32_inst;
output p2b_dop16_inst;
output p2b_sop16_inst;
output p2b_zop16_inst;
output [4:0]  p2b_opcode;
output [5:0]  p2b_subopcode;
output [5:0]  p2b_a_field_r;
output [5:0]  p2b_b_field_r;
output [5:0]  p2b_c_field_r;
output en3;
output p3iv;
output [4:0]  p3opcode;
output [5:0]  p3subopcode;
output [4:0]  p3subopcode2_r;
output [5:0]  p3a_field_r;
output [5:0]  p3b_field_r;
output [5:0]  p3c_field_r;
output [3:0]  p3cc;
output p3condtrue;
output p3destlimm;
output [1:0]  p3format;
output p3setflags;
output x_idecode3;
output p3wb_en;
output [5:0]  p3wba;
output p3lr;
output p3sr;
output p3dop32_inst;
output p3sop32_inst;
output p3zop32_inst;
output p3dop16_inst;
output p3sop16_inst;
output p3zop16_inst;
output [5:0]  s1a;
output [5:0]  fs2a;
output [5:0]  wba;
output wben;
output [5:0]  dest;
output desten;
output sc_reg1;
output sc_reg2;
output p3_xmultic_nwb;
output lpending;
output p1int;
output p2int;
output p2bint;
output p3int;
output pcounter_jmp_restart_r;
output [5:0]  regadr;
output x_idecode2b;
output x_multic_busy;
output x_multic_wben;
output x_snglec_wben;
output en1;
output ifetch_aligned;
output inst_stepping;
output instr_pending_r;
output pcen;
output pcen_niv;
output brk_inst_a;
output p2_brcc_instr_a;
output p2_dopred;
output p2_dorel;
output [INSTR_UBND:0]  p2_iw_r;
output p2_lp_instr;
output [5:0]  p2_s1a;
output [5:0]  p2_s2a;
output p2condtrue;
output p2limm;
output [5:0]  p2minoropcode;
output [2:0]  p2subopcode3_r;
output p2subopcode4_r;
output [1:0]  p2subopcode5_r;
output [2:0]  p2subopcode6_r;
output [1:0]  p2subopcode7_r;
output p2b_abs_op;
output [1:0]  p2b_alu_op;
output p2b_arithiv;
output p2b_blcc_a;
output p2b_condtrue;
output p2b_delay_slot;
output p2b_dojcc;
output p2b_jlcc_a;
output p2b_limm;
output p2b_lr;
output p2b_neg_op;
output p2b_not_op;
output p2b_setflags;
output p2b_shift_by_one_a;
output p2b_shift_by_three_a;
output p2b_shift_by_two_a;
output p2b_shift_by_zero_a;
output [12:0]  p2b_shimm_data;
output p2b_shimm_s1_a;
output p2b_shimm_s2_a;
output p2b_jmp_holdup_a;
output en3_niv_a;
output ldvalid_wb;
output mload;
output mstore;
output nocache;
output p3_alu_absiv;
output p3_alu_arithiv;
output p3_alu_logiciv;
output [1:0]  p3_alu_op;
output p3_alu_snglopiv;
output [1:0]  p3_bit_op_sel;
output p3_brcc_instr_a;
output p3_docmprel_a;
output p3_flag_instr;
output p3_sync_instr;
output p3_max_instr;
output p3_min_instr;
output [1:0]  p3_shiftin_sel_r;
output [2:0]  p3_sop_op_r;
output [1:0]  p3awb_field_r;
output p3dolink;
output [5:0]  p3minoropcode;
output [2:0]  p3subopcode3_r;
output p3subopcode4_r;
output [1:0]  p3subopcode5_r;
output [2:0]  p3subopcode6_r;
output [1:0]  p3subopcode7_r;
output sc_load1;
output sc_load2;
output sex;
output [1:0]  size;
output p4_docmprel;
output loopcount_hit_a;
output p4_disable_r;
output kill_p1_nlp_a;
output kill_p2_a;
output kill_tagged_p1;
output stop_step;
output [1:0]  barrel_type_r;
output x_p3_brl_decode_16_r;
output x_p3_brl_decode_32_r;
output x_p3_norm_decode_r;
output x_p3_snorm_decode_r;
output x_p3_swap_decode_r;
output x_flgen;
output xsetflags;
output x_set_sflag;
output p3ilev1;
output [1:0]  aux_lv12;
output [4:0]  aux_hint;
output [31:3]  aux_lev;
output max_one_lpend;
output ctrl_cpu_start_r;
output ck_gated;
output [PC_MSB:0]  currentpc_r;
output misaligned_target;
output pc_is_linear_r;
output [PC_MSB:0]  next_pc;
output [PC_MSB:0]  last_pc_plus_len;
output [PC_MSB:0]  p2b_pc_r;
output [PC_MSB:0]  p2_target;
output [DATAWORD_MSB:0]  p2_s1val_tmp_r;
output pcounter_jmp_restart_a;

wire clk_ungated;
wire en;
wire rst_a;
wire wd_clear;
wire ctrl_cpu_start_sync_r;
wire test_mode;
wire clk;
wire ibus_busy;
wire mem_access;
wire memory_error;
wire  [31:0] s1bus;
wire  [31:0] s2bus;
wire  [3:0] aluflags_r;
wire  [31:0] ext_s2val;
wire  [31:0] aux_addr;
wire  [31:0] aux_dataw;
wire aux_write;
wire  [31:0] h_addr;
wire  [31:0] h_dataw;
wire h_write;
wire aux_access;
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
wire actionhalt;
wire actionpt_swi_a;
wire actionpt_pc_brk_a;
wire p2_ap_stall_a;
wire  [3:0] br_flags_a;
wire cr_hostw;
wire do_inst_step_r;
wire h_pcwr;
wire h_pcwr32;
wire  [5:0] h_regadr;
wire ivalid_aligned;
wire ivic;
wire ldvalid;
wire loop_kill_p1_a;
wire loop_int_holdoff_a;
wire loopend_hit_a;
wire sync_queue_idle;
wire debug_if_r;
wire dmp_mload;
wire dmp_mstore;
wire is_local_ram;
wire mwait;
wire  [DATAWORD_MSB:0] p1iw_aligned_a;
wire sleeping;
wire sleeping_r2;
wire code_stall_ldst;
wire mulatwork_r;
wire dmp_holdup12;
wire  [31:0] s2val;
wire  [31:3] irq;
wire  [PC_MSB:`INT_BASE_LSB] int_vector_base_r;
wire misaligned_int;
wire e1flag_r;
wire e2flag_r;
wire q_ldvalid;
wire loc_ldvalid;
wire is_peripheral;
wire dc_disable_r;
wire q_busy;
wire host_rw;
wire ic_busy;
wire cgm_queue_idle;
wire pcp_rd_rq;
wire pcp_wr_rq;
wire aligner_do_pc_plus_8;
wire aligner_pc_enable;
wire ivalid;
wire  [PC_MSB:0] loopstart_r;
wire p1inst_16;
wire do_loop_a;
wire  [31:0] qd_b;
wire  [31:0] x2data_2_pc;
wire step;
wire inst_step;
wire ck_disable;
wire ck_dmp_gated;
wire s1en;
wire s2en;
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
wire  [5:0] s1a;
wire  [5:0] fs2a;
wire  [5:0] wba;
wire wben;
wire  [5:0] dest;
wire desten;
wire sc_reg1;
wire sc_reg2;
wire p3_xmultic_nwb;
wire lpending;
wire p1int;
wire p2int;
wire p2bint;
wire p3int;
wire pcounter_jmp_restart_r;
wire  [5:0] regadr;
wire x_idecode2b;
wire x_multic_busy;
wire x_multic_wben;
wire x_snglec_wben;
wire en1;
wire ifetch_aligned;
wire inst_stepping;
wire instr_pending_r;
wire pcen;
wire pcen_niv;
wire brk_inst_a;
wire p2_brcc_instr_a;
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
wire p2b_condtrue;
wire p2b_delay_slot;
wire p2b_dojcc;
wire p2b_jlcc_a;
wire p2b_limm;
wire p2b_lr;
wire p2b_neg_op;
wire p2b_not_op;
wire p2b_setflags;
wire p2b_shift_by_one_a;
wire p2b_shift_by_three_a;
wire p2b_shift_by_two_a;
wire p2b_shift_by_zero_a;
wire  [12:0] p2b_shimm_data;
wire p2b_shimm_s1_a;
wire p2b_shimm_s2_a;
wire p2b_jmp_holdup_a;
wire en3_niv_a;
wire ldvalid_wb;
wire mload;
wire mstore;
wire nocache;
wire p3_alu_absiv;
wire p3_alu_arithiv;
wire p3_alu_logiciv;
wire  [1:0] p3_alu_op;
wire p3_alu_snglopiv;
wire  [1:0] p3_bit_op_sel;
wire p3_brcc_instr_a;
wire p3_docmprel_a;
wire p3_flag_instr;
wire p3_sync_instr;
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
wire sc_load1;
wire sc_load2;
wire sex;
wire  [1:0] size;
wire p4_docmprel;
wire loopcount_hit_a;
wire p4_disable_r;
wire kill_p1_nlp_a;
wire kill_p2_a;
wire kill_tagged_p1;
wire stop_step;
wire  [1:0] barrel_type_r;
wire x_p3_brl_decode_16_r;
wire x_p3_brl_decode_32_r;
wire x_p3_norm_decode_r;
wire x_p3_snorm_decode_r;
wire x_p3_swap_decode_r;
wire x_flgen;
wire xsetflags;
wire x_set_sflag;
wire p3ilev1;
wire  [1:0] aux_lv12;
wire  [4:0] aux_hint;
wire  [31:3] aux_lev;
wire max_one_lpend;
wire ctrl_cpu_start_r;
wire ck_gated;
wire  [PC_MSB:0] currentpc_r;
wire misaligned_target;
wire pc_is_linear_r;
wire  [PC_MSB:0] next_pc;
wire  [PC_MSB:0] last_pc_plus_len;
wire  [PC_MSB:0] p2b_pc_r;
wire  [PC_MSB:0] p2_target;
wire  [DATAWORD_MSB:0] p2_s1val_tmp_r;
wire pcounter_jmp_restart_a;


// Intermediate signals
wire i_s1en;
wire i_s2en;
wire i_en2;
wire i_mload2b;
wire i_mstore2b;
wire  [4:0] i_p2opcode;
wire  [5:0] i_p2subopcode;
wire  [4:0] i_p2subopcode2_r;
wire  [5:0] i_p2_a_field_r;
wire  [5:0] i_p2_b_field_r;
wire  [5:0] i_p2_c_field_r;
wire i_p2iv;
wire  [3:0] i_p2cc;
wire i_p2conditional;
wire i_p2sleep_inst;
wire i_p2setflags;
wire i_p2st;
wire  [1:0] i_p2format;
wire i_p2bch;
wire i_en2b;
wire i_p2b_iv;
wire i_p2b_conditional;
wire  [3:0] i_p2b_cc;
wire  [4:0] i_p2b_opcode;
wire  [5:0] i_p2b_subopcode;
wire  [5:0] i_p2b_a_field_r;
wire  [5:0] i_p2b_b_field_r;
wire  [5:0] i_p2b_c_field_r;
wire i_en3;
wire i_p3iv;
wire  [4:0] i_p3opcode;
wire  [5:0] i_p3subopcode;
wire  [4:0] i_p3subopcode2_r;
wire  [5:0] i_p3a_field_r;
wire  [5:0] i_p3b_field_r;
wire  [5:0] i_p3c_field_r;
wire  [3:0] i_p3cc;
wire i_p3condtrue;
wire i_p3destlimm;
wire  [1:0] i_p3format;
wire i_p3setflags;
wire i_x_idecode3;
wire i_p3wb_en;
wire  [5:0] i_p3wba;
wire i_p3lr;
wire i_p3sr;
wire  [5:0] i_s1a;
wire  [5:0] i_fs2a;
wire  [5:0] i_dest;
wire i_desten;
wire i_sc_reg1;
wire i_sc_reg2;
wire i_p3_xmultic_nwb;
wire i_lpending;
wire i_p1int;
wire i_p2int;
wire i_p2bint;
wire i_p3int;
wire i_pcounter_jmp_restart_r;
wire  [5:0] i_regadr;
wire i_x_idecode2b;
wire i_x_multic_busy;
wire i_x_multic_wben;
wire i_x_snglec_wben;
wire i_en1;
wire i_instr_pending_r;
wire i_pcen;
wire i_pcen_niv;
wire i_p2_brcc_instr_a;
wire i_p2_dopred;
wire i_p2_dorel;
wire  [INSTR_UBND:0] i_p2_iw_r;
wire  [5:0] i_p2_s1a;
wire i_p2limm;
wire  [5:0] i_p2minoropcode;
wire  [2:0] i_p2subopcode3_r;
wire i_p2subopcode4_r;
wire  [1:0] i_p2subopcode5_r;
wire  [2:0] i_p2subopcode6_r;
wire  [1:0] i_p2subopcode7_r;
wire i_p2b_dojcc;
wire i_p2b_setflags;
wire  [12:0] i_p2b_shimm_data;
wire i_p2b_shimm_s2_a;
wire i_mload;
wire i_nocache;
wire  [5:0] i_p3minoropcode;
wire  [2:0] i_p3subopcode3_r;
wire i_p4_docmprel;
wire i_p4_disable_r;
wire i_kill_p2_a;
wire i_holdup2b;
wire i_p2ilev1;
wire i_regadr_eq_src1;
wire i_regadr_eq_src2;
wire i_x_idecode2;
wire i_x_idop_decode2;
wire i_x_isop_decode2;
wire  [5:0] i_x_multic_wba;
wire i_x_p1_rev_src;
wire i_x_p2_bfield_wb_a;
wire i_x_p2_jump_decode;
wire i_x_p2b_jump_decode;
wire i_x_p2nosc1;
wire i_x_p2nosc2;
wire i_x_p2shimm_a;
wire i_xholdup2;
wire i_xholdup2b;
wire i_xholdup3;
wire i_xnwb;
wire i_xp2bccmatch;
wire i_xp2ccmatch;
wire i_xp2idest;
wire i_xp3ccmatch;
wire i_awake_a;
wire i_p2_abs_neg_a;
wire i_p2_dopred_nds;
wire i_p2_jblcc_a;
wire i_p2_not_a;
wire i_p2_s1en;
wire i_p2delay_slot;
wire i_p2lr;
wire  [TARGSZ:0] i_p2offset;
wire  [1:0] i_p2subopcode1_r;
wire i_p2b_bch;
wire i_p2b_dopred_ds;
wire  [1:0] i_p2b_format;
wire  [5:0] i_p2b_minoropcode;
wire i_p2b_st;
wire  [1:0] i_p2b_subopcode1_r;
wire  [4:0] i_p2b_subopcode2_r;
wire  [2:0] i_p2b_subopcode3_r;
wire i_p2b_subopcode4_r;
wire  [1:0] i_p2b_subopcode5_r;
wire  [2:0] i_p2b_subopcode6_r;
wire  [1:0] i_p2b_subopcode7_r;
wire  [1:0] i_p3subopcode1_r;
wire i_flagu_block;
wire i_instruction_error;
wire i_interrupt_holdoff;
wire i_kill_last;
wire i_kill_p1_a;
wire i_kill_p2b_a;
wire i_kill_p3_a;
wire i_hold_int_st2_a;
wire  [PC_MSB:0] i_int_vec;
wire i_p123int;


// Dummy signals for 'unconnected' ports
// (doing this, rather than leaving them genuinely unconnected, stops
//  simulators emitting pointless warnings)
wire u_unconnected_0;
wire  [12:0] u_unconnected_1;
wire u_unconnected_2;
wire u_unconnected_3;
wire  [1:0] u_unconnected_4;
wire  [1:0] u_unconnected_5;
wire u_unconnected_6;
wire  [4:0] u_unconnected_7;
wire u_unconnected_8;
wire  [5:0] u_unconnected_9;
wire u_unconnected_10;
wire u_unconnected_11;
wire u_unconnected_12;
wire u_unconnected_13;
wire u_unconnected_14;
wire u_unconnected_15;
wire u_unconnected_16;
wire  [PC_MSB:PC_LSB] u_unconnected_17;
wire  [PC_MSB:0] u_unconnected_18;
wire  [PC_MSB:0] u_unconnected_19;


// Instantiation of module rctl
rctl irctl(
  .clk(clk),
  .rst_a(rst_a),
  .en(en),
  .aux_addr(aux_addr),
  .actionhalt(actionhalt),
  .actionpt_swi_a(actionpt_swi_a),
  .actionpt_pc_brk_a(actionpt_pc_brk_a),
  .p2_ap_stall_a(p2_ap_stall_a),
  .aluflags_r(aluflags_r),
  .br_flags_a(br_flags_a),
  .cr_hostw(cr_hostw),
  .do_inst_step_r(do_inst_step_r),
  .h_pcwr(h_pcwr),
  .h_pcwr32(h_pcwr32),
  .h_regadr(h_regadr),
  .holdup2b(i_holdup2b),
  .ivalid_aligned(ivalid_aligned),
  .ivic(ivic),
  .ldvalid(ldvalid),
  .loop_kill_p1_a(loop_kill_p1_a),
  .loop_int_holdoff_a(loop_int_holdoff_a),
  .loopend_hit_a(loopend_hit_a),
  .sync_queue_idle(sync_queue_idle),
  .lpending(i_lpending),
  .debug_if_r(debug_if_r),
  .dmp_mload(dmp_mload),
  .dmp_mstore(dmp_mstore),
  .is_local_ram(is_local_ram),
  .mwait(mwait),
  .p1int(i_p1int),
  .p1iw_aligned_a(p1iw_aligned_a),
  .p2ilev1(i_p2ilev1),
  .p2int(i_p2int),
  .p2bint(i_p2bint),
  .p3int(i_p3int),
  .pcounter_jmp_restart_r(i_pcounter_jmp_restart_r),
  .regadr(i_regadr),
  .regadr_eq_src1(i_regadr_eq_src1),
  .regadr_eq_src2(i_regadr_eq_src2),
  .sleeping(sleeping),
  .sleeping_r2(sleeping_r2),
  .x_idecode2(i_x_idecode2),
  .x_idecode2b(i_x_idecode2b),
  .x_idecode3(i_x_idecode3),
  .x_idop_decode2(i_x_idop_decode2),
  .x_isop_decode2(i_x_isop_decode2),
  .x_multic_busy(i_x_multic_busy),
  .x_multic_wba(i_x_multic_wba),
  .x_multic_wben(i_x_multic_wben),
  .x_p1_rev_src(i_x_p1_rev_src),
  .x_p2_bfield_wb_a(i_x_p2_bfield_wb_a),
  .x_p2_jump_decode(i_x_p2_jump_decode),
  .x_p2b_jump_decode(i_x_p2b_jump_decode),
  .x_p2nosc1(i_x_p2nosc1),
  .x_p2nosc2(i_x_p2nosc2),
  .x_p2shimm_a(i_x_p2shimm_a),
  .x_snglec_wben(i_x_snglec_wben),
  .xholdup2(i_xholdup2),
  .xholdup2b(i_xholdup2b),
  .xholdup3(i_xholdup3),
  .xnwb(i_xnwb),
  .xp2bccmatch(i_xp2bccmatch),
  .xp2ccmatch(i_xp2ccmatch),
  .xp2idest(i_xp2idest),
  .xp3ccmatch(i_xp3ccmatch),
  .awake_a(i_awake_a),
  .en1(i_en1),
  .ifetch_aligned(ifetch_aligned),
  .inst_stepping(inst_stepping),
  .instr_pending_r(i_instr_pending_r),
  .pcen(i_pcen),
  .pcen_niv(i_pcen_niv),
  .brk_inst_a(brk_inst_a),
  .dest(i_dest),
  .desten(i_desten),
  .en2(i_en2),
  .fs2a(i_fs2a),
  .p2_a_field_r(i_p2_a_field_r),
  .p2_abs_neg_a(i_p2_abs_neg_a),
  .p2_b_field_r(i_p2_b_field_r),
  .p2_brcc_instr_a(i_p2_brcc_instr_a),
  .p2_c_field_r(i_p2_c_field_r),
  .p2_dopred(i_p2_dopred),
  .p2_dopred_ds(u_unconnected_0),
  .p2_dopred_nds(i_p2_dopred_nds),
  .p2_dorel(i_p2_dorel),
  .p2_iw_r(i_p2_iw_r),
  .p2_jblcc_a(i_p2_jblcc_a),
  .p2_lp_instr(p2_lp_instr),
  .p2_not_a(i_p2_not_a),
  .p2_s1a(i_p2_s1a),
  .p2_s1en(i_p2_s1en),
  .p2_s2a(p2_s2a),
  .p2_shimm_data(u_unconnected_1),
  .p2_shimm_s1_a(u_unconnected_2),
  .p2_shimm_s2_a(u_unconnected_3),
  .p2bch(i_p2bch),
  .p2cc(i_p2cc),
  .p2conditional(i_p2conditional),
  .p2condtrue(p2condtrue),
  .p2delay_slot(i_p2delay_slot),
  .p2format(i_p2format),
  .p2iv(i_p2iv),
  .p2limm(i_p2limm),
  .p2lr(i_p2lr),
  .p2minoropcode(i_p2minoropcode),
  .p2offset(i_p2offset),
  .p2opcode(i_p2opcode),
  .p2setflags(i_p2setflags),
  .p2sleep_inst(i_p2sleep_inst),
  .p2st(i_p2st),
  .p2subopcode(i_p2subopcode),
  .p2subopcode1_r(i_p2subopcode1_r),
  .p2subopcode2_r(i_p2subopcode2_r),
  .p2subopcode3_r(i_p2subopcode3_r),
  .p2subopcode4_r(i_p2subopcode4_r),
  .p2subopcode5_r(i_p2subopcode5_r),
  .p2subopcode6_r(i_p2subopcode6_r),
  .p2subopcode7_r(i_p2subopcode7_r),
  .s1a(i_s1a),
  .s1en(i_s1en),
  .s2en(i_s2en),
  .en2b(i_en2b),
  .mload2b(i_mload2b),
  .mstore2b(i_mstore2b),
  .p2b_a_field_r(i_p2b_a_field_r),
  .p2b_abs_op(p2b_abs_op),
  .p2b_alu_op(p2b_alu_op),
  .p2b_arithiv(p2b_arithiv),
  .p2b_awb_field(u_unconnected_4),
  .p2b_b_field_r(i_p2b_b_field_r),
  .p2b_bch(i_p2b_bch),
  .p2b_blcc_a(p2b_blcc_a),
  .p2b_c_field_r(i_p2b_c_field_r),
  .p2b_cc(i_p2b_cc),
  .p2b_conditional(i_p2b_conditional),
  .p2b_condtrue(p2b_condtrue),
  .p2b_delay_slot(p2b_delay_slot),
  .p2b_dojcc(i_p2b_dojcc),
  .p2b_dopred_ds(i_p2b_dopred_ds),
  .p2b_format(i_p2b_format),
  .p2b_iv(i_p2b_iv),
  .p2b_jlcc_a(p2b_jlcc_a),
  .p2b_limm(p2b_limm),
  .p2b_lr(p2b_lr),
  .p2b_minoropcode(i_p2b_minoropcode),
  .p2b_neg_op(p2b_neg_op),
  .p2b_not_op(p2b_not_op),
  .p2b_opcode(i_p2b_opcode),
  .p2b_setflags(i_p2b_setflags),
  .p2b_shift_by_one_a(p2b_shift_by_one_a),
  .p2b_shift_by_three_a(p2b_shift_by_three_a),
  .p2b_shift_by_two_a(p2b_shift_by_two_a),
  .p2b_shift_by_zero_a(p2b_shift_by_zero_a),
  .p2b_shimm_data(i_p2b_shimm_data),
  .p2b_shimm_s1_a(p2b_shimm_s1_a),
  .p2b_shimm_s2_a(i_p2b_shimm_s2_a),
  .p2b_size(u_unconnected_5),
  .p2b_st(i_p2b_st),
  .p2b_subopcode(i_p2b_subopcode),
  .p2b_subopcode1_r(i_p2b_subopcode1_r),
  .p2b_subopcode2_r(i_p2b_subopcode2_r),
  .p2b_subopcode3_r(i_p2b_subopcode3_r),
  .p2b_subopcode4_r(i_p2b_subopcode4_r),
  .p2b_subopcode5_r(i_p2b_subopcode5_r),
  .p2b_subopcode6_r(i_p2b_subopcode6_r),
  .p2b_subopcode7_r(i_p2b_subopcode7_r),
  .p2b_jmp_holdup_a(p2b_jmp_holdup_a),
  .en3(i_en3),
  .en3_niv_a(en3_niv_a),
  .ldvalid_wb(ldvalid_wb),
  .mload(i_mload),
  .mstore(mstore),
  .nocache(i_nocache),
  .p3_alu_absiv(p3_alu_absiv),
  .p3_alu_arithiv(p3_alu_arithiv),
  .p3_alu_logiciv(p3_alu_logiciv),
  .p3_alu_op(p3_alu_op),
  .p3_alu_snglopiv(p3_alu_snglopiv),
  .p3_bit_op_sel(p3_bit_op_sel),
  .p3_brcc_instr_a(p3_brcc_instr_a),
  .p3_docmprel_a(p3_docmprel_a),
  .p3_flag_instr(p3_flag_instr),
  .p3_sync_instr(p3_sync_instr),
  .p3_max_instr(p3_max_instr),
  .p3_min_instr(p3_min_instr),
  .p3_ni_wbrq(u_unconnected_6),
  .p3_shiftin_sel_r(p3_shiftin_sel_r),
  .p3_sop_op_r(p3_sop_op_r),
  .p3_xmultic_nwb(i_p3_xmultic_nwb),
  .p3a_field_r(i_p3a_field_r),
  .p3awb_field_r(p3awb_field_r),
  .p3b_field_r(i_p3b_field_r),
  .p3c_field_r(i_p3c_field_r),
  .p3cc(i_p3cc),
  .p3condtrue(i_p3condtrue),
  .p3destlimm(i_p3destlimm),
  .p3dolink(p3dolink),
  .p3format(i_p3format),
  .p3iv(i_p3iv),
  .p3lr(i_p3lr),
  .p3minoropcode(i_p3minoropcode),
  .p3opcode(i_p3opcode),
  .p3q(u_unconnected_7),
  .p3setflags(i_p3setflags),
  .p3sr(i_p3sr),
  .p3subopcode(i_p3subopcode),
  .p3subopcode1_r(i_p3subopcode1_r),
  .p3subopcode2_r(i_p3subopcode2_r),
  .p3subopcode3_r(i_p3subopcode3_r),
  .p3subopcode4_r(p3subopcode4_r),
  .p3subopcode5_r(p3subopcode5_r),
  .p3subopcode6_r(p3subopcode6_r),
  .p3subopcode7_r(p3subopcode7_r),
  .p3wb_en(i_p3wb_en),
  .p3wb_en_nld(u_unconnected_8),
  .p3wba(i_p3wba),
  .p3wba_nld(u_unconnected_9),
  .sc_load1(sc_load1),
  .sc_load2(sc_load2),
  .sc_reg1(i_sc_reg1),
  .sc_reg2(i_sc_reg2),
  .sex(sex),
  .size(size),
  .wben_nxt(u_unconnected_10),
  .wba(wba),
  .wben(wben),
  .p4_docmprel(i_p4_docmprel),
  .loopcount_hit_a(loopcount_hit_a),
  .p4_disable_r(i_p4_disable_r),
  .p4iv(u_unconnected_11),
  .flagu_block(i_flagu_block),
  .instruction_error(i_instruction_error),
  .interrupt_holdoff(i_interrupt_holdoff),
  .kill_last(i_kill_last),
  .kill_p1_a(i_kill_p1_a),
  .kill_p1_en_a(u_unconnected_12),
  .kill_p1_nlp_a(kill_p1_nlp_a),
  .kill_p1_nlp_en_a(u_unconnected_13),
  .kill_p2_a(i_kill_p2_a),
  .kill_p2_en_a(u_unconnected_14),
  .kill_p2b_a(i_kill_p2b_a),
  .kill_p3_a(i_kill_p3_a),
  .kill_tagged_p1(kill_tagged_p1),
  .stop_step(stop_step),
  .hold_int_st2_a(i_hold_int_st2_a)
);


// Instantiation of module xrctl
xrctl ixrctl(
  .clk(clk),
  .rst_a(rst_a),
  .en(en),
  .s1en(i_s1en),
  .s2en(i_s2en),
  .code_stall_ldst(code_stall_ldst),
  .mulatwork_r(mulatwork_r),
  .ivalid_aligned(ivalid_aligned),
  .en2(i_en2),
  .p2_a_field_r(i_p2_a_field_r),
  .p2_b_field_r(i_p2_b_field_r),
  .p2_c_field_r(i_p2_c_field_r),
  .p2bch(i_p2bch),
  .p2cc(i_p2cc),
  .p2conditional(i_p2conditional),
  .p2format(i_p2format),
  .p2iv(i_p2iv),
  .p2minoropcode(i_p2minoropcode),
  .p2opcode(i_p2opcode),
  .p2sleep_inst(i_p2sleep_inst),
  .p2setflags(i_p2setflags),
  .p2st(i_p2st),
  .p2subopcode(i_p2subopcode),
  .p2subopcode1_r(i_p2subopcode1_r),
  .p2subopcode2_r(i_p2subopcode2_r),
  .p2subopcode3_r(i_p2subopcode3_r),
  .p2subopcode4_r(i_p2subopcode4_r),
  .p2subopcode5_r(i_p2subopcode5_r),
  .p2subopcode6_r(i_p2subopcode6_r),
  .p2subopcode7_r(i_p2subopcode7_r),
  .en2b(i_en2b),
  .mload2b(i_mload2b),
  .mstore2b(i_mstore2b),
  .p2bint(i_p2bint),
  .p2b_a_field_r(i_p2b_a_field_r),
  .p2b_b_field_r(i_p2b_b_field_r),
  .p2b_c_field_r(i_p2b_c_field_r),
  .p2b_bch(i_p2b_bch),
  .p2b_cc(i_p2b_cc),
  .p2b_conditional(i_p2b_conditional),
  .p2b_format(i_p2b_format),
  .p2b_iv(i_p2b_iv),
  .p2b_minoropcode(i_p2b_minoropcode),
  .p2b_opcode(i_p2b_opcode),
  .p2b_setflags(i_p2b_setflags),
  .p2b_st(i_p2b_st),
  .p2b_subopcode(i_p2b_subopcode),
  .p2b_subopcode1_r(i_p2b_subopcode1_r),
  .p2b_subopcode2_r(i_p2b_subopcode2_r),
  .p2b_subopcode3_r(i_p2b_subopcode3_r),
  .p2b_subopcode4_r(i_p2b_subopcode4_r),
  .p2b_subopcode5_r(i_p2b_subopcode5_r),
  .p2b_subopcode6_r(i_p2b_subopcode6_r),
  .p2b_subopcode7_r(i_p2b_subopcode7_r),
  .dmp_holdup12(dmp_holdup12),
  .fs2a(i_fs2a),
  .s1a(i_s1a),
  .s1bus(s1bus),
  .s2bus(s2bus),
  .sc_reg1(i_sc_reg1),
  .sc_reg2(i_sc_reg2),
  .ext_s2val(ext_s2val),
  .s2val(s2val),
  .p3a_field_r(i_p3a_field_r),
  .p3b_field_r(i_p3b_field_r),
  .p3c_field_r(i_p3c_field_r),
  .p3condtrue(i_p3condtrue),
  .p3format(i_p3format),
  .p3iv(i_p3iv),
  .p3destlimm(i_p3destlimm),
  .p3minoropcode(i_p3minoropcode),
  .p3opcode(i_p3opcode),
  .p3setflags(i_p3setflags),
  .p3subopcode(i_p3subopcode),
  .p3subopcode1_r(i_p3subopcode1_r),
  .p3subopcode2_r(i_p3subopcode2_r),
  .p3subopcode3_r(i_p3subopcode3_r),
  .p3wb_en(i_p3wb_en),
  .p3wba(i_p3wba),
  .en3(i_en3),
  .p3cc(i_p3cc),
  .dest(i_dest),
  .desten(i_desten),
  .aluflags_r(aluflags_r),
  .p3lr(i_p3lr),
  .p3sr(i_p3sr),
  .aux_addr(aux_addr),
  .kill_p1_a(i_kill_p1_a),
  .kill_p2_a(i_kill_p2_a),
  .kill_p2b_a(i_kill_p2b_a),
  .kill_p3_a(i_kill_p3_a),
  .p3_xmultic_nwb(i_p3_xmultic_nwb),
  .ux_p2nosc1(ux_p2nosc1),
  .ux_p2nosc2(ux_p2nosc2),
  .uxp2ccmatch(uxp2ccmatch),
  .uxp2bccmatch(uxp2bccmatch),
  .uxp3ccmatch(uxp3ccmatch),
  .uxholdup2(uxholdup2),
  .uxholdup2b(uxholdup2b),
  .uxholdup3(uxholdup3),
  .uxnwb(uxnwb),
  .uxp2idest(uxp2idest),
  .uxsetflags(uxsetflags),
  .ux_isop_decode2(ux_isop_decode2),
  .ux_idop_decode2(ux_idop_decode2),
  .ux_izop_decode2(ux_izop_decode2),
  .ux_flgen(ux_flgen),
  .ux_p1_rev_src(ux_p1_rev_src),
  .ux_multic_wba(ux_multic_wba),
  .ux_multic_wben(ux_multic_wben),
  .ux_multic_busy(ux_multic_busy),
  .ux_p2_bfield_wb_a(ux_p2_bfield_wb_a),
  .ux_p2_jump_decode(ux_p2_jump_decode),
  .ux_snglec_wben(ux_snglec_wben),
  .barrel_type_r(barrel_type_r),
  .x_p3_brl_decode_16_r(x_p3_brl_decode_16_r),
  .x_p3_brl_decode_32_r(x_p3_brl_decode_32_r),
  .x_p3_norm_decode_r(x_p3_norm_decode_r),
  .x_p3_snorm_decode_r(x_p3_snorm_decode_r),
  .x_p3_swap_decode_r(x_p3_swap_decode_r),
  .p2dop32_inst(p2dop32_inst),
  .p2sop32_inst(p2sop32_inst),
  .p2zop32_inst(p2zop32_inst),
  .p2dop16_inst(p2dop16_inst),
  .p2sop16_inst(p2sop16_inst),
  .p2zop16_inst(p2zop16_inst),
  .p2b_dop32_inst(p2b_dop32_inst),
  .p2b_sop32_inst(p2b_sop32_inst),
  .p2b_zop32_inst(p2b_zop32_inst),
  .p2b_dop16_inst(p2b_dop16_inst),
  .p2b_sop16_inst(p2b_sop16_inst),
  .p2b_zop16_inst(p2b_zop16_inst),
  .p3dop32_inst(p3dop32_inst),
  .p3sop32_inst(p3sop32_inst),
  .p3zop32_inst(p3zop32_inst),
  .p3dop16_inst(p3dop16_inst),
  .p3sop16_inst(p3sop16_inst),
  .p3zop16_inst(p3zop16_inst),
  .x_p1_rev_src(i_x_p1_rev_src),
  .xholdup2(i_xholdup2),
  .xholdup2b(i_xholdup2b),
  .xp2idest(i_xp2idest),
  .x_flgen(x_flgen),
  .x_idecode2(i_x_idecode2),
  .x_idecode2b(i_x_idecode2b),
  .x_isop_decode2(i_x_isop_decode2),
  .x_idop_decode2(i_x_idop_decode2),
  .x_izop_decode2(u_unconnected_15),
  .x_multic_wba(i_x_multic_wba),
  .x_multic_wben(i_x_multic_wben),
  .x_multic_busy(i_x_multic_busy),
  .x_p2_bfield_wb_a(i_x_p2_bfield_wb_a),
  .xp2ccmatch(i_xp2ccmatch),
  .xp2bccmatch(i_xp2bccmatch),
  .x_p2nosc1(i_x_p2nosc1),
  .x_p2nosc2(i_x_p2nosc2),
  .x_p2shimm_a(i_x_p2shimm_a),
  .x_p2_jump_decode(i_x_p2_jump_decode),
  .x_p2b_jump_decode(i_x_p2b_jump_decode),
  .x_snglec_wben(i_x_snglec_wben),
  .xsetflags(xsetflags),
  .xp3ccmatch(i_xp3ccmatch),
  .xholdup3(i_xholdup3),
  .x_idecode3(i_x_idecode3),
  .x_set_sflag(x_set_sflag),
  .xnwb(i_xnwb)
);


// Instantiation of module int_unit
int_unit iint_unit(
  .clk_ungated(clk_ungated),
  .rst_a(rst_a),
  .irq(irq),
  .instruction_error(i_instruction_error),
  .int_vector_base_r(int_vector_base_r),
  .memory_error(memory_error),
  .misaligned_int(misaligned_int),
  .en1(i_en1),
  .en2(i_en2),
  .en2b(i_en2b),
  .en3(i_en3),
  .interrupt_holdoff(i_interrupt_holdoff),
  .flagu_block(i_flagu_block),
  .e1flag_r(e1flag_r),
  .e2flag_r(e2flag_r),
  .aux_access(aux_access),
  .aux_addr(aux_addr),
  .aux_dataw(aux_dataw),
  .aux_write(aux_write),
  .h_write(h_write),
  .h_addr(h_addr),
  .h_dataw(h_dataw),
  .hold_int_st2_a(i_hold_int_st2_a),
  .int_vec(i_int_vec),
  .p1int(i_p1int),
  .p2int(i_p2int),
  .p2bint(i_p2bint),
  .p2ilev1(i_p2ilev1),
  .p2bilev1(u_unconnected_16),
  .p3int(i_p3int),
  .p3ilev1(p3ilev1),
  .p123int(i_p123int),
  .aux_lv12(aux_lv12),
  .aux_hint(aux_hint),
  .aux_lev(aux_lev)
);


// Instantiation of module lsu
lsu ilsu(
  .clk(clk),
  .rst_a(rst_a),
  .ldvalid(ldvalid),
  .q_ldvalid(q_ldvalid),
  .loc_ldvalid(loc_ldvalid),
  .is_local_ram(is_local_ram),
  .is_peripheral(is_peripheral),
  .s1a(i_s1a),
  .fs2a(i_fs2a),
  .dest(i_dest),
  .mload2b(i_mload2b),
  .s1en(i_s1en),
  .s2en(i_s2en),
  .desten(i_desten),
  .en2b(i_en2b),
  .kill_last(i_kill_last),
  .en3(i_en3),
  .mload(i_mload),
  .nocache(i_nocache),
  .dc_disable_r(dc_disable_r),
  .regadr(i_regadr),
  .regadr_eq_src1(i_regadr_eq_src1),
  .regadr_eq_src2(i_regadr_eq_src2),
  .holdup2b(i_holdup2b),
  .max_one_lpend(max_one_lpend),
  .lpending(i_lpending)
);


// Instantiation of module ck_ctrl
ck_ctrl ick_ctrl(
  .clk_ungated(clk_ungated),
  .rst_a(rst_a),
  .test_mode(test_mode),
  .ctrl_cpu_start_sync_r(ctrl_cpu_start_sync_r),
  .do_inst_step_r(do_inst_step_r),
  .sleeping_r2(sleeping_r2),
  .en(en),
  .q_busy(q_busy),
  .p123int(i_p123int),
  .host_rw(host_rw),
  .p4_disable_r(i_p4_disable_r),
  .mem_access(mem_access),
  .lpending(i_lpending),
  .instr_pending_r(i_instr_pending_r),
  .ic_busy(ic_busy),
  .wd_clear(wd_clear),
  .mload2b(i_mload2b),
  .mstore2b(i_mstore2b),
  .dmp_mload(dmp_mload),
  .dmp_mstore(dmp_mstore),
  .is_local_ram(is_local_ram),
  .debug_if_r(debug_if_r),
  .cgm_queue_idle(cgm_queue_idle),
  .ibus_busy(ibus_busy),
  .pcp_rd_rq(pcp_rd_rq),
  .pcp_wr_rq(pcp_wr_rq),
  .ctrl_cpu_start_r(ctrl_cpu_start_r),
  .ck_disable(ck_disable),
  .ck_gated(ck_gated),
  .ck_dmp_gated(ck_dmp_gated)
);


// Instantiation of module pcounter
pcounter ipcounter(
  .clk(clk),
  .rst_a(rst_a),
  .aligner_do_pc_plus_8(aligner_do_pc_plus_8),
  .aligner_pc_enable(aligner_pc_enable),
  .awake_a(i_awake_a),
  .en2(i_en2),
  .en2b(i_en2b),
  .en3(i_en3),
  .h_dataw(h_dataw),
  .h_pcwr(h_pcwr),
  .h_pcwr32(h_pcwr32),
  .int_vec(i_int_vec),
  .ivalid(ivalid),
  .ivalid_aligned(ivalid_aligned),
  .loopstart_r(loopstart_r),
  .p1inst_16(p1inst_16),
  .p2_jblcc_a(i_p2_jblcc_a),
  .p2_abs_neg_a(i_p2_abs_neg_a),
  .p2_brcc_instr_a(i_p2_brcc_instr_a),
  .p2_dorel(i_p2_dorel),
  .p2_iw_r(i_p2_iw_r),
  .p2_not_a(i_p2_not_a),
  .p2_s1a(i_p2_s1a),
  .p2_s1en(i_p2_s1en),
  .p2b_dojcc(i_p2b_dojcc),
  .p2b_shimm_data(i_p2b_shimm_data),
  .p2b_shimm_s2_a(i_p2b_shimm_s2_a),
  .p2delay_slot(i_p2delay_slot),
  .p2int(i_p2int),
  .p2limm(i_p2limm),
  .p2lr(i_p2lr),
  .p2offset(i_p2offset),
  .p4_docmprel(i_p4_docmprel),
  .pcen(i_pcen),
  .pcen_niv(i_pcen_niv),
  .fs2a(i_fs2a),
  .p2_dopred(i_p2_dopred),
  .p2_dopred_nds(i_p2_dopred_nds),
  .p2b_dopred_ds(i_p2b_dopred_ds),
  .do_loop_a(do_loop_a),
  .qd_b(qd_b),
  .x2data_2_pc(x2data_2_pc),
  .step(step),
  .inst_step(inst_step),
  .currentpc_nxt(u_unconnected_17),
  .currentpc_r(currentpc_r),
  .misaligned_target(misaligned_target),
  .pc_is_linear_r(pc_is_linear_r),
  .next_pc(next_pc),
  .running_pc(u_unconnected_18),
  .last_pc_plus_len(last_pc_plus_len),
  .p2_pc_r(u_unconnected_19),
  .p2b_pc_r(p2b_pc_r),
  .p2_target(p2_target),
  .p2_s1val_tmp_r(p2_s1val_tmp_r),
  .pcounter_jmp_restart_r(i_pcounter_jmp_restart_r),
  .pcounter_jmp_restart_a(pcounter_jmp_restart_a)
);


// Output drives
assign s1en                    = i_s1en;
assign s2en                    = i_s2en;
assign en2                     = i_en2;
assign mload2b                 = i_mload2b;
assign mstore2b                = i_mstore2b;
assign p2opcode                = i_p2opcode;
assign p2subopcode             = i_p2subopcode;
assign p2subopcode2_r          = i_p2subopcode2_r;
assign p2_a_field_r            = i_p2_a_field_r;
assign p2_b_field_r            = i_p2_b_field_r;
assign p2_c_field_r            = i_p2_c_field_r;
assign p2iv                    = i_p2iv;
assign p2cc                    = i_p2cc;
assign p2conditional           = i_p2conditional;
assign p2sleep_inst            = i_p2sleep_inst;
assign p2setflags              = i_p2setflags;
assign p2st                    = i_p2st;
assign p2format                = i_p2format;
assign p2bch                   = i_p2bch;
assign en2b                    = i_en2b;
assign p2b_iv                  = i_p2b_iv;
assign p2b_conditional         = i_p2b_conditional;
assign p2b_cc                  = i_p2b_cc;
assign p2b_opcode              = i_p2b_opcode;
assign p2b_subopcode           = i_p2b_subopcode;
assign p2b_a_field_r           = i_p2b_a_field_r;
assign p2b_b_field_r           = i_p2b_b_field_r;
assign p2b_c_field_r           = i_p2b_c_field_r;
assign en3                     = i_en3;
assign p3iv                    = i_p3iv;
assign p3opcode                = i_p3opcode;
assign p3subopcode             = i_p3subopcode;
assign p3subopcode2_r          = i_p3subopcode2_r;
assign p3a_field_r             = i_p3a_field_r;
assign p3b_field_r             = i_p3b_field_r;
assign p3c_field_r             = i_p3c_field_r;
assign p3cc                    = i_p3cc;
assign p3condtrue              = i_p3condtrue;
assign p3destlimm              = i_p3destlimm;
assign p3format                = i_p3format;
assign p3setflags              = i_p3setflags;
assign x_idecode3              = i_x_idecode3;
assign p3wb_en                 = i_p3wb_en;
assign p3wba                   = i_p3wba;
assign p3lr                    = i_p3lr;
assign p3sr                    = i_p3sr;
assign s1a                     = i_s1a;
assign fs2a                    = i_fs2a;
assign dest                    = i_dest;
assign desten                  = i_desten;
assign sc_reg1                 = i_sc_reg1;
assign sc_reg2                 = i_sc_reg2;
assign p3_xmultic_nwb          = i_p3_xmultic_nwb;
assign lpending                = i_lpending;
assign p1int                   = i_p1int;
assign p2int                   = i_p2int;
assign p2bint                  = i_p2bint;
assign p3int                   = i_p3int;
assign pcounter_jmp_restart_r  = i_pcounter_jmp_restart_r;
assign regadr                  = i_regadr;
assign x_idecode2b             = i_x_idecode2b;
assign x_multic_busy           = i_x_multic_busy;
assign x_multic_wben           = i_x_multic_wben;
assign x_snglec_wben           = i_x_snglec_wben;
assign en1                     = i_en1;
assign instr_pending_r         = i_instr_pending_r;
assign pcen                    = i_pcen;
assign pcen_niv                = i_pcen_niv;
assign p2_brcc_instr_a         = i_p2_brcc_instr_a;
assign p2_dopred               = i_p2_dopred;
assign p2_dorel                = i_p2_dorel;
assign p2_iw_r                 = i_p2_iw_r;
assign p2_s1a                  = i_p2_s1a;
assign p2limm                  = i_p2limm;
assign p2minoropcode           = i_p2minoropcode;
assign p2subopcode3_r          = i_p2subopcode3_r;
assign p2subopcode4_r          = i_p2subopcode4_r;
assign p2subopcode5_r          = i_p2subopcode5_r;
assign p2subopcode6_r          = i_p2subopcode6_r;
assign p2subopcode7_r          = i_p2subopcode7_r;
assign p2b_dojcc               = i_p2b_dojcc;
assign p2b_setflags            = i_p2b_setflags;
assign p2b_shimm_data          = i_p2b_shimm_data;
assign p2b_shimm_s2_a          = i_p2b_shimm_s2_a;
assign mload                   = i_mload;
assign nocache                 = i_nocache;
assign p3minoropcode           = i_p3minoropcode;
assign p3subopcode3_r          = i_p3subopcode3_r;
assign p4_docmprel             = i_p4_docmprel;
assign p4_disable_r            = i_p4_disable_r;
assign kill_p2_a               = i_kill_p2_a;

endmodule


