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
// This version of the load/store queue has a two deep address queue
// for LOADS and STORES. It is capable of handling any combination of
// LOADS and STORES:
//
//  - 2 LOADS
//  - 2 STORES
//  - 1 LOAD followed by a STORE
//  - 1 STORE folowed by a LOAD
//   
// The addresses are stacked into the address queue regardless of
// whether it is a LOAD or STORE. This ensures that operations get sent
// to the the memory arbitrator in the correct order.
// 
// This also forms read/write data into the correct position in a 32 
// bit word and performs any sign extensions etc. It also generates an
// mwait signal (stall signal) to the ARC pipeline when the load/store
// queue cannot accept any further data.
// 
// The load/store queue only services loads (LD) or stores (ST) when 
// the data cache is disabled (or not in the build) or the .DI 
// extensions are used on the LD/ST instructions in the assembler code.
// Also the load/store queue does not service LD/ST instructions whose
// address is within the address ranges of the load/store RAM (if there
// is a load/store RAM in the build).
// 
// The memory arbitrator interface is fully BVCI compatible. BVCI
// stands for Basic Virtual Component Interface and is a standardised
// point to point protocol.
// 
// 
// L indicates a latched signal and U indicates a signal produced by
// logic.
//
// ======================== Inputs to this block ========================--
//
// clk_dmp          DMP clock domain.
//
// rst_a            U Global asynchronous reset signal.
//
// dmp_dwr[31:0]    U Load Store Write data. Data value to be stored to
//                  memory.
//
// dmp_en3          U Pipeline stage 3 enable. When this signal is true,
//                  a load or stor request will be serviced on the next
//                  clock edge.
//
// dmp_addr         U Load/store address connected to the DMP
//                  sub-modules (e.g. the load/store queue). The
//                  address can come from either the ARC pipeline or
//                  the debug interface depending on which module that
//                  is requesting to access memory.
//
// dmp_mload        U Load instruction indicator. When it is set either
//                  the ARC or the debug interface whish to load data
//                  from an address in the LD/ST memory space.
//
// dmp_mstore       U Store instruction indicator. When it is set either
//                  the ARC or the debug interface whish to store data
//                  to an address in the LD/ST memory space.
//
// dmp_nocache      U No cache signal. This is always set in debug
//                  access mode. In ARC access mode it is set to
//                  nocache. When the signal is set the load/store
//                  queue is servicing the load and store requests
//                  (unless they are within the address range of the
//                  LD/ST RAM).
//
// dmp_size         U Size of Transfer, connected to the DMP-submodules
//                  (e.g. the load/store queue). This is always cleared
//                  in debug mode. In ARC access mode it is controlled
//                  by the ARC pipeline.
//
// dmp_sex          U Sign extend signal connected to the DMP-submodules
//                  (e.g. the load/store queue). It is always cleared in
//                  debug mode. In ARC access mode it is controlled from
//                  the ARC pipeline.
//
// q_rdata          U Read Data. Response data (q_rdata) is the 
//                  data that is returned by the target (mem_arbitrator)
//                  to the initiator (ld/st_q) when the ld/st_q
//                  initiates a read-operation. This is a BVCI signal
//                  (read the header for information on BVCI).
//              
// lram_base        U Base address for the LD/ST RAM. The address of a
//                  memory request (dmp_addr) is compared to this
//                  auxiliary register (lram_base) in order to generate
//                  the signal is_local_ram.
//
// dc_disable_r     L The DC flag (dc_disable_r) is always set if there
//                  is no data cache in the build. If there is a data
//                  cache in the build this flag can be set from a
//                  program using LR/SR instructions. When the data
//                  cache is disabled the load/store queue will service
//                  the load and store requests (unless they are within
//                  the address range of the LD/ST RAM).
//
// q_rspack         U Response acknowledge is asserted by the 
//                  load/store queue when it is ready to receive 
//                  responses from the memory arbitrator. This signal 
//                  is permanently set as the load/store queue is always
//                  ready to recieve responses. This is a BVCI signal 
//                  (read the header for information on BVCI).
//
// q_rspval         U Response valid (q_rspval) indicates that the
//                  memory arbitrator has a valid response available.
//                  This valid response can either be returning read
//                  data or a data acknowledgement of a write data
//                  transfer. The response is transferred when q_rspval
//                  and the response acknowledgement signal q_rspack
//                  are set (q_rspack is always set). This is a BVCI 
//                  signal (read the header for information on BVCI).
//
// q_cmdack         U Command acknowledge is asserted by the memory
//                  arbitrator when a load or store command from the
//                  load/store queue has been acknowledged.
//
// q_reop           U Response end of packet is asserted by the
//                  memory arbitrator on the last cycle of a response
//                  burst. As the load/store queue never issues
//                  bursts this signal is is set whenever the valid
//                  response signal q_rspval is set. This is a BVCI
//                  signal (read the header for information on BVCI).
//
// ====================== Outputs from this block =======================--
//
// a_pc_en          U Enable for the first bank of latches for the LD
//                  queue. These latches are updated with the value of
//                  the PC of the instruction which requested each read
//                  memory transaction.
//
// b_pc_en          U Enable for the second bank of latches for the LD
//                  queue. These latches are updated with the value of
//                  the PC of the instruction which requested each read
//                  memory transaction.
//
// sel_dat          L Select the correct bank of latches for the LD/ST
//                  queue.
//
// q_drd            U Load data return bus from the load/store queue to
//                  the processor.
//
// q_ldvalid        U This signal is set when read data bus q_drd
//                  contains valid data. This signal is fed back to the
//                  processor.
//
// q_mwait          U Wait. This signal is set true by this module in
//                  order to hold up stages 1, 2, and 3 of the
//                  processor. It is used when the load/store queue
//                  cannot service a request for a memory access.
//
// q_busy           U This signal is true when there is a memory request
//                  in the queue that has not been serviced yet. It is
//                  used to generate the Data Memory Pipeline idle
//                  signal (dmp_idle) in the load return arbitrator.
//
// cgm_queue_idle   Set true when the DMP is idle and can it's clocks
//                  can be gated to save power.
//
// is_local_ram     This signal is true when the address (dmp_addr) is
//                  within the address range of the load/store RAM or 
//                  the code RAM.
// 
// is_peripheral    This signal is true when the address (dmp_addr) is
//                  within the address range of the peripherals.
// 
// q_address        U This address is issued by the load/store queue
//                  when it issues a request to the memory arbitrator.
//                  This is a BVCI signal (read the header for
//                  information on BVCI).
//
// q_eop            U End of packet (q_eop) is asserted on the last
//                  cycle of every burst request. As the load/store
//                  queue never request bursts, it is always asserted on
//                  requests. This is a BVCI signal (read the header for
//                  information on BVCI).
//
// q_plen           U BVCI packet length signal
//
// q_wdata[31:0]    L This is the write data issued by the load/store 
//                  to the memory arbitrator during a write command. 
//                  The actual data bits that are enabled during a 
//                  given cell transfer are defined by the byte enables
//                  (q_be). This is a BVCI signal (read the header for
//                  information on BVCI).
//
// q_be[3:0]        U These are the byte enables. They indicate to the
//                  memory arbitrator which bytes of the write data 
//                  are enabled. This is a BVCI signal (read the
//                  header for information on BVCI).
//                 
// q_cmd[1:0]       U This is the command bus, which defines whether
//                  a read/write operation is being requested by the
//                  load/store queue.
//
//                  The encoding is as follows according to the BVCI
//                  standard:
//
//                  01 = Read
//                  10 = Write
//                  11 = Locked read.  Optional, not supported here.
//                  00 = No operation. Optional, not supported here.
//
//                  Only the read and write operations are mandatory
//                  according to the BVCI standard. Only these two
//                  operation types are supported. Read the header for
//                  more information on BVCI.
//
// q_cmdval         U This is the request signal. When the load/store
//                  queue sets this signal it wants to perform a read
//                  or write operation depending on the value of q_cmd.
//                  The request is serviced when the command
//                  acknowledgement signal is set (q_cmdack). This is a
//                  BVCI signal (read the header for information on
//                  BVCI).
//
// q_rspack         L This is the response acknowledge signal that is
//                  used by the load/store queue to indicate to the
//                  memory arbitrator that it is prepared to receive a
//                  response. This will be permanently held high because
//                  the load/store queueu is always prepared to receive
//                  a response.
//
// ======================================================================--
//
module ldst_queue (clk_dmp,
                   rst_a,
                   dmp_dwr,
                   dmp_en3,
                   dmp_addr,
                   dmp_mload,
                   dmp_mstore,
                   dmp_nocache,
                   dmp_size,
                   dmp_sex,
                   is_local_ram,
                   is_peripheral,
                   q_cmdack,
                   q_rdata,
                   q_reop,
                   q_rspval,
                   dc_disable_r,

                   a_pc_en,
                   b_pc_en,
                   sel_dat,
                   cgm_queue_idle,
		   sync_queue_idle,
                   q_drd,
                   q_ldvalid,
                   q_mwait,
                   q_busy,
                   q_address,
                   q_wdata,
                   q_be,
                   q_cmdval,
                   q_eop,
                   q_plen,
                   q_rspack,
	           q_cache,
	           q_priv,
	           q_buffer,
	           q_mode,
		   
                   q_cmd 
                   );

`include "ext_msb.v"
`include "arcutil.v"
`include "extutil.v"
`include "xdefs.v"

// system clock
   input          clk_dmp; 

// system reset
   input          rst_a; 

// Interface to the ARC
//
   input   [31:0] dmp_dwr; 
   input          dmp_en3; 
   input   [31:0] dmp_addr; 
   input          dmp_mload; 
   input          dmp_mstore; 
   input          dmp_nocache; 
   input   [1:0]  dmp_size; 
   input          dmp_sex;

// Address range matches
//
   input          is_local_ram; 
   input          is_peripheral;


// Interface to memory arbitrator
//
   input          q_cmdack; 
   input   [31:0] q_rdata;
   input          q_reop;
   input          q_rspval;

// Auxillary Registers 
//
   input          dc_disable_r;

// Interface to the ARC
//
   output         a_pc_en; 
   output         b_pc_en; 
   output         sel_dat; 

// Clock Gating
   output         cgm_queue_idle;
   output         sync_queue_idle;
   

// Load return arbitrator interface
//
   output  [31:0] q_drd; 
   output         q_ldvalid; 
   output         q_mwait; 
   output         q_busy;

// Interface to memory arbitrator
//
   output  [EXT_A_MSB:0] q_address;
   output  [31:0] q_wdata; 
   output  [3:0] q_be; 
   output         q_cmdval;
   output         q_eop;
   output  [8:0]  q_plen;
   output         q_rspack;
   output  [1:0]  q_cmd; 
   output         q_cache;
   output         q_priv;
   output         q_buffer;
   output         q_mode;

// Internal signals
//
   wire           a_pc_en; 
   wire           b_pc_en; 
   wire           sel_dat; 

   wire    [31:0] q_drd; 
   wire           q_ldvalid; 
   wire           q_mwait; 
   wire           q_busy; 
   wire           cgm_queue_idle;
   wire           sync_queue_idle;
   wire    [EXT_A_MSB:0] q_address;
   wire    [31:0] q_wdata; 
   reg     [3:0] q_be; 
   wire           q_cmdval;
   wire           q_eop;
   wire    [8:0]  q_plen;
   wire           q_rspack;
   wire    [1:0]  q_cmd; 
   wire           q_cache;
   wire           q_priv;
   wire           q_buffer;
   wire           q_mode;

// ------------------------------------------------------------------------
   reg            i_sel_dat_r; 

   wire    [31:0] i_dwr;
   reg     [1:0]  i_wdata_shift;
// ------------------------------------------------------------------------
   reg            i_a_full_r; 
   reg            i_a_next_r; 
   reg     [EXT_A_MSB:0] i_a_addr_r; 
   reg     [1:0]  i_a_size_r; 
   reg            i_a_sex_r; 
   reg            i_a_load_r; 
   reg     [31:0] i_a_wdata_r;

// ------------------------------------------------------------------------
   reg            i_b_full_r; 
   reg            i_b_next_r; 
   reg     [EXT_A_MSB:0] i_b_addr_r; 
   reg     [1:0]  i_b_size_r; 
   reg            i_b_sex_r; 
   reg            i_b_load_r; 
   reg     [31:0] i_b_wdata_r;

// ------------------------------------------------------------------------
   wire           i_alat_full; 

// ------------------------------------------------------------------------
   wire    [1:0]  i_addr; 
   wire    [1:0]  i_size; 
   wire           i_sex;
   reg     [8:0]  i_plen; 
   reg     [1:0]  i_sel_addr; 
   reg     [1:0]  i_sel_size; 
   reg            i_sel_sex; 

// ------------------------------------------------------------------------
   wire    [EXT_A_MSB:0] i_q_address; 
   reg            i_ls_rd_rq; 
   reg            i_ls_wr_rq; 
   wire           is_queue; 
   wire           i_q_ldvalid;
   wire           i_queue_idle;

// ------------------------------------------------------------------------
   reg     [1:0]  i_fifo_addr0_r;
   reg     [1:0]  i_fifo_addr1_r;
   reg     [1:0]  i_fifo_size0_r;
   reg     [1:0]  i_fifo_size1_r;
   reg            i_fifo_sex0_r;
   reg            i_fifo_sex1_r;
   reg            i_fifo_valid0_r;
   reg            i_fifo_valid1_r;
   reg            i_fifo_store0_r;
   reg            i_fifo_store1_r;
   wire           i_st_response;

   reg     [1:0]  i_fifo_addr2_r;
   reg     [1:0]  i_fifo_addr3_r;
   reg     [1:0]  i_fifo_size2_r;
   reg     [1:0]  i_fifo_size3_r;
   reg            i_fifo_sex2_r;
   reg            i_fifo_sex3_r;
   reg            i_fifo_valid2_r;
   reg            i_fifo_valid3_r;
   reg            i_fifo_store2_r;
   reg            i_fifo_store3_r;

   assign          q_cache  = LDSTQ_AHB_CACHEABLE;
   assign          q_priv   = 1'b1;
   assign          q_buffer = LDSTQ_AHB_BUFFERABLE;
   assign          q_mode   = 1'b1;

// ============================== is_queue ==============================--
// 
//  The signal is_queue is set when the load/store queue should
//  service the load/store request from the ARC pipeline or the debug
//  interface.
//
//  If the address (dmp_addr) is not within the address range of the
//  LD/ST RAM (is_local_ram = '0') and the data cache is either
//  disabled or the .DI extensions are used, then the load/store
//  queue should service the request.
//   
assign is_queue = ((( dmp_nocache == 1'b 1 ) | ( dc_disable_r == 1'b 1 )) & 
                  ( is_local_ram == 1'b 0 ) & 
                  ( is_peripheral == 1'b 0 )) ? 1'b 1 : 
    1'b 0; 

// Pre-process write data (if on critical path might need to post-process
// after the buffering).
//
 always @(dmp_addr)
    begin : WRITE_SHIFT_CALC_PROC
  // Little-endian shift = long word byte-offset
  i_wdata_shift = dmp_addr[1:0];  
   end 
 // ------------------------------------------------------------------------
//  Write data generation
// 
//  The write data is sorted to ensure it lines up with the correct
//  position in the output word. This happens at the same time as the
//  store request from the processor is stored in the load/store
//  queue. On the following cycle the store request may be issued to
//  the memory arbitrator with the sorted write data available at the
//  same time. Sorting of the write data is generated
//  synchronously.
// 
assign i_dwr = (i_wdata_shift == BYTE1) ? {dmp_dwr[23:0], dmp_dwr[31:24]} :
               (i_wdata_shift == BYTE2) ? {dmp_dwr[15:0], dmp_dwr[31:16]} :
               (i_wdata_shift == BYTE3) ? {dmp_dwr[7:0], dmp_dwr[31:8]} :
               dmp_dwr;

// ============================ Set-Up LD/ST Queue ======================--
// 
//  This process loads a data bank for an access to memory, and
//  provides the address, burst size, etc to the memory system
//  based upon signals from the ARC. There are banks of latches, i.e.
//  bank 'a' and 'b'.
// 
//  It also determines when the controller should wait, i.e. during
//  a pending memory access.
// 
always @(posedge clk_dmp or posedge rst_a)
   begin : LOAD_DATA_BANKS_PROC
   if (rst_a == 1'b 1)
      begin
      i_a_full_r  <= 1'b 0;  
      i_a_load_r  <= 1'b 1;  
      i_a_sex_r   <= 1'b 0;   
      i_a_size_r  <= {2{1'b 0}}; 
      i_a_addr_r  <= {(EXT_A_MSB + 1){1'b 0}};   
      i_a_wdata_r <= 32'b 0;
      i_b_full_r  <= 1'b 0;  
      i_b_load_r  <= 1'b 0;  
      i_b_sex_r   <= 1'b 0;   
      i_b_size_r  <= {2{1'b 0}}; 
      i_b_addr_r  <= {(EXT_A_MSB + 1){1'b 0}};   
      i_b_wdata_r <= 32'b 0;
      i_a_next_r  <= 1'b 1;  
      i_b_next_r  <= 1'b 0;  
      i_sel_dat_r <= 1'b 0; 
      end
   else
      begin

      if ((( i_ls_rd_rq == 1'b 1 ) | ( i_ls_wr_rq == 1'b 1 )) &
         ( q_cmdack == 1'b 1 ))
         begin
           
         //  Once a bank has been reset invert the select data signal
         //  so that upon the next access the appropriate data is
         //  selected.
         //             
         i_sel_dat_r <= ~i_sel_dat_r;   
         end

      //  The appropriate bank of latches holding the appropriate 
      //  information upon the request, e.g. address, size, etc, are
      //  updated when the following conditions are met:
      // 
      //   [1] There is a load requested or a store has been requested
      //       and the queue is full,
      //   &
      //   [2] Stage 3 is enabled,
      //   &
      //   [3] The local LD/ST RAM is not being accessed.
      // 
      if ((( dmp_mload == 1'b 1 ) | ( dmp_mstore == 1'b 1 )) & 
            ( dmp_en3 == 1'b 1 ) & ( is_queue == 1'b 1 ))
         begin

         //  Bank 'a' is updated when this bank is empty, and a
         //  request for a memory transaction has completed when the
         //  current bank is full.
         //
         if (( i_a_next_r == 1'b 1 ) & (( i_a_full_r == 1'b 0 ) | 
         (( i_a_full_r == 1'b 1 ) & ((( i_ls_wr_rq == 1'b 1 ) | 
         ( i_ls_rd_rq == 1'b 1 )) & ( q_cmdack == 1'b 1 )))))

            begin
            i_a_addr_r <= dmp_addr[EXT_A_MSB:0];    
            i_a_size_r <= dmp_size; 
            i_a_sex_r  <= dmp_sex;  
            i_a_load_r <= dmp_mload;    
            i_a_wdata_r <= i_dwr;
            i_a_full_r <= 1'b 1;    
            i_a_next_r <= 1'b 0;    
            i_b_next_r <= 1'b 1;    

            if ((( i_ls_rd_rq == 1'b 1 ) | ( i_ls_wr_rq == 1'b 1 )) &
                (q_cmdack == 1'b 1)                         &
                (i_sel_dat_r == 1'b 1))
              begin
              i_b_full_r <= 1'b 0;    
              end

            end

         //  Bank 'b' is updated when this bank is empty, and a
         //  request for a memory transaction has completed when
         //  the current bank is full.
         // 
         else if (( i_b_next_r == 1'b 1 ) & (( i_b_full_r == 1'b 0 ) | 
                 (( i_b_full_r == 1'b 1 ) & ((( i_ls_rd_rq == 1'b 1 ) |
                 ( i_ls_wr_rq == 1'b 1 )) & ( q_cmdack == 1'b 1 )))))
            begin
            i_b_addr_r <= dmp_addr[EXT_A_MSB:0];    
            i_b_size_r <= dmp_size; 
            i_b_sex_r  <= dmp_sex;  
            i_b_load_r <= dmp_mload;    
            i_b_wdata_r <= i_dwr;
            i_b_full_r <= 1'b 1;    
            i_b_next_r <= 1'b 0;    
            i_a_next_r <= 1'b 1;

            if ((( i_ls_rd_rq == 1'b 1 ) | ( i_ls_wr_rq == 1'b 1 )) &
                (q_cmdack == 1'b 1)                         &
                (i_sel_dat_r == 1'b 0))
              begin
              i_a_full_r <= 1'b 0;    
              end

            end
         
     else if ((( i_ls_rd_rq == 1'b 1 ) | ( i_ls_wr_rq == 1'b 1 )) &
                 ( q_cmdack == 1'b 1 ))
           begin

           if (i_sel_dat_r == 1'b 0)
             begin
             i_a_full_r <= 1'b 0;    
             end
           else
             begin
             i_b_full_r <= 1'b 0;
             end
           end
     
         end

      // When a request has been acknowledged then one of the
      // banks is assumed to be ready for use. The 'i_sel_dat_r'
      // signal determines which of the two banks are to be
      // reset.
      //
      else if ((( i_ls_rd_rq == 1'b 1 ) | ( i_ls_wr_rq == 1'b 1 )) &
                 ( q_cmdack == 1'b 1 ))
         begin

          if (i_sel_dat_r == 1'b 0)
            begin
            i_a_full_r <= 1'b 0;    
            end
         else
            begin
            i_b_full_r <= 1'b 0;
            end
         end
      end
   end

//  This signal is true when both latch banks are full. 
// 
assign i_alat_full = ((i_a_next_r & i_a_full_r) | 
                     (i_b_next_r & i_b_full_r)) &
                     (~(i_ls_rd_rq & q_cmdack))   &
                     (~(i_ls_wr_rq & q_cmdack));

// =============================== MWAIT ================================--
// 
//  This signal is set true by this module in order to hold up stages
//  1, 2, and 3. It is used when the load/store queue cannot service
//  a request for a memory access. It will be produced from dmp_mload,
//  dmp_mstore and logic internal to the load/store queue.

assign q_mwait = ((dmp_mload | dmp_mstore) == 1'b 1 ) & 
                 ( i_alat_full == 1'b 1 ) & 
                 ((dmp_nocache | dc_disable_r) == 1'b 1 ) ? 1'b 1 : 

    1'b 0; 

// ============================ LD/ST Request ===========================--
// 
//  Here the read/write request signals to the memory arbitrator are
//  set depending upon the memory transaction. Depending on the
//  signal i_sel_dat_r the operation in either bank A or B is
//  performed, but only if this bank is full (indicated by
//  i_a_full_r and i_b_full_r).
// 
//  Both read and write operations generate responses. It is not
//  possible to detect whether it is a read or write response by
//  reading the BVCI interface signals so the load/store queue must
//  remember if it issued a read or write request. All responses
//  return in the same order they were requested. The load/store
//  queue can remember 3 outstanding requests in a dedicated FIFO. 
//  The signal i_fifo_valid1_r is set when the FIFO is full. If set,
//  then the load/store queue stops issueing more requests.
// 
always @(i_a_load_r or 
         i_a_full_r or 
         i_b_load_r or 
         i_b_full_r or 
         i_sel_dat_r or
         i_fifo_valid3_r)

   begin : REQUEST_RD_PROC

   if (( i_sel_dat_r == 1'b 0 ) & 
       ( i_a_full_r == 1'b 1 ) & 
       ( i_fifo_valid3_r == 1'b 0 ))
      begin
      i_ls_rd_rq = i_a_load_r;     
      end

   else if (( i_sel_dat_r == 1'b 1 ) & 
           ( i_b_full_r == 1'b 1 ) & 
           ( i_fifo_valid3_r == 1'b 0 ))
      begin
      i_ls_rd_rq = i_b_load_r;    
      end

   else
      begin
      i_ls_rd_rq = 1'b 0;    
      end
   end
   
// Performing the write request to memory.
//
always @(i_a_load_r or 
         i_a_full_r or 
         i_b_load_r or 
         i_b_full_r or 
         i_sel_dat_r or
         i_fifo_valid3_r)

   begin : REQUEST_WR_PROC

   if (( i_sel_dat_r == 1'b 0 ) & 
       ( i_a_full_r == 1'b 1 ) & 
       ( i_fifo_valid3_r == 1'b 0 ))
      begin 
      i_ls_wr_rq = ~i_a_load_r;    
      end

   else if (( i_sel_dat_r == 1'b 1 ) & 
           ( i_b_full_r == 1'b 1 ) & 
           ( i_fifo_valid3_r == 1'b 0 ))
      begin 
      i_ls_wr_rq = ~i_b_load_r;    
      end

   else
      begin  
      i_ls_wr_rq = 1'b 0;  
      end
   end

//  The command signal q_cmd is generated by concatenating the two
//  internal signals for read and write requests. The command
//  valid signal q_cmdval is set when there is either a read or write
//  request. The End Of Packet signal q_eop is set when q_cmdval 
//  is set, because the load/store queue never issues burst requests.
// 
  assign q_cmd    = {i_ls_wr_rq, i_ls_rd_rq};
  assign q_cmdval = i_ls_wr_rq | i_ls_rd_rq;
  assign q_eop    = i_ls_wr_rq | i_ls_rd_rq;

//  The response acknowledge signal is permanently set to indicate
//  that it is always ready to receive responses from the memory
//  arbitrator.
//  
  assign q_rspack = 1'b 1;

//  This FIFO keeps track of requests that has been acknowledged by
//  the memory arbitrator, but where the response has not yet come
//  back. The FIFO can keep track of up to 2 outstanding requests
//  of any type (i.e. either read or write requests).
//
//  The FIFO stores the following information about each outstanding
//  request:
//
//        --------------------------------------------------   
//     1. Whether it is a store or a load (i_fifo_store0_r).
//        --------------------------------------------------   
//        This information is used to filter out write
//        responses (q_rspval), so that they are not sent back
//        to the processor as read returns (q_ldvalid).
//
//        --------------------------------------------------   
//     2. The two lower address bits (i_fifo_addr0_r), 
//        The sign extend information (i_fifo_sex0_r),
//        The size information (i_fifo_size0_r),
//        --------------------------------------------------   
//        This information is only used for read responses. The
//        memory arbitrator interface always returns a long word.
//        For byte and word access as well as sign extension, the
//        load/store queue needs to process the returning data.
//
//  Each FIFO item is valid when the valid bit is set 
//  (e.g. i_fifo_valid0_r).
//
always @(posedge clk_dmp or posedge rst_a)
   begin : RESPONSE_FIFO_PROC
   if (rst_a == 1'b 1)
      begin
      i_fifo_addr0_r  <= {2{1'b 0}};
      i_fifo_addr1_r  <= {2{1'b 0}};
      i_fifo_addr2_r  <= {2{1'b 0}};
      i_fifo_addr3_r  <= {2{1'b 0}};
      i_fifo_size0_r  <= {2{1'b 0}};
      i_fifo_size1_r  <= {2{1'b 0}};
      i_fifo_size2_r  <= {2{1'b 0}};
      i_fifo_size3_r  <= {2{1'b 0}};
      i_fifo_sex0_r   <= 1'b 0;
      i_fifo_sex1_r   <= 1'b 0;
      i_fifo_sex2_r   <= 1'b 0;
      i_fifo_sex3_r   <= 1'b 0;
      i_fifo_valid0_r <= 1'b 0;
      i_fifo_valid1_r <= 1'b 0;
      i_fifo_valid2_r <= 1'b 0;
      i_fifo_valid3_r <= 1'b 0;
      i_fifo_store0_r <= 1'b 0;
      i_fifo_store1_r <= 1'b 0;
      i_fifo_store2_r <= 1'b 0;
      i_fifo_store3_r <= 1'b 0;
      end
   else
      //  Add a new outstanding request to the fifo
      //
      begin
      if ((( i_ls_wr_rq == 1'b 1 ) | ( i_ls_rd_rq == 1'b 1 )) &
         ( q_cmdack == 1'b 1 ))

          //  Simultaneous response
          //
          begin
          if (( q_rspval == 1'b 1 ) & ( i_fifo_valid0_r == 1'b 1 ))
             begin
             if (i_fifo_valid1_r == 1'b 0)
            // Only stage 0 valid, stage 0 takes new data.
                begin
                i_fifo_valid0_r <= 1'b 1;
                i_fifo_store0_r <= i_ls_wr_rq;
                i_fifo_addr0_r  <= i_addr;
                i_fifo_size0_r  <= i_size;
                i_fifo_sex0_r   <= i_sex;
                end

             else if (i_fifo_valid2_r == 1'b 0)
               begin
        // Stages 0 and 1 valid, shuffle stage 1 data into 0 and
        // put new input data into stage 1.
                i_fifo_valid0_r <= i_fifo_valid1_r;
                i_fifo_store0_r <= i_fifo_store1_r;
                i_fifo_addr0_r  <= i_fifo_addr1_r;
                i_fifo_size0_r  <= i_fifo_size1_r;
                i_fifo_sex0_r   <= i_fifo_sex1_r;

                i_fifo_valid1_r <= 1'b 1;
                i_fifo_store1_r <= i_ls_wr_rq;
                i_fifo_addr1_r  <= i_addr;
                i_fifo_size1_r  <= i_size;
                i_fifo_sex1_r   <= i_sex;
                end

             else if (i_fifo_valid3_r == 1'b 0)
                begin
                i_fifo_valid0_r <= i_fifo_valid1_r;
                i_fifo_store0_r <= i_fifo_store1_r;
                i_fifo_addr0_r  <= i_fifo_addr1_r;
                i_fifo_size0_r  <= i_fifo_size1_r;
                i_fifo_sex0_r   <= i_fifo_sex1_r;

                i_fifo_valid1_r <= i_fifo_valid2_r;
                i_fifo_store1_r <= i_fifo_store2_r;
                i_fifo_addr1_r  <= i_fifo_addr2_r;
                i_fifo_size1_r  <= i_fifo_size2_r;
                i_fifo_sex1_r   <= i_fifo_sex2_r;

                i_fifo_valid2_r <= 1'b 1;
                i_fifo_store2_r <= i_ls_wr_rq;
                i_fifo_addr2_r  <= i_addr;
                i_fifo_size2_r  <= i_size;
                i_fifo_sex2_r   <= i_sex;
                end

             else if (i_fifo_valid3_r == 1'b 1)
                begin
                i_fifo_valid0_r <= i_fifo_valid1_r;
                i_fifo_store0_r <= i_fifo_store1_r;
                i_fifo_addr0_r  <= i_fifo_addr1_r;
                i_fifo_size0_r  <= i_fifo_size1_r;
                i_fifo_sex0_r   <= i_fifo_sex1_r;

                i_fifo_valid1_r <= i_fifo_valid2_r;
                i_fifo_store1_r <= i_fifo_store2_r;
                i_fifo_addr1_r  <= i_fifo_addr2_r;
                i_fifo_size1_r  <= i_fifo_size2_r;
                i_fifo_sex1_r   <= i_fifo_sex2_r;

                i_fifo_valid2_r <= i_fifo_valid3_r;
                i_fifo_store2_r <= i_fifo_store3_r;
                i_fifo_addr2_r  <= i_fifo_addr3_r;
                i_fifo_size2_r  <= i_fifo_size3_r;
                i_fifo_sex2_r   <= i_fifo_sex3_r;

                i_fifo_valid3_r <= 1'b 1;
                i_fifo_store3_r <= i_ls_wr_rq;
                i_fifo_addr3_r  <= i_addr;
                i_fifo_size3_r  <= i_size;
                i_fifo_sex3_r   <= i_sex;
                end

             end

          //  No simultaneous response
          //
          else if (q_rspval == 1'b 0)
             begin
               
             if (i_fifo_valid0_r == 1'b 0)
            // FIFO is empty, fill stage 0
                begin
                i_fifo_valid0_r <= 1'b 1;
                i_fifo_store0_r <= i_ls_wr_rq;
                i_fifo_addr0_r  <= i_addr;
                i_fifo_size0_r  <= i_size;
                i_fifo_sex0_r   <= i_sex;
                end

             else if (i_fifo_valid1_r == 1'b 0)
            // Stage 0 full , fill stage 1.
                begin
                i_fifo_valid1_r <= 1'b 1;
                i_fifo_store1_r <= i_ls_wr_rq;
                i_fifo_addr1_r  <= i_addr;
                i_fifo_size1_r  <= i_size;
                i_fifo_sex1_r   <= i_sex;
                end
        
             else if (i_fifo_valid2_r == 1'b 0)
                begin
                i_fifo_valid2_r <= 1'b 1;
                i_fifo_store2_r <= i_ls_wr_rq;
                i_fifo_addr2_r  <= i_addr;
                i_fifo_size2_r  <= i_size;
                i_fifo_sex2_r   <= i_sex;
                end

             else if (i_fifo_valid3_r == 1'b 0)
                begin
                i_fifo_valid3_r <= 1'b 1;
                i_fifo_store3_r <= i_ls_wr_rq;
                i_fifo_addr3_r  <= i_addr;
                i_fifo_size3_r  <= i_size;
                i_fifo_sex3_r   <= i_sex;
                end
             end
          end

       //  Pop oldest item in fifo as a response is coming back.
       //  No request is added to the fifo in this case.
       //
       else if (( q_rspval == 1'b 1 ) & ( i_fifo_valid0_r == 1'b 1 ))
          begin
          i_fifo_valid0_r <= i_fifo_valid1_r;
          i_fifo_store0_r <= i_fifo_store1_r;
          i_fifo_addr0_r  <= i_fifo_addr1_r;
          i_fifo_size0_r  <= i_fifo_size1_r;
          i_fifo_sex0_r   <= i_fifo_sex1_r;

          i_fifo_valid1_r <= i_fifo_valid2_r;
          i_fifo_store1_r <= i_fifo_store2_r;
          i_fifo_addr1_r  <= i_fifo_addr2_r;
          i_fifo_size1_r  <= i_fifo_size2_r;
          i_fifo_sex1_r   <= i_fifo_sex2_r;

          i_fifo_valid2_r <= i_fifo_valid3_r;
          i_fifo_store2_r <= i_fifo_store3_r;
          i_fifo_addr2_r  <= i_fifo_addr3_r;
          i_fifo_size2_r  <= i_fifo_size3_r;
          i_fifo_sex2_r   <= i_fifo_sex3_r;

          i_fifo_valid3_r <= 1'b 0;
          end
      end
   end

// ================== Load Return from the LD/ST queue ==================--
// 
//  The signal i_q_ldvalid is set when a read response is returning.
//  It indicates that the return data bus q_drd contains valid read
//  data. The difference between i_q_ldvalid and q_rspval is that the
//  write responses have been filtered out by using the signal
//  i_st_reponse, which in turn is set when a store response occurs.
// 
assign i_st_response = (i_fifo_valid0_r & i_fifo_store0_r) |
                       ((~i_fifo_valid0_r) & i_ls_wr_rq);

assign i_q_ldvalid = 
                     (q_rspval &  ~i_st_response) 
                     ;

// ======================= Set LD/ST Parameters =========================--
// 
//  Select which bank that contains the data related to the current
//  request.
// 
assign i_addr = ( i_sel_dat_r == 1'b 1 ) ? i_b_addr_r[1:0] : 
    i_a_addr_r[1:0]; 

assign i_size = ( i_sel_dat_r == 1'b 1 ) ? i_b_size_r : 
    i_a_size_r; 

assign i_sex = ( i_sel_dat_r == 1'b 1 ) ? i_b_sex_r : 
    i_a_sex_r; 
 
// ========================= PLEN generation ============================--
//
// generate appropriate PLEN based on the size of transfer
//
always @ ( i_size or i_addr )
   begin : Q_PLEN_PROC
       case (i_size)
         LDST_BYTE : begin
                        i_plen = 9'b 000000001;
                     end // 1 byte
         LDST_WORD : begin
                        i_plen = 9'b 000000010;
                     end // 2 byte
         default   : begin
                        //i_plen = 9'b 000000100;
                        case (i_addr)            
                        BYTE0:                   
                          i_plen = 9'b 000000100;    
                        BYTE1:                   
                          i_plen = 9'b 000000001;    
                        BYTE2:                   
                          i_plen = 9'b 000000010;    
                        default:                 
                          i_plen = 9'b 000000001;    
                        endcase                  
                     end // 4 byte
       endcase
   end

assign q_plen = i_plen;
 
// =========================== Address Selection ========================--
// 
//  Select the correct buffer for the external memory requests.
// 
assign i_q_address[EXT_A_MSB: 0] = ( i_sel_dat_r == 1'b 1 ) ?
   
           i_b_addr_r[EXT_A_MSB:0]:
           i_a_addr_r[EXT_A_MSB:0];

assign q_address = i_q_address;

// ================ Instantiation of Read/Write Buffers =================--
//
//  Select the data needed to process the read response. This data 
//  is stored either in the response FIFO (when i_fifo_valid0_r is 
//  set) or in the request banks.
// 
always @(i_addr or 
         i_size or 
         i_sex  or 
         i_fifo_addr0_r or
         i_fifo_size0_r or 
         i_fifo_sex0_r or
         i_fifo_valid0_r)

   begin : SORT_SELECT_PROC

   if (i_fifo_valid0_r == 1'b 1)
      begin
      i_sel_addr = i_fifo_addr0_r; 
      i_sel_size = i_fifo_size0_r; 
      i_sel_sex  = i_fifo_sex0_r;
      end
   else
      begin
      i_sel_addr = i_addr; 
      i_sel_size = i_size; 
      i_sel_sex  = i_sex;
      end
   end

//  Process the returning data. This is necessary for byte and word
//  reads as well as sign extension.
//
readsort U_readsort (.d_in(q_rdata), 
                     .addr(i_sel_addr),
                     .size(i_sel_size),
                     .sex(i_sel_sex),

                     .d_out(q_drd));
   
//  The write data is sorted to ensure it lines up with the correct
//  position in the output word, and the appropriate byte read/write
//  controls are asserted. But only if the store request (dmp_mstore)
//  is going to be serviced by the load/store queue (is_queue = '1').
// 
assign q_wdata = ( i_sel_dat_r == 1'b 1 ) ? i_b_wdata_r : i_a_wdata_r;

// ------------------------------------------------------------------------
//  Mask calculation
// 
//  The mask is set asynchronously depending on the size of the
//  operation (byte, word or longword) and the position in the
//  longword.
// 
always @(i_addr or i_size)
begin : MASKING_PROC
   case (i_size)
 
   LDST_BYTE:
   begin
     case (i_addr)
     BYTE0:
       q_be = BYTE0_MASK;    
     BYTE1:
       q_be = BYTE1_MASK;    
     BYTE2:
       q_be = BYTE2_MASK;    
     default:
       q_be = BYTE3_MASK;    
     endcase
   end
    
   LDST_WORD:
     begin
     if (i_addr[1] == 1'b 0)
       q_be = WORD0_MASK;    
     else
       q_be = WORD1_MASK;    
     end

   //  Longword
   // 
   default:
     q_be = LONG_MASK;    
   endcase
end

// =========================== PC Tracking ==============================--
// 
//  PC tracking enables for Actionpoint Debugging system
// 
//  There are 2 banks of latches for the LD queue which are updated with
//  the value of the PC of the instruction which requested each read
//  memory transaction.
// 
//  The first bank of latches is updated with new value of
//  the PC when it obeys the following criterion:
// 
//  [1] It is ready for use,
//  [2] It is not full,
//  [3] It is full, but the memory transaction has just been
//      serviced

assign a_pc_en = 

           (( i_a_next_r == 1'b 1 ) & (( i_a_full_r == 1'b 0 ) | 
           (( i_a_full_r == 1'b 1 ) & ((( i_ls_rd_rq == 1'b 1 ) |
           ( i_ls_wr_rq == 1'b 1 )) & ( q_cmdack == 1'b 1 ))))) ? 1'b 1: 

    1'b 0;  

//  The second bank of latches is updated with new value of
//  the PC when it obeys the following criterion:
// 
//  [1] It is ready for use,
//  [2] It is not full,
//  [3] It is full, but the memory transaction has been
//      serviced (q_rspval),

assign b_pc_en = 

           (( i_b_next_r == 1'b 1 ) & (( i_b_full_r == 1'b 0 ) | 
           (( i_b_full_r == 1'b 1 ) & ((( i_ls_rd_rq == 1'b 1 ) | 
           ( i_ls_wr_rq == 1'b 1 )) & ( q_cmdack == 1'b 1 ))))) ? 1'b 1 : 
    1'b 0; 

// ============================= q_busy =================================--
// 
//  This signal is true when there is a memory request in the queue
//  that has not been serviced yet. The first condition is true when
//  both banks are full. The second condition is true when at least
//  one bank is full and the memory request has not yet been serviced.
//
assign q_busy = (( i_a_full_r == 1'b 1 ) & ( i_b_full_r == 1'b 1 )) | 
                ((( i_a_full_r == 1'b 1 ) | ( i_b_full_r == 1'b 1 )) & 
                (( i_ls_wr_rq == 1'b 0 ) | ( q_cmdack == 1'b 0 )) &
                (( i_ls_rd_rq == 1'b 0 ) | ( q_cmdack == 1'b 0 ))) ? 1'b 1 :
    1'b 0; 

// =========================== queue_idle ===============================--
// 
//  This isgnal is used for clock gating the DMP domain
//  when it's not in use.
//   
assign i_queue_idle = (// No outstanding memory requests in the queue.
                         ( q_busy == 1'b 0 ) &
                         // load/store queue can / has serviced all requests.
                         ( q_mwait == 1'b 0 ) &
                         // No loads to service.
                         ( dmp_mload == 1'b 0 ) &
                         // No stores to service.
                         ( dmp_mstore == 1'b 0 ) &
                         // Store has completed.
                         ( i_st_response == 1'b 0 )) ? 1'b 1 : 1'b 0;
  
assign cgm_queue_idle = ( 
                         i_queue_idle &
                         // No memory accesses in progress (bypassing the
                         // cache).
                         ( dmp_nocache == 1'b 0 )) ? 1'b 1 : 1'b 0;
			 
assign sync_queue_idle = i_queue_idle &
                         // No stores backed-up in the queue
                         (((i_fifo_valid0_r & i_fifo_store0_r) |
                           (i_fifo_valid1_r & i_fifo_store1_r) |
                           (i_fifo_valid2_r & i_fifo_store2_r) |
                           (i_fifo_valid3_r & i_fifo_store3_r)) == 1'b0);

// ============================= outputs ================================--


assign sel_dat         = i_sel_dat_r;
assign q_ldvalid       = i_q_ldvalid;			 

endmodule
