// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 2004-2012 ARC International (Unpublished)
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
// The JTAG Debug Port is the module that contains all the internal JTAG
// registers and performs the actual communication between the ARC and
// Refer to the JTAG section in the ARC interface manual for an explanation
// on how to communicate with the complete module.  In this revision, the
// debug port does not contain the address, data, command, or status
// registers.  These physically reside on the other side of a BVCI
// interface, and are read by the debug port during the Capture-DR state
// and written during the Update-DR state. A command is initiated during
// the Run-Test/Idle state by writing a do-command address over the BVCI
// interface, and the registers are reset during the Test-Logic-Reset state
// by writing a reset address.
//
//========================== Inputs to this block ==========================--
//
//  clk_ungated         The core clock, which is never gated
//
//  rst_a               The asynchronous system reset
//
//  debug_address       BVCI debug port inputs
//  debug_be
//  debug_cmd
//  debug_cmdval
//  debug_eop
//  debug_rspack
//  debug_wdata
//
//  noaccess            An illegal access has been attempted, such as
//                      an access to a core register while the ARC is
//                      running.
//
//  hold_host           True while waiting for a load return or other
//                      stall
//
//  h_datar             Returning core or auxiliary read data
//
//  pc_sel_r            Processor-writable bit that can be read by the
//                      host.
//
// en                   The global run bit.
//
// reset_applied_r      This bit in the debug register is set to true when a
//                      a reset happens. The bit is read only from the
//                      processor side and the debugger clears this bit when
//                      it performs a read.
//
//  pcp_ack             Memory channel command acknowledge
//
//  pcp_dlat            Memory channel data ready signal
//
//  pcp_dak             Memory channel data taken signal
//
//  pcp_d_rd            Memory channel read data
//
//  pm_powered_down_r   True when the Power Management Unit has
//                      'powered down' the core.
//
//========================= Output from this block =========================--
//
//  debug_cmdack        BVCI debug port outputs
//  debug_rdata_r
//  debug_reop
//  debug_rspval
//  debug_rerror_r
//
//  h_addr              Core or auxiliary register address
//
//  h_dataw             Core or auxiliary write data
//
//  h_write             Core or auxiliary write command
//
//  h_read              Core or auxiliary read command
//
//  aux_access          Address space selects for non-memory access
//  core_access
//  madi_access         (deprecated)
//
//  halt                (tied off)
//
//  xstep               (tied off)
//
//  pcp_wr_rq           Memory write request
//
//  pcp_rd_rq           Memory read request
//
//  pcp_addr            Memory address
//
//  pcp_brst            Memory request burst size, always one longword
//
//  pcp_mask            Memory request byte enables, always all true
//
//  pcp_d_wr            Memory write data
//
//==========================================================================--
//
module hif2bt(
  clk_ungated,
  rst_a,
  debug_address,
  debug_be,
  debug_cmd,
  debug_cmdval,
  debug_eop,
  debug_rspack,
  debug_wdata,
  noaccess,
  hold_host,
  h_datar,
  pc_sel_r,
  en,
  reset_applied_r,
  pcp_ack,
  pcp_dlat,
  pcp_dak,
  pcp_d_rd,

  debug_cmdack,
  debug_rdata_r,
  debug_reop,
  debug_rspval,
  debug_rerror_r,
  h_write,
  h_read,
  h_addr,
  h_dataw,
  aux_access,
  core_access,
  madi_access,
  halt,
  xstep,
  pcp_wr_rq,
  pcp_rd_rq,
  pcp_addr,
  pcp_brst,
  pcp_mask,
  pcp_d_wr
  );

  `include "arcutil_pkg_defines.v"
  `include "arcutil.v"
  `include "extutil.v"
  `include "ext_msb.v"

  input                   clk_ungated;     //  clock
  input                   rst_a;            //  reset async

  // ARC interface
  //
  output                  h_write;
  output                  h_read;
  output [31 : 0]         h_addr;
  output [31 : 0]         h_dataw;
  input  [31 : 0]         h_datar;
  output                  aux_access;
  output                  core_access;
  output                  madi_access;
  input                   noaccess;
  input                   hold_host;
  output                  halt;
  output                  xstep;

  //  from xaux_regs for debug_port status reg
  //
  input                   pc_sel_r;

  //  from aux_regs for debug_port status reg
  //
  input                   en;
  input                   reset_applied_r;

  //  Arbitrator interface
  //
  output                  pcp_wr_rq;
  output                  pcp_rd_rq;
  output [EXT_A_MSB : 0]  pcp_addr;
  output [7 : 0]          pcp_brst;
  output [3 : 0]          pcp_mask;
  output [31 : 0]         pcp_d_wr;
  input  [31 : 0]         pcp_d_rd;
  input                   pcp_ack;
  input                   pcp_dlat;
  input                   pcp_dak;

  // BVCI target interface
  //
  input  [31 : 0]         debug_address;  //  Byte Address
  input  [3 : 0]          debug_be;       //  Byte enables
  input  [1 : 0]          debug_cmd;      //  Command
  input                   debug_cmdval;   //  Command Valid
  input                   debug_eop;      //  End Of Packet
  input                   debug_rspack;   //  Response ACK
  input  [31 : 0]         debug_wdata;    //  Write Data
  output                  debug_cmdack;   //  Command Ack
  output [31 : 0]         debug_rdata_r;    //  Read Data
  output                  debug_reop;     //  (unused)
  output                  debug_rspval;   //  Rsp Valid
  output                  debug_rerror_r;   //  Rsp error

  wire   [31 : 0]         h_addr;
  wire   [31 : 0]         h_dataw;
  reg                     h_write;
  reg                     h_read;
  wire                    aux_access;
  wire                    core_access;
  wire                    madi_access;
  wire                    halt;
  wire                    xstep;
  reg                     pcp_wr_rq;
  reg                     pcp_rd_rq;
  wire   [EXT_A_MSB : 0]  pcp_addr;
  wire   [7 : 0]          pcp_brst;
  wire   [3 : 0]          pcp_mask;
  wire   [31 : 0]         pcp_d_wr;
  wire                    debug_cmdack;
  reg    [31 : 0]         debug_rdata_r;
  wire                    debug_reop;
  wire                    debug_rspval;
  reg                     debug_rerror_r;

  //  These signals are all to do with the registers. There are the registers
  //  themselves, the signals used to increment the address after an operation,
  //  and the signal, resulting from a write to the status register, that
  //  initiates an operation.
  reg                     do_command_nxt;
  reg                     do_command_r;
  reg                     increment_address_nxt;
  reg                     increment_address_r;
  wire   [31 : 0]         address_increment;
  reg    [31 : 0]         i_data_out_nxt;
  reg    [31 : 0]         i_data_out_r;
  reg    [31 : 0]         i_data_in_nxt;
  reg    [31 : 0]         i_data_in_r;
  reg    [31 : 0]         i_address_nxt;
  reg    [31 : 0]         i_address_r;
  reg    [31 : 0]         debug_rdata_nxt;
  wire   [31 : 0]         debug_rdata_src;
  reg    [3 : 0]          i_command_nxt;
  reg    [3 : 0]          i_command_r;
  reg                     i_rspval_nxt;
  reg                     i_rspval_r;
  reg                     debug_rerror_nxt;

  reg                     fail_nxt;
  reg                     fail;               //  Access failed status
  reg                     stalled;            //  Waiting for memory
  reg                     i_pc_sel_r;         //  from xaux_regs
  reg                     ready_nxt;
  reg                     ready;              //  Ready to access ARC

  reg    [3 : 0]          tsm_fsm_nxt;
  reg    [3 : 0]          tsm_fsm_r;

  // ------------------begin rtl architecture-------------------------------
  // -------------------------------------------------------------------------
  //  drive constant values
  // -------------------------------------------------------------------------
  //
  //  These are registers, so they all respond in a single cycle
  assign debug_cmdack = 1'b1;

  //  These signals are unused and tied off
  assign halt         = 1'b0;
  assign xstep        = 1'b0;

  //  This one is ignored, but always true since we only support
  //  one-cell packets
  assign debug_reop   = 1'b1;

  // -------------------------------------------------------------------------
  //  read/write registers: address, data, command
  //  special register: status
  // -------------------------------------------------------------------------
  always @(debug_cmdval or debug_address or debug_cmd or debug_wdata or
           i_rspval_r or debug_rspack or increment_address_r or i_address_r or
           address_increment or debug_rerror_r or i_data_out_r or i_command_r or
           debug_rdata_r or debug_rdata_src)
  begin : HIF_ASYNC_PROC
    do_command_nxt    = 1'b0; // default values
    debug_rerror_nxt  = debug_rerror_r;
    i_address_nxt   = i_address_r;
    i_data_out_nxt  = i_data_out_r;
    i_command_nxt   = i_command_r;
    i_rspval_nxt    = i_rspval_r;
    debug_rdata_nxt   = debug_rdata_r;

    if (debug_cmdval == 1'b1)
    begin
      if ((debug_address[31 : `ADDR_SIZE] == `BASE_ADDR) &&
          (debug_address[1 : 0] == 2'b00))
      begin
        debug_rerror_nxt          = 1'b0; // default value
        case (debug_cmd)
          `BVCI_CMD_READ :
            case (debug_address[`ADDR_SIZE - 1 : 2])
              `ADDRESS_R_ADDR, `DATA_R_ADDR, `COMMAND_R_ADDR, `STATUS_R_ADDR :
                debug_rdata_nxt   = debug_rdata_src;

              default :
                debug_rerror_nxt  = 1'b1;
            endcase

          `BVCI_CMD_WRITE :
            case (debug_address[`ADDR_SIZE - 1 : 2])
              `ADDRESS_R_ADDR :
                i_address_nxt   = debug_wdata;

              `DATA_R_ADDR :
                i_data_out_nxt  = debug_wdata;

              `COMMAND_R_ADDR :
                i_command_nxt   = debug_wdata[3 : 0];

              `DO_CMD_ADDR :
                do_command_nxt  = 1'b1;

              `RESET_ADDR :
              begin
                i_address_nxt   = { 32 { 1'b0 }};
                i_data_out_nxt  = { 32 { 1'b0 }};
                i_command_nxt   = `CMD_RESET_VALUE;
              end

              default :
                debug_rerror_nxt  = 1'b1;
            endcase

          `BVCI_CMD_NOP :
            ;

          default :
            debug_rerror_nxt      = 1'b1;

        endcase
      end

      else
        debug_rerror_nxt          = 1'b1;

      i_rspval_nxt    = 1'b1;
    end

    //  Handle the generation of debug_rspval
    if ((i_rspval_r == 1'b1) && (debug_rspack == 1'b1))
      i_rspval_nxt    = 1'b0;

    //  Increment the address register if necessary
    if (increment_address_r == 1'b1)
      i_address_nxt   = i_address_r + address_increment;
  end

  always @(posedge clk_ungated or posedge rst_a)
  begin : HIF_SYNC_PROC
    if (rst_a == 1'b1)
    begin
      i_address_r   <= { 32 { 1'b0 }};
      i_data_out_r  <= { 32 { 1'b0 }};
      i_command_r   <= `CMD_RESET_VALUE;
      debug_rdata_r <= { 32 { 1'b0 }};
      i_rspval_r    <= 1'b0;
      debug_rerror_r <= 1'b0;
      do_command_r    <= 1'b0;
      i_pc_sel_r    <= 1'b0;
    end

    else
    begin
      i_address_r   <= i_address_nxt;
      i_data_out_r  <= i_data_out_nxt;
      i_command_r   <= i_command_nxt;
      debug_rdata_r <= debug_rdata_nxt;
      i_rspval_r    <= i_rspval_nxt;
      debug_rerror_r <= debug_rerror_nxt;
      do_command_r    <= do_command_nxt;
      i_pc_sel_r    <= pc_sel_r;
    end
  end

  //  Drive outputs
  assign debug_rdata_src  =
    (debug_address[`ADDR_SIZE - 1 : 2] == `ADDRESS_R_ADDR)  ? i_address_r :
    (debug_address[`ADDR_SIZE - 1 : 2] == `DATA_R_ADDR)     ? i_data_in_r :
    (debug_address[`ADDR_SIZE - 1 : 2] == `COMMAND_R_ADDR)  ? i_command_r :
    (debug_address[`ADDR_SIZE - 1 : 2] == `STATUS_R_ADDR)   ?
      { 
      reset_applied_r,
      en,
      i_pc_sel_r, ready, 
      fail, 
      stalled
      } : { 32 { 1'b0 }};

  assign debug_rspval     = i_rspval_r;

  //  This is the state machine that performs the actual communication with
  //  the ARC and local memory. The state machine is kicked off when a BVCI
  //  write to the status register causes do_command_r to be asserted.
  always @(tsm_fsm_r or do_command_r or fail or ready or i_command_r or 
           pcp_ack or pcp_dlat or pcp_d_rd or pcp_dak or noaccess or
           hold_host or 
           h_datar or i_data_in_r)
  begin : TXN_FSM_ASYNC_PROC
    increment_address_nxt = 1'b0; // default values
    fail_nxt                  = fail;
    ready_nxt                 = ready;
    tsm_fsm_nxt               = tsm_fsm_r;
    i_data_in_nxt             = i_data_in_r;

    case (tsm_fsm_r)
      //  The reset state is used to direct the Transaction State Machine
      //  to the idle state after a system reset.
      `S_RST :
      begin
        ready_nxt             = 1'b1;
        tsm_fsm_nxt           = `S_IDLE;
      end

      //  The `S_WAIT_H state is entered at the end of a transaction. It
      //  handles incrementing of the address register, then goes to the
      //  idle state. It isn't strictly necesary, but there is no real
      //  speed constraint and it makes the code simpler.
      `S_WAIT_H :
      begin
        increment_address_nxt = 1'b1;
        ready_nxt             = 1'b1;
        tsm_fsm_nxt           = `S_IDLE;
      end

      //  The `S_IDLE state is held until do_command_r has been asserted and
      //  there is a valid transaction code in the command register. When
      //  the trigger signal has been asserted and there is a valid
      //  command, the Transaction State Machine enters the starting
      //  state of the requested transaction.
      `S_IDLE :
        if (do_command_r == 1'b1)
        begin
          //  Clear out the fail bit now that a new mode has started
          fail_nxt  = 1'b0;
          ready_nxt = 1'b0; // We're starting a transaction

          //  Determine the transaction protocol to run
          case (i_command_r)
            `CMD_RD_MEM :
              tsm_fsm_nxt = `S_MR_RQ; //  do mem read request

            `CMD_WR_MEM :
              tsm_fsm_nxt = `S_MW_RQ; //  do mem write request

            `CMD_RD_AUX :
              tsm_fsm_nxt = `S_ARC_READ; //  do arc aux space read request

            `CMD_RD_MADI :
              tsm_fsm_nxt = `S_ARC_READ; //  do arc madi space read request

            `CMD_RD_CORE :
              tsm_fsm_nxt = `S_ARC_READ; //  do arc core register read request

            `CMD_WR_AUX :
              tsm_fsm_nxt = `S_ARC_WRITE; //  do arc aux space write request

            `CMD_WR_MADI :
              tsm_fsm_nxt = `S_ARC_WRITE; //  do arc madi space write request

            `CMD_WR_CORE :
              tsm_fsm_nxt = `S_ARC_WRITE; //  do arc core register write request

            `CMD_RESET_VALUE :
            begin
              tsm_fsm_nxt = `S_IDLE; //  reset value is a nop
              ready_nxt   = 1'b1;
            end

            default :
            begin
              tsm_fsm_nxt = `S_IDLE; //  everything else is an error
              fail_nxt    = 1'b1;
              ready_nxt   = 1'b1;
            end
          endcase
        end

      //  Wait for a memory read acknowledge
      //
      //  In the `S_MR_RQ state the Transaction State Machine waits until
      //  the memory has acknowledged the request. When the request has
      //  been acknowledged the state machine moves onto the `S_MR_WAIT
      //  state. Otherwise the state is held.
      `S_MR_RQ :
        if (pcp_ack == 1'b1)
          tsm_fsm_nxt = `S_MR_WAIT;

      //  Latch the data present on the read bus
      //
      //  In the `S_MR_WAIT state, the Transaction State Machine waits for
      //  the latch permission signal pcp_d_rd to be asserted before
      //  latching the data present on the read bus into the data register.
      //  latching takes place on the next rising edge after the pcp_dlat
      //  signal has been asserted. The state machine then moves onto the
      //  `S_WAIT_H state.
      `S_MR_WAIT :
           begin
             if (pcp_dlat == 1'b 1)
              begin
                i_data_in_nxt = pcp_d_rd;
                tsm_fsm_nxt   = `S_WAIT_H;
              end
           end

      //  Wait for a memory write acknowledge
      //
      //  In the `S_MW_RQ state the Transaction State Machine waits until
      //  the memory has acknowledged the write request. When the request
      //  has been acknowledged the state machine then state checks the
      //  state of the pcp_dak signal. If the signal has been asserted the
      //  state machine goes to the S_WAIT state, if it has not been
      //  asserted then the state machine waits for the data to be taken by
      //  entering the `S_MW_WAIT  state.
      `S_MW_RQ :
          if (pcp_ack == 1'b 1)
                 //
                 //  we can accept ACK and DAK on the same cycle
                 //
                begin
                  if (pcp_dak == 1'b1) tsm_fsm_nxt = `S_WAIT_H;
                  else                 tsm_fsm_nxt = `S_MW_WAIT;
                end

      //  Wait until memory accept the data
      //
      //  The `S_MW_RQ state is entered from `S_MW_RQ when the memory has
      //  not yet accepted the data present on the write bus. The state is
      //  held until the pcp_dak signal has been asserted.
      `S_MW_WAIT :
            begin
              if (pcp_dak == 1'b 1) tsm_fsm_nxt = `S_WAIT_H;
            end

      //  ARC read request evaluation
      //
      //  The `S_ARC_READ state evaluates a read request to the ARC core.
      //  If the ARC rejects the read request (i.e. if it is running) the
      //  state asserts the fail signal and then enters the `S_WAIT_H
      //  state. If the ARC requests the access to stall, then the state
      //  machine enters the `S_AR_STALL state which is used for stalling
      //  reads. If all is fine the `S_ARC_READ2 state is entered which
      //  captures the data present on the read bus.
      `S_ARC_READ :
        if (noaccess == 1'b1)
        begin
          tsm_fsm_nxt = `S_WAIT_H;
          fail_nxt    = 1'b1;
        end

        else if (hold_host == 1'b1)
          tsm_fsm_nxt = `S_AR_STALL;

        else
          tsm_fsm_nxt = `S_ARC_READ2;

      //  Latch the incoming data
      //
      //  The `S_ARC_READ2 state is used to grab data coming back from the
      //  ARC at the end of a read transaction. The `S_WAIT_H state is
      //  entered on the following rising edge of clk_ungated.
      `S_ARC_READ2 :
      begin
        i_data_in_nxt = h_datar;   //  latch the data on the host read
        tsm_fsm_nxt   = `S_WAIT_H; //  data bus
      end

      //  ARC read stall state
      //
      //  The `S_AR_STALL state is used to halt the Transaction State
      //  Machine when the ARC asserts a hold host. When the host host has
      //  finally deasserted the hold host signal the `S_ARC_READ2 state is
      //  entered to latch the data present on the read data bus.
      `S_AR_STALL :
        if (hold_host == 1'b0)
          tsm_fsm_nxt = `S_ARC_READ2;

      //  ARC write request evaluation
      //
      //  The ARC read request state evaluates a write request to the ARC
      //  core. If the ARC rejects the write request (i.e. if it is
      //  running) the state asserts the fail signal and then enters the
      //  `S_WAIT_H state. If the ARC requests the access to stall, then the
      //  `S_AR_STALL state which is used for stalled reads. If all is fine
      //  the `S_WAIT_H state is entered to end the write transaction.
      `S_ARC_WRITE :
        if (noaccess == 1'b1)
        begin
          tsm_fsm_nxt = `S_WAIT_H;
          fail_nxt    = 1'b1;
        end

        else if (hold_host == 1'b0)
          tsm_fsm_nxt = `S_WAIT_H;

        else
          tsm_fsm_nxt = `S_AW_STALL;

      //  ARC write stall state
      //
      //  The read stall state is used to halt the Transaction State
      //  Machine when the ARC asserts a hold host. When the host host is
      //  finally deasserted the `S_ARC_READ2 state is entered to latch the
      //  data present on the read data bus.
      `S_AW_STALL :
        if (hold_host == 1'b0)
          tsm_fsm_nxt = `S_WAIT_H;

      //  reset to the idle state if we are is an undefined state
      default :
      begin
        tsm_fsm_nxt   = `S_IDLE;
        ready_nxt     = 1'b1;
      end
    endcase
  end

  always @(posedge clk_ungated or posedge rst_a)
  begin : TXN_FSM_SYNC_PROC
    if (rst_a == 1'b1)
    begin
      //  upon a rst_a signal reset the transaction state machine.
      tsm_fsm_r             <= `S_RST;
      fail                <= 1'b0; //  clear out the failed status
      ready               <= 1'b1; //  We can accept a command
      i_data_in_r         <= { 32 { 1'b0 }};
      increment_address_r <= 1'b0;
    end

    else
    begin
      tsm_fsm_r             <= tsm_fsm_nxt;
      fail                <= fail_nxt;
      ready               <= ready_nxt;
      i_data_in_r         <= i_data_in_nxt;
      increment_address_r <= increment_address_nxt;
    end
  end

  //  Host interface state machine
  //
  //  Asynchronous part
  //  This part is used to generate the correct control signals for an upcoming
  //  transaction, as well as the stalled status bit.
  always @(tsm_fsm_r)
  begin : ARC_FSM_ASYNC_PROC
    h_write   = 1'b0;
    h_read    = 1'b0;
    pcp_wr_rq = 1'b0;
    pcp_rd_rq = 1'b0;
    stalled   = 1'b0;

    case (tsm_fsm_r)
      `S_MR_RQ :
        pcp_rd_rq = 1'b1;

      `S_MW_RQ :
        pcp_wr_rq = 1'b1;

      `S_ARC_READ :
        h_read    = 1'b1;

      `S_AR_STALL :
      begin
        h_read    = 1'b1;
        stalled   = 1'b1;
      end

      `S_ARC_WRITE :
        h_write   = 1'b1;

      `S_AW_STALL :
      begin
        h_write   = 1'b1;
        stalled   = 1'b1;
      end

      default :
        ;

    endcase
  end

  //  This concurrent statement produces the amount by which the address
  //  register is incremented after an operation.
  //
  assign address_increment =
    ((i_command_r == `CMD_RD_MEM)||(i_command_r == `CMD_WR_MEM)) ? `MEM_OFFSET :
                                                               `REG_OFFSET;

  // Output drives of signals
  //
  // ARC and memory address will always be from the address register
  assign h_addr   = i_address_r;                // 32 bits
  assign pcp_addr = i_address_r[EXT_A_MSB : 0]; // EXT_A_WIDTH bits

  //  Burst and mask are fixed.
  //
  assign pcp_brst = 8'b00000011;
  assign pcp_mask = 4'b1111;

  //  ARC and memory write data will always be from the 32-bit register
  //
  assign h_dataw  = i_data_out_r;
  assign pcp_d_wr = i_data_out_r;

  //  Select which type of host access is going to happen.
  //
  assign aux_access  = (i_command_r[1 : 0] == `CMD_AUX);
  assign core_access = (i_command_r[1 : 0] == `CMD_CORE);
  assign madi_access = ((i_command_r == `CMD_WR_MADI) ||
                        (i_command_r == `CMD_RD_MADI));
                       

endmodule // module hif2bt
