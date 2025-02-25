// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 2000-2012 ARC International (Unpublished)
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
// The Debug Access Unit allows access to the load/store memory space
// through the debug interface (i.e. the PC port or the JTAG port).
//
// L indicates a latched signal and U indicates a signal produced by
// logic.
// 
// ======================= Inputs to this block =======================--
// 
//  clk_dmp          DMP clock domain.
// 
//  rst_a            L Latched external reset signal. The rst_a signal is
//                   asynchronously applied and synchronously removed.
// 
//  en               L The global halt bit.
// 
//  pcp_wr_rq        U Debug interface write request. This is produced by
//                   the debug interface (PC/JTAG port). This signal is
//                   reset when the request has been acknowledged
//                   (pcp_ack ='1').
// 
//  pcp_rd_rq        U Debug interface read request. This is produced by
//                   the  debug interface (PC/JTAG port). This signal is
//                   reset when the request has been acknowledged
//                   (pcp_ack ='1').
// 
//  pcp_addr         U Debug interface address. The address to which the
//                   memory transaction is to take place and should be
//                   valid when the debug interface request signal is
//                   high. This address bus is 24 bits wide.
// 
//  pcp_d_wr         U Debug interface write data. The data must be valid
//                   when the write request is made (pcp_wr_rq = '1').
//   
//  dwr[31:0]        Load Store Write data. Data value to be stored to
//                   memory. It is latched stval from the ARC interface.
//                   The value is latched when en2='1', i.e. the pipeline
//                   is not stalled.
// 
//  en3              U Pipeline stage 3 enable. When this signal is true,
//                   the instruction in stage 3 can pass into stage 4 at
//                   the end of the cycle. When it is false, it will
//                   probably hold up stages one (pcen), two (en2), and
//                   three. It is also used to qualify mload & mstore.
// 
//  mc_addr[]        Load Store Address. The result of the adder unit. 
//                   This goes to LSU, to be latched by the memory
//                   controller. The address is valid when either mload 
//                   OR mstore is active.
// 
//  mload            U Load Data. This signal indicates to the LSU that
//                   there is a valid load instruction in stage 3. It is
//                   produced from a decode of p3i[4:0], p3iw(25) (to
//                   exclude LR) and the p3iv signal.
//  
//  mstore           U Store Data. This signal indicates to the LSU that
//                   there is a valid store instruction in stage 3. It is
//                   produced from a decode of p3i[4:0], p3iw(25) (to
//                   exclude SR) and the p3iv signal.
// 
//  nocache          L No Data Cache. This signal is used to indicate to
//                   the LSU whether the load/store operation is required
//                   to bypass the cache. It comes from bit 5 of the
//                   LD/ST control group which is found in different
//                   places in the LDO/LDR/ST instructions.
// 
//  sex              L Sign extend. This signal is used to indicate to
//                   the LSU whether a sign-extended load is required. It
//                   is produced during stage 2 and latched as the
//                   sign-extend bit in the two versions of the LD
//                   instruction (LDO/LDR) are in different places in the
//                   instruction word.
// 
//  size[1:0]        L Size of Transfer. This pair of signals are used to
//                   indicate to the LSU the size of the memory 
//                   transaction which is being requested by a LD or ST 
//                   instruction. It is produced during stage 2 and
//                   latched as the size information bits are encoded in 
//                   different places on the LD and ST instructions. It
//                   must be qualified by the mload/mstore signals as it
//                   does not include an opcode decode.
// 
//                   The encoding for the size of the transfer is as
//                   follows:
// 
//                       00 - Long word
//                       01 - byte
//                       10 - word
//                       11 - Reserved
// 
//  lpending         U Indicates to ARC that there is at least one load
//                   pending. It is the inverse of the empty flag from
//                   the scoreboard.
// 
//  max_one_lpend    L Indicates that the LSU contains zero or one
//                   pending load. It is generated from the inverse of
//                   the status flag of the second fifo item in the LSU.
//                   If the second fifo item is empty, then the LSU
//                   cannot contain more than at most one pending load.
//                   This signal is used by the DMP control logic.
// 
//  dmp_drd          Load return data. This is the 32 bit result of a
//                   load returned from any of the DMP sub-modules or a
//                   peripheral via the load return arbitrator.
// 
//  dmp_ldvalid      U Load data valid. This signal is set true when the
//                   load return data from the load return arbitrator
//                   (dmp_drd) is valid.
// 
//  mwait            U Wait. This signal is set true by a DMP sub-module
//                   or a peripheral in order to hold up stages 1, 2, and
//                   3. It is used when a DMP sub-module/peripheral
//                   cannot service a memory data request (LD/ST) in
//                   pipeline stage 3.
//
//  dmp_idle         U The DMP idle signal is set when all DMP
//                   sub-modules and peripherals are idle.
//   
// ====================== Outputs from this block =====================--
// 
// debug_if_r        Debug Memory Access. This is asserted true when a debug
//                   access to memory is in progress.
//
//  PC Port/JTAG Port interface
// 
//  pcp_d_rd         U Load return data. This is the 32 bit result of a
//                   load returned from any of the DMP sub-modules
//                   (except data-cache) or peripheral via the load
//                   return arbitrator. It comes as a result of a debug
//                   access read request (pcp_rd_rq = '1').
// 
//  pcp_ack          U Debug interface request acknowledge. This set
//                   to '1' for a single cycle to acknowledge the
//                   receipt of the request from the debug interface. On
//                   the cycle following the acknowledge being set the
//                   pcp_addr, pcp_wr_rq (or pcp_rd_rq) busses are no
//                   longer used by the arbitrator, hence the debug
//                   interface can therefore set up signals for the
//                   next request.
// 
//  pcp_dlat         U Load data valid for the debug interface. This
//                   signal is set true when the load return data from
//                   the load return arbitrator (pcp_d_rd) is valid.
// 
//  pcp_dak          L Write data acknowledge. This signal acknowledges
//                   the write data (pcp_d_wr). It is set in this file in
//                   debug access mode on the same cycle as the request
//                   acknowledge signal (pcp_ack).
//   
//  dmp_holdup12     U DMP hold signal for ARC pipeline stages 1-2. When
//                   the DMP receives a debug interface request this
//                   signal is set. It is used in the pipeline
//                   controller (rctl) to hold these pipeline stages if
//                   a load (LD) or store (ST) instruction enters
//                   pipeline stage 2. The reason for stalling is that 
//                   the DMP is busy servicing data memory accesses from
//                   the debug interface. However if the pipeline is
//                   free from LD/ST instructions it will continue to
//                   flow during debug access mode.
// 
//  drd              Load return data. This is the 32 bit result of a
//                   load returned from any of the DMP sub-modules or a
//                   peripheral via the load return arbitrator. This data
//                   bus is used in the ARC pipeline.
// 
//  ldvalid          U Load data valid. This signal is set true when the
//                   load return data from the load return arbitrator
//                   (drd) is valid. This signal is used in the ARC
//                   pipeline.
//  
//
//  dmp_dwr          Load Store Write data connected to the
//                   DMP/peripherals. In ARC access mode it is set to
//                   dwr and in debug access mode it is set to pcp_d_wr.
// 
//  dmp_en3          U Pipeline stage 3 enable signal connected to the
//                   DMP/peripherals. In ARC access mode it is set to
//                   en3 and in debug access mode it is high for one
//                   cycle.
// 
//  dmp_addr         Load/store address, connected to the DMP. It is set
//                   to mc_addr in ARC access mode and in debug access
//                   mode it is set to pcp_addr.
// 
//  dmp_mload        Load instruction indicator, connected to the DMP.
//                   It is set to mload in ARC access mode and to
//                   pcp_rd_rq in debug access mode.
// 
//  dmp_mstore       Store instruction indicator, connected to the DMP.
//                   It is set to mstore in ARC access mode and to
//                   pcp_wr_rq in debug access mode.
// 
//  dmp_nocache      No cache signal. This is always set in debug access
//                   mode. In ARC access mode it is set to nocache.
// 
//  dmp_sex          Sign extend signal connected to the DMP. This is
//                   always cleared in debug mode. In ARC access mode it
//                   is set to sex.
// 
//  dmp_size         Size of Transfer, connected to the DMP. This is
//                   always cleared in debug mode. In ARC access mode it
//                   is set to size.
// 
// ====================================================================--
//
module debug_access (clk_dmp,
   rst_a,
   en,
   pcp_wr_rq,
   pcp_rd_rq,
   pcp_addr,
   pcp_d_wr,
   is_local_ram,
   dwr,
   en3,
   mc_addr,
   mload,
   mstore,
   nocache,
   size,
   sex,
   lpending,
   max_one_lpend,
   dmp_drd,
   dmp_ldvalid,
   mwait,
   
   dmp_idle,
   debug_if_r,
   debug_if_a,
   pcp_d_rd,
   pcp_ack,
   pcp_dlat,
   pcp_dak,
   dmp_holdup12,
   drd,
   ldvalid,
   dmp_dwr,
   dmp_addr,
   dmp_mload,
   dmp_mstore,
   dmp_nocache,
   dmp_sex,
   dmp_size,
   dmp_en3);

`include "arcutil_pkg_defines.v" 
`include "arcutil.v" 
`include "extutil.v" 
`include "xdefs.v" 
`include "ext_msb.v"

input   clk_dmp; 
input   rst_a; 
input   en; 
input   pcp_wr_rq; 
input   pcp_rd_rq; 
input   is_local_ram; 
input   [EXT_A_MSB:0] pcp_addr;
input   [31:0] pcp_d_wr; 
input   [31:0] dwr; 
input   en3; 
input   [31:0] mc_addr; 
input   mload; 
input   mstore; 
input   nocache; 
input   [1:0] size; 
input   sex; 
input   lpending; 
input   max_one_lpend; 
input   [31:0] dmp_drd; 
input   dmp_ldvalid; 
input   mwait; 
input   dmp_idle; 

output   debug_if_r;
output   debug_if_a; 
output   [31:0] pcp_d_rd; 
output   pcp_ack; 
output   pcp_dlat; 
output   pcp_dak; 
output   dmp_holdup12; 
output   [31:0] drd; 
output   ldvalid; 
output   [31:0] dmp_dwr; 
output   [31:0] dmp_addr; 
output   dmp_mload; 
output   dmp_mstore; 
output   dmp_nocache; 
output   dmp_sex; 
output   [1:0] dmp_size; 
output   dmp_en3; 

wire    debug_if_r; 
reg     [31:0] pcp_d_rd; 
wire    pcp_ack; 
reg     pcp_dlat; 

//  ARC interface
wire    pcp_dak; 
wire    dmp_holdup12; 
reg     [31:0] drd; 

//  DMP interface
reg     ldvalid; 
reg     [31:0] dmp_dwr; 
reg     [31:0] dmp_addr; 
reg     dmp_mload; 
reg     dmp_mstore; 
reg     dmp_nocache; 
reg     dmp_sex; 
reg     [1:0] dmp_size; 
reg     dmp_en3; 

reg     i_debug_if_r; 
reg     i_pcp_ack_r; 
reg     i_pcp_dak_r; 
reg     do_access_r; 
wire    i_dmp_en3_a;
 
reg     dmp_lpending_r; 
wire    wait_for_ld; 
wire    is_host_access_local_ram; 
wire    debug_if_a; 
	


   // --------------------------------------------------------------
   //  Stall the ARC during debug access if it contains a LD/ST
   // --------------------------------------------------------------
   //  The signal dmp_holdup12 stalls pipeline stages 1-2 if there
   //  is a load (LD) or store (ST) in pipeline stage 2. This occurs
   //  when the debug interface is accessing the LD/ST memory space.
   //  The reason to stall pipeline stages 1-2 in this situation is
   //  that the Data Memory Pipeline (DMP) is busy servicing memory
   //  requests from the debug interface (i.e. PC Port or JTAG Port)
   //  and consequently no data memory request from the ARC can be
   //  serviced. Note that pipeline stage 1-2 are only stalled if
   //  pipeline stage 2 contains a LD or ST instruction. The ARC
   //  pipeline can continue to flow during debug access as long as
   //  it does not contain a LD or ST instruction.


   assign dmp_holdup12 = (pcp_rd_rq | pcp_wr_rq | i_debug_if_r); 

   // --------------------------------------------------------------
   //  Wait for pending loads
   // --------------------------------------------------------------
   //  Wait for all pending loads to complete (lpending = '1') with
   //  exception for one case. This exception occurs when there is a
   //  load in pipeline stage 3 and the ARC is halted. In this case
   //  the load has not yet been issued to the memory subsystem. The
   //  load will not complete until the pipeline is re-enabled.
   //  Conseqeuntly we cannot wait for it to complete as long as the
   //  ARC is halted. However the lpending signal is already set in
   //  pipeline stage 2. If the LSU contains only one pending load
   //  (max_one_lpend = '1' AND lpending = '1') and the ARC is
   //  halted (en = '0') and there is a load in pipeline stage 3,
   //  then we will not wait for the lpending signal to be cleared.

   assign wait_for_ld = ((lpending == 1'b 1) & 
                         (~((mload == 1'b 1) & 
                            (en == 1'b 0) & 
                            (max_one_lpend == 1'b 1)))) ? 
                        1'b 1 : 1'b 0; 

   // --------------------------------------------------------------
   //  Enter and exit the debug access mode
   // --------------------------------------------------------------
   //  When the debug interface (JTAG or PC port) requests to do a
   //  memory read (pcp_rd_rq = '1') or a memory write
   //  (pcp_wr_rq = '1') then pipeline stage 3, the DMP and the
   //  Load Scoreboard Unit (LSU) are checked before entering
   //  debug access mode. If there is a memory access to the data
   //  cache or load/store queue or peripheral (dmp_idle == '0') we
   //  wait for this to complete before entering debug access mode. 
   //  If there is no load or store in pipeline stage 3 (mload == '1'
   //  OR mstore == '1') or if the ARC is halted (en = '0') we don't
   //  wait for stage 3 to move on.
   // 
   //  We also wait for the DMP to be idle (dmp_idle = '1') and for
   //  all outstanding loads to complete (lpending = '0') before
   //  entering the debug access mode (i_debug_if_r = '1').
   // 
   //  We exit the debug access mode when there are no more requests
   //  (pcp_rd_rq = '0' AND pcp_wr_rq = '0) the DMP is idle
   //  (dmp_idle = '1') and there are no pending loads
   //  (dmp_lpending_r = '0'). Note that the ARC load pending signal
   //  (lpending) cannot be used when in debug mode because it is
   //  generated by the LSU which is not used during debug mode.

   always @(posedge clk_dmp or posedge rst_a)
     begin : debug_if_sync_PROC
        if (rst_a == 1'b 1)
          begin
             i_debug_if_r <= 1'b 0; 
          end
        else
          begin
             if (((pcp_rd_rq == 1'b 1) || (pcp_wr_rq == 1'b 1)) && 

                 (dmp_idle == 1'b 1) && 

		 
		
                 // ---------------------------------- //
                 // added condition to check for more  //
                 // than one pending loads in the LSU  //
                 // prior to giving access to the host //
                 // ---------------------------------- //

                 (wait_for_ld == 1'b 0) &&

                 (!(((mload == 1'b 1) || (mstore == 1'b 1)) &&
                   (en == 1'b 1)))) 
               begin
                  i_debug_if_r <= 1'b 1;    

               end
             else if ((pcp_rd_rq == 1'b 0) &&
                      (pcp_wr_rq == 1'b 0) && 
                      (dmp_idle  == 1'b 1) &&
                      (dmp_lpending_r == 1'b 0))
               begin
                  i_debug_if_r <= 1'b 0;    
               end
          end
     end // block: debug_if_proc

   assign is_host_access_local_ram  = (is_local_ram & pcp_wr_rq & i_debug_if_r);

   
   // --------------------------------------------------------------
   //  Servicing/acknowledging the request in debug mode
   // --------------------------------------------------------------
   //  When in debug mode (i_debug_if_r = '1') the Data Memory
   //  Pipeline (DMP) is told to service the incoming the
   //  request (i_dmp_en3_r = '1) on the same cycle as the
   //  request is acknowledged (i_pcp_ack_r = '1'). If the request
   //  is a write request the data is acknowledged on the same
   //  cycle as well. However all this only happens if no DMP
   //  sub-module is stalling incoming requests (mwait = '0'). 
   // 
   //  The cycle after all this has happened the debug
   //  interface can request a second access. If the debug
   //  interface does not request a second access the debug
   //  access will be closed (i_debug_if_r = '0') as soon as
   //  the DMP is idle and all loads have returned.

   always @(posedge clk_dmp or posedge rst_a)
     begin : serv_sync_PROC
        if (rst_a == 1'b 1)
          begin
             do_access_r <= 1'b 0;  
          end
        else
          begin

               //  Acknowledge the request (i_pcp_ack_r = '1') and tell
               //  If a write request has been issued then
               //  acknowledge the reception of the write data
               //
               if (((pcp_rd_rq == 1'b 1) | (pcp_wr_rq == 1'b 1)) & 
                  (i_debug_if_r == 1'b 1) & (i_dmp_en3_a == 1'b 0))
                 begin
                   do_access_r <= 1'b 1; 
                 end
              else if (i_dmp_en3_a == 1'b 1)
                 begin
                   do_access_r <= 1'b 0; 
                 end
	
          end
     end // block: serv_proc

   assign i_dmp_en3_a = do_access_r & !mwait;


   // --------------------------------------------------------------
   //  Access mode (either ARC or debug mode)
   // --------------------------------------------------------------
   //  Depending on the debug access control signal i_debug_if_r
   //  access to the Data Memory Pipeline is granted to either the
   //  ARC pipeline (i_debug_if_r = '0') or the debug interface
   //  (i_debug_if_r = '1'). The debug interface consists of either
   //  the PC Port or a JTAG port.

   always @(pcp_wr_rq or 
            pcp_rd_rq or pcp_addr or 
            pcp_d_wr or 
            dwr or 
            mc_addr or 
            mload or 
            mstore or 
            nocache or 
            size or 
            sex or 
            en3 or 
            dmp_drd or 
            dmp_ldvalid or 
            i_debug_if_r or 
            i_dmp_en3_a)
     
     begin : dbg_async_PROC
        if (i_debug_if_r == 1'b 0)
          begin
             //  arc access mode             
             dmp_dwr = dwr; 
             dmp_addr = mc_addr;    
             dmp_mload = mload; 
             dmp_mstore = mstore;   
             dmp_nocache = nocache; 
             dmp_sex = sex; 
             dmp_size = size;   
             dmp_en3 = en3; 
             ldvalid = dmp_ldvalid; 
             drd = dmp_drd; 
             pcp_dlat = 1'b 0;  
             pcp_d_rd = {32{1'b 0}};    
          end
        else
          begin
             //  debug access mode
             dmp_dwr = pcp_d_wr;    
             dmp_addr = {`EIGHT_ZEROS, pcp_addr};    
             dmp_mload = pcp_rd_rq; 
             dmp_mstore = pcp_wr_rq;    
             dmp_nocache = 1'b 1;   
             dmp_sex = 1'b 0;   
             dmp_size = LDST_LWORD; 
             dmp_en3 = i_dmp_en3_a; 	     
             ldvalid = 1'b 0;   
             drd = {32{1'b 0}}; 
             pcp_dlat = dmp_ldvalid;    
             pcp_d_rd = dmp_drd;    
          end
     end // block: dbg_proc

   // --------------------------------------------------------------
   //  DMP load pending signal (only used in debug mode)
   // --------------------------------------------------------------
   //  The signal dmp_lpending_r is a load pending signal that
   //  indicates when a load has been issued from the debug
   //  interface (PC/JTAG port) in debug access mode. The LSU
   //  generates a similar signal (lpending) but this is only valid
   //  for loads issued by the ARC.
   // 
   //  The signal dmp_lpending_r is set when a load is requested
   //  from the debug interface (pcp_rd_rq = '1'). The signal is
   //  cleared when the load returns (dmp_ldvalid = '1').

   always @(posedge clk_dmp or posedge rst_a)
     begin : lpending_sync_PROC
        if (rst_a == 1'b 1)
          begin
             dmp_lpending_r <= 1'b 0;   
          end
        else
          begin
             if (pcp_rd_rq == 1'b 1)
               begin
                  dmp_lpending_r <= 1'b 1;  
               end
             else if (dmp_ldvalid == 1'b 1 )
               begin
                  dmp_lpending_r <= 1'b 0;  
               end
          end
     end // block: lpending_proc

   //  Output signals used and generated in this module
   //
   assign pcp_ack    = i_dmp_en3_a; 
   assign pcp_dak    = i_dmp_en3_a & pcp_wr_rq;

			    
			    
   // Debug access signals - one synchronous the other asynchronous
   //
   assign debug_if_r = i_debug_if_r; 
   
   assign debug_if_a = (pcp_rd_rq|pcp_wr_rq) & dmp_idle & ~wait_for_ld &
                       ~i_debug_if_r &
		       ~((mload|mstore) & en);

		   
		   

endmodule

