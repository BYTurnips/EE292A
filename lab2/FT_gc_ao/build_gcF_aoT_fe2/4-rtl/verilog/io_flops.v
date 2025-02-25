// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 1999-2012 ARC International (Unpublished)
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
// This file contains the latches for incoming external signals, like
// clear and interrupt.These are all supplied by external logic which
// ensures that all metastable states have been removed. These signals
// are only implemented as part of the ARCAngel or Generic system build.
// 
//======================= Inputs to this block =======================
//
// clk_ungated    Core Clock (Not Gated)
// rst_n_a        Global Reset (active low)
// xirq_n[]       External Interrupts (if present)
// testmode       Test mode signal for scan operation
// wd_clear       Watch dog reset from a timer
//
//====================== Output from this block ======================
//
// rst_a          Registered and synchronized external reset signal
// l_irq[7:5]     Latched external interrupts (if present)
//
//====================================================================
//
module io_flops (
	clk_ungated,
	rst_n_a,
	en,
	rst_a,
	wd_clear,
	ctrl_cpu_start_sync_r,
	ctrl_cpu_start,

// Signals required for the interrupts
xirq_n_4,
xirq_n_5,
xirq_n_6,
xirq_n_7,
xirq_n_8,
xirq_n_9,
xirq_n_10,
xirq_n_11,
xirq_n_12,
xirq_n_13,
xirq_n_14,
xirq_n_15,
xirq_n_16,
xirq_n_17,
xirq_n_18,
xirq_n_19,
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

   jtag_tck,
   jtag_trst_n,
   jtag_trst_a,
	test_mode);

input  clk_ungated; 
input  rst_n_a;
input  en;
input  test_mode;
input  ctrl_cpu_start;


// Signals required for the interrupts
input xirq_n_4;
input xirq_n_5;
input xirq_n_6;
input xirq_n_7;
input xirq_n_8;
input xirq_n_9;
input xirq_n_10;
input xirq_n_11;
input xirq_n_12;
input xirq_n_13;
input xirq_n_14;
input xirq_n_15;
input xirq_n_16;
input xirq_n_17;
input xirq_n_18;
input xirq_n_19;
output l_irq_4;
output l_irq_5;
output l_irq_6;
output l_irq_7;
output l_irq_8;
output l_irq_9;
output l_irq_10;
output l_irq_11;
output l_irq_12;
output l_irq_13;
output l_irq_14;
output l_irq_15;
output l_irq_16;
output l_irq_17;
output l_irq_18;
output l_irq_19;

input  jtag_tck;
input  jtag_trst_n;
output jtag_trst_a;
wire   jtag_trst_a;
output ctrl_cpu_start_sync_r; 
output rst_a;  
wire   rst_a; 
input  wd_clear;


// Signals required for the interrupts
reg l_irq_4;
reg l_irq_5;
reg l_irq_6;
reg l_irq_7;
reg l_irq_8;
reg l_irq_9;
reg l_irq_10;
reg l_irq_11;
reg l_irq_12;
reg l_irq_13;
reg l_irq_14;
reg l_irq_15;
reg l_irq_16;
reg l_irq_17;
reg l_irq_18;
reg l_irq_19;


reg   i_jtag_trst_synchro_r;
reg   i_jtag_trst_r1;

wire  i_rst_a; 

reg   ctrl_cpu_start_sync_r;
reg   i_start_synchro_r;

// Double flop the 'external start' signal to prevent metastability.
//
always @(posedge clk_ungated or posedge i_rst_a)
begin : ctrl_cpu_start_meta_PROC
  if (i_rst_a == 1'b1)
  begin
    i_start_synchro_r  <= 1'b0;
    ctrl_cpu_start_sync_r <= 1'b0;
  end
  else
  begin
    i_start_synchro_r  <= ctrl_cpu_start;
    ctrl_cpu_start_sync_r <= i_start_synchro_r;
  end
end

// The reset is clocked by the core clock and is asynchronously applied 
// and synchronously removed (double register synchronization)
// 
reg   i_rst_r1;         // dual sync FFs
reg   i_rst_synchro_r;

always @(posedge clk_ungated or negedge rst_n_a)
  begin : ext_clear_PROC
  if (rst_n_a == 1'b 0)
    begin
    i_rst_synchro_r <= 1'b 1;
    i_rst_r1      <= 1'b 1;        
    end
  else if (wd_clear == 1'b 1)
    begin
    i_rst_synchro_r <= 1'b 1;
    i_rst_r1      <= 1'b 1;
    end
  else
    begin
    i_rst_synchro_r <= 1'b 0;
    i_rst_r1      <= i_rst_synchro_r;        
    end
  end
assign i_rst_a = (test_mode == 1'b 1) ? ~rst_n_a : i_rst_r1;


assign rst_a   = 0 
            | i_rst_a;

// -------------------------------------------------------------------------
// External interrupt signals
// 
// Latch and invert external IRQ signals since the external interrupts
// active low, but the ARC services active high interrupts. It is clocked
// by the ungated clock.
// 
// -------------------------------------------------------------------------

always @(posedge clk_ungated or posedge i_rst_a)
  begin : ext_interrupt_PROC
  if (i_rst_a == 1'b 1)
     begin
		l_irq_4 <= 1'b 0;
		l_irq_5 <= 1'b 0;
		l_irq_6 <= 1'b 0;
		l_irq_7 <= 1'b 0;
		l_irq_8 <= 1'b 0;
		l_irq_9 <= 1'b 0;
		l_irq_10 <= 1'b 0;
		l_irq_11 <= 1'b 0;
		l_irq_12 <= 1'b 0;
		l_irq_13 <= 1'b 0;
		l_irq_14 <= 1'b 0;
		l_irq_15 <= 1'b 0;
		l_irq_16 <= 1'b 0;
		l_irq_17 <= 1'b 0;
		l_irq_18 <= 1'b 0;
		l_irq_19 <= 1'b 0;
    end
 else
    begin
		l_irq_4 <= ~xirq_n_4;
		l_irq_5 <= ~xirq_n_5;
		l_irq_6 <= ~xirq_n_6;
		l_irq_7 <= ~xirq_n_7;
		l_irq_8 <= ~xirq_n_8;
		l_irq_9 <= ~xirq_n_9;
		l_irq_10 <= ~xirq_n_10;
		l_irq_11 <= ~xirq_n_11;
		l_irq_12 <= ~xirq_n_12;
		l_irq_13 <= ~xirq_n_13;
		l_irq_14 <= ~xirq_n_14;
		l_irq_15 <= ~xirq_n_15;
		l_irq_16 <= ~xirq_n_16;
		l_irq_17 <= ~xirq_n_17;
		l_irq_18 <= ~xirq_n_18;
		l_irq_19 <= ~xirq_n_19;
     end
  end

// This process synchronizes the removal of the JTAG reset. It might go
// metastable because the external reset can be removed in any relationship to
// the clock, so it's resynchronized here.
always @(posedge jtag_tck or negedge jtag_trst_n)
  begin : JTAG_CLEAR_PROC
    if (jtag_trst_n == 1'b 0)
    begin
      i_jtag_trst_synchro_r <= 1'b 1;
      i_jtag_trst_r1      <= 1'b 1;
    end
    else
    begin
      i_jtag_trst_synchro_r <= 1'b 0;
      i_jtag_trst_r1      <= i_jtag_trst_synchro_r;
    end
  end

assign jtag_trst_a = test_mode==1'b 1 ? ~jtag_trst_n : i_jtag_trst_r1;


endmodule // module io_flops

