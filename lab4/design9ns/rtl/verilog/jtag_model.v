// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 1998-2012 ARC International (Unpublished)
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
// JTAG PC Model that talks to the JTAG Interface
// 
// This version of JTAG_MODEL is a structure for implementing an
// interface between RASCAL and the system JTAG port.
// 
module jtag_model (
`ifdef XCAM_TESTBENCH_COMPONENT
`else
`endif
   ejtag_tck,
   ejtag_tms,
   ejtag_tdi,
   ejtag_tdo,
   ejtag_trst_n,
`ifdef XCAM_TESTBENCH_COMPONENT
`else
`endif
   del_xck_x1,
   xxclr,
   xxirq_n_4,
   xxirq_n_5,
   xxirq_n_6,
   xxirq_n_7,
   xxirq_n_8,
   xxirq_n_9,
   xxirq_n_10,
   xxirq_n_11,
   xxirq_n_12,
   xxirq_n_13,
   xxirq_n_14,
   xxirq_n_15,
   xxirq_n_16,
   xxirq_n_17,
   xxirq_n_18,
   xxirq_n_19,

`ifdef XCAM_TESTBENCH_COMPONENT
`else
   xen,
   xsram_a,
   xsram_we_n,
   xsram_oe_n,
   xsram_d,
   xsram_wait_n,
   xsram_mrq_n,
   xsram_high_z,
   no_step_test,
   do_pc_test
`endif
   );

`include "arc600constants.v"                  
`include "ext_msb.v"
`ifdef TTVTOC
`include "arcutil_pkg_defines.v"
`include "extutil.v"
`include "jtag_defs.v"
`endif

`ifdef XCAM_TESTBENCH_COMPONENT
`else
`endif
input  ejtag_tdo;
output  ejtag_tdi; 
wire    ejtag_tdi; 
input   ejtag_trst_n;

//  JTAG interface signals
// 
output  ejtag_tck; 
output  ejtag_tms; 

`ifdef XCAM_TESTBENCH_COMPONENT
`else
//  Busy signal from the JTAG port
//  (for ARCAngel systems)
// 

`endif // XCAM_TESTBENCH_COMPONENT
input   del_xck_x1; 
input   xxclr; 
output xxirq_n_4;
output xxirq_n_5;
output xxirq_n_6;
output xxirq_n_7;
output xxirq_n_8;
output xxirq_n_9;
output xxirq_n_10;
output xxirq_n_11;
output xxirq_n_12;
output xxirq_n_13;
output xxirq_n_14;
output xxirq_n_15;
output xxirq_n_16;
output xxirq_n_17;
output xxirq_n_18;
output xxirq_n_19;

`ifdef XCAM_TESTBENCH_COMPONENT
`else
input   xen; 
inout   [EXT_A_MSB:2] xsram_a;
inout   [3:0] xsram_we_n; 
inout   xsram_oe_n; 
inout   [31:0] xsram_d; 
output  xsram_wait_n; 
output  xsram_mrq_n; 
input   xsram_high_z; 

// Verification options
//
input   no_step_test; 
input   do_pc_test; 
`endif // XCAM_TESTBENCH_COMPONENT

wire    [EXT_A_MSB:2] V_xsram_a; 
wire    [3:0] V_xsram_we_n; 
wire    V_xsram_oe_n; 
wire    [31:0] V_xsram_d; 
wire    ejtag_tck; 
wire    ejtag_tms; 

wire xxirq_n_4;
reg  i_xxirq_n_4_r;
reg  i_xxirq_n_4_d_r;
wire i_xxirq_n_4;
wire xxirq_n_5;
reg  i_xxirq_n_5_r;
reg  i_xxirq_n_5_d_r;
wire i_xxirq_n_5;
wire xxirq_n_6;
reg  i_xxirq_n_6_r;
reg  i_xxirq_n_6_d_r;
wire i_xxirq_n_6;
wire xxirq_n_7;
reg  i_xxirq_n_7_r;
reg  i_xxirq_n_7_d_r;
wire i_xxirq_n_7;
wire xxirq_n_8;
reg  i_xxirq_n_8_r;
reg  i_xxirq_n_8_d_r;
wire i_xxirq_n_8;
wire xxirq_n_9;
reg  i_xxirq_n_9_r;
reg  i_xxirq_n_9_d_r;
wire i_xxirq_n_9;
wire xxirq_n_10;
reg  i_xxirq_n_10_r;
reg  i_xxirq_n_10_d_r;
wire i_xxirq_n_10;
wire xxirq_n_11;
reg  i_xxirq_n_11_r;
reg  i_xxirq_n_11_d_r;
wire i_xxirq_n_11;
wire xxirq_n_12;
reg  i_xxirq_n_12_r;
reg  i_xxirq_n_12_d_r;
wire i_xxirq_n_12;
wire xxirq_n_13;
reg  i_xxirq_n_13_r;
reg  i_xxirq_n_13_d_r;
wire i_xxirq_n_13;
wire xxirq_n_14;
reg  i_xxirq_n_14_r;
reg  i_xxirq_n_14_d_r;
wire i_xxirq_n_14;
wire xxirq_n_15;
reg  i_xxirq_n_15_r;
reg  i_xxirq_n_15_d_r;
wire i_xxirq_n_15;
wire xxirq_n_16;
reg  i_xxirq_n_16_r;
reg  i_xxirq_n_16_d_r;
wire i_xxirq_n_16;
wire xxirq_n_17;
reg  i_xxirq_n_17_r;
reg  i_xxirq_n_17_d_r;
wire i_xxirq_n_17;
wire xxirq_n_18;
reg  i_xxirq_n_18_r;
reg  i_xxirq_n_18_d_r;
wire i_xxirq_n_18;
wire xxirq_n_19;
reg  i_xxirq_n_19_r;
reg  i_xxirq_n_19_d_r;
wire i_xxirq_n_19;
wire    [EXT_A_MSB:2] xsram_a; 
wire    [3:0] xsram_we_n; 
wire    xsram_oe_n; 
wire    [31:0] xsram_d; 
wire    xsram_wait_n; 
wire    xsram_mrq_n; 
wire    ra_ck; 
wire    ra_ack; 
wire    [31:0] ra_rd_data; 
wire    [1:0] ra_fail; 

wire    [1:0] ra_select; 
wire    ra_read; 
wire    ra_write; 
wire    [9:0] ra_burst; 
wire    [31:0] ra_addr; 
wire    [31:0] ra_wr_data; 

//  Drive the signals not required for RASCAL implementation


always @(posedge del_xck_x1 or negedge xxclr)
begin
        if (xxclr == 1'b0)
        begin
        i_xxirq_n_4_r <= 1'b1; i_xxirq_n_4_d_r <= 1'b0;
        i_xxirq_n_5_r <= 1'b1; i_xxirq_n_5_d_r <= 1'b0;
        i_xxirq_n_6_r <= 1'b1; i_xxirq_n_6_d_r <= 1'b0;
        i_xxirq_n_7_r <= 1'b1; i_xxirq_n_7_d_r <= 1'b0;
        i_xxirq_n_8_r <= 1'b1; i_xxirq_n_8_d_r <= 1'b0;
        i_xxirq_n_9_r <= 1'b1; i_xxirq_n_9_d_r <= 1'b0;
        i_xxirq_n_10_r <= 1'b1; i_xxirq_n_10_d_r <= 1'b0;
        i_xxirq_n_11_r <= 1'b1; i_xxirq_n_11_d_r <= 1'b0;
        i_xxirq_n_12_r <= 1'b1; i_xxirq_n_12_d_r <= 1'b0;
        i_xxirq_n_13_r <= 1'b1; i_xxirq_n_13_d_r <= 1'b0;
        i_xxirq_n_14_r <= 1'b1; i_xxirq_n_14_d_r <= 1'b0;
        i_xxirq_n_15_r <= 1'b1; i_xxirq_n_15_d_r <= 1'b0;
        i_xxirq_n_16_r <= 1'b1; i_xxirq_n_16_d_r <= 1'b0;
        i_xxirq_n_17_r <= 1'b1; i_xxirq_n_17_d_r <= 1'b0;
        i_xxirq_n_18_r <= 1'b1; i_xxirq_n_18_d_r <= 1'b0;
        i_xxirq_n_19_r <= 1'b1; i_xxirq_n_19_d_r <= 1'b0;
        end
        else 
        begin
        i_xxirq_n_4_r   <= i_xxirq_n_4; 
	i_xxirq_n_4_d_r <= i_xxirq_n_4_r;
        i_xxirq_n_5_r   <= i_xxirq_n_5; 
	i_xxirq_n_5_d_r <= i_xxirq_n_5_r;
        i_xxirq_n_6_r   <= i_xxirq_n_6; 
	i_xxirq_n_6_d_r <= i_xxirq_n_6_r;
        i_xxirq_n_7_r   <= i_xxirq_n_7; 
	i_xxirq_n_7_d_r <= i_xxirq_n_7_r;
        i_xxirq_n_8_r   <= i_xxirq_n_8; 
	i_xxirq_n_8_d_r <= i_xxirq_n_8_r;
        i_xxirq_n_9_r   <= i_xxirq_n_9; 
	i_xxirq_n_9_d_r <= i_xxirq_n_9_r;
        i_xxirq_n_10_r   <= i_xxirq_n_10; 
	i_xxirq_n_10_d_r <= i_xxirq_n_10_r;
        i_xxirq_n_11_r   <= i_xxirq_n_11; 
	i_xxirq_n_11_d_r <= i_xxirq_n_11_r;
        i_xxirq_n_12_r   <= i_xxirq_n_12; 
	i_xxirq_n_12_d_r <= i_xxirq_n_12_r;
        i_xxirq_n_13_r   <= i_xxirq_n_13; 
	i_xxirq_n_13_d_r <= i_xxirq_n_13_r;
        i_xxirq_n_14_r   <= i_xxirq_n_14; 
	i_xxirq_n_14_d_r <= i_xxirq_n_14_r;
        i_xxirq_n_15_r   <= i_xxirq_n_15; 
	i_xxirq_n_15_d_r <= i_xxirq_n_15_r;
        i_xxirq_n_16_r   <= i_xxirq_n_16; 
	i_xxirq_n_16_d_r <= i_xxirq_n_16_r;
        i_xxirq_n_17_r   <= i_xxirq_n_17; 
	i_xxirq_n_17_d_r <= i_xxirq_n_17_r;
        i_xxirq_n_18_r   <= i_xxirq_n_18; 
	i_xxirq_n_18_d_r <= i_xxirq_n_18_r;
        i_xxirq_n_19_r   <= i_xxirq_n_19; 
	i_xxirq_n_19_d_r <= i_xxirq_n_19_r;
        end

end

`define PULSE  1'b 1
`define LEVEL  1'b 0
parameter IRQ_TYPE_PULSE = `PULSE;
parameter IRQ_TYPE_LEVEL = `LEVEL;
// example: assign xxirq_n_3 = (IRQ3_TYPE==IRQ_TYPE_PULSE)? (~(~i_xxirq_n_3_r & i_xxirq_n_3_d_r)) : i_xxirq_n_3_r;
assign xxirq_n_4 = (`LEVEL==IRQ_TYPE_PULSE)? (~(~i_xxirq_n_4_r & i_xxirq_n_4_d_r)) : i_xxirq_n_4_r;
assign xxirq_n_5 = (`LEVEL==IRQ_TYPE_PULSE)? (~(~i_xxirq_n_5_r & i_xxirq_n_5_d_r)) : i_xxirq_n_5_r;
assign xxirq_n_6 = (`LEVEL==IRQ_TYPE_PULSE)? (~(~i_xxirq_n_6_r & i_xxirq_n_6_d_r)) : i_xxirq_n_6_r;
assign xxirq_n_7 = (`LEVEL==IRQ_TYPE_PULSE)? (~(~i_xxirq_n_7_r & i_xxirq_n_7_d_r)) : i_xxirq_n_7_r;
assign xxirq_n_8 = (`LEVEL==IRQ_TYPE_PULSE)? (~(~i_xxirq_n_8_r & i_xxirq_n_8_d_r)) : i_xxirq_n_8_r;
assign xxirq_n_9 = (`LEVEL==IRQ_TYPE_PULSE)? (~(~i_xxirq_n_9_r & i_xxirq_n_9_d_r)) : i_xxirq_n_9_r;
assign xxirq_n_10 = (`LEVEL==IRQ_TYPE_PULSE)? (~(~i_xxirq_n_10_r & i_xxirq_n_10_d_r)) : i_xxirq_n_10_r;
assign xxirq_n_11 = (`LEVEL==IRQ_TYPE_PULSE)? (~(~i_xxirq_n_11_r & i_xxirq_n_11_d_r)) : i_xxirq_n_11_r;
assign xxirq_n_12 = (`LEVEL==IRQ_TYPE_PULSE)? (~(~i_xxirq_n_12_r & i_xxirq_n_12_d_r)) : i_xxirq_n_12_r;
assign xxirq_n_13 = (`LEVEL==IRQ_TYPE_PULSE)? (~(~i_xxirq_n_13_r & i_xxirq_n_13_d_r)) : i_xxirq_n_13_r;
assign xxirq_n_14 = (`LEVEL==IRQ_TYPE_PULSE)? (~(~i_xxirq_n_14_r & i_xxirq_n_14_d_r)) : i_xxirq_n_14_r;
assign xxirq_n_15 = (`LEVEL==IRQ_TYPE_PULSE)? (~(~i_xxirq_n_15_r & i_xxirq_n_15_d_r)) : i_xxirq_n_15_r;
assign xxirq_n_16 = (`LEVEL==IRQ_TYPE_PULSE)? (~(~i_xxirq_n_16_r & i_xxirq_n_16_d_r)) : i_xxirq_n_16_r;
assign xxirq_n_17 = (`LEVEL==IRQ_TYPE_PULSE)? (~(~i_xxirq_n_17_r & i_xxirq_n_17_d_r)) : i_xxirq_n_17_r;
assign xxirq_n_18 = (`LEVEL==IRQ_TYPE_PULSE)? (~(~i_xxirq_n_18_r & i_xxirq_n_18_d_r)) : i_xxirq_n_18_r;
assign xxirq_n_19 = (`LEVEL==IRQ_TYPE_PULSE)? (~(~i_xxirq_n_19_r & i_xxirq_n_19_d_r)) : i_xxirq_n_19_r;

assign xsram_a = {(EXT_A_MSB - 1){1'b z}}; 
assign xsram_we_n = {4{1'b z}}; 
assign xsram_oe_n = 1'b Z; 
assign xsram_d = {32{1'b z}}; 
assign xsram_wait_n = 1'b 1; 
assign xsram_mrq_n = 1'b 1; 



`ifdef TTVTOC

reg [63:0]jtag_task_data;
reg [31:0]interrupts;

initial interrupts = {32{1'b1}};

initial
    $vtoc_jtag_task_init(jtag_task_data,
               32'b0, // RESET_ACTIVE
               `JTAG_STATUS_REG_LEN,
               `JTAG_STATUS_REG_INIT,
               `JTAG_IDCODE_REG_LEN,
               `JTAG_IDCODE_REG_INIT,
               {`JTAG_IDCODE_REG_LEN{1'b1}},
//!Multicpu not supported.
(32'b1 <<  4) |
(32'b1 <<  5) |
(32'b1 <<  6) |
(32'b1 <<  7) |
(32'b1 <<  8) |
(32'b1 <<  9) |
(32'b1 <<  10) |
(32'b1 <<  11) |
(32'b1 <<  12) |
(32'b1 <<  13) |
(32'b1 <<  14) |
(32'b1 <<  15) |
(32'b1 <<  16) |
(32'b1 <<  17) |
(32'b1 <<  18) |
(32'b1 <<  19) |
               32'b0  // Interrupts connected
               );

always @(posedge del_xck_x1)
    $vtoc_jtag_task(jtag_task_data,
               xxclr,
               ejtag_tdo,
               ejtag_trst_n,
               ejtag_tck,
               ejtag_tms,
               ejtag_tdi,
               interrupts);

//!Multi_cpu not supported here.
assign i_xxirq_n_4  = interrupts[4]; 
assign i_xxirq_n_5  = interrupts[5]; 
assign i_xxirq_n_6  = interrupts[6]; 
assign i_xxirq_n_7  = interrupts[7]; 
assign i_xxirq_n_8  = interrupts[8]; 
assign i_xxirq_n_9  = interrupts[9]; 
assign i_xxirq_n_10  = interrupts[10]; 
assign i_xxirq_n_11  = interrupts[11]; 
assign i_xxirq_n_12  = interrupts[12]; 
assign i_xxirq_n_13  = interrupts[13]; 
assign i_xxirq_n_14  = interrupts[14]; 
assign i_xxirq_n_15  = interrupts[15]; 
assign i_xxirq_n_16  = interrupts[16]; 
assign i_xxirq_n_17  = interrupts[17]; 
assign i_xxirq_n_18  = interrupts[18]; 
assign i_xxirq_n_19  = interrupts[19]; 

`else

rascal irascal (.ra_ck(ra_ck),
          .ra_ack(ra_ack),
          .ra_rd_data(ra_rd_data),
          .ra_fail(ra_fail),
          .ra_select(ra_select),
          .ra_read(ra_read),
          .ra_write(ra_write),
          .ra_burst(ra_burst),
          .ra_addr(ra_addr),
          .ra_wr_data(ra_wr_data));

`define parms 

`define name_reset rst_a
`define name_tck ejtag_tck
`define name_tms ejtag_tms
`define name_tdi ejtag_tdi
`define name_tdo ejtag_tdo
`define name_trst_n ejtag_trst_n

rascal2jtag `parms irascal2jtag (        
          .`name_reset(xxclr),
          .`name_tck(ejtag_tck),
          .`name_tms(ejtag_tms),
          .`name_tdi(ejtag_tdi),
          .`name_tdo(ejtag_tdo),
          .`name_trst_n(ejtag_trst_n),
	  .xxirq_n_4(i_xxirq_n_4), 
	  .xxirq_n_5(i_xxirq_n_5), 
	  .xxirq_n_6(i_xxirq_n_6), 
	  .xxirq_n_7(i_xxirq_n_7), 
	  .xxirq_n_8(i_xxirq_n_8), 
	  .xxirq_n_9(i_xxirq_n_9), 
	  .xxirq_n_10(i_xxirq_n_10), 
	  .xxirq_n_11(i_xxirq_n_11), 
	  .xxirq_n_12(i_xxirq_n_12), 
	  .xxirq_n_13(i_xxirq_n_13), 
	  .xxirq_n_14(i_xxirq_n_14), 
	  .xxirq_n_15(i_xxirq_n_15), 
	  .xxirq_n_16(i_xxirq_n_16), 
	  .xxirq_n_17(i_xxirq_n_17), 
	  .xxirq_n_18(i_xxirq_n_18), 
	  .xxirq_n_19(i_xxirq_n_19), 
          .ra_select(ra_select),
          .ra_read(ra_read),
          .ra_write(ra_write),
          .ra_burst(ra_burst),
          .ra_addr(ra_addr),
          .ra_wr_data(ra_wr_data),
          .ra_ck(ra_ck),
          .ra_ack(ra_ack),
          .ra_rd_data(ra_rd_data),
          .ra_fail(ra_fail));


`endif
`undef name_reset 
`undef name_tck 
`undef name_tms 
`undef name_tdi 
`undef name_tdo 
`undef name_trst_n 
`undef parms 

endmodule // module jtag_model
