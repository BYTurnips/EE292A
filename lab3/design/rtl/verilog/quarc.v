// *SYNOPSYS CONFIDENTIAL*
//
// This is an unpublished, proprietary work of Synopsys, Inc., and is fully 
// protected under copyright and trade secret laws.  You may not view, use, 
// disclose, copy, or distribute this file or any information contained herein 
// except pursuant to a valid written license from Synopsys.


// This file is generated automatically by 'veriloggen'.




module quarc(clk_ungated,
             code_ram_rdata,
             rst_a,
             ctrl_cpu_start_sync_r,
             l_irq_4,
             l_irq_5,
             l_irq_6,
             l_irq_7,
             l_irq_8,
             l_irq_9,
             l_irq_10,
             l_irq_11,
             l_irq_12,
             l_irq_13,
             l_irq_14,
             l_irq_15,
             l_irq_16,
             l_irq_17,
             l_irq_18,
             l_irq_19,
             test_mode,
             clk,
             clk_debug,
             ibus_busy,
             mem_access,
             memory_error,
             h_addr,
             h_dataw,
             h_write,
             h_read,
             aux_access,
             core_access,
             ldvalid,
             sync_queue_idle,
             debug_if_r,
             dmp_mload,
             dmp_mstore,
             is_local_ram,
             mwait,
             dmp_holdup12,
             misaligned_int,
             q_ldvalid,
             loc_ldvalid,
             is_peripheral,
             q_busy,
             cgm_queue_idle,
             pcp_rd_rq,
             pcp_wr_rq,
             drd,
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
             arc_start_a,
             debug_if_a,
             halt,
             xstep,
             misaligned_err,
             code_ram_addr,
             code_ram_wdata,
             code_ram_wr,
             code_ram_be,
             code_ram_ck_en,
             en,
             wd_clear,
             ck_disable,
             ck_dmp_gated,
             en_debug_r,
             en3,
             lpending,
             mload,
             mstore,
             nocache,
             sex,
             size,
             dc_disable_r,
             max_one_lpend,
             mc_addr,
             dwr,
             hold_host,
             code_drd,
             code_ldvalid_r,
             code_dmi_rdata,
             noaccess,
             en_misaligned,
             reset_applied_r,
             power_toggle,
             lram_base,
             pc_sel_r,
             h_datar);


// Includes found automatically in dependent files.
`include "arcutil_pkg_defines.v"
`include "arcutil.v"
`include "asmutil.v"
`include "extutil.v"
`include "che_util.v"
`include "xdefs.v"
`include "uxdefs.v"
`include "ext_msb.v"


input  clk_ungated;
input  [31:0]  code_ram_rdata;
input  rst_a;
input  ctrl_cpu_start_sync_r;
input  l_irq_4;
input  l_irq_5;
input  l_irq_6;
input  l_irq_7;
input  l_irq_8;
input  l_irq_9;
input  l_irq_10;
input  l_irq_11;
input  l_irq_12;
input  l_irq_13;
input  l_irq_14;
input  l_irq_15;
input  l_irq_16;
input  l_irq_17;
input  l_irq_18;
input  l_irq_19;
input  test_mode;
input  clk;
input  clk_debug;
input  ibus_busy;
input  mem_access;
input  memory_error;
input  [31:0]  h_addr;
input  [31:0]  h_dataw;
input  h_write;
input  h_read;
input  aux_access;
input  core_access;
input  ldvalid;
input  sync_queue_idle;
input  debug_if_r;
input  dmp_mload;
input  dmp_mstore;
input  is_local_ram;
input  mwait;
input  dmp_holdup12;
input  misaligned_int;
input  q_ldvalid;
input  loc_ldvalid;
input  is_peripheral;
input  q_busy;
input  cgm_queue_idle;
input  pcp_rd_rq;
input  pcp_wr_rq;
input  [31:0]  drd;
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
input  arc_start_a;
input  debug_if_a;
input  halt;
input  xstep;
input  misaligned_err;
output [CODE_RAM_ADDR_MSB-CODE_RAM_ADDR_LSB:0]  code_ram_addr;
output [31:0]  code_ram_wdata;
output code_ram_wr;
output [3:0]  code_ram_be;
output code_ram_ck_en;
output en;
output wd_clear;
output ck_disable;
output ck_dmp_gated;
output en_debug_r;
output en3;
output lpending;
output mload;
output mstore;
output nocache;
output sex;
output [1:0]  size;
output dc_disable_r;
output max_one_lpend;
output [31:0]  mc_addr;
output [31:0]  dwr;
output hold_host;
output [31:0]  code_drd;
output code_ldvalid_r;
output [31:0]  code_dmi_rdata;
output noaccess;
output en_misaligned;
output reset_applied_r;
output power_toggle;
output [EXT_A_MSB:LDST_A_MSB+3]  lram_base;
output pc_sel_r;
output [31:0]  h_datar;

wire clk_ungated;
wire  [31:0] code_ram_rdata;
wire rst_a;
wire ctrl_cpu_start_sync_r;
wire l_irq_4;
wire l_irq_5;
wire l_irq_6;
wire l_irq_7;
wire l_irq_8;
wire l_irq_9;
wire l_irq_10;
wire l_irq_11;
wire l_irq_12;
wire l_irq_13;
wire l_irq_14;
wire l_irq_15;
wire l_irq_16;
wire l_irq_17;
wire l_irq_18;
wire l_irq_19;
wire test_mode;
wire clk;
wire clk_debug;
wire ibus_busy;
wire mem_access;
wire memory_error;
wire  [31:0] h_addr;
wire  [31:0] h_dataw;
wire h_write;
wire h_read;
wire aux_access;
wire core_access;
wire ldvalid;
wire sync_queue_idle;
wire debug_if_r;
wire dmp_mload;
wire dmp_mstore;
wire is_local_ram;
wire mwait;
wire dmp_holdup12;
wire misaligned_int;
wire q_ldvalid;
wire loc_ldvalid;
wire is_peripheral;
wire q_busy;
wire cgm_queue_idle;
wire pcp_rd_rq;
wire pcp_wr_rq;
wire  [31:0] drd;
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
wire arc_start_a;
wire debug_if_a;
wire halt;
wire xstep;
wire misaligned_err;
wire  [CODE_RAM_ADDR_MSB-CODE_RAM_ADDR_LSB:0] code_ram_addr;
wire  [31:0] code_ram_wdata;
wire code_ram_wr;
wire  [3:0] code_ram_be;
wire code_ram_ck_en;
wire en;
wire wd_clear;
wire ck_disable;
wire ck_dmp_gated;
wire en_debug_r;
wire en3;
wire lpending;
wire mload;
wire mstore;
wire nocache;
wire sex;
wire  [1:0] size;
wire dc_disable_r;
wire max_one_lpend;
wire  [31:0] mc_addr;
wire  [31:0] dwr;
wire hold_host;
wire  [31:0] code_drd;
wire code_ldvalid_r;
wire  [31:0] code_dmi_rdata;
wire noaccess;
wire en_misaligned;
wire reset_applied_r;
wire power_toggle;
wire  [EXT_A_MSB:LDST_A_MSB+3] lram_base;
wire pc_sel_r;
wire  [31:0] h_datar;


// Intermediate signals
wire i_en;
wire i_wd_clear;
wire i_ck_disable;
wire i_en_debug_r;
wire i_en3;
wire i_lpending;
wire i_mload;
wire i_mstore;
wire i_dc_disable_r;
wire  [31:0] i_mc_addr;
wire  [31:0] i_dwr;
wire i_hold_host;
wire i_s1en;
wire i_s2en;
wire  [31:0] i_s1bus;
wire  [31:0] i_s2bus;
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
wire i_p2dop32_inst;
wire i_p2sop32_inst;
wire i_p2zop32_inst;
wire i_p2dop16_inst;
wire i_p2sop16_inst;
wire i_p2zop16_inst;
wire i_en2b;
wire i_p2b_iv;
wire i_p2b_conditional;
wire  [3:0] i_p2b_cc;
wire i_p2b_dop32_inst;
wire i_p2b_sop32_inst;
wire i_p2b_zop32_inst;
wire i_p2b_dop16_inst;
wire i_p2b_sop16_inst;
wire i_p2b_zop16_inst;
wire  [4:0] i_p2b_opcode;
wire  [5:0] i_p2b_subopcode;
wire  [5:0] i_p2b_a_field_r;
wire  [5:0] i_p2b_b_field_r;
wire  [5:0] i_p2b_c_field_r;
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
wire i_p3dop32_inst;
wire i_p3sop32_inst;
wire i_p3zop32_inst;
wire i_p3dop16_inst;
wire i_p3sop16_inst;
wire i_p3zop16_inst;
wire  [3:0] i_aluflags_r;
wire  [31:0] i_ext_s1val;
wire  [31:0] i_ext_s2val;
wire  [31:0] i_aux_addr;
wire  [31:0] i_aux_dataw;
wire i_aux_write;
wire i_aux_read;
wire  [5:0] i_s1a;
wire  [5:0] i_s2a;
wire  [5:0] i_fs2a;
wire  [5:0] i_wba;
wire  [31:0] i_wbdata;
wire i_wben;
wire  [5:0] i_dest;
wire i_desten;
wire i_sc_reg1;
wire i_sc_reg2;
wire i_p3_xmultic_nwb;
wire  [31:0] i_ap_param0;
wire i_ap_param0_read;
wire i_ap_param0_write;
wire  [31:0] i_ap_param1;
wire i_ap_param1_read;
wire i_ap_param1_write;
wire  [31:0] i_uxdrx_reg;
wire i_uxreg_hit;
wire i_ux_da_am;
wire  [31:0] i_ux_dar;
wire i_uxivic;
wire i_uxhold_host;
wire i_uxnoaccess;
wire  [31:0] i_ux2data_2_pc;
wire  [31:0] i_ux1data;
wire  [31:0] i_ux2data;
wire i_ux_p2nosc1;
wire i_ux_p2nosc2;
wire i_uxp2bccmatch;
wire i_uxp2ccmatch;
wire i_uxp3ccmatch;
wire i_uxholdup2;
wire i_uxholdup2b;
wire i_uxholdup3;
wire i_ux_isop_decode2;
wire i_ux_idop_decode2;
wire i_ux_izop_decode2;
wire i_uxnwb;
wire i_uxp2idest;
wire i_uxsetflags;
wire i_ux_flgen;
wire  [5:0] i_ux_multic_wba;
wire i_ux_multic_wben;
wire i_ux_multic_busy;
wire i_ux_p1_rev_src;
wire i_ux_p2_bfield_wb_a;
wire i_ux_p2_jump_decode;
wire i_ux_snglec_wben;
wire  [31:0] i_uxresult;
wire  [3:0] i_uxflags;
wire i_actionhalt;
wire i_actionpt_swi_a;
wire i_actionpt_pc_brk_a;
wire i_p2_ap_stall_a;
wire  [3:0] i_br_flags_a;
wire i_cr_hostw;
wire i_do_inst_step_r;
wire i_h_pcwr;
wire i_h_pcwr32;
wire  [5:0] i_h_regadr;
wire i_ivalid_aligned;
wire i_ivic;
wire i_loop_kill_p1_a;
wire i_loop_int_holdoff_a;
wire i_loopend_hit_a;
wire  [DATAWORD_MSB:0] i_p1iw_aligned_a;
wire i_sleeping;
wire i_sleeping_r2;
wire i_code_stall_ldst;
wire i_mulatwork_r;
wire  [31:0] i_s2val;
wire  [31:3] i_irq;
wire  [PC_MSB:`INT_BASE_LSB] i_int_vector_base_r;
wire i_e1flag_r;
wire i_e2flag_r;
wire i_host_rw;
wire i_ic_busy;
wire i_aligner_do_pc_plus_8;
wire i_aligner_pc_enable;
wire i_ivalid;
wire  [PC_MSB:0] i_loopstart_r;
wire i_p1inst_16;
wire i_do_loop_a;
wire  [31:0] i_qd_b;
wire  [31:0] i_x2data_2_pc;
wire i_step;
wire i_inst_step;
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
wire i_ifetch_aligned;
wire i_inst_stepping;
wire i_instr_pending_r;
wire i_pcen;
wire i_pcen_niv;
wire i_brk_inst_a;
wire i_p2_brcc_instr_a;
wire i_p2_dopred;
wire i_p2_dorel;
wire  [INSTR_UBND:0] i_p2_iw_r;
wire i_p2_lp_instr;
wire  [5:0] i_p2_s1a;
wire  [5:0] i_p2_s2a;
wire i_p2condtrue;
wire i_p2limm;
wire  [5:0] i_p2minoropcode;
wire  [2:0] i_p2subopcode3_r;
wire i_p2subopcode4_r;
wire  [1:0] i_p2subopcode5_r;
wire  [2:0] i_p2subopcode6_r;
wire  [1:0] i_p2subopcode7_r;
wire i_p2b_abs_op;
wire  [1:0] i_p2b_alu_op;
wire i_p2b_arithiv;
wire i_p2b_blcc_a;
wire i_p2b_condtrue;
wire i_p2b_delay_slot;
wire i_p2b_dojcc;
wire i_p2b_jlcc_a;
wire i_p2b_limm;
wire i_p2b_lr;
wire i_p2b_neg_op;
wire i_p2b_not_op;
wire i_p2b_setflags;
wire i_p2b_shift_by_one_a;
wire i_p2b_shift_by_three_a;
wire i_p2b_shift_by_two_a;
wire i_p2b_shift_by_zero_a;
wire  [12:0] i_p2b_shimm_data;
wire i_p2b_shimm_s1_a;
wire i_p2b_shimm_s2_a;
wire i_p2b_jmp_holdup_a;
wire i_en3_niv_a;
wire i_ldvalid_wb;
wire i_p3_alu_absiv;
wire i_p3_alu_arithiv;
wire i_p3_alu_logiciv;
wire  [1:0] i_p3_alu_op;
wire i_p3_alu_snglopiv;
wire  [1:0] i_p3_bit_op_sel;
wire i_p3_brcc_instr_a;
wire i_p3_docmprel_a;
wire i_p3_flag_instr;
wire i_p3_sync_instr;
wire i_p3_max_instr;
wire i_p3_min_instr;
wire  [1:0] i_p3_shiftin_sel_r;
wire  [2:0] i_p3_sop_op_r;
wire  [1:0] i_p3awb_field_r;
wire i_p3dolink;
wire  [5:0] i_p3minoropcode;
wire  [2:0] i_p3subopcode3_r;
wire i_p3subopcode4_r;
wire  [1:0] i_p3subopcode5_r;
wire  [2:0] i_p3subopcode6_r;
wire  [1:0] i_p3subopcode7_r;
wire i_sc_load1;
wire i_sc_load2;
wire i_p4_docmprel;
wire i_loopcount_hit_a;
wire i_p4_disable_r;
wire i_kill_p1_nlp_a;
wire i_kill_p2_a;
wire i_kill_tagged_p1;
wire i_stop_step;
wire  [1:0] i_barrel_type_r;
wire i_x_p3_brl_decode_16_r;
wire i_x_p3_brl_decode_32_r;
wire i_x_p3_norm_decode_r;
wire i_x_p3_snorm_decode_r;
wire i_x_p3_swap_decode_r;
wire i_x_flgen;
wire i_xsetflags;
wire i_x_set_sflag;
wire i_p3ilev1;
wire  [1:0] i_aux_lv12;
wire  [4:0] i_aux_hint;
wire  [31:3] i_aux_lev;
wire i_ctrl_cpu_start_r;
wire i_ck_gated;
wire  [PC_MSB:0] i_currentpc_r;
wire i_misaligned_target;
wire i_pc_is_linear_r;
wire  [PC_MSB:0] i_next_pc;
wire  [PC_MSB:0] i_last_pc_plus_len;
wire  [PC_MSB:0] i_p2b_pc_r;
wire  [PC_MSB:0] i_p2_target;
wire  [DATAWORD_MSB:0] i_p2_s1val_tmp_r;
wire i_pcounter_jmp_restart_a;
wire  [31:0] i_aux_datar;
wire i_aux_pc32hit;
wire i_aux_pchit;
wire  [31:0] i_s1val;
wire i_s2val_inverted_r;
wire i_aux_st_mulhi_a;
wire  [3:0] i_alurflags;
wire  [31:0] i_p3res_sc;
wire  [31:0] i_p3result;
wire  [63:0] i_lmulres_r;
wire  [1:0] i_x_s_flag;
wire  [3:0] i_xflags;
wire i_cr_hostr;
wire i_h_status32;
wire  [31:0] i_h_rr_data;
wire  [PC_MSB:0] i_loopend_r;
wire i_sr_xhold_host_a;
wire  [31:0] i_p1iw;
wire i_actionpt_hit_a;
wire  [NUM_APS-1:0] i_actionpt_status_r;
wire  [31:0] i_ap_ahv0;
wire  [31:0] i_ap_ahv1;
wire  [31:0] i_ap_ahv2;
wire  [31:0] i_ap_ahv3;
wire  [31:0] i_ap_ahv4;
wire  [31:0] i_ap_ahv5;
wire  [31:0] i_ap_ahv6;
wire  [31:0] i_ap_ahv7;
wire  [31:0] i_ap_ahc0;
wire  [31:0] i_ap_ahc1;
wire  [31:0] i_ap_ahc2;
wire  [31:0] i_ap_ahc3;
wire  [31:0] i_ap_ahc4;
wire  [31:0] i_ap_ahc5;
wire  [31:0] i_ap_ahc6;
wire  [31:0] i_ap_ahc7;
wire  [31:0] i_ap_ahm0;
wire  [31:0] i_ap_ahm1;
wire  [31:0] i_ap_ahm2;
wire  [31:0] i_ap_ahm3;
wire  [31:0] i_ap_ahm4;
wire  [31:0] i_ap_ahm5;
wire  [31:0] i_ap_ahm6;
wire  [31:0] i_ap_ahm7;


// Dummy signals for 'unconnected' ports
// (doing this, rather than leaving them genuinely unconnected, stops
//  simulators emitting pointless warnings)


// Instantiation of module userextensions
userextensions iuserextensions(
  .en(i_en),
  .rst_a(rst_a),
  .clk(clk),
  .s1en(i_s1en),
  .s2en(i_s2en),
  .s1bus(i_s1bus),
  .s2bus(i_s2bus),
  .en2(i_en2),
  .mload2b(i_mload2b),
  .mstore2b(i_mstore2b),
  .p2opcode(i_p2opcode),
  .p2subopcode(i_p2subopcode),
  .p2subopcode2_r(i_p2subopcode2_r),
  .p2_a_field_r(i_p2_a_field_r),
  .p2_b_field_r(i_p2_b_field_r),
  .p2_c_field_r(i_p2_c_field_r),
  .p2iv(i_p2iv),
  .p2cc(i_p2cc),
  .p2conditional(i_p2conditional),
  .p2sleep_inst(i_p2sleep_inst),
  .p2setflags(i_p2setflags),
  .p2st(i_p2st),
  .p2format(i_p2format),
  .p2bch(i_p2bch),
  .p2dop32_inst(i_p2dop32_inst),
  .p2sop32_inst(i_p2sop32_inst),
  .p2zop32_inst(i_p2zop32_inst),
  .p2dop16_inst(i_p2dop16_inst),
  .p2sop16_inst(i_p2sop16_inst),
  .p2zop16_inst(i_p2zop16_inst),
  .en2b(i_en2b),
  .p2b_iv(i_p2b_iv),
  .p2b_conditional(i_p2b_conditional),
  .p2b_cc(i_p2b_cc),
  .p2b_dop32_inst(i_p2b_dop32_inst),
  .p2b_sop32_inst(i_p2b_sop32_inst),
  .p2b_zop32_inst(i_p2b_zop32_inst),
  .p2b_dop16_inst(i_p2b_dop16_inst),
  .p2b_sop16_inst(i_p2b_sop16_inst),
  .p2b_zop16_inst(i_p2b_zop16_inst),
  .p2b_opcode(i_p2b_opcode),
  .p2b_subopcode(i_p2b_subopcode),
  .p2b_a_field_r(i_p2b_a_field_r),
  .p2b_b_field_r(i_p2b_b_field_r),
  .p2b_c_field_r(i_p2b_c_field_r),
  .en3(i_en3),
  .p3iv(i_p3iv),
  .p3opcode(i_p3opcode),
  .p3subopcode(i_p3subopcode),
  .p3subopcode2_r(i_p3subopcode2_r),
  .p3a_field_r(i_p3a_field_r),
  .p3b_field_r(i_p3b_field_r),
  .p3c_field_r(i_p3c_field_r),
  .p3cc(i_p3cc),
  .p3condtrue(i_p3condtrue),
  .p3destlimm(i_p3destlimm),
  .p3format(i_p3format),
  .p3setflags(i_p3setflags),
  .x_idecode3(i_x_idecode3),
  .p3wb_en(i_p3wb_en),
  .p3wba(i_p3wba),
  .p3lr(i_p3lr),
  .p3sr(i_p3sr),
  .p3dop32_inst(i_p3dop32_inst),
  .p3sop32_inst(i_p3sop32_inst),
  .p3zop32_inst(i_p3zop32_inst),
  .p3dop16_inst(i_p3dop16_inst),
  .p3sop16_inst(i_p3sop16_inst),
  .p3zop16_inst(i_p3zop16_inst),
  .aluflags_r(i_aluflags_r),
  .ext_s1val(i_ext_s1val),
  .ext_s2val(i_ext_s2val),
  .aux_addr(i_aux_addr),
  .aux_dataw(i_aux_dataw),
  .aux_write(i_aux_write),
  .aux_read(i_aux_read),
  .h_addr(h_addr),
  .h_dataw(h_dataw),
  .h_write(h_write),
  .h_read(h_read),
  .aux_access(aux_access),
  .s1a(i_s1a),
  .s2a(i_s2a),
  .fs2a(i_fs2a),
  .wba(i_wba),
  .wbdata(i_wbdata),
  .wben(i_wben),
  .core_access(core_access),
  .dest(i_dest),
  .desten(i_desten),
  .sc_reg1(i_sc_reg1),
  .sc_reg2(i_sc_reg2),
  .p3_xmultic_nwb(i_p3_xmultic_nwb),
  .ap_param0(i_ap_param0),
  .ap_param0_read(i_ap_param0_read),
  .ap_param0_write(i_ap_param0_write),
  .ap_param1(i_ap_param1),
  .ap_param1_read(i_ap_param1_read),
  .ap_param1_write(i_ap_param1_write),
  .uxdrx_reg(i_uxdrx_reg),
  .uxreg_hit(i_uxreg_hit),
  .ux_da_am(i_ux_da_am),
  .ux_dar(i_ux_dar),
  .uxivic(i_uxivic),
  .uxhold_host(i_uxhold_host),
  .uxnoaccess(i_uxnoaccess),
  .ux2data_2_pc(i_ux2data_2_pc),
  .ux1data(i_ux1data),
  .ux2data(i_ux2data),
  .ux_p2nosc1(i_ux_p2nosc1),
  .ux_p2nosc2(i_ux_p2nosc2),
  .uxp2bccmatch(i_uxp2bccmatch),
  .uxp2ccmatch(i_uxp2ccmatch),
  .uxp3ccmatch(i_uxp3ccmatch),
  .uxholdup2(i_uxholdup2),
  .uxholdup2b(i_uxholdup2b),
  .uxholdup3(i_uxholdup3),
  .ux_isop_decode2(i_ux_isop_decode2),
  .ux_idop_decode2(i_ux_idop_decode2),
  .ux_izop_decode2(i_ux_izop_decode2),
  .uxnwb(i_uxnwb),
  .uxp2idest(i_uxp2idest),
  .uxsetflags(i_uxsetflags),
  .ux_flgen(i_ux_flgen),
  .ux_multic_wba(i_ux_multic_wba),
  .ux_multic_wben(i_ux_multic_wben),
  .ux_multic_busy(i_ux_multic_busy),
  .ux_p1_rev_src(i_ux_p1_rev_src),
  .ux_p2_bfield_wb_a(i_ux_p2_bfield_wb_a),
  .ux_p2_jump_decode(i_ux_p2_jump_decode),
  .ux_snglec_wben(i_ux_snglec_wben),
  .uxresult(i_uxresult),
  .uxflags(i_uxflags)
);


// Instantiation of module control
control icontrol(
  .clk_ungated(clk_ungated),
  .en(i_en),
  .rst_a(rst_a),
  .wd_clear(i_wd_clear),
  .ctrl_cpu_start_sync_r(ctrl_cpu_start_sync_r),
  .test_mode(test_mode),
  .clk(clk),
  .ibus_busy(ibus_busy),
  .mem_access(mem_access),
  .memory_error(memory_error),
  .s1bus(i_s1bus),
  .s2bus(i_s2bus),
  .aluflags_r(i_aluflags_r),
  .ext_s2val(i_ext_s2val),
  .aux_addr(i_aux_addr),
  .aux_dataw(i_aux_dataw),
  .aux_write(i_aux_write),
  .h_addr(h_addr),
  .h_dataw(h_dataw),
  .h_write(h_write),
  .aux_access(aux_access),
  .ux_p2nosc1(i_ux_p2nosc1),
  .ux_p2nosc2(i_ux_p2nosc2),
  .uxp2bccmatch(i_uxp2bccmatch),
  .uxp2ccmatch(i_uxp2ccmatch),
  .uxp3ccmatch(i_uxp3ccmatch),
  .uxholdup2(i_uxholdup2),
  .uxholdup2b(i_uxholdup2b),
  .uxholdup3(i_uxholdup3),
  .ux_isop_decode2(i_ux_isop_decode2),
  .ux_idop_decode2(i_ux_idop_decode2),
  .ux_izop_decode2(i_ux_izop_decode2),
  .uxnwb(i_uxnwb),
  .uxp2idest(i_uxp2idest),
  .uxsetflags(i_uxsetflags),
  .ux_flgen(i_ux_flgen),
  .ux_multic_wba(i_ux_multic_wba),
  .ux_multic_wben(i_ux_multic_wben),
  .ux_multic_busy(i_ux_multic_busy),
  .ux_p1_rev_src(i_ux_p1_rev_src),
  .ux_p2_bfield_wb_a(i_ux_p2_bfield_wb_a),
  .ux_p2_jump_decode(i_ux_p2_jump_decode),
  .ux_snglec_wben(i_ux_snglec_wben),
  .actionhalt(i_actionhalt),
  .actionpt_swi_a(i_actionpt_swi_a),
  .actionpt_pc_brk_a(i_actionpt_pc_brk_a),
  .p2_ap_stall_a(i_p2_ap_stall_a),
  .br_flags_a(i_br_flags_a),
  .cr_hostw(i_cr_hostw),
  .do_inst_step_r(i_do_inst_step_r),
  .h_pcwr(i_h_pcwr),
  .h_pcwr32(i_h_pcwr32),
  .h_regadr(i_h_regadr),
  .ivalid_aligned(i_ivalid_aligned),
  .ivic(i_ivic),
  .ldvalid(ldvalid),
  .loop_kill_p1_a(i_loop_kill_p1_a),
  .loop_int_holdoff_a(i_loop_int_holdoff_a),
  .loopend_hit_a(i_loopend_hit_a),
  .sync_queue_idle(sync_queue_idle),
  .debug_if_r(debug_if_r),
  .dmp_mload(dmp_mload),
  .dmp_mstore(dmp_mstore),
  .is_local_ram(is_local_ram),
  .mwait(mwait),
  .p1iw_aligned_a(i_p1iw_aligned_a),
  .sleeping(i_sleeping),
  .sleeping_r2(i_sleeping_r2),
  .code_stall_ldst(i_code_stall_ldst),
  .mulatwork_r(i_mulatwork_r),
  .dmp_holdup12(dmp_holdup12),
  .s2val(i_s2val),
  .irq(i_irq),
  .int_vector_base_r(i_int_vector_base_r),
  .misaligned_int(misaligned_int),
  .e1flag_r(i_e1flag_r),
  .e2flag_r(i_e2flag_r),
  .q_ldvalid(q_ldvalid),
  .loc_ldvalid(loc_ldvalid),
  .is_peripheral(is_peripheral),
  .dc_disable_r(i_dc_disable_r),
  .q_busy(q_busy),
  .host_rw(i_host_rw),
  .ic_busy(i_ic_busy),
  .cgm_queue_idle(cgm_queue_idle),
  .pcp_rd_rq(pcp_rd_rq),
  .pcp_wr_rq(pcp_wr_rq),
  .aligner_do_pc_plus_8(i_aligner_do_pc_plus_8),
  .aligner_pc_enable(i_aligner_pc_enable),
  .ivalid(i_ivalid),
  .loopstart_r(i_loopstart_r),
  .p1inst_16(i_p1inst_16),
  .do_loop_a(i_do_loop_a),
  .qd_b(i_qd_b),
  .x2data_2_pc(i_x2data_2_pc),
  .step(i_step),
  .inst_step(i_inst_step),
  .ck_disable(i_ck_disable),
  .ck_dmp_gated(ck_dmp_gated),
  .s1en(i_s1en),
  .s2en(i_s2en),
  .en2(i_en2),
  .mload2b(i_mload2b),
  .mstore2b(i_mstore2b),
  .p2opcode(i_p2opcode),
  .p2subopcode(i_p2subopcode),
  .p2subopcode2_r(i_p2subopcode2_r),
  .p2_a_field_r(i_p2_a_field_r),
  .p2_b_field_r(i_p2_b_field_r),
  .p2_c_field_r(i_p2_c_field_r),
  .p2iv(i_p2iv),
  .p2cc(i_p2cc),
  .p2conditional(i_p2conditional),
  .p2sleep_inst(i_p2sleep_inst),
  .p2setflags(i_p2setflags),
  .p2st(i_p2st),
  .p2format(i_p2format),
  .p2bch(i_p2bch),
  .p2dop32_inst(i_p2dop32_inst),
  .p2sop32_inst(i_p2sop32_inst),
  .p2zop32_inst(i_p2zop32_inst),
  .p2dop16_inst(i_p2dop16_inst),
  .p2sop16_inst(i_p2sop16_inst),
  .p2zop16_inst(i_p2zop16_inst),
  .en2b(i_en2b),
  .p2b_iv(i_p2b_iv),
  .p2b_conditional(i_p2b_conditional),
  .p2b_cc(i_p2b_cc),
  .p2b_dop32_inst(i_p2b_dop32_inst),
  .p2b_sop32_inst(i_p2b_sop32_inst),
  .p2b_zop32_inst(i_p2b_zop32_inst),
  .p2b_dop16_inst(i_p2b_dop16_inst),
  .p2b_sop16_inst(i_p2b_sop16_inst),
  .p2b_zop16_inst(i_p2b_zop16_inst),
  .p2b_opcode(i_p2b_opcode),
  .p2b_subopcode(i_p2b_subopcode),
  .p2b_a_field_r(i_p2b_a_field_r),
  .p2b_b_field_r(i_p2b_b_field_r),
  .p2b_c_field_r(i_p2b_c_field_r),
  .en3(i_en3),
  .p3iv(i_p3iv),
  .p3opcode(i_p3opcode),
  .p3subopcode(i_p3subopcode),
  .p3subopcode2_r(i_p3subopcode2_r),
  .p3a_field_r(i_p3a_field_r),
  .p3b_field_r(i_p3b_field_r),
  .p3c_field_r(i_p3c_field_r),
  .p3cc(i_p3cc),
  .p3condtrue(i_p3condtrue),
  .p3destlimm(i_p3destlimm),
  .p3format(i_p3format),
  .p3setflags(i_p3setflags),
  .x_idecode3(i_x_idecode3),
  .p3wb_en(i_p3wb_en),
  .p3wba(i_p3wba),
  .p3lr(i_p3lr),
  .p3sr(i_p3sr),
  .p3dop32_inst(i_p3dop32_inst),
  .p3sop32_inst(i_p3sop32_inst),
  .p3zop32_inst(i_p3zop32_inst),
  .p3dop16_inst(i_p3dop16_inst),
  .p3sop16_inst(i_p3sop16_inst),
  .p3zop16_inst(i_p3zop16_inst),
  .s1a(i_s1a),
  .fs2a(i_fs2a),
  .wba(i_wba),
  .wben(i_wben),
  .dest(i_dest),
  .desten(i_desten),
  .sc_reg1(i_sc_reg1),
  .sc_reg2(i_sc_reg2),
  .p3_xmultic_nwb(i_p3_xmultic_nwb),
  .lpending(i_lpending),
  .p1int(i_p1int),
  .p2int(i_p2int),
  .p2bint(i_p2bint),
  .p3int(i_p3int),
  .pcounter_jmp_restart_r(i_pcounter_jmp_restart_r),
  .regadr(i_regadr),
  .x_idecode2b(i_x_idecode2b),
  .x_multic_busy(i_x_multic_busy),
  .x_multic_wben(i_x_multic_wben),
  .x_snglec_wben(i_x_snglec_wben),
  .en1(i_en1),
  .ifetch_aligned(i_ifetch_aligned),
  .inst_stepping(i_inst_stepping),
  .instr_pending_r(i_instr_pending_r),
  .pcen(i_pcen),
  .pcen_niv(i_pcen_niv),
  .brk_inst_a(i_brk_inst_a),
  .p2_brcc_instr_a(i_p2_brcc_instr_a),
  .p2_dopred(i_p2_dopred),
  .p2_dorel(i_p2_dorel),
  .p2_iw_r(i_p2_iw_r),
  .p2_lp_instr(i_p2_lp_instr),
  .p2_s1a(i_p2_s1a),
  .p2_s2a(i_p2_s2a),
  .p2condtrue(i_p2condtrue),
  .p2limm(i_p2limm),
  .p2minoropcode(i_p2minoropcode),
  .p2subopcode3_r(i_p2subopcode3_r),
  .p2subopcode4_r(i_p2subopcode4_r),
  .p2subopcode5_r(i_p2subopcode5_r),
  .p2subopcode6_r(i_p2subopcode6_r),
  .p2subopcode7_r(i_p2subopcode7_r),
  .p2b_abs_op(i_p2b_abs_op),
  .p2b_alu_op(i_p2b_alu_op),
  .p2b_arithiv(i_p2b_arithiv),
  .p2b_blcc_a(i_p2b_blcc_a),
  .p2b_condtrue(i_p2b_condtrue),
  .p2b_delay_slot(i_p2b_delay_slot),
  .p2b_dojcc(i_p2b_dojcc),
  .p2b_jlcc_a(i_p2b_jlcc_a),
  .p2b_limm(i_p2b_limm),
  .p2b_lr(i_p2b_lr),
  .p2b_neg_op(i_p2b_neg_op),
  .p2b_not_op(i_p2b_not_op),
  .p2b_setflags(i_p2b_setflags),
  .p2b_shift_by_one_a(i_p2b_shift_by_one_a),
  .p2b_shift_by_three_a(i_p2b_shift_by_three_a),
  .p2b_shift_by_two_a(i_p2b_shift_by_two_a),
  .p2b_shift_by_zero_a(i_p2b_shift_by_zero_a),
  .p2b_shimm_data(i_p2b_shimm_data),
  .p2b_shimm_s1_a(i_p2b_shimm_s1_a),
  .p2b_shimm_s2_a(i_p2b_shimm_s2_a),
  .p2b_jmp_holdup_a(i_p2b_jmp_holdup_a),
  .en3_niv_a(i_en3_niv_a),
  .ldvalid_wb(i_ldvalid_wb),
  .mload(i_mload),
  .mstore(i_mstore),
  .nocache(nocache),
  .p3_alu_absiv(i_p3_alu_absiv),
  .p3_alu_arithiv(i_p3_alu_arithiv),
  .p3_alu_logiciv(i_p3_alu_logiciv),
  .p3_alu_op(i_p3_alu_op),
  .p3_alu_snglopiv(i_p3_alu_snglopiv),
  .p3_bit_op_sel(i_p3_bit_op_sel),
  .p3_brcc_instr_a(i_p3_brcc_instr_a),
  .p3_docmprel_a(i_p3_docmprel_a),
  .p3_flag_instr(i_p3_flag_instr),
  .p3_sync_instr(i_p3_sync_instr),
  .p3_max_instr(i_p3_max_instr),
  .p3_min_instr(i_p3_min_instr),
  .p3_shiftin_sel_r(i_p3_shiftin_sel_r),
  .p3_sop_op_r(i_p3_sop_op_r),
  .p3awb_field_r(i_p3awb_field_r),
  .p3dolink(i_p3dolink),
  .p3minoropcode(i_p3minoropcode),
  .p3subopcode3_r(i_p3subopcode3_r),
  .p3subopcode4_r(i_p3subopcode4_r),
  .p3subopcode5_r(i_p3subopcode5_r),
  .p3subopcode6_r(i_p3subopcode6_r),
  .p3subopcode7_r(i_p3subopcode7_r),
  .sc_load1(i_sc_load1),
  .sc_load2(i_sc_load2),
  .sex(sex),
  .size(size),
  .p4_docmprel(i_p4_docmprel),
  .loopcount_hit_a(i_loopcount_hit_a),
  .p4_disable_r(i_p4_disable_r),
  .kill_p1_nlp_a(i_kill_p1_nlp_a),
  .kill_p2_a(i_kill_p2_a),
  .kill_tagged_p1(i_kill_tagged_p1),
  .stop_step(i_stop_step),
  .barrel_type_r(i_barrel_type_r),
  .x_p3_brl_decode_16_r(i_x_p3_brl_decode_16_r),
  .x_p3_brl_decode_32_r(i_x_p3_brl_decode_32_r),
  .x_p3_norm_decode_r(i_x_p3_norm_decode_r),
  .x_p3_snorm_decode_r(i_x_p3_snorm_decode_r),
  .x_p3_swap_decode_r(i_x_p3_swap_decode_r),
  .x_flgen(i_x_flgen),
  .xsetflags(i_xsetflags),
  .x_set_sflag(i_x_set_sflag),
  .p3ilev1(i_p3ilev1),
  .aux_lv12(i_aux_lv12),
  .aux_hint(i_aux_hint),
  .aux_lev(i_aux_lev),
  .max_one_lpend(max_one_lpend),
  .ctrl_cpu_start_r(i_ctrl_cpu_start_r),
  .ck_gated(i_ck_gated),
  .currentpc_r(i_currentpc_r),
  .misaligned_target(i_misaligned_target),
  .pc_is_linear_r(i_pc_is_linear_r),
  .next_pc(i_next_pc),
  .last_pc_plus_len(i_last_pc_plus_len),
  .p2b_pc_r(i_p2b_pc_r),
  .p2_target(i_p2_target),
  .p2_s1val_tmp_r(i_p2_s1val_tmp_r),
  .pcounter_jmp_restart_a(i_pcounter_jmp_restart_a)
);


// Instantiation of module alu
alu ialu(
  .rst_a(rst_a),
  .clk(clk),
  .en2b(i_en2b),
  .p2b_iv(i_p2b_iv),
  .p2b_opcode(i_p2b_opcode),
  .p2b_subopcode(i_p2b_subopcode),
  .en3(i_en3),
  .p3iv(i_p3iv),
  .p3opcode(i_p3opcode),
  .p3subopcode(i_p3subopcode),
  .p3subopcode2_r(i_p3subopcode2_r),
  .p3a_field_r(i_p3a_field_r),
  .p3b_field_r(i_p3b_field_r),
  .p3c_field_r(i_p3c_field_r),
  .p3condtrue(i_p3condtrue),
  .x_idecode3(i_x_idecode3),
  .p3wb_en(i_p3wb_en),
  .p3lr(i_p3lr),
  .aluflags_r(i_aluflags_r),
  .ext_s1val(i_ext_s1val),
  .ext_s2val(i_ext_s2val),
  .aux_dataw(i_aux_dataw),
  .h_dataw(h_dataw),
  .uxsetflags(i_uxsetflags),
  .uxresult(i_uxresult),
  .uxflags(i_uxflags),
  .cr_hostw(i_cr_hostw),
  .p3int(i_p3int),
  .x_multic_wben(i_x_multic_wben),
  .x_snglec_wben(i_x_snglec_wben),
  .ldvalid_wb(i_ldvalid_wb),
  .p3_alu_absiv(i_p3_alu_absiv),
  .p3_alu_arithiv(i_p3_alu_arithiv),
  .p3_alu_logiciv(i_p3_alu_logiciv),
  .p3_alu_op(i_p3_alu_op),
  .p3_alu_snglopiv(i_p3_alu_snglopiv),
  .p3_bit_op_sel(i_p3_bit_op_sel),
  .p3_max_instr(i_p3_max_instr),
  .p3_min_instr(i_p3_min_instr),
  .p3_shiftin_sel_r(i_p3_shiftin_sel_r),
  .p3_sop_op_r(i_p3_sop_op_r),
  .p3awb_field_r(i_p3awb_field_r),
  .p3dolink(i_p3dolink),
  .p3minoropcode(i_p3minoropcode),
  .p3subopcode3_r(i_p3subopcode3_r),
  .p3subopcode4_r(i_p3subopcode4_r),
  .p3subopcode5_r(i_p3subopcode5_r),
  .p3subopcode6_r(i_p3subopcode6_r),
  .p3subopcode7_r(i_p3subopcode7_r),
  .s2val(i_s2val),
  .barrel_type_r(i_barrel_type_r),
  .x_p3_brl_decode_16_r(i_x_p3_brl_decode_16_r),
  .x_p3_brl_decode_32_r(i_x_p3_brl_decode_32_r),
  .x_p3_norm_decode_r(i_x_p3_norm_decode_r),
  .x_p3_snorm_decode_r(i_x_p3_snorm_decode_r),
  .x_p3_swap_decode_r(i_x_p3_swap_decode_r),
  .e1flag_r(i_e1flag_r),
  .e2flag_r(i_e2flag_r),
  .aux_datar(i_aux_datar),
  .aux_pc32hit(i_aux_pc32hit),
  .aux_pchit(i_aux_pchit),
  .drd(drd),
  .s1val(i_s1val),
  .s2val_inverted_r(i_s2val_inverted_r),
  .aux_st_mulhi_a(i_aux_st_mulhi_a),
  .wbdata(i_wbdata),
  .br_flags_a(i_br_flags_a),
  .mulatwork_r(i_mulatwork_r),
  .alurflags(i_alurflags),
  .mc_addr(i_mc_addr),
  .p3res_sc(i_p3res_sc),
  .p3result(i_p3result),
  .lmulres_r(i_lmulres_r),
  .x_s_flag(i_x_s_flag),
  .xflags(i_xflags)
);


// Instantiation of module registers
registers iregisters(
  .clk_ungated(clk_ungated),
  .code_ram_rdata(code_ram_rdata),
  .en(i_en),
  .rst_a(rst_a),
  .test_mode(test_mode),
  .ck_disable(i_ck_disable),
  .clk(clk),
  .s1en(i_s1en),
  .s2en(i_s2en),
  .en2(i_en2),
  .mstore2b(i_mstore2b),
  .p2opcode(i_p2opcode),
  .p2subopcode(i_p2subopcode),
  .p2iv(i_p2iv),
  .en2b(i_en2b),
  .p2b_iv(i_p2b_iv),
  .aux_addr(i_aux_addr),
  .aux_dataw(i_aux_dataw),
  .aux_write(i_aux_write),
  .h_addr(h_addr),
  .h_read(h_read),
  .s1a(i_s1a),
  .s2a(i_s2a),
  .fs2a(i_fs2a),
  .wba(i_wba),
  .wbdata(i_wbdata),
  .wben(i_wben),
  .core_access(core_access),
  .sc_reg1(i_sc_reg1),
  .sc_reg2(i_sc_reg2),
  .ux2data_2_pc(i_ux2data_2_pc),
  .ux1data(i_ux1data),
  .ux2data(i_ux2data),
  .do_inst_step_r(i_do_inst_step_r),
  .h_pcwr(i_h_pcwr),
  .h_pcwr32(i_h_pcwr32),
  .ivic(i_ivic),
  .ldvalid(ldvalid),
  .dmp_mload(dmp_mload),
  .dmp_mstore(dmp_mstore),
  .p1int(i_p1int),
  .p2int(i_p2int),
  .p2bint(i_p2bint),
  .pcounter_jmp_restart_r(i_pcounter_jmp_restart_r),
  .regadr(i_regadr),
  .x_idecode2b(i_x_idecode2b),
  .en1(i_en1),
  .ifetch_aligned(i_ifetch_aligned),
  .pcen(i_pcen),
  .pcen_niv(i_pcen_niv),
  .p2_dopred(i_p2_dopred),
  .p2_dorel(i_p2_dorel),
  .p2_iw_r(i_p2_iw_r),
  .p2_lp_instr(i_p2_lp_instr),
  .p2_s1a(i_p2_s1a),
  .p2_s2a(i_p2_s2a),
  .p2condtrue(i_p2condtrue),
  .p2limm(i_p2limm),
  .p2minoropcode(i_p2minoropcode),
  .p2subopcode3_r(i_p2subopcode3_r),
  .p2subopcode4_r(i_p2subopcode4_r),
  .p2subopcode5_r(i_p2subopcode5_r),
  .p2subopcode6_r(i_p2subopcode6_r),
  .p2subopcode7_r(i_p2subopcode7_r),
  .p2b_abs_op(i_p2b_abs_op),
  .p2b_alu_op(i_p2b_alu_op),
  .p2b_arithiv(i_p2b_arithiv),
  .p2b_blcc_a(i_p2b_blcc_a),
  .p2b_delay_slot(i_p2b_delay_slot),
  .p2b_dojcc(i_p2b_dojcc),
  .p2b_jlcc_a(i_p2b_jlcc_a),
  .p2b_limm(i_p2b_limm),
  .p2b_lr(i_p2b_lr),
  .p2b_neg_op(i_p2b_neg_op),
  .p2b_not_op(i_p2b_not_op),
  .p2b_shift_by_one_a(i_p2b_shift_by_one_a),
  .p2b_shift_by_three_a(i_p2b_shift_by_three_a),
  .p2b_shift_by_two_a(i_p2b_shift_by_two_a),
  .p2b_shift_by_zero_a(i_p2b_shift_by_zero_a),
  .p2b_shimm_data(i_p2b_shimm_data),
  .p2b_shimm_s1_a(i_p2b_shimm_s1_a),
  .p2b_shimm_s2_a(i_p2b_shimm_s2_a),
  .sc_load1(i_sc_load1),
  .sc_load2(i_sc_load2),
  .p4_docmprel(i_p4_docmprel),
  .loopcount_hit_a(i_loopcount_hit_a),
  .kill_p1_nlp_a(i_kill_p1_nlp_a),
  .kill_tagged_p1(i_kill_tagged_p1),
  .currentpc_r(i_currentpc_r),
  .misaligned_target(i_misaligned_target),
  .pc_is_linear_r(i_pc_is_linear_r),
  .next_pc(i_next_pc),
  .last_pc_plus_len(i_last_pc_plus_len),
  .p2b_pc_r(i_p2b_pc_r),
  .p2_target(i_p2_target),
  .p2_s1val_tmp_r(i_p2_s1val_tmp_r),
  .drd(drd),
  .p3res_sc(i_p3res_sc),
  .p3result(i_p3result),
  .lmulres_r(i_lmulres_r),
  .hold_host(i_hold_host),
  .cr_hostr(i_cr_hostr),
  .h_status32(i_h_status32),
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
  .s1bus(i_s1bus),
  .s2bus(i_s2bus),
  .ext_s1val(i_ext_s1val),
  .ext_s2val(i_ext_s2val),
  .ivalid_aligned(i_ivalid_aligned),
  .loop_kill_p1_a(i_loop_kill_p1_a),
  .loop_int_holdoff_a(i_loop_int_holdoff_a),
  .loopend_hit_a(i_loopend_hit_a),
  .p1iw_aligned_a(i_p1iw_aligned_a),
  .code_stall_ldst(i_code_stall_ldst),
  .s2val(i_s2val),
  .ic_busy(i_ic_busy),
  .aligner_do_pc_plus_8(i_aligner_do_pc_plus_8),
  .aligner_pc_enable(i_aligner_pc_enable),
  .ivalid(i_ivalid),
  .loopstart_r(i_loopstart_r),
  .p1inst_16(i_p1inst_16),
  .do_loop_a(i_do_loop_a),
  .qd_b(i_qd_b),
  .x2data_2_pc(i_x2data_2_pc),
  .s1val(i_s1val),
  .s2val_inverted_r(i_s2val_inverted_r),
  .dwr(i_dwr),
  .h_rr_data(i_h_rr_data),
  .loopend_r(i_loopend_r),
  .sr_xhold_host_a(i_sr_xhold_host_a),
  .p1iw(i_p1iw),
  .code_drd(code_drd),
  .code_ldvalid_r(code_ldvalid_r),
  .code_dmi_rdata(code_dmi_rdata)
);


// Instantiation of module auxiliary
auxiliary iauxiliary(
  .clk_ungated(clk_ungated),
  .rst_a(rst_a),
  .l_irq_4(l_irq_4),
  .l_irq_5(l_irq_5),
  .l_irq_6(l_irq_6),
  .l_irq_7(l_irq_7),
  .l_irq_8(l_irq_8),
  .l_irq_9(l_irq_9),
  .l_irq_10(l_irq_10),
  .l_irq_11(l_irq_11),
  .l_irq_12(l_irq_12),
  .l_irq_13(l_irq_13),
  .l_irq_14(l_irq_14),
  .l_irq_15(l_irq_15),
  .l_irq_16(l_irq_16),
  .l_irq_17(l_irq_17),
  .l_irq_18(l_irq_18),
  .l_irq_19(l_irq_19),
  .en_debug_r(i_en_debug_r),
  .clk(clk),
  .en2(i_en2),
  .p2sleep_inst(i_p2sleep_inst),
  .en2b(i_en2b),
  .p2b_iv(i_p2b_iv),
  .p2b_opcode(i_p2b_opcode),
  .p2b_subopcode(i_p2b_subopcode),
  .en3(i_en3),
  .p3iv(i_p3iv),
  .p3condtrue(i_p3condtrue),
  .p3setflags(i_p3setflags),
  .x_idecode3(i_x_idecode3),
  .p3wba(i_p3wba),
  .p3lr(i_p3lr),
  .p3sr(i_p3sr),
  .h_addr(h_addr),
  .h_dataw(h_dataw),
  .h_write(h_write),
  .h_read(h_read),
  .aux_access(aux_access),
  .fs2a(i_fs2a),
  .core_access(core_access),
  .uxdrx_reg(i_uxdrx_reg),
  .uxreg_hit(i_uxreg_hit),
  .ux_da_am(i_ux_da_am),
  .ux_dar(i_ux_dar),
  .uxivic(i_uxivic),
  .uxhold_host(i_uxhold_host),
  .uxnoaccess(i_uxnoaccess),
  .actionpt_pc_brk_a(i_actionpt_pc_brk_a),
  .ldvalid(ldvalid),
  .lpending(i_lpending),
  .debug_if_r(debug_if_r),
  .p1int(i_p1int),
  .p2int(i_p2int),
  .p2bint(i_p2bint),
  .p3int(i_p3int),
  .x_multic_busy(i_x_multic_busy),
  .inst_stepping(i_inst_stepping),
  .instr_pending_r(i_instr_pending_r),
  .brk_inst_a(i_brk_inst_a),
  .p2b_condtrue(i_p2b_condtrue),
  .p2b_setflags(i_p2b_setflags),
  .en3_niv_a(i_en3_niv_a),
  .p3_docmprel_a(i_p3_docmprel_a),
  .p3_flag_instr(i_p3_flag_instr),
  .p3_sync_instr(i_p3_sync_instr),
  .p4_disable_r(i_p4_disable_r),
  .stop_step(i_stop_step),
  .s2val(i_s2val),
  .x_flgen(i_x_flgen),
  .xsetflags(i_xsetflags),
  .x_set_sflag(i_x_set_sflag),
  .p3ilev1(i_p3ilev1),
  .aux_lv12(i_aux_lv12),
  .aux_hint(i_aux_hint),
  .aux_lev(i_aux_lev),
  .ic_busy(i_ic_busy),
  .ctrl_cpu_start_r(i_ctrl_cpu_start_r),
  .ck_gated(i_ck_gated),
  .loopstart_r(i_loopstart_r),
  .currentpc_r(i_currentpc_r),
  .pcounter_jmp_restart_a(i_pcounter_jmp_restart_a),
  .s1val(i_s1val),
  .alurflags(i_alurflags),
  .x_s_flag(i_x_s_flag),
  .xflags(i_xflags),
  .h_rr_data(i_h_rr_data),
  .loopend_r(i_loopend_r),
  .sr_xhold_host_a(i_sr_xhold_host_a),
  .arc_start_a(arc_start_a),
  .debug_if_a(debug_if_a),
  .actionpt_hit_a(i_actionpt_hit_a),
  .actionpt_status_r(i_actionpt_status_r),
  .halt(halt),
  .xstep(xstep),
  .misaligned_err(misaligned_err),
  .ap_ahv0(i_ap_ahv0),
  .ap_ahv1(i_ap_ahv1),
  .ap_ahv2(i_ap_ahv2),
  .ap_ahv3(i_ap_ahv3),
  .ap_ahv4(i_ap_ahv4),
  .ap_ahv5(i_ap_ahv5),
  .ap_ahv6(i_ap_ahv6),
  .ap_ahv7(i_ap_ahv7),
  .ap_ahc0(i_ap_ahc0),
  .ap_ahc1(i_ap_ahc1),
  .ap_ahc2(i_ap_ahc2),
  .ap_ahc3(i_ap_ahc3),
  .ap_ahc4(i_ap_ahc4),
  .ap_ahc5(i_ap_ahc5),
  .ap_ahc6(i_ap_ahc6),
  .ap_ahc7(i_ap_ahc7),
  .ap_ahm0(i_ap_ahm0),
  .ap_ahm1(i_ap_ahm1),
  .ap_ahm2(i_ap_ahm2),
  .ap_ahm3(i_ap_ahm3),
  .ap_ahm4(i_ap_ahm4),
  .ap_ahm5(i_ap_ahm5),
  .ap_ahm6(i_ap_ahm6),
  .ap_ahm7(i_ap_ahm7),
  .en(i_en),
  .wd_clear(i_wd_clear),
  .aluflags_r(i_aluflags_r),
  .aux_addr(i_aux_addr),
  .aux_dataw(i_aux_dataw),
  .aux_write(i_aux_write),
  .aux_read(i_aux_read),
  .s2a(i_s2a),
  .actionhalt(i_actionhalt),
  .cr_hostw(i_cr_hostw),
  .do_inst_step_r(i_do_inst_step_r),
  .h_pcwr(i_h_pcwr),
  .h_pcwr32(i_h_pcwr32),
  .h_regadr(i_h_regadr),
  .ivic(i_ivic),
  .sleeping(i_sleeping),
  .sleeping_r2(i_sleeping_r2),
  .irq(i_irq),
  .int_vector_base_r(i_int_vector_base_r),
  .e1flag_r(i_e1flag_r),
  .e2flag_r(i_e2flag_r),
  .dc_disable_r(i_dc_disable_r),
  .host_rw(i_host_rw),
  .step(i_step),
  .inst_step(i_inst_step),
  .aux_datar(i_aux_datar),
  .aux_pc32hit(i_aux_pc32hit),
  .aux_pchit(i_aux_pchit),
  .aux_st_mulhi_a(i_aux_st_mulhi_a),
  .hold_host(i_hold_host),
  .cr_hostr(i_cr_hostr),
  .h_status32(i_h_status32),
  .noaccess(noaccess),
  .en_misaligned(en_misaligned),
  .reset_applied_r(reset_applied_r),
  .power_toggle(power_toggle),
  .lram_base(lram_base),
  .pc_sel_r(pc_sel_r),
  .h_datar(h_datar)
);


// Instantiation of module debug_exts
debug_exts idebug_exts(
  .clk(clk),
  .clk_debug(clk_debug),
  .clk_ungated(clk_ungated),
  .rst_a(rst_a),
  .ivic(i_ivic),
  .p2b_iv(i_p2b_iv),
  .p2_iw_r(i_p2_iw_r),
  .actionpt_pc_brk_a(i_actionpt_pc_brk_a),
  .p2_brcc_instr_a(i_p2_brcc_instr_a),
  .p3_brcc_instr_a(i_p3_brcc_instr_a),
  .p2_ap_stall_a(i_p2_ap_stall_a),
  .p2b_jmp_holdup_a(i_p2b_jmp_holdup_a),
  .en(i_en),
  .aux_access(aux_access),
  .aux_read(i_aux_read),
  .aux_write(i_aux_write),
  .core_access(core_access),
  .h_addr(h_addr),
  .h_dataw(h_dataw),
  .h_write(h_write),
  .h_read(h_read),
  .en1(i_en1),
  .en2(i_en2),
  .en2b(i_en2b),
  .en3(i_en3),
  .ivalid_aligned(i_ivalid_aligned),
  .mload2b(i_mload2b),
  .mstore2b(i_mstore2b),
  .mwait(mwait),
  .p2limm(i_p2limm),
  .p2iv(i_p2iv),
  .p2opcode(i_p2opcode),
  .p2subopcode(i_p2subopcode),
  .currentpc_r(i_currentpc_r),
  .p1iw(i_p1iw),
  .mc_addr(i_mc_addr),
  .dwr(i_dwr),
  .drd(drd),
  .aux_addr(i_aux_addr),
  .aux_dataw(i_aux_dataw),
  .aux_datar(i_aux_datar),
  .ap_param0(i_ap_param0),
  .ap_param1(i_ap_param1),
  .ivalid(i_ivalid),
  .kill_tagged_p1(i_kill_tagged_p1),
  .kill_p2_a(i_kill_p2_a),
  .mload(i_mload),
  .mstore(i_mstore),
  .ldvalid(ldvalid),
  .ap_param0_read(i_ap_param0_read),
  .ap_param0_write(i_ap_param0_write),
  .ap_param1_read(i_ap_param1_read),
  .ap_param1_write(i_ap_param1_write),
  .actionhalt(i_actionhalt),
  .actionpt_status_r(i_actionpt_status_r),
  .ap_ahv0(i_ap_ahv0),
  .ap_ahv1(i_ap_ahv1),
  .ap_ahv2(i_ap_ahv2),
  .ap_ahv3(i_ap_ahv3),
  .ap_ahv4(i_ap_ahv4),
  .ap_ahv5(i_ap_ahv5),
  .ap_ahv6(i_ap_ahv6),
  .ap_ahv7(i_ap_ahv7),
  .ap_ahc0(i_ap_ahc0),
  .ap_ahc1(i_ap_ahc1),
  .ap_ahc2(i_ap_ahc2),
  .ap_ahc3(i_ap_ahc3),
  .ap_ahc4(i_ap_ahc4),
  .ap_ahc5(i_ap_ahc5),
  .ap_ahc6(i_ap_ahc6),
  .ap_ahc7(i_ap_ahc7),
  .ap_ahm0(i_ap_ahm0),
  .ap_ahm1(i_ap_ahm1),
  .ap_ahm2(i_ap_ahm2),
  .ap_ahm3(i_ap_ahm3),
  .ap_ahm4(i_ap_ahm4),
  .ap_ahm5(i_ap_ahm5),
  .ap_ahm6(i_ap_ahm6),
  .ap_ahm7(i_ap_ahm7),
  .actionpt_hit_a(i_actionpt_hit_a),
  .actionpt_swi_a(i_actionpt_swi_a),
  .en_debug_r(i_en_debug_r)
);


// Output drives
assign en                      = i_en;
assign wd_clear                = i_wd_clear;
assign ck_disable              = i_ck_disable;
assign en_debug_r              = i_en_debug_r;
assign en3                     = i_en3;
assign lpending                = i_lpending;
assign mload                   = i_mload;
assign mstore                  = i_mstore;
assign dc_disable_r            = i_dc_disable_r;
assign mc_addr                 = i_mc_addr;
assign dwr                     = i_dwr;
assign hold_host               = i_hold_host;

endmodule


