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
// This file contains load/store RAM control logic. The load/store RAM
// is an on-chip memory that can be accessed from the ARC pipeline 
// using load (LD) or store (ST) instructions. It can also be accessed
// from the debug interface (i.e from the PC port or the JTAG port) or
// the LD/ST Direct Memory Interface (LD/ST DMI).
// 
//========================== Inputs from this module =========================--
//
// clk_ungated      Core ungated clock. The ungated clock is used
//                  here so that DMI requests issued when the clock
//                  is asleep are still serviced.
//
// rst_a            Global asynchronous reset signal.
//
// test_mode        Global production test mode signal.
//
// dmp_dwr          Load write data connected to the DMP sub-modules
//                  (e.g. the load/store RAM) and the peripherals. The
//                  write data can come from either the ARC pipeline or
//                  the debug interface, depending on which module 
//                  requests to write to memory.
//
// dmp_en3          U Pipeline stage 3 enable signal connected to the
//                  DMP sub-modules (e.g. the load/store RAM) and the
//                  peripherals. This signal is controlled by either the
//                  ARC pipeline or the debug access unit. When it is
//                  set, a DMP sub-module or a peripheral will service
//                  the load/store request.
//
// dmp_addr         Load/store address connected to the DMP sub-modules
//                  (e.g. the load/store RAM) and the peripherals. This
//                  address can come from either the ARC pipeline or the
//                  debug interface, depending on which module requests
//                  to access memory.
//
// dmp_mload        Load instruction indicator. When it is set either
//                  the ARC or the debug interface wish to load data
//                  from an address in the LD/ST memory space.
//
// dmp_mstore       Store instruction indicator. When it is set either
//                  the ARC or the debug interface wish to store data
//                  to an address in the LD/ST memory space.
//
// dmp_size         Size of Transfer, connected to the DMP-submodules
//                  (e.g. the load/store RAM) and the peripherals. This
//                  is always cleared in debug mode. In ARC access mode,
//                  it is controlled by the ARC pipeline.
//
// dmp_sex          Sign extend signal connected to the DMP-submodules
//                  (e.g. the load/store RAM) and the peripherals. It is
//                  always cleared in debug mode. In ARC access mode, it
//                  is controlled from the ARC pipeline.
//
// hold_loc         This is a hold signal for the load/store RAM. If the
//                  load/store RAM is trying to return a load
//                  (ldst_ldvalid = '1') on the same cycle as hold_loc 
//                  is set then the load/store RAM should stall.
//
// is_ldst_ram      This is set when the address (dmp_addr) is within
//                  the load/store RAM address range.
//
// is_peripheral    This is set when the address (dmp_addr) is within
//                  the peripherals address range.
//
// ldst_dmi_req     DMI request to the LD/ST RAM. When set the Direct
//                  Memory Interface (DMI) has immediate direct access
//                  to the LD/ST RAM. The other LD/ST RAM interfaces 
//                  the data memory pipeline interfaces is held off as 
//                  it has lower priority. During one access several 
//                  reads and writes can be performed. Access ends when
//                  this signal is again set low. 
//
// ldst_dmi_addr    Address for the LD/ST RAM Direct Memory Interface.
//
// ldst_dmi_wdata   Write data for the LD/ST RAM Direct Memory 
//                  Interface.
//
// ldst_dmi_wr      Write enable for the LD/ST RAM Direct Memory 
//                  Interface. Set means write and clear means read.
//
// ldst_dmi_be      Byte enables on the LD/ST RAM Direct Memory 
//                  Interface. There are four byte enables, one for each
//                  byte lane. The byte enable bus is little endian.
//
//========================= Outputs from this module =========================--
//
// ldst_drd         The load data return bus from the load/store RAM.   
//
// ldst_ldvalid     Indicates that the load/store RAM wishes to perform
//                  a writeback on the next cycle.This signal is set
//                  when ldst_drd contains valid data.
//
// ldst_dmi_rdata   Read data to the LD/ST RAM Direct Memory Interface.
//
// stored_ld_rtn    Set when a load return from the DCCM is held off
//                  due to a DMI request and a Dcache load return
//                  happening at the same time.
//
module dccm_control (
   clk_ungated,
   rst_a,
   test_mode,
   dmp_dwr,
   dmp_en3,
   dmp_addr,
   dmp_mload,
   dmp_mstore,
   dmp_size,
   dmp_sex,
   ldst_dmi_req,
   ldst_dmi_addr,
   ldst_dmi_wdata,
   ldst_dmi_wr,
   ldst_dmi_be,
   ldst_dout,
   hold_loc,
   is_ldst_ram,
   is_peripheral,

   ldst_addr,
   ldst_din,
   ldst_mask,
   ldst_wren,
   ldst_ck_en,
   ldst_dmi_rdata,
   ldst_drd,
   ldst_ldvalid,
   stored_ld_rtn);

`include "arcutil_pkg_defines.v"
`include "arcutil.v"
`include "extutil.v"
`include "xdefs.v"

input                       clk_ungated;
input                       rst_a;
input                       test_mode;

// Read/Write signals from the debug access unit
//
input   [31:0]              dmp_dwr; 
input                       dmp_en3;
input   [31:0]              dmp_addr; 
input                       dmp_mload; 
input                       dmp_mstore; 
input   [1:0]               dmp_size; 
input                       dmp_sex;

// LD/ST RAM Direct Memory Interface (LD/ST RAM DMI)
//
input                       ldst_dmi_req; 
input   [31:0]              ldst_dmi_addr; 
input   [31:0]              ldst_dmi_wdata; 
input                       ldst_dmi_wr; 
input   [3:0]               ldst_dmi_be; 

// DCCM RAM Interface
//
input   [31:0]              ldst_dout; 

// Hold signal from the load return arbitrator
//
input                       hold_loc; 

// Address decodes from the load/store queue
//
input                       is_ldst_ram; 
input                       is_peripheral;

// DCCM RAM Interface
//
output  [LDST_A_MSB:0]      ldst_addr;
output  [31:0]              ldst_din;
output  [3:0]               ldst_mask;
output                      ldst_wren;
output                      ldst_ck_en;

// DCCM RAM Direct Memory Interface (DCCM RAM DMI)
//
output  [31:0]              ldst_dmi_rdata;

// Load return to the load return arbitrator
//
output  [31:0]              ldst_drd;
output                      ldst_ldvalid; 
output                      stored_ld_rtn;

wire    [LDST_A_MSB:0]      ldst_addr;
wire    [31:0]              ldst_din;
wire    [3:0]               ldst_mask;
wire                        ldst_wren;
wire                        ldst_ck_en;
wire    [31:0]              ldst_dmi_rdata; 
wire    [31:0]              ldst_drd; 

//  Signals for LD/ST RAM
// 
reg     [1:0]               i_d_addr_r; 
reg     [1:0]               i_d_size_r; 
reg                         i_d_sex_r; 
wire                        i_ldst_wren_a; 
wire    [31:0]              i_ldst_d_wr_a; 
wire    [3:0]               i_ldst_mask_a; 
wire    [31:0]              i_ldst_d_rd; 
wire                        i_ldst_ck_en_a; 
reg                         i_ldst_dlat_r;
wire                        i_ldst_ld_a; 
wire    [LDST_A_MSB:0]      i_ldst_raddr_nxt; 
reg     [LDST_A_MSB:0]      i_ldst_raddr_r; 
wire    [LDST_A_MSB:0]      i_rldst_raddr_a; 
reg                         i_stored_ld_rtn_r; 
reg     [3:0]               i_dmp_be_a; 
wire    [1:0]               i_be_addr_a; 
wire    [1:0]               i_be_size_a; 
reg     [1:0]               i_wdata_shift_a; 
reg                         i_ldst_st_d;
wire                        i_ldst_st_a;
wire                        stored_ld_rtn_r;

// ============================== LD/ST RAM ================================--
// 
   //  This provides a useful on-chip memory in the load/store space. A
   //  register is provided to enable the user to select where in the
   //  memory map the LD/ST RAM is mapped.
   // 
   //  Note that contents of the LD/ST RAM do not and will not correspond
   //  to the values in external memory, at the location where the LD/ST
   //  RAM is mapped. It is not a cache. Writes to the LD/ST RAM do
   //  not 'write-through' to external memory.
   //
   //  The LD/ST RAM is a fast on-chip memory, which services stores and 
   //  loads in a single cycle, provided that no scoreboard or register 
   //  writeback stalls are generated.
   //
   //  The only time the LD/ST RAM stalls is when it cannot return a
   //  load because another module with higher priority is returning a
   //  load on the same cycle. If this happens the LD/ST RAM stalls for 
   //   one cycle and attempts to return the load on the following clock
   //  cycle.
   // 
   //  The LD/ST RAM can also be accessed using the Direct Memory 
   //  Interface (LD/ST RAM DMI). This interface can, typically, be used
   //  by another on-chip module that wishes to access the LD/ST RAM.
   //  As the DMI interface has higher priority than the DMP interface, 
   //  the DMI accesses will always be serviced immediately. 
   // 
   //  In this version (ARC4), the method for dealing with loads from the
   //  LD/ST RAM has been adjusted. Rather than stalling a LD/ST RAM
   //  load which cannot complete immediately we save the load address
   //  and its associated information and perform the access when all
   //  previous memory accesses have completed. If another load or
   //  store operation is attempted whilst we have an outstanding
   //  request for the LD/ST RAM, then that load or store will be stalled.
   // 
   //  Essentially, this allows us to simplify the stalling logic - we
   //  do not have to generate a stall as a result of an address match -
   //  where the address is valid at the very end of the cycle. We,
   //  simply, have to do the address match and store the load information
   //  for later - then stall any subsequent accesses.
   // 
   //  i_ldst_dlat_r  : Registered signal which indicates completion of 
   //                   the LD/ST RAM access. Used to generate 
   //                   ldst_ldvalid for immediate and temporarily 
   //                   held-off accesses. It is never set during DMI 
   //                   accesses.
   // 
   //  i_ldst_ld_a    : Late-arriving signal indicating a LD/ST RAM load
   //                   being requested.
   // 
   //  i_ldst_raddr_r : Register to store the dmp_addr value that is to be
   //                   re-applied to the LD/ST RAM once the unsatisified
   //                   load has passed out of stage 3.
   // 
   //  i_d_addr_r     : Stored bottom 2 bits of dmp_addr, for LD/ST RAM
   //                   access. Passed to readsort for correct
   //                   byte/word/long access. Now stored only when a
   //                   load is issued to the LD/ST RAM.
   // 
   //  i_d_size_r     : Stored size bits, for LD/ST RAM access. Now
   //                   stored only when a load is issued to the
   //                   LD/ST RAM.
   // 
   //  i_d_sex_r      : Store sign-extend bit, for LD/ST RAM access. Now
   //                   stored only when a load is issued to the
   //                   LD/ST RAM.
   //  
   //  This signal is set when a load is issued to the LD/ST RAM. It will
   //  be valid late in the cycle, owing to the signals is_ldst_ram and 
   //  is_peripheral decode from the ALU adder.
   // 
   assign i_ldst_ld_a = ((dmp_mload     == 1'b 1) & 
                         (is_ldst_ram   == 1'b 1) & 
                         (is_peripheral == 1'b 0)) ?
          1'b 1 : 
          1'b 0;

   //  Here we switch the LD/ST RAM's input address between the value that
   //  comes directly from stage 3, the value stored when a LD cannot be
   //  immediately serviced and the value on the DMI interface of the 
   //  LD/ST RAM.
   // 
   assign i_rldst_raddr_a = 
                            (ldst_dmi_req == 1'b 1) ?
          ldst_dmi_addr[LDST_A_MSB + 2:2] : 
                            ((i_stored_ld_rtn_r == 1'b 1) | 
                             ((hold_loc == 1'b 1) &
                              (i_ldst_dlat_r == 1'b 1))) ?
          i_ldst_raddr_r :

          i_ldst_raddr_nxt; 

   //  In this process, we deal with all stored information related to a
   //  LD/ST RAM access. We generate the signals used in readsort when a 
   //  load access returns. The i_ldst_dlat_r signal is generated, which 
   //  indicates that the load is returning.
   // 
   always @(posedge clk_ungated or posedge rst_a)
   begin : redo_ldst_PROC

   //  Reset condition
   // 
   if (rst_a == 1'b 1)
      begin
      i_ldst_dlat_r     <= 1'b 0;   
      i_ldst_raddr_r    <= {(LDST_A_WIDTH) {1'b 0}}; 
      i_d_addr_r        <= {2 {1'b 0}}; 
      i_d_size_r        <= {2 {1'b 0}}; 
      i_d_sex_r         <= 1'b 0;   
      i_stored_ld_rtn_r <= 1'b 0;   
      end

   //  Clocked region
   // 
   else
      begin

      //  When a LD/ST RAM load occurs, save the signals needed to
      //  pass to readsort when an access completes (ldst_ldvalid
      //  true).
      // 
      if (i_ldst_ld_a == 1'b 1 & dmp_en3 == 1'b 1)
         begin
         i_d_addr_r <= dmp_addr[1:0];   
         i_d_size_r <= dmp_size;    
         i_d_sex_r  <= dmp_sex; 
         end

      //  Register the LD/ST RAM address, so it can be used if the 
      //  load cannot return. Don't register during DMI accesses 
      //  because we want to preserve the last value of the last DMP
      //  access. The DMI access never needs to get stored, as this
      //  inteface has the highest priority and therefore always gets 
      //  immediate access.
      // 
      if (ldst_dmi_req == 1'b 0)
         begin
         i_ldst_raddr_r <= i_ldst_raddr_nxt; 
         end

      //  If a load cannot return and a request is issued at the same 
      //  time on the LD/ST DMI interface then store the load return.
      //  Re-issue the load when the DMI session is over.
      // 
      if ((ldst_dmi_req == 1'b 1) & 
          (((hold_loc     == 1'b 1) & 
          (i_ldst_dlat_r == 1'b 1)) |
          ((i_ldst_ld_a == 1'b1) & (dmp_en3 == 1'b1))))
         begin
         i_stored_ld_rtn_r <= 1'b 1;    
         end
      else if (ldst_dmi_req == 1'b 0 )
         begin
         i_stored_ld_rtn_r <= 1'b 0;    
         end

      //  Generation of ldst_ldvalid for load returns.
      // 
      //  The valid load return signal (ldst_ldvalid) is set on the 
      //  next cycle if:
      // 
      //     [1] A valid load to the LD/ST RAM is issued.
      // 
      //     [2] A load cannot return and needs to be returned on the
      //         next cycle.
      // 
      //     [3] A DMI access has just finished and a DMP load that 
      //         was interrupted when the DMI access started can now
      //         be issued.
      // 
      if (((i_ldst_ld_a      == 1'b 1) &
           (dmp_en3          == 1'b 1) &
           (ldst_dmi_req     == 1'b 0))    | 

         ((hold_loc          == 1'b 1) &
          (i_ldst_dlat_r     == 1'b 1) & 
          (ldst_dmi_req      == 1'b 0))    | 

         ((i_stored_ld_rtn_r == 1'b 1) &
          (ldst_dmi_req      == 1'b 0)))

         begin
         i_ldst_dlat_r <= 1'b 1;    
         end
      else
         begin
         i_ldst_dlat_r <= 1'b 0;    
         end
      end
   end

   //  This is the ARC addressing the LD/ST RAM.
   // 
   assign i_ldst_raddr_nxt = dmp_addr[LDST_A_MSB + 2:2];
 
   //  The write enable for the LD/ST RAM is set when ARC executes
   //  a store operation provided to the LD/ST RAM or when a LD/ST RAM
   //  DMI write operation occurs.
   // 

   assign i_ldst_st_a =    ((dmp_mstore    == 1'b 1) & 
                            (is_ldst_ram   == 1'b 1) & 
                            (is_peripheral == 1'b 0));

   always @(posedge clk_ungated or posedge rst_a)
   begin
   //  Reset condition
   if (rst_a == 1'b 1)
      begin
      i_ldst_st_d   <= 1'b 0; 
      end

   //  Clocked region
   else
      begin
      if ((i_ldst_st_a == 1'b 1) & (dmp_en3 == 1'b 1) &
          (ldst_dmi_req == 1'b 1))
         begin
         i_ldst_st_d  <= 1'b 1; 
         end
      else if (ldst_dmi_req == 1'b 0)
         begin
         i_ldst_st_d <= 1'b 0;
         end
      end
   end

   assign i_ldst_wren_a = (((ldst_dmi_req == 1'b 1) & 
                            (ldst_dmi_wr  == 1'b 1)) |

                           ((i_ldst_st_d  == 1'b 1) &
                            (ldst_dmi_req == 1'b 0))  |
 
                           ((dmp_mstore    == 1'b 1) & 
                            (is_ldst_ram   == 1'b 1) & 
                            (is_peripheral == 1'b 0) & 
                            (dmp_en3       == 1'b 1))) ?
         LDST_WR_ACTIVE : 
         ~LDST_WR_ACTIVE;


   // The LD/ST RAM write data must be shifted into the correct byte-lanes
   // according to the endianness. This is done by modifying the addresses
   // individual bytes and words are stored in for non long-word accesses.
   always @(dmp_addr)       
    begin : write_shift_calc_PROC
            // Little-endian shift = long word byte-offset
      i_wdata_shift_a = dmp_addr[1:0] ; 
   end // block: write_shift_calc
   
   //  The LD/ST RAM write data is set to the DMI interface write data
   //  during LD/ST RAM DMI accesses. Otherwise they are set to the 
   //  appropriate bytes of the DMP write data.
   // 
   assign i_ldst_d_wr_a = 
                          (ldst_dmi_req   == 1'b 1)  ?
          ldst_dmi_wdata : 
                          (i_wdata_shift_a == BYTE1) ?
          {dmp_dwr[23:0], dmp_dwr[31:24]} : 
                          (i_wdata_shift_a == BYTE2) ?
          {dmp_dwr[15:0], dmp_dwr[31:16]} : 
                          (i_wdata_shift_a == BYTE3) ?
          {dmp_dwr[7:0], dmp_dwr[31:8]} : 
          dmp_dwr; 

// ====================== LD/ST RAM Mask Calculation =======================--
// 
   //  Choose address and size to use for the mask calculation. Normally,
   //  these signals are taken directly from the ARC pipeline interface.
   //  The only exception is when a load from the LD/ST RAM has not been
   //  able to return to the processor because a DMP sub-module with
   //  higher priority has returned a load at the same time. In this
   //  special case the address and size are, instead, taken from a 
   //  registered value.
   // 
   assign i_be_addr_a = ((i_stored_ld_rtn_r == 1'b 1) | 
                         ((hold_loc         == 1'b 1) & 
                          (i_ldst_dlat_r    == 1'b 1))) ?
          i_d_addr_r : 
          dmp_addr[1:0];

   assign i_be_size_a = ((i_stored_ld_rtn_r == 1'b 1) | 
                         ((hold_loc         == 1'b 1) & 
                          (i_ldst_dlat_r    == 1'b 1))) ?
          i_d_size_r : 
          dmp_size;

   //  This process performs mask calculations for the LD/ST RAM for byte,
   //  word and longword accesses.
   // 
   always @(i_be_addr_a or i_be_size_a)
   begin : dmp_be_PROC

   case (i_be_size_a)

   //  byte mask
   LDST_BYTE:
     case (i_be_addr_a)
       BYTE0:  i_dmp_be_a = BYTE0_MASK;
       BYTE1:  i_dmp_be_a = BYTE1_MASK;    
       BYTE2:  i_dmp_be_a = BYTE2_MASK;    
       default:i_dmp_be_a = BYTE3_MASK;    
     endcase 
     
   //  word mask
   LDST_WORD:
      if (i_be_addr_a[1] == 1'b 0)
         i_dmp_be_a = WORD0_MASK;    
      else
         i_dmp_be_a = WORD1_MASK;    

   
   //  longword mask
   default:
      i_dmp_be_a = LONG_MASK;    
   endcase
   end

   //  Select whether to get the byte enables from the DMI interface
   //  or the DMP interface.
   // 
   assign i_ldst_mask_a = (ldst_dmi_req == 1'b 1) ?
          ldst_dmi_be :
          i_dmp_be_a; 

// ====================== Load return valid signal =========================--
//
   //  Generate the load valid signal for the ARC from ls_dlat or from
   //  the LD/ST RAM (i_ldst_dlat_r).
   // 
   assign ldst_ldvalid = i_ldst_dlat_r; 

// ================= Read data on the DMI interface ========================--
// 
   assign ldst_dmi_rdata = i_ldst_d_rd; 

// ======================== Clock Enable for RAMs ==========================--
// 
   //  The clock enable for the LD/ST RAM block is enabled in the
   //  following manner: It is enabled on loads, stores, when the ARC
   //  is in test mode, during LD/ST RAM DMI accesses or when there is 
   //  a registered load that is waiting to return. The test mode is 
   //  always disabled during normal operation and only enabled during 
   //  ATPG generation and during production test.
   // 
   //  This signal turns off the RAM when not in use to save power.
   //  Depending on the technology used this may cause delays on the 
   //  critical path. If this is the case and it is not acceptable, don't
   //  connect this signal to the LD/ST RAM instantiated below.
   // 
   assign i_ldst_ck_en_a = (((test_mode         == 1'b 1)  | 
                             (ldst_dmi_req      == 1'b 1)  | 
                             (i_stored_ld_rtn_r == 1'b 1) | 
                             (i_ldst_st_d == 1'b 1)) | 

                            (((dmp_mload    == 1'b 1) |
                              (dmp_mstore   == 1'b 1)) & 
                             (dmp_en3       == 1'b 1)  & 
                             (is_ldst_ram   == 1'b 1)  & 
                             (is_peripheral == 1'b 0))) ?
          LDST_CK_EN_ACTIVE : 

          ~LDST_CK_EN_ACTIVE;
 
// ====================== Interface to the LD/ST RAM =======================--
// 
   assign i_ldst_d_rd = ldst_dout;
   assign ldst_addr   = i_rldst_raddr_a;
   assign ldst_din    = i_ldst_d_wr_a;
   assign ldst_mask   = i_ldst_mask_a;
   assign ldst_wren   = i_ldst_wren_a;
   assign ldst_ck_en  = i_ldst_ck_en_a;
   assign stored_ld_rtn = i_stored_ld_rtn_r;

// ================= Instantiation of read/write buffers ===================--
// 
   //  Select the data from read stream and sign extend it if necessary.
   // 
   readsort U_readsort (   
          .d_in(i_ldst_d_rd),
          .addr(i_d_addr_r),
          .size(i_d_size_r),
          .sex(i_d_sex_r),
          .d_out(ldst_drd));

endmodule
