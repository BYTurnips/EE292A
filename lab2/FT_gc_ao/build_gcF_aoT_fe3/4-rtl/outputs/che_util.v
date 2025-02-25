// `ifndef CHE_UTIL_V
// `define CHE_UTIL_V

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
// Cache block definitions file
//
//  Direct Mapped caches.
// 
//   Any instruction from memory can only appear in one place in a direct mapped
//  cache. The cache is arranged as a number of 'lines,' each of which contain a
//  few instructions. The size of the line is determined by analysis of code 
//  traces. An entire line is the only burst size requested by the cache system.
//  The data in the line is stored in the cache data RAM. Since the data RAM is
//  as wide as the instruction, the position of an instruction in the data RAM is
//  found by :
// 
//    data_ram address =  (real_address MOD cache_size) DIV instruction_bytes.
// 
//  (for 32 bit instructions, instruction_bytes = 4)
// 
//   A tag value for each line is held in a separate RAM, which allows the cache
//  control logic to tell where the line came from in memory. In addition, the 
//  top bit of the tag is used to show whether the line is valid, i.e. whether
//  the line in question has ever been loaded from memory. These tags
//  are cleared after reset or by an invalidate request. Since the cache is
//  direct mapped, the tag value stored is : real_address DIV cache_size.
//   This value is stored at the tag address :
// 
//   tag_ram address = (real_address MOD cache_size) DIV (line_length*instruction_bytes)
// 
//   When an instruction fetch is attempted, the cache takes the address from the
//  ARC, gets the tag RAM value for the address (see tag_ram address above) and
//  if this is equal to client_address DIV cache_size, then the instruction in
//  question is held in the data RAM, and we have a 'hit'. If not, then a 'miss'
//  has occurred, and a line fetch from memory must be initiated.
// 
// 
//    25                                                             2   1   0
//    +------------------------------------------------------------------------+
//    | ignored  |  cmp with tag data  |    use as tag addr     |      | 0 | 0 |
//    +------------------------------------------------------------------------+
//               |                     |<---- use as data ram addr --->|
//               |
//               |<------------- useful bits in the memory system ------------>|
// 
//  
// 
//

//  Testbench constants
// 
//  Used in the testbench. Only CHE_LINELENGTH is used in the logic itself.
// 
//  CHE_SIZE         Cache size in bytes.
// 
//  CHE_LINELENGTH   Number of 32-bit instructions in a cache line
//                   - used to produce burst size byte
// 
//  CHE_LINES        (Derived) number of lines in the cache
//

parameter CHE_SIZE = 2048;
parameter CHE_LINELENGTH = 8;
parameter CHE_OPS = CHE_SIZE / 4; 
parameter CHE_LINES = CHE_OPS / CHE_LINELENGTH;


//  These are the clock_to_out access times for two synchronous RAMs.
//  Note no setup or hold checks are made in the dummy memory models.
//  Set the multiplier to 1 if timing is required.

// synopsys translate_off

parameter cache_ram_multiplier = 0; 
parameter data_tdor = 1.5 * cache_ram_multiplier;
parameter tag_tdor = 1 * cache_ram_multiplier;

// synopsys translate_on

//  Initialise RAM contents to zero?
// 
//  For the behavioural RAM models, this will cut out loads of 'X' related 
//  warnings when blank 'X' instructions are flowed throught the pipeline.
// 

parameter INIT0_DATA_RAM = 1'b 1;


//  Memory System Constants
//  =======================
// 
//  MEM_A_WIDTH      Number of address lines which are used in the external
//                   memory system.
//                   This is used to calculate how wide the tags need to be.
//                   Should never be set higher than 26, which is the maximum
//                   address range of the ARC's 24-bit program counter.
//                    If the memory is wider, then the memory controller must 
//                   produce the extra bits itself, since addresses wider than
//                   26 bits cannot be accomodated by the cache system.
// 
//  MEM_D_WIDTH      Data width of memory system. Only valid option is 32 bits.
// 
//  BURST_WIDTH      Width of the bus used to specify the size of a burst load from
//                   memory.
// 
//  LINE_BURST       Number of bytes to be fetched which make up a whole cache line.
// 

parameter MEM_A_WIDTH = 24;
parameter MEM_A_MSB = (MEM_A_WIDTH - 1);
 
parameter MEM_D_WIDTH = 32; 
parameter MEM_D_MSB = (MEM_D_WIDTH - 1); 

parameter BURST_WIDTH = 8; // MAX_BURST_WIDTH || 8
parameter BURST_MSB = (BURST_WIDTH - 1); 

parameter LINE_BURST = ((CHE_LINELENGTH * 4) - 1);

//  Cache constants
//  ===============     
// 
//  CHE_LINE_WIDTH   Number of bits needed to specify line length.
//                   line_length = 2^CHE_LINE_WIDTH
//                   for 4 instruction lines, CHE_LINE_WIDTH = 2
//                   for 8 instruction lines, CHE_LINE_WIDTH = 3 etc..
// 
//  CHE_A_WIDTH      Number of bits needed to specify a location in the data RAM.
//                   for 32bit instructions, 1k icache -> = log(1024)/log(2) - 2 = 8
//                                           2k icache -> = log(2048)/log(2) - 2 = 9
//                                           4k icache -> = log(4096)/log(2) - 2 = 10
// 
//  TAG_A_WIDTH      Derived constant for address width of tag RAM. Depends upon size
//                   of cache, and length of lines.
//                   for 8x32bits instrs per line, 1k icache -> = 8 - 3 = 5
//                                                 2k icache -> = 9 - 3 = 6
//                                                 4k icache -> = 10 - 3 = 7
// 
//  TAG_D_WIDTH      Derived constant for data width of tag RAM. Depends upon size of
//                   cache, and size of the external memory system. One is added to the
//                   width, since the valid bits are held in this RAM.
// 
//  CHE_PC_DA_LSB &  Derived constants for the position in the nextpc[25:2] word where
//  CHE_PC_DA_MSB    the data RAM's address bits are to be found.
// 
//  CHE_PC_TA_LSB &  Derived constants for the position in the nextpc[25:2] word where
//  CHE_PC_TA_MSB    the tag RAM's address bits are to be found.
// 
//  CHE_PC_TD_LSB &  Derived constants for the position in the nextpc[25:2] word with
//  CHE_PC_TD_MSB    which the tag RAM's data bits are to be compared.
// 
//  START_I_TAG_ADDR_MASK &  Initial mask setting, the builder calculates the masks for
//  the minimum START_I_TAG_DATA_MASK &  cache size and line length with in the
//  selected bounds START_I_LINE_LENGTH_MASK.
//
parameter START_I_LINE_LENGTH_MASK = 32'b 00000000000000000000000000000000;
parameter START_I_TAG_ADDR_MASK = 32'b 00000000000000000000000000000000;
parameter START_I_TAG_DATA_MASK = 32'b 00000000000000000000000000000000;

//  64k cache down to 16 byte cache.
//  64 word line downto 4 word line.

parameter MAX_CHE_A_WIDTH = 9;
parameter MIN_CHE_A_WIDTH = 0;

parameter MAX_LINE_WIDTH = 3;
parameter MIN_LINE_WIDTH = 0;

parameter MAX_TAG_A_WIDTH = (MAX_CHE_A_WIDTH - MIN_LINE_WIDTH);
parameter MAX_TAG_D_WIDTH = MEM_A_WIDTH - MIN_CHE_A_WIDTH - 2;

parameter MIN_CHE_A_MSB = MIN_CHE_A_WIDTH + 1; 
parameter MAX_TAG_D_MSB = MEM_A_MSB; 
parameter MAX_LINE_MSB = MAX_LINE_WIDTH + 1; 
parameter MAX_TAG_D_LSB = MIN_CHE_A_MSB + 1; 
parameter MAX_TAG_A_MSB = MAX_CHE_A_WIDTH + 1; 
parameter MAX_TAG_A_LSB = MIN_LINE_WIDTH + 2; 
parameter MAX_CHE_A_MSB = MAX_TAG_A_MSB;
parameter ADDR_LSB = 2;

parameter MAX_BURST_WIDTH = MAX_LINE_WIDTH + 2; 
parameter MAX_BURST_MSB = (MAX_LINE_WIDTH - 1) + 2;

parameter CHE_LINE_WIDTH = MAX_LINE_WIDTH; 
parameter CHE_LINE_MSB = MAX_LINE_MSB;

parameter CHE_A_WIDTH = MAX_CHE_A_WIDTH; 
parameter CHE_A_MSB = MAX_CHE_A_MSB; 
parameter CHE_A_LSB = ADDR_LSB;

parameter IC_DATA_WIDTH = (CHE_A_MSB - ADDR_LSB); // SD

// MAX_TAG_A_WIDTH ||  (CHE_A_WIDTH - CHE_LINE_WIDTH)
parameter TAG_A_WIDTH = 0;

// MAX_TAG_A_LSB || CHE_LINE_WIDTH + 2
parameter CHE_PC_TA_LSB = 0;

parameter CHE_PC_TA_MSB = MAX_TAG_A_MSB; 

parameter TAG_A_MSB = MAX_TAG_A_MSB;

// MAX_TAG_A_LSB    || CHE_PC_TA_LSB
parameter TAG_A_LSB = 0;

parameter TAG_ADDR_WIDTH = (TAG_A_MSB - TAG_A_LSB); // SD

// MAX_TAG_D_WIDTH || (MEM_A_WIDTH - CHE_A_WIDTH - 2 + 2)
parameter TAG_D_WIDTH =  0;

// MAX_TAG_D_MSB + 1 + 1 || (MAX_TAG_D_MSB + 1)
parameter TAG_D_MSB = 0;

// MAX_TAG_D_LSB || (CHE_PC_TA_MSB + 1)
parameter TAG_D_LSB = 0;

parameter TAG_DATA_WIDTH = (TAG_D_MSB - TAG_D_LSB); // SD

parameter CHE_PC_DA_LSB = ADDR_LSB; 
parameter CHE_PC_DA_MSB = MAX_CHE_A_MSB;

// MAX_TAG_D_LSB || CHE_PC_TA_MSB + 1
parameter CHE_PC_TD_LSB = 0;
parameter CHE_PC_TD_MSB = MAX_TAG_D_MSB; 

parameter DEBUG_BIT = 28; 
parameter CONFIG_BIT = 29; 

parameter EN_CODE_RAM = 1'b0;
parameter EN_LINE_LOCK = 1'b0;

parameter EN_VIRTUAL_CACHE = 1'b0;

//  RAM constants
//  =============
// 
//  These constants describe the behavior of the RAM interfaces for the cache
//  (the RAM constants for the other RAMs are set in the file extutil.v).
//  It is only necessary to change these constants when you are replacing the
//  fake RAM models with real RAM models.
// 
//  These constants describe write enables of the RAMS and define whether a
//  write is active high or low. When the RAM port is not writing it is reading.

parameter DATA_WR_ACTIVE = 1'b1;
parameter TAG_WR_ACTIVE = 1'b1;

parameter DATA_RE_ACTIVE = !DATA_WR_ACTIVE; 
parameter TAG_RE_ACTIVE = !TAG_WR_ACTIVE;

//  These constants define whether the clock enable signals are active high or
//  low.

parameter DATA_CK_EN_ACTIVE = 1'b1;
parameter TAG_CK_EN_ACTIVE = 1'b1;

//  These constants define whether are the RAMs are write-through or not

parameter IC_DATA_WR_THROUGH = 1'b 0; 
parameter IC_TAG_WR_THROUGH  = 1'b 0; 



// `endif
