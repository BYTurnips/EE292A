// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 1996-2008 ARC International (Unpublished)
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
// AHB slave memory testbench:
//
// The AHB testbench connects to the island BVCI-to-AHB bridge
// and provides a simple AHB slave memory model. This allows
// ARCtests to be run on AHB systems. Note that ARC does not
// currently provide RTL for AHB decoder, arbiter or slave.
//
`include "arc600constants.v"
module ahb_slave_tb (
  xck_system,
  del_xck_system,
  xxclr,
  xhbusreq,
  xhtrans,
  xhaddr,
  xhwrite,
  xhburst,
  xhwdata,
  xhsize,
  xhlock,
  xhprot,
  xhclk,
  xhresetn,
  xhgrant,
  xhready,
  xhresp,
  xhrdata,
  xsram_a,
  xsram_d,
  xsram_we_n,
  xsram_oe_n
  );

// `include "arcutil_pkg_defines.v"
// `include "extutil.v"
`include "ext_msb.v"
`include "clock_defs.v"

input                xck_system;
input                del_xck_system;
input                xxclr;
input                xhbusreq;
input  [1:0]         xhtrans;
input  [31:0]        xhaddr;
input                xhwrite;
input  [2:0]         xhburst;
input  [31:0]        xhwdata;
input  [2:0]         xhsize;
input                xhlock;
input  [3:0]         xhprot;
input                xhclk;
output               xhresetn;
output               xhgrant;
output               xhready;
output [1:0]         xhresp;
output [31:0]        xhrdata;
inout  [EXT_A_MSB:2] xsram_a;
inout  [31:0]        xsram_d;
inout  [3:0]         xsram_we_n;
inout                xsram_oe_n;

wire                 xhclk;
wire                 xhgrant;
wire                 xhready;
wire   [1:0]         xhresp;
reg                  xhresetn;

wire   [3:0]         xhmaster;
wire   [15:0]        xhsplit;
wire                 xhsel;
wire                 xhmastlock;
wire   [31:0]        xhrdata;
wire   [EXT_A_MSB:2] xsram_a;
wire   [31:0]        xsram_d;
wire   [3:0]         xsram_we_n;
wire                 xsram_oe_n;

//  FSM states
//
parameter IDLE_STATE  = 3'b 000;
parameter START_STATE = 3'b 001;
parameter WRITE_STATE = 3'b 010;
parameter READ_STATE  = 3'b 011;
parameter BUSY_STATE  = 3'b 100;

// internal signals
//
reg         i_hgrant_r;
reg         i_hgrant_nxt;
reg         i_hgrant_a;
reg         i_hready_r;
reg         i_hready_nxt;
reg         i_hready_a;
reg  [1:0]  i_hresp_r;
reg  [1:0]  i_hresp_nxt;
reg  [31:0] i_haddr_r;
reg  [31:0] i_haddr_nxt;
reg  [2:0]  i_hsize_r;
reg  [2:0]  i_hsize_nxt;
reg  [2:0]  i_hburst_r;
reg  [2:0]  i_hburst_nxt;
reg  [2:0]  i_state_r;
reg  [2:0]  i_state_nxt;


reg  [EXT_A_MSB:2] i_xsram_a_r;
reg  [EXT_A_MSB:2] i_xsram_a_nxt;
reg  [31:0]          i_xsram_d_r;
reg                  i_xsram_oe_n_r;
reg                  i_xsram_oe_n_nxt;

wire [3:0] i_we_n_a;
wire       delayed_clk;
wire       w_strobe;
wire       i_xsram_d_high_a;

always @*
  begin
    if(i_state_r == WRITE_STATE)
    i_xsram_d_r = xhwdata;
    else
    i_xsram_d_r = 32'bz;
  end

always @*
  begin
    i_hsize_nxt  = xhsize;
  end

always @*
  begin
    i_haddr_nxt  = xhaddr;
  end
// synopsys_translate_off
// async part of FSM
//
always @(
  xhbusreq       or   // ahb inputs
  xhtrans        or
  xhaddr         or
  xhwrite        or
  xhburst        or
  xhwdata        or
  xhsize         or

  i_hready_r     or   // internal state
  i_hgrant_r     or
  i_hresp_r      or
  i_haddr_r      or
  i_hsize_r      or
  i_hburst_r     or

  i_xsram_a_r    or
  i_xsram_oe_n_r or

  i_state_r
        )

  begin : async_fsm_proc

  i_hgrant_nxt     = i_hgrant_r;
  i_hgrant_a       = 1'b0;
  i_hready_nxt     = i_hready_r;
  i_hready_a       = 1'b0;
  i_hresp_nxt      = i_hresp_r;
 //i_haddr_nxt      = i_haddr_r;
 //i_hsize_nxt      = i_hsize_r;
  i_hburst_nxt     = i_hburst_r;

  i_xsram_a_nxt    = i_xsram_a_r;
  i_xsram_oe_n_nxt = i_xsram_oe_n_r;

  i_state_nxt  = i_state_r;

  case (i_state_r)

    IDLE_STATE:
    begin
    if (xhbusreq == 1'b 1)
      begin
      i_hgrant_nxt = 1'b 1;
      i_hgrant_a   = 1'b 1;
      i_hready_nxt = 1'b 1;
      i_hready_a   = 1'b 1;
      i_hresp_nxt  = 2'b 00;
      i_state_nxt  = START_STATE;
      end
    else
      begin
      i_hgrant_nxt     = 1'b 0;
      i_hgrant_a       = 1'b 0;
      i_hready_nxt     = 1'b 0;
      i_hready_a       = 1'b 1;
      i_xsram_a_nxt    = 0;
      i_xsram_oe_n_nxt = 1'b 1;
      end
    end

    START_STATE:
    begin
    i_hgrant_a   = 1'b 1;
    i_hready_a   = 1'b 1;
    if (xhtrans[1] == 1'b 1)
      begin
      //i_haddr_nxt  = xhaddr;
      //i_hsize_nxt  = xhsize;
      i_hburst_nxt = xhburst;
      i_xsram_a_nxt    = xhaddr[EXT_A_MSB:2];
      if (xhwrite == 1'b 1)
        begin
        i_xsram_oe_n_nxt = 1'b 1;
        i_state_nxt = WRITE_STATE;
        end
      else
        begin
        i_xsram_oe_n_nxt = 1'b 0;
        i_state_nxt      = READ_STATE;
        end
      end
    end

    WRITE_STATE:
    begin
    i_hgrant_a       = 1'b 1;
    i_hready_a       = 1'b 1;
    i_xsram_a_nxt    = xhaddr[EXT_A_MSB:2];
    i_xsram_oe_n_nxt = 1'b 1;
    if (xhtrans == 2'b 01)
      begin
        i_state_nxt  = BUSY_STATE;
        i_xsram_oe_n_nxt = 1'b 1;
      end
    else if (xhtrans[1] == 1'b 1)
      begin
     //i_haddr_nxt = xhaddr;
      if(xhwrite == 1'b0)
        begin
        i_xsram_oe_n_nxt = 1'b 0;
        i_state_nxt      = READ_STATE;
        end
      end
    else if(xhbusreq == 1'b 1)
      begin
      i_state_nxt = START_STATE;
      end
    else
      begin
      i_state_nxt = IDLE_STATE;
      end
    end

    READ_STATE:
    begin
    i_hgrant_a   = 1'b 1;
    i_hready_a   = 1'b 1;
    if((xhbusreq == 1'b 1) && (xhtrans[1] == 1'b 0) && (xhtrans[0] == 1'b 0))
      begin
      i_state_nxt = START_STATE;
      end
    else if (xhtrans[1] == 1'b 0  && xhtrans[0] == 1'b0)
      begin
      i_xsram_a_nxt    = 0;
      i_xsram_oe_n_nxt = 1'b 1;
      i_state_nxt      = IDLE_STATE;
      end
    else if (xhtrans == 2'b01)
      begin
      i_xsram_a_nxt    = xhaddr[EXT_A_MSB:2];
      i_state_nxt = BUSY_STATE;
      i_xsram_oe_n_nxt = 1'b 1;
      end
    else
      begin
      i_xsram_a_nxt    = xhaddr[EXT_A_MSB:2];
      i_xsram_oe_n_nxt = 1'b 0;
      if(xhwrite == 1'b1)
        begin
        i_xsram_oe_n_nxt = 1'b 1;
        i_state_nxt = WRITE_STATE;
        end
      end
    end

   BUSY_STATE:
   begin
     i_hgrant_a   = 1'b 1;
     i_hready_a   = 1'b 1;
     //i_xsram_a_nxt    = 0;
     i_xsram_oe_n_nxt = 1'b 1;
     if(xhtrans == 2'b11)
       begin
         if(xhwrite == 1'b1)
           begin
             i_xsram_oe_n_nxt = 1'b 1;
             i_state_nxt = WRITE_STATE;
           end 
         else if(xhwrite == 1'b0)
           begin
             i_xsram_oe_n_nxt = 1'b 0;
             i_state_nxt = READ_STATE;
           end 
         else    
           i_state_nxt = BUSY_STATE;
       end
     else
       i_state_nxt = BUSY_STATE;
   end
   default:
      begin
      i_hgrant_a   = 1'b 0;
      i_hready_a   = 1'b 0;
      i_state_nxt  = IDLE_STATE;
      end
   endcase
   end

// sync part of FSM
//
always @(posedge del_xck_system or negedge xxclr)
  begin : sync_fsm_proc
  if (xxclr == 1'b 0)
    begin
    i_hgrant_r     <=  1'b 0;
    i_hready_r     <=  1'b 1;
    i_hresp_r      <=  2'b 00;
    i_haddr_r      <=  32'b 0;
    i_hsize_r      <=  3'b 0;
    i_hburst_r     <=  3'b 0;
    i_xsram_a_r    <=  {EXT_A_MSB-2 {1'b 0}};
    i_xsram_oe_n_r <=  1'b 0;
    i_state_r      <= IDLE_STATE;
    end
  else
    begin
    i_hgrant_r     <= i_hgrant_nxt;
    i_hready_r     <= i_hready_nxt;
    i_hresp_r      <= i_hresp_nxt;
    i_haddr_r      <= i_haddr_nxt;
    i_hsize_r      <= i_hsize_nxt;
    i_hburst_r     <= i_hburst_nxt;
    i_xsram_a_r    <= i_xsram_a_nxt;
    i_xsram_oe_n_r <= i_xsram_oe_n_nxt;
    i_state_r      <= i_state_nxt;
    end
  end

// sram byte enable generations
//
assign i_we_n_a[0] = (((i_hsize_r == 3'b 000) & (i_haddr_r[1:0] == 2'b 00)) |
                      ((i_hsize_r == 3'b 001) & (i_haddr_r[1]   == 1'b 0 )) |
                       (i_hsize_r == 3'b 010))
                   ? 1'b 0 : 1'b 1;

assign i_we_n_a[1] = (((i_hsize_r == 3'b 000) & (i_haddr_r[1:0] == 2'b 01)) |
                      ((i_hsize_r == 3'b 001) & (i_haddr_r[1]   == 1'b 0 )) |
                       (i_hsize_r == 3'b 010))
                   ? 1'b 0 : 1'b 1;

assign i_we_n_a[2] = (((i_hsize_r == 3'b 000) & (i_haddr_r[1:0] == 2'b 10)) |
                      ((i_hsize_r == 3'b 001) & (i_haddr_r[1]   == 1'b 1 )) |
                       (i_hsize_r == 3'b 010))
                   ? 1'b 0 : 1'b 1;

assign i_we_n_a[3] = (((i_hsize_r == 3'b 000) & (i_haddr_r[1:0] == 2'b 11)) |
                      ((i_hsize_r == 3'b 001) & (i_haddr_r[1]   == 1'b 1 )) |
                      (i_hsize_r == 3'b 010))
                   ? 1'b 0 : 1'b 1;


// drive output signals
//

// The AHB spec states that the 'xhresetn' signal is an active low
// reset and is asyncronously applied and removed syncronously to
// the positive edge of the 'hclk'.
always @(posedge xhclk or negedge xxclr)
  begin : sync_proc
  if (xxclr == 1'b 0)
    xhresetn <= 1'b0;
  else
    xhresetn <= 1'b1;
  end

// Assign xhgrant and xhready: use the unregistered version
// to save a cycle in the START state, i.e. so that the START
// state lasts a single cycle rather than two. This allows for
// a slightly better performance on the AHB bus for
// benchmarking purposes.
//assign xhgrant    = i_hgrant_r;
assign xhgrant    = i_hgrant_a;
//assign xhready    = i_hready_r;
assign xhready    = i_hready_a;


assign xhmaster = 4'b0;
assign xhsplit  = 16'b0;
assign xhsel    = 1'b1;
assign xhmastlock = 1'b0;
assign xhresp     = i_hresp_r;

// If the data bus coming from the SRAM is set to high impedance, output
// 0s instead, thus preventing the possibility of Xs being generated in
// the core during gate level sims. Also tri-state buses do not seem to
// be supported by AHB specs.
//assign i_xsram_d_high_a = (xsram_d === 32'b ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ) ?
assign i_xsram_d_high_a = ((xsram_d === 32'b ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ) && (i_state_r != BUSY_STATE)) ?
                          1 : 0;
assign xhrdata          = (i_xsram_d_high_a == 1'b1) ? 32'h0 : xsram_d;


assign xsram_a    = i_xsram_a_r;
assign xsram_we_n = (w_strobe == 1'b 1) ? ((i_state_r == WRITE_STATE)?i_we_n_a:4'b1111): 4'b 1111;
assign xsram_oe_n = i_xsram_oe_n_r;
assign xsram_d    = (xsram_oe_n == 1'b 1) ? i_xsram_d_r : 32'b z;

// write strobe generation
//
assign #(clock_period / 4) delayed_clk = del_xck_system;
assign w_strobe = delayed_clk & del_xck_system;

// synopsys_translate_on

endmodule // module ahb_slave_tb

