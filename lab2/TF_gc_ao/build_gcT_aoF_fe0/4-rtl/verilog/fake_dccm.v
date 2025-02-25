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
// Fake LD/ST RAM model
//
// Simulation model of fake memory block used in place of a
// vendor memory model. This model has 4 byte enables. If byte
// enables do not exist in your selected technology, replace this 
// fake RAM model with four separate RAM's.
//
module fake_dccm (clk,
                  address,
                  wr_data,
                  we,
                  ck_en,
                  rd_data
                  );

`include "arcutil_pkg_defines.v"
`include "extutil.v"
`include "xdefs.v"
`include "clock_defs.v"

input                 clk;
input  [LDST_A_MSB:0] address;
input  [31:0]         wr_data;
input  [3:0]          we;
input  [3:0]          ck_en;
output [31:0]         rd_data;
//synopsys translate_off

reg  [LDST_A_MSB:0]   i_address_r;
reg  [31:0]           i_wr_data_r;
reg  [3:0]            i_we_r;
reg  [3:0]            i_ck_en_r;
   
reg    [31:0]         i_rd_data;
reg    [31:0]         i_mem_out;
reg    [31:0]         i_rd_data_r;
wire   [31:0]         rd_data;
reg    [3:0]          i_we_n;
reg                   i_we_ck;
wire                  tied_high;
wire                  i_enable_ram_n;
wire                  i_out_enable_n;
parameter options = 6;  // Configure SRAM's hex-reader in little-endian mode.


// Constant used to keep the second RAM enable always active
//
assign tied_high = 1'b 1;

// The write clock and the write enables are set to inactive at the 
// start of the simulation.
//
initial
  begin
  i_we_n  <= 4'b 1;
  i_we_ck <= 1'b 0;
  end

// Write enables (one per byte).
//
// The write enable is active if the clock enable for the same byte is active.
//
`ifdef TTVTOC

// No pulse for VTOC configuration. Keep the signal active.
always @(posedge clk)
  begin 
   i_we_ck = 1'b 1;
  end 

always @(i_we_ck or i_we_r or i_ck_en_r)

`else

// Generate a write pulse that is active during the second quarter of 
// the clock period. This is needed because the RAM C-model instantiated
// in this file is an asynchronous RAM.
//
always @(posedge clk)
  begin 
   # (clock_period/4) i_we_ck = 1'b 1;
   # (clock_period/4) i_we_ck = 1'b 0;
  end 
 
// Each write enable is AND:ed with the write pulse clock (i_we_ck)
// in order to create a write pulse that is only active in the
// second quarter of the clock period.
//

always @(i_we_ck or i_we_r or i_ck_en_r)

`endif

   begin
   if (i_we_ck == 1'b 1 & i_we_r[0] == CODE_WR_ACTIVE & i_ck_en_r[0] == CODE_CK_EN_ACTIVE)
      i_we_n[0] <= 1'b 0;
   else
      i_we_n[0] <= 1'b 1;

   if (i_we_ck == 1'b 1 & i_we_r[1] == CODE_WR_ACTIVE & i_ck_en_r[1] == CODE_CK_EN_ACTIVE)
      i_we_n[1] <= 1'b 0;
   else
      i_we_n[1] <= 1'b 1;

   if (i_we_ck == 1'b 1 & i_we_r[2] == CODE_WR_ACTIVE & i_ck_en_r[2] == CODE_CK_EN_ACTIVE)
      i_we_n[2] <= 1'b 0;
   else
      i_we_n[2] <= 1'b 1;

   if (i_we_ck == 1'b 1 & i_we_r[3] == CODE_WR_ACTIVE & i_ck_en_r[3] == CODE_CK_EN_ACTIVE)
      i_we_n[3] <= 1'b 0;
   else
      i_we_n[3] <= 1'b 1;
   end
     
// Enable output when a read is taking place (i.e when no write byte 
// enable is active).
//

assign i_out_enable_n = ((i_we_r[0] == CODE_WR_ACTIVE &
                        i_ck_en_r[0] == CODE_CK_EN_ACTIVE) |

                        (i_we_r[1] == CODE_WR_ACTIVE &
                        i_ck_en_r[1] == CODE_CK_EN_ACTIVE) |

                        (i_we_r[2] == CODE_WR_ACTIVE &
                        i_ck_en_r[2] == CODE_CK_EN_ACTIVE) |

                        (i_we_r[3] == CODE_WR_ACTIVE &
                        i_ck_en_r[3] == CODE_CK_EN_ACTIVE)) ? 1'b 1: 
                1'b 0;
                
// Enable the RAM when any access is taking place
//
assign i_enable_ram_n = (i_ck_en_r[0] == LDST_CK_EN_ACTIVE |
                         i_ck_en_r[1] == LDST_CK_EN_ACTIVE  |
                         i_ck_en_r[2] == LDST_CK_EN_ACTIVE  |
                         i_ck_en_r[3] == LDST_CK_EN_ACTIVE) ? 1'b 0 :
                 1'b 1;

// Set the read data to the corresponding byte from the read output of
// the C RAM model, but only if a read operation is being performed.
//
always @(i_mem_out or i_we_r or i_ck_en_r)
   begin

   if (i_we_r[3] == CODE_RE_ACTIVE &
       i_ck_en_r[3] == CODE_CK_EN_ACTIVE)
      begin
      i_rd_data[31:24] <= i_mem_out[31:24];
      end
      
   if (i_we_r[2] == CODE_RE_ACTIVE &
       i_ck_en_r[2] == CODE_CK_EN_ACTIVE)
      begin
      i_rd_data[23:16] <= i_mem_out[23:16];
      end
      
   if (i_we_r[1] == CODE_RE_ACTIVE &
       i_ck_en_r[1] == CODE_CK_EN_ACTIVE)
      begin
      i_rd_data[15:8] <= i_mem_out[15:8];
      end
      
   if (i_we_r[0] == CODE_RE_ACTIVE &
       i_ck_en_r[0] == CODE_CK_EN_ACTIVE)
      begin
      i_rd_data[7:0] <= i_mem_out[7:0];
      end
      
   end

// register control signals for the first stage    
always @(posedge clk)
begin
         i_address_r <= address;      
         i_wr_data_r <= wr_data;
         i_we_r      <= we;
         i_ck_en_r   <= ck_en;         
end   

assign rd_data = i_rd_data;

// =================== RAM model instantiation =========================

// INIT_FILE is set to the hex file that is loaded on start of 
// simulation if the parameter DOWNLOAD_ON_POWER_UP is set to true.
//
parameter INIT_FILE = "init_mem.hex";

// If CLEAR_ON_POWER_UP is set to true, then the RAM is initialized at 
// start of simulation (before hex upload). 
//
parameter CLEAR_ON_POWER_UP = `FALSE;

// If DOWNLOAD_ON_POWER_UP is set to true, then the RAM is downloaded 
// at start of simulation.
//
parameter DOWNLOAD_ON_POWER_UP = `TRUE;

// Number of memory words
//
parameter MEMORY_SIZE = 131072;

// Address bus width
//
parameter ADDRESS_WIDTH = LDST_A_WIDTH;

// Identifies which ARC memory model this RAM model is associated
//
parameter MEMORY_MODEL_NUM = 4 + 0;

// Defines where in the memory map this RAM is located.
//
parameter BASE_ADDRESS = (32'h 00800000)/4;

`ifndef IS_ARCv1_TB

`ifdef TTVTOC
always @(*)
`else
initial
`endif
begin
$jk_sram
(
    "init_mem.hex",
    CLEAR_ON_POWER_UP,
    DOWNLOAD_ON_POWER_UP,
    BASE_ADDRESS,
    MEMORY_SIZE,
    ADDRESS_WIDTH,
    MEMORY_MODEL_NUM,
    i_enable_ram_n,        // nCE, (RAM model ports)
    i_out_enable_n,        // nOE,
    i_we_n,                // nWE,
    i_address_r,               // A,
    i_wr_data_r,               // D,
    tied_high,             // CE2,
    i_mem_out,             // D_out
    options                // Endianness etc.
);
end

`endif

//synopsys translate_on
   
endmodule


