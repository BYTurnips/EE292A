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
module ibus_iarb (

   // INPUTS =========================================================
    
   // clocks and resets ----------------------------------------------

   clk,
   rst_a,

   // Target Port 0 with Highest Prioirty ----------------------------
   t0_address,
   t0_be,
   t0_cmd,
   t0_eop,
   t0_plen,
   t0_wdata,
   t0_cmdval,
   t0_rspack,
   t0_priv,
   t0_buffer,
   t0_cache,
   t0_mode,
   // Target Port 1 with High Priority -------------------------------
   t1_address,
   t1_be,
   t1_cmd,
   t1_eop,
   t1_plen,
   t1_wdata,
   t1_cmdval,
   t1_rspack,
   t1_priv,
   t1_buffer,
   t1_cache,
   t1_mode,
   // Target Port 2 with Medium Priority -----------------------------
   t2_address,
   t2_be,
   t2_cmd,
   t2_eop,
   t2_plen,
   t2_wdata,
   t2_cmdval,
   t2_rspack,
   t2_priv,
   t2_buffer,
   t2_cache,
   t2_mode,
   // Target Port 3 with Low Priority --------------------------------
   t3_address,
   t3_be,
   t3_cmd,
   t3_eop,
   t3_plen,
   t3_wdata,
   t3_cmdval,
   t3_rspack,
   t3_priv,
   t3_buffer,
   t3_cache,
   t3_mode,

   // Target Port 4 with Lowest Priority -----------------------------
   t4_address,
   t4_be,
   t4_cmd,
   t4_eop,
   t4_plen,
   t4_wdata,
   t4_cmdval,
   t4_rspack,
   t4_priv,
   t4_buffer,
   t4_cache,
   t4_mode,

   // Initiator Port -------------------------------------------------
   i_cmdack,
   i_rdata,
   i_reop,
   i_rspval,

   // OUTPUTS ========================================================

   // Target Port 0 with Highest Prioirty ----------------------------
   t0_cmdack,
   t0_rdata,
   t0_reop,
   t0_rspval,

   // Target Port 0 with High Prioirty -------------------------------
   t1_cmdack,
   t1_rdata,
   t1_reop,
   t1_rspval,

   // Target Port 0 with Medium Prioirty -----------------------------
   t2_cmdack,
   t2_rdata,
   t2_reop,
   t2_rspval,

   // Target Port 0 with Low Prioirty --------------------------------
   t3_cmdack,
   t3_rdata,
   t3_reop,
   t3_rspval,

   // Target Port 0 with Lowest Priority -----------------------------
   t4_cmdack,
   t4_rdata,
   t4_reop,
   t4_rspval,

   // Initiator Port -------------------------------------------------
   i_address,
   i_be,
   i_cmd,
   i_eop,
   i_plen,
   i_wdata,
   i_cmdval,
   i_rspack,
   i_buffer,
   i_priv,
   i_cache,
   i_mode,
   // Busy signal ----------------------------------------------------
   iarb_busy

);

parameter ADDR_WIDTH = 32;
parameter DATA_WIDTH = 64;
parameter BE_WIDTH   = 8;
parameter FIFO_DEPTH = 4;


//  INPUTS =========================================================

//  clocks and resets ----------------------------------------------
input   clk; 
input   rst_a; 
//  Target Port 0 with Highest Priority ----------------------------
input   [ADDR_WIDTH - 1:0] t0_address; 
input   [BE_WIDTH-1:0] t0_be; 
input   [1:0] t0_cmd; 
input   t0_eop; 
input   [8:0] t0_plen; 
input   [DATA_WIDTH - 1:0] t0_wdata; 
input   t0_cmdval; 
input   t0_rspack; 
input   t0_cache; 
input   t0_priv; 
input   t0_buffer; 
input   t0_mode; 
 
//  Target Port 1 with High Priority -------------------------------
input   [ADDR_WIDTH - 1:0] t1_address; 
input   [BE_WIDTH-1:0] t1_be; 
input   [1:0] t1_cmd; 
input   t1_eop; 
input   [8:0] t1_plen; 
input   [DATA_WIDTH - 1:0] t1_wdata; 
input   t1_cmdval; 
input   t1_rspack; 
input   t1_cache; 
input   t1_priv; 
input   t1_buffer; 
input   t1_mode; 
 
//  Target Port 2 with Medium Priority -----------------------------
input   [ADDR_WIDTH - 1:0] t2_address; 
input   [BE_WIDTH-1:0] t2_be; 
input   [1:0] t2_cmd; 
input   t2_eop; 
input   [8:0] t2_plen; 
input   [DATA_WIDTH - 1:0] t2_wdata; 
input   t2_cmdval; 
input   t2_rspack; 
input   t2_cache; 
input   t2_priv; 
input   t2_buffer; 
input   t2_mode; 
 
//  Target Port 3 with Low Priority --------------------------------
input   [ADDR_WIDTH - 1:0] t3_address; 
input   [BE_WIDTH-1:0] t3_be; 
input   [1:0] t3_cmd; 
input   t3_eop; 
input   [8:0] t3_plen; 
input   [DATA_WIDTH - 1:0] t3_wdata; 
input   t3_cmdval; 
input   t3_rspack; 
input   t3_cache; 
input   t3_priv; 
input   t3_buffer; 
input   t3_mode; 
 
//  Target Port 4 with Lowest Priority -----------------------------
input   [ADDR_WIDTH - 1:0] t4_address; 
input   [BE_WIDTH-1:0] t4_be; 
input   [1:0] t4_cmd; 
input   t4_eop; 
input   [8:0] t4_plen; 
input   [DATA_WIDTH - 1:0] t4_wdata; 
input   t4_cmdval; 
input   t4_rspack; 
input   t4_cache; 
input   t4_priv; 
input   t4_buffer; 
input   t4_mode; 
 
//  Initiator Port -------------------------------------------------
input   i_cmdack; 
input   [DATA_WIDTH - 1:0] i_rdata; 
input   i_reop; 
input   i_rspval; 

//  OUTPUTS ========================================================

//  Target Port 0 with Highest Priority ----------------------------
output   t0_cmdack; 
output   [DATA_WIDTH - 1:0] t0_rdata; 
output   t0_reop; 
output   t0_rspval; 
//  Target Port 2 with Medium Priority -----------------------------
output   t1_cmdack; 
output   [DATA_WIDTH - 1:0] t1_rdata; 
output   t1_reop; 
output   t1_rspval; 
//  Target Port 2 with Medium Priority -----------------------------
output   t2_cmdack; 
output   [DATA_WIDTH - 1:0] t2_rdata; 
output   t2_reop; 
output   t2_rspval; 
//  Target Port 3 with Low Priority --------------------------------
output   t3_cmdack; 
output   [DATA_WIDTH - 1:0] t3_rdata; 
output   t3_reop; 
output   t3_rspval; 
//  Target Port 4 with Lowest Priority -----------------------------
output   t4_cmdack; 
output   [DATA_WIDTH - 1:0] t4_rdata; 
output   t4_reop; 
output   t4_rspval; 
//  Initiator Port -------------------------------------------------
output   [ADDR_WIDTH - 1:0] i_address; 
output   [BE_WIDTH-1:0] i_be; 
output   [1:0] i_cmd; 
output   i_eop; 
output   [8:0] i_plen; 
output   [DATA_WIDTH - 1:0] i_wdata; 
output   i_cmdval; 
output   i_rspack; 
//  Busy signal ----------------------------------------------------
output   iarb_busy; 
output   i_cache; 
output   i_priv; 
output   i_buffer; 
output   i_mode; 
 
reg     t0_cmdack; 
wire    [DATA_WIDTH - 1:0] t0_rdata; 
wire    t0_reop; 
reg     t0_rspval; 
reg     t1_cmdack; 
wire    [DATA_WIDTH - 1:0] t1_rdata; 
wire    t1_reop; 
reg     t1_rspval; 
reg     t2_cmdack; 
wire    [DATA_WIDTH - 1:0] t2_rdata; 
wire    t2_reop; 
reg     t2_rspval; 
reg     t3_cmdack; 
wire    [DATA_WIDTH - 1:0] t3_rdata; 
wire    t3_reop; 
reg     t3_rspval; 
reg     t4_cmdack; 
wire    [DATA_WIDTH - 1:0] t4_rdata; 
wire    t4_reop; 
reg     t4_rspval; 
reg     [ADDR_WIDTH - 1:0] i_address; 
reg     [BE_WIDTH-1:0] i_be; 
wire    [1:0] i_cmd; 
wire    i_eop; 
reg     [8:0] i_plen; 
reg     [DATA_WIDTH - 1:0] i_wdata; 
wire    i_cmdval; 
wire    i_rspack; 
wire    iarb_busy; 
reg    i_cache; 
reg    i_priv; 
reg    i_buffer; 
reg    i_mode; 
 

// ============================================================================
// CONSTANT DECLARATIONS 
// ============================================================================

parameter FIFO_WIDTH     = 3;    //  Width of FIFO. 
parameter FIFO_PTR_WIDTH = 3;    //  Pointer counter width.
parameter CMD_ST_ARB     = 1'b0; //  Command Control ARB state
parameter CMD_ST_HOLD    = 1'b1; //  Command Control HOLD state

//  ============================================================================
//  SIGNAL DECLARATIONS 
//  ============================================================================

//  Command Arbitrator
wire    [FIFO_WIDTH - 1:0] cmd_arb; 
reg     [FIFO_WIDTH - 1:0] cmd_arb_hold_r; 
reg     [FIFO_WIDTH - 1:0] cmd_sel; 
reg                        cmd_state_r; 
reg                        cmd_lock_r; 
reg                        cmd_inhibit_n; 
reg                        cmd_load; 
reg                        cmd_state_next;
reg                        cmd_lock_next; 
reg     [FIFO_WIDTH - 1:0] cmd_arb_hold_next; 
reg                        i_eop_int; 
reg                        i_cmdval_int_r; 
reg     [1:0]              i_cmd_int;   

//  Packet Tracking FIFO
wire                                    fifo_full; 
wire                                    fifo_load; 
wire                                    fifo_unload;
reg     [FIFO_DEPTH * FIFO_WIDTH - 1:0] fifo_regs_r; 
wire    [FIFO_WIDTH - 1:0]              fifo_in; 
wire    [FIFO_WIDTH - 1:0]              fifo_out;
reg     [FIFO_PTR_WIDTH - 1:0]          fifo_ptr_r; 
wire    [FIFO_PTR_WIDTH - 1:0]          fifo_ptr_m1; 
wire    [FIFO_PTR_WIDTH - 1:0]          fifo_ptr_p1; 
wire    [FIFO_PTR_WIDTH - 1:0]          fifo_ptr_muxed; 
wire                                    fifo_empty_n;

//  Response Switch
wire    [FIFO_WIDTH - 1:0] rsp_sel; 
wire                       rsp_unload; 
reg                        i_rspack_int_r; 

integer  dcnt; 
integer  wcnt;

//  ============================================================================
//  ARCHITECTURE
//  ============================================================================

//  ------------------------------------------------------------------------
//  Command Arbitrartor ----------------------------------------------------
//  ------------------------------------------------------------------------

//  Arbitration Logic ------------------------------------------------------
//  t0 has highest priority
//  t2 has lowest priority
//                                          T4  T3  T2  T1  T0  cmd_arb

assign cmd_arb[0] =  (   t1_cmdval 
                      & ~t0_cmdval)      //  X   X   X   1   0     001
                    |(   t3_cmdval
                      & ~t2_cmdval
                      & ~t1_cmdval
                      & ~t0_cmdval);     //  X   1   0   0   0     011

assign cmd_arb[1] =  (   t2_cmdval
                      & ~t1_cmdval
                      & ~t0_cmdval)      //  X   X   1   0   0     010
                    |(   t3_cmdval
                      & ~t2_cmdval
                      & ~t1_cmdval
                      & ~t0_cmdval);     //  X   1   0   0   0     011

assign cmd_arb[2] =  (   t4_cmdval
                      & ~t3_cmdval
                      & ~t2_cmdval
                      & ~t1_cmdval
                      & ~t0_cmdval);     //  1   0   0   0   0     100

//  Command cell mulitplexer and inhibitor ---------------------------------

always @(    t0_address
          or t0_be
          or t0_cmd
          or t0_eop
          or t0_plen
          or t0_wdata
          or t0_cache 
          or t0_priv
          or t0_buffer 
          or t0_mode 
 	  
          or t1_address 	  
          or t1_be 
          or t1_cmd 
          or t1_eop
          or t1_plen 
          or t1_wdata
          or t1_cache 
          or t1_priv
          or t1_buffer 
          or t1_mode 
 	  
          or t2_address 
          or t2_be 
          or t2_cmd
          or t2_eop 
          or t2_plen 
          or t2_wdata
          or t2_cache 
          or t2_priv
          or t2_buffer 
          or t2_mode 
	   
          or t3_address 
          or t3_be
          or t3_cmd 
          or t3_eop 
          or t3_plen 
          or t3_wdata
          or t3_cache 
          or t3_priv
          or t3_buffer 
          or t3_mode 
	   
          or t4_address
          or t4_be 
          or t4_cmd 
          or t4_eop 
          or t4_plen 
          or t4_wdata
          or t4_cache 
          or t4_priv
          or t4_buffer 
          or t4_mode 
	  
          or cmd_sel
         )
begin : CMDMUX_PROC
  case (cmd_sel)
    3'b000,
    3'b101,
    3'b110,
    3'b111:
    begin
       i_address = t0_address;   
       i_be      = t0_be;   
       i_cmd_int = t0_cmd;   
       i_eop_int = t0_eop;   
       i_plen    = t0_plen;   
       i_wdata   = t0_wdata;
       i_cache   = t0_cache; 
       i_priv    = t0_priv;
       i_buffer  = t0_buffer; 
       i_mode    = t0_mode; 
           
    end
    3'b001:
    begin
       i_address = t1_address;   
       i_be      = t1_be;   
       i_cmd_int = t1_cmd;   
       i_eop_int = t1_eop;   
       i_plen    = t1_plen;   
       i_wdata   = t1_wdata; 
       i_cache   = t1_cache; 
       i_priv    = t1_priv;
       i_buffer  = t1_buffer; 
       i_mode    = t1_mode; 
          
    end
    3'b010:
    begin
       i_address = t2_address;   
       i_be      = t2_be;   
       i_cmd_int = t2_cmd;   
       i_eop_int = t2_eop;   
       i_plen    = t2_plen;   
       i_wdata   = t2_wdata; 
       i_cache   = t2_cache; 
       i_priv    = t2_priv;
       i_buffer  = t2_buffer; 
       i_mode    = t2_mode; 
          
    end
    3'b011:
    begin
       i_address = t3_address;   
       i_be      = t3_be;   
       i_cmd_int = t3_cmd;   
       i_eop_int = t3_eop;   
       i_plen    = t3_plen;   
       i_wdata   = t3_wdata; 
       i_cache   = t3_cache; 
       i_priv    = t3_priv;
       i_buffer  = t3_buffer; 
       i_mode    = t3_mode; 
           
    end
    3'b100:
    begin
       i_address = t4_address;   
       i_be      = t4_be;   
       i_cmd_int = t4_cmd;   
       i_eop_int = t4_eop;   
       i_plen    = t4_plen;   
       i_wdata   = t4_wdata; 
       i_cache   = t4_cache; 
       i_priv    = t4_priv;
       i_buffer  = t4_buffer; 
       i_mode    = t4_mode; 
           
    end
    default;
  endcase
end

//  Command Valid Handshake Muliplexer and inhibitor -----------------------
always @(   t0_cmdval
         or t1_cmdval
         or t2_cmdval
         or t3_cmdval
         or t4_cmdval
         or cmd_sel
         or cmd_inhibit_n
        )
begin : CMVLMI_PROC
  if (cmd_inhibit_n == 1'b0)
  begin
    i_cmdval_int_r = 1'b0;   
  end
  else
  begin
    case (cmd_sel)
      3'b000,
      3'b101,
      3'b110,
      3'b111:
      begin
        i_cmdval_int_r = t0_cmdval;   
      end
      3'b001:
      begin
        i_cmdval_int_r = t1_cmdval;   
      end
      3'b010:
      begin
        i_cmdval_int_r = t2_cmdval;   
      end
      3'b011:
      begin
        i_cmdval_int_r = t3_cmdval;   
      end
      3'b100:
      begin
        i_cmdval_int_r = t4_cmdval;   
      end
      default;
    endcase
  end
end

//  Command Acknowleddement Handshake Switch and inhibitor ------------
always @(   i_cmdack 
         or cmd_inhibit_n
         or cmd_sel
        )
  begin : CMAKMI_PROC
  if (cmd_inhibit_n == 1'b0)
  begin
    t0_cmdack = 1'b0;   
    t1_cmdack = 1'b0;   
    t2_cmdack = 1'b0;   
    t3_cmdack = 1'b0;   
    t4_cmdack = 1'b0;   
  end
  else
  begin
    case (cmd_sel)
      3'b000,
      3'b101,
      3'b110,
      3'b111:
      begin
        t0_cmdack = i_cmdack;   
        t1_cmdack = 1'b0;   
        t2_cmdack = 1'b0;   
        t3_cmdack = 1'b0;   
        t4_cmdack = 1'b0;   
      end
      3'b001:
      begin
        t0_cmdack = 1'b0;   
        t1_cmdack = i_cmdack;   
        t2_cmdack = 1'b0;   
        t3_cmdack = 1'b0;   
        t4_cmdack = 1'b0;   
      end
      3'b010:
      begin
        t0_cmdack = 1'b0;   
        t1_cmdack = 1'b0;   
        t2_cmdack = i_cmdack;   
        t3_cmdack = 1'b0;   
        t4_cmdack = 1'b0;   
      end
      3'b011:
      begin
        t0_cmdack = 1'b0;   
        t1_cmdack = 1'b0;   
        t2_cmdack = 1'b0;   
        t3_cmdack = i_cmdack;   
        t4_cmdack = 1'b0;   
      end
      3'b100:
      begin
        t0_cmdack = 1'b0;   
        t1_cmdack = 1'b0;   
        t2_cmdack = 1'b0;   
        t3_cmdack = 1'b0;   
        t4_cmdack = i_cmdack;   
      end
      default;
    endcase
  end
end

//  Command Control --------------------------------------------------------
always @(   cmd_state_r
         or i_cmdval_int_r
         or i_cmdack
         or i_eop_int
         or i_cmd_int
         or fifo_full 
         or cmd_arb
         or cmd_arb_hold_r
         or cmd_lock_r
        )
begin : CCTRL_NXT_PROC

  cmd_state_next    = cmd_state_r;   
  cmd_lock_next     = cmd_lock_r;   
  cmd_arb_hold_next = cmd_arb_hold_r;   

  //  State Transistion ------------------------------
  
  case (cmd_state_r)
  
    //  Arbitration State --------------------------
    CMD_ST_ARB:
    begin

      //  Command state transistion
      if (   (   (   (i_cmdval_int_r == 1'b1)
                  && (i_cmdack == 1'b0))
              || (   (i_cmdval_int_r == 1'b1)
                  &&(i_cmdack == 1'b1)
                  &&(i_eop_int == 1'b0)))
          && (fifo_full == 1'b0))
      begin
        cmd_state_next = CMD_ST_HOLD;   
      end

      //  cmd_arb_hold_r next value
      if (cmd_lock_r == 1'b0)
      begin
         cmd_arb_hold_next = cmd_arb;   
      end
      
      //  cmd_lock_r next value
      if (cmd_lock_r == 1'b0)
      begin
        if (   (i_cmdval_int_r == 1'b1)
            && (i_cmd_int == 2'b11)
            && (fifo_full == 1'b0))
        begin
          cmd_lock_next = 1'b1;   
        end
      end
      else //  (cmd_lock_r = '1')
      begin
        if (   (i_cmdval_int_r == 1'b1)
            && (i_cmd_int == 2'b10)
            && (fifo_full == 1'b0))
        begin
            cmd_lock_next = 1'b0;   
        end
      end

    end

    //  Hold State ---------------------------------
    CMD_ST_HOLD:
    begin
      if (   (i_cmdval_int_r == 1'b1)
          && (i_cmdack == 1'b1)
          && (i_eop_int == 1'b1))
      begin
        cmd_state_next = CMD_ST_ARB;   
      end
    end
   
    default;
    
  endcase

  //  Control Signal Decoding ----------------------------------

  // only inhibit a new packet, not one that is already ongoing
  if (cmd_state_r == CMD_ST_ARB)
  begin
    cmd_inhibit_n = ~fifo_full;
  end
  else
  begin
    cmd_inhibit_n = 1'b1;
  end
  
  if (   (cmd_state_r == CMD_ST_HOLD)
      || (cmd_lock_r == 1'b1))
  begin
    cmd_sel = cmd_arb_hold_r;   
  end
  else
  begin
    cmd_sel = cmd_arb;   
  end
  
  if (   (cmd_state_r == CMD_ST_ARB)
      && (i_cmdval_int_r == 1'b1)
      && (fifo_full == 1'b0))
  begin
    cmd_load = 1'b1;   
  end
  else
  begin
    cmd_load = 1'b0;   
  end

end

always @(posedge clk or posedge rst_a)
begin : CCTRL_STATE_PROC
  if (rst_a == 1'b1)
  begin
    cmd_state_r    <= CMD_ST_ARB;   
    cmd_lock_r     <= 1'b0;   
    cmd_arb_hold_r <= {FIFO_WIDTH{1'b0}};   
  end
  else
  begin
    cmd_state_r    <= cmd_state_next;   
    cmd_lock_r     <= cmd_lock_next;   
    cmd_arb_hold_r <= cmd_arb_hold_next;   
  end
end

//  Wiring up the rest -----------------------------------------------------

assign i_eop    = i_eop_int; 
assign i_cmdval = i_cmdval_int_r; 
assign i_cmd    = i_cmd_int; 


//  ------------------------------------------------------------------------
//  Packet Tracking FIFO ---------------------------------------------------
//  ------------------------------------------------------------------------

//  Storage Registers loading and unloading --------------------------------

always @(posedge clk or posedge rst_a)
begin : FIFO_MEM_PROC

  if (rst_a == 1'b 1)
  begin
    fifo_regs_r <= {(FIFO_DEPTH * FIFO_WIDTH - 1 - 0 + 1){1'b 0}};   
  end
  else
  begin

    //  unload from fifo
        //  IF formality work around is needed use the following instead
        //  if ((fifo_unload == '1')and(FIFO_DEPTH > 1))
    if (fifo_unload == 1'b 1)
    begin
      for (dcnt = FIFO_DEPTH - 2; dcnt >= 0; dcnt = dcnt - 1)
      begin
        for (wcnt = FIFO_WIDTH - 1; wcnt >= 0; wcnt = wcnt - 1)
        begin
          fifo_regs_r[dcnt * FIFO_WIDTH + wcnt] <= fifo_regs_r[(dcnt + 1) * FIFO_WIDTH + wcnt];
        end
      end
    end
    
    //  load fifo
    if (fifo_load == 1'b 1)
    begin
      //  This work around is needed here for Formality.
      for (dcnt = FIFO_DEPTH - 1; dcnt >= 0; dcnt = dcnt - 1)
      begin
        if (dcnt == fifo_ptr_muxed)
        begin
          for (wcnt = FIFO_WIDTH - 1; wcnt >= 0; wcnt = wcnt - 1)
          begin
            fifo_regs_r[dcnt * FIFO_WIDTH + wcnt] <= fifo_in[wcnt];   
          end
        end
      end
    end

  end
end

//  Use fifo_ptr_m1 when unloading at the same time as loading.
assign fifo_ptr_muxed = (fifo_unload == 1'b1)? fifo_ptr_m1 : fifo_ptr_r; 

//  FIFO pointer update ----------------------------------------------------

always @(posedge clk or posedge rst_a)
begin : FIFO_PTR_PROC
  if (rst_a == 1'b1)
  begin
    fifo_ptr_r <= {FIFO_PTR_WIDTH{1'b0}};   
  end
  else
  begin
    if (fifo_load == 1'b0)
    begin
      if ((fifo_unload == 1'b1)&&(fifo_ptr_r != 0))
      begin
        fifo_ptr_r <= fifo_ptr_m1;
      end
    end
    else //  (fifo_load = '1')
    begin
      if ((fifo_unload == 1'b0)&&(fifo_ptr_r != FIFO_DEPTH))
      begin
        fifo_ptr_r <= fifo_ptr_p1;
      end
    end
  end
end

assign fifo_ptr_p1 = fifo_ptr_r + 1'b1; 
assign fifo_ptr_m1 = fifo_ptr_r - 1'b1; 

//  FIFO full signal -------------------------------------------------------

assign fifo_full = (fifo_ptr_r == FIFO_DEPTH)? 1'b1 : 1'b0; 

//  FIFO output ------------------------------------------------------------

assign fifo_out = fifo_regs_r[FIFO_WIDTH - 1:0]; 

//  FIFO empty -------------------------------------------------------------

assign fifo_empty_n = (fifo_ptr_r == {FIFO_WIDTH{1'b0}})? 1'b0 : 1'b1; 

//  Wiring up FIFO ---------------------------------------------------------

assign fifo_in     = cmd_sel; 
assign fifo_load   = cmd_load; 
assign fifo_unload = rsp_unload; 
assign rsp_sel     = (~fifo_empty_n)? cmd_sel : fifo_out;
assign iarb_busy   = fifo_empty_n; 


//  ------------------------------------------------------------------------
//  Response Switch --------------------------------------------------------
//  ------------------------------------------------------------------------

//  Response valid switch --------------------------------------------------

always @(i_rspval or rsp_sel)
begin : RSPSW_PROC
  case (rsp_sel)
    3'b000,
    3'b101,
    3'b110,
    3'b111:
    begin
      t0_rspval = i_rspval;   
      t1_rspval = 1'b0;   
      t2_rspval = 1'b0;   
      t3_rspval = 1'b0;   
      t4_rspval = 1'b0;   
    end
    3'b001:
    begin
      t0_rspval = 1'b0;   
      t1_rspval = i_rspval;   
      t2_rspval = 1'b0;   
      t3_rspval = 1'b0;   
      t4_rspval = 1'b0;   
    end
    3'b010:
    begin
      t0_rspval = 1'b0;   
      t1_rspval = 1'b0;   
      t2_rspval = i_rspval;   
      t3_rspval = 1'b0;   
      t4_rspval = 1'b0;   
    end
    3'b011:
    begin
      t0_rspval = 1'b0;   
      t1_rspval = 1'b0;   
      t2_rspval = 1'b0;   
      t3_rspval = i_rspval;   
      t4_rspval = 1'b0;   
    end
    3'b100:
    begin
      t0_rspval = 1'b0;   
      t1_rspval = 1'b0;   
      t2_rspval = 1'b0;   
      t3_rspval = 1'b0;   
      t4_rspval = i_rspval;   
    end
    default;
  endcase
end

//  Response acknowledgement mulitplexer -----------------------------------

always @(   t0_rspack
         or t1_rspack
         or t2_rspack
         or t3_rspack
         or t4_rspack
         or rsp_sel
        )
begin : RSPMX_PROC
  case (rsp_sel)
    3'b000,
    3'b101,
    3'b110,
    3'b111:
    begin
      i_rspack_int_r = t0_rspack;   
    end
    3'b 001:
    begin
      i_rspack_int_r = t1_rspack;   
    end
    3'b 010:
    begin
      i_rspack_int_r = t2_rspack;   
    end
    3'b 011:
    begin
      i_rspack_int_r = t3_rspack;   
    end
    3'b 100:
    begin
      i_rspack_int_r = t4_rspack;   
    end
    default;
  endcase
end

//  Response Control -------------------------------------------------------

assign rsp_unload = i_rspack_int_r & i_rspval & i_reop; 

//  Wiring up The rest of the response bus ---------------------------------

assign i_rspack = i_rspack_int_r; 
assign t0_rdata = i_rdata; 
assign t0_reop  = i_reop; 
assign t1_rdata = i_rdata; 
assign t1_reop  = i_reop; 
assign t2_rdata = i_rdata; 
assign t2_reop  = i_reop; 
assign t3_rdata = i_rdata; 
assign t3_reop  = i_reop; 
assign t4_rdata = i_rdata; 
assign t4_reop  = i_reop; 

//  ------------------------------------------------------------------------
//  ------------------------------------------------------------------------
//  ------------------------------------------------------------------------

endmodule // module ibus_iarb

