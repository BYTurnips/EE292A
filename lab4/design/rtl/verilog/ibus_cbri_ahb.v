// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 2003-2012 ARC International (Unpublished)
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
// --------------------------------------------------------------- //
// The "bvci_to_ahb" bridge has two functions:                     //
//                                                                 //
// 1) BVCI-initiator to AHB-master protocol conversion             //
// 2) Data path registering (i.e. introducing a pipeline stage)    //
//                                                                 //
// It is important to note that bvci_to_ahb is not a general       //
// purpose protocol translator for BVCI to AHB since a number of   //
// simplications are made according to the known behaviour of      //
// the island internal BVCI initiators. In particular, the         //
// beats in BVCI initiator bursts are assumed to be back-to-back   //
// and so the bridge never needs to generate BUSY transactions     //
// on the AHB bus.                                                 //
//                                                                 //
// The bridge frontend port connects to an island internal BVCI    //
// initiator port. The BVCI signals of the frontend port are       //
// prefixed with "t_". The bridge backend port connects to an AHB  //
// subsytem master port. The AHB signals of the backend port are   //
// prefixed with letter "h". The AMBA specification states that    //
// AHB signal names should be in capital letters. However, in      //
// keeping with ARC's signal naming convention and to comply with  //
// RMM, lower case letters are used instead.                       //
//                                                                 //
// The bridge receives a BVCI cmd, translates it and passes it as  //
// an AHB command, waits to receives the AHB response, and finally //
// translate the response and passes it as a BVCI response. The    //
// bridge has no control over the operation of the BVCI protocol   //
// inside the island or the operation of AHB at the external       //
// memory controller. The AHB Error response is mapped and passed  //
// through to the processor as a BVCI rerror signal.               //
//                                                                 //
// Extension 1:                                                    //
//                                                                 //
// The AHB protocol does not have byte enable signals, instead     //
// HSIZE and the lower bits of the HADDR busses are used to encode //
// the size and offset of a cell transfer. Therefore, only bytes,  //
// halfwords, words and longwords can be written. The BVCI         //
// protocol supports byte enable signals and so is able to write   //
// cells with any byte patterns such as 0000_1110, 1000_0001 or    //
// even 0000_0000. The AHB bridge is extended to cater for such    //
// BVCI byte patterns by splitting the BVCI single cell accesses   //
// to two, three or four AHB accesses whenever required. There is  //
// a separate bus request/grant cycle for each of the split        //
// accesses on the AHB bus and so there is no guarantee that such  //
// AHB write accesses are carried atomically. However, BVCI Locked //
// accesses (resulting from Exchange instruction) are always       //
// carried out atomically - i.e. the HLOCK signal remains asserted //
// throughout the first read and any number of subsequent writes.  //
//                                                                 //
// Extension 2:                                                    //
//                                                                 //
// It is illegal in AHB for bursts to cross 1Kbyte address         //
// boundaries but there is no such restriction in the BVCI         //
// protocol. The AHB bridge is extended to detect 1KByte boundary  //
// crossing BVCI bursts and split them so that the first half runs //
// from the starting address to the boundary address. The AHB bus  //
// is then released and re-requested. Once re-granted the second   //
// half of the burst starts from the boundary address upto the end //
// address.                                                        //
//                                                                 //
// Extension 3:                                                    //
//                                                                 //
// Gate-keeper logic and a buffer is added between the original    //
// Gasket and the BVCI interface so as to handle the situation     //
// where rspack is set to low when a response is valid. The buffer //
// will simply buffer up these responses to be returned to the     //
// BVCI initiator later. In order to prevent the buffer from       //
// overflowing. The gatekeepr logic simply blocks any new packets  //
// from entering the Gasket when there is one or more item in the  //
// buffer. Hence the depth of the FIFO has to be at least the      //
// maximum packet length plus 2. The depth is set by the parameter //
// FIFO_DEPTH. FIFO_PTR_WIDTH has to be set to N such that         //
// 2^N > FIFO_DEPTH. For example, if FIFO_DEPTH = 4, then          //
// FIFO_PTR_WIDTH can be set to 3                                  //
//                                                                 //
// --------------------------------------------------------------- //
// --------------------------------------------------------------- //
// Input and output signals:                                       //
//                                                                 //
// iclk      : in  : module clock signal, processor clock          //
// hclk      : in  : module clock signal, bus clock                //
// rst_a     : in  : module reset signal, processor clock domain   //
// hresetn   : in  : module reset signal, bus clock domain         //
//                                                                 //
// Miscellaneous inputs:                                           //
//                                                                 //
// sync_r    : in  : Synchronization signal from ARC700 bridge     //
//                                                                 //
// BVCI port inputs:                                               //
//                                                                 //
// t_address : in  : BVCI address [31:0]                           //
// t_be      : in  : BVCI byte enables [byte-width:0]              //
// t_cmd     : in  : BVCI command [1:0]                            //
// t_eop     : in  : BVCI end of packet                            //
// t_plen    : in  : BVCI packet length [8:0] (in bytes)           //
// t_wdata   : in  : BVCI write data [data-width:0]                //
// t_cmdval  : in  : BVCI command valid                            //
// t_rspack  : in  : BVCI response acknowledge                     //
//                                                                 //
// AHB protocol port inputs:                                       //
//                                                                 //
// hgrant    : in  : AHB bus grant signal                          //
// hready    : in  : AHB bus ready signal                          //
// hresp     : in  : AHB bus response code [1:0]                   //
// hrdata    : in  : AHB bus read data [data-width:0]              //
//                                                                 //
// BVCI port outputs:                                              //
//                                                                 //
// t_cmdack  : out : BVCI command acknowledge                      //
// t_rdata   : out : BVCI read data [data-width:0]                 //
// t_reop    : out : BVCI response to end of packet                //
// t_rspval  : out : BVCI response valid                           //
// t_rerror  : out : BVCI error                                    //
//                                                                 //
// AHB protocol port outputs:                                      //
//                                                                 //
// hlock     : out : AHB locked access                             //
// htrans    : out : AHB transaction type [1:0]                    //
// haddr     : out : AHB address bus [31:0]                        //
// hwrite    : out : AHB read/write signal                         //
// hsize     : out : AHB data single transfer size [2:0]           //
// hburst    : out : AHB burst type [2:0]                          //
// hprot     : out : AHB protection bus [3:0]                      //
// hwdata    : out : AHB write data bus [data_width:0]             //
//                                                                 //
// Miscellaneous outputs:                                          //
//                                                                 //
// busy      : out : indicates if the bridge is in idle state      //
// --------------------------------------------------------------- //

module ibus_cbri_ahb(
  iclk,
  hclk,
  rst_a,
  hresetn,
  sync_r,
  t_address,
  t_be,
  t_cmd,
  t_eop,
  t_plen,
  t_wdata,
  t_cmdval,
  t_rspack,
  t_mode,
  t_priv,
  t_buffer,
  t_cache,
  hgrant,
  hready,
  hresp,
  hrdata,
  t_cmdack,
  t_rdata,
  t_reop,
  t_rspval,
  t_rerror,
  hbusreq,
  hlock,
  htrans,
  haddr,
  hwrite,
  hsize,
  hburst,
  hprot,
  hwdata,
  busy);

// External parameter
//
parameter C_DATA_WIDTH     = 64;
parameter FIFO_DEPTH       = 8;
parameter FIFO_PTR_WIDTH   = 4;
parameter EXT_A_MSB        = 31;

// Inputs
//
input                      iclk;
input                      hclk;
input                      rst_a;
input                      hresetn;
input                      sync_r;
input   [EXT_A_MSB:0]      t_address;
input   [(C_DATA_WIDTH/8)-1:0] t_be;
input   [1:0]              t_cmd;
input                      t_eop;
input   [8:0]              t_plen;
input   [C_DATA_WIDTH-1:0] t_wdata;
input                      t_cmdval;
input                      t_rspack;
input                      t_mode;
input                      t_priv;
input                      t_buffer;
input                      t_cache;
input                      hgrant;
input                      hready;
input   [1:0]              hresp;
input   [C_DATA_WIDTH-1:0] hrdata;

// Outputs
//
output                     t_cmdack;
output  [C_DATA_WIDTH-1:0] t_rdata;
output                     t_reop;
output                     t_rspval;
output                     t_rerror;
output                     hbusreq;
output                     hlock;
output  [1:0]              htrans;
output  [31:0]             haddr;
output                     hwrite;
output  [2:0]              hsize;
output  [2:0]              hburst;
output  [3:0]              hprot;
output  [C_DATA_WIDTH-1:0] hwdata;
output                     busy;

// Output wires
//
wire                       t_cmdack;
wire    [C_DATA_WIDTH-1:0] t_rdata;
wire                       t_reop;
wire                       t_rspval;
wire                       t_rerror;
wire                       hbusreq;
wire                       hlock;
wire    [1:0]              htrans;
wire    [31:0]             haddr;
wire                       hwrite;
wire    [2:0]              hsize;
wire    [2:0]              hburst;
wire    [3:0]              hprot;
wire    [C_DATA_WIDTH-1:0] hwdata;
wire                       busy;

// Internal parameters
//

// FSM state constants
//
parameter IDLE_STATE = 4'b 0000;
parameter GRNT_STATE = 4'b 0001;
parameter INIT_STATE = 4'b 0010;
parameter ACKN_STATE = 4'b 0011;
parameter WAIT_STATE = 4'b 0100;
parameter LAST_STATE = 4'b 0101;
parameter RTY0_STATE = 4'b 0110;
parameter RTY1_STATE = 4'b 0111;
parameter RTY2_STATE = 4'b 1000;
parameter RSPS_STATE = 4'b 1001;
parameter TRMT_STATE = 4'b 1010;

// AHB parameters
//
parameter AHB_RSP_OKAY    = 2'b 00;
parameter AHB_RSP_ERR     = 2'b 01;
parameter AHB_RSP_SPLIT   = 2'b 11;
parameter AHB_RSP_RETRY   = 2'b 10;

parameter AHB_SNGL_ACC    = 3'b 000;
parameter AHB_UNDF_BRST   = 3'b 001;
parameter AHB_WRAP4_BRST  = 3'b 010;
parameter AHB_INCR4_BRST  = 3'b 011;
parameter AHB_WRAP8_BRST  = 3'b 100;
parameter AHB_INCR8_BRST  = 3'b 101;
parameter AHB_WRAP16_BRST = 3'b 110;
parameter AHB_INCR16_BRST = 3'b 111;

parameter AHB_SIZE_8      = 3'b 000;
parameter AHB_SIZE_16     = 3'b 001;
parameter AHB_SIZE_32     = 3'b 010;
parameter AHB_SIZE_64     = 3'b 011;

parameter AHB_TRANS_IDLE  = 2'b 00;
parameter AHB_TRANS_NSEQ  = 2'b 10;
parameter AHB_TRANS_SEQ   = 2'b 11;

// Non-cacheable, non-bufferable, privileged data access
//
parameter AHB_PROT_NNPD   = 4'b 0011;

// BVCI commands
//
parameter BVCI_WR_CMD     = 2'b 10; // WRITE
parameter BVCI_LR_CMD     = 2'b 11; // LOCKED_READ

// Parameters to define the number of separate AHB single cell 
// writes for each single cell BVCI write
//
parameter SGL_0_AHB       = 3'b 000; // no    ahb accesses
parameter SGL_1_AHB       = 3'b 001; // one   ahb access
parameter SGL_2_AHB       = 3'b 010; // two   ahb accesses
parameter SGL_3_AHB       = 3'b 011; // three ahb accesses
parameter SGL_4_AHB       = 3'b 100; // four  ahb accesses

// Parameters to define the size of single cell AHB wirtes
//
parameter SGL_0_BYTE      = 2'b 00;  // no    bytes
parameter SGL_1_BYTE      = 2'b 01;  // one   byte
parameter SGL_2_BYTE      = 2'b 10;  // two   bytes
parameter SGL_4_BYTE      = 2'b 11;  // four  bytes
parameter SGL_8_BYTE      = 3'b 100; // eight bytes

parameter FIFO_WIDTH = C_DATA_WIDTH + 2;

// All internal signals have the "i_" prefix. This should not 
// be confused with "i_" prefix that is sometimes used for BVCI 
// initiator signals. There are no BVCI initiator signals in this
// module.

// Control signals
//
wire                    i_t_cmdval_sync;   //  synchronised version
wire                    i_bvci_cmd_a;      //  BVCI cmd received
wire                    i_ahb_rsp_a;       //  AHB rsp received
wire                    i_ahb_grant_a;     //  AHB bus granted

// FSM current state
//
reg  [3:0]              i_state_r;
reg  [3:0]              i_state_nxt;

// t_cmdack and t_rspval flipflops (not synchronised)
//
reg                     i_t_cmdack_r;
reg                     i_t_cmdack_nxt;
reg                     i_t_rspval_r;
reg                     i_t_rspval_nxt;

// Bus request, hwrite, hlock, reop, old buffer valid, 
// top buffer valid, restarted, wrap burst, last access,
// htrans type, hsize, and burst type flip flops
//
reg                     i_hbusreq_r;
reg                     i_hbusreq_nxt;
reg                     i_hwrite_r;
reg                     i_hwrite_nxt;
reg                     i_t_reop_r;
reg                     i_t_reop_nxt;
reg                     i_last_nxt;
reg                     i_last_r;
reg                     i_old_valid_r;
reg                     i_old_valid_nxt;
reg                     i_top_valid_r;
reg                     i_top_valid_nxt;
reg                     i_restarted_r;
reg                     i_restarted_nxt;
wire                    i_wrap_a;
reg                     i_wrap_r;
reg                     i_wrap_nxt;
reg  [1:0]              i_htrans_r;
reg  [1:0]              i_htrans_nxt;
reg  [2:0]              i_hsize_r;
reg  [2:0]              i_hsize_nxt;
reg  [2:0]              i_hburst_r;
reg  [2:0]              i_hburst_nxt;
reg                     i_hlock_r;
reg                     i_hlock_nxt;
reg                     i_atomic_r;
reg                     i_atomic_nxt;

// Signals for mapping BVCI to AHB signals
//
reg  [31:0]             i_haddr_a;
wire [C_DATA_WIDTH-1:0] i_hwdata_a;
wire [3:0]              i_hprot_a;
reg  [2:0]              i_hburst_a;

// Registers for storing the outstanding (translated) BVCI 
// signals
//
reg  [31:0]             i_haddr_top_r;
reg  [C_DATA_WIDTH-1:0] i_hwdata_top_r;
reg                     i_eop_top_r;
reg  [3:0]              i_hprot_r;
reg  [31:0]             i_haddr_top_nxt;
reg  [C_DATA_WIDTH-1:0] i_hwdata_top_nxt;
reg                     i_eop_top_nxt;
reg  [3:0]              i_hprot_nxt;

// Registers for keeping the current (translated) BVCI 
// signals
//
reg  [31:0]             i_haddr_out_r;
reg  [C_DATA_WIDTH-1:0] i_hwdata_out_r;
reg                     i_eop_out_r;
reg  [31:0]             i_haddr_out_nxt;
reg  [C_DATA_WIDTH-1:0] i_hwdata_out_nxt;
reg                     i_eop_out_nxt;

// Registers for saving the previous (translated) BVCI 
// signals
//
reg  [31:0]             i_haddr_old_r;
reg  [C_DATA_WIDTH-1:0] i_hwdata_old_r;
reg                     i_eop_old_r;
reg  [31:0]             i_haddr_old_nxt;
reg  [C_DATA_WIDTH-1:0] i_hwdata_old_nxt;
reg                     i_eop_old_nxt;

// Signals for mapping AHB to BVCI signals
//
wire [C_DATA_WIDTH-1:0] i_t_rdata_a;
wire                    i_t_rerror_a;

// Registers for keeping the current (translated) AHB 
// signal
//
reg  [C_DATA_WIDTH-1:0] i_t_rdata_r;
reg  [C_DATA_WIDTH-1:0] i_t_rdata_nxt;
reg                     i_t_rerror_r;
reg                     i_t_rerror_nxt;

// AHB transaction return response signals
//
wire                    i_okay_rsp_a;
wire                    i_err_rsp_a;
wire                    i_retry_rsp_a;
wire                    i_retry_a; // not qualified with hready

// Asserted if a bvci write command
//
wire                    i_bvci_write_a;

// Signals to detect the next sequential AHB address value and
// if a wrapped burst is re-started
//
wire [10:0]             i_addr_inc_a;
wire                    i_wrap_restart_a;

// Signals to indicate if the next address from various sources
// to go on the bus is non-sequential to the last address
//
wire                    i_bvci_nseq_a;
wire                    i_top_nseq_a;
wire                    i_old_nseq_a;

// The write data lags one cycle behind the write address
// and control signals
//
reg  [C_DATA_WIDTH-1:0] i_hwdata_lagged_r;

// Registers and wires for converting single cell BVCI writes to 
// one to four AHB single cell writes
//
wire [1:0]              i_num_lo_wr_a;
wire [2:0]              i_num_ahb_wr_a;
wire [2:0]              i_outstanding_a;
wire [1:0]              i_outstand_wr_a;
reg  [1:0]              i_outstand_wr_r;
reg  [1:0]              i_outstand_wr_nxt;
wire [1:0]              i_outstand_wr_minus1_a;
reg                     i_null_byte_r;
reg                     i_null_byte_nxt;
wire [1:0]              i_1st_id_sz_a;
wire [2:0]              i_1st_wr_sz_a;
wire [1:0]              i_1st_wr_off_a;
wire [1:0]              i_2nd_id_sz_a;
wire [1:0]              i_2nd_wr_sz_a;
reg  [1:0]              i_2nd_wr_sz_r;
reg  [1:0]              i_2nd_wr_sz_nxt;
wire [1:0]              i_2nd_wr_off_a;
reg  [1:0]              i_2nd_wr_off_r;
reg  [1:0]              i_2nd_wr_off_nxt;
reg                     i_byte_split_r;
reg                     i_byte_split_nxt;


// Wires for detecting 1K byte boundary crossing - illegal in AHB
// but allowed in BVCI - the BVCI burst is split
//
wire   [8:0]            i_brst_end_addr_a;
wire                    i_1k_bnd_cross_a;
reg                     i_1k_sbrst_r;
reg                     i_1k_sbrst_nxt;

// Wires and registers to implement the Response buffer
wire                    b_t_cmdval;
wire                    b_t_cmdack;
wire                    b_t_rspval;
wire                    b_t_reop;
wire                    b_t_rerror;
wire [C_DATA_WIDTH-1:0] b_t_rdata;

wire [FIFO_WIDTH - 1:0] fifo_in_a;     //  input to fifo
wire                    fifo_ld_a;     //  load fifo
wire                    fifo_unld_a;   //  unload fifo
reg                     fifo_empty_r;  //  fifo empty status bit
reg                     fifo_full_r;   //  fifo full status bit
wire [FIFO_WIDTH - 1:0] fifo_out_a;    //  fifo output

reg  [((FIFO_DEPTH * FIFO_WIDTH) - 1):0] fifo_regs_r;  // array of fifo regs
reg  [FIFO_PTR_WIDTH - 1:0] fifo_wr_ptr_ctr_r;  // counter for write ptr
wire [FIFO_PTR_WIDTH - 1:0] fifo_wr_ptr;        // write pointer
reg                     cmd_pass_r;
integer                 ilp; 
integer                 jlp; 
integer                 klp;

// Function to determine the number of AHB writes for 32 bit of a 
// single cell BVCI write
//
function [1:0] num_ahb32_wr;
input [3:0] be;
  begin
  case (be)
    4'b 0000: num_ahb32_wr = 2'b 00;
    4'b 0001,
    4'b 0010,
    4'b 0100,
    4'b 1000,
    4'b 0011,
    4'b 1100,
    4'b 1111: num_ahb32_wr = 2'b 01;
    default : num_ahb32_wr = 2'b 10;
  endcase
  end
endfunction

// Function to determine the size of the first AHB write resulting
// from a single cell BVCI write
//
function [1:0] size_1st_wr;
input [3:0] be;
  begin
  case (be)
    4'b 0000: size_1st_wr = SGL_0_BYTE;
    4'b 1111: size_1st_wr = SGL_4_BYTE;
    4'b 0011,
    4'b 1100,
    4'b 1011,
    4'b 0111: size_1st_wr = SGL_2_BYTE;
    default:  size_1st_wr = SGL_1_BYTE;
  endcase
  end
endfunction

// Function to determine the size of the second AHB write 
// resulting from a single cell BVCI write
//
function [1:0] size_2nd_wr;
input [3:0] be;
  begin
  case (be)
    4'b 1101,
    4'b 1110: size_2nd_wr = SGL_2_BYTE;
    4'b 0101,
    4'b 0110,
    4'b 0111,
    4'b 1001,
    4'b 1010,
    4'b 1011: size_2nd_wr = SGL_1_BYTE;
    default:  size_2nd_wr = SGL_0_BYTE;
  endcase
  end
endfunction

// Function to determine the offset of the first AHB write 
// resulting from a single cell BVCI write
//
function [1:0] off_1st_wr;
input [3:0] be;
  begin
  case (be)
  4'b 0010,
  4'b 0110,
  4'b 1010,
  4'b 1110: off_1st_wr = 2'b 01;
  4'b 0100,
  4'b 1100: off_1st_wr = 2'b 10;
  4'b 1000: off_1st_wr = 2'b 11;
  default:  off_1st_wr = 2'b 00;
  endcase
  end
endfunction

// Function to determine the offset of the second AHB write 
// resulting from a single cell BVCI write
//
function [1:0] off_2nd_wr;
input [3:0] be;
  begin
  case (be)
  4'b 0101,
  4'b 0110,
  4'b 0111,
  4'b 1101,
  4'b 1110: off_2nd_wr = 2'b 10;
  4'b 1001,
  4'b 1010,
  4'b 1011: off_2nd_wr = 2'b 11;
  default:  off_2nd_wr = 2'b 00;
  endcase
  end
endfunction



// function to convert internal size encoding to AHB HSIZE
//
function [2:0] to_ahb_size;
input [2:0] size;
  begin
  case (size)
    {1'b 0, SGL_1_BYTE}: to_ahb_size = AHB_SIZE_8;
    {1'b 0, SGL_2_BYTE}: to_ahb_size = AHB_SIZE_16;
    {1'b 0, SGL_4_BYTE}: to_ahb_size = AHB_SIZE_32;
    default:             to_ahb_size = AHB_SIZE_64;
  endcase
  end
endfunction

// function to evaluate the size of AHB read access
//
function [2:0] ahb_read_size;
input [8:0] plen;
input [1:0] offset;
  begin
  case (plen)
    9'b 000000001: ahb_read_size = AHB_SIZE_8;
    9'b 000000010:
      case (offset)
        2'b 00,
        2'b 10:  ahb_read_size = AHB_SIZE_16;
        default: ahb_read_size = AHB_SIZE_32;
      endcase
    default: ahb_read_size = AHB_SIZE_32;
  endcase
  end
endfunction

// function to evaluate the offset of AHB read access
//
function [1:0] ahb_read_offset;
input [8:0] plen;
input [1:0] offset;
  begin
  case (plen)
    9'b 000000001: ahb_read_offset = offset;
    9'b 000000010:
      case (offset)
        2'b 00,
        2'b 10:  ahb_read_offset = offset;
        default: ahb_read_offset = 2'b 00;
      endcase
    default: ahb_read_offset = 2'b 00;
  endcase
  end
endfunction

//  asynchronous part of FSM
//
always @(
  i_eop_top_r     or
  i_haddr_top_r   or
  i_hwdata_top_r  or
  i_eop_out_r     or
  i_haddr_out_r   or
  i_hwdata_out_r  or
  i_eop_old_r     or
  i_haddr_old_r   or
  i_hwdata_old_r  or
  i_t_rdata_r     or
  i_t_rerror_r    or
  i_last_r        or
  i_t_reop_r      or
  i_hsize_r       or
  i_hwrite_r      or
  i_hlock_r       or
  i_hprot_r       or  
  i_atomic_r      or
  i_htrans_r      or
  i_hburst_r      or
  i_hbusreq_r     or
  i_old_valid_r   or
  i_top_valid_r   or
  i_wrap_r        or
  i_restarted_r   or
  i_t_cmdack_r    or
  i_t_rspval_r    or
  i_1k_sbrst_r    or
  i_null_byte_r   or
  i_outstand_wr_r or
  i_2nd_wr_sz_r   or
  i_2nd_wr_off_r  or
  i_byte_split_r  or
  i_state_r       or
  t_priv          or
  t_mode          or
  t_cache         or
  t_buffer        or
  hgrant          or
  hready          or
  t_cmd           or
  t_eop           or
  t_plen          or
  i_t_rdata_a     or
  i_t_rerror_a    or
  i_haddr_a       or
  i_hwdata_a      or
  i_hburst_a      or
  i_bvci_cmd_a    or
  i_wrap_a        or
  i_bvci_nseq_a   or
  i_top_nseq_a    or
  i_old_nseq_a    or
  i_ahb_rsp_a     or
  i_ahb_grant_a   or
  i_retry_a       or
  i_retry_rsp_a   or
  i_bvci_write_a  or
  i_num_ahb_wr_a  or
  i_1st_wr_sz_a   or
  i_1st_wr_off_a  or
  i_2nd_wr_sz_a   or
  i_2nd_wr_off_a  or
  i_outstand_wr_a or
  i_outstand_wr_minus1_a)

  begin : ASYNC_FSM_PROC

  // keep current values unless explicitly updated later
  // in this block
  //
  i_eop_top_nxt     = i_eop_top_r;
  i_haddr_top_nxt   = i_haddr_top_r;
  i_hwdata_top_nxt  = i_hwdata_top_r;
  i_eop_out_nxt     = i_eop_out_r;
  i_haddr_out_nxt   = i_haddr_out_r;
  i_hwdata_out_nxt  = i_hwdata_out_r;
  i_eop_old_nxt     = i_eop_old_r;
  i_haddr_old_nxt   = i_haddr_old_r;
  i_hwdata_old_nxt  = i_hwdata_old_r;
  i_t_rdata_nxt     = i_t_rdata_r;
  i_t_rerror_nxt    = i_t_rerror_r;
  i_t_reop_nxt      = i_t_reop_r;
  i_last_nxt        = i_last_r;
  i_restarted_nxt   = i_restarted_r;
  i_wrap_nxt        = i_wrap_r;
  i_hsize_nxt       = i_hsize_r;
  i_hwrite_nxt      = i_hwrite_r;
  i_hlock_nxt       = i_hlock_r;
  i_atomic_nxt      = i_atomic_r;
  i_htrans_nxt      = i_htrans_r;
  i_hprot_nxt       = i_hprot_r;  
  i_hburst_nxt      = i_hburst_r;
  i_hbusreq_nxt     = i_hbusreq_r;
  i_old_valid_nxt   = i_old_valid_r;
  i_top_valid_nxt   = i_top_valid_r;
  i_t_cmdack_nxt    = i_t_cmdack_r;
  i_t_rspval_nxt    = i_t_rspval_r;
  i_1k_sbrst_nxt    = i_1k_sbrst_r;
  i_null_byte_nxt   = i_null_byte_r;
  i_outstand_wr_nxt = i_outstand_wr_r;
  i_2nd_wr_sz_nxt   = i_2nd_wr_sz_r;
  i_2nd_wr_off_nxt  = i_2nd_wr_off_r;
  i_byte_split_nxt  = i_byte_split_r;
  i_state_nxt       = i_state_r;

  case (i_state_r)

  // ---------- //
  // IDLE state //
  // ---------- //
  //
  // wait until there is a bvci cmd and if so register
  // the translated details of the transaction, put it on
  // the local AHB bus and request access to the slave AHB
  // bus. There are three sets of registers; "top" stores
  // any outstanding transactions that can not go on the AHB
  // bus immediately, "out" keeps the current transaction
  // that is on the AHB bus and "old" saves the previously
  // translated transaction that was on the AHB. When there
  // is a new BVCI command and no AHB response then the
  // new transaction will stored in "top". Whenever "out"
  // changes then its old value is stored in "old" to be
  // reused in case of an AHB retry.
  // Extension 1: check if any outstanding access remaining 
  // from the previous BVCI write access and if so handle 
  // then first.
  // 
  IDLE_STATE:
    begin
    if (i_outstand_wr_r == 2'b 0)
      begin
      i_byte_split_nxt = 1'b 0;
      if (i_bvci_cmd_a == 1'b 1)
        begin
	  i_hprot_nxt = {t_cache, t_buffer, t_priv, t_mode};
        if (t_eop == 1'b 1)
          begin
          i_hburst_nxt = AHB_SNGL_ACC;
          end
        else
          begin
          i_hburst_nxt = i_hburst_a;
          end
        if (t_cmd == BVCI_LR_CMD)
          begin
          i_hlock_nxt  = 1'b 1;
          i_atomic_nxt = 1'b 1;
          end
        i_eop_out_nxt    = t_eop;        //  out <- BVCI
        i_hwdata_out_nxt = i_hwdata_a;   //  out <- BVCI
        i_hwrite_nxt     = i_bvci_write_a;
        i_t_cmdack_nxt   = 1'b 0;
        i_1k_sbrst_nxt   = i_haddr_a[10];// starting addr bit 10
        if (i_bvci_write_a == 1'b 1)
          begin
          if (i_num_ahb_wr_a == 3'b 0)
            begin
            i_hbusreq_nxt     = 1'b 0;
            i_haddr_out_nxt   = i_haddr_a;  //  out <- BVCI
            i_null_byte_nxt   = 1'b 1;
            i_outstand_wr_nxt = 2'b 0;
            i_state_nxt       = LAST_STATE;            
            end
          else
            begin
            i_hbusreq_nxt     = 1'b 1;
            i_haddr_out_nxt   = {i_haddr_a[31:2],i_1st_wr_off_a}; //  out <- BVCI
            i_hsize_nxt       = to_ahb_size(i_1st_wr_sz_a);
            i_2nd_wr_sz_nxt   = i_2nd_wr_sz_a;
            i_2nd_wr_off_nxt  = i_2nd_wr_off_a;
            i_outstand_wr_nxt = i_outstand_wr_a;
            i_byte_split_nxt  = i_outstand_wr_a != 2'b 0; 
            i_state_nxt       = GRNT_STATE;
            end
          end
        else
          begin
          i_haddr_out_nxt   = {i_haddr_a[31:2],         //  out <- BVCI
                               ahb_read_offset(t_plen, i_haddr_a[1:0])};  
          i_hsize_nxt       =    ahb_read_size(t_plen, i_haddr_a[1:0]);
          i_hbusreq_nxt     = 1'b 1;
          i_outstand_wr_nxt = SGL_0_AHB;
          i_state_nxt       = GRNT_STATE;
          end
        end
      else
        begin
        i_hbusreq_nxt   = i_hlock_r;
        i_last_nxt      = 1'b 0;
        i_t_reop_nxt    = 1'b 0;
        i_t_cmdack_nxt  = 1'b 1;
        i_old_valid_nxt = 1'b 0;
        i_top_valid_nxt = 1'b 0;
        i_t_rspval_nxt  = 1'b 0;
        i_t_rerror_nxt  = 1'b 0;
        end
      end
    else // if there are outstanding writes
      begin
      i_outstand_wr_nxt = i_outstand_wr_minus1_a;
      if (i_2nd_wr_sz_r != 2'b 0)
        begin
        i_hsize_nxt     = to_ahb_size(i_2nd_wr_sz_r);
        i_haddr_out_nxt = {i_haddr_out_r[31:2], i_2nd_wr_off_r};
        i_2nd_wr_sz_nxt = 2'b 0;
        end
      i_hburst_nxt   = AHB_SNGL_ACC;
      i_hwrite_nxt   = 1'b 1;
      i_hbusreq_nxt  = 1'b 1;
      i_eop_out_nxt  = 1'b 1;
      i_t_cmdack_nxt = 1'b 0;
      i_state_nxt    = GRNT_STATE;
      end
    i_htrans_nxt    = AHB_TRANS_IDLE;
    i_restarted_nxt = 1'b 0;
    i_wrap_nxt      = i_wrap_a;
    end // case: IDLE_STATE

  // ----------- //
  // GRANT state //
  // ----------- //
  //
  // wait until granted the bus and then start the first
  // non sequential transaction on AHB.
  //
  GRNT_STATE:
    begin
    if ((i_ahb_grant_a == 1'b 1) ||
        ((i_atomic_r   == 1'b 0) &&
         (i_hlock_r    == 1'b 1)))
      begin
      if (i_top_valid_r == 1'b 1)
        begin
        i_t_cmdack_nxt = 1'b 0;
        end
      else
        begin
        i_t_cmdack_nxt = ~i_eop_out_r;
        end
      i_htrans_nxt = AHB_TRANS_NSEQ;
      i_state_nxt  = INIT_STATE;
      if ((i_hburst_r != AHB_UNDF_BRST) &&
          (i_hlock_r  == 1'b 0))
        begin
        i_hbusreq_nxt = 1'b 0;
        end
      end
    else
      begin
      i_t_cmdack_nxt = 1'b 0;
      end
    i_t_rspval_nxt = 1'b 0;
    end // case: GRNT_STATE

  // --------------- //
  // INITIAL 0 state //
  // --------------- //
  //
  // if hready is high then for single accesses go to LAST
  // state else for bursts either put out the new BVCI 
  // command or put out the saved BVCI command. if grant
  // has gone low then go to TRMT state.
  // 
  INIT_STATE:
    begin
    if (hready == 1'b 1)
      begin
      if (i_eop_out_r == 1'b 1)
        begin
        i_hbusreq_nxt = i_hlock_r;
        i_last_nxt    = 1'b 1;
        i_htrans_nxt  = AHB_TRANS_IDLE;
        i_state_nxt   = LAST_STATE;
        end
      else
        begin
        if (i_bvci_cmd_a == 1'b 1)
          begin
          i_eop_out_nxt    = t_eop;      //  out <- BVCI
          i_haddr_out_nxt  = i_haddr_a;  //  out <- BVCI
          i_hwdata_out_nxt = i_hwdata_a; //  out <- BVCI
          i_t_cmdack_nxt   = ~t_eop;
          end
        else
          begin
          i_eop_out_nxt    = i_eop_top_r;    //  out <- top
          i_haddr_out_nxt  = i_haddr_top_r;  //  out <- top
          i_hwdata_out_nxt = i_hwdata_top_r; //  out <- top
          i_t_cmdack_nxt   = ~i_eop_top_r;
          i_top_valid_nxt  = 1'b 0;
          end
        i_eop_old_nxt    = i_eop_out_r;    //  old <- out
        i_haddr_old_nxt  = i_haddr_out_r;  //  old <- out
        i_hwdata_old_nxt = i_hwdata_out_r; //  old <- out
        i_old_valid_nxt  = 1'b 1;
        if ((hgrant == 1'b 0)                                     ||
            ((i_bvci_cmd_a == 1'b 1) && (i_bvci_nseq_a == 1'b 1)) ||
            ((i_bvci_cmd_a == 1'b 0) && (i_top_nseq_a  == 1'b 1)) )
          begin
          i_hbusreq_nxt   = 1'b 0;
          i_t_cmdack_nxt  = 1'b 0;
          i_htrans_nxt    = AHB_TRANS_IDLE;
          i_state_nxt     = TRMT_STATE;
          end
        else
          begin
          i_htrans_nxt = AHB_TRANS_SEQ;
          i_state_nxt  = ACKN_STATE;
          end
        end
      end
    else
      begin
      if (i_bvci_cmd_a == 1'b 1)
        begin
        i_eop_top_nxt    = t_eop;      //  top <- BVCI
        i_haddr_top_nxt  = i_haddr_a;  //  top <- BVCI
        i_hwdata_top_nxt = i_hwdata_a; //  top <- BVCI
        i_top_valid_nxt  = 1'b 1;
        end
      i_t_cmdack_nxt = 1'b 0;
      end
    end // case: INIT_STATE
     
  // --------------------- //
  // ACKNOWLEDGEMENT state //
  // --------------------- //
  //
  // if there is a retry response then start the RTY
  // sequence else if early burst termination then goto
  // the TRMT state. Else take suitable action depending
  // on whether there is a new bvci command or a new AHB
  // response. Note that if there is no AHB response and
  // grant has gone away then will go to TRMT via RSPS
  // state.
  //
  ACKN_STATE:
    begin
    if (i_retry_a == 1'b 1)
      begin
      if (i_bvci_cmd_a == 1'b 1)
        begin
        i_eop_top_nxt    = t_eop;      //  top <- BVCI
        i_haddr_top_nxt  = i_haddr_a;  //  top <- BVCI
        i_hwdata_top_nxt = i_hwdata_a; //  top <- BVCI
        i_top_valid_nxt  = 1'b 1;
        end
      i_hbusreq_nxt  = 1'b 0;
      i_t_cmdack_nxt = 1'b 0;
      i_t_rspval_nxt = 1'b 0;
      i_htrans_nxt   = AHB_TRANS_IDLE;
      i_state_nxt    = RTY0_STATE;
      end
    else // i_retry_a='0'
      begin
      if (i_ahb_rsp_a == 1'b 1)
        begin
        i_t_rdata_nxt  = i_t_rdata_a;
        i_t_rerror_nxt = i_t_rerror_a;
        if (i_bvci_cmd_a == 1'b 1)
          begin
          i_eop_out_nxt    = t_eop;          //  out <- BVCI
          i_haddr_out_nxt  = i_haddr_a;      //  out <- BVCI
          i_hwdata_out_nxt = i_hwdata_a;     //  out <- BVCI
          i_eop_old_nxt    = i_eop_out_r;    //  old <- out
          i_haddr_old_nxt  = i_haddr_out_r;  //  old <- out
          i_hwdata_old_nxt = i_hwdata_out_r; //  old <- out
          i_old_valid_nxt  = 1'b 1;
          end
        if ((hgrant == 1'b 0) ||
           ((i_bvci_cmd_a == 1'b 1) && (i_bvci_nseq_a == 1'b 1)))
          begin
          if (i_bvci_cmd_a == 1'b 0)
            begin
            i_last_nxt = i_eop_out_r;
            end
          i_hbusreq_nxt   = 1'b 0;
          i_t_cmdack_nxt  = 1'b 0;
          i_htrans_nxt    = AHB_TRANS_IDLE;
          i_state_nxt     = TRMT_STATE;
          end
        else //  hgrant='1'
          begin
          if (i_bvci_cmd_a == 1'b 1)
            begin
            i_t_cmdack_nxt = ~t_eop;
            i_state_nxt = ACKN_STATE;
            end
          else //  i_bvci_cmd_a='0'
            begin
            if (i_eop_out_r == 1'b 1)
              begin
              i_hbusreq_nxt = 1'b 0;
              i_last_nxt    = 1'b 1;
              i_htrans_nxt  = AHB_TRANS_IDLE;
              i_state_nxt   = LAST_STATE;
              end
            else
              begin
              i_state_nxt = ACKN_STATE;
              end
            i_t_cmdack_nxt = 1'b 0;
            end
          end
        end
      else //  i_ahb_rsp_a=0
        begin
        if (i_bvci_cmd_a == 1'b 1)
          begin
          i_eop_top_nxt    = t_eop;      //  top <- BVCI
          i_haddr_top_nxt  = i_haddr_a;  //  top <- BVCI
          i_hwdata_top_nxt = i_hwdata_a; //  top <- BVCI
          i_top_valid_nxt  = 1'b 1;
          end
        if (hgrant == 1'b 0)
          begin
          i_hbusreq_nxt  = 1'b 0;
          i_t_cmdack_nxt = 1'b 0;
          i_state_nxt    = RSPS_STATE;
          end
        else //  hgrant='1'
          begin
          if (i_bvci_cmd_a == 1'b 1)
            begin
            i_t_cmdack_nxt = 1'b 0;
            i_state_nxt    = WAIT_STATE;
            end
          else //  i_bvci_cmd_a='0'
            begin
            i_t_cmdack_nxt = ~i_eop_out_r;
            end
          end
        end

        i_t_rspval_nxt = i_ahb_rsp_a;
      end
    end // case: ACKN_STATE

  // ---------- //
  // WAIT STATE //
  // ---------- //
  //
  //  if there is a retry response then start the RTY
  //  sequence. if early bus termination then goto 
  //  TRMT state, else wait until receive AHB response
  //  and go back to ACKN state. Note that if there is no
  //  AHB response and grant has gone away then will go
  //  to TRMT via RSPS state.
  // 
  WAIT_STATE:
    begin
    if (i_retry_a == 1'b 1)
      begin
      i_hbusreq_nxt = 1'b 0;
      i_htrans_nxt  = AHB_TRANS_IDLE;
      i_state_nxt   = RTY0_STATE;
      end
    else //  i_retry_a='0'
      begin
      if (i_ahb_rsp_a == 1'b 1)
        begin
        i_eop_out_nxt    = i_eop_top_r;    //  out <- top
        i_haddr_out_nxt  = i_haddr_top_r;  //  out <- top
        i_hwdata_out_nxt = i_hwdata_top_r; //  out <- top
        i_eop_old_nxt    = i_eop_out_r;    //  old <- out
        i_haddr_old_nxt  = i_haddr_out_r;  //  old <- out
        i_hwdata_old_nxt = i_hwdata_out_r; //  old <- out
        i_old_valid_nxt  = 1'b 1;
        i_top_valid_nxt  = 1'b 0;
        i_t_rdata_nxt    = i_t_rdata_a;
        i_t_rerror_nxt   = i_t_rerror_a;
        if ((hgrant == 1'b 0) || (i_top_nseq_a == 1'b 1))
          begin
          i_hbusreq_nxt   = 1'b 0;
          i_t_cmdack_nxt  = 1'b 0;
          i_htrans_nxt    = AHB_TRANS_IDLE;
          i_state_nxt     = TRMT_STATE;
          end
        else //  hgrant='1'
          begin
          i_t_cmdack_nxt = ~i_eop_top_r;
          i_state_nxt = ACKN_STATE;
          end
        end
      else
        begin
        if (hgrant == 1'b 0)
          begin
          i_hbusreq_nxt = 1'b 0;
          i_state_nxt = RSPS_STATE;
          end
        end
      i_t_rspval_nxt = i_ahb_rsp_a;
      end
    end // case: WAIT_STATE

  // ---------- //
  // LAST STATE //
  // ---------- //
  //
  // if there is a retry response then start the retry
  // sequence else for either single accesses or bursts
  // wait for the final response before going back to  
  // the IDLE state.
  // Extension 1: Do not signal the end of BVCI response
  // if there are outstanding AHB access remaining from the
  // current BVCI access
  //
  LAST_STATE:
    begin
    if (i_null_byte_r == 1'b 1)
      begin
      i_t_reop_nxt    = 1'b 1;
      i_t_rspval_nxt  = 1'b 1;
      i_t_rerror_nxt  = 1'b 0;
      i_null_byte_nxt = 1'b 0;
      i_state_nxt     = IDLE_STATE;
      end
    else
      begin
      if (i_retry_a == 1'b 1)
        begin
        i_hbusreq_nxt  = i_hlock_r;
        i_t_rspval_nxt = 1'b 0;
        i_htrans_nxt   = AHB_TRANS_IDLE;
        i_state_nxt    = RTY0_STATE;
        end
      else //  i_retry_a='0'
        begin
        if (i_ahb_rsp_a == 1'b 1)
          begin
          if (i_atomic_r == 1'b 1)
            begin
            i_atomic_nxt  = 1'b 0;
            end
          else
            begin
            i_hbusreq_nxt = 1'b 0;
            if (i_outstand_wr_r == 2'b 0)
              begin
              if (i_hlock_r == 1'b 1)
                begin
                i_hlock_nxt = 1'b 0;
                end
              end
            end
          if (i_outstand_wr_r == 2'b 0)
            begin
            i_t_reop_nxt   = i_eop_out_r;
            i_t_rspval_nxt = 1'b 1;
            end
          else
            begin
            i_t_reop_nxt   = 1'b 0;
            i_t_rspval_nxt = 1'b 0;
            end
          if (i_byte_split_r == 1'b 0)
            begin
            i_t_rerror_nxt = i_t_rerror_a;
            end
          else
            begin
            i_t_rerror_nxt = i_t_rerror_a | i_t_rerror_r;
            end
          i_t_rdata_nxt  = i_t_rdata_a;
          i_state_nxt    = IDLE_STATE;
          end
        else
          begin
          i_t_rspval_nxt = 1'b 0;  
          end
        end
      end
    end // case: LAST_STATE

  // ------------- //
  // RETRY 0 state //
  // ------------- //
  //
  // wait for the slave retry response final cycle before
  // swapping "old" and "out" buffers (if necessary) and
  // re-requesting the bus.
  //  
  RTY0_STATE:
    begin
    i_restarted_nxt = 1'b 1;
    if (i_retry_rsp_a == 1'b 1)
      begin
      if ((i_old_valid_r == 1'b 1) && (i_last_r == 1'b 0))
        begin
        i_eop_out_nxt    = i_eop_old_r;    //  out <- old
        i_haddr_out_nxt  = i_haddr_old_r;  //  out <- old
        i_hwdata_out_nxt = i_hwdata_old_r; //  out <- old
        i_eop_old_nxt    = i_eop_out_r;    //  old <- out
        i_haddr_old_nxt  = i_haddr_out_r;  //  old <- out
        i_hwdata_old_nxt = i_hwdata_out_r; //  old <- out
        end
      if (i_hburst_r != AHB_SNGL_ACC)
        begin
        i_hburst_nxt = AHB_UNDF_BRST;
        end
      i_hbusreq_nxt = 1'b 1;
      i_state_nxt   = RTY1_STATE;
      end
    end // case: RTY0_STATE

  // ------------- //
  // RETRY 1 state //
  // ------------- //
  //
  // wait until re-granted the bus and start the 
  // re-try transfer before moving to the final retry 
  // sequence state.
  // 
  RTY1_STATE:
    begin
    if (i_ahb_grant_a == 1'b 1)
      begin
      i_htrans_nxt = AHB_TRANS_NSEQ;
      i_state_nxt  = RTY2_STATE;
      end
    end

  // ------------- //
  // RETRY 2 state //
  // ------------- //
  //
  // if single access then goto LAST state else swap "old"
  // and "out" buffers (if necessary). if there is an 
  // outstanding transaction in "top" the go the WAIT else
  // to ACKN state. If grant has gone away then go to TRMT
  // state.
  //
  RTY2_STATE:
    begin
    if (hready == 1'b 1)
      begin
      if (i_last_r == 1'b 1)
        begin
        i_hbusreq_nxt = i_hlock_r;   
        i_htrans_nxt  = AHB_TRANS_IDLE;   
        i_state_nxt   = LAST_STATE;   
        end
      else
        begin
        i_eop_out_nxt    = i_eop_old_r;    //  out <- old
        i_haddr_out_nxt  = i_haddr_old_r;  //  out <- old
        i_hwdata_out_nxt = i_hwdata_old_r; //  out <- old
        i_eop_old_nxt    = i_eop_out_r;    //  old <- out
        i_haddr_old_nxt  = i_haddr_out_r;  //  old <- out
        i_hwdata_old_nxt = i_hwdata_out_r; //  old <- out
        i_old_valid_nxt   = 1'b 1;
        if ((hgrant == 1'b 0) || (i_old_nseq_a == 1'b 1))
          begin
          i_hbusreq_nxt   = 1'b 0;
          i_htrans_nxt    = AHB_TRANS_IDLE;   
          i_state_nxt     = TRMT_STATE;   
          end
        else //  hgrant='1'
          begin
          i_htrans_nxt = AHB_TRANS_SEQ;   
          if (i_top_valid_r == 1'b 1)
            begin
            i_t_cmdack_nxt = 1'b 0;   
            i_state_nxt    = WAIT_STATE;   
            end
          else
            begin
            i_t_cmdack_nxt = ~i_eop_old_r;   
            i_state_nxt    = ACKN_STATE;   
            end
          end
        end
      end
    end // case: RTY2_STATE

  // -------------- //
  // RESPONSE state //
  // -------------- //
  //
  // Start a retry sequence if there is a retry response
  // else wait for response for the previous access before 
  // moving to TRMT state.
  //
  RSPS_STATE:
    begin
    if (i_retry_a == 1'b 1)
      begin
      i_htrans_nxt = AHB_TRANS_IDLE;  
      i_state_nxt = RTY0_STATE;
      end
    else
      begin
      if (i_ahb_rsp_a == 1'b 1)
        begin
        if (i_top_valid_r == 1'b 1)
          begin
          i_eop_out_nxt    = i_eop_top_r;    //  out <- top
          i_haddr_out_nxt  = i_haddr_top_r;  //  out <- top
          i_hwdata_out_nxt = i_hwdata_top_r; //  out <- top
          i_eop_old_nxt    = i_eop_out_r;    //  old <- out
          i_haddr_old_nxt  = i_haddr_out_r;  //  old <- out
          i_hwdata_old_nxt = i_hwdata_out_r; //  old <- out
          i_old_valid_nxt  = 1'b 1;   
          i_top_valid_nxt  = 1'b 0;   
          end
        else
          begin
          i_old_valid_nxt = 1'b 0;
          i_last_nxt      = i_eop_out_r;
          end
        i_t_rdata_nxt   = i_t_rdata_a;
        i_t_rerror_nxt  = i_t_rerror_a;
        i_t_rspval_nxt  = 1'b 1;
        i_t_cmdack_nxt  = 1'b 0;
        i_htrans_nxt    = AHB_TRANS_IDLE;
        i_state_nxt     = TRMT_STATE;
        end
      end
    end // case: RSPS_STATE

  // -------------------- //
  // BUS TERMINATED state //
  // -------------------- //
  //
  // if retry then start a retry sequence else wait for
  // a response and move to IDLE if it was the last state
  // else re-request the bus and move to GRNT state. Note
  // that if a retry then that means the previous access 
  // did not go through so the sequence of events would 
  // be identical to a normal retry sequence.
  //
  TRMT_STATE:
    begin
    i_restarted_nxt = 1'b 1;
    if (i_retry_a == 1'b 1)
      begin
      i_t_rspval_nxt = 1'b 0;
      i_htrans_nxt   = AHB_TRANS_IDLE;
      i_state_nxt    = RTY0_STATE;
      end
    else
      begin
      if (i_ahb_rsp_a == 1'b 1)
        begin
        i_t_rdata_nxt   = i_t_rdata_a;
        i_t_rerror_nxt  = i_t_rerror_a;
        i_old_valid_nxt = 1'b 0;
        if (i_last_r == 1'b 1)
          begin
          i_t_reop_nxt = 1'b 1;
          i_state_nxt  = IDLE_STATE;
          end
        else
          begin
          if (i_hburst_r != AHB_SNGL_ACC)
            begin
            i_hburst_nxt = AHB_UNDF_BRST;
            end
          i_hbusreq_nxt = 1'b 1;
          i_state_nxt   = GRNT_STATE;
          end
        end
      i_t_rspval_nxt = i_ahb_rsp_a;
      end
    end // case: TRMT_STATE

  // ------------- //
  // default state //
  // ------------- //
  //
  default:
    begin
    i_t_rerror_nxt = 1'b 1;
    i_state_nxt    = IDLE_STATE;
    end

  endcase
  end // block: ASYNC_FSM_PROC
   
// synchronous part of FSM
//
always @(posedge hclk or negedge hresetn)
  begin : SYNC_FSM_PROC
  if (hresetn == 1'b 0)
    begin
    i_eop_top_r     <= 1'b 0;
    i_haddr_top_r   <= {32 {1'b 0}};
    i_hwdata_top_r  <= {(C_DATA_WIDTH){1'b 0}};
    i_eop_out_r     <= 1'b 0;
    i_haddr_out_r   <= {32 {1'b 0}};
    i_hwdata_out_r  <= {(C_DATA_WIDTH){1'b 0}};
    i_eop_old_r     <= 1'b 0;
    i_haddr_old_r   <= {32 {1'b 0}};
    i_hwdata_old_r  <= {(C_DATA_WIDTH){1'b 0}};
    i_t_rerror_r    <= 1'b 0;
    i_t_rdata_r     <= {(C_DATA_WIDTH){1'b 0}};
    i_t_reop_r      <= 1'b 0;
    i_last_r        <= 1'b 0;
    i_restarted_r   <= 1'b 0;
    i_wrap_r        <= 1'b 0;
    i_hsize_r       <= 3'b 000;
    i_hwrite_r      <= 1'b 0;
    i_hlock_r       <= 1'b 0;
    i_hprot_r       <= 4'b 0000;
    i_atomic_r      <= 1'b 0;
    i_htrans_r      <= 2'b 00;
    i_hburst_r      <= 3'b 000;
    i_hbusreq_r     <= 1'b 0;
    i_old_valid_r   <= 1'b 0;
    i_top_valid_r   <= 1'b 0;
    i_t_cmdack_r    <= 1'b 0;
    i_t_rspval_r    <= 1'b 0;
    i_1k_sbrst_r    <= 1'b 0;
    i_null_byte_r   <= 1'b 0;
    i_outstand_wr_r <= 2'b 00;
    i_2nd_wr_sz_r   <= 2'b 00;
    i_2nd_wr_off_r  <= 2'b 00;
    i_byte_split_r  <= 1'b 0;
    i_state_r       <= IDLE_STATE;   
    end
  else
    begin
    //  update the FSM flipflops with new values from
    //  the async part of FSM.
    //
    i_eop_top_r     <= i_eop_top_nxt;
    i_haddr_top_r   <= i_haddr_top_nxt;
    i_hwdata_top_r  <= i_hwdata_top_nxt;
    i_eop_out_r     <= i_eop_out_nxt;
    i_haddr_out_r   <= i_haddr_out_nxt;
    i_hwdata_out_r  <= i_hwdata_out_nxt;
    i_eop_old_r     <= i_eop_old_nxt;
    i_haddr_old_r   <= i_haddr_old_nxt;
    i_hwdata_old_r  <= i_hwdata_old_nxt;
    i_t_rdata_r     <= i_t_rdata_nxt;
    i_t_rerror_r    <= i_t_rerror_nxt;
    i_t_reop_r      <= i_t_reop_nxt;
    i_last_r        <= i_last_nxt;
    i_restarted_r   <= i_restarted_nxt;
    i_wrap_r        <= i_wrap_nxt;
    i_hsize_r       <= i_hsize_nxt;
    i_hwrite_r      <= i_hwrite_nxt;
    i_hlock_r       <= i_hlock_nxt;
    i_hprot_r       <= i_hprot_nxt;
    i_atomic_r      <= i_atomic_nxt;
    i_htrans_r      <= i_htrans_nxt;
    i_hburst_r      <= i_hburst_nxt;
    i_hbusreq_r     <= i_hbusreq_nxt;
    i_old_valid_r   <= i_old_valid_nxt;
    i_top_valid_r   <= i_top_valid_nxt;
    i_t_cmdack_r    <= i_t_cmdack_nxt;
    i_t_rspval_r    <= i_t_rspval_nxt;
    i_1k_sbrst_r    <= i_1k_sbrst_nxt;
    i_null_byte_r   <= i_null_byte_nxt;
    i_outstand_wr_r <= i_outstand_wr_nxt;
    i_2nd_wr_sz_r   <= i_2nd_wr_sz_nxt;
    i_2nd_wr_off_r  <= i_2nd_wr_off_nxt;
    i_byte_split_r  <= i_byte_split_nxt;
    i_state_r       <= i_state_nxt;
    end
  end // block: SYNC_FSM_PROC

// --------------------------------------------- //
// register process to ensure that the data lags //
// one cycle behind the the write address and    //
// controll signals                              //
// --------------------------------------------- //
//
always @(posedge hclk or negedge hresetn)
  begin : WDATA_LAG_PROC
  if (hresetn == 1'b 0)
    begin
    i_hwdata_lagged_r <= {(C_DATA_WIDTH){1'b 0}};
    end
  else
    begin
    if (hready == 1'b 1)
      begin
      i_hwdata_lagged_r <= i_hwdata_out_r;
      end
    end
  end // block: WDATA_LAG_PROC

// ---------------------- //
// control/output signals //
// ---------------------- //

// Evaluate the number of AHB writes for the BVCI single cell 
// write and work out their sizes and offsets
//
assign i_num_lo_wr_a  = num_ahb32_wr (t_be[3:0]);
assign i_1st_id_sz_a  = size_1st_wr  (t_be[3:0]);
assign i_2nd_id_sz_a  = size_2nd_wr  (t_be[3:0]);
assign i_1st_wr_off_a = off_1st_wr   (t_be[3:0]);
assign i_2nd_wr_off_a = off_2nd_wr   (t_be[3:0]);

assign i_num_ahb_wr_a = {1'b 0, i_num_lo_wr_a};
assign i_1st_wr_sz_a  = (i_1st_id_sz_a == 2'b 00) ? 
                        {1'b 0, i_2nd_id_sz_a}:
                        {1'b 0, i_1st_id_sz_a};
assign i_2nd_wr_sz_a  =  (i_1st_id_sz_a == 2'b 00)  ? 2'b 00:
                        i_2nd_id_sz_a;

assign i_outstanding_a = i_num_ahb_wr_a - 3'b 1;
assign i_outstand_wr_a = i_outstanding_a[1:0];
assign i_outstand_wr_minus1_a = i_outstand_wr_r - 2'b 1;

//  BVCI input/output signal synchronization
//
assign i_t_cmdval_sync = b_t_cmdval & sync_r;

//  FSM control input signals
//
assign i_okay_rsp_a  = (hresp == AHB_RSP_OKAY) ? 1'b 1 : 1'b 0; 
assign i_err_rsp_a   = (hresp == AHB_RSP_ERR ) ? 1'b 1 : 1'b 0; 
assign i_retry_rsp_a = ((hready == 1'b 1) && 
                        ((hresp == AHB_RSP_SPLIT) || 
                         (hresp == AHB_RSP_RETRY))) ? 
                       1'b 1 : 1'b 0;
 
assign i_retry_a     = ((hresp == AHB_RSP_SPLIT) ||
                        (hresp == AHB_RSP_RETRY)) 
                       ? 1'b 1 : 1'b 0;

assign i_bvci_cmd_a   = i_t_cmdval_sync & i_t_cmdack_r;
assign i_bvci_write_a = (t_cmd == BVCI_WR_CMD) ? 1'b 1 : 1'b 0;
assign i_ahb_grant_a  = hgrant & hready;
assign i_ahb_rsp_a    = hready & (i_okay_rsp_a | i_err_rsp_a);

//  BVCI to AHB signal mapping
//
assign i_hprot_a  = AHB_PROT_NNPD;
assign i_hwdata_a = t_wdata;

// assign ahb address and clear unused address bits
//
always @(t_address)
   begin : ADDR_ASSIGN_PROC
   i_haddr_a[EXT_A_MSB:0] = t_address[EXT_A_MSB:0];   
   for (klp = 31; klp > EXT_A_MSB; klp = klp - 1)
     begin
     i_haddr_a[klp] = 1'b 0;   
     end
   end

// map BVCI PLEN signal to AHB HBUSRT signal
//
always @(t_plen or t_address or i_1k_bnd_cross_a)
  begin : AHB_BURST_PROC
  if (i_1k_bnd_cross_a == 1'b 1)
    begin
    i_hburst_a = AHB_UNDF_BRST;
    end
  else
    begin
    case (t_plen)
      9'b 000010000: 
        begin 
        i_hburst_a = AHB_INCR4_BRST;
        end
      9'b 000100000: 
        begin 
        i_hburst_a = AHB_INCR8_BRST;
        end
      9'b 001000000: 
        begin 
        i_hburst_a = AHB_INCR16_BRST; 
        end
      default:       
        begin 
        i_hburst_a = AHB_UNDF_BRST;
        end
    endcase
    end
  end // block: AHB_BURST_PROC

assign i_brst_end_addr_a = i_haddr_a[10:2]+({2'b 0, t_plen[8:2]}-9'b 1);
assign i_1k_bnd_cross_a  = i_haddr_a[10] != i_brst_end_addr_a[8];
assign i_addr_inc_a      = {(i_haddr_out_r [10:2] + 9'b 1), 2'b 00};

assign i_wrap_a         = ((i_hburst_a == AHB_WRAP4_BRST) ||
                           (i_hburst_a == AHB_WRAP8_BRST) ||
                           (i_hburst_a == AHB_WRAP16_BRST))
                           ? 1'b 1 : 1'b 0;

assign i_wrap_restart_a = i_wrap_r & i_restarted_r;

assign i_bvci_nseq_a    = (((i_addr_inc_a[6:0] != i_haddr_a[6:0]) &&
                            (i_wrap_restart_a  == 1'b 1))          ||
                           (i_1k_sbrst_r       != i_haddr_a[10]))
                          ? 1'b 1 : 1'b 0;
assign i_top_nseq_a     = (((i_addr_inc_a[6:0] != i_haddr_top_r[6:0]) &&
                            (i_wrap_restart_a  == 1'b 1))             ||
                           (i_1k_sbrst_r       != i_haddr_top_r[10]))
                          ? 1'b 1 : 1'b 0;
assign i_old_nseq_a     = (((i_addr_inc_a[6:0] != i_haddr_old_r[6:0]) &&
                            (i_wrap_restart_a  == 1'b 1))             ||
                           (i_1k_sbrst_r       != i_haddr_old_r[10]))
                          ? 1'b 1 : 1'b 0;

//  AHB to BVCI signal mapping
//
assign i_t_rdata_a  = hrdata; 
assign i_t_rerror_a = i_err_rsp_a;

//  BVCI target outputs
//
assign b_t_cmdack = i_t_cmdack_r & sync_r;
assign b_t_rspval = i_t_rspval_r & sync_r;
assign b_t_reop   = i_t_reop_r   & sync_r;
assign b_t_rerror = i_t_rerror_r & sync_r;
assign b_t_rdata  = i_t_rdata_r;

//  AHB master outputs
//
assign haddr    = i_haddr_out_r;
assign hwdata   = i_hwdata_lagged_r;
assign hsize    = i_hsize_r;
assign hwrite   = i_hwrite_r;
assign hburst   = i_hburst_r;
assign htrans   = i_htrans_r;
assign hbusreq  = i_hbusreq_r;
assign hlock    = i_hlock_r;
//assign hprot    = i_hprot_a; //  constant
assign hprot    = i_hprot_r; //  constant

//  bridge busy when FSM not in idle state
//
assign busy = ((i_state_r    == IDLE_STATE) &&
               (i_outstand_wr_r == 2'b 00 ) &&
               (i_bvci_cmd_a == 1'b 0     ) &&
               (fifo_empty_r == 1'b 1     ) &&
               (i_t_rspval_r == 1'b 0     )) ? 1'b 0 : 1'b 1; 

// -----------------------------------------------------------------------------
// Buffer to deal with rsp_ack issue
// -----------------------------------------------------------------------------

  // ---- Registers ------------------------------------------------------------

  always @(posedge iclk or posedge rst_a)
  begin
    if (rst_a == 1'b1)
    begin
      cmd_pass_r        <= 1'b0;
      fifo_wr_ptr_ctr_r <= {(FIFO_PTR_WIDTH){1'b0}};
      fifo_full_r       <= 1'b0;
      fifo_empty_r      <= 1'b1;
      for (ilp = FIFO_DEPTH - 1; ilp >= 0; ilp = ilp - 1)
        for (jlp = FIFO_WIDTH - 1; jlp >= 0; jlp = jlp - 1)
          fifo_regs_r[(ilp * FIFO_WIDTH) + jlp] <= 1'b 0;   
    end
    else
    begin

      // unload fifo
      if ((fifo_unld_a == 1'b1)&&(fifo_empty_r == 1'b0))
      begin
        for (ilp = FIFO_DEPTH - 2; ilp >= 0; ilp = ilp - 1)
          for (jlp = FIFO_WIDTH - 1; jlp >= 0; jlp = jlp - 1)
            fifo_regs_r[(ilp*FIFO_WIDTH)+jlp] 
              <= fifo_regs_r[(ilp*FIFO_WIDTH)+FIFO_WIDTH+jlp];
      end
      
      // load fifo
      if (   (fifo_ld_a == 1'b1)
          && (   (fifo_unld_a == 1'b0)
              || (fifo_empty_r == 1'b0)))
      begin
        for (ilp = FIFO_DEPTH - 1; ilp >= 0; ilp = ilp - 1)
        begin
          if (ilp == fifo_wr_ptr)//  Formality 2002.05 workaround
            for (jlp = FIFO_WIDTH - 1; jlp >= 0; jlp = jlp - 1)
              fifo_regs_r[(ilp * FIFO_WIDTH) + jlp] <= fifo_in_a[jlp];   
        end
      end

      // FIFO write pointer register
      if ((fifo_ld_a == 1'b1)&&(fifo_unld_a == 1'b0))
        fifo_wr_ptr_ctr_r <= fifo_wr_ptr_ctr_r + 1'b1;
      else if (   (fifo_ld_a == 1'b0)
               && (fifo_unld_a == 1'b1)
               && ((|fifo_wr_ptr_ctr_r) == 1'b1))
        fifo_wr_ptr_ctr_r <= fifo_wr_ptr_ctr_r - 1'b1;
      
      // Full signal
      if (   (fifo_wr_ptr_ctr_r == (FIFO_DEPTH - 1'b1))
          && (fifo_ld_a == 1'b1)
          && (fifo_unld_a == 1'b0))
        fifo_full_r <= 1'b1;
      else if (   (fifo_ld_a == 1'b0)
               && (fifo_unld_a == 1'b1))
        fifo_full_r <= 1'b0;
      
      // Empty Signal
      if (   (fifo_wr_ptr_ctr_r == 1)
          && (fifo_ld_a == 1'b0) 
          && (fifo_unld_a == 1'b1))
        fifo_empty_r <= 1'b1;
      else if (   (fifo_ld_a == 1'b1)
               && (fifo_unld_a == 1'b0))
        fifo_empty_r <= 1'b0;
      
      // ---- Command bus pass signal register -----
      //      the 'cmd_pss_r' signal is normally high to allow command
      //      bus to flow. However, if buffer starts filling because 
      //      rspack == 0 and the current command is
      //      the last cell of a packet, this register is cleared and is only
      //      reset when rspack == 1 and FIFO is empty
      if (   (cmd_pass_r == 1'b1)
          && (fifo_empty_r == 1'b0)
          && (   (t_cmdval == 1'b0)
              || ((t_eop == 1'b1) && (b_t_cmdack == 1'b1))))
        cmd_pass_r <= 1'b0;
      else if (   (cmd_pass_r == 1'b0)
               && (fifo_empty_r == 1'b1))
        cmd_pass_r <= 1'b1;
       
    end
  end

  // ---- assigns --------------------------------------------------------------

  assign fifo_out_a  = (fifo_empty_r == 1'b0)? fifo_regs_r[FIFO_WIDTH -1 : 0]:
                                               fifo_in_a;

  assign fifo_wr_ptr = ((fifo_ld_a == 1'b1)&&(fifo_unld_a == 1'b1))? 
                            fifo_wr_ptr_ctr_r - 1'b1 : fifo_wr_ptr_ctr_r;

  assign fifo_in_a   = {b_t_reop, b_t_rerror, b_t_rdata};  

  assign fifo_ld_a   = b_t_rspval;

  assign fifo_unld_a = t_rspack;
  
  assign t_cmdack    = b_t_cmdack & cmd_pass_r;
  
  assign t_rspval    = b_t_rspval | ~fifo_empty_r;

  assign t_reop      = fifo_out_a[FIFO_WIDTH -1];

  assign t_rerror    = fifo_out_a[FIFO_WIDTH -2];

  assign t_rdata     = fifo_out_a[FIFO_WIDTH -3 : 0];
  
  assign b_t_cmdval  = t_cmdval & cmd_pass_r;

endmodule // module ibus_cbri_ahb
