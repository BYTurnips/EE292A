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
// The JTAG Debug Port is the module that contains all the
// internal JTAG registers and performs the actual communication
// between the ARC600 and the host. Refer to the JTAG section in
// the ARC interface manual for an explanation on how to
// communicate with the complete module. In this revision, the
// debug port does not contain the address, data, command, or
// status registers.  These physically reside on the other side
// of a BVCI interface, and are read by the debug port during the
// Capture-DR state and written during the Update-DR state. A
// command is initiated during the Run-Test/Idle state by writing
// a do-command address over the BVCI interface, and the
// registers are reset during the Test-Logic-Reset state by
// writing a reset address.
//
//======================= Inputs to this block =======================--
//
// jtag_trst_a          The internal version of TRST*, conditioned to be
//                      asynchronously applied and synchronously released
//
// jtag_tck             The JTAG clock
//
// jtag_tck_muxed       The inverted JTAG clock during functional mode
//                      JTAG clock during test mode
//
// jtag_tdi             JTAG Test Data In, input to the data and instruction
//                      shift registers
//
// jtag_bsr_tdo         Test Data Out from the user's boundary scan register
//
// test_logic_reset     TAP controller state decodes
//                      run_test_idle
//                      capture_ir
//                      shift_ir
//                      update_ir
//                      capture_dr
//                      shift_dr
//
// select_r             Selects instruction or data shift register for TDO
//
// test_logic_reset_nxt TAP controller next state decodes
//                      run_test_idle_nxt
//                      select_dr_scan_nxt
//                      capture_dr_nxt
//                      update_dr_nxt
//
// debug_rdata_r          Read data from the BVCI debug port
//
//====================== Output from this block ======================--
//
// bvci_addr_r            Variable part of BVCI address, to be synchronized with
//                      clk_main
//
// bvci_cmd_r             BVCI command, to be synchronized with clk_main
//
// debug_be             BVCI Byte Enables. All bytes always enabled
//
// debug_eop            BVCI End Of Packet. Always true; we only do one-word
//                      transfers
//
// debug_rspack         BVCI Response Acknowledge. Always true.
//
// debug_wdata          BVCI Write Data. Only changed on entry to Update-DR, do
//                      doesn't need to be synchronized
//
// do_bvci_cycle        Request to perform a transaction on the BVCI debug
//                      interface. Edge-signaling.
//
// arca_busy            JTAG busy signal. Used for activity LED if desired
//
// jtag_tdo_r             JTAG Test Data Out. Output from shift registers
//
// jtag_extest_mode     Decodes for user boundary scan circuitry
// jtag_sample_mode
//
//====================================================================--
//
module debug_port(
  jtag_tck,
  jtag_tck_muxed,
  jtag_trst_a,
  jtag_tdi,
  debug_rdata_r,
  jtag_bsr_tdo,
  test_logic_reset,
  run_test_idle,
  shift_ir,
  update_ir,
  shift_dr,
  capture_dr,
  capture_ir,
  select_r,
  test_logic_reset_nxt,
  run_test_idle_nxt,
  select_dr_scan_nxt,
  capture_dr_nxt,
  update_dr_nxt,

  do_bvci_cycle,
  arca_busy,
  jtag_tdo_r,
  bvci_addr_r,
  debug_be,
  bvci_cmd_r,
  debug_eop,
  debug_rspack,
  debug_wdata,
  jtag_extest_mode,
  jtag_sample_mode
  );

`include "arcutil_pkg_defines.v"
`include "arcutil.v"
`include "extutil.v"

  // Inputs for JTAG interface
  input                       jtag_tck;
  input                       jtag_tck_muxed;
  input                       jtag_trst_a;
  input                       jtag_tdi;

  //  This input is generated in the BVCI target, synchronous to the system
  //  clock.
  //
  input  [31 : 0]             debug_rdata_r;  // Read data

  // Connection to a Boundary Scan Register (scan chain) will involve decoding
  // eight signals called jtag_bsr_tdo, jtag_extest_mode, jtag_sample_mode,
  // capture_en, shiftdr_en, updatedr_en and jtag_tdi. The jtag_tdi is connected
  // to the first cell in the Boundary Scan Register. The jtag_bsr_tdo pin is
  // wired to the final cell of the Boundary Scan Register.

  // The jtag_extest_mode and jtag_sample_mode signals are used as master
  // enables. This allow the Boundary Scan Register to be activated
  // whenever the EXTEST or SAMPLE instruction is selected.

  // The shiftdr_en, capturedr_en and updatedr_en enable signals are
  // combined with decoding logic allowing the shift and latch elements of
  // the Boundary Scan Register to be controlled in the Shift-DR,
  // Capture-DR and Update-DR TAP states.

  input                       jtag_bsr_tdo; // Output from boundary scan cell

  //  TAP Controller Interface (state control signals) Signals indicating that
  //  the TAP controller is in a certain state
  input                       test_logic_reset;
  input                       run_test_idle;
  input                       shift_ir;
  input                       update_ir;
  input                       shift_dr;
  input                       capture_dr;
  input                       capture_ir;

  input                       select_r;

  // Signals indicating that the TAP controller will enter a certain state
  // on the next clock
  input                       test_logic_reset_nxt;
  input                       run_test_idle_nxt;
  input                       select_dr_scan_nxt;
  input                       capture_dr_nxt;
  input                       update_dr_nxt;

  // Signals from here on are synchronous to the JTAG clock.
  //
  // BVCI transaction request. Edge-signaling, and synchronized to system clock
  // in sys_clk_sync.
  output                      do_bvci_cycle;

  // Used to indicate that a transaction is taking place. Tied to activity LED
  // on ARCangel 3 board.
  output                      arca_busy;

  //  Additional signals for JTAG Interface
  //
  output                      jtag_tdo_r;

  //  BVCI initiator interface, except for cmdval, which is generated in the
  //  sys_clk_sync module on the system clock. These are all generated on the
  //  JTAG clock, but are not sampled in the BVCI target until it sees cmdval,
  //  which is guaranteed to be later since it's generated from
  //  a system-clock-synchronized version of a signal generated on the JTAG
  //  clock.
  output [`ADDR_SIZE - 1 : 2] bvci_addr_r;    // Longword address, variable part
  output [3 : 0]              debug_be;     // Byte enables
  output [1 : 0]              bvci_cmd_r;     // Command
  output                      debug_eop;    // End-of-packet
  output                      debug_rspack; // Response acknowledge
  output [31 : 0]             debug_wdata;  // Write data

  output                      jtag_extest_mode; // IR decode to boundary scan
  output                      jtag_sample_mode; // IR decode to boundary scan


  reg    [`ADDR_SIZE - 1 : 2] bvci_addr_r;
  wire   [3 : 0]              debug_be;
  reg    [1 : 0]              bvci_cmd_r;
  wire                        debug_eop;
  wire                        debug_rspack;
  wire   [31 : 0]             debug_wdata;
  wire                        do_bvci_cycle;
  wire                        arca_busy;
  reg                         jtag_tdo_r;
  wire                        jtag_extest_mode;
  wire                        jtag_sample_mode;

  //  Signal used to communicate with the BVCI cycle initiator.
  reg                         i_do_bvci_cycle_r;

  //  The following signals are generated from D-type-flops with enables
  //  and are used to hold the data register contents. The registers are
  //  commonly referred to as shadow latches (IEEE Std 1149.1).
  reg    [31 : 0]             shift_register_r;   // the shift reg (used by DRs)
  reg    [3 : 0]              ir_latch_r;         // the instruction register
  reg    [3 : 0]              ir_sreg_r;          // shift register for IR
  reg                         bypass_reg_r;       // bypass reg, a one bit reg

  //  The following signals are used to connect to the TDO output. The TDO
  //  output can be connected to two source outputs, the data registers or
  //  the instruction register.
  wire                        tdo_src_dr;       // DRs muxed to TDO
  wire                        tdo_src_ir;       // IR muxed to TDO

  //  Misc signals used in decoding and other stuff
  integer                     index;            // used for the shift register

  //  interface signals that connect to the boundary scan register. The two
  //  signals are driven when a specific instruction is selected.
  assign jtag_extest_mode = (ir_latch_r == `IR_EXTEST);
  assign jtag_sample_mode = (ir_latch_r == `IR_SAMPLE);

  //  The busy signal that goes onto the orange led of the ARCAngel
  assign arca_busy = ~ (run_test_idle | test_logic_reset);

  //  The concurrent statement below is used to select the appropriate data
  //  register output for the TDO signal. The signal inputs to this mux are
  //  taken from the LSB of the shift register, the boundary scan register
  //  last cells output and the bypass register. Only one of LSB bits is
  //  selected to the tdo_src_dr output dependent upon the value contained
  //  in the instruction latch. The selected signal is then pass on into
  //  the final mux, which determines what goes onto the TDO output pin.
  //  As per the JTAG spec, all unused instructions select the bypass
  //  register.
  assign tdo_src_dr = ((ir_latch_r == `IR_STATUS)||(ir_latch_r == `IR_COMMAND)||
                       (ir_latch_r == `IR_ADDRESS)||(ir_latch_r == `IR_DATA)  ||
                       (ir_latch_r == `IR_IDCODE)) ?
                      shift_register_r[0] :

                      ((ir_latch_r == `IR_EXTEST)||(ir_latch_r == `IR_SAMPLE)) ?
                      jtag_bsr_tdo :

                      bypass_reg_r; // Covers ir_latch_r == `IR_BYPASS
                                  // and all other cases

  //  the LSB of the instruction register is always selected for this source.
  assign tdo_src_ir = ir_sreg_r[0];

  //  The process statement below selects between the data or instruction
  //  register to the main TDO output. The selection is made according to
  //  the select_r signal that comes from the TAP controller. It indicates
  //  what type of register is being accessed (if any). HIGH = instruction
  //  register access, LOW = data register access. The TDO output always
  //  changes on the falling edge of TCK, which is implemented by inverting
  //  jtag_tck to jtag_tck_muxed in functional mode
  always @(posedge jtag_tck_muxed or posedge jtag_trst_a)
  begin : TDO_OUTPUT_PROC
    if (jtag_trst_a == 1'b1)
      jtag_tdo_r <= 1'b0;

    else
      if (test_logic_reset == 1'b1)
        jtag_tdo_r <= 1'b0;

      else if ((shift_dr == 1'b1) | (shift_ir == 1'b1))
        if (select_r == 1'b0)
          jtag_tdo_r <= tdo_src_dr;
        else
          jtag_tdo_r <= tdo_src_ir;
  end

  //  The shift Data Register Cell
  //
  //  The shift data register is used to load and unload data from the
  //  selected data register and serially shift data in from TDI and out
  //  through TDO. Data is loaded into the shift cell when the capture_dr
  //  state is entered and the instruction register contains a valid
  //  instruction code.
  always @(posedge jtag_tck or posedge jtag_trst_a)
  begin : DR_SHIFT_REG_CELL_PROC
    if (jtag_trst_a == 1'b1)
      shift_register_r <= { `SREG_SIZE { 1'b0 }};

    else
      if (test_logic_reset == 1'b1)
        shift_register_r <= { `SREG_SIZE { 1'b0 }};

      else if (shift_dr == 1'b1)
        //  Command is 4 bits
        if (ir_latch_r == `IR_COMMAND)
        begin //  shift register on by one
          for (index = 0; index < (`JTAG_CMD_SIZE - 1); index = index + 1)
            shift_register_r[index] <= shift_register_r[index + 1];
          shift_register_r[`JTAG_CMD_MSB] <= jtag_tdi; // latch new data
        end
        // Status is 6 bits
        else if (ir_latch_r == `IR_STATUS)
        begin //  shift register on by one
          for (index = 0; index < (`JTAG_STATUS_SIZE - 1); index = index + 1)
            shift_register_r[index] <= shift_register_r[index + 1];
          shift_register_r[`JTAG_STATUS_MSB] <= jtag_tdi; // latch new data
        end
        else //  All others are 32 bits
        begin //  shift register on by one
          for (index = 0; index < (`SREG_SIZE - 1); index = index + 1)
            shift_register_r[index] <= shift_register_r[index + 1];
          shift_register_r[`SREG_MSB] <= jtag_tdi; // latch new data
        end

      else if (capture_dr == 1'b1)
        case (ir_latch_r)
          `IR_ADDRESS, `IR_DATA :
            shift_register_r <= debug_rdata_r;

          `IR_COMMAND :
          begin
            shift_register_r[`JTAG_CMD_MSB : 0] <=
              debug_rdata_r[`JTAG_CMD_MSB : 0];
            shift_register_r[`SREG_MSB : `JTAG_CMD_SIZE] <=
              { `SREG_SIZE - `JTAG_CMD_SIZE { 1'b0 }}; // Zero upper bits
          end

          `IR_STATUS :
          begin
            shift_register_r[`JTAG_STATUS_MSB : 0] <=
              debug_rdata_r[`JTAG_STATUS_MSB : 0];
            shift_register_r[`SREG_MSB : `JTAG_STATUS_SIZE] <=
              { `SREG_SIZE - `JTAG_STATUS_SIZE { 1'b0 }}; // Zero upper bits
          end

          `IR_IDCODE :
            shift_register_r <= {`JTAG_VERSION, `TWO_ZEROS, `ARCNUM, `ARC_TYPE,
                               `ARC_JEDEC_CODE, 1'b1}; //  load id register

          default :
            shift_register_r <= { `SREG_SIZE { 1'b0 }};

        endcase
  end

  //  The Shift Instruction Register Cell
  //
  //  The shift instruction register cell is used to shift the elements of the
  //  instruction register.  The capture circuitry loads a 0001 pattern into the
  //  instruction register every time the Capture-IR state is entered. This
  //  allow the communicating device to detect faults along a 1149.1 bus.
  always @(posedge jtag_tck or posedge jtag_trst_a)
  begin : IR_SHIFT_REG_CELL_PROC
    if (jtag_trst_a == 1'b1)
      ir_sreg_r <= 4'b0000;

    else
      if (capture_ir == 1'b1)
        ir_sreg_r <= `IR_INIT; //  whenever we capture IR we must load a 01 into
                             //  the two LSBs. This aids in diagnosing
                             //  faults along the IEEE 1149.1-1990 bus

    else if (shift_ir == 1'b1)
    begin
      ir_sreg_r[3] <= jtag_tdi;   // latch new data in on TDI
      ir_sreg_r[2] <= ir_sreg_r[3]; // shift register on by one
      ir_sreg_r[1] <= ir_sreg_r[2];
      ir_sreg_r[0] <= ir_sreg_r[1];
    end
  end

  //  The following processes are used to load shifted data into instruction or
  //  a selected data register. A D type flip flop with an enable is inferred
  //  for all registers. The enable is asserted active on all data registers
  //  only when the update_dr state is entered and the instruction latch
  //  contains the selected data register code. The instruction register is
  //  updated only when the update-ir state is entered. Note all registers are
  //  updated on the falling edge of the TCK clock when in the update-ir/dr
  //  state, except for the address, command, and data registers, which are
  //  updated via a write over the BVCI interface.
  always @(posedge jtag_tck or posedge jtag_trst_a)
  begin : BVCI_PROC
    if (jtag_trst_a == 1'b1)
    begin
      bvci_cmd_r  <= `BVCI_CMD_NOP;
      bvci_addr_r <= `RESET_ADDR;
    end

    else //  Generate the BVCI address and command
      if (update_dr_nxt == 1'b1)
      begin
        bvci_cmd_r <= `BVCI_CMD_WRITE;
        case (ir_latch_r)
          `IR_ADDRESS :
            bvci_addr_r <= `ADDRESS_R_ADDR;
          `IR_DATA :
            bvci_addr_r <= `DATA_R_ADDR;
          `IR_COMMAND :
            bvci_addr_r <= `COMMAND_R_ADDR;
          default :
            bvci_addr_r <= `RESET_ADDR;
        endcase
      end

      // The address must be presented for two clocks to allow the
      // returned read data to be synchronized before use, as it's
      // generated on the system clock.
      else if ((capture_dr_nxt == 1'b1) || (select_dr_scan_nxt == 1'b1))
      begin
        bvci_cmd_r <= `BVCI_CMD_READ;
        case (ir_latch_r)
          `IR_ADDRESS :
            bvci_addr_r <= `ADDRESS_R_ADDR;
          `IR_DATA :
            bvci_addr_r <= `DATA_R_ADDR;
          `IR_COMMAND :
            bvci_addr_r <= `COMMAND_R_ADDR;
          `IR_STATUS :
            bvci_addr_r <= `STATUS_R_ADDR;
          default :
            bvci_addr_r <= `RESET_ADDR;
        endcase
      end

      else if (run_test_idle_nxt == 1'b1)
      begin
        bvci_cmd_r  <= `BVCI_CMD_WRITE;
        bvci_addr_r <= `DO_CMD_ADDR;
      end

      else if (test_logic_reset_nxt == 1'b1)
      begin
        bvci_cmd_r  <= `BVCI_CMD_WRITE;
        bvci_addr_r <= `RESET_ADDR;
      end

      else
      begin
        bvci_cmd_r  <= `BVCI_CMD_NOP;
        bvci_addr_r <= `RESET_ADDR;
      end
  end

  assign debug_wdata = shift_register_r;

  //  These signals are fixed in this implementation
  assign debug_be     = 4'b1111; // We always write all the bytes
  assign debug_eop    = 1'b1;    // We only do one word
  assign debug_rspack = 1'b1;    // We always take the data in a cycle

  //  This process manages the do_bvci_cycle flop, which is toggled to
  //  request a BVCI cycle. This edge-signaling, rather than level-
  //  signaling, is done so that we can request BVCI cycles on consecutive
  //  JTAG clocks.
  always @(posedge jtag_tck or posedge jtag_trst_a)
  begin : DO_BVCI_CMD_PROC
    if (jtag_trst_a == 1'b1)
      i_do_bvci_cycle_r <= 1'b0;

    else
      if (update_dr_nxt == 1'b1)
        case (ir_latch_r)
          `IR_ADDRESS, `IR_DATA, `IR_COMMAND :
            i_do_bvci_cycle_r <= ~ i_do_bvci_cycle_r;
          default :
            ;
        endcase

      else if (select_dr_scan_nxt == 1'b1) // We do the read speculatively
        case (ir_latch_r)
          `IR_ADDRESS, `IR_DATA, `IR_COMMAND, `IR_STATUS :
            i_do_bvci_cycle_r <= ~ i_do_bvci_cycle_r;
          default :
            ;
        endcase

      else if ((run_test_idle_nxt == 1'b1) && (run_test_idle == 1'b0))
        case (ir_latch_r)
          `IR_BYPASS, `IR_EXTEST, `IR_SAMPLE, `IR_UNUSED0, `IR_UNUSED1,
          `IR_UNUSED2, `IR_UNUSED3, `IR_UNUSED4, `IR_UNUSED5, `IR_UNUSED6,
          `IR_UNUSED7 :
            ;
          default :
            i_do_bvci_cycle_r <= ~ i_do_bvci_cycle_r;
        endcase

      else if (test_logic_reset_nxt == 1'b1)
        i_do_bvci_cycle_r <= ~ i_do_bvci_cycle_r;
  end

  assign do_bvci_cycle = i_do_bvci_cycle_r; //  Drive the output

  //  Note that the instruction register, as required by the JTAG spec, updates
  //  on the falling edge of JTAG clock, which is implemented by inverting 
  //  jtag_tck to jtag_tck_muxed in functional mode
  always @(posedge jtag_tck_muxed or posedge jtag_trst_a)
  begin : THE_INSTRUCTION_REG_PROC
    if (jtag_trst_a == 1'b1)
      ir_latch_r <= `IR_IDCODE;

    else
      if (test_logic_reset == 1'b1)
        ir_latch_r <= `IR_IDCODE;

      else if (update_ir == 1'b1)
        ir_latch_r <= ir_sreg_r; //  update the instruction reg
  end

  //  The following process defines the BYPASS register. The Bypass mode is set
  //  when all ones have been written into instruction register or when the JTAG
  //  port has be reset. The bypass register is set to zero on during
  //  Capture-DR, and to TDI during Shift-DR, and is held in all other states,
  //  as per the JTAG spec.
  always @(posedge jtag_tck or posedge jtag_trst_a)
  begin : BYPASS_BIT_PROC
    if (jtag_trst_a == 1'b1)
      bypass_reg_r <= 1'b0;

    else
      if (capture_dr == 1'b1)
        bypass_reg_r <= 1'b0;

      else if (shift_dr == 1'b1)
        bypass_reg_r <= jtag_tdi;
  end

endmodule // module debug_port
