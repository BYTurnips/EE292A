// *SYNOPSYS CONFIDENTIAL*
//
// This is an unpublished, proprietary work of Synopsys, Inc., and is fully 
// protected under copyright and trade secret laws.  You may not view, use, 
// disclose, copy, or distribute this file or any information contained herein 
// except pursuant to a valid written license from Synopsys.


// This file is generated automatically by 'veriloggen'.




module if_sys(clk_ungated,
              code_ram_rdata,
              rst_a,
              test_mode,
              ck_disable,
              ivic,
              dmp_mload,
              dmp_mstore,
              next_pc,
              ifetch,
              dmp_dwr,
              dmp_en3,
              dmp_addr,
              dmp_size,
              dmp_sex,
              hold_loc,
              is_code_ram,
              code_dmi_req,
              code_dmi_addr,
              code_dmi_wdata,
              code_dmi_wr,
              code_dmi_be,
              code_ram_addr,
              code_ram_wdata,
              code_ram_wr,
              code_ram_be,
              code_ram_ck_en,
              code_stall_ldst,
              ic_busy,
              ivalid,
              p1iw,
              code_drd,
              code_ldvalid_r,
              code_dmi_rdata);


// Includes found automatically in dependent files.
`include "arcutil_pkg_defines.v"
`include "arcutil.v"
`include "extutil.v"
`include "xdefs.v"


input  clk_ungated;
input  [31:0]  code_ram_rdata;
input  rst_a;
input  test_mode;
input  ck_disable;
input  ivic;
input  dmp_mload;
input  dmp_mstore;
input  [PC_MSB:0]  next_pc;
input  ifetch;
input  [31:0]  dmp_dwr;
input  dmp_en3;
input  [31:0]  dmp_addr;
input  [1:0]  dmp_size;
input  dmp_sex;
input  hold_loc;
input  is_code_ram;
input  code_dmi_req;
input  [31:0]  code_dmi_addr;
input  [31:0]  code_dmi_wdata;
input  code_dmi_wr;
input  [3:0]  code_dmi_be;
output [CODE_RAM_ADDR_MSB-CODE_RAM_ADDR_LSB:0]  code_ram_addr;
output [31:0]  code_ram_wdata;
output code_ram_wr;
output [3:0]  code_ram_be;
output code_ram_ck_en;
output code_stall_ldst;
output ic_busy;
output ivalid;
output [31:0]  p1iw;
output [31:0]  code_drd;
output code_ldvalid_r;
output [31:0]  code_dmi_rdata;

wire clk_ungated;
wire  [31:0] code_ram_rdata;
wire rst_a;
wire test_mode;
wire ck_disable;
wire ivic;
wire dmp_mload;
wire dmp_mstore;
wire  [PC_MSB:0] next_pc;
wire ifetch;
wire  [31:0] dmp_dwr;
wire dmp_en3;
wire  [31:0] dmp_addr;
wire  [1:0] dmp_size;
wire dmp_sex;
wire hold_loc;
wire is_code_ram;
wire code_dmi_req;
wire  [31:0] code_dmi_addr;
wire  [31:0] code_dmi_wdata;
wire code_dmi_wr;
wire  [3:0] code_dmi_be;
wire  [CODE_RAM_ADDR_MSB-CODE_RAM_ADDR_LSB:0] code_ram_addr;
wire  [31:0] code_ram_wdata;
wire code_ram_wr;
wire  [3:0] code_ram_be;
wire code_ram_ck_en;
wire code_stall_ldst;
wire ic_busy;
wire ivalid;
wire  [31:0] p1iw;
wire  [31:0] code_drd;
wire code_ldvalid_r;
wire  [31:0] code_dmi_rdata;


// Intermediate signals


// Dummy signals for 'unconnected' ports
// (doing this, rather than leaving them genuinely unconnected, stops
//  simulators emitting pointless warnings)


// Instantiation of module iccm_control
iccm_control iiccm_control(
  .clk_ungated(clk_ungated),
  .rst_a(rst_a),
  .ck_disable(ck_disable),
  .test_mode(test_mode),
  .ivic(ivic),
  .code_ram_rdata(code_ram_rdata),
  .ifetch(ifetch),
  .next_pc(next_pc),
  .dmp_dwr(dmp_dwr),
  .dmp_en3(dmp_en3),
  .dmp_addr(dmp_addr),
  .dmp_mload(dmp_mload),
  .dmp_mstore(dmp_mstore),
  .dmp_size(dmp_size),
  .dmp_sex(dmp_sex),
  .hold_loc(hold_loc),
  .is_code_ram(is_code_ram),
  .code_dmi_req(code_dmi_req),
  .code_dmi_addr(code_dmi_addr),
  .code_dmi_wdata(code_dmi_wdata),
  .code_dmi_wr(code_dmi_wr),
  .code_dmi_be(code_dmi_be),
  .code_ram_addr(code_ram_addr),
  .code_ram_wdata(code_ram_wdata),
  .code_ram_wr(code_ram_wr),
  .code_ram_be(code_ram_be),
  .code_ram_ck_en(code_ram_ck_en),
  .p1iw(p1iw),
  .ivalid(ivalid),
  .code_drd(code_drd),
  .code_ldvalid_r(code_ldvalid_r),
  .code_dmi_rdata(code_dmi_rdata),
  .code_stall_ldst(code_stall_ldst),
  .ic_busy(ic_busy)
);


// Output drives

endmodule


