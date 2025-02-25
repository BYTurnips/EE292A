// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 2003-2012 ARC International (Unpublished)
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
// ibus - Internal Bus Module
//                                     
//
// =============================================================================
// 
// =============================================================================

module ibus (        

        // Clocks and Resets ---------------------------------------------------

        clk,
        clk_ungated,
        clk_system,
        rst_a,
	sync,
        
       // Clock Gating Control ------------------------------------------------
        
        ibus_busy,

// Signals for initiators from the core.
	// Load/Store queue of highest priority
	q_address,	// byte address
	q_be     ,	// byte enables
	q_cmd    ,	// command
	q_cmdval ,	// command valid
	q_eop    ,	// end of packet
	q_rspack ,	// response acknowledge
	q_wdata  ,	// write data
	q_plen   ,	// packet length
	q_buffer  ,	// buffer transfer
	q_cache   ,	// cache transfer
	q_mode    ,	// data or opcode tranfer
	q_priv    ,	// privilege transfer
	q_cmdack ,	// command acknowledge
	q_rdata  ,	// read data
	q_reop   ,	// response end of packet
	q_rspval ,	// response valid

	// Data cache fetch of high priority

	// Data cache flush of medium priority

	// XY memory of low priority

	// icache fetch or IFQ of lowest priority

   hclk,
   hresetn,
   hgrant,
   hready,
   hresp,
   hrdata,
   hbusreq,
   hlock,
   htrans,
   haddr,
   hwrite,
   hsize,
   hburst,
   hprot,
   hwdata,
   mem_access,
   memory_error,
	   

        // Interrupts ----------------------------------------------------------

        ext_bus_error
);
        
`include "arcutil_pkg_defines.v"
`include "arcutil.v"
`include "extutil.v"
`include "che_util.v"
`include "xdefs.v"
`include "ext_msb.v"

// Clocks and Resets ---------------------------------------------------
input         clk;
input         clk_ungated;
input         clk_system;
input         rst_a;

// Interrupts ----------------------------------------------------------
//output         mem_err;

// Clock Gating Control ------------------------------------------------
output                ibus_busy;

// Interrupts ----------------------------------------------------------
output                ext_bus_error;

input  [EXT_A_MSB:0]	q_address;	// byte address
input  [3:0]        	q_be     ;	// byte enables
input  [1:0]        	q_cmd    ;	// command
input               	q_cmdval ;	// command valid
input               	q_eop    ;	// end of packet
input               	q_rspack ;	// response acknowledge
input  [31:0]       	q_wdata  ;	// write data
input  [8:0]        	q_plen   ;	// packet length
input               	q_buffer  ;	// buffer transfer
input               	q_cache   ;	// cache transfer
input               	q_mode    ;	// data or opcode tranfer
input               	q_priv    ;	// privilege transfer
output             	q_cmdack ;	// command acknowledge
output [31:0]      	q_rdata  ;	// read data
output             	q_reop   ;	// response end of packet
output             	q_rspval ;	// response valid

input hclk; 
input hresetn;
	
input hgrant; 
input hready; 
input [1:0] hresp; 
input [31:0] hrdata;  
output hbusreq; 
output hlock; 
output [1:0] htrans; 
output [31:0] haddr; 
output hwrite; 
output [2:0] hsize; 
output [2:0] hburst; 
output [3:0] hprot; 
output [31:0] hwdata;

output mem_access;
output memory_error;

wire hbusreq; 
wire hlock; 
wire [1:0] htrans; 
wire [31:0] haddr; 
wire hwrite; 
wire [2:0] hsize; 
wire [2:0] hburst; 
wire [3:0] hprot; 
wire [31:0] hwdata;

wire mem_access;
wire memory_error;

// =============================================================================
// Internal Signal Declarations
// =============================================================================

wire [EXT_A_MSB:0] t0_address;
wire [3:0]         t0_be;
wire [1:0]         t0_cmd;
wire               t0_eop;
wire [8:0]         t0_plen;
wire [MEM_D_MSB:0] t0_wdata;
wire               t0_cmdval;
wire               t0_rspack;
wire               t0_cmdack;
wire [MEM_D_MSB:0] t0_rdata;
wire               t0_reop;
wire               t0_rspval;
wire               t0_buffer;
wire               t0_cache;
wire               t0_priv;
wire               t0_mode;

wire [EXT_A_MSB:0] t1_address;
wire [3:0]         t1_be;
wire [1:0]         t1_cmd;
wire               t1_eop;
wire [8:0]         t1_plen;
wire [MEM_D_MSB:0] t1_wdata;
wire               t1_cmdval;
wire               t1_rspack;
wire               t1_cmdack;
wire [MEM_D_MSB:0] t1_rdata;
wire               t1_reop;
wire               t1_rspval;
wire               t1_buffer;
wire               t1_cache;
wire               t1_priv;
wire               t1_mode;

wire [EXT_A_MSB:0] t2_address;
wire [3:0]         t2_be;
wire [1:0]         t2_cmd;
wire               t2_eop;
wire [8:0]         t2_plen;
wire [MEM_D_MSB:0] t2_wdata;
wire               t2_cmdval;
wire               t2_rspack;
wire               t2_cmdack;
wire [MEM_D_MSB:0] t2_rdata;
wire               t2_reop;
wire               t2_rspval;
wire               t2_buffer;
wire               t2_cache;
wire               t2_priv;
wire               t2_mode;

wire [EXT_A_MSB:0] t3_address;
wire [3:0]         t3_be;
wire [1:0]         t3_cmd;
wire               t3_eop;
wire [8:0]         t3_plen;
wire [MEM_D_MSB:0] t3_wdata;
wire               t3_cmdval;
wire               t3_rspack;
wire               t3_cmdack;
wire [MEM_D_MSB:0] t3_rdata;
wire               t3_reop;
wire               t3_rspval;
wire               t3_buffer;
wire               t3_cache;
wire               t3_priv;
wire               t3_mode;

wire [EXT_A_MSB:0] t4_address;
wire [3:0]         t4_be;
wire [1:0]         t4_cmd;
wire               t4_eop;
wire [8:0]         t4_plen;
wire [MEM_D_MSB:0] t4_wdata;
wire               t4_cmdval;
wire               t4_rspack;
wire               t4_cmdack;
wire [MEM_D_MSB:0] t4_rdata;
wire               t4_reop;
wire               t4_rspval;
wire               t4_buffer;
wire               t4_cache;
wire               t4_priv;
wire               t4_mode;

wire [EXT_A_MSB:0] iarb_address;
wire [3:0]         iarb_be;
wire [1:0]         iarb_cmd;
wire               iarb_eop;
wire [8:0]         iarb_plen;
wire [MEM_D_MSB:0] iarb_wdata;
wire               iarb_cmdval;
wire               iarb_rspack;
wire               iarb_cmdack;
wire [MEM_D_MSB:0] iarb_rdata;
wire               iarb_reop;
wire               iarb_rspval;
wire               iarb_rerror;
wire               iarb_cache;  
wire               iarb_buffer;
wire               iarb_mode;
wire               iarb_priv;    

input               sync;
wire               cbri_busy;
wire               iarb_busy;
//wire  [8:0]        i_plen;

wire               clk_ext;


// =============================================================================
// Instances
// =============================================================================

/*
// Clock Synchronisation Unit --------------------------------------------------

ibus_cksyn icksyn (
    .clk_ungated  (clk_ungated),
    .clk_ext      (clk_system),
    .rst_a        (rst_a),
    .sync         (sync)
);
*/

// Internal Arbiter Unit -------------------------------------------------------

ibus_iarb #(

  EXT_A_WIDTH, // ADDR_WIDTH
  MEM_D_WIDTH, // DATA_WIDTH
  4,           // BE_WIDTH  
  4            // FIFO_DEPTH

) iiarb (

    // Clocks and resets ----------------------------------------------
  .clk         (clk),
  .rst_a       (rst_a),
  
  // Target Port 0 with Highest Prioirty ----------------------------
  .t0_address  (t0_address),
  .t0_be       (t0_be),
  .t0_cmd      (t0_cmd), 
  .t0_eop      (t0_eop), 
  .t0_plen     (t0_plen),
  .t0_wdata    (t0_wdata),
  .t0_cmdval   (t0_cmdval),
  .t0_rspack   (t0_rspack),
  .t0_cache    (t0_cache),  
  .t0_buffer   (t0_buffer),
  .t0_mode     (t0_mode),
  .t0_priv     (t0_priv),    
  // Target Port 1 with High Priority -------------------------------
  .t1_address  (t1_address),
  .t1_be       (t1_be),
  .t1_cmd      (t1_cmd),
  .t1_eop      (t1_eop),
  .t1_plen     (t1_plen),
  .t1_wdata    (t1_wdata),
  .t1_cmdval   (t1_cmdval),
  .t1_rspack   (t1_rspack),
  .t1_cache    (t1_cache),  
  .t1_buffer   (t1_buffer),
  .t1_mode     (t1_mode),
  .t1_priv     (t1_priv),    
  // Target Port 2 with Medium Priority -----------------------------
  .t2_address  (t2_address),
  .t2_be       (t2_be),
  .t2_cmd      (t2_cmd),
  .t2_eop      (t2_eop),
  .t2_plen     (t2_plen),
  .t2_wdata    (t2_wdata),
  .t2_cmdval   (t2_cmdval),
  .t2_rspack   (t2_rspack),
  .t2_cache    (t2_cache),  
  .t2_buffer   (t2_buffer),
  .t2_mode     (t2_mode),
  .t2_priv     (t2_priv),    
  // Target Port 3 with Low Priority -------------------------------
  .t3_address  (t3_address),
  .t3_be       (t3_be),
  .t3_cmd      (t3_cmd),
  .t3_eop      (t3_eop),
  .t3_plen     (t3_plen),
  .t3_wdata    (t3_wdata),
  .t3_cmdval   (t3_cmdval),
  .t3_rspack   (t3_rspack),
  .t3_cache    (t3_cache),  
  .t3_buffer   (t3_buffer),
  .t3_mode     (t3_mode),
  .t3_priv     (t3_priv),    
  // Target Port 4 with Lowest Priority -----------------------------
  .t4_address  (t4_address),
  .t4_be       (t4_be),
  .t4_cmd      (t4_cmd),
  .t4_eop      (t4_eop),
  .t4_plen     (t4_plen),
  .t4_wdata    (t4_wdata),
  .t4_cmdval   (t4_cmdval),
  .t4_rspack   (t4_rspack),
  .t4_cache    (t4_cache),  
  .t4_buffer   (t4_buffer),
  .t4_mode     (t4_mode),
  .t4_priv     (t4_priv),    
  // Initiator Port -------------------------------------------------
  .i_cmdack    (iarb_cmdack),
  .i_rdata     (iarb_rdata),
  .i_reop      (iarb_reop),
  .i_rspval    (iarb_rspval),

  // OUTPUTS ========================================================

  // Target Port 0 with Highest Prioirty ----------------------------
  .t0_cmdack   (t0_cmdack),
  .t0_rdata    (t0_rdata),
  .t0_reop     (t0_reop),
  .t0_rspval   (t0_rspval),

  // Target Port 1 with Medium Priority -----------------------------
  .t1_cmdack   (t1_cmdack),
  .t1_rdata    (t1_rdata),
  .t1_reop     (t1_reop),
  .t1_rspval   (t1_rspval),

  // Target Port 2 with Lowest Priority -----------------------------
  .t2_cmdack   (t2_cmdack),
  .t2_rdata    (t2_rdata),
  .t2_reop     (t2_reop),
  .t2_rspval   (t2_rspval),

  // Target Port 3 with Medium Priority -----------------------------
  .t3_cmdack   (t3_cmdack),
  .t3_rdata    (t3_rdata),
  .t3_reop     (t3_reop),
  .t3_rspval   (t3_rspval),

  // Target Port 4 with Lowest Priority -----------------------------
  .t4_cmdack   (t4_cmdack),
  .t4_rdata    (t4_rdata),
  .t4_reop     (t4_reop),
  .t4_rspval   (t4_rspval),

  // Initiator Port -------------------------------------------------
  .i_address   (iarb_address),
  .i_be        (iarb_be),
  .i_cmd       (iarb_cmd),
  .i_eop       (iarb_eop),
  .i_plen      (iarb_plen),
  .i_wdata     (iarb_wdata),
  .i_cmdval    (iarb_cmdval),
  .i_rspack    (iarb_rspack),
  .i_cache     (iarb_cache),  
  .i_buffer    (iarb_buffer),
  .i_mode      (iarb_mode),
  .i_priv      (iarb_priv),    

  // Busy signal ----------------------------------------------------
  .iarb_busy   (iarb_busy)
    
);

// Interrupt Re-Sync and Extender Unit ------------------------------------

ibus_isyn isyn (

    // INPUTS =========================================================

  // System Bus Error Inputs ----------------------------------------
  .sys_bus_error (iarb_rerror),

  // Internal Bus Error Inputs --------------------------------------
  .iarb_rerror   (iarb_rerror),
  .iarb_rspval   (iarb_rspval),
  .iarb_rspack   (iarb_rspack),
  
  // OUTPUTS ========================================================
  
  // Re-Sync and Extended Bus Error Interrupt -----------------------
  .ext_bus_error (ext_bus_error));

ibus_cbri_ahb #(32, 1, 1, EXT_A_MSB) ibus_dcbri_ahb  
  (
   .hclk(hclk),
   .hresetn(hresetn),
   .rst_a(rst_a),
   .iclk(clk),   
   .t_address(iarb_address),
   .t_be(iarb_be),
   .t_cmd(iarb_cmd),
   .t_eop(iarb_eop),
   .t_plen(iarb_plen),
   .t_wdata(iarb_wdata),
   .t_cmdval(iarb_cmdval),
   .t_rspack(iarb_rspack),
   .t_buffer(iarb_buffer),
   .t_cache(iarb_cache),
   .t_priv(iarb_priv),
   .t_mode(iarb_mode),
   .hgrant(hgrant),
   .hready(hready),
   .hresp(hresp),
   .hrdata(hrdata),
   .sync_r(sync),
   .t_cmdack(iarb_cmdack),
   .t_rdata(iarb_rdata),
   .t_reop(iarb_reop),
   .t_rspval(iarb_rspval),
   .t_rerror(iarb_rerror),
   .hbusreq(hbusreq),
   .hlock(hlock),
   .htrans(htrans),
   .haddr(haddr),
   .hwrite(hwrite),
   .hsize(hsize),
   .hburst(hburst),
   .hprot(hprot),
   .hwdata(hwdata),
   .busy(cbri_busy)); 




// Combining Busy Signals -------------------------------------------------
assign ibus_busy = 
                                    cbri_busy |
                    iarb_busy;
	 
// Load/Store queue of highest priority
assign t0_address  	= q_address;	// byte address
assign t0_be       	= q_be     ;	// byte enables
assign t0_cmd      	= q_cmd    ;	// command
assign t0_cmdval   	= q_cmdval ;	// command valid
assign t0_eop      	= q_eop    ;	// end of packet
assign t0_rspack   	= q_rspack ;	// response acknowledge
assign t0_wdata    	= q_wdata  ;	// write data
assign t0_plen     	= q_plen   ;	// packet length
assign t0_buffer    	= q_buffer  ;	// buffer transfer
assign t0_cache     	= q_cache   ;	// cache transfer
assign t0_mode      	= q_mode    ;	// data or opcode tranfer
assign t0_priv      	= q_priv    ;	// privilege transfer
assign q_cmdack   	= t0_cmdack ;	// command acknowledge
assign q_rdata    	= t0_rdata  ;	// read data
assign q_reop     	= t0_reop   ;	// response end of packet
assign q_rspval   	= t0_rspval ;	// response valid

assign t1_address	= 0;
assign t1_be     	= 0;
assign t1_cmd    	= 0;
assign t1_cmdval 	= 0;
assign t1_eop    	= 0;
assign t1_rspack 	= 0;
assign t1_wdata  	= 0;
assign t1_plen   	= 0;
assign t1_buffer  	= 0;
assign t1_cache   	= 0;
assign t1_mode    	= 0;
assign t1_priv    	= 0;

assign t2_address	= 0;
assign t2_be     	= 0;
assign t2_cmd    	= 0;
assign t2_cmdval 	= 0;
assign t2_eop    	= 0;
assign t2_rspack 	= 0;
assign t2_wdata  	= 0;
assign t2_plen   	= 0;
assign t2_buffer  	= 0;
assign t2_cache   	= 0;
assign t2_mode    	= 0;
assign t2_priv    	= 0;

assign t3_address	= 0;
assign t3_be     	= 0;
assign t3_cmd    	= 0;
assign t3_cmdval 	= 0;
assign t3_eop    	= 0;
assign t3_rspack 	= 0;
assign t3_wdata  	= 0;
assign t3_plen   	= 0;
assign t3_buffer  	= 0;
assign t3_cache   	= 0;
assign t3_mode    	= 0;
assign t3_priv    	= 0;

assign t4_address	= 0;
assign t4_be     	= 0;
assign t4_cmd    	= 0;
assign t4_cmdval 	= 0;
assign t4_eop    	= 0;
assign t4_rspack 	= 0;
assign t4_wdata  	= 0;
assign t4_plen   	= 0;
assign t4_buffer  	= 0;
assign t4_cache   	= 0;
assign t4_mode    	= 0;
assign t4_priv    	= 0;

assign clk_ext      = clk_system;
assign mem_access = ibus_busy;
assign memory_error = (iarb_rerror & iarb_rspval)
		       
			;
   
endmodule // module ibus
