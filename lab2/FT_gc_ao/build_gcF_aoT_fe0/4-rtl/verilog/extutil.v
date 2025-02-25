//`ifndef EXTUTIL_V
//`define EXTUTIL_V
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
//  Manufacturer code and version numbers: used in identity register
// 
//  The values for the manufacturer code will be allocated by ARC
//  to each customer adding extensions. Manufacturer version numbers are
//  free and can be changed at will by customers.
// 
//
//  Manufacturer name : Generic install 
// 
`define MANCODE 8'h 00
`define MANVER  8'h 00

//   Constants used by ARC which let it know what extensions are present, 
//   in order to correctly synthesize multiplexers and so on:
//
parameter XT_COREREG   = 1'b 1;    //  extension core regs
parameter XT_AUXREG    = 1'b 1;    //  extension aux regs
parameter XT_AUXDAR    = 1'b 1;    //  extension dual access aux regs
parameter XT_ALUOP     = 1'b 1;    //  extension alu operations
parameter XT_MULTIC_OP = 1'b 1;    //  pipelined mulitcycle extension  operations
parameter XT_INSCC     = 1'b 1;    //  extension instruction cc's
parameter XT_JMPCC     = 1'b 1;    //  extension branch/jump cc's
parameter XT_ALUFLAGS  = 1'b 1;    //  extensions can set flags

//  The parameter AUXDECSZ defines the width of the decode performed on the
//  addresses used to access the auxiliary registers from both the ARC and
//  the host. If it is desired to add a large amount of RAM to the auxiliary
//  registers bus which would require a wider decode for all the registers
//  then this parameter must be altered and all affected parts of the design
//  resynthesised.
//
parameter AUXDECSZ = 15; //  (16 bits of decode)

// --------------- Register file and DCCM RAM constants ----------------
// 
// These constants describe the behavior of the RAM interface for the 
// register file and the DCCM RAM (the RAM constants for the cache are
// set in the file che_util.v). It is only necessary to change these 
// constants when you are replacing the fake RAM models with real RAM 
// models.
//
// These constants describe write enables of the RAMS and define 
// whether a write is active high or low. When the RAM port is not 
// writing it is reading.

parameter REGFILE_WR_ACTIVE = 1'b 1; 
parameter LDST_WR_ACTIVE    = 1'b 1; 

parameter REGFILE_RE_ACTIVE = ~REGFILE_WR_ACTIVE; 
parameter LDST_RE_ACTIVE    = ~LDST_WR_ACTIVE; 

//  These constants define whether the clock enable signals are active 
//  high or low.

parameter REGFILE_CK_EN_ACTIVE = 1'b 1; 
parameter LDST_CK_EN_ACTIVE    = 1'b 1;

// ------------- End of Register file and DCCM RAM constants -----------
//
// ----------------------- ICCM RAM constants --------------------------
//
// When a ICCM RAM is selected a fake ICCM RAM of fixed size (512k) is
// used. The user must manually replace the fake ICCM RAM with a real 
// RAM. If the real RAM is small then the test code might not work
// anymore. The constants below describe the fake ICCM RAM.
// 
// The constants below define the size of the address. The least
// significant bit (CODE_RAM_ADDR_LSB) should be 0 because all RAM
// accesses are longwords.
//
   parameter CODE_RAM_ADDR_LSB = 0;
   parameter CODE_RAM_ADDR_MSB = 16;
   parameter CODE_RAM_A_WIDTH  = (CODE_RAM_ADDR_MSB - 
                                  CODE_RAM_ADDR_LSB + 1);

// The RAM size in longwords (CODE_RAM_SIZE) equals two to the power of
// the number of address bits in the longword address (CODE_RAM_ADDR_MSB
// minus CODE_RAM_ADDR_LSB).
//
   parameter CODE_RAM_SIZE = 131072;

   `define     code_cell_msb   CODE_RAM_ADDR_MSB
   `define     code_cell_lsb   `code_cell_msb - 2
   `define     code_cell_addr_msb `code_cell_lsb - 1

   `define     code_ram0       3'b 000
   `define     code_ram1       3'b 001
   `define     code_ram2       3'b 010
   `define     code_ram3       3'b 011
   `define     code_ram4       3'b 100
   `define     code_ram5       3'b 101
   `define     code_ram6       3'b 110
   `define     code_ram7       3'b 111

// These constants describe write enables of the RAMS and define whether
// a write is active high or low. When the RAM is not writing it is
// reading.
//
   parameter CODE_WR_ACTIVE = 1'b 1;
   parameter CODE_RE_ACTIVE = ~CODE_WR_ACTIVE; 

// These constant define whether the clock enable signals is active
// high or low.
//
   parameter CODE_CK_EN_ACTIVE = 1'b 1; 

//------------------End of ICCM RAM constants ---------------------

// The constant CK_GATING is used to indicate whether clock gating 
// should be used.

parameter CK_GATING = 1'b 1; 

// The constant IN_TEST_MODE is used to set the test_mode pin at top level.
// During normal operation it should be set to 0. During test mode it should
// be set to 1.
 
parameter IN_TEST_MODE  = 1'b 0;

//synopsys translate_off

// Simulation timing constant, set multiplier to 
//  1 if timing is required.

parameter register_multiplier = 0; 

// Choose one from the following to replace this!!!!
parameter rf_tdor = 0.65 * register_multiplier;
//synopsys translate_on

// ---------------------------------------------------------------------
//
// The interrupt sensitivity is also configurable. It can be set either
// to be pulse sensitive or level sensitive.
//
// [Pulse]  a momentary pulse is received, which is converted into a
// level. The level is cleared when the interrupt is issued. Multiple
// pulses can be received and latched before the interrupt is issued.
//
// [Level] The interrupt line must be held active until cleared
// explicitly by the interrupt service routine.
//
`define PULSE  1'b 1
`define LEVEL  1'b 0

parameter IRQ_TYPE_PULSE = `PULSE;
parameter IRQ_TYPE_LEVEL = `LEVEL;

//
// Basecase interrupts 3..15; extension 15..MAX_LAST_INTERRUPT.
// --------------------------------------------
//
parameter MEM_IRQ_TYPE = `PULSE; //  fixed
parameter INS_IRQ_TYPE = `PULSE; //  fixed
parameter IRQ3_TYPE  = `LEVEL;
parameter IRQ4_TYPE  = `LEVEL;
parameter IRQ5_TYPE  = `LEVEL;
parameter IRQ6_TYPE  = `LEVEL;
parameter IRQ7_TYPE  = `LEVEL;
parameter IRQ8_TYPE  = `LEVEL;
parameter IRQ9_TYPE  = `LEVEL;
parameter IRQ10_TYPE  = `LEVEL;
parameter IRQ11_TYPE  = `LEVEL;
parameter IRQ12_TYPE  = `LEVEL;
parameter IRQ13_TYPE  = `LEVEL;
parameter IRQ14_TYPE  = `LEVEL;
parameter IRQ15_TYPE  = `LEVEL;
parameter IRQ16_TYPE  = `LEVEL;
parameter IRQ17_TYPE  = `LEVEL;
parameter IRQ18_TYPE  = `LEVEL;
parameter IRQ19_TYPE  = `LEVEL;
parameter IRQ20_TYPE  = `LEVEL;
parameter IRQ21_TYPE  = `LEVEL;
parameter IRQ22_TYPE  = `LEVEL;
parameter IRQ23_TYPE  = `LEVEL;
parameter IRQ24_TYPE  = `LEVEL;
parameter IRQ25_TYPE  = `LEVEL;
parameter IRQ26_TYPE  = `LEVEL;
parameter IRQ27_TYPE  = `LEVEL;
parameter IRQ28_TYPE  = `LEVEL;
parameter IRQ29_TYPE  = `LEVEL;
parameter IRQ30_TYPE  = `LEVEL;
parameter IRQ31_TYPE  = `LEVEL;

// ------------------------------------------------------------------------
// The vector constant below, IRQ_PULSE_TYPES, is used to tell the hmsl
// scripts whether level or pulse IRQ:s should be generated. Each position
// in the vector describes an interrupt channel. High means pulse and
// low means level type of IRQ.
// ------------------------------------------------------------------------


parameter IRQ_PULSE_TYPES = {
    MEM_IRQ_TYPE, 
    INS_IRQ_TYPE
    , IRQ3_TYPE
    , IRQ4_TYPE
    , IRQ5_TYPE
    , IRQ6_TYPE
    , IRQ7_TYPE
    , IRQ8_TYPE
    , IRQ9_TYPE
    , IRQ10_TYPE
    , IRQ11_TYPE
    , IRQ12_TYPE
    , IRQ13_TYPE
    , IRQ14_TYPE
    , IRQ15_TYPE
    , IRQ16_TYPE
    , IRQ17_TYPE
    , IRQ18_TYPE
    , IRQ19_TYPE
    , IRQ20_TYPE
    , IRQ21_TYPE
    , IRQ22_TYPE
    , IRQ23_TYPE
    , IRQ24_TYPE
    , IRQ25_TYPE
    , IRQ26_TYPE
    , IRQ27_TYPE
    , IRQ28_TYPE
    , IRQ29_TYPE
    , IRQ30_TYPE
    , IRQ31_TYPE
    };

// External Memory Bus constants
// =============================
//
// EXT_A_WIDTH      Number of address lines which are used in the external
//                  memory system.
//                  Should never be set higher than 32, which is the maximum
//                  address range of the ARC's LD/ST accesses.
//                  It has to be greater than or equal the cache memory bus,  
//                  since the cache controller will be able to load
//                  instructions from locations that cannot be accomodated 
//                  by the system.
// 
//  32 Bits = 4G of RAM
//
// parameter EXT_A_WIDTH = 24; 
// parameter EXT_A_MSB = EXT_A_WIDTH - 1; 

// Constant arc_endianness
// =======================
// 
// This constant determines which endian type you require. If you need Little
// endian, set the constant to 'little' in order that bytes assume their
// natural lsb-first order in memory. If you require Big endian support then
// set the constant to 'big'.
//
// All ARC memory systems are little-endian. This constant has been added in
// order to support big-endian mode.
//
// The affected modules include inst_align at the instruction fetch interface,
// and readsort in the standard memory controller ldst_queue.
// These modules deal with aligning instructions and byte reads and writes to
// and from memory respectively.
//  
// TYPE endian_type:
//
parameter endian_type_little = 0;
parameter endian_type_big = 1;
parameter endian_type_switchable = 2;

parameter arc_endianness = endian_type_little;

// Standard extension opcode mappings
// ==================================
//
parameter OLR_N = 1;
parameter OSR_N = 2;

// Extension op code id
//
parameter OS_OP_N = 3; 

// DCCM RAM address range
// =======================
//
// The constant LDST_RAM_BASE_DEFAULT defines the default memory
// address range mapped to the DCCM RAM. Unlike the peripheral
// memory space, the DCCM RAM memory space can be changed
// during operation. The constant lram_base_default defines the
// DCCM RAM memory space after an asynchronous global clear.
//
parameter LDST_RAM_BASE_DEFAULT = 24'b100000000000000000000000;
parameter LDST_RAM_BASE_INT     = 32'd 8388608;

//-----------------------------------------------------------------------

// Debug Modes
// ===========
//
// The number of actionpoints selected for the ARC are defined through
// the variable defined below:
// 
parameter NUM_APS = 2; 

// The number of data sources for the actionpoint mechanism are defined
// by the variable below:
// 
parameter NUM_SOURCES = 7; 

// The number of bits required to encode all the bits for the actionpoint
// mechanism are defined by the variable defined below:
// 
parameter NUM_AP_BITS = 3; 
  
// =====================================
// New Actionpoints constant definitions
// =====================================
//
// MSB of mask and value registers
parameter AP_AMV_SIZE         = 32;
// MSB of control registers
parameter AP_AC_SIZE          = 10;
// Control register fields
// LSB of actionpoint target (AT) field
parameter AP_AC_AT_LSB        = 0;
// MSB of actionpoint target (AT) field
parameter AP_AC_AT_MSB        = 2;
// Check writes bit
parameter AP_AC_WRITE         = 4;
// Check reads bit
parameter AP_AC_READ          = 5;
// Invert range bit
parameter AP_AC_INVERT        = 6;
// Pair bit
parameter AP_AC_PAIR          = 7;
// Action bit (BRK/SWI)
parameter AP_AC_ACTION        = 8;
// Quad bit
parameter AP_AC_QUAD          = 9;
// Test pattern to check external parameter 0
parameter AP_TEST_PATTERN0    = 32'hDEADBEEF;
// Test pattern to check external parameter 1
parameter AP_TEST_PATTERN1    = 32'hC0FFEE23;

// The following constants are specific to this ARC.
// They are typically defined before including jtag_defs.v.
//The following definitions are duplicated in jtag_defs.v so removing from here. Otherwise problem for analyze -autoread
//`define ARC_JEDEC_CODE 11'b0100_101_1000 // JEDEC code 0x58, bank 5; ARC's
//`define JTAG_IDCODE_REG_INIT {`JTAG_VERSION, `TWO_ZEROS, `ARCNUM, `ARC_TYPE, `ARC_JEDEC_CODE, 1'b1}

//Parameters for functions
parameter FOR_19B_ZERO_ONES      = 19'b 0000000000000000000;
parameter FOR_19B_ONE_ONES       = 19'b 0000000000000000001;
parameter FOR_19B_TWO_ONES       = 19'b 0000000000000000011;
parameter FOR_19B_THREE_ONES     = 19'b 0000000000000000111;
parameter FOR_19B_FOUR_ONES      = 19'b 0000000000000001111;
parameter FOR_19B_FIVE_ONES      = 19'b 0000000000000011111;
parameter FOR_19B_SIX_ONES       = 19'b 0000000000000111111;
parameter FOR_19B_SEVEN_ONES     = 19'b 0000000000001111111;
parameter FOR_19B_EIGHT_ONES     = 19'b 0000000000011111111;
parameter FOR_19B_NINE_ONES      = 19'b 0000000000111111111;
parameter FOR_19B_TEN_ONES       = 19'b 0000000001111111111;
parameter FOR_19B_ELEVEN_ONES    = 19'b 0000000011111111111;
parameter FOR_19B_TWELVE_ONES    = 19'b 0000000111111111111;
parameter FOR_19B_THIRTEEN_ONES  = 19'b 0000001111111111111;
parameter FOR_19B_FOURTEEN_ONES  = 19'b 0000011111111111111;
parameter FOR_19B_FIFTEEN_ONES   = 19'b 0000111111111111111;
parameter FOR_19B_SIXTEEN_ONES   = 19'b 0001111111111111111;
parameter FOR_19B_SEVENTEEN_ONES = 19'b 0011111111111111111;
parameter FOR_19B_EIGHTEEN_ONES  = 19'b 0111111111111111111;
parameter FOR_19B_NINETEEN_ONES  = 19'b 1111111111111111111;

//Decimal constants
parameter DECIMAL_32  = 32;
parameter DECIMAL_4   = 4;


//-----------------------------------------------------------------------
// Miscellaneous
// =============
//
// A constant for use with the XMAC extension.
//
parameter USE_XMAC = 1'b 1;

     // This function returns the MPU region size
     //
     function  [18:0] region_size;

         input [4:0]  region_code;

         begin
            case (region_code)
               5'b01100 : region_size = FOR_19B_ZERO_ONES     ;
               5'b01101 : region_size = FOR_19B_ONE_ONES      ;
               5'b01110 : region_size = FOR_19B_TWO_ONES      ;
               5'b01111 : region_size = FOR_19B_THREE_ONES    ;
               5'b10000 : region_size = FOR_19B_FOUR_ONES     ;
               5'b10001 : region_size = FOR_19B_FIVE_ONES     ;
               5'b10010 : region_size = FOR_19B_SIX_ONES      ;
               5'b10011 : region_size = FOR_19B_SEVEN_ONES    ;
               5'b10100 : region_size = FOR_19B_EIGHT_ONES    ;
               5'b10101 : region_size = FOR_19B_NINE_ONES     ;
               5'b10110 : region_size = FOR_19B_TEN_ONES      ;
               5'b10111 : region_size = FOR_19B_ELEVEN_ONES   ;
               5'b11000 : region_size = FOR_19B_TWELVE_ONES   ;
               5'b11001 : region_size = FOR_19B_THIRTEEN_ONES ;
               5'b11010 : region_size = FOR_19B_FOURTEEN_ONES ;
               5'b11011 : region_size = FOR_19B_FIFTEEN_ONES  ;
               5'b11100 : region_size = FOR_19B_SIXTEEN_ONES  ;
               5'b11101 : region_size = FOR_19B_SEVENTEEN_ONES;
               5'b11110 : region_size = FOR_19B_EIGHTEEN_ONES ;
               5'b11111 : region_size = FOR_19B_NINETEEN_ONES ;
               default  : region_size = FOR_19B_ZERO_ONES     ;
            endcase
         end
     endfunction // region_size

     // Modified compare used for modular renormalizition in the
     // Viterbi extension.
     function  [0:0]  f_modular_A_gt_B;

         input [15:0] A; 
         input [15:0] B; 

         reg          a_gt_b; 

         begin
            // f_modular_A_gt_B
            if (A[14:0] > B[14:0])
               a_gt_b = 1'b1; 
            else
               a_gt_b = 1'b0; 

            f_modular_A_gt_B = (A[15] ^ B[15] ^ a_gt_b) == 1'b1; 
         end
     endfunction // f_modular_A_gt_B

     function  [7:0] reflect;
         input [7:0] A;
          
         begin
            reflect = {A[0],A[1],A[2],A[3],A[4],A[5],A[6],A[7]};
         end
     endfunction // reflect

//synopsys translate_off
    // This performs X-Checking on a 32-bit bus and returns zero when there
    // is an X set in one or more bits in the bus.
    function chk_vec_31_0;

        input [31:0] test_vec;

        reg          any_x;
        reg   [5:0]  pos_count;

        begin

           any_x = 1;
   
           for (pos_count = 0; pos_count <= 31; pos_count = pos_count + 1)
               if ((test_vec[pos_count] !== 1'b0) &&
                   (test_vec[pos_count] !== 1'b1))
                   any_x =  0;
               else 
                  any_x = any_x;
   
               chk_vec_31_0 = any_x; 
        end 
    endfunction

    // This performs X-Checking on a 5-bit bus and returns zero when there
    // is an X set in one or more bits in the bus.
    function chk_vec_7_3;

        input [7:3] test_vec;

        reg         any_x;
        reg   [5:0] pos_count;

        begin
    
           any_x = 1;
   
           for (pos_count = 3; pos_count <= 7; pos_count = pos_count + 1)
               if ((test_vec[pos_count] !== 1'b0) &&
                   (test_vec[pos_count] !== 1'b1))
                   any_x =  0;
               else 
                   any_x = any_x;

               chk_vec_7_3 = any_x; 
        end 
    endfunction

    // This performs X-Checking on a 5-bit bus and returns zero when there
    // is an X set in one or more bits in the bus.
    function chk_vec_4_0;

        input [4:0] test_vec;

        reg         any_x;
        reg   [5:0] pos_count;

        begin
    
           any_x = 1;
   
           for (pos_count = 0; pos_count <= 4; pos_count = pos_count + 1)
               if ((test_vec[pos_count] !== 1'b0) &&
                   (test_vec[pos_count] !== 1'b1))
                   any_x =  0;
               else 
                   any_x = any_x;

           chk_vec_4_0 = any_x; 
        end 
    endfunction

    // This performs X-Checking on a 6-bit bus and returns zero when there
    // is an X set in one or more bits in the bus.
    function chk_vec_5_0;

        input [5:0] test_vec;

        reg         any_x;
        reg   [5:0] pos_count;

        begin
    
           any_x = 1;
   
           for (pos_count = 0; pos_count <= 5; pos_count = pos_count + 1)
               if ((test_vec[pos_count] !== 1'b0) &&
                   (test_vec[pos_count] !== 1'b1))
                   any_x =  0;
               else 
                   any_x = any_x;

               chk_vec_5_0 = any_x; 
        end 
    endfunction

    // This performs X-Checking on a 24-bit bus and returns zero when there
    // is an X set in one or more bits in the bus.
    function chk_vec_25_2;

        input [25:2] test_vec;

        reg           any_x;
        reg    [5:0]  pos_count;

        begin
    
           any_x = 1;
   
           for (pos_count = 2; pos_count <= 25; pos_count = pos_count + 1)
               if ((test_vec[pos_count] !== 1'b0) &&
                   (test_vec[pos_count] !== 1'b1))
                   any_x =  0;
               else 
                   any_x = any_x;

               chk_vec_25_2 = any_x; 
        end 
    endfunction

    // This performs X-Checking on a 4-bit bus and returns zero when there
    // is an X set in one or more bits in the bus.
    function chk_vec_3_0;

        input [3:0] test_vec;

        reg         any_x;
        reg   [5:0] pos_count;

        begin
    
           any_x = 1;
   
           for (pos_count = 0; pos_count <= 3; pos_count = pos_count + 1)
               if ((test_vec[pos_count] !== 1'b0) &&
                   (test_vec[pos_count] !== 1'b1))
                   any_x =  0;
               else 
                   any_x = any_x;

               chk_vec_3_0 = any_x; 
        end 
    endfunction

    // This performs X-Checking on a 2-bit bus and returns zero when there
    // is an X set in one or more bits in the bus.
    function chk_vec_1_0;

        input [1:0] test_vec;

        reg         any_x;
        reg   [5:0] pos_count;

        begin
    
           any_x = 1;
   
           for (pos_count = 0; pos_count <= 1; pos_count = pos_count + 1)
               if ((test_vec[pos_count] != 1'b0) &&
                   (test_vec[pos_count] != 1'b1))
                   any_x =  0;
               else 
                   any_x = any_x;

               chk_vec_1_0 = any_x; 
        end 
    endfunction
//synopsys translate_on

    // Checks for xholdup123 assertion.
    function [((10*8)-1):0] dostr2;

         input en;

         begin
            if (en != 0)
               dostr2 = "xholdup2  ";
            else
               dostr2 = 0;
   
        end 
    endfunction // dostr

    function [((10*8)-1):0] dostr2b;

        input en;

        begin
           if (en != 0)
              dostr2b = "xholdup2b ";
           else
              dostr2b = 0;

        end 
    endfunction // dostr

    function [((10*8)-1):0] dostr3;

        input en;

        begin
           if (en != 0)
              dostr3 = "xholdup3  ";
           else
              dostr3 = 0;
   
        end 
    endfunction

    function [0:0] auxdc;

        input   [31:0]       a;
        input   [AUXDECSZ:0] reg_width;

        reg                  match;

        begin

           match = (a[AUXDECSZ:0] == reg_width[AUXDECSZ:0]);

           if (match)
              auxdc =1'b 1;
           else
              auxdc = 1'b 0;
   
        end
    endfunction

// Debug port needs this.
`include "jtag_defs.v"
// `endif
