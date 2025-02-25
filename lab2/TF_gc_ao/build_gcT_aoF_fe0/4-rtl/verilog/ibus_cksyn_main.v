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
module ibus_cksyn_main (
  clk_ungated,
  rst_a,
  toggle,
  sync
);

input         clk_ungated; 
input         rst_a; 
input         toggle; 
output        sync; 

wire          sync; 

//  ============================================================================
//  SIGNAL DECLARATIONS 
//  ============================================================================

reg           toggle_r; 
wire          edge_detect; 
reg    [1:0]  count_r; 
reg    [1:0]  ratio_r; 
wire          pulse_1; 
wire          pulse_2; 
wire          pulse_3; 
wire          pulse_4; 
reg           sec_last_ph; 
reg           mask_r0_r; 
reg           sync_mask_r; 
reg           sync_out_r; 

//  ============================================================================
//  ARCHITECTURE
//  ============================================================================

//  Edge Detect Logic ------------------------------------------------------

always @(posedge clk_ungated or posedge rst_a)
begin : EDGEDET_PROC
  if (rst_a == 1'b1)
  begin
     toggle_r <= 1'b0;   
  end
  else
  begin
     toggle_r <= toggle;   
  end
end

assign edge_detect = toggle_r ^ toggle; 

//  Phase Counter Logic ----------------------------------------------------

always @(posedge clk_ungated or posedge rst_a)
begin : PHCNT_PROC
  if (rst_a == 1'b1)
  begin
      count_r <= 2'b 00;   
  end
  else
  begin
    if (edge_detect == 1'b1)
    begin
      count_r <= 2'b 00;   
    end
    else
    begin
      count_r <= count_r + 1'b1;   
    end
  end
end

//  Startup mask Logic -----------------------------------------------------

always @(posedge clk_ungated or posedge rst_a)
begin : MASK_PROC
  if (rst_a == 1'b1)
  begin
    mask_r0_r   <= 1'b0;   
    sync_mask_r <= 1'b0;   
  end
  else
  begin
    if (edge_detect == 1'b1)
    begin
      mask_r0_r   <= 1'b1;   
      sync_mask_r <= mask_r0_r;   
    end
  end
end

//  Last Phase Detect Logic ------------------------------------------------

always @(posedge clk_ungated or posedge rst_a)
begin : PHDET_PROC
  if (rst_a == 1'b1)
  begin
    ratio_r    <= 2'b 00;   
    sync_out_r <= 1'b0;   
  end
  else
  begin
    if (edge_detect == 1'b1)
    begin
      ratio_r <= count_r;   
    end
    sync_out_r <= sec_last_ph & sync_mask_r;   
  end
end

assign pulse_1 = 1'b1; 
assign pulse_2 = (count_r == 2'b01)? 1'b1 : 1'b0; 
assign pulse_3 = (count_r == 2'b00)? 1'b1 : 1'b0; 
assign pulse_4 = pulse_2; 

always @(pulse_1 or pulse_2 or pulse_3 or pulse_4 or ratio_r)
  begin : PULSEL_PROC
  case (ratio_r)
    2'b00  : sec_last_ph = pulse_1;   
    2'b01  : sec_last_ph = pulse_2;   
    2'b10  : sec_last_ph = pulse_3;   
    2'b11  : sec_last_ph = pulse_4;   
    default;
  endcase
end

assign sync = sync_out_r; 

endmodule // module ibus_cksyn_main

