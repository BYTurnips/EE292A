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
// RASCAL to JTAG port interface
//
// Supports PC and Sun communications protocols, for ARCAngel boards
// v1-3.
//
//========================== Inputs to this block ==========================--
//
//   ra_select       :2  Selects between a register access or
//                       a memory access or a madi access.
//
//   ra_read         :1  Set when a read request is required.
//                       (burst and addr must also be valid).
//
//   ra_write        :1  Set when a write request is required.
//                       (burst, addr and data must be valid).
//
//   ra_burst        :11 Burst size-1 in lwords (max = 2kb). Must
//                       be valid when a read/write request is
//                       valid
//
//   ra_addr         :32 Base address (lword) of transfer request. Must be
//                       valid when read/write request is valid.
//
//   ra_wr_data      :32 Write data bus, stays valid until ra_ack
//                       is recieved.
//
//========================= Output from this block =========================--
//
//   ra_ck           :1  Clock input to RASCAL controller, the
//                       controller synchronises to this clock.
//                       This clock can change it's source or
//                       frequency whenever desired.
//
//   ra_ack          :1  Acknowledges that either the data is valid
//                       for a read, or that data has been consumed
//                       for a write.
//
//   ra_rd_data      :32 Read data bus.
//
//   ra_fail         :2  Set if transaction request
//                       is invalid, or the transaction will
//                       not be able to complete. If the value is 2,
//                       the chip is powered down, and that's the failure
//                       reason.
//
//==========================================================================--
//

// `include "board_pkg_defines.v"
`include "board_pkg_defines.v"

module rascal2jtag(rst_a,
                   ejtag_tck,
                   ejtag_tms,
                   ejtag_tdi,
                   ejtag_tdo,
                   ejtag_trst_n,

xxirq_n_4,
xxirq_n_5,
xxirq_n_6,
xxirq_n_7,
xxirq_n_8,
xxirq_n_9,
xxirq_n_10,
xxirq_n_11,
xxirq_n_12,
xxirq_n_13,
xxirq_n_14,
xxirq_n_15,
xxirq_n_16,
xxirq_n_17,
xxirq_n_18,
xxirq_n_19,
                   ra_select,
                   ra_read,
                   ra_write,
                   ra_burst,
                   ra_addr,
                   ra_wr_data,
                   ra_ck,
                   ra_ack,
                   ra_rd_data,
                   ra_fail);

  `include "arc600constants.v"
//   `include "extutil.v"
 `include "jtag_defs.v"

  input ejtag_tdo;
  input ejtag_trst_n;
  input rst_a;
  output ejtag_tck;
  output ejtag_tms;
  output ejtag_tdi;
  input [1 : 0] ra_select;
  input ra_read;
  input ra_write;
  input [9 : 0] ra_burst;
  input [31 : 0] ra_addr;
  input [31 : 0] ra_wr_data;
  output ra_ck;
  output ra_ack;
  output [31 : 0] ra_rd_data;
  output [1:0] ra_fail;

output xxirq_n_4;
output xxirq_n_5;
output xxirq_n_6;
output xxirq_n_7;
output xxirq_n_8;
output xxirq_n_9;
output xxirq_n_10;
output xxirq_n_11;
output xxirq_n_12;
output xxirq_n_13;
output xxirq_n_14;
output xxirq_n_15;
output xxirq_n_16;
output xxirq_n_17;
output xxirq_n_18;
output xxirq_n_19;
reg xxirq_n_4;
reg xxirq_n_5;
reg xxirq_n_6;
reg xxirq_n_7;
reg xxirq_n_8;
reg xxirq_n_9;
reg xxirq_n_10;
reg xxirq_n_11;
reg xxirq_n_12;
reg xxirq_n_13;
reg xxirq_n_14;
reg xxirq_n_15;
reg xxirq_n_16;
reg xxirq_n_17;
reg xxirq_n_18;
reg xxirq_n_19;
reg clear_xxirq_n_4;
reg clear_xxirq_n_5;
reg clear_xxirq_n_6;
reg clear_xxirq_n_7;
reg clear_xxirq_n_8;
reg clear_xxirq_n_9;
reg clear_xxirq_n_10;
reg clear_xxirq_n_11;
reg clear_xxirq_n_12;
reg clear_xxirq_n_13;
reg clear_xxirq_n_14;
reg clear_xxirq_n_15;
reg clear_xxirq_n_16;
reg clear_xxirq_n_17;
reg clear_xxirq_n_18;
reg clear_xxirq_n_19;

  wire ejtag_tck;
  wire ejtag_tms;
  wire ejtag_tdi;
  wire ra_ck;
  reg ra_ack;
  reg [31 : 0] ra_rd_data;
  reg [1:0] ra_fail;

  reg ra_rq_type;
  wire strobe_pulse;
  wire strobe_low;
  wire [31 : 0] pc_d;
  reg ira_ck;

  // Master generated clock. Do not use directly. Use either ati_ck output
  // or iati_ck internally.
  reg generated_ra_ck;

  //  *************************** Usage Notes ****************************
  //  **                                                                **
  //  **  The signal pc_ddir should be used to control the drive of the **
  //  **  bidirectional pc_data  bus at the pads of the ASIC/FPGA.      **
  //  **  Data should be driven out from the chip when pc_ddir = '1'.   **
  //  **  It is recommended that the pc_ddir signal is sent out from    **
  //  **  the ASIC so that it can be used to control the direction of   **
  //  **  external buffer devices being usedto protect the ASIC - for   **
  //  **  example a 74LS245.                                            **
  //  **                                                                **
  //  **  It should be noted that this module has been designed to work **
  //  **  with the ARCAngelDevelopment boards supplied by ARC Cores Ltd.**
  //  **  These boards feature a switchfor PC/Sun mode which swaps the  **
  //  **  ALF and SEL_IN lines when being used by the Sun.              **
  //  **                                                                **
  //  **  The 'auto detection logic' below uses this feature of the     **
  //  **  boards to detect whether  the first access post-reset is      **
  //  **  coming from a PC or a Sun, and change protocol accordingly.   **
  //  **                                                                **
  //  **  Please refer to document 'ARC Development Board (ARCAngel)'   **
  //  **  for a full discussion of the external signals and             **
  //  **  communications protocol.                                      **
  //  **                                                                **
  //  ********************************************************************
  //
  //   RASCAL Interface
  //
  //   The scheme is this :    Either ra_read or ra_write is set to '1' to
  //                           make a transfer request,
  //                           ra_select,ra_addr and ra_burst are valid at
  //                           this time, ra_wr_data must be valid for
  //                           writes.
  //
  //                           RASCAL then waits for ra_ack to be '1' for
  //                           each data transfer (which may be a multiple
  //                           transfer if ra_burst > 0. (burst value is
  //                           number of lwords-1.
  //
  //                           The address is offset by 64 for auxillary
  //                           register access, ie:
  //                           ra_addr = 0->63 : core registers 0->63
  //                           ra_addr = 64->N : auxillary registers
  //                                             0->(N-64)
  //
  //                          ra_select = "01" for core register access,
  //                                      "00" for memory access,
  //                                      "11" for madi accesses,
  //                                  and "10" for auxiliary register
  //                                               access.
  // ---------------------------------------------------------------------
  //  RASCAL clock generator.

  // TYPE access_type:
  `define access_type_core 0
  `define access_type_aux 1
  `define access_type_memory 2
  `define access_type_madi 3

  `define MADI_PROCESSOR_REG_ADDR 32'h0000_0000
  `define MADI_JTAG_BIST_REG 32'h0000_0010

  `define AUX_IVIC 32'h0000_0010 // Auxiliary register to invalidate I-cache

  // TYPE request_type:
  `define request_type_read 0
  `define request_type_write 1

  // TYPE rascal_states:
  // idle state
  `define idle 0
  // performs jtag data transfers
  `define perform_request 1
  // acknowledges transfer to RASCAL
  `define acknowledge_request 2
  // one cycle to clear acknowledge
  `define acknowledge_clear 3

  reg [9 : 0] burst_count;
  reg [9 : 0] burst_size;
  reg [31 : 0] request_addr;
  reg [31 : 0] write_data;

  reg [1 : 0] ra_access_type;
  reg [1 : 0] rascal_state;

  integer command;

  //Intercept MADI writes and direct to specific processor.
  reg [31 : 0] processor;
  integer num_processors;

  // These are used by the JTAG BIST
  reg jtag_bist_passed;
  reg jtag_ireg_ok;
  reg [4 : 0] jtag_reg_len_ok;
  reg jtag_bypass_ok;
  reg [3 : 0] jtag_reg_ok;
  reg [7 : 0] jtag_unused_ok;
  reg jtag_reset_ok;
  reg jtag_transaction_ok;
  reg jtag_high_z_ok;

  reg tck;
  reg tdi;
  reg tms;
  reg [31 : 0] tdo_data; // used to store the shifted out data
  reg [32 * `MAX_PROCESSORS - 1 : 0] tdo_capture;
  reg [`JTAG_STATUS_REG_LEN-1 : 0] status; // used to store the status of JTAG port
  reg result;
  reg powerdown;

  integer i;

  //  Procedures used by the jtag_model.
  //
  // The following sections contains procedures that are used to communicate with the JTAG port.
  // Theses procedures allow the host device to write and read to the ARC or local sram memory.
  // the jtag signals TMS, TDI are taken from the epc_d bus signals and TDO is taken from
  // the epc_sel signal and TCK driven to the epc_str signal.

  // The procedure Clock_TCK applies a clock on TCK for a number of times specified in an argument.
  //
  task Clock_TCK;
    input no_of_cycles; //go through how many cycles?
    integer no_of_cycles;
    integer clk_count;

    // ok clock TCK for the number of cycles specified in the no_of_cycles variable. This is done
    // without changing the logic level of TMS.
    begin : clock_tck
      for (clk_count = 0; clk_count < no_of_cycles; clk_count = clk_count + 1)
        begin
          # `TCK_HALF_PERIOD_TDO
            ;
          tck <= 1'b1;
          # `TCK_HALF_PERIOD
            ;
          tck <= 1'b0;
          # `DELAY_ON_TDO
            ;
        end
    end
  endtask

  //-------------------------------------------------------------------------------------------
  //
  // The Start_JTAG_Sequence procedure is the lowest level in communicating directly with the
  // JTAG port. The procedure is used with the aid of flags to control the TAP controller which
  // is used to load/unload data registers and trigger transactions across the ARC host bus or
  // memory sequencer bus.
  //
  task Start_JTAG_Sequence;
    input [31 : 0] processor;
    input [9 : 0] sqflags; // JTAG sequence flags
    input [31 : 0] tdi_data;
    input [31 : 0] bitlength;
    reg [9 : 0] sqflags;
    reg [31 : 0] tdi_data;
    integer bitlength;

    reg [31 : 0] shift_out_contents;
    reg [10 : 0] state_count;

    begin
      shift_out_contents = { 32 { 1'b0 }};

      //shall we reset the tap controller?
      if (| (sqflags & `JF_RESET_TAP_CT))
        begin
          //Apply 5 tck clocks, with tms set high to ensure a TAP controller reset
          tms = 1'b1;
          Clock_TCK(`FOR_FIVE_CYCLES);
        end

      // Are we performing a write to IR or DR from the reset state?
      // If so, move from Test-Logic-Reset into Select-DR-Scan
      if (| (sqflags & (`JF_TLR_WRITE_IR | `JF_TLR_WRITE_DR)))
        begin
          tms = 1'b0;
          Clock_TCK(`FOR_ONE_CYCLE);
          tms = 1'b1;
          Clock_TCK(`FOR_ONE_CYCLE);
        end

      // Just entered Select_DR scan state or assume were left in it from last call
      // Are we performing a write to the instruction register?
      // If so we enter enter Select-IR-Scan state
      // Otherwise we are left in Select-DR-Scan state
      if (| (sqflags & (`JF_TLR_WRITE_IR | `JF_SDS_WRITE_IR)))
        begin
          tms = 1'b1;
          Clock_TCK(`FOR_ONE_CYCLE);
        end

      //Currently in Select-DR-Scan or Select-IR-Scan state
      //Determine which and shift in instruction or data
      //Need to know because in mp systems must put other processors into bypass
      //Test to see if it is an IR write
      if (| (sqflags & (`JF_TLR_WRITE_IR | `JF_SDS_WRITE_IR)))
        begin
          tms = 1'b0;
          Clock_TCK(`FOR_ONE_CYCLE);
          //Just entered Capture IR
          //Old IR is now in shift register
          for (i = num_processors - 1; i >= 0; i = i - 1)
            begin : bypass_p_ir
              //tdi feeds into processor number 0
              if (i == processor)
                //We are shifted to the processor of interest
                for (state_count = 0; state_count < bitlength; state_count = state_count + 1)
                  begin
                    //Note first clock moves us into shift DR state
                    Clock_TCK(`FOR_ONE_CYCLE); //apply the jtag clock
                    shift_out_contents[state_count] = ejtag_tdo; //capture the shifted out data
                    tdi = tdi_data[state_count]; //setup the new level of TDI
                  end
              else
                //This is a processor we aren't talking to
                //Shift in the bypass instruction (all 1's)
                for (state_count = 0; state_count < bitlength; state_count = state_count + 1)
                  begin
                    Clock_TCK(`FOR_ONE_CYCLE); //apply the jtag clock
                    tdi = 1'b1; //setup the new level of TDI
                  end
            end // block: bypass_p_ir
          //the final capture of the shifted data is when we exit the Shift_IR
          //and enter Update IR
          tms = 1'b1;
          Clock_TCK(`FOR_TWO_CYCLES);
        //We are now in Update IR
        //Talking to DR
        end
      else
        if (| (sqflags & (`JF_TLR_WRITE_DR | `JF_SDS_WRITE_DR)))
          begin
            tms = 1'b0;
            Clock_TCK(`FOR_ONE_CYCLE);
            //Just entered Capture IR
            //Old IR is now in shift register
            for (i = num_processors - 1; i >= 0; i = i - 1)
              begin : bypass_p_dr
                //tdi feeds into processor number 0
                if (i == processor)
                  //We are shifted to the processor of interest
                  for (state_count = 0; state_count < bitlength; state_count = state_count + 1)
                    begin
                      //Note first clock moves us into shift DR state
                      Clock_TCK(`FOR_ONE_CYCLE); //apply the jtag clock
                      shift_out_contents[state_count] = ejtag_tdo; //capture the shifted out data
                      tdi = tdi_data[state_count]; //setup the new level of TDI
                    end
                else
                  //Shift in or out the bypass register bit
                  //This could be optimzed to remove the extra shifts if new read or write
                  Clock_TCK(`FOR_ONE_CYCLE); //apply the jtag clock
              end // block: bypass_p_dr

            //the final capture of the shifted data is when we exit the Shift_DR
            //and enter update DR
            tms = 1'b1;
            Clock_TCK(`FOR_TWO_CYCLES);
          //We are now in Update DR
          end // if (|(sqflags & (`JF_TLR_WRITE_DR | `JF_SDS_WRITE_DR)))

      //determine whether we should return to the Run-Test/Idle or Select-DR-Scan State
      if ((| (sqflags & `JF_END_RUNTESTIDLE)) &
          (| (sqflags & (`JF_SDS_WRITE_DR | `JF_SDS_WRITE_IR | `JF_TLR_WRITE_DR | `JF_TLR_WRITE_IR))))
        begin
          tms = 1'b0;
          Clock_TCK(`FOR_ONE_CYCLE);
        end
      else
        if (| (sqflags & (`JF_SDS_WRITE_DR | `JF_SDS_WRITE_IR | `JF_TLR_WRITE_DR | `JF_TLR_WRITE_IR)))
          begin
            tms = 1'b1;
            Clock_TCK(`FOR_ONE_CYCLE);
          end

      //for stepping the TAP controller with TMS set high or low
      if (| (sqflags & `JF_STEP_TMS_HIGH))
        begin
          tms = 1'b1;
          Clock_TCK(`FOR_ONE_CYCLE);
        end
      else
        if (| (sqflags & `JF_STEP_TMS_LOW))
          begin
            tms = 1'b0;
            Clock_TCK(`FOR_ONE_CYCLE);
          end

      //convert the finally shifted out data to the integer tdo_data
      tdo_data = shift_out_contents;
    end
  endtask

  //-------------------------------------------------------------------------------------------
  //
  // The write_jtag_reg procedure writes to a specific JTAG data register. The access is performed by
  // using two calls to the Start_JTAG_Sequence procedure. The first procedure is used to write to the
  // instruction register to enable the target data register and the second writes to that data register.
  task write_jtag_reg;
    input [31 : 0] processor;
    input [31 : 0] wdata;
    input [31 : 0] waddr;
    reg [31 : 0] wdata;
    reg [31 : 0] waddr;

    begin
      // First of all write the instruction reg with the address of the register we want to write
      Start_JTAG_Sequence(processor, `JF_SDS_WRITE_IR, waddr, `JTAG_INSTRUCTION_REG_LEN);
      // Now write the data into the target data register
      Start_JTAG_Sequence(processor, `JF_SDS_WRITE_DR, wdata, 32);
    end
  endtask

  //-------------------------------------------------------------------------------------------
  //
  // The read_jtag_reg procedure reads from a selected JTAG data register. The access is performed by
  // using two calls to the Start_JTAG_Sequence procedure. The first procedure is used to write to
  // the instruction register to select the target data register and the second call reads from that
  // data register. The data read is placed in tdo_data.
  task read_jtag_reg;
    input [31 : 0] processor;
    input [31 : 0] raddr;
    reg [31 : 0] raddr;

    begin
      // First of all write the instruction with the address of the register we want to read
      Start_JTAG_Sequence(processor, `JF_SDS_WRITE_IR, raddr, `JTAG_INSTRUCTION_REG_LEN);
      // Now shift the data through the target data register and into tdo_data
      Start_JTAG_Sequence(processor, `JF_SDS_WRITE_DR, 32'h0000_0000, 32);
    end
  endtask

  //-------------------------------------------------------------------------------------------
  //
  // The run_jtag_comms procedure runs the transaction defined in the command register. A number
  // of Start_JTAG_Sequence procedures are used. Essentially the command register is written with
  // the value passed in as the argument. The run_test/idle is then entered to trigger the
  // transaction. To determine whether the transaction has completed the status register accessed.
  // The procedure does not return until the transaction has completed.
  task run_jtag_comms;
    input [31 : 0] processor;
    input [2 : 0] command;
    inout result;
    output powerdown;
    reg [2 : 0] command;

    begin
      // write the command register
      Start_JTAG_Sequence(processor, `JF_SDS_WRITE_IR, `JTAG_TRANSACTION_CMD_REG, `JTAG_INSTRUCTION_REG_LEN);
      Start_JTAG_Sequence(processor, `JF_SDS_WRITE_DR | `JF_END_RUNTESTIDLE, command, `JTAG_TRANSACTION_CMD_REG_LEN);
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0);
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0);
      Start_JTAG_Sequence(processor, `JF_SDS_WRITE_IR, `JTAG_STATUS_REG, `JTAG_INSTRUCTION_REG_LEN);
      status = 7'b 0000000; // clear the status
      // wait until the transaction has completed before exiting the procedure
      //
      powerdown = `false;
      while (status[`JTAG_STATUS_READY] == 1'b0)
        begin
          Start_JTAG_Sequence(processor, `JF_SDS_WRITE_DR, 4'h0, `JTAG_STATUS_REG_LEN); // Shift out the new status
          status = tdo_data;
          if (status[6] == 1'b 1)
              begin
              // $display("!POWERDOWN!\n");
              powerdown = `true;
              end
          // if protocol fails then signal a failure
          if (status[`JTAG_STATUS_FAILURE] == 1'b1)
            result = `false;
          else
            result = `true;
        end
    end
  endtask

  //-------------------------------------------------------------------------------------------
  // The Test_JTAG_Reg_Len procedure verifies the length of a single
  // register. If the register length is as specified in expected_len, the
  // result parameter is returned as `true.
  task Test_JTAG_Reg_Len;
    input [31 : 0] processor;
    input [3 : 0] reg_to_test;
    input [31 : 0] expected_len;
    output passed;

    integer processor;
    integer expected_len;
    reg passed;
    reg found_one_early;

    begin
      // Reset the TAP controller, set the IR to point to the register of
      // interest, and leave the TAP controller in the Select-DR-Scan state.
      Start_JTAG_Sequence(processor, `JF_RESET_TAP_CT, 1'b0, 0);
      Start_JTAG_Sequence(processor, `JF_TLR_WRITE_IR, reg_to_test, `JTAG_INSTRUCTION_REG_LEN);

      // Zero out the data shift register chain. The first two clocks with
      // TMS=0 put the TAP controller into the Shift-DR state.
      tdi = 1'b0;
      for (i = 0; i < (32 * num_processors) + 2; i = i + 1)
        Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0);

      // Now pump ones in. At this point, all other processors should be in
      // bypass mode, and the processor of interest should be addressing the
      // register to test, so after shifting in expected_len ones for this
      // processor and one for each of the others, the first one should have
      // appeared in tdo.
      found_one_early = 1'b0;
      tdi = 1'b1;
      for (i = 0; i < expected_len + num_processors - 2; i = i + 1)
        begin
          Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0);
          found_one_early = found_one_early | ejtag_tdo;
        end
      // Step it one last time; this should bring the one to tdo
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0);

      // Form the result, leave the TAP controller in Select-DR-Scan, and say
      // we're done.
      passed = (ejtag_tdo == 1'b1) && (found_one_early == 1'b0);
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0);
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0);
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0);
    end
  endtask

  //-------------------------------------------------------------------------------------------
  // The Test_JTAG_Instruction_Reg procedure verifies both the length and
  // correct functioning of the instruction register. It is done first. The
  // assumption is made that all the JTAG instruction registers in
  // a multi-processor design are the same length. The test leaves all the
  // instruction registers in the chain containing the BYPASS instruction.
  task Test_JTAG_Instruction_Reg;
    input [31 : 0] processor;
    input [31 : 0] expected_len;
    output passed;

    integer processor;
    integer expected_len;
    reg passed;

    integer p_index;

    begin
      tdo_capture = { 32 * `MAX_PROCESSORS { 1'b0 }}; // Eases debugging

      // Reset the TAP controller and move into the Capture-IR state
      Start_JTAG_Sequence(processor, `JF_RESET_TAP_CT, 1'b0, 0); // Reset
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0); // Run-Test/Idle
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Select-DR-Scan
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Select-IR-Scan
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0); // Capture-IR

      // Capture-IR should have loaded 4'b0001 into the instruction shift register.
      // We now move through Exit1-IR, Pause-IR, and Exit2-IR, none of which
      // should modify that pattern.
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Exit1-IR
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0); // Pause-IR
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Exit2-IR

      // Move into and remain in Shift-IR state. Capture-IR should have
      // loaded 4'b0001 into each of the instruction registers in the chain.
      tdi = 1'b1;
      for (i = 0; i < expected_len * num_processors; i = i + 1)
        begin
          Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0);
          tdo_capture[i] = ejtag_tdo;
        end

      // This evaluates the result of the previous loop. Note that the
      // least-significant bits in tdo_capture come from the last processor
      // in the chain.
      p_index = (num_processors - 1 - processor) * expected_len;
      passed = (tdo_capture[p_index] == 1'b1);
      for (i = p_index + 1; i < p_index + expected_len; i = i + 1)
        passed = passed && (tdo_capture[i] == 1'b0);

      // Now we should see all ones on tdo; this verifies that the length is
      // as expected.
      for (i = 0; i < 32 * num_processors; i = i + 1)
        begin
          Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0);
          passed = passed && (ejtag_tdo == 1'b1);
        end
    end
  endtask

  //-------------------------------------------------------------------------------------------
  // The Test_JTAG_Bypass_Reg procedure verifies the correct functioning of
  // the bypass register.
  task Test_JTAG_Bypass_Reg;
    input [31 : 0] processor;
    input [3 : 0] reg_to_test;
    output passed;

    integer processor;
    reg passed;

    begin
      tdo_capture = { 32 * `MAX_PROCESSORS { 1'b0 }}; // Eases debugging

      // Reset the TAP controller and move into the Capture-DR state
      Start_JTAG_Sequence(processor, `JF_RESET_TAP_CT, 1'b0, 0); // Reset
      // Write the instruction register, leaving the TAP controller in
      // Select-DR-Scan
      Start_JTAG_Sequence(processor, `JF_TLR_WRITE_IR, reg_to_test, `JTAG_INSTRUCTION_REG_LEN);
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0); // Capture-DR

      // Capture-DR should have loaded 1'b0 into the bypass shift register.
      // We now move through Exit1-DR, Pause-DR, and Exit2-DR, none of which
      // should modify that pattern.
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Exit1-DR
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0); // Pause-DR
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Exit2-DR

      // Move into and remain in Shift-DR state. Capture-DR should have
      // loaded 1'b0 into each of the bypass registers in the chain.
      tdi = 1'b1;
      for (i = 0; i < num_processors; i = i + 1)
        begin
          Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0);
          tdo_capture[i] = ejtag_tdo;
        end

      // This evaluates the result of the previous loop. We check both that
      // the zero put into the register during Capture-DR is there, and that
      // the one we shifted through has shown up.
      passed = tdo_capture[num_processors - 1 - processor] == 1'b0;
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0);
      passed = passed && ejtag_tdo == 1'b1;

      // Test to make sure that the one now in the shift register is held as
      // it should be in Exit1-DR, Pause-DR, and Exit2-DR
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Exit1-DR
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0); // Pause-DR
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Exit2-DR

      tdi = 1'b0;
      for (i = 0; i < num_processors; i = i + 1)
        begin
          Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0);
          tdo_capture[i] = ejtag_tdo;
        end

      // This evaluates the result of the previous loop. We check both that
      // the one put into the register during the previous section is there,
      // and that the zero we shifted through has shown up.
      passed =  passed && tdo_capture[num_processors - 1 - processor] == 1'b1;
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0);
      passed = passed && ejtag_tdo == 1'b0;

      // Finally, leave the TAP controller in Select-DR-Scan state.
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Exit1-DR
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Update-DR
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Select-DR-Scan
    end
  endtask

  //-------------------------------------------------------------------------------------------
  // The Test_JTAG_Reg procedure tests to see that a register is initialized
  // to the right value, can be read and written, and is only modified in the
  // states in which it's supposed to be modified.
  task Test_JTAG_Reg;
    input [31 : 0] processor;
    input [3 : 0] reg_to_test;
    input [31 : 0] expected_len;
    input [31 : 0] expected_init;
    output passed;

    integer processor;
    reg passed;

    integer processors_from_end;
    reg check_data;

    begin
      // Reset the TAP controller
      Start_JTAG_Sequence(processor, `JF_RESET_TAP_CT, 1'b0, 0); // Reset
      // Write the instruction register, leaving the TAP controller in Select-DR-Scan
      Start_JTAG_Sequence(processor, `JF_TLR_WRITE_IR, reg_to_test, `JTAG_INSTRUCTION_REG_LEN);
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0); // Capture-DR

      // Capture-DR should have loaded the initialization value into the shift register.
      // We now move through Exit1-DR, Pause-DR, and Exit2-DR, none of which
      // should modify that pattern.
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Exit1-DR
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0); // Pause-DR
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Exit2-DR

      // Now pick up the data. We get expected_len bits from the processor of
      // interest, and one from each of the other processors in bypass.
      // Note that the first clock puts the TAP controller into Shift-DR,
      // so the first bit actually clocked into the shift register is
      // a zero, on the second clock.
      tdo_capture = { 32 * `MAX_PROCESSORS { 1'b0 }}; // So we can compare below
      tdi = 1'b1;
      for (i = 0; i < expected_len + num_processors - 1; i = i + 1)
        begin
          Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0);
          tdo_capture[i] = ejtag_tdo;
          tdi = ~ tdi;
        end

      // Shift the captured data over to remove the bypass bits from
      // processors after the one of interest, then remove the upper bits to
      // get rid of the bypass bits from processors before the one of
      // interest.
      tdo_capture = tdo_capture >> num_processors - 1 - processor;
      for (i = expected_len; i < 32 * `MAX_PROCESSORS; i = i + 1)
        tdo_capture[i] = 1'b0;
      passed = tdo_capture == expected_init;

      // Move through the other states to make sure the data's held, then
      // into Update-DR to write it to the register, then finally read it
      // back to check it.
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Exit1-DR
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0); // Pause-DR
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Exit2-DR
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Update-DR
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Select-DR-Scan
 
      // This both writes the initialization data back into the register, and
      // reads the alternating ones and zeros back for the check.
      Start_JTAG_Sequence(processor, `JF_SDS_WRITE_DR, expected_init, expected_len);

      // Check it. This is a bit tricky: we shifted alternating ones and
      // zeros into the whole chain, so with even processors we should start
      // with a zero in the LSB.
      processors_from_end = num_processors - 1 - processor; 
      check_data = processors_from_end[0];
      for (i = 0; i < expected_len; i = i + 1)
        begin
          passed = passed && tdo_data[i] == check_data;
          check_data = ~ check_data;
        end
    end
  endtask

  //-------------------------------------------------------------------------------------------
  // The Test_JTAG_Reg_RO procedure tests to see that a register is initialized
  // to the right value, can be read, and is only modified in the
  // states in which it's supposed to be modified. It is like the above
  // routine, but designed to be used for read-only registers.
  task Test_JTAG_Reg_RO;
    input [31 : 0] processor;
    input [3 : 0] reg_to_test;
    input [31 : 0] expected_len;
    input [31 : 0] expected_init;
    output passed;

    integer processor;
    reg passed;

    begin
      // Reset the TAP controller
      Start_JTAG_Sequence(processor, `JF_RESET_TAP_CT, 1'b0, 0); // Test-Logic-Reset
      // Write the instruction register, leaving the TAP controller in Select-DR-Scan
      Start_JTAG_Sequence(processor, `JF_TLR_WRITE_IR, reg_to_test, `JTAG_INSTRUCTION_REG_LEN);
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0); // Capture-DR

      // Capture-DR should have loaded the initialization value into the shift register.
      // We now move through Exit1-DR, Pause-DR, and Exit2-DR, none of which
      // should modify that pattern.
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Exit1-DR
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0); // Pause-DR
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Exit2-DR

      // Now pick up the data. We get expected_len bits from the processor of
      // interest, and one from each of the other processors in bypass.
      tdo_capture = { 32 * `MAX_PROCESSORS { 1'b0 }}; // So we can compare below
      tdi = 1'b0;
      for (i = 0; i < expected_len + num_processors - 1; i = i + 1)
        begin
          Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0);
          tdo_capture[i] = ejtag_tdo;
        end

      // Shift the captured data over to remove the bypass bits from
      // processors after the one of interest, then remove the upper bits to
      // get rid of the bypass bits from processors before the one of
      // interest.
      tdo_capture = tdo_capture >> num_processors - 1 - processor;
      for (i = expected_len; i < 32 * `MAX_PROCESSORS; i = i + 1)
        tdo_capture[i] = 1'b0;

      passed = tdo_capture == expected_init;

      // Move back to leave the TAP controller in Select-DR-Scan
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Exit1-DR
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Update-DR
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Select-DR-Scan
    end
  endtask

  //-------------------------------------------------------------------------------------------
  // The Test_JTAG_Reset procedure verifies that upon passing through
  // Test-Logic-Reset, IDCODE is set into the instruction register,
  task Test_JTAG_Reset;
    input [31 : 0] processor;
    output passed;

    integer processor;
    reg passed;

    integer theProcessor;
    reg [31 : 0] id_capture;

    begin
      // Reset the TAP controller and move into the Capture-DR state
      Start_JTAG_Sequence(processor, `JF_RESET_TAP_CT, 1'b0, 0); // Reset
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0); // Run-Test/Idle
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Select-DR-Scan
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0); // Capture-DR

      // Check each unit in the chain, until we get to the one of interest.
      // If the initial Shift-DR for a unit reveals a zero on TDO, it's
      // a one-bit bypass register. If the first bit is a one, it's a 32-bit
      // IDCODE register, which we should have.
      for (theProcessor = num_processors - 1; theProcessor >= processor; theProcessor = theProcessor - 1)
        begin
          id_capture = { 32 { 1'b0 }}; // Clear it out to avoid confusion
          Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0); // Shift in the first data bit
          id_capture[0] = ejtag_tdo; // Capture it
          if (id_capture[0] == 1'b1)
            for (i = 1; i < 32; i = i + 1)
              begin
                Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0); // Shift in the next data bit
                id_capture[i] = ejtag_tdo;
              end
        end

      // At this point, id_capture should contain our IDCODE.
      // This code can't be right: it's dependent on arc-specific properties.
      // Perhaps we are checking only the first arc in the chain.
      // So, we define the values for such.
      `define ARC_TYPE `ARC_TYPE_ARC600
      `define ARCNUM 8'h 01
      passed = id_capture == `JTAG_IDCODE_REG_INIT;

      // Clean up by leaving the TAP controller in Select-DR-Scan
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Exit1-DR
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Update-DR
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Select-DR-Scan
    end
  endtask

  //-------------------------------------------------------------------------------------------
  // The Discover_JTAG_Chain procedure is run on startup to find out how
  // many TAP controllers are in the JTAG chain.
  task Discover_JTAG_Chain;
    output num_TAP_controllers;

    integer num_TAP_controllers;

    reg [31 : 0] id_capture;
    reg [31 : 0] tdi_buffer;
    integer tdi_ptr;

    begin
      // Initialize local variables
      id_capture = { 32 { 1'b0 }};
      tdi_buffer = `DISCOVER_IDCODE;
      tdi_ptr = 0;

      // Reset the TAP controller and move into the Capture-DR state
      Start_JTAG_Sequence(0, `JF_RESET_TAP_CT, 1'b0, 0); // Reset
      Start_JTAG_Sequence(0, `JF_STEP_TMS_LOW, 1'b0, 0); // Run-Test/Idle
      Start_JTAG_Sequence(0, `JF_STEP_TMS_HIGH, 1'b0, 0); // Select-DR-Scan
      Start_JTAG_Sequence(0, `JF_STEP_TMS_LOW, 1'b0, 0); // Capture-DR

      // Check each unit in the chain, until we get to the one of interest.
      // If the initial Shift-DR for a unit reveals a zero on TDO, it's
      // a one-bit bypass register. If the first bit is a one, it's a 32-bit
      // IDCODE register, which we should have.
      for (num_TAP_controllers = -1; id_capture != `DISCOVER_IDCODE; num_TAP_controllers = num_TAP_controllers + 1)
        begin
          id_capture = { 32 { 1'b0 }}; // Clear it out to avoid confusion
          Start_JTAG_Sequence(0, `JF_STEP_TMS_LOW, 1'b0, 0); // Shift out the first data bit
          id_capture[0] = ejtag_tdo; // Capture it
          tdi = tdi_ptr < 32 ? tdi_buffer[tdi_ptr] : 1'b0; // Shift in the discovery code
          tdi_ptr = tdi_ptr + 1;
          if (id_capture[0] == 1'b1)
            for (i = 1; i < 32; i = i + 1)
              begin
                Start_JTAG_Sequence(0, `JF_STEP_TMS_LOW, 1'b0, 0); // Shift out the next data bit
                id_capture[i] = ejtag_tdo;
                tdi = tdi_ptr < 32 ? tdi_buffer[tdi_ptr] : 1'b0;
                tdi_ptr = tdi_ptr + 1;
              end
        end

      // Clean up by leaving the TAP controller in Select-DR-Scan
      Start_JTAG_Sequence(0, `JF_STEP_TMS_HIGH, 1'b0, 0); // Exit1-DR
      Start_JTAG_Sequence(0, `JF_STEP_TMS_HIGH, 1'b0, 0); // Update-DR
      Start_JTAG_Sequence(0, `JF_STEP_TMS_HIGH, 1'b0, 0); // Select-DR-Scan
    end
  endtask

  //-------------------------------------------------------------------------------------------
  // The Test_JTAG_Transaction procedure runs a memory read transaction,
  // staying in Run-Test/Idle for several clocks and verifying that the
  // address increments exactly once.
  task Test_JTAG_Transaction;
    input [31 : 0] processor;
    output passed;

    integer processor;
    reg passed;

    begin
      // Start by moving the TAP controller into the Select-DR-Scan
      // state
      Start_JTAG_Sequence(processor, `JF_RESET_TAP_CT, 1'b0, 0); // Test-Logic-Reset
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0); // Run-Test/Idle
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Select-DR-Scan

      write_jtag_reg(processor, 0, `JTAG_ADDRESS_REG);
      Start_JTAG_Sequence(processor, `JF_SDS_WRITE_IR, `JTAG_TRANSACTION_CMD_REG, `JTAG_INSTRUCTION_REG_LEN);
      Start_JTAG_Sequence(processor, `JF_SDS_WRITE_DR | `JF_END_RUNTESTIDLE, `CMD_READ_MEM, `JTAG_TRANSACTION_CMD_REG_LEN);
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0); // Remain in Run-Test/Idle
      Clock_TCK(100); // Give it time to happen, and to repeat the command if it's going to
      Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0); // Select-DR-Scan, for read_jtag_reg
      read_jtag_reg(processor, `JTAG_ADDRESS_REG); // Now read it back to check
      passed = tdo_data == 4; // Should have incremented only once
    end
  endtask

  //-------------------------------------------------------------------------------------------
  // The Test_JTAG_High_Z_Timing procedure makes sure that tdo goes into and out of
  // tristate at the appropriate times with respect to both the TAP
  // controller state and the clock. By definition, this can only be tested
  // for the last TAP controller in the chain.
  task Test_JTAG_High_Z_Timing;
    output passed;

    reg passed;

    begin
      Start_JTAG_Sequence(num_processors - 1, `JF_RESET_TAP_CT, 1'b0, 0); // Test-Logic-Reset
      passed = ejtag_tdo === 1'bz;
      Start_JTAG_Sequence(num_processors - 1, `JF_STEP_TMS_LOW, 1'b0, 0); // Run-Test/Idle
      passed = passed && ejtag_tdo === 1'bz;
      Start_JTAG_Sequence(num_processors - 1, `JF_STEP_TMS_HIGH, 1'b0, 0); // Select-DR-Scan
      passed = passed && ejtag_tdo === 1'bz;
      Start_JTAG_Sequence(num_processors - 1, `JF_STEP_TMS_HIGH, 1'b0, 0); // Select-IR-Scan
      passed = passed && ejtag_tdo === 1'bz;
      Start_JTAG_Sequence(num_processors - 1, `JF_STEP_TMS_LOW, 1'b0, 0); // Capture-IR
      passed = passed && ejtag_tdo === 1'bz;
      tdi = 1'b1; // Select the bypass register; it's safe
      tms = 1'b0; // Move into Shift-IR, where TDO should come out of tristate
      # `TCK_HALF_PERIOD_TDO
        ;
      tck <= 1'b1;
      # `TCK_HALF_PERIOD
        passed = passed && ejtag_tdo === 1'bz; // Not yet
      tck <= 1'b0;
      # `DELAY_ON_TDO
        passed = passed && ejtag_tdo !== 1'bz; // Now out of tristate
      for (i = 0; i < `JTAG_INSTRUCTION_REG_LEN * num_processors - 1; i = i + 1)
        begin
          Start_JTAG_Sequence(num_processors - 1, `JF_STEP_TMS_LOW, 1'b0, 0); // Stay in Shift-IR
          passed = passed && ejtag_tdo !== 1'bz;
        end
      tms = 1'b1; // Move into Exit1-IR, where TDO should go into tristate
      # `TCK_HALF_PERIOD_TDO
        ;
      tck <= 1'b1;
      # `TCK_HALF_PERIOD
        passed = passed && ejtag_tdo !== 1'bz; // Not yet
      tck <= 1'b0;
      # `DELAY_ON_TDO
        passed = passed && ejtag_tdo === 1'bz; // Now into tristate
      Start_JTAG_Sequence(num_processors - 1, `JF_STEP_TMS_LOW, 1'b0, 0); // Pause-IR
      passed = passed && ejtag_tdo === 1'bz;
      Start_JTAG_Sequence(num_processors - 1, `JF_STEP_TMS_HIGH, 1'b0, 0); // Exit2-IR
      passed = passed && ejtag_tdo === 1'bz;
      Start_JTAG_Sequence(num_processors - 1, `JF_STEP_TMS_HIGH, 1'b0, 0); // Update-IR
      passed = passed && ejtag_tdo === 1'bz;
      Start_JTAG_Sequence(num_processors - 1, `JF_STEP_TMS_HIGH, 1'b0, 0); // Select-DR-Scan
      passed = passed && ejtag_tdo === 1'bz;
      Start_JTAG_Sequence(num_processors - 1, `JF_STEP_TMS_LOW, 1'b0, 0); // Capture-DR
      passed = passed && ejtag_tdo === 1'bz;
      tdi = 1'b0;
      tms = 1'b0; // Move into Shift-DR, where TDO should come out of tristate
      # `TCK_HALF_PERIOD_TDO
        ;
      tck <= 1'b1;
      # `TCK_HALF_PERIOD
        passed = passed && ejtag_tdo === 1'bz; // Not yet
      tck <= 1'b0;
      # `DELAY_ON_TDO
        passed = passed && ejtag_tdo !== 1'bz; // Now out of tristate
      tms = 1'b1; // Move into Exit1-DR, where TDO should go into tristate
      # `TCK_HALF_PERIOD_TDO
        ;
      tck <= 1'b1;
      # `TCK_HALF_PERIOD
        passed = passed && ejtag_tdo !== 1'bz; // Not yet
      tck <= 1'b0;
      # `DELAY_ON_TDO
        passed = passed && ejtag_tdo === 1'bz; // Now into tristate
      Start_JTAG_Sequence(num_processors - 1, `JF_STEP_TMS_LOW, 1'b0, 0); // Pause-DR
      passed = passed && ejtag_tdo === 1'bz;
      Start_JTAG_Sequence(num_processors - 1, `JF_STEP_TMS_HIGH, 1'b0, 0); // Exit2-DR
      passed = passed && ejtag_tdo === 1'bz;
      Start_JTAG_Sequence(num_processors - 1, `JF_STEP_TMS_HIGH, 1'b0, 0); // Update-DR
      passed = passed && ejtag_tdo === 1'bz;
      Start_JTAG_Sequence(num_processors - 1, `JF_STEP_TMS_HIGH, 1'b0, 0); // Select-DR-Scan
    end
  endtask

  //-------------------------------------------------------------------------------------------
  initial
    begin
      generated_ra_ck = 1'b0;
      processor = 0;
      jtag_bist_passed = 1'b0;
   // Interrupts are active low.
   `define INT_SET 1'b 0
   `define INT_CLR 1'b 1
xxirq_n_4 = `INT_CLR;
xxirq_n_5 = `INT_CLR;
xxirq_n_6 = `INT_CLR;
xxirq_n_7 = `INT_CLR;
xxirq_n_8 = `INT_CLR;
xxirq_n_9 = `INT_CLR;
xxirq_n_10 = `INT_CLR;
xxirq_n_11 = `INT_CLR;
xxirq_n_12 = `INT_CLR;
xxirq_n_13 = `INT_CLR;
xxirq_n_14 = `INT_CLR;
xxirq_n_15 = `INT_CLR;
xxirq_n_16 = `INT_CLR;
xxirq_n_17 = `INT_CLR;
xxirq_n_18 = `INT_CLR;
xxirq_n_19 = `INT_CLR;
         
    end

  always
    /* @(insert appropriate event expressions) */
    begin
      // This should be safe to run at same speed as system clock.
      # (`TCK_CLOCK_PERIOD)
        generated_ra_ck = ~ generated_ra_ck;
      ira_ck = generated_ra_ck;
    end
  assign ra_ck = generated_ra_ck;

  // ---------------------------------------------------------------------
  //  RASCAL / JTAG interface state machine ------------------------------
  //
  //
  //
  always
    begin : interface_fsm_sync
      ra_rd_data <= {(31 + 1){ 1'b0 }};
      ra_ack <= 1'b0;
      ra_fail <= 2'b00;
      rascal_state = `idle;
      tms <= 1'b1;
      tdi <= 1'b1;
      tck <= 1'b1;

      // @ ( posedge rst_a );
      wait (rst_a == 1'b0 && ejtag_trst_n == 1'b0)
        ;
      wait (rst_a == 1'b1 && ejtag_trst_n == 1'b1)
        ;
      Discover_JTAG_Chain(num_processors); 

      //  Evaluate Rascal signals on ra_ck edges.
      forever
        begin
          @(posedge ira_ck)
            ;

          ra_ack <= 1'b0; // Default assignment, to be overridden

          `define level_check(name,num) \
              name = (write_data & (1<<num)) != 0 \
                              ? `INT_SET : `INT_CLR     
                               
          `define pulse_check(sig,clr,num) \
               begin if ((write_data & (1<<num)) != 0) \
                 begin sig = `INT_SET; clr = 1; end end
                 
          `define pulse_clear(sig,clr) begin sig = `INT_CLR; clr = 0; end
          
          `define set_level_check(name,num) \
             begin if ((write_data & (1<<num)) != 0) \
                             name = `INT_SET; end
                             
          `define clear_check(name,num) \
	       begin if ((write_data & (1<<num)) != 0) \
		     name = `INT_CLR; end
                             
          // ---------------------------------------------------------------------
          //  Idle state
          //
          //   Wait for the RASCAL read or write request lines to go high then
          //   start request to jtag port.
          //   Also grab the burst size for use in burst transfers.
          //
          //  The requested address for auxillary register access is offset by
          //  64 (values 0-63 are core registers), therefore the address must be
          //  corrected for auxiliary access.
          //
          //  'ra_select' = "01" for core register access,
          //                "10" for auxiliary register access,
          //                "00" for memory access,
          //            and "11" for madi accesses.

          case (rascal_state)
            `idle :
              begin
                result = `true;
                if (ra_read === 1'b1 | ra_write === 1'b1)
                  begin
                    rascal_state = `perform_request;
                    burst_size = ra_burst;
                    burst_count = 1'b1;

                    if (ra_read === 1'b1)
                      ra_rq_type = `request_type_read;

                    else
                      begin
                        ra_rq_type = `request_type_write;
                        write_data = ra_wr_data;
                      end

                    request_addr = ra_addr;

                    case (ra_select)
                      2'b00 :
                        ra_access_type = `access_type_memory;
                      2'b01 :
                        ra_access_type = `access_type_core;
                      2'b10 :
                        ra_access_type = `access_type_aux;
                      2'b11 :
                        ra_access_type = `access_type_madi;
                      default :
                        ra_access_type = 2'bxx;
                    endcase
                  end

              end

            // ---------------------------------------------------------------------
            //  Performs the request accross the JTAG interface.
            //
            `perform_request :
              begin
                case (ra_access_type)
                  `access_type_core :
                    if (ra_rq_type === `request_type_write)
                      command = `CMD_WRITE_CORE;
                    else
                      command = `CMD_READ_CORE;
                  `access_type_aux :
                    if (ra_rq_type === `request_type_write)
                      command = `CMD_WRITE_AUX;
                    else
                      command = `CMD_READ_AUX;
                  `access_type_memory :
                    if (ra_rq_type === `request_type_write)
                      command = `CMD_WRITE_MEM;
                    else
                      command = `CMD_READ_MEM;
                  `access_type_madi :
                  
                    `define TESTBENCH_VERSION_REG         32'h100
                    `define TESTBENCH_ASSIGN_ALL_INTERRUPTS         32'h101
                    // level interrupts: set/reset all level interrupts at once
                    // to SET or CLR (1=set, 0=clr).
                      // You need to keep track of all interrupt states.
                    `define TESTBENCH_PULSE_INTERRUPTS         32'h102
                        // pulse interrupts: set indicate interrupts to pulse.
                    `define TESTBENCH_SET_INTERRUPTS         32'h103
                    // set interrupts indicated by 1 bits
                      // You need to know only about your own interrupt.
                    `define TESTBENCH_CLEAR_INTERRUPTS         32'h104
                                      
                    if (ra_rq_type === `request_type_write)
                      case (request_addr)
                      
                       `TESTBENCH_VERSION_REG: 
                       begin
                           // Do nothing.  Writes to version reg are ignored.
                             //interface_fsm_sync_command = 9;        // 9 = done.
                       end
                  
                       `TESTBENCH_ASSIGN_ALL_INTERRUPTS: 
                       begin
                          // Set or reset all interrupts.
`level_check(xxirq_n_4,4);
`level_check(xxirq_n_5,5);
`level_check(xxirq_n_6,6);
`level_check(xxirq_n_7,7);
`level_check(xxirq_n_8,8);
`level_check(xxirq_n_9,9);
`level_check(xxirq_n_10,10);
`level_check(xxirq_n_11,11);
`level_check(xxirq_n_12,12);
`level_check(xxirq_n_13,13);
`level_check(xxirq_n_14,14);
`level_check(xxirq_n_15,15);
`level_check(xxirq_n_16,16);
`level_check(xxirq_n_17,17);
`level_check(xxirq_n_18,18);
`level_check(xxirq_n_19,19);
                          //   interface_fsm_sync_command = 9;        // 9 = done.
                       end
                       
                       `TESTBENCH_PULSE_INTERRUPTS: 
                       begin
                          // Generate a pulse on all interrupts indicated by 1.
`pulse_check(xxirq_n_4,clear_xxirq_n_4,4)
`pulse_check(xxirq_n_5,clear_xxirq_n_5,5)
`pulse_check(xxirq_n_6,clear_xxirq_n_6,6)
`pulse_check(xxirq_n_7,clear_xxirq_n_7,7)
`pulse_check(xxirq_n_8,clear_xxirq_n_8,8)
`pulse_check(xxirq_n_9,clear_xxirq_n_9,9)
`pulse_check(xxirq_n_10,clear_xxirq_n_10,10)
`pulse_check(xxirq_n_11,clear_xxirq_n_11,11)
`pulse_check(xxirq_n_12,clear_xxirq_n_12,12)
`pulse_check(xxirq_n_13,clear_xxirq_n_13,13)
`pulse_check(xxirq_n_14,clear_xxirq_n_14,14)
`pulse_check(xxirq_n_15,clear_xxirq_n_15,15)
`pulse_check(xxirq_n_16,clear_xxirq_n_16,16)
`pulse_check(xxirq_n_17,clear_xxirq_n_17,17)
`pulse_check(xxirq_n_18,clear_xxirq_n_18,18)
`pulse_check(xxirq_n_19,clear_xxirq_n_19,19)
                                 
                        //     interface_fsm_sync_command = 9;        // 9 = done.
                       end
                       
                       `TESTBENCH_SET_INTERRUPTS: 
                       begin
                         // Set interrupts indicated by 1.
`set_level_check(xxirq_n_4,4)
`set_level_check(xxirq_n_5,5)
`set_level_check(xxirq_n_6,6)
`set_level_check(xxirq_n_7,7)
`set_level_check(xxirq_n_8,8)
`set_level_check(xxirq_n_9,9)
`set_level_check(xxirq_n_10,10)
`set_level_check(xxirq_n_11,11)
`set_level_check(xxirq_n_12,12)
`set_level_check(xxirq_n_13,13)
`set_level_check(xxirq_n_14,14)
`set_level_check(xxirq_n_15,15)
`set_level_check(xxirq_n_16,16)
`set_level_check(xxirq_n_17,17)
`set_level_check(xxirq_n_18,18)
`set_level_check(xxirq_n_19,19)
                             
                          // interface_fsm_sync_command = 9;        // 9 = done.
                       end
                       
                       `TESTBENCH_CLEAR_INTERRUPTS: 
                       begin
                         // Clear interrupts indicated by 1.
`clear_check(xxirq_n_4,4)
`clear_check(xxirq_n_5,5)
`clear_check(xxirq_n_6,6)
`clear_check(xxirq_n_7,7)
`clear_check(xxirq_n_8,8)
`clear_check(xxirq_n_9,9)
`clear_check(xxirq_n_10,10)
`clear_check(xxirq_n_11,11)
`clear_check(xxirq_n_12,12)
`clear_check(xxirq_n_13,13)
`clear_check(xxirq_n_14,14)
`clear_check(xxirq_n_15,15)
`clear_check(xxirq_n_16,16)
`clear_check(xxirq_n_17,17)
`clear_check(xxirq_n_18,18)
`clear_check(xxirq_n_19,19)
                          // interface_fsm_sync_command = 9;        // 9 = done.
                       end  
                                             
                        `MADI_PROCESSOR_REG_ADDR :
                          processor = write_data;
                        `MADI_JTAG_BIST_REG :
                          begin
                            // Test the instruction register for length and
                            // function
                            Test_JTAG_Instruction_Reg(processor, `JTAG_INSTRUCTION_REG_LEN, jtag_ireg_ok);

                            // Test the data registers for proper length
                            Test_JTAG_Reg_Len(processor, `JTAG_BYPASS_REG, `JTAG_BYPASS_REG_LEN, jtag_reg_len_ok[0]);
                            Test_JTAG_Reg_Len(processor, `JTAG_DATA_REG, `JTAG_DATA_REG_LEN, jtag_reg_len_ok[1]);
                            Test_JTAG_Reg_Len(processor, `JTAG_ADDRESS_REG, `JTAG_ADDRESS_REG_LEN, jtag_reg_len_ok[2]);
                            Test_JTAG_Reg_Len(processor, `JTAG_TRANSACTION_CMD_REG, `JTAG_TRANSACTION_CMD_REG_LEN,
                                              jtag_reg_len_ok[3]);
                            Test_JTAG_Reg_Len(processor, `JTAG_STATUS_REG, `JTAG_STATUS_REG_LEN, jtag_reg_len_ok[4]);

                            // Test register functionality
                            Test_JTAG_Bypass_Reg(processor, `JTAG_BYPASS_REG, jtag_bypass_ok);
                            Test_JTAG_Reg(processor, `JTAG_ADDRESS_REG, `JTAG_ADDRESS_REG_LEN,
                                          `JTAG_ADDRESS_REG_INIT, jtag_reg_ok[0]);
                            Test_JTAG_Reg(processor, `JTAG_TRANSACTION_CMD_REG, `JTAG_TRANSACTION_CMD_REG_LEN,
                                          `JTAG_TRANSACTION_CMD_REG_INIT, jtag_reg_ok[1]);
                            Test_JTAG_Reg_RO(processor, `JTAG_STATUS_REG, `JTAG_STATUS_REG_LEN,
                                          `JTAG_STATUS_REG_INIT, jtag_reg_ok[2]);
                            Test_JTAG_Reg_RO(processor, `JTAG_IDCODE_REG, `JTAG_IDCODE_REG_LEN,
                                          `JTAG_IDCODE_REG_INIT, jtag_reg_ok[3]);

                            // Make sure all unused instructions select the
                            // BYPASS register
                            Test_JTAG_Bypass_Reg(processor, `JTAG_UNUSED_REG0, jtag_unused_ok[0]);
                            Test_JTAG_Bypass_Reg(processor, `JTAG_UNUSED_REG1, jtag_unused_ok[1]);
                            Test_JTAG_Bypass_Reg(processor, `JTAG_UNUSED_REG2, jtag_unused_ok[2]);
                            Test_JTAG_Bypass_Reg(processor, `JTAG_UNUSED_REG3, jtag_unused_ok[3]);
                            Test_JTAG_Bypass_Reg(processor, `JTAG_UNUSED_REG4, jtag_unused_ok[4]);
                            Test_JTAG_Bypass_Reg(processor, `JTAG_UNUSED_REG5, jtag_unused_ok[5]);
                            Test_JTAG_Bypass_Reg(processor, `JTAG_UNUSED_REG6, jtag_unused_ok[6]);
                            Test_JTAG_Bypass_Reg(processor, `JTAG_UNUSED_REG7, jtag_unused_ok[7]);

                            // Test that upon reset, the IDCODE register is
                            // selected.
                            Test_JTAG_Reset(processor, jtag_reset_ok);

                            // Test the proper operation of the command
                            // mechanism, specifically that the address
                            // increment works and that remaining in
                            // Run-Test/Idle will only execute a command
                            // once.
                            Test_JTAG_Transaction(processor, jtag_transaction_ok);

                            // Test the timing of high-Z on TDO (by
                            // definition only testable on the last
                            // processor in the chain)
                            Test_JTAG_High_Z_Timing(jtag_high_z_ok);

                            jtag_bist_passed =
                              jtag_high_z_ok &&
                              jtag_transaction_ok &&
                              jtag_reset_ok &&
                              (& jtag_unused_ok) &&
                              (& jtag_reg_ok) &&
                              jtag_bypass_ok &&
                              (& jtag_reg_len_ok) &&
                              jtag_ireg_ok;
                          end
                        default :
                          ;
                      endcase
                    else
                      case (request_addr)
                        `MADI_PROCESSOR_REG_ADDR :
                          ra_rd_data = processor;
                        `MADI_JTAG_BIST_REG :
                          ra_rd_data = {{ 9 { 1'b0 }}, jtag_high_z_ok, jtag_transaction_ok,
                                        jtag_reset_ok, jtag_unused_ok, jtag_reg_ok, jtag_bypass_ok,
                                        jtag_reg_len_ok, jtag_ireg_ok, jtag_bist_passed };
                        default :
                          ;
                      endcase
                  default :
                    command = 4'bxxxx;
                endcase

                if (ra_access_type == `access_type_madi)
                  // MADI-space accesses are now local
                  begin
                    rascal_state = `acknowledge_request;
                    ra_ack <= 1'b1;
                  end
                else
                  begin
                    // Perform the read from the register
                    // Start by moving the TAP controller into the Select-DR-Scan
                    // state
                    Start_JTAG_Sequence(processor, `JF_RESET_TAP_CT, 1'b0, 0);
                    Start_JTAG_Sequence(processor, `JF_STEP_TMS_LOW, 1'b0, 0);
                    Start_JTAG_Sequence(processor, `JF_STEP_TMS_HIGH, 1'b0, 0);

                    write_jtag_reg(processor, request_addr, `JTAG_ADDRESS_REG);

                    if (ra_rq_type === `request_type_write)
                      begin
                        write_data = ra_wr_data;
                        write_jtag_reg(processor, write_data, `JTAG_DATA_REG);
                      end

                    powerdown = `false;
                    ra_fail <= 2'b 00;
                    run_jtag_comms(processor, command, result, powerdown);

                  if (powerdown === `true) begin
                      $display("Set ra_fail to 2 due to powerdown");
                      ra_fail <= 2'b 10;
                      end
                    else if (result === `false)
                      begin
                      if (ra_access_type === `access_type_aux &
                            request_addr === `AUX_IVIC |
                            ra_access_type === `access_type_core)
                          begin
                            if (! (`false))
                              begin
                                $write("note: ");
                                $display("WARNING : Debugger access failed to %s register 0x%4x=%4d",
				    ra_access_type === `access_type_aux 
				    ? "aux" : "core",
				    request_addr,
				    request_addr);

                                $display("Time: ", $time);
                              end
                          end

                      else if (ra_access_type === `access_type_memory )
                          begin
                            if (! (`false))
                              begin
                                $write("note: ");
                                $display("WARNING : Debugger tried to access unmapped peripheral space");
                                $display("Time: ", $time);
                              end
                          end

                        else
                          begin
                            if (! (`false))
                              begin
                                $write("failure: ");
                                $display("JTAG COMMUNICATIONS FAILURE");
                                $display("Time: ", $time);
                                $stop;
                              end
                          end

                      end

                    if (ra_rq_type === `request_type_read)
                      read_jtag_reg(processor, `JTAG_DATA_REG);

                    rascal_state = `acknowledge_request;
                    ra_ack <= 1'b1;
                    ra_rd_data <= tdo_data;
                  end
              end

            //  Sets the ra_ack signal for 1 cycle to acknowledge the trasfer of
            //  1 lword of data.  Then either continues burst or goes to idle state
            //  if the transfer is complete. The burst address is
            //  incremented by four because bursts are only used for
            //  memory transfers.
            `acknowledge_request :
              begin
                if (burst_count === burst_size)
                  // End of the burst transfer
                  rascal_state = `acknowledge_clear;
                else
                  begin
                    burst_count = burst_count + 1;
                    request_addr = request_addr + 4;
                    rascal_state = `perform_request;
                  end
              end

            `acknowledge_clear :
              begin
                ra_ack <= 1'b0;
                rascal_state = `idle;        
`pulse_clear(xxirq_n_4,clear_xxirq_n_4)
`pulse_clear(xxirq_n_5,clear_xxirq_n_5)
`pulse_clear(xxirq_n_6,clear_xxirq_n_6)
`pulse_clear(xxirq_n_7,clear_xxirq_n_7)
`pulse_clear(xxirq_n_8,clear_xxirq_n_8)
`pulse_clear(xxirq_n_9,clear_xxirq_n_9)
`pulse_clear(xxirq_n_10,clear_xxirq_n_10)
`pulse_clear(xxirq_n_11,clear_xxirq_n_11)
`pulse_clear(xxirq_n_12,clear_xxirq_n_12)
`pulse_clear(xxirq_n_13,clear_xxirq_n_13)
`pulse_clear(xxirq_n_14,clear_xxirq_n_14)
`pulse_clear(xxirq_n_15,clear_xxirq_n_15)
`pulse_clear(xxirq_n_16,clear_xxirq_n_16)
`pulse_clear(xxirq_n_17,clear_xxirq_n_17)
`pulse_clear(xxirq_n_18,clear_xxirq_n_18)
`pulse_clear(xxirq_n_19,clear_xxirq_n_19)
            end

            //
            //  Default state, just in case.
            //
            default :
              rascal_state = `idle;
          endcase
        end
    end

  // ---------------------------------------------------------------------
  //  Output drives
  assign ejtag_tck = tck;
  assign ejtag_tms = tms;
  assign ejtag_tdi = tdi;

endmodule // module rascal2jtag
