// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 2004-2012 ARC International (Unpublished)
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
// This is the section of the JTAG port that runs on the core
// clock.
//
//======================= Inputs to this block =======================--
//
// clk_ungated      The ungated CPU clock, always running
//
// rst_a            The core reset signal
//
// do_bvci_cycle  From debug_port, and synchronous to jtag_tck. Any edge
//                signals a request for a BVCI transaction
//
// bvci_addr_r      From debug_port, synchronous to jtag_tck. The variable
//                portion of the BVCI address
//
// bvci_cmd_r       From debug_port, synchronous to jtag_tck. The BVCI
//                command
//
//====================== Output from this block ======================--
//
// debug_address  The BVCI address to the core's debug port
//
// debug_cmd      The BVCI command to the core's debug port
//
// debug_cmdval   The BVCI command-valid signal.
//
//====================================================================--
//

module sys_clk_sync(
  clk_ungated,
  rst_a,
  test_mode,
  do_bvci_cycle,
  bvci_addr_r,
  bvci_cmd_r,

  debug_address,
  debug_cmd,
  debug_cmdval
);

`include "extutil.v"

  input                       clk_ungated;
  input                       rst_a;
  input                       test_mode;
  input                       do_bvci_cycle;
  input  [`ADDR_SIZE - 1 : 2] bvci_addr_r;
  input  [1 : 0]              bvci_cmd_r;
  output [31 : 0]             debug_address;
  output [1 : 0]              debug_cmd;
  output                      debug_cmdval;

  wire   [31 : 0]             debug_address;
  wire   [1 : 0]              debug_cmd;
  wire                        debug_cmdval;

  reg    [`ADDR_SIZE - 1 : 2] i_bvci_addr_synchro_r;
  reg    [`ADDR_SIZE - 1 : 2] i_bvci_addr_r1_r;
  reg    [1 : 0]              i_bvci_cmd_synchro_r;
  reg    [1 : 0]              i_bvci_cmd_r1_r;
  reg                         i_rq_r1_r;
  reg                         i_rq_r2_r;
  reg                         i_rq_synchro_r;
  reg                         i_rst_mask_r3_r;
  reg                         i_rst_mask_r2_r;
  reg                         i_rst_mask_r1_r;
  
  //  This process implements a very restricted BVCI initiator. It is
  //  designed only to connect to the BVCI target in the ARC 600 / 700 debug
  //  port, which responds in a single cycle and has cmdack tied true. It
  //  gets a command via the do_bvci_cycle signal, which is generated on
  //  the JTAG clock. That signal gets double-synchronized, and the leading
  //  edge of the result is put out as cmdval.
  //
  //  Nota bene: We need to be able to generate BVCI cycles on consecutive
  //  cycles of the JTAG clock. In order to do this without logic asynchronous
  //  to that clock, the signal do_bvci_cycle is edge-signaling rather than
  //  level- signaling. That is, *any* edge will cause a BVCI cycle to be
  //  initiated.
  always @(posedge clk_ungated or posedge rst_a)
  begin : POSEDGE_SYNC_PROC
    if (rst_a == 1'b1)
    begin
      i_rq_r2_r        <= 1'b0;
      i_rq_r1_r        <= 1'b0;
      i_rq_synchro_r   <= 1'b0;
      i_rst_mask_r3_r  <= 1'b1;
      i_rst_mask_r2_r  <= 1'b1;
      i_rst_mask_r1_r  <= 1'b1;
      i_bvci_addr_r1_r <= { `ADDR_SIZE - 2 { 1'b0 }};
      i_bvci_cmd_r1_r  <= 2'b00;
    end

    else
    begin
      i_rq_r2_r        <= i_rq_r1_r;             // For the edge detector
      i_rq_r1_r        <= i_rq_synchro_r;        // Form the double synchronizer
      i_rq_synchro_r   <= do_bvci_cycle;
      i_rst_mask_r3_r  <= i_rst_mask_r2_r;
      i_rst_mask_r2_r  <= i_rst_mask_r1_r;
      i_rst_mask_r1_r  <= 1'b0;
      i_bvci_addr_r1_r <= i_bvci_addr_synchro_r; // Just a delay
      i_bvci_cmd_r1_r  <= i_bvci_cmd_synchro_r;
    end
  end

  // This capturing of the address and command on the negative edge is done
  // to guarantee that if the edges of the JTAG clock and core clock
  // happen to align, the BVCI interface won't see the command and data
  // from the wrong cycle. The reason this works is somewhat subtle.
  // Because do_bvci_cycle and the address/command combo are being captured
  // on different clock edges, they cannot go metastable at the same time.
  // If this stage goes metastable, because address, command, and
  // do_bvci_cycle are changing when the core clock is falling, then this
  // stage will be invalid, but the capture of do_bvci_cycle will happen
  // half a cycle later and will be valid. Call this negative edge t0. Then
  // do_bvci_cycle will be captured cleanly at t0.5, and cmdval will be
  // true from t1.5-t2.5. The output of these flops is metastable, so it
  // may be wrong when it's captured by the next rank above at t0.5. But
  // the fact that we require the JTAG clock to be no faster than 1/2 the
  // core clock speed means that it won't change again until t2, and will
  // be captured cleanly at t1. This in turn means that the second rank of
  // flops above will present clean data to the BVCI interface from
  // t1.5-t2.5, at the same time as cmdval. For a more thorough analysis, see
  // the ARC 600/ARC 700 JTAG Port Implementation Reference
  //.

wire clk_ungated_n;
assign clk_ungated_n = (test_mode) ? clk_ungated : ~clk_ungated;

//  leda NTL_CLK03 off
  always @(posedge clk_ungated_n or posedge rst_a)
  begin : NEGEDGE_SYNC_PROC
    if (rst_a == 1'b1)
    begin
      i_bvci_addr_synchro_r <= { `ADDR_SIZE - 2 { 1'b0 }};
      i_bvci_cmd_synchro_r  <= 2'b00;
    end

    else
    begin
      i_bvci_addr_synchro_r <= bvci_addr_r;
      i_bvci_cmd_synchro_r  <= bvci_cmd_r;
    end
  end
//  leda NTL_CLK03 on
  // This violation of the normal standard, which specifies that all the
  // outputs from a module must be latched, is done to eliminate the extra
  // cycle required on a transaction across the BVCI bus. This seems
  // a compelling reason to add one level of gating to this path. It is
  // read in synchronous circuitry on the other side of the interface.
  //
  // Note: Edge-detect the request.
  //
  assign debug_cmdval   = (i_rq_r2_r != i_rq_r1_r) &
                          (i_rst_mask_r3_r != 1'b1); 

  // Drive the outputs. The fixed parts of the address are added here.
  //
  assign debug_cmd      = i_bvci_cmd_r1_r;
  assign debug_address  = { `BASE_ADDR, i_bvci_addr_r1_r, 2'b00 };

endmodule // module sys_clk_sync
