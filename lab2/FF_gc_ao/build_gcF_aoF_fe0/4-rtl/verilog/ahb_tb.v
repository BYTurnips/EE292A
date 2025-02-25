// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 2003-2007 ARC International (Unpublished)
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
// ARC Product:  ARC MSS v1.7.12
// File version:  MSS IP Library version 1.7.12, file revision 
// ARC Chip ID:  0
//
// Description:
//
// ----------------------------------------------------------------//
//                                                                 //
// ARC700 AHB testbench to behaviourally model an arbiter, memory  //
// controller and memory model.                                    //
//                                                                 //
// --------------------------------------------------------------- //

// Includes found automatically in dependent files.
`include "bus_defs.v"

module ahb_tb 
  (
  xrw1_hbusreq,   // rw1 port inputs
  xrw1_htrans,
  xrw1_haddr,
  xrw1_hwrite,
  xrw1_hburst,
  xrw1_hwdata,
  xrw1_hsize,
  xrw1_hlock,
  xrw1_hprot,

  xrw1_hgrant,    // rw1 port outputs
  xrw1_hready,
  xrw1_hresp,
  xrw1_hrdata,


  xhclk,
  xxclr

  );

input                   xhclk;
input                   xxclr;

input                   xrw1_hbusreq;
input  [1:0]            xrw1_htrans;
input  [31:0]           xrw1_haddr;
input                   xrw1_hwrite;
input  [2:0]            xrw1_hburst;
input  [`SYSBUS_DATA_MSB:0]           xrw1_hwdata;
input  [2:0]            xrw1_hsize;
input                   xrw1_hlock;
input  [3:0]            xrw1_hprot;

output                  xrw1_hgrant; 
output                  xrw1_hready; 
output [1:0]            xrw1_hresp; 
output [`SYSBUS_DATA_MSB:0]           xrw1_hrdata;

// output wires
//
wire                    xrw1_hgrant; 
wire                    xrw1_hready; 
wire   [1:0]            xrw1_hresp; 
wire   [`SYSBUS_DATA_MSB:0]           xrw1_hrdata;

wire                    xrw2_hgrant; 
wire                    xrw2_hready; 
wire   [1:0]            xrw2_hresp; 
wire   [`SYSBUS_DATA_MSB:0]           xrw2_hrdata;

wire                    xrw3_hgrant; 
wire                    xrw3_hready; 
wire   [1:0]            xrw3_hresp; 
wire   [`SYSBUS_DATA_MSB:0]           xrw3_hrdata;

wire                    xrw4_hgrant; 
wire                    xrw4_hready; 
wire   [1:0]            xrw4_hresp; 
wire   [`SYSBUS_DATA_MSB:0]           xrw4_hrdata;

wire                    xrw5_hgrant; 
wire                    xrw5_hready; 
wire   [1:0]            xrw5_hresp; 
wire   [`SYSBUS_DATA_MSB:0]           xrw5_hrdata;

wire                    xrw6_hgrant; 
wire                    xrw6_hready; 
wire   [1:0]            xrw6_hresp; 
wire   [`SYSBUS_DATA_MSB:0]           xrw6_hrdata;

// internal signals
//
wire [1:0]            sel_htrans;  // to memory controller
wire                  sel_hwrite;
wire [2:0]            sel_hburst;
wire [`SYSBUS_DATA_MSB:0]           sel_hwdata;
wire [2:0]            sel_hsize;
wire                  sel_hlock;
wire [31:0]           sel_haddr;
wire                  sel_hready;  // from memory controller
wire  [1:0]           sel_hresp;
wire  [`SYSBUS_DATA_MSB:0]          sel_hrdata;
wire                  sel_err;
reg                   sel_err_r;
//wire                  addr_mem_error;
reg                   addr_mem_error;

wire                   xrw2_hbusreq;
wire  [1:0]            xrw2_htrans;
wire  [31:0]           xrw2_haddr;
wire                   xrw2_hwrite;
wire  [2:0]            xrw2_hburst;
wire  [`SYSBUS_DATA_MSB:0]           xrw2_hwdata;
wire  [2:0]            xrw2_hsize;
wire                   xrw2_hlock;
wire  [3:0]            xrw2_hprot;

assign xrw2_hbusreq = 0;
assign xrw2_htrans  = 0;
assign xrw2_haddr   = 0;
assign xrw2_hwrite  = 0;
assign xrw2_hburst  = 0;
assign xrw2_hwdata  = 0;
assign xrw2_hsize   = 0;
assign xrw2_hlock   = 0;
assign xrw2_hprot   = 0;

wire                    xrw3_hbusreq;
wire   [1:0]            xrw3_htrans;
wire   [31:0]           xrw3_haddr;
wire                    xrw3_hwrite;
wire   [2:0]            xrw3_hburst;
wire   [`SYSBUS_DATA_MSB:0]           xrw3_hwdata;
wire   [2:0]            xrw3_hsize;
wire                    xrw3_hlock;
wire   [3:0]            xrw3_hprot;

assign xrw3_hbusreq = 0;
assign xrw3_htrans  = 0;
assign xrw3_haddr   = 0;
assign xrw3_hwrite  = 0;
assign xrw3_hburst  = 0;
assign xrw3_hwdata  = 0;
assign xrw3_hsize   = 0;
assign xrw3_hlock   = 0;
assign xrw3_hprot   = 0;

wire                    xrw4_hbusreq;
wire   [1:0]            xrw4_htrans;
wire   [31:0]           xrw4_haddr;
wire                    xrw4_hwrite;
wire   [2:0]            xrw4_hburst;
wire   [`SYSBUS_DATA_MSB:0]           xrw4_hwdata;
wire   [2:0]            xrw4_hsize;
wire                    xrw4_hlock;
wire   [3:0]            xrw4_hprot;

assign xrw4_hbusreq = 0;
assign xrw4_htrans  = 0;
assign xrw4_haddr   = 0;
assign xrw4_hwrite  = 0;
assign xrw4_hburst  = 0;
assign xrw4_hwdata  = 0;
assign xrw4_hsize   = 0;
assign xrw4_hlock   = 0;
assign xrw4_hprot   = 0;

wire                    xrw5_hbusreq;
wire   [1:0]            xrw5_htrans;
wire   [31:0]           xrw5_haddr;
wire                    xrw5_hwrite;
wire   [2:0]            xrw5_hburst;
wire   [`SYSBUS_DATA_MSB:0]           xrw5_hwdata;
wire   [2:0]            xrw5_hsize;
wire                    xrw5_hlock;
wire   [3:0]            xrw5_hprot;

assign xrw5_hbusreq = 0;
assign xrw5_htrans  = 0;
assign xrw5_haddr   = 0;
assign xrw5_hwrite  = 0;
assign xrw5_hburst  = 0;
assign xrw5_hwdata  = 0;
assign xrw5_hsize   = 0;
assign xrw5_hlock   = 0;
assign xrw5_hprot   = 0;

wire                    xrw6_hbusreq;
wire   [1:0]            xrw6_htrans;
wire   [31:0]           xrw6_haddr;
wire                    xrw6_hwrite;
wire   [2:0]            xrw6_hburst;
wire   [`SYSBUS_DATA_MSB:0]           xrw6_hwdata;
wire   [2:0]            xrw6_hsize;
wire                    xrw6_hlock;
wire   [3:0]            xrw6_hprot;

assign xrw6_hbusreq = 0;
assign xrw6_htrans  = 0;
assign xrw6_haddr   = 0;
assign xrw6_hwrite  = 0;
assign xrw6_hburst  = 0;
assign xrw6_hwdata  = 0;
assign xrw6_hsize   = 0;
assign xrw6_hlock   = 0;
assign xrw6_hprot   = 0;


// rename clock and reset signals
//
wire   hclk;
wire   hresetn;

assign hclk    =  xhclk ;
assign hresetn =  xxclr ;

// --------------------------------------------------------------- //
//                              arbiter                            //
// --------------------------------------------------------------- //

parameter TERM_WRAP = 1'b0;  // for debugging purposes

parameter ARB_0 = 12'b000_000000000;
parameter RW1_0 = 12'b000_000000001;
parameter RW1_1 = 12'b010_000000001;
parameter RW1_2 = 12'b011_000000001;
parameter RW1_3 = 12'b100_000000001;
parameter RW2_0 = 12'b000_000000010;
parameter RW2_1 = 12'b010_000000010;
parameter RW2_2 = 12'b011_000000010;
parameter RW2_3 = 12'b100_000000010;
parameter RW3_0 = 12'b000_000000100;
parameter RW3_1 = 12'b010_000000100;
parameter RW3_2 = 12'b011_000000100;
parameter RW3_3 = 12'b100_000000100;
parameter RW4_0 = 12'b000_000001000;
parameter RW4_1 = 12'b010_000001000;
parameter RW4_2 = 12'b011_000001000;
parameter RW4_3 = 12'b100_000001000;
parameter RW5_0 = 12'b000_000010000;
parameter RW5_1 = 12'b010_000010000;
parameter RW5_2 = 12'b011_000010000;
parameter RW5_3 = 12'b100_000010000;
parameter RW6_0 = 12'b000_000100000;
parameter RW6_1 = 12'b010_000100000;
parameter RW6_2 = 12'b011_000100000;
parameter RW6_3 = 12'b100_000100000;

//EE bits
parameter RW7_0 = 12'b000_001000000;
parameter RW7_1 = 12'b010_001000000;
parameter RW7_2 = 12'b011_001000000;
parameter RW7_3 = 12'b100_001000000;
//ME bits
parameter RW8_0 = 12'b000_010000000;
parameter RW8_1 = 12'b010_010000000;
parameter RW8_2 = 12'b011_010000000;
parameter RW8_3 = 12'b100_010000000;

// How many cycles each grant to a client is allowed
`define GRANT_CNT  6'b100000

wire                  i_wrap_a;
reg     [11:0]         i_gstate_r;
reg     [11:0]         i_gstate_nxt;

reg     [5:0]         i_grant_cnt_r;
reg     [5:0]         i_grant_cnt_nxt;

// arbiter FSM async process
//
always @(
  i_grant_cnt_r or
  i_wrap_a      or
  xrw1_hlock    or
  xrw2_hlock    or
  xrw3_hlock    or
  xrw4_hlock    or
  xrw5_hlock    or
  xrw6_hlock    or
  i_gstate_r    or
  xrw1_htrans   or
  xrw2_htrans   or
  xrw3_htrans   or
  xrw4_htrans   or
  xrw5_htrans   or
  xrw6_htrans   or
  xrw1_hbusreq  or
  xrw2_hbusreq  or
  xrw3_hbusreq  or
  xrw4_hbusreq  or
  xrw5_hbusreq  or
  xrw6_hbusreq  
  )
begin

  i_gstate_nxt = i_gstate_r;
  i_grant_cnt_nxt = i_grant_cnt_r + 1;

  case (i_gstate_r)

    ARB_0:      if (xrw3_hbusreq == 1'b1) i_gstate_nxt = RW3_0;
           else if (xrw2_hbusreq == 1'b1) i_gstate_nxt = RW2_0;
           else if (xrw1_hbusreq == 1'b1) i_gstate_nxt = RW1_0;
           else if (xrw6_hbusreq == 1'b1) i_gstate_nxt = RW6_0;
           else if (xrw4_hbusreq == 1'b1) i_gstate_nxt = RW4_0;
           else if (xrw5_hbusreq == 1'b1) i_gstate_nxt = RW5_0;
 
    RW1_0: 
        begin
	  i_grant_cnt_nxt = 6'b000000;
          i_gstate_nxt = RW1_1;
	end
    RW1_1: if ((((xrw1_htrans[1] == 1'b0) | (i_wrap_a == 1'b1)) &
               (xrw1_hlock == 1'b0)) | (i_grant_cnt_r == `GRANT_CNT))
             i_gstate_nxt = RW1_2;
    RW1_2: i_gstate_nxt = RW1_3;
    RW1_3: i_gstate_nxt = ARB_0;

    RW2_0:
            begin
	     i_grant_cnt_nxt = 6'b000000;
             i_gstate_nxt = RW2_1;
	    end
    RW2_1: if ((((xrw2_htrans[1] == 1'b0) | (i_wrap_a == 1'b1)) &
               (xrw2_hlock == 1'b0)) | (i_grant_cnt_r == `GRANT_CNT))
             i_gstate_nxt = RW2_2;
    RW2_2: i_gstate_nxt = RW2_3;
    RW2_3: i_gstate_nxt = ARB_0;

    RW3_0: 
	   begin
	      i_grant_cnt_nxt = 6'b000000;
              i_gstate_nxt = RW3_1;
	   end     
    RW3_1: if ((((xrw3_htrans[1] == 1'b0) | (i_wrap_a == 1'b1)) &
               (xrw3_hlock == 1'b0)) | (i_grant_cnt_r == `GRANT_CNT))
             i_gstate_nxt = RW3_2;
    RW3_2: i_gstate_nxt = RW3_3;
    RW3_3: i_gstate_nxt = ARB_0;

    RW4_0: 
          begin
	    i_grant_cnt_nxt = 6'b000000;
            i_gstate_nxt = RW4_1;
	  end
    RW4_1: if ((((xrw4_htrans[1] == 1'b0) | (i_wrap_a == 1'b1)) &
               (xrw4_hlock == 1'b0)) | (i_grant_cnt_r == `GRANT_CNT))
             i_gstate_nxt = RW4_2;
    RW4_2: i_gstate_nxt = RW4_3;
    RW4_3: i_gstate_nxt = ARB_0;

    RW5_0: 
           begin
	      i_grant_cnt_nxt = 6'b000000;
              i_gstate_nxt = RW5_1;
           end
    RW5_1: if ((((xrw5_htrans[1] == 1'b0) | (i_wrap_a == 1'b1)) &
               (xrw5_hlock == 1'b0)) | (i_grant_cnt_r == `GRANT_CNT))
             i_gstate_nxt = RW5_2;
    RW5_2: i_gstate_nxt = RW5_3;
    RW5_3: i_gstate_nxt = ARB_0;

    RW6_0: 
           begin 
	     i_grant_cnt_nxt = 6'b000000;
             i_gstate_nxt = RW6_1;
    	   end
	
    RW6_1: if ((((xrw6_htrans[1] == 1'b0) | (i_wrap_a == 1'b1)) &
               (xrw6_hlock == 1'b0)) | (i_grant_cnt_r == `GRANT_CNT))
             i_gstate_nxt = RW6_2;
    RW6_2: i_gstate_nxt = RW6_3;
    RW6_3: i_gstate_nxt = ARB_0;
    

    default: i_gstate_nxt = ARB_0;

  endcase
end

// arbiter FSM sync process
//
always @(posedge hclk or negedge hresetn)
  begin
  if (hresetn == 1'b0)
    begin
    i_gstate_r <= ARB_0;
    i_grant_cnt_r <= 6'b0;
    end
  else
    begin
    i_grant_cnt_r <= i_grant_cnt_nxt;    
    i_gstate_r <= i_gstate_nxt;
    end
  end

// drive memory controller outputs
//

assign i_wrap_a   =   (((i_gstate_r[0] == 1'b1) & 
                       ((xrw1_hburst   == 3'b010) | 
                        (xrw1_hburst   == 3'b100) | 
                        (xrw1_hburst   == 3'b110))) |
                       ((i_gstate_r[1] == 1'b1) & 
                       ((xrw2_hburst   == 3'b010) | 
                        (xrw2_hburst   == 3'b100) | 
                        (xrw2_hburst   == 3'b110))) |
                       ((i_gstate_r[2] == 1'b1) & 
                       ((xrw3_hburst   == 3'b010) | 
                        (xrw3_hburst   == 3'b100) | 
                        (xrw3_hburst   == 3'b110))) |
                       ((i_gstate_r[3] == 1'b1) & 
                       ((xrw4_hburst   == 3'b010) | 
                        (xrw4_hburst   == 3'b100) | 
                        (xrw4_hburst   == 3'b110))) |
                       ((i_gstate_r[4] == 1'b1) & 
                       ((xrw5_hburst   == 3'b010) | 
                        (xrw5_hburst   == 3'b100) | 
                        (xrw5_hburst   == 3'b110))) |
                       ((i_gstate_r[5] == 1'b1) & 
                       ((xrw6_hburst   == 3'b010) | 
                        (xrw6_hburst   == 3'b100) | 
                        (xrw6_hburst   == 3'b110)))
                      )
                      ? TERM_WRAP : 1'b0;

//assign   i_wrap_a   = 1'b0;

assign sel_htrans =   (i_gstate_r[0] == 1'b1) ? xrw1_htrans
                    : (i_gstate_r[1] == 1'b1) ? xrw2_htrans
                    : (i_gstate_r[2] == 1'b1) ? xrw3_htrans
                    : (i_gstate_r[3] == 1'b1) ? xrw4_htrans
                    : (i_gstate_r[4] == 1'b1) ? xrw5_htrans
                    : (i_gstate_r[5] == 1'b1) ? xrw6_htrans
       
                    : 2'b0;

assign sel_hwrite =   (i_gstate_r[0] == 1'b1) ? xrw1_hwrite
                    : (i_gstate_r[1] == 1'b1) ? xrw2_hwrite
                    : (i_gstate_r[2] == 1'b1) ? xrw3_hwrite
                    : (i_gstate_r[3] == 1'b1) ? xrw4_hwrite
                    : (i_gstate_r[4] == 1'b1) ? xrw5_hwrite
                    : (i_gstate_r[5] == 1'b1) ? xrw6_hwrite
                    : 1'b0;

assign sel_hburst =   (i_gstate_r[0] == 1'b1) ? xrw1_hburst
                    : (i_gstate_r[1] == 1'b1) ? xrw2_hburst
                    : (i_gstate_r[2] == 1'b1) ? xrw3_hburst
                    : (i_gstate_r[3] == 1'b1) ? xrw4_hburst
                    : (i_gstate_r[4] == 1'b1) ? xrw5_hburst
                    : (i_gstate_r[5] == 1'b1) ? xrw6_hburst
                    : 3'b0;

assign sel_hwdata =   (i_gstate_r[0] == 1'b1) ? xrw1_hwdata
                    : (i_gstate_r[1] == 1'b1) ? xrw2_hwdata
                    : (i_gstate_r[2] == 1'b1) ? xrw3_hwdata
                    : (i_gstate_r[3] == 1'b1) ? xrw4_hwdata
                    : (i_gstate_r[4] == 1'b1) ? xrw5_hwdata
                    : (i_gstate_r[5] == 1'b1) ? xrw6_hwdata
                    : {`SYSBUS_DATA_WIDTH {1'b0}};

assign sel_hsize  =   (i_gstate_r[0] == 1'b1) ? xrw1_hsize
                    : (i_gstate_r[1] == 1'b1) ? xrw2_hsize
                    : (i_gstate_r[2] == 1'b1) ? xrw3_hsize
                    : (i_gstate_r[3] == 1'b1) ? xrw4_hsize
                    : (i_gstate_r[4] == 1'b1) ? xrw5_hsize
                    : (i_gstate_r[5] == 1'b1) ? xrw6_hsize
                    : 3'b0;

assign sel_hlock  =   (i_gstate_r[0] == 1'b1) ? xrw1_hlock
                    : (i_gstate_r[1] == 1'b1) ? xrw2_hlock
                    : (i_gstate_r[2] == 1'b1) ? xrw3_hlock
                    : (i_gstate_r[3] == 1'b1) ? xrw4_hlock
                    : (i_gstate_r[4] == 1'b1) ? xrw5_hlock
                    : (i_gstate_r[5] == 1'b1) ? xrw6_hlock
            
                    : 1'b0;

assign sel_haddr  =   (i_gstate_r[0] == 1'b1) ? xrw1_haddr
                    : (i_gstate_r[1] == 1'b1) ? xrw2_haddr
                    : (i_gstate_r[2] == 1'b1) ? xrw3_haddr
                    : (i_gstate_r[3] == 1'b1) ? xrw4_haddr
                    : (i_gstate_r[4] == 1'b1) ? xrw5_haddr
                    : (i_gstate_r[5] == 1'b1) ? xrw6_haddr
                    : 32'b0;

assign sel_err   = (((sel_hsize == 3'b 001) && (sel_haddr[0]   != 1'b 0  )) ||
                    ((sel_hsize == 3'b 010) && (sel_haddr[1:0] != 2'b 00 )) ||
                    ((sel_hsize == 3'b 011) && (sel_haddr[2:0] != 3'b 000)));

// Protocol Error detection
//
always @(posedge hclk or negedge hresetn)
  begin
  if (hresetn == 1'b0)
    begin
    sel_err_r <= 1'b 0;
    end
  else
    begin
    if (i_gstate_r == 3'b 000)
      begin
      sel_err_r <= 1'b 0;
      end
    else if (sel_err == 1'b 1)
      begin
      sel_err_r <= 1'b 1;
      end
    end
  end

// drive module outputs
//
assign xrw1_hgrant = ((i_gstate_r == RW1_0)|(i_gstate_r == RW1_1))? 1'b1 : 1'b0;
assign xrw2_hgrant = ((i_gstate_r == RW2_0)|(i_gstate_r == RW2_1))? 1'b1 : 1'b0;
assign xrw3_hgrant = ((i_gstate_r == RW3_0)|(i_gstate_r == RW3_1))? 1'b1 : 1'b0;
assign xrw4_hgrant = ((i_gstate_r == RW4_0)|(i_gstate_r == RW4_1))? 1'b1 : 1'b0;
assign xrw5_hgrant = ((i_gstate_r == RW5_0)|(i_gstate_r == RW5_1))? 1'b1 : 1'b0;
assign xrw6_hgrant = ((i_gstate_r == RW6_0)|(i_gstate_r == RW6_1))? 1'b1 : 1'b0;

assign xrw1_hready = (i_gstate_r[0] == 1'b1)? sel_hready : 1'b0;
assign xrw2_hready = (i_gstate_r[1] == 1'b1)? sel_hready : 1'b0;
assign xrw3_hready = (i_gstate_r[2] == 1'b1)? sel_hready : 1'b0;
assign xrw4_hready = (i_gstate_r[3] == 1'b1)? sel_hready : 1'b0;
assign xrw5_hready = (i_gstate_r[4] == 1'b1)? sel_hready : 1'b0;
assign xrw6_hready = (i_gstate_r[5] == 1'b1)? sel_hready : 1'b0;

assign xrw1_hresp  = (i_gstate_r[0] == 1'b1)? sel_hresp  : 2'b0;
assign xrw2_hresp  = (i_gstate_r[1] == 1'b1)? sel_hresp  : 2'b0;
assign xrw3_hresp  = (i_gstate_r[2] == 1'b1)? sel_hresp  : 2'b0;
assign xrw4_hresp  = (i_gstate_r[3] == 1'b1)? sel_hresp  : 2'b0;
assign xrw5_hresp  = (i_gstate_r[4] == 1'b1)? sel_hresp  : 2'b0;
assign xrw6_hresp  = (i_gstate_r[5] == 1'b1)? sel_hresp  : 2'b0;

assign xrw1_hrdata = (i_gstate_r[0] == 1'b1)? sel_hrdata : {64{1'b0}};
assign xrw2_hrdata = (i_gstate_r[1] == 1'b1)? sel_hrdata : {64{1'b0}};
assign xrw3_hrdata = (i_gstate_r[2] == 1'b1)? sel_hrdata : {64{1'b0}};
assign xrw4_hrdata = (i_gstate_r[3] == 1'b1)? sel_hrdata : {64{1'b0}};
assign xrw5_hrdata = (i_gstate_r[4] == 1'b1)? sel_hrdata : {64{1'b0}};
assign xrw6_hrdata = (i_gstate_r[5] == 1'b1)? sel_hrdata : {64{1'b0}};

// --------------------------------------------------------------- //
//                          memory controller                      //
// --------------------------------------------------------------- //

// signals to and from the SDRAM
//
wire                  i_ram_we_n;
wire                  i_ram_ce_n;
wire [`SYSBUS_BE_MSB:0]            i_ram_be_n;
wire [31:0]           i_ram_addr;
wire [`SYSBUS_DATA_MSB:0]           i_ram_din;
wire [`SYSBUS_DATA_MSB:0]           i_ram_dout;
wire [`SYSBUS_DATA_MSB:0]           i_ram_dout_fmtd0;
wire [`SYSBUS_DATA_MSB:0]           i_ram_dout_fmtd1;

// internal signals and registers
//
reg  [31:0]           i_haddr_r;
wire [31:0]           i_haddr_a;
reg  [2:0]            i_hsize_r;
wire [2:0]            i_hsize_a;
reg                   i_hwrite_r;
wire                  i_hwrite_a;
reg  [1:0]            i_htrans_r;
reg  [`SYSBUS_DATA_MSB:0]           i_hwdata_r;

// Detect memory error
//
// Generate memory error in range 0x00f0_0000 to
//                                0x00fb_ffff
//

always @(posedge hclk or negedge hresetn)
  begin
    if(hresetn == 1'b0)
      addr_mem_error <= 1'b0;
    else
      addr_mem_error = (i_haddr_r[31:18] == 14'b0000_0000_1111_00) | 
                       (i_haddr_r[31:18] == 14'b0000_0000_1111_01) | 
                       (i_haddr_r[31:18] == 14'b0000_0000_1111_10) ;
  end

// drive outputs to the arbiter
//
assign sel_hready = 1'b 1;
assign sel_hresp  = ((addr_mem_error == 1'b0) && (sel_err_r == 1'b 0)) ? 2'b00: 2'b01;
assign sel_hrdata = i_ram_dout;

// Register command signals for write accesses 
// because wdata lags by one cycle
// 
//always @(posedge hclk or negedge hresetn)
//  begin : SYNC_MC_PROC
//  if (hresetn == 1'b0)
//    begin
//    i_haddr_r  <= 32'b 0;
//    i_hsize_r  <=  3'b 0;
//    i_htrans_r <=  2'b 0;
//    i_hwrite_r <=  1'b 0;
//    i_hwdata_r <= {`SYSBUS_DATA_WIDTH{1'b0}};
//    end
//  else
//    begin
//    i_haddr_r  <= sel_haddr;
//    i_hsize_r  <= sel_hsize;
//    i_htrans_r <= sel_htrans;
//    i_hwrite_r <= sel_hwrite;
//    i_hwdata_r <= sel_hwdata;
//    end
//  end

 always @(*)
   begin : SYNC_MC_PROC
     i_haddr_r  = sel_haddr;
     i_hsize_r  = sel_hsize;
     i_htrans_r = sel_htrans;
     i_hwrite_r = sel_hwrite;
     i_hwdata_r = sel_hwdata;
   end
  


assign i_hwrite_a = (i_hwrite_r == 1'b 1) ? i_htrans_r[1] : 1'b 0;
assign i_hsize_a  = (i_hwrite_r == 1'b 1) ? i_hsize_r : sel_hsize;
assign i_haddr_a  = (i_hwrite_r == 1'b 1) ? i_haddr_r : sel_haddr;

// drive outputs to ram
//
assign i_ram_we_n    = ~i_hwrite_a;
assign i_ram_ce_n    = 1'b 0;

assign i_ram_addr    = {i_haddr_a [31:2]};
  


assign i_ram_din     = i_hwdata_r;
assign i_ram_be_n[0] = 
  (((i_hsize_a == 3'b 000) && (i_haddr_a[1:0]== 2'b 00)) ||
   ((i_hsize_a == 3'b 001) && (i_haddr_a[1]  == 1'b 0 )) ||
   (i_hsize_a == 3'b 010))
   ? 1'b 0 : 1'b 1;
assign i_ram_be_n[1] = 
  (((i_hsize_a == 3'b 000) && (i_haddr_a[1:0]== 2'b 01)) ||
   ((i_hsize_a == 3'b 001) && (i_haddr_a[1]  == 1'b 0 )) ||
   (i_hsize_a == 3'b 010))
   ? 1'b 0 : 1'b 1;
assign i_ram_be_n[2] = 
  (((i_hsize_a == 3'b 000) && (i_haddr_a[1:0]== 2'b 10)) ||
   ((i_hsize_a == 3'b 001) && (i_haddr_a[1]  == 1'b 1 )) ||
    (i_hsize_a == 3'b 010))
   ? 1'b 0 : 1'b 1;
assign i_ram_be_n[3] = 
  (((i_hsize_a == 3'b 000) && (i_haddr_a[1:0]== 2'b 11)) ||
   ((i_hsize_a == 3'b 001) && (i_haddr_a[1]  == 1'b 1 )) ||
    (i_hsize_a == 3'b 010))
    ? 1'b 0 : 1'b 1;

// --------------------------------------------------------------- //
//                            memory model                         //
// --------------------------------------------------------------- //

// synopsys translate_off
syncsram_wd #(
  .INIT_FILE            ("init_mem.hex"),
  .CLEAR_ON_POWER_UP    (1),
  .DOWNLOAD_ON_POWER_UP (1),
  .BASE_ADDRESS         (0),
  .MEMORY_SIZE          (512*2048*1024),
  .ADDRESS_WIDTH        (32),
  .MEMORY_MODEL_NUM     (0),
  .DATA_WIDTH           (`SYSBUS_DATA_WIDTH),
  .BWE_WIDTH            (`SYSBUS_BE_WIDTH)
  )
u_beh_bank0(
  .ck                   (hclk),
  .ce_n                 (i_ram_ce_n),
  .we_n                 (i_ram_we_n),
  .bw_n                 (i_ram_be_n),
  .addr                 (i_ram_addr),
  .din                  (i_ram_din),
  .dout                 (i_ram_dout)
  );

// synopsys translate_on

endmodule // module ahb_tb

