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
// This wrap file contains the core register memory. The memory is 
// implemented as either a RAM or as flip-flops depending on the 
// selected ARChitect configuration (for more info read the comments in
// conjunction with the memory instantiation at the end of this file).
//                
// The instantiated memory is a synchronous 32x32 three-port RAM, with
// writethrough. On the rising (active) clock edge, the three 
// addresses, write data and the write control signal are latched in. 
// Data appears on the outputs some time later. Write-through reads 
// have longer access times.
//
//======================= Inputs to this block =======================--
// 
//  clk              Rising-edge master clock.
// 
//  ck_en_a          Clock enable - Port A
//  ck_en_b          Clock enable - Port B
//  ck_en_w          Clock enable - Write Port
//  s3p_we           Active-high write enable
//  s3p_aw[4:0]      Write address
//  s3p_ara[4:0]     Read address - Port A
//  s3p_arb[4:0]     Read address - Port B
//  wbdata[31:0]     Write data in
//
//====================== Output from this block ======================--
//
//  s3p_qa[31:0]     Read data    - Port A
//  s3p_qb[31:0]     Read data    - Port B
//
//====================================================================--
//

module regfile_3p_wrap (clk,
                        s3p_aw,
                        s3p_ara,
                        s3p_arb,
                        wbdata,
                        s3p_we,
                        ck_en_w,
                        ck_en_a,
                        ck_en_b,

                        s3p_qa,
                        s3p_qb);

`include "arcutil.v"

input   clk; 
input   [4:0] s3p_aw; 
input   [4:0] s3p_ara; 
input   [4:0] s3p_arb; 
input   [31:0] wbdata; 
input   s3p_we; 
input   ck_en_w; 
input   ck_en_a; 
input   ck_en_b; 

output  [31:0] s3p_qa; 
output  [31:0] s3p_qb; 

wire    [31:0] s3p_qa; 
wire    [31:0] s3p_qb; 

wire    [4:0] i_address_a; 
wire    [4:0] i_address_b; 
wire    [4:0] i_address_w; 

wire    [31:0] i_wr_data; 
wire    [31:0] i_rd_data_a; 
wire    [31:0] i_rd_data_b; 

`ifdef FAKE_RAMS
`else
wire        [4:0] i_raddr_a;
wire        [4:0] i_raddr_b;
wire        [4:0] i_raddr_w;
reg        i_zero_a;
reg        i_zero_b;
`endif

`ifdef FAKE_RAMS
`else
// Store top bit of translated address
// - used to provide zero result for non-existent registers
// 
always @(posedge clk)
 begin : zero_proc
   i_zero_a <= i_raddr_a[4];
   i_zero_b <= i_raddr_b[4];
 end

// For FPGA builds, to avoid conflicts, avoid having the RD and WR addresses being the same.
assign i_raddr_a = rf_addr(s3p_ara);
assign i_raddr_b = rf_addr(s3p_arb);
assign i_raddr_w = rf_addr(s3p_aw);
assign i_address_a = (i_raddr_a[3:0] == i_raddr_w[3:0] && s3p_we == 1'b1) ? (i_raddr_w[3:0] + 1'b1) : i_raddr_a[3:0];
assign i_address_b = (i_raddr_b[3:0] == i_raddr_w[3:0] && s3p_we == 1'b1) ? (i_raddr_w[3:0] + 1'b1) : i_raddr_b[3:0];
assign i_address_w = i_raddr_w[3:0];
`endif

assign i_wr_data = wbdata; 

`ifdef FAKE_RAMS
assign s3p_qa = i_rd_data_a; 
assign s3p_qb = i_rd_data_b; 
`else
assign s3p_qa      = i_zero_a == 1'b1 ? 32'h00000000 : i_rd_data_a; 
assign s3p_qb      = i_zero_b == 1'b1 ? 32'h00000000 : i_rd_data_b; 
`endif

//  Memory instantiation
// 
//  This is memory is implemented using flip-flops. It can be used 
//  both for synthesis and simulation. It can be replaced with a 
//  vendor specific RAM.
// 
//  In the ARChitect configuration tool you can select different 
//  implementations of the core register file. Depending on the 
//  selected type of core register this instantiated memory is used 
//  differently:
// 
//   [1] If a 3 port flip-flop implementation is selected then this
//       module is synthesised.
// 
//   [2] If a 3 port RAM cell implementation is selected then this
//       module is not synthesised. Instead the zero-area RAM model 
//       (with the same name as this module, i.e. regfile_3p) in 
//       arc_rams.db is used.
// 
//  This module is only used for 3-port core register files. It is 
//  always used as a simulation model independently of whether a 
//  3 port flip-flop implementation or a RAM cell has been selected.
// 
//  Note that if a 3 port RAM cell has been selected the RAM model
//  used will have:
// 
//       * No capacitance
//       * Infinite drive capacity
// 
//   ..and writethrough is not modelled in the Synopsys timing model.
// 
//  and hence timings should be taken with a pinch of salt.
// 
//  The clock enables signals turns off the RAM ports when not in use
//  to save power. Depending on technology this may cause time delays
//  on the critical path. If this is the case and this is not 
//  acceptable, just don't connect these signal to the instantiation
//  of the real RAM.
// 
//  If the clock enables and write enables of the vendor RAM are not 
//  active low as they are for for this model, do not insert an 
//  inverter! Instead change the related constants in extutil.v.
//


regfile_3p U_regfile_3p (
          .clk(clk),
          .address_a(s3p_ara),
          .address_b(s3p_arb),
          .address_w(s3p_aw),
          .wr_data(i_wr_data),
          .we(s3p_we),
          .ck_en_w(ck_en_w),
          .ck_en_a(ck_en_a),
          .ck_en_b(ck_en_b),

          .rd_data_a(i_rd_data_a),
          .rd_data_b(i_rd_data_b));


endmodule

