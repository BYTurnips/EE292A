// *SYNOPSYS CONFIDENTIAL*
//
// This is an unpublished, proprietary work of Synopsys, Inc., and is fully 
// protected under copyright and trade secret laws.  You may not view, use, 
// disclose, copy, or distribute this file or any information contained herein 
// except pursuant to a valid written license from Synopsys.


// This file is generated automatically by 'veriloggen'.




module auxiliary(clk_ungated,
                 rst_a,
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
                 en_debug_r,
                 clk,
                 en2,
                 p2sleep_inst,
                 en2b,
                 p2b_iv,
                 p2b_opcode,
                 p2b_subopcode,
                 en3,
                 p3iv,
                 p3condtrue,
                 p3setflags,
                 x_idecode3,
                 p3wba,
                 p3lr,
                 p3sr,
                 h_addr,
                 h_dataw,
                 h_write,
                 h_read,
                 aux_access,
                 fs2a,
                 core_access,
                 uxdrx_reg,
                 uxreg_hit,
                 ux_da_am,
                 ux_dar,
                 uxivic,
                 uxhold_host,
                 uxnoaccess,
                 actionpt_pc_brk_a,
                 ldvalid,
                 lpending,
                 debug_if_r,
                 p1int,
                 p2int,
                 p2bint,
                 p3int,
                 x_multic_busy,
                 inst_stepping,
                 instr_pending_r,
                 brk_inst_a,
                 p2b_condtrue,
                 p2b_setflags,
                 en3_niv_a,
                 p3_docmprel_a,
                 p3_flag_instr,
                 p3_sync_instr,
                 p4_disable_r,
                 stop_step,
                 s2val,
                 x_flgen,
                 xsetflags,
                 x_set_sflag,
                 p3ilev1,
                 aux_lv12,
                 aux_hint,
                 aux_lev,
                 ic_busy,
                 ctrl_cpu_start_r,
                 ck_gated,
                 loopstart_r,
                 currentpc_r,
                 pcounter_jmp_restart_a,
                 s1val,
                 alurflags,
                 x_s_flag,
                 xflags,
                 h_rr_data,
                 loopend_r,
                 sr_xhold_host_a,
                 arc_start_a,
                 debug_if_a,
                 actionpt_hit_a,
                 actionpt_status_r,
                 halt,
                 xstep,
                 misaligned_err,
                 ap_ahv0,
                 ap_ahv1,
                 ap_ahv2,
                 ap_ahv3,
                 ap_ahv4,
                 ap_ahv5,
                 ap_ahv6,
                 ap_ahv7,
                 ap_ahc0,
                 ap_ahc1,
                 ap_ahc2,
                 ap_ahc3,
                 ap_ahc4,
                 ap_ahc5,
                 ap_ahc6,
                 ap_ahc7,
                 ap_ahm0,
                 ap_ahm1,
                 ap_ahm2,
                 ap_ahm3,
                 ap_ahm4,
                 ap_ahm5,
                 ap_ahm6,
                 ap_ahm7,
                 en,
                 wd_clear,
                 aluflags_r,
                 aux_addr,
                 aux_dataw,
                 aux_write,
                 aux_read,
                 s2a,
                 actionhalt,
                 cr_hostw,
                 do_inst_step_r,
                 h_pcwr,
                 h_pcwr32,
                 h_regadr,
                 ivic,
                 sleeping,
                 sleeping_r2,
                 irq,
                 int_vector_base_r,
                 e1flag_r,
                 e2flag_r,
                 dc_disable_r,
                 host_rw,
                 step,
                 inst_step,
                 aux_datar,
                 aux_pc32hit,
                 aux_pchit,
                 aux_st_mulhi_a,
                 hold_host,
                 cr_hostr,
                 h_status32,
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
`include "extutil.v"
`include "xdefs.v"
`include "asmutil.v"
`include "ext_msb.v"
`include "che_util.v"


input  clk_ungated;
input  rst_a;
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
input  en_debug_r;
input  clk;
input  en2;
input  p2sleep_inst;
input  en2b;
input  p2b_iv;
input  [4:0]  p2b_opcode;
input  [5:0]  p2b_subopcode;
input  en3;
input  p3iv;
input  p3condtrue;
input  p3setflags;
input  x_idecode3;
input  [5:0]  p3wba;
input  p3lr;
input  p3sr;
input  [31:0]  h_addr;
input  [31:0]  h_dataw;
input  h_write;
input  h_read;
input  aux_access;
input  [5:0]  fs2a;
input  core_access;
input  [31:0]  uxdrx_reg;
input  uxreg_hit;
input  ux_da_am;
input  [31:0]  ux_dar;
input  uxivic;
input  uxhold_host;
input  uxnoaccess;
input  actionpt_pc_brk_a;
input  ldvalid;
input  lpending;
input  debug_if_r;
input  p1int;
input  p2int;
input  p2bint;
input  p3int;
input  x_multic_busy;
input  inst_stepping;
input  instr_pending_r;
input  brk_inst_a;
input  p2b_condtrue;
input  p2b_setflags;
input  en3_niv_a;
input  p3_docmprel_a;
input  p3_flag_instr;
input  p3_sync_instr;
input  p4_disable_r;
input  stop_step;
input  [31:0]  s2val;
input  x_flgen;
input  xsetflags;
input  x_set_sflag;
input  p3ilev1;
input  [1:0]  aux_lv12;
input  [4:0]  aux_hint;
input  [31:3]  aux_lev;
input  ic_busy;
input  ctrl_cpu_start_r;
input  ck_gated;
input  [PC_MSB:0]  loopstart_r;
input  [PC_MSB:0]  currentpc_r;
input  pcounter_jmp_restart_a;
input  [31:0]  s1val;
input  [3:0]  alurflags;
input  [1:0]  x_s_flag;
input  [3:0]  xflags;
input  [31:0]  h_rr_data;
input  [PC_MSB:0]  loopend_r;
input  sr_xhold_host_a;
input  arc_start_a;
input  debug_if_a;
input  actionpt_hit_a;
input  [NUM_APS-1:0]  actionpt_status_r;
input  halt;
input  xstep;
input  misaligned_err;
input  [31:0]  ap_ahv0;
input  [31:0]  ap_ahv1;
input  [31:0]  ap_ahv2;
input  [31:0]  ap_ahv3;
input  [31:0]  ap_ahv4;
input  [31:0]  ap_ahv5;
input  [31:0]  ap_ahv6;
input  [31:0]  ap_ahv7;
input  [31:0]  ap_ahc0;
input  [31:0]  ap_ahc1;
input  [31:0]  ap_ahc2;
input  [31:0]  ap_ahc3;
input  [31:0]  ap_ahc4;
input  [31:0]  ap_ahc5;
input  [31:0]  ap_ahc6;
input  [31:0]  ap_ahc7;
input  [31:0]  ap_ahm0;
input  [31:0]  ap_ahm1;
input  [31:0]  ap_ahm2;
input  [31:0]  ap_ahm3;
input  [31:0]  ap_ahm4;
input  [31:0]  ap_ahm5;
input  [31:0]  ap_ahm6;
input  [31:0]  ap_ahm7;
output en;
output wd_clear;
output [3:0]  aluflags_r;
output [31:0]  aux_addr;
output [31:0]  aux_dataw;
output aux_write;
output aux_read;
output [5:0]  s2a;
output actionhalt;
output cr_hostw;
output do_inst_step_r;
output h_pcwr;
output h_pcwr32;
output [5:0]  h_regadr;
output ivic;
output sleeping;
output sleeping_r2;
output [31:3]  irq;
output [PC_MSB:`INT_BASE_LSB]  int_vector_base_r;
output e1flag_r;
output e2flag_r;
output dc_disable_r;
output host_rw;
output step;
output inst_step;
output [31:0]  aux_datar;
output aux_pc32hit;
output aux_pchit;
output aux_st_mulhi_a;
output hold_host;
output cr_hostr;
output h_status32;
output noaccess;
output en_misaligned;
output reset_applied_r;
output power_toggle;
output [EXT_A_MSB:LDST_A_MSB+3]  lram_base;
output pc_sel_r;
output [31:0]  h_datar;

wire clk_ungated;
wire rst_a;
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
wire en_debug_r;
wire clk;
wire en2;
wire p2sleep_inst;
wire en2b;
wire p2b_iv;
wire  [4:0] p2b_opcode;
wire  [5:0] p2b_subopcode;
wire en3;
wire p3iv;
wire p3condtrue;
wire p3setflags;
wire x_idecode3;
wire  [5:0] p3wba;
wire p3lr;
wire p3sr;
wire  [31:0] h_addr;
wire  [31:0] h_dataw;
wire h_write;
wire h_read;
wire aux_access;
wire  [5:0] fs2a;
wire core_access;
wire  [31:0] uxdrx_reg;
wire uxreg_hit;
wire ux_da_am;
wire  [31:0] ux_dar;
wire uxivic;
wire uxhold_host;
wire uxnoaccess;
wire actionpt_pc_brk_a;
wire ldvalid;
wire lpending;
wire debug_if_r;
wire p1int;
wire p2int;
wire p2bint;
wire p3int;
wire x_multic_busy;
wire inst_stepping;
wire instr_pending_r;
wire brk_inst_a;
wire p2b_condtrue;
wire p2b_setflags;
wire en3_niv_a;
wire p3_docmprel_a;
wire p3_flag_instr;
wire p3_sync_instr;
wire p4_disable_r;
wire stop_step;
wire  [31:0] s2val;
wire x_flgen;
wire xsetflags;
wire x_set_sflag;
wire p3ilev1;
wire  [1:0] aux_lv12;
wire  [4:0] aux_hint;
wire  [31:3] aux_lev;
wire ic_busy;
wire ctrl_cpu_start_r;
wire ck_gated;
wire  [PC_MSB:0] loopstart_r;
wire  [PC_MSB:0] currentpc_r;
wire pcounter_jmp_restart_a;
wire  [31:0] s1val;
wire  [3:0] alurflags;
wire  [1:0] x_s_flag;
wire  [3:0] xflags;
wire  [31:0] h_rr_data;
wire  [PC_MSB:0] loopend_r;
wire sr_xhold_host_a;
wire arc_start_a;
wire debug_if_a;
wire actionpt_hit_a;
wire  [NUM_APS-1:0] actionpt_status_r;
wire halt;
wire xstep;
wire misaligned_err;
wire  [31:0] ap_ahv0;
wire  [31:0] ap_ahv1;
wire  [31:0] ap_ahv2;
wire  [31:0] ap_ahv3;
wire  [31:0] ap_ahv4;
wire  [31:0] ap_ahv5;
wire  [31:0] ap_ahv6;
wire  [31:0] ap_ahv7;
wire  [31:0] ap_ahc0;
wire  [31:0] ap_ahc1;
wire  [31:0] ap_ahc2;
wire  [31:0] ap_ahc3;
wire  [31:0] ap_ahc4;
wire  [31:0] ap_ahc5;
wire  [31:0] ap_ahc6;
wire  [31:0] ap_ahc7;
wire  [31:0] ap_ahm0;
wire  [31:0] ap_ahm1;
wire  [31:0] ap_ahm2;
wire  [31:0] ap_ahm3;
wire  [31:0] ap_ahm4;
wire  [31:0] ap_ahm5;
wire  [31:0] ap_ahm6;
wire  [31:0] ap_ahm7;
wire en;
wire wd_clear;
wire  [3:0] aluflags_r;
wire  [31:0] aux_addr;
wire  [31:0] aux_dataw;
wire aux_write;
wire aux_read;
wire  [5:0] s2a;
wire actionhalt;
wire cr_hostw;
wire do_inst_step_r;
wire h_pcwr;
wire h_pcwr32;
wire  [5:0] h_regadr;
wire ivic;
wire sleeping;
wire sleeping_r2;
wire  [31:3] irq;
wire  [PC_MSB:`INT_BASE_LSB] int_vector_base_r;
wire e1flag_r;
wire e2flag_r;
wire dc_disable_r;
wire host_rw;
wire step;
wire inst_step;
wire  [31:0] aux_datar;
wire aux_pc32hit;
wire aux_pchit;
wire aux_st_mulhi_a;
wire hold_host;
wire cr_hostr;
wire h_status32;
wire noaccess;
wire en_misaligned;
wire reset_applied_r;
wire power_toggle;
wire  [EXT_A_MSB:LDST_A_MSB+3] lram_base;
wire pc_sel_r;
wire  [31:0] h_datar;


// Intermediate signals
wire i_en;
wire  [31:0] i_aux_addr;
wire  [31:0] i_aux_dataw;
wire i_aux_write;
wire i_aux_read;
wire i_do_inst_step_r;
wire  [31:0] i_aux_datar;
wire i_noaccess;
wire i_xcache_hold_host;
wire  [31:0] i_drx_reg;
wire  [7:0] i_id_arcnum;
wire i_xreg_hit;
wire i_x_da_am;
wire  [31:0] i_x_dar;
wire  [31:0] i_aux_dar;
wire i_da_auxam;
wire i_hold_host_intrpt_a;
wire i_hold_host_multic_a;
wire i_host_write_en_n_a;
wire i_l_irq_3;
wire  [TIMER_MSB:0] i_timer_r;
wire  [TIMER_MSB:0] i_tlimit_r;
wire i_timer_pirq_r;
wire i_tcontrol_r;
wire i_timer_mode_r;
wire i_timer_clr_r;
wire i_twatchdog_r;
wire i_xnoaccess;
wire i_xhold_host;


// Dummy signals for 'unconnected' ports
// (doing this, rather than leaving them genuinely unconnected, stops
//  simulators emitting pointless warnings)
wire  [3:0] u_unconnected_0;


// Instantiation of module aux_regs
aux_regs iaux_regs(
  .clk(clk),
  .rst_a(rst_a),
  .ctrl_cpu_start_r(ctrl_cpu_start_r),
  .arc_start_a(arc_start_a),
  .aux_addr(i_aux_addr),
  .aux_dataw(i_aux_dataw),
  .aux_write(i_aux_write),
  .brk_inst_a(brk_inst_a),
  .stop_step(stop_step),
  .currentpc_r(currentpc_r),
  .en2(en2),
  .fs2a(fs2a),
  .instr_pending_r(instr_pending_r),
  .p2int(p2int),
  .en2b(en2b),
  .p2b_opcode(p2b_opcode),
  .p2b_subopcode(p2b_subopcode),
  .p2b_iv(p2b_iv),
  .p2b_condtrue(p2b_condtrue),
  .p2b_setflags(p2b_setflags),
  .p1int(p1int),
  .p2bint(p2bint),
  .p3iv(p3iv),
  .p3condtrue(p3condtrue),
  .p3_docmprel_a(p3_docmprel_a),
  .p3setflags(p3setflags),
  .p3int(p3int),
  .p3ilev1(p3ilev1),
  .p3wba(p3wba),
  .en3(en3),
  .s2val(s2val),
  .alurflags(alurflags),
  .p3_flag_instr(p3_flag_instr),
  .p3_sync_instr(p3_sync_instr),
  .debug_if_r(debug_if_r),
  .debug_if_a(debug_if_a),
  .lpending(lpending),
  .aux_access(aux_access),
  .inst_stepping(inst_stepping),
  .h_addr(h_addr),
  .h_dataw(h_dataw),
  .h_write(h_write),
  .noaccess(i_noaccess),
  .xcache_hold_host(i_xcache_hold_host),
  .drx_reg(i_drx_reg),
  .id_arcnum(i_id_arcnum),
  .xreg_hit(i_xreg_hit),
  .x_da_am(i_x_da_am),
  .x_dar(i_x_dar),
  .xflags(xflags),
  .x_flgen(x_flgen),
  .x_idecode3(x_idecode3),
  .xsetflags(xsetflags),
  .actionpt_hit_a(actionpt_hit_a),
  .p4_disable_r(p4_disable_r),
  .actionpt_status_r(actionpt_status_r),
  .en_debug_r(en_debug_r),
  .actionpt_pc_brk_a(actionpt_pc_brk_a),
  .p2sleep_inst(p2sleep_inst),
  .halt(halt),
  .xstep(xstep),
  .loopstart_r(loopstart_r),
  .loopend_r(loopend_r),
  .x_multic_busy(x_multic_busy),
  .pcounter_jmp_restart_a(pcounter_jmp_restart_a),
  .misaligned_err(misaligned_err),
  .en_misaligned(en_misaligned),
  .en(i_en),
  .aux_datar(i_aux_datar),
  .aux_dar(i_aux_dar),
  .aux_pchit(aux_pchit),
  .aux_pc32hit(aux_pc32hit),
  .da_auxam(i_da_auxam),
  .do_inst_step_r(i_do_inst_step_r),
  .h_pcwr(h_pcwr),
  .h_pcwr32(h_pcwr32),
  .h_status32(h_status32),
  .aluflags_nxt(u_unconnected_0),
  .aluflags_r(aluflags_r),
  .e1flag_r(e1flag_r),
  .e2flag_r(e2flag_r),
  .actionhalt(actionhalt),
  .hold_host_intrpt_a(i_hold_host_intrpt_a),
  .hold_host_multic_a(i_hold_host_multic_a),
  .host_write_en_n_a(i_host_write_en_n_a),
  .reset_applied_r(reset_applied_r),
  .sleeping_r2(sleeping_r2),
  .sleeping(sleeping),
  .step(step),
  .inst_step(inst_step)
);


// Instantiation of module xaux_regs
xaux_regs ixaux_regs(
  .clk(clk),
  .rst_a(rst_a),
  .en(i_en),
  .aux_addr(i_aux_addr),
  .aux_dataw(i_aux_dataw),
  .aux_write(i_aux_write),
  .aux_read(i_aux_read),
  .h_addr(h_addr),
  .h_dataw(h_dataw),
  .h_write(h_write),
  .h_read(h_read),
  .aux_access(aux_access),
  .core_access(core_access),
  .en2b(en2b),
  .en3(en3),
  .s1val(s1val),
  .s2val(s2val),
  .x_s_flag(x_s_flag),
  .x_set_sflag(x_set_sflag),
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
  .l_irq_3(i_l_irq_3),
  .sr_xhold_host_a(sr_xhold_host_a),
  .ic_busy(ic_busy),
  .p3lr(p3lr),
  .p3sr(p3sr),
  .aux_lv12(aux_lv12),
  .aux_hint(aux_hint),
  .aux_lev(aux_lev),
  .uxdrx_reg(uxdrx_reg),
  .uxreg_hit(uxreg_hit),
  .ux_da_am(ux_da_am),
  .ux_dar(ux_dar),
  .uxivic(uxivic),
  .uxhold_host(uxhold_host),
  .uxnoaccess(uxnoaccess),
  .ap_ahv0(ap_ahv0),
  .ap_ahv1(ap_ahv1),
  .ap_ahv2(ap_ahv2),
  .ap_ahv3(ap_ahv3),
  .ap_ahv4(ap_ahv4),
  .ap_ahv5(ap_ahv5),
  .ap_ahv6(ap_ahv6),
  .ap_ahv7(ap_ahv7),
  .ap_ahc0(ap_ahc0),
  .ap_ahc1(ap_ahc1),
  .ap_ahc2(ap_ahc2),
  .ap_ahc3(ap_ahc3),
  .ap_ahc4(ap_ahc4),
  .ap_ahc5(ap_ahc5),
  .ap_ahc6(ap_ahc6),
  .ap_ahc7(ap_ahc7),
  .ap_ahm0(ap_ahm0),
  .ap_ahm1(ap_ahm1),
  .ap_ahm2(ap_ahm2),
  .ap_ahm3(ap_ahm3),
  .ap_ahm4(ap_ahm4),
  .ap_ahm5(ap_ahm5),
  .ap_ahm6(ap_ahm6),
  .ap_ahm7(ap_ahm7),
  .timer_r(i_timer_r),
  .tlimit_r(i_tlimit_r),
  .timer_pirq_r(i_timer_pirq_r),
  .tcontrol_r(i_tcontrol_r),
  .timer_mode_r(i_timer_mode_r),
  .timer_clr_r(i_timer_clr_r),
  .twatchdog_r(i_twatchdog_r),
  .drx_reg(i_drx_reg),
  .xreg_hit(i_xreg_hit),
  .x_da_am(i_x_da_am),
  .x_dar(i_x_dar),
  .id_arcnum(i_id_arcnum),
  .xnoaccess(i_xnoaccess),
  .xhold_host(i_xhold_host),
  .xcache_hold_host(i_xcache_hold_host),
  .dc_disable_r(dc_disable_r),
  .power_toggle(power_toggle),
  .lram_base(lram_base),
  .pc_sel_r(pc_sel_r),
  .aux_st_mulhi_a(aux_st_mulhi_a),
  .int_vector_base_r(int_vector_base_r),
  .irq(irq),
  .ivic(ivic),
  .wd_clear(wd_clear)
);


// Instantiation of module hostif
hostif ihostif(
  .clk(clk),
  .rst_a(rst_a),
  .en(i_en),
  .fs2a(fs2a),
  .h_rr_data(h_rr_data),
  .s1val(s1val),
  .s2val(s2val),
  .p3lr(p3lr),
  .p3sr(p3sr),
  .aux_datar(i_aux_datar),
  .aux_dar(i_aux_dar),
  .da_auxam(i_da_auxam),
  .en3_niv_a(en3_niv_a),
  .p3_docmprel_a(p3_docmprel_a),
  .pcounter_jmp_restart_a(pcounter_jmp_restart_a),
  .ldvalid(ldvalid),
  .instr_pending_r(instr_pending_r),
  .do_inst_step_r(i_do_inst_step_r),
  .ck_gated(ck_gated),
  .hold_host_intrpt_a(i_hold_host_intrpt_a),
  .hold_host_multic_a(i_hold_host_multic_a),
  .host_write_en_n_a(i_host_write_en_n_a),
  .xnoaccess(i_xnoaccess),
  .xhold_host(i_xhold_host),
  .xcache_hold_host(i_xcache_hold_host),
  .h_addr(h_addr),
  .h_dataw(h_dataw),
  .h_write(h_write),
  .h_read(h_read),
  .aux_access(aux_access),
  .core_access(core_access),
  .s2a(s2a),
  .aux_addr(i_aux_addr),
  .aux_dataw(i_aux_dataw),
  .aux_read(i_aux_read),
  .aux_write(i_aux_write),
  .cr_hostr(cr_hostr),
  .cr_hostw(cr_hostw),
  .h_regadr(h_regadr),
  .host_rw(host_rw),
  .h_datar(h_datar),
  .noaccess(i_noaccess),
  .hold_host(hold_host)
);


// Instantiation of module timer0
timer0 itimer0(
  .clk_ungated(clk_ungated),
  .rst_a(rst_a),
  .en(i_en),
  .aux_write(i_aux_write),
  .aux_addr(i_aux_addr),
  .aux_dataw(i_aux_dataw),
  .timer_r(i_timer_r),
  .tlimit_r(i_tlimit_r),
  .timer_pirq_r(i_timer_pirq_r),
  .tcontrol_r(i_tcontrol_r),
  .timer_mode_r(i_timer_mode_r),
  .l_irq_3(i_l_irq_3),
  .timer_clr_r(i_timer_clr_r),
  .twatchdog_r(i_twatchdog_r)
);


// Output drives
assign en                      = i_en;
assign aux_addr                = i_aux_addr;
assign aux_dataw               = i_aux_dataw;
assign aux_write               = i_aux_write;
assign aux_read                = i_aux_read;
assign do_inst_step_r          = i_do_inst_step_r;
assign aux_datar               = i_aux_datar;
assign noaccess                = i_noaccess;

endmodule


