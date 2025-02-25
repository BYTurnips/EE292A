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
// This module is a 3-port memory (2 read ports/1 write port)
// implemented using flip-flops. It is used as the core register
// file. This module can be used both for synthesis and simulation.
// It can be replaced with a vendor specific RAM.
//
// In the ARChitect configuration tool you can select different 
// implementations of the core register file. Depending on the
// selected type of core register this module is used differently:
// 
//  [1] If a 3 port flip-flop implementation is selected then this
//      module is synthesised.
// 
//  [2] If a 3 port RAM cell implementation is selected then this
//      module is not synthesised. Instead the zero-area RAM model 
//      (with the same name as this module, i.e. regfile_3p) in 
//      arc_rams.db is used.
// 
// This module is only used for 3-port core register files. It is 
// always used as a simulation model independently of whether a 3
// port flip-flop implementation or a RAM cell has been selected.
//
//
module regfile_3p (clk,
                   address_a,
                   address_b,
                   address_w,
                   wr_data,
                   we,
                   ck_en_w,
                   ck_en_a,
                   ck_en_b,

                   rd_data_a,
                   rd_data_b);

`include "arcutil_pkg_defines.v"
`include "arcutil.v"
`include "asmutil.v"
`include "extutil.v"

input   clk; 
input   [4:0] address_a; 
input   [4:0] address_b; 
input   [4:0] address_w; 
input   [31:0] wr_data; 
input   we; 
input   ck_en_w; 
input   ck_en_a; 
input   ck_en_b; 

output  [31:0] rd_data_a; 
output  [31:0] rd_data_b;

reg     [31:0] rd_data_a; 
reg     [31:0] rd_data_b; 

reg     [31:0] regfile_mem_0_r; 
reg     [31:0] regfile_mem_1_r; 
reg     [31:0] regfile_mem_2_r; 
reg     [31:0] regfile_mem_3_r; 
reg     [31:0] regfile_mem_10_r; 
reg     [31:0] regfile_mem_11_r; 
reg     [31:0] regfile_mem_12_r; 
reg     [31:0] regfile_mem_13_r; 
reg     [31:0] regfile_mem_14_r; 
reg     [31:0] regfile_mem_15_r; 
reg     [31:0] regfile_mem_26_r; 
reg     [31:0] regfile_mem_27_r; 
reg     [31:0] regfile_mem_28_r; 
reg     [31:0] regfile_mem_29_r; 
reg     [31:0] regfile_mem_30_r; 
reg     [31:0] regfile_mem_31_r; 
reg     regfile_init; 
reg     [4:0] address_a_r; 
reg     [4:0] address_b_r; 

//synopsys translate_off

initial 
   begin
   regfile_init = `true;    
   end
   
//synopsys translate_on

always @(posedge clk)
   begin : reg_3p_sync_PROC

//synopsys translate_off

   if (regfile_init)
      begin

      //  If the switch is set, initialise the RAM to bits = 0.
      //  This will cut down on 'X' warnings.
      // 
         regfile_mem_0_r <= {32{1'b 0}};  
         regfile_mem_1_r <= {32{1'b 0}};  
         regfile_mem_2_r <= {32{1'b 0}};  
         regfile_mem_3_r <= {32{1'b 0}};  
         regfile_mem_10_r <= {32{1'b 0}};  
         regfile_mem_11_r <= {32{1'b 0}};  
         regfile_mem_12_r <= {32{1'b 0}};  
         regfile_mem_13_r <= {32{1'b 0}};  
         regfile_mem_14_r <= {32{1'b 0}};  
         regfile_mem_15_r <= {32{1'b 0}};  
         regfile_mem_26_r <= {32{1'b 0}};  
         regfile_mem_27_r <= {32{1'b 0}};  
         regfile_mem_28_r <= {32{1'b 0}};  
         regfile_mem_29_r <= {32{1'b 0}};  
         regfile_mem_30_r <= {32{1'b 0}};  
         regfile_mem_31_r <= {32{1'b 0}};  

      regfile_init = `false;    
      end

//synopsys translate_on

   //  Synchronous RAM model
   // 
        // Latch the addresses and enables from stage 1:
        if (ck_en_a == REGFILE_CK_EN_ACTIVE)
        begin
            address_a_r <= address_a; 
        end
        
        if (ck_en_b == REGFILE_CK_EN_ACTIVE)
        begin
            address_b_r <= address_b; 
        end
      
      //  Check that the write and address signals are valid on the clock edge
      // 
//synopsys translate_off
      if (! ( chk_bit(we)))
          begin
          $write("error: ");
          $write("3p RAM we = X at simulation time");
          $write("%b", time2str_f($time));
          $write("ns");
          $display();
          $display("Time: ", $time);
          end

      if (! ( chk_vec_4_0(address_a)))
          begin
          $write("warning: ");
          $write("3p RAM address_a = X at simulation time");
          $write("%b", time2str_f($time));
          $write("ns");
          $display();
          $display("Time: ", $time);
          end

      if (! ( chk_vec_4_0(address_b)))
          begin
          $write("warning: ");
          $write("3p RAM address_b = X at simulation time");
          $write("%b", time2str_f($time));
          $write("ns");
          $display();
          $display("Time: ", $time);
          end

      if (! ( chk_vec_4_0(address_w)))
          begin
          $write("warning: ");
          $write("3p RAM address_w = X at simulation time");
          $write("%b", time2str_f($time));
          $write("ns");
          $display();
          $display("Time: ", $time);
          end
//synopsys translate_on

      //  Write Port
      // 
      if (ck_en_w == REGFILE_CK_EN_ACTIVE)
         begin

         //  Store data into memory and write through to the output
         //   
         if (we == REGFILE_WR_ACTIVE)
            begin
               case (address_w)
                   5'b00000:  regfile_mem_0_r <= wr_data[31:0];
                   5'b00001:  regfile_mem_1_r <= wr_data[31:0];
                   5'b00010:  regfile_mem_2_r <= wr_data[31:0];
                   5'b00011:  regfile_mem_3_r <= wr_data[31:0];
                   5'b01010:  regfile_mem_10_r <= wr_data[31:0];
                   5'b01011:  regfile_mem_11_r <= wr_data[31:0];
                   5'b01100:  regfile_mem_12_r <= wr_data[31:0];
                   5'b01101:  regfile_mem_13_r <= wr_data[31:0];
                   5'b01110:  regfile_mem_14_r <= wr_data[31:0];
                   5'b01111:  regfile_mem_15_r <= wr_data[31:0];
                   5'b11010:  regfile_mem_26_r <= wr_data[31:0];
                   5'b11011:  regfile_mem_27_r <= wr_data[31:0];
                   5'b11100:  regfile_mem_28_r <= wr_data[31:0];
                   5'b11101:  regfile_mem_29_r <= wr_data[31:0];
                   5'b11110:  regfile_mem_30_r <= wr_data[31:0];
                   5'b11111:  regfile_mem_31_r <= wr_data[31:0];
                endcase

            //  Check written data is valid
            // 

//synopsys translate_off

            if (! (chk_vec_31_0(wr_data)))
                begin
                $write("error: ");
                $write("3p RAM wr_data = X at simulation time");
                $write("%b", time2str_f($time));
                $write("ns");
                $display();
                $display("Time: ", $time);
                end

//synopsys translate_on

            end  // if (we == REGFILE_WR_ACTIVE)
       end  // if (ck_en_w)
   end   // always block


// Read Port A

always @(address_a_r
or regfile_mem_0_r or regfile_mem_1_r or regfile_mem_2_r or regfile_mem_3_r
or regfile_mem_10_r or regfile_mem_11_r or regfile_mem_12_r or regfile_mem_13_r
or regfile_mem_14_r or regfile_mem_15_r
or regfile_mem_26_r or regfile_mem_27_r
or regfile_mem_28_r or regfile_mem_29_r or regfile_mem_30_r or regfile_mem_31_r)
begin : read_porta_async_PROC

         case (address_a_r)
             5'b00000:  rd_data_a = regfile_mem_0_r;
             5'b00001:  rd_data_a = regfile_mem_1_r;
             5'b00010:  rd_data_a = regfile_mem_2_r;
             5'b00011:  rd_data_a = regfile_mem_3_r;
             5'b01010:  rd_data_a = regfile_mem_10_r;
             5'b01011:  rd_data_a = regfile_mem_11_r;
             5'b01100:  rd_data_a = regfile_mem_12_r;
             5'b01101:  rd_data_a = regfile_mem_13_r;
             5'b01110:  rd_data_a = regfile_mem_14_r;
             5'b01111:  rd_data_a = regfile_mem_15_r;
             5'b11010:  rd_data_a = regfile_mem_26_r;
             5'b11011:  rd_data_a = regfile_mem_27_r;
             5'b11100:  rd_data_a = regfile_mem_28_r;
             5'b11101:  rd_data_a = regfile_mem_29_r;
             5'b11110:  rd_data_a = regfile_mem_30_r;
             5'b11111:  rd_data_a = regfile_mem_31_r;
             default:   rd_data_a = 32'h00000000;
         endcase
end

// Read Port B

always @(address_b_r
or regfile_mem_0_r or regfile_mem_1_r or regfile_mem_2_r or regfile_mem_3_r
or regfile_mem_10_r or regfile_mem_11_r or regfile_mem_12_r or regfile_mem_13_r
or regfile_mem_14_r or regfile_mem_15_r
or regfile_mem_26_r or regfile_mem_27_r
or regfile_mem_28_r or regfile_mem_29_r or regfile_mem_30_r or regfile_mem_31_r)
begin : read_portb_async_PROC

         case (address_b_r)
             5'b00000:  rd_data_b = regfile_mem_0_r;
             5'b00001:  rd_data_b = regfile_mem_1_r;
             5'b00010:  rd_data_b = regfile_mem_2_r;
             5'b00011:  rd_data_b = regfile_mem_3_r;
             5'b01010:  rd_data_b = regfile_mem_10_r;
             5'b01011:  rd_data_b = regfile_mem_11_r;
             5'b01100:  rd_data_b = regfile_mem_12_r;
             5'b01101:  rd_data_b = regfile_mem_13_r;
             5'b01110:  rd_data_b = regfile_mem_14_r;
             5'b01111:  rd_data_b = regfile_mem_15_r;
             5'b11010:  rd_data_b = regfile_mem_26_r;
             5'b11011:  rd_data_b = regfile_mem_27_r;
             5'b11100:  rd_data_b = regfile_mem_28_r;
             5'b11101:  rd_data_b = regfile_mem_29_r;
             5'b11110:  rd_data_b = regfile_mem_30_r;
             5'b11111:  rd_data_b = regfile_mem_31_r;
             default:   rd_data_b = 32'h00000000;
         endcase
end

endmodule 

