// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 2002-2012 ARC International (Unpublished)
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
// This file contains the load return arbitrator. It arbitrates
// between returning loads from different Data Memory Pipeline (DMP)
// sub-modules and peripherals. This file also generates the mwait
// signal used to stall the ARC pipeline if necessary. The idle signal
// dmp_idle (which is set if the DMP is idle) is also generated in this
// module.
//
// ========================== Inputs to this block ===========================--
//
// dmp_mload        The load instruction indicator is created in the
//                  Data Memory Pipeline (DMP). When this signal is set
//                  either the processor or the debug interface wish to
//                  load data from an address in the LD/ST memory space.
//
// dmp_mstore       The store instruction indicator is created in the
//                  Data Memory Pipeline (DMP). When this signal is set
//                  either the processor or the debug interface wish to
//                  store data to an address in the LD/ST memory space.
//
// q_drd            Load data return bus from the load/store queue.
//
// q_ldvalid        Indicates that the load/store queue wishes to
//                  perform a writeback on the next cycle. This signal
//                  is set when q_drd contains valid data.
//
// q_mwait          This signal holds pipeline stages 1-3 when the
//                  load/store queue is full and cannot service a
//                  LD/ST request in pipeline stage 3.
//
// q_busy           This signal is set when the load/store queue
//                  contains at least one load or store request. It is
//                  used to generate the DMP idle signal (dmp_idle).
//
// code_drd         The load data return bus from the code RAM.
//
// code_ldvalid_r   Indicates that the code RAM wishes to perform a
//                  writeback on the next cycle.This signal is set when
//                  code_drd contains valid data.
//
// code_dmi_req     The DMI request signal to the code RAM. When set the
//                  direct memory interface (DMI) has immediate access
//                  to the code RAM. The other code RAM interfaces
//                  (instruction fetch and data memory pipeline) are
//                  held off, as they have lower priority. All
//                  load/store instructions are held off when this
//                  signal is set. During a single access several reads
//                  and writes can be performed. The DMI access ends
//                  when this signal is again set low.
//
// ldst_drd         The load data return bus from the load/store RAM.
//
// ldst_ldvalid     Indicates that the load/store RAM wishes to perform
//                  a writeback on the next cycle.This signal is set
//                  when ldst_drd contains valid data.
//
// ldst_dmi_req     The DMI request to the LD/ST RAM. When set the
//                  Direct Memory Interface (DMI) has immediate access
//                  to the LD/ST RAM. All load/store instructions are
//                 held off when this signal is set. During a single
//                  access several reads and writes can be performed.
//                  The DMI access ends when this signal is again set
//                  low.
//
// p_drd            The load data return bus from the peripherals.
//
// p_ldvalid        Indicates that a peripheral wishes to perform a
//                  writeback on the next cycle.This signal is set when
//                  p_drd contains valid data.
//
// stored_ld_rtn    Set when a load return from the DCCM is held off
//                  due to a DMI request and a Dcache load return
//                  happening at the same time.
//
// ========================= Outputs from this block =========================--
//
// hold_loc         This is a hold signal for the load/store RAM and the
//                  code RAM. If either one of these RAM's are trying
//                  to return a load on the same cycle as hold_loc is
//                  set then the load return should be reissued on the
//                  next cycle.
//
// hold_p           This is a hold signal for the peripherals. If the
//                  load/store RAM is trying to return a load
//                  (p_ldvalid = '1') on the same cycle as hold_p is
//                  set then the load/store RAM should stall.
//
// dmp_drd          The load return data bus from the Data Memory
//                  Pipeline (DMP). This load return data bus returns
//                  data from one of the three DMP sub-modules, the code
//                  RAM or a peripheral. The three DMP sub-modules are
//                  the load/store queue, the data cache and the
//                  load/store RAM.
//
// loc_ldvalid      Indicates that the either the load/store RAM or
//                  the code RAM wishes to perform a writeback on the
//                  next cycle.
//
// dmp_ldvalid      Indicates that a DMP sub-module or a peripheral
//                  wish to perform a writeback on the next cycle. This
//                  signal is set when dmp_drd contains valid data.
//
// mwait            This signal holds pipeline stages 1-3 when one of
//                  the three DMP sub-modules or a perpiheral demands
//                  it. The three DMP sub-modules are the load/store
//                  queue, the data cache and the load/store RAM.
//
// dmp_idle         The Data Memory Pipeline (DMP) idle signal. This
//                  signal is set when the DMP is idle. It checks the
//                  data cache and the load/store queue. The other
//                  modules can only contain stalled load returns
//                  which are covered by the load pending signal
//                  (lpending).
//
// ===========================================================================--
//
module ld_arb (

   // From ARC pipeline stage 3
   dmp_mload,
   dmp_mstore,
  
   // from the load/store queue
   q_drd,
   q_ldvalid,
   q_mwait,
   q_busy,
 

               
   // from the DCCM
   ldst_dmi_req,
   ldst_drd,
   ldst_ldvalid,
   stored_ld_rtn,

   // from the ICCM
   code_dmi_req,
   code_ldvalid_r,
   code_drd,

               
   // to the DCCM
   hold_loc,

   // to the peripherals
   hold_p,

   // to arc pipeline
   dmp_drd,
   dmp_ldvalid,
   loc_ldvalid,
   mwait,

   // to the dmp
   dmp_idle);

`include "arcutil_pkg_defines.v" 
`include "arcutil.v" 

// From ARC pipeline stage 3
 input   dmp_mload; 
 input   dmp_mstore;

// from the load/store queue
 input   [31:0] q_drd; 
 input   q_ldvalid; 
 input   q_mwait; 
 input   q_busy; 



// from the DCCM
 input   ldst_dmi_req;
 input [31:0] ldst_drd;
 input   ldst_ldvalid; 
 input   stored_ld_rtn;

// from the ICCM
 input   code_dmi_req;
 input   code_ldvalid_r;
 input [31:0] code_drd;

// to the load/store ram
 output   hold_loc; 

// to the peripherals
 output   hold_p;

// to arc pipeline 
 output   [31:0] dmp_drd; 
 output   dmp_ldvalid;
 output   loc_ldvalid; 
 output   mwait;

// to the dmp 
 output   dmp_idle; 

// to the load/store ram
 wire    hold_loc; 

// to the peripherals
 wire    hold_p;

// to arc pipeline
 wire    [31:0] dmp_drd; 
 wire    dmp_ldvalid;
wire loc_ldvalid; 
 wire    mwait; 

//  to the dmp
 wire    dmp_idle; 

//load/store ram signals
 wire    loc_mwait; 
 wire    i_hold_loc; 

//  peripheral signals
 wire    i_hold_p; 

// =============================== Local RAM's ===============================--
//
// If there is a local RAM in the build (i.e. a DCCM RAM or a ICCM RAM), the
// following hold_loc is generated:
//
   // This signal is set if there is a returning load on this cycle from a
   // module that has higher priority than the load/store RAM and the ICCM RAM.
   // If this signal is set at the same time as any of these two CCM RAM's are
   // trying to return a load then both the processor pipeline and the concerned
   // DCCM RAM need to be stalled for one cycle to allow the data from the CCM
   // RAM to return on the next cycle. The stalling mechanisms of the CCM RAM's
   // are implemented in respective files.
   // Stalling of the pipeline is controlled by the signal loc_mwait (see below).
   //
   // The two modules with higher priority than the CCM RAM's are the load/store
   // queue and the data cache. 
   //
   assign i_hold_loc =
                     (q_ldvalid == 1'b 1) 
             ? 1'b 1 :
             1'b 0;

   assign hold_loc = i_hold_loc; 

   // The loc_mwait signal is set if there is a returning load on this cycle
   // from a module with higher priority than the DCCM RAM's at the same time
   // as a new load/store request is in pipeline stage 3 of the processor. This
   // signal is also set if a direct memory access (DMI) is occuring to the DCCM
   // RAM or the ICCM RAM at the same time as a new load/store request is in
   // pipeline stage 3 of the processor.
   //
   assign loc_mwait = 
                   (((dmp_mload == 1'b 1) | (dmp_mstore == 1'b 1)) & ( 
                   (code_dmi_req == 1'b 1) | 
                   (ldst_dmi_req == 1'b 1) |
                   (stored_ld_rtn == 1'b 1) |

                   ((i_hold_loc == 1'b 1) 
                                  &
                                (
                           (ldst_ldvalid == 1'b 1) 
                                     |
                           (code_ldvalid_r == 1'b 1) 
                                  )
                       ))) ? 1'b 1: 
           1'b 0;

   assign loc_ldvalid  = 
                            code_ldvalid_r |
                            ldst_ldvalid |  
                            1'b 0;

 // ============================= Peripherals ===============================--
 //
 // If there is a peripheral in the build, the following two signals are
 // generated:
 //
   // This signal is set if there is a returning load on this cycle from a
   // module that has higher priority than the peripherals. If this signal is
   // set at the same time as a peripheral is trying to return a load
   // (p_ldvalid = '1') then both the ARC pipeline and the peripherals need to
   // be stalled for one cycle to allow the load from the peripheral to return
   // on the next cycle.
   // All other modules have higher priority than the peripherals, i.e
   // the load/store queue, the data cache, the ICCM RAM and the
   // DCCM RAM.

   assign i_hold_p = 
                   
                   (q_ldvalid == 1'b 1) 
                   |
             (code_ldvalid_r == 1'b 1) 
                   | (ldst_ldvalid == 1'b 1) 
                   ? 1'b 1 :

            1'b 0;

   assign hold_p = i_hold_p; 


// ====================== Signals returning to the ARC =======================--
// 
//  The following signals return to the ARC. They are present in all
//  types of builds.
// 
   // The mwait signal stalls the ARC pipeline if any of the modules that
   // service LD/ST instructions demands it.
   // 
   assign mwait = 
                 (q_mwait == 1'b 1) 
                 | 
                 (loc_mwait == 1'b 1) 
          ? 1'b 1 : 1'b 0; 

   // The dmp_ldvalid is the valid signal of the load return data.
   // 
   assign dmp_ldvalid = 
                        (q_ldvalid == 1'b 1) 
                        | 
                  (code_ldvalid_r == 1'b 1)
                        | (ldst_ldvalid == 1'b 1 )

          ? 1'b 1 : 1'b 0; 

   // The dmp_drd signal is the load return data.
   //
   assign dmp_drd = 
                    (q_ldvalid == 1'b 1) ? q_drd : 
            (code_ldvalid_r == 1'b 1) ? code_drd: 
                    (ldst_ldvalid == 1'b 1) ? ldst_drd : 
      q_drd;

// ============================ DMP idle signal  =============================--
//
// 
   // The DMP idle signal is used in the debug access unit to check when the
   // Data Memory Pipeline (DMP) is idle. This signals is generated from the
   // busy signals from the load/store queue and the data cache (if there is a
   // data cache in the build). The other sub-modules that service LD/ST
   // requests (i.e the load/store RAM and peripherals) cannot queue incoming
   // requests and must consequently not be checked.
   // 
   // However these modules can have stalled load returns. All outstanding loads
   // are covered by the load pending signal lpending, which is checked in the
   // debug access unit as well. The DMP idle signal is generated in all types
   // of builds.
   //
   assign dmp_idle = 
                     (q_busy == 1'b 1) 
                             ? 1'b 0 : 
          1'b 1; 

endmodule 

