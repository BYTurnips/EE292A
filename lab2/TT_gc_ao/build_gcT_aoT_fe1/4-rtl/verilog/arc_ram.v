// *SYNOPSYS CONFIDENTIAL*
//
// This is an unpublished, proprietary work of Synopsys, Inc., and is fully 
// protected under copyright and trade secret laws.  You may not view, use, 
// disclose, copy, or distribute this file or any information contained herein 
// except pursuant to a valid written license from Synopsys.


// This file is generated automatically by 'veriloggen'.




module arc_ram(clk_ungated,
               ldst_addr,
               ldst_din,
               ldst_mask,
               ldst_wren,
               ldst_ck_en,
               code_ram_addr,
               code_ram_wdata,
               code_ram_wr,
               code_ram_be,
               code_ram_ck_en,
               ldst_dout,
               code_ram_rdata);


// Includes found automatically in dependent files.
`include "arcutil_pkg_defines.v"
`include "extutil.v"
`include "xdefs.v"
`include "che_util.v"


input  clk_ungated;
input  [LDST_A_MSB:0]  ldst_addr;
input  [31:0]  ldst_din;
input  [3:0]  ldst_mask;
input  ldst_wren;
input  ldst_ck_en;
input  [CODE_RAM_ADDR_MSB-CODE_RAM_ADDR_LSB:0]  code_ram_addr;
input  [31:0]  code_ram_wdata;
input  code_ram_wr;
input  [3:0]  code_ram_be;
input  code_ram_ck_en;
output [31:0]  ldst_dout;
output [31:0]  code_ram_rdata;

wire clk_ungated;
wire  [LDST_A_MSB:0] ldst_addr;
wire  [31:0] ldst_din;
wire  [3:0] ldst_mask;
wire ldst_wren;
wire ldst_ck_en;
wire  [CODE_RAM_ADDR_MSB-CODE_RAM_ADDR_LSB:0] code_ram_addr;
wire  [31:0] code_ram_wdata;
wire code_ram_wr;
wire  [3:0] code_ram_be;
wire code_ram_ck_en;
wire  [31:0] ldst_dout;
wire  [31:0] code_ram_rdata;


// Intermediate signals


// Dummy signals for 'unconnected' ports
// (doing this, rather than leaving them genuinely unconnected, stops
//  simulators emitting pointless warnings)


// Instantiation of module dccm_ram
dccm_ram idccm_ram(
  .clk_ungated(clk_ungated),
  .ldst_addr(ldst_addr),
  .ldst_din(ldst_din),
  .ldst_mask(ldst_mask),
  .ldst_wren(ldst_wren),
  .ldst_ck_en(ldst_ck_en),
  .ldst_dout(ldst_dout)
);


// Instantiation of module iccm_ram
iccm_ram iiccm_ram(
  .clk_ungated(clk_ungated),
  .code_ram_addr(code_ram_addr),
  .code_ram_wdata(code_ram_wdata),
  .code_ram_wr(code_ram_wr),
  .code_ram_be(code_ram_be),
  .code_ram_ck_en(code_ram_ck_en),
  .code_ram_rdata(code_ram_rdata)
);


// Output drives

endmodule


