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
// Wrapper for Synchronous register file.
//
module sync_regs (clk,
                  rst_a,
                  en,
                  core_access,
                  hold_host,
                  en2,
                  fs2a,
                  p2_s1a,
                  p2_s2a,
                  s1a,
                  h_addr,
                  h_read,
                  wben,
                  wbdata,
                  wba,
                  regadr,
                  ldvalid,
                  s3p_qa,
                  s3p_qb,
                  p2iv,
                  cr_hostr,
                  test_mode,
                  sr_xhold_host_a,
                  ldv_r0r31,
                  qd_a,
                  qd_b,
                  s3p_aw,
                  s3p_ara,
                  s3p_arb,
                  s3p_we,
                  ck_en_w,
                  ck_en_w2,
                  ck_en_a,
                  ck_en_b);

`include "arcutil_pkg_defines.v"
`include "arcutil.v"
`include "extutil.v"

input   clk; 
input   rst_a; 

//  Signals for register reads
//
input   en; 
input   core_access; 
input   hold_host; 
input   en2; 
input   [5:0] fs2a; 
input   [5:0] p2_s1a; 
input   [5:0] p2_s2a; 
input   [5:0] s1a; 
input   [31:0] h_addr; 
input   h_read; 

//  Write data in
//
input   wben; 
input   [31:0] wbdata; 
input   [5:0] wba; 

//  Second (direct load) write port connections
//
//  Note that drd and regadr also go direct to the RAM.
//
input   [5:0]  regadr; 
input   ldvalid;

//  Connections to the core register file
//
input   [31:0] s3p_qa; 
input   [31:0] s3p_qb; 

//  Generation of the enable signals for the core register 
//  file.
//
input   p2iv; 
input   cr_hostr; 
input   test_mode; 

//  Signals for register reads
//
output  sr_xhold_host_a; 

//  Second (direct load) write port connections
//
output  ldv_r0r31; 

//  Read data out
//
output  [31:0] qd_a; 
output  [31:0] qd_b; 

//  Connections to the core register file
//
output  [4:0] s3p_aw; 
output  [4:0] s3p_ara; 
output  [4:0] s3p_arb; 
output  s3p_we; 

//  Generation of the enable signals for the core register 
//  file.
//
output  ck_en_w; 
output  ck_en_w2; 
output  ck_en_a; 
output  ck_en_b; 

wire    sr_xhold_host_a; 
wire    ldv_r0r31; 
wire    [31:0] qd_a; 
wire    [31:0] qd_b; 
wire    [4:0] s3p_aw; 
wire    [4:0] s3p_ara; 
wire    [4:0] s3p_arb; 
wire    s3p_we; 
wire    ck_en_w; 
wire    ck_en_w2; 
wire    ck_en_a; 
wire    ck_en_b; 

wire    [CORE_REG_MSB:0] i_aw_a; 
reg     i_hold_host_r; 
wire    i_ldvalid_r0r31_a; 
wire    [CORE_REG_MSB:0] i_rega_a; 
wire    [CORE_REG_MSB:0] i_regb_a; 
wire    i_sr_xhold_host_a; 
wire    i_we_a; 
reg     i_p5_we_r;
reg     [DATAWORD_MSB:0] i_p5_wbdata_r;
reg     [5:0] i_p5_wba_r;


   //  Generate Read addresses
   // 
   //  Read A address - Register read. The address comes direct from the
   //  instruction word which is being supplied by the cache.
   // 
   assign i_rega_a = (en2 == 1'b 1) ?
          p2_s1a[CORE_REG_MSB:0] : 
          s1a[CORE_REG_MSB:0]; 


   //  Read B address - Register reads plus HOST port accesses.
   //  Address comes from the instruction word being supplied by the cache,
   //  if the ARC is running, otherwise from the host address.
   // 
   //  We need to generate a cycle delay for host reads from the core 
   //  registers, since the data will not be ready until the end of the 
   //  cycle after the host address value first became true.
   //  
   //  Once we know that the Host read is going to complete successfully,
   //  we can remove the host address, and allow the RAM to re-fetch the
   //  values it had when the ARC was halted.
   // 
   assign i_regb_a = (en2         == 1'b 1) ?
          p2_s2a[CORE_REG_MSB:0] : 
                     ((hold_host   == 1'b 1) &&
                      (h_read      == 1'b 1) &&
                      (core_access == 1'b 1) &&
                      (en          == 1'b 0)) ?
          h_addr[CORE_REG_MSB:0] : 
          fs2a[CORE_REG_MSB:0]; 

   //  Generate Write signals
   // 
   //  Write address
   // 
   assign i_aw_a = wba[CORE_REG_MSB:0]; 

   //  Write enable : true when a register is being written, and the 
   //  address is in the lower half of the register space.
   // 
   assign i_we_a = ((wben             == 1'b 1) && 
                    (rf_reg(wba)      == 1'b 1)) ?
          REGFILE_WR_ACTIVE : 
          (~REGFILE_WR_ACTIVE); 

   //  Clock enable for the write port controlled by the write enable above.
   //  It is enabled during writes or when the ARC is in test mode.
   // 
   //  This turns off the RAM port when not in use to save power. Depending
   //  on technology this may cause time delays on the critical path. If
   //  this the case and this is not acceptable, just don't connect this
   //  signal to the RAM. If the flip-flop implementation of the core 
   //  register file is used then this signal is not used.
   //
   assign ck_en_w = (wben             == 1'b 1) &&
                    (rf_reg(wba)      == 1'b 1) || 
                    (test_mode        == 1'b 1) ?
          REGFILE_CK_EN_ACTIVE : 
          (~REGFILE_CK_EN_ACTIVE); 

   //  Host access.
   //   Generate a holdup signal when the host reads from the register file
   // 
   //   The nature of synchronous RAMs, and the lack of a pre-latch h_addr
   //   signal mean that host reads from the ARC register file will take 
   //   two cycles in this version.
   // 
   //  So, we stall if:
   //       The ARC is halted
   //       The host is attempting a core register read
   //       The previous cycle's host access was OK (not stalled)
   // 
   //  Hence when we generate a stall, or if one is generated somewhere else,
   //  the stall will go away after one cycle.
   // 
   assign i_sr_xhold_host_a = ((en            == 1'b 0) &&
                               (h_read        == 1'b 1) &&
                               (core_access   == 1'b 1) &&
                               (i_hold_host_r == 1'b 0)) ?
          1'b 1 : 
          1'b 0; 

   assign sr_xhold_host_a = i_sr_xhold_host_a; 

   // Keep a copy of the value of hold_host from the last cycle
   // Also, latch the write-enable signal.
   // 
   always @(posedge clk or posedge rst_a)
   begin : ff_sync_PROC
      if (rst_a == 1'b 1)
         begin
            i_hold_host_r <= 1'b 0; 
            i_p5_wbdata_r <= 32'b 0;    
            i_p5_wba_r    <= 6'b 0;    
            i_p5_we_r     <= 1'b 0;    
         end
      else
         begin
            i_hold_host_r <= hold_host;
                         
            if (i_we_a == REGFILE_WR_ACTIVE)
               begin
                  i_p5_wbdata_r <= wbdata;    
                  i_p5_wba_r    <= wba;
               end

            i_p5_we_r     <= i_we_a; 
         end
   end

//----------------------------------------------------------------------- 
//
// Generate write signal for direct load of r0-r31 data.
// 
// This signal controls the writing of drd[31:0] into the 4-port
// register file at the address specified by the bottom five bits of
// regadr.
// 
// The pipeline control system additionally has to deal with
// shortcutting of this data, and know not to generate stalls for these
// loads under normal circumstances.
// 
//
   assign i_ldvalid_r0r31_a = ((ldvalid             == 1'b 1) &&
                               (rf_reg(regadr)      == 1'b 1)) ?
          REGFILE_WR_ACTIVE : 
          (~REGFILE_WR_ACTIVE); 

   assign ldv_r0r31 = i_ldvalid_r0r31_a; 

// Clock enable for the write port controlled by the write enable above.
// It is enabled during writes or when the ARC is in test mode.
// (this signal is only used with the 4-port register file).
// 
// This turns off the RAM port when not in use to save power. Depending
// on technology this may cause time delays on the critical path. If
// this the case and this is not acceptable, just don't connect this
// signal to the RAM. If the flip-flop implementation of the core 
// register file is used then this signal is not used.
//
   assign ck_en_w2 = (((ldvalid           == 1'b 1) &&
                     (rf_reg(regadr)      == 1'b 1)) ||

                     (test_mode == 1'b 1)) ?

          REGFILE_CK_EN_ACTIVE : 
          (~REGFILE_CK_EN_ACTIVE); 

//----------------------------------------------------------------------- 
// 
// Some implementations require that we provide a write-through path,
// if the timing does not allow write-through inside the RAM.
//  
// Hence we switch the write data onto the outputs if
//
//      [1] A write is taking place,
//      OR
//      [2] The register being written to is also being read.
// 

   //  Multiplex the normal results with the writethrough result.
   // 
   assign qd_a = (i_we_a           == REGFILE_WR_ACTIVE) &&
                 (s1a              == wba) ?
          wbdata :
                 (i_p5_we_r        == REGFILE_WR_ACTIVE) &&
                 (s1a              == i_p5_wba_r) ?
          i_p5_wbdata_r :
          s3p_qa; 


   //  Multiplex the normal results with the writethrough result.
   // 
   assign qd_b = (i_we_a           == REGFILE_WR_ACTIVE) &&
                 (fs2a             == wba) ?
          wbdata : 
                 (i_p5_we_r        == REGFILE_WR_ACTIVE) &&
                 (fs2a             == i_p5_wba_r) ?
          i_p5_wbdata_r :
          s3p_qb; 

   //  Clock enables for the read ports.
   // 
   //  This turns off the RAM port when not in use to save power. Depending
   //  on technology this may cause time delays on the critical path. If this
   //  is the case and this is not acceptable, just don't connect these
   //  signals to the register file. If the flip-flop implementation of the 
   //  core register file is used then these signals are not used.
   // 
   //  The read ports of the RAM will be active on the next clock cycle if:
   // 
   //    1. a valid instruction is in pipe stage 1 and the ARC isn't stalled.
   //    2. the host will perform a read on the next clock cycle (this only
   //       applies to port A).
   //    3. a write is performed to the register file during the present
   //       clock cycle. This is to ensure that the outputs of the read ports
   //       will be updated with the latest content of the address it is
   //       reading.
   //    4. the ARC is in test mode (test_mode = '1')
   //
   assign ck_en_a = (p2iv             == 1'b 1) &&
                    (en2              == 1'b 1) ||
                    (i_we_a           == REGFILE_WR_ACTIVE) ||
                    (i_p5_we_r        == REGFILE_WR_ACTIVE) ||
                    (test_mode == 1'b 1) ?
          REGFILE_CK_EN_ACTIVE : 
          (~REGFILE_CK_EN_ACTIVE); 

   assign ck_en_b = (p2iv             == 1'b 1) &&
                    (en2              == 1'b 1) || 
                    (cr_hostr         == 1'b 1) ||
                    (i_we_a           == REGFILE_WR_ACTIVE) ||
                    (i_p5_we_r        == REGFILE_WR_ACTIVE) ||
                    (test_mode        == 1'b 1) ?
          REGFILE_CK_EN_ACTIVE : 
          (~REGFILE_CK_EN_ACTIVE); 


//----------------------------------------------------------------------- 

   //  Outputs to the 4-port RAM
   // 
   assign s3p_aw  = i_aw_a; 
   assign s3p_ara = i_rega_a; 
   assign s3p_arb = i_regb_a; 
   assign s3p_we  = i_we_a; 

endmodule // module sync_regs

