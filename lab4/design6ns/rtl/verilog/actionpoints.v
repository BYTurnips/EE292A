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
module actionpoints (
   clk_ungated,
   clk_debug,
   rst_a,
   en,
   en1,
   en2,   
   ivic,
   currentpc_r,
   mc_addr,
   dwr,
   drd,
   aux_addr,
   aux_dataw,
   h_addr,
   h_dataw,  
   aux_datar,
   ap_param0,
   ap_param1,
   kill_p2_a,
   p2b_iv,
   p2_iw_r,
   actionpt_pc_brk_a,
   p2_brcc_instr_a,
   p3_brcc_instr_a,
   p2b_jmp_holdup_a,
   p2_ap_stall_a,
   p2iv,
   mload,
   mstore,
   ldvalid,
   h_write,      
   aux_read,
   aux_write,
   ap_param0_read,
   ap_param0_write,
   ap_param1_read,
   ap_param1_write,
   aux_access,
   actionhalt,
   ap_ahv0,
   ap_ahv1,
   ap_ahv2,
   ap_ahv3,
   ap_ahv4,
   ap_ahv5,
   ap_ahv6,
   ap_ahv7,
   ap_ahc0,
   ap_ahc1,
   ap_ahc2,
   ap_ahc3,
   ap_ahc4,
   ap_ahc5,
   ap_ahc6,
   ap_ahc7,
   ap_ahm0,
   ap_ahm1,
   ap_ahm2,
   ap_ahm3,
   ap_ahm4,
   ap_ahm5,
   ap_ahm6,
   ap_ahm7,
   actionpt_status_r,
   actionpt_brk_a,
   actionpt_swi_a,
   en_debug_r
   );

`include "arcutil_pkg_defines.v"
`include "arcutil.v"
`include "extutil.v"
`include "xdefs.v"

// Global clock and reset signals
input                       clk_ungated;         // ungated core clock
input                       clk_debug;           // debug clock
input                       rst_a;               // master reset

input                       p2b_iv;
input   [INSTR_UBND:0]      p2_iw_r;
input                       kill_p2_a;
input                       en1;
input                       en2;
input                       p2_brcc_instr_a;
input                       p3_brcc_instr_a;
input                       p2b_jmp_holdup_a;
input                       ivic;

// Global run signal
input                       en;                 // global run

// Actionpoint data sources
input   [PC_MSB:0]          currentpc_r;        // architectural PC
input   [DATAWORD_MSB:0]    mc_addr;            // mem access addr
input   [DATAWORD_MSB:0]    dwr;                // mem access write data
input   [DATAWORD_MSB:0]    drd;                // mem access read data
input   [DATAWORD_MSB:0]    aux_addr;           // aux access addr
input   [DATAWORD_MSB:0]    aux_dataw;          // aux access write data
input   [DATAWORD_MSB:0]    h_addr;             // aux access addr
input   [DATAWORD_MSB:0]    h_dataw;            // aux access write data
input   [DATAWORD_MSB:0]    aux_datar;          // aux access read data
input   [DATAWORD_MSB:0]    ap_param0;          // external parameter 0
input   [DATAWORD_MSB:0]    ap_param1;          // external parameter 1

// Actionpoint data source qualifiers
input                       p2iv;               // for currentpc_r
input                       mload;              // for mc_addr
input                       mstore;             // for mc_addr, dwr
input                       ldvalid;            // for drd
input                       aux_read;           // for aux_addr, aux_datar
input                       h_write;            // for host write
input                       aux_write;          // for aux_addr, aux_dataw
input                       ap_param0_read;     // for ap_param0
input                       ap_param0_write;    // for ap_param0
input                       ap_param1_read;     // for ap_param1
input                       ap_param1_write;    // for ap_param1

// Indicates a host access to auxiliary registers
input                       aux_access;
// Indicators from flags
input                       actionhalt;

// Actionpoint outputs
output   [31:0]             ap_ahv0;            // actionpoint 0 value
output   [31:0]             ap_ahv1;            // actionpoint 1 value

output   [31:0]             ap_ahv2;            // actionpoint 2 value
output   [31:0]             ap_ahv3;            // actionpoint 3 value
output   [31:0]             ap_ahv4;            // actionpoint 4 value
output   [31:0]             ap_ahv5;            // actionpoint 5 value
output   [31:0]             ap_ahv6;            // actionpoint 6 value
output   [31:0]             ap_ahv7;            // actionpoint 7 value

output   [31:0]             ap_ahc0;            // actionpoint 0 control
output   [31:0]             ap_ahc1;            // actionpoint 1 control

output   [31:0]             ap_ahc2;            // actionpoint 2 control
output   [31:0]             ap_ahc3;            // actionpoint 3 control
output   [31:0]             ap_ahc4;            // actionpoint 4 control
output   [31:0]             ap_ahc5;            // actionpoint 5 control
output   [31:0]             ap_ahc6;            // actionpoint 6 control
output   [31:0]             ap_ahc7;            // actionpoint 7 control

output   [31:0]             ap_ahm0;            // actionpoint 0 match
output   [31:0]             ap_ahm1;            // actionpoint 1 match

output   [31:0]             ap_ahm2;            // actionpoint 2 match
output   [31:0]             ap_ahm3;            // actionpoint 3 match
output   [31:0]             ap_ahm4;            // actionpoint 4 match
output   [31:0]             ap_ahm5;            // actionpoint 5 match
output   [31:0]             ap_ahm6;            // actionpoint 6 match
output   [31:0]             ap_ahm7;            // actionpoint 7 match

output   [NUM_APS - 1:0]    actionpt_status_r;  // actionpoint hit bits that
                                                // end up in debug register
output                      actionpt_brk_a;     // signal to pipeline control 
                                                // that a halt is requested
output                      actionpt_swi_a;     // signal to pipeline control 
                                                //that a SWI is requested
output                      en_debug_r;         // enable debug extensions clk

output                      actionpt_pc_brk_a;
output                      p2_ap_stall_a;

reg     [31:0]              ap_ahv0; 
reg     [31:0]              ap_ahv1; 
reg     [31:0]              ap_ahv2; 
reg     [31:0]              ap_ahv3; 
reg     [31:0]              ap_ahv4; 
reg     [31:0]              ap_ahv5; 
reg     [31:0]              ap_ahv6; 
reg     [31:0]              ap_ahv7; 
reg     [31:0]              ap_ahc0; 
reg     [31:0]              ap_ahc1; 
reg     [31:0]              ap_ahc2; 
reg     [31:0]              ap_ahc3; 
reg     [31:0]              ap_ahc4; 
reg     [31:0]              ap_ahc5; 
reg     [31:0]              ap_ahc6; 
reg     [31:0]              ap_ahc7; 
reg     [31:0]              ap_ahm0; 
reg     [31:0]              ap_ahm1; 
reg     [31:0]              ap_ahm2; 
reg     [31:0]              ap_ahm3; 
reg     [31:0]              ap_ahm4; 
reg     [31:0]              ap_ahm5; 
reg     [31:0]              ap_ahm6; 
reg     [31:0]              ap_ahm7; 
wire                        actionpt_brk_a; 
wire                        actionpt_swi_a; 
wire                        en_debug_r; 
wire                        actionpt_pc_brk_a;
wire                        p2_ap_stall_a;


// Set of large vectors that hold the registers associated
// with each actionpoint.
//
// Actionpoint value
reg     [(AP_AMV_SIZE*NUM_APS)-1:0] i_ap_value_nxt; 
reg     [(AP_AMV_SIZE*NUM_APS)-1:0] i_ap_value_r; 
// Actionpoint mask
reg     [(AP_AMV_SIZE*NUM_APS)-1:0] i_ap_mask_nxt; 
reg     [(AP_AMV_SIZE*NUM_APS)-1:0] i_ap_mask_r; 
// Actionpoint control
reg     [(AP_AC_SIZE*NUM_APS)-1:0]  i_ap_control_nxt; 
reg     [(AP_AC_SIZE*NUM_APS)-1:0]  i_ap_control_r; 

// Vectors which hold the decode bits for register access
//
wire    [7:0]               i_v_decode_a;         // Value
wire    [7:0]               i_m_decode_a;         // Mask
wire    [7:0]               i_c_decode_a;         // Control

wire    [7:0]               i_v_decode_h_a;       // Value
wire    [7:0]               i_m_decode_h_a;       // Mask
wire    [7:0]               i_c_decode_h_a;       // Control

// Raw hits from ap_compare
wire    [NUM_APS - 1:0]     i_ap_hit_a; 
// Qualified hits after pairing
reg     [NUM_APS - 1:0]     i_ap_hit_qual_a;
reg     [NUM_APS - 1:0]     i_ap_hit_qual_p3_a; 
 
// Hit indicator for second of paired actionpoints
reg     [NUM_APS - 1:0]     i_ap_hit_pair_a; 
// Qualified hits after pairing where action is BRK
reg     [NUM_APS - 1:0]     i_ap_hit_qual_brk_a; 
reg     [NUM_APS - 1:0]     i_ap_hit_quad_a; 
reg     [NUM_APS - 1:0]     i_ap_hit_sing_a;
reg     [NUM_APS - 1:0]     i_ap_hit_qual_r; 

// Qualified hits after pairing where action is BRK. Used to halt instruction in stage 2
reg     [NUM_APS - 1:0]     i_ap_hit_qual_pc_brk_a; 

// Qualified hits after pairing where action is SWI
reg     [NUM_APS - 1:0]     i_ap_hit_qual_swi_a; 
// Array holding values from all the ap_compares
wire    [(AP_AMV_SIZE*NUM_APS)-1:0] i_ap_hit_value_a; 


// Single bit indicating a BRK hit
wire                        i_ap_hit_comb_brk_a; 
// Single bit indicating a SWI hit
wire                        i_ap_hit_comb_swi_a; 
// Registered version of actionhalt
reg                         i_actionhalt_r;
// Enable Debug (ED) flag internal
wire                        i_en_debug_nxt;
reg                         i_en_debug_r;
// aux read from core
wire                        i_aux_read_core_a;
// aux write from core
wire                        i_aux_write_core_a;

wire                        i_ap_pc_brk_a;
wire                        i_ap_hit_swi_a;
wire                        i_ap_p3_qual_hit_a;
wire                        i_actionhalt_nxt;
wire                        i_brcc_p2b_p3_a;


reg                         i_en_r;
reg                         i_ivic_r;

// preregistered actionpt_status_r
reg     [NUM_APS-1:0]       i_actionpt_status_r;
reg     [NUM_APS-1:0]       i_ap_write_a;
reg     [PC_MSB:0]          i_p2_currentpc_r;        // architectural PC
reg                         i_p2b_brcc_instr_r;

// action-point value register update
function [0:0] avr_update;
  input  [(AP_AC_SIZE*NUM_APS)-1:0] ap_control_r;
  input  [0:0] index;
  input   brcc_p2b_p3_a;
  integer ilp;
  begin  
    ilp = index;
    avr_update = // if it's a general watch point we can trigger
                (~(~ap_control_r[(AP_AC_SIZE*ilp)+1] & ~ap_control_r[(AP_AC_SIZE*ilp)+2] &
                 ~ap_control_r[(AP_AC_SIZE*ilp)+3]) |
           
                    // if it's a Opcode or PC and brcc ahead in the pipeline wait until it resolves
                 (~ap_control_r[(AP_AC_SIZE*ilp)+1] & ~ap_control_r[(AP_AC_SIZE*ilp)+2] &
                  ~ap_control_r[(AP_AC_SIZE*ilp)+3] & ~brcc_p2b_p3_a)); 
  end          
endfunction


// Create three decode vectors These constants are defined in xdefs.v.
// Actionpoint Match Value
assign i_v_decode_a[0] = auxdc(aux_addr, aux_ap_amv0);
assign i_v_decode_a[1] = auxdc(aux_addr, aux_ap_amv1);
assign i_v_decode_a[2] = auxdc(aux_addr, aux_ap_amv2); 
assign i_v_decode_a[3] = auxdc(aux_addr, aux_ap_amv3);
assign i_v_decode_a[4] = auxdc(aux_addr, aux_ap_amv4);
assign i_v_decode_a[5] = auxdc(aux_addr, aux_ap_amv5);
assign i_v_decode_a[6] = auxdc(aux_addr, aux_ap_amv6);
assign i_v_decode_a[7] = auxdc(aux_addr, aux_ap_amv7);

//  Actionpoint Match Mask
assign i_m_decode_a[0] = auxdc(aux_addr, aux_ap_amm0);
assign i_m_decode_a[1] = auxdc(aux_addr, aux_ap_amm1);
assign i_m_decode_a[2] = auxdc(aux_addr, aux_ap_amm2);
assign i_m_decode_a[3] = auxdc(aux_addr, aux_ap_amm3);
assign i_m_decode_a[4] = auxdc(aux_addr, aux_ap_amm4);
assign i_m_decode_a[5] = auxdc(aux_addr, aux_ap_amm5);
assign i_m_decode_a[6] = auxdc(aux_addr, aux_ap_amm6);
assign i_m_decode_a[7] = auxdc(aux_addr, aux_ap_amm7);

//  Actionpoint Control
assign i_c_decode_a[0] = auxdc(aux_addr, aux_ap_ac0);
assign i_c_decode_a[1] = auxdc(aux_addr, aux_ap_ac1);
assign i_c_decode_a[2] = auxdc(aux_addr, aux_ap_ac2);
assign i_c_decode_a[3] = auxdc(aux_addr, aux_ap_ac3);
assign i_c_decode_a[4] = auxdc(aux_addr, aux_ap_ac4);
assign i_c_decode_a[5] = auxdc(aux_addr, aux_ap_ac5);
assign i_c_decode_a[6] = auxdc(aux_addr, aux_ap_ac6);
assign i_c_decode_a[7] = auxdc(aux_addr, aux_ap_ac7);

// For host accesses

assign i_v_decode_h_a[0] = auxdc(h_addr, aux_ap_amv0) & aux_access;
assign i_v_decode_h_a[1] = auxdc(h_addr, aux_ap_amv1) & aux_access;
assign i_v_decode_h_a[2] = auxdc(h_addr, aux_ap_amv2) & aux_access; 
assign i_v_decode_h_a[3] = auxdc(h_addr, aux_ap_amv3) & aux_access;
assign i_v_decode_h_a[4] = auxdc(h_addr, aux_ap_amv4) & aux_access;
assign i_v_decode_h_a[5] = auxdc(h_addr, aux_ap_amv5) & aux_access;
assign i_v_decode_h_a[6] = auxdc(h_addr, aux_ap_amv6) & aux_access;
assign i_v_decode_h_a[7] = auxdc(h_addr, aux_ap_amv7) & aux_access;

//  Actionpoint Match Mask
assign i_m_decode_h_a[0] = auxdc(h_addr, aux_ap_amm0) & aux_access;
assign i_m_decode_h_a[1] = auxdc(h_addr, aux_ap_amm1) & aux_access;
assign i_m_decode_h_a[2] = auxdc(h_addr, aux_ap_amm2) & aux_access;
assign i_m_decode_h_a[3] = auxdc(h_addr, aux_ap_amm3) & aux_access;
assign i_m_decode_h_a[4] = auxdc(h_addr, aux_ap_amm4) & aux_access;
assign i_m_decode_h_a[5] = auxdc(h_addr, aux_ap_amm5) & aux_access;
assign i_m_decode_h_a[6] = auxdc(h_addr, aux_ap_amm6) & aux_access;
assign i_m_decode_h_a[7] = auxdc(h_addr, aux_ap_amm7) & aux_access;

//  Actionpoint Control
assign i_c_decode_h_a[0] = auxdc(h_addr, aux_ap_ac0) & aux_access;
assign i_c_decode_h_a[1] = auxdc(h_addr, aux_ap_ac1) & aux_access;
assign i_c_decode_h_a[2] = auxdc(h_addr, aux_ap_ac2) & aux_access;
assign i_c_decode_h_a[3] = auxdc(h_addr, aux_ap_ac3) & aux_access;
assign i_c_decode_h_a[4] = auxdc(h_addr, aux_ap_ac4) & aux_access;
assign i_c_decode_h_a[5] = auxdc(h_addr, aux_ap_ac5) & aux_access;
assign i_c_decode_h_a[6] = auxdc(h_addr, aux_ap_ac6) & aux_access;
assign i_c_decode_h_a[7] = auxdc(h_addr, aux_ap_ac7) & aux_access;

          
// Infer the registers clocked by clk_debug. This clock is gated to reduce power
// when the clock gating option is used.
//
always @(posedge clk_debug or posedge rst_a)
   begin : regs1_PROC
   if (rst_a == 1'b 1)
      begin
      i_actionhalt_r         <= 1'b0;
      i_p2b_brcc_instr_r     <= 1'b0;
      i_ap_hit_qual_r        <= {(NUM_APS){1'b0}};
      i_ap_value_r           <= {(32*NUM_APS){1'b0}};
      i_ap_mask_r            <= {(32*NUM_APS){1'b0}};
      i_ap_control_r         <= {(AP_AC_SIZE*NUM_APS){1'b0}};      
      i_p2_currentpc_r       <= {(PC_MSB){1'b0}};
      i_actionpt_status_r    <= {(NUM_APS){1'b0}};
      i_en_r                 <= 1'b0;
      i_ivic_r               <= 1'b0;      
                  
      end
   else
      begin
      i_ap_value_r           <= i_ap_value_nxt;
      i_ap_mask_r            <= i_ap_mask_nxt;
      i_ap_control_r         <= i_ap_control_nxt;      
      i_actionhalt_r         <= i_actionhalt_nxt;
      i_en_r                 <= en;
      i_ivic_r               <= ivic;       // delay ivic for one cycle (covers clock gating scenario)

// Update the registered version of the brk hit qualifier signal if hit. We update
// the ap value register with the triggering value, so the combinational qual signal 
// is no longer valid, hence we use the registered version until an IVIC is performed
// which clears stage 1 and 2 and this signal.

      if (i_ivic_r==1'b1)
          i_ap_hit_qual_r        <= {(NUM_APS){1'b0}};
      else if ((i_ap_pc_brk_a==1'b1) && (i_brcc_p2b_p3_a==1'b0) && (i_actionhalt_r==1'b0) && (en==1'b1))
               i_ap_hit_qual_r   <= i_ap_hit_qual_pc_brk_a; 

// Handle the updating of the AP status bits here.     
      if (i_en_r == 1'b0 && en==1'b1)
          i_actionpt_status_r <= {(NUM_APS){1'b0}} | i_ap_hit_qual_brk_a | i_ap_hit_qual_swi_a;
          
      else if (i_ap_hit_comb_brk_a==1'b1)
               i_actionpt_status_r <=  i_actionpt_status_r | i_ap_hit_qual_brk_a | i_ap_hit_qual_p3_a;
               
      else if (i_ap_hit_comb_swi_a == 1'b1 && i_actionhalt_r == 1'b0 && en==1'b1) 
               i_actionpt_status_r <= i_actionpt_status_r | i_ap_hit_qual_swi_a | i_ap_hit_qual_p3_a;               

      else if (i_ap_p3_qual_hit_a==1'b1)
               i_actionpt_status_r <= i_actionpt_status_r | i_ap_hit_qual_p3_a;
      else  
// Update the action status bits for SWI AP writes
               i_actionpt_status_r <= i_actionpt_status_r & (~i_ap_write_a);


      if (en1==1'b1) // log current pc for use in stage 2
          i_p2_currentpc_r     <= currentpc_r;

      if (en2==1'b1) // determine if p2b contains an brcc instruction  
          i_p2b_brcc_instr_r   <= p2_brcc_instr_a; 

      
      end
   end

   assign i_brcc_p2b_p3_a = (i_p2b_brcc_instr_r & p2b_iv) | p3_brcc_instr_a;
   
// Infer the register clocked by ck
// This clock is always active so the 
// en_debug_r bit can always begin controlled
always @(posedge clk_ungated or posedge rst_a)
   begin : regs2_sync_PROC
   if (rst_a == 1'b1)
      i_en_debug_r <= 1'b0;
   else
      i_en_debug_r <= i_en_debug_nxt;
   end


// Delay actionhalt by one cycle for use in AMV update control
assign i_actionhalt_nxt = actionhalt;
         

// Decode access to the registers and update their "nxt" values
always @(i_ap_value_r or i_ap_mask_r or i_ap_control_r or en or
         aux_write or i_v_decode_a or aux_dataw or h_dataw or h_write or
	 i_v_decode_h_a or i_m_decode_h_a or i_c_decode_h_a or en or
        i_m_decode_a or i_c_decode_a  or i_ap_hit_pair_a or 
        i_actionhalt_r or i_ap_hit_value_a or i_actionpt_status_r or 
        i_ap_hit_sing_a or i_ap_hit_quad_a or i_ap_hit_qual_p3_a)
   begin : aux_regs_decode_PROC
   integer ilp,jlp; // Local loop variables

// assign the defaults
   i_ap_value_nxt        = i_ap_value_r;
   i_ap_mask_nxt         = i_ap_mask_r;
   i_ap_control_nxt      = i_ap_control_r;
   i_ap_write_a          = {(NUM_APS){1'b0}};   

//  Registers associated with each actionpoint
   if (aux_write == 1'b 1) // SR instruction from core or host (debugger) write whilst core halted
      begin
      for (ilp = 0; ilp <= NUM_APS - 1; ilp = ilp + 1)
         begin
         
            if (i_v_decode_a[ilp]==1'b 1 || i_m_decode_a[ilp]==1'b1 || i_c_decode_a[ilp]==1'b1)
                 i_ap_write_a[ilp] = 1'b1;  
                 
            for (jlp = 0; jlp < AP_AMV_SIZE; jlp = jlp + 1)
               begin
               if (i_v_decode_a[ilp] == 1'b 1)
                  i_ap_value_nxt[(AP_AMV_SIZE*ilp)+jlp] 
                     = aux_dataw[jlp];   
               if (i_m_decode_a[ilp] == 1'b 1)
                  i_ap_mask_nxt[(AP_AMV_SIZE*ilp)+jlp] 
                     = aux_dataw[jlp];   
               end
            for (jlp = 0; jlp < AP_AC_SIZE; jlp = jlp + 1)
               if (i_c_decode_a[ilp] == 1'b 1)
                  i_ap_control_nxt[(AP_AC_SIZE*ilp)+jlp] 
                     = aux_dataw[jlp];   
         end
      end

   if ((h_write == 1'b1) && (en == 1'b1)) // host (debugger) write whilst core running
      begin
      for (ilp = 0; ilp <= NUM_APS - 1; ilp = ilp + 1)
         begin
         
            if (i_v_decode_h_a[ilp]==1'b 1 || i_m_decode_h_a[ilp]==1'b1 || i_c_decode_h_a[ilp]==1'b1)
                 i_ap_write_a[ilp] = 1'b1;  
                 
            for (jlp = 0; jlp < AP_AMV_SIZE; jlp = jlp + 1)
               begin
	       
               if (i_v_decode_h_a[ilp] == 1'b 1)
                  i_ap_value_nxt[(AP_AMV_SIZE*ilp)+jlp] 
                     = h_dataw[jlp]; 	              
		     
               if (i_m_decode_h_a[ilp] == 1'b 1)
                  i_ap_mask_nxt[(AP_AMV_SIZE*ilp)+jlp] 
                     = h_dataw[jlp]; 
		 
               end
	       
            for (jlp = 0; jlp < AP_AC_SIZE; jlp = jlp + 1)
               if (i_c_decode_h_a[ilp] == 1'b 1)
			      i_ap_control_nxt[(AP_AC_SIZE*ilp)+jlp] 
                     = h_dataw[jlp];   		   
         end
      end

        
// Update the value register with the hit value. Only
// do this once at the beginning of the actionpoint process
// to avoid false triggering with the new match value

      for (ilp = 0; ilp <= NUM_APS - 1; ilp = ilp + 1)
      
         for (jlp = 0; jlp < AP_AMV_SIZE; jlp = jlp + 1) 
            if ((i_ap_hit_sing_a[ilp]==1'b1 || i_ap_hit_quad_a[ilp]==1'b1 || i_ap_hit_pair_a[ilp]==1'b1) 
                && (i_actionhalt_r == 1'b0) && en==1'b1)
                i_ap_value_nxt[(AP_AMV_SIZE*ilp)+jlp] = i_ap_hit_value_a[(AP_AMV_SIZE*ilp)+jlp];
                
            else if (i_ap_hit_qual_p3_a[ilp]==1'b1 && i_actionhalt_r==1'b1 && i_actionpt_status_r[ilp]==1'b0)
                i_ap_value_nxt[(AP_AMV_SIZE*ilp)+jlp] = i_ap_hit_value_a[(AP_AMV_SIZE*ilp)+jlp];   
              
   end



// Enable debug
// This is the Enable Debug flag (ED) in the DEBUG register
// If clock gating has been selected in the build then the ED bit must be
// set to enable actionpoints. If there is no clock gating then the 
// actionpoints are always enabled
assign i_en_debug_nxt = 
    (aux_write & auxdc(aux_addr,AX_DEBUG_N))==1'b1 
    ? aux_dataw[DB_DEBUG_N] 
    : (h_write & auxdc(h_addr,AX_DEBUG_N) & aux_access)==1'b1 
    ? h_dataw[DB_DEBUG_N] 
    : i_en_debug_r;
assign en_debug_r = i_en_debug_r;


// i_ap_hit_a             :   raw hits
// i_ap_hit_qual_a        :   hits qualified with pairing information
// i_ap_hit_qual_brk_a    :   qualified hits that are going to cause a brk
// i_ap_hit_qual_swi_a    :   qualified hits that are going to cause a swi


// Create vectors of valid hit bits for both BRK and SWI cases
// Create vectors of valid hit bits for both BRK and SWI cases
always @(
   i_ap_control_r or
   i_ap_hit_a or
   i_brcc_p2b_p3_a)
   begin : hit_value_PROC
   integer ilp; // Local loop variable
// Qualify the hit vector with pairing information
// If any actionpoint has the pairing bit set then it will only trigger
// if the next higher actionpoint triggers simultaneously. This works in a
// wraparound manner so that if AP7 is paired it will only trigger if AP0
// triggers

// Default value
   i_ap_hit_qual_a = {(NUM_APS){1'b0}};
   i_ap_hit_sing_a = {(NUM_APS){1'b0}};
   i_ap_hit_pair_a = {(NUM_APS){1'b0}};
   i_ap_hit_quad_a = {(NUM_APS){1'b0}};
   
   for (ilp = 0; ilp <= NUM_APS - 1; ilp = ilp + 1)
      begin
      if ((i_ap_control_r[(AP_AC_SIZE*((ilp+NUM_APS-1) % NUM_APS))
          +AP_AC_QUAD] == 1'b 1) ||
          (i_ap_control_r[(AP_AC_SIZE*((ilp+NUM_APS-2) % NUM_APS))
          +AP_AC_QUAD] == 1'b 1) ||
          (i_ap_control_r[(AP_AC_SIZE*((ilp+2*NUM_APS-3) % NUM_APS))
          +AP_AC_QUAD] == 1'b 1))
// Stop an actionpoint hitting individually if it is in a quad
         i_ap_hit_qual_a[ilp] = 1'b0;
      else if (i_ap_control_r[(AP_AC_SIZE*ilp)+AP_AC_QUAD] == 1'b 1)
         begin
// This is a quadded actionpoint so AND the hit bit with
// the next three actionpoints hit bits
         i_ap_hit_qual_a[ilp] = i_ap_hit_a[ilp] & 
                         i_ap_hit_a[(ilp+1) % NUM_APS] &
                         i_ap_hit_a[(ilp+2) % NUM_APS] &
                         i_ap_hit_a[(ilp+3) % NUM_APS];
// indicate in the i_ap_hit_pair_a vector which were the
// quadded actionpoint so their AMVs can begin updated

         i_ap_hit_quad_a[ilp] = i_ap_hit_a[ilp]  &  i_ap_hit_a[(ilp+1) % NUM_APS] & i_ap_hit_a[(ilp+2) % NUM_APS] &
                         i_ap_hit_a[(ilp+3) % NUM_APS] & avr_update(i_ap_control_r, ilp, i_brcc_p2b_p3_a);
                                                                           
         i_ap_hit_quad_a[(ilp+1) % NUM_APS] = i_ap_hit_a[ilp] & i_ap_hit_a[(ilp+1) % NUM_APS] & i_ap_hit_a[(ilp+2) % NUM_APS] &
                         i_ap_hit_a[(ilp+3) % NUM_APS] & avr_update(i_ap_control_r, (ilp+1) % NUM_APS, i_brcc_p2b_p3_a);
                                                          
         i_ap_hit_quad_a[(ilp+2) % NUM_APS] = i_ap_hit_a[ilp] & i_ap_hit_a[(ilp+1) % NUM_APS] & i_ap_hit_a[(ilp+2) % NUM_APS] &
                         i_ap_hit_a[(ilp+3) % NUM_APS] & avr_update(i_ap_control_r, (ilp+2) % NUM_APS, i_brcc_p2b_p3_a);
                                                 
         i_ap_hit_quad_a[(ilp+3) % NUM_APS] = i_ap_hit_a[ilp] & i_ap_hit_a[(ilp+1) % NUM_APS] & i_ap_hit_a[(ilp+2) % NUM_APS] &
                         i_ap_hit_a[(ilp+3) % NUM_APS] & avr_update(i_ap_control_r, (ilp+3) % NUM_APS, i_brcc_p2b_p3_a);
                         
         end
      else if (i_ap_control_r[(AP_AC_SIZE*((ilp+NUM_APS-1) % NUM_APS))
         +AP_AC_PAIR] == 1'b 1)
// Stop an actionpoint hitting if it is paired with the previous one
// ie the pair bit of the previous actionpoint is set
           i_ap_hit_qual_a[ilp] = 1'b0;   
      else if (i_ap_control_r[(AP_AC_SIZE*ilp)+AP_AC_PAIR] == 1'b 1)
         begin
// This is a paired actionpoint so AND the hit bit with the
// next actionpoint hit bit
         i_ap_hit_qual_a[ilp] = i_ap_hit_a[ilp] & 
                                i_ap_hit_a[(ilp+1) % NUM_APS];
// Also indicate in i_ap_hit_pair_a vector which was the paired
// actionpoint so that its AMV can also be updated
         i_ap_hit_pair_a[ilp] = i_ap_hit_a[ilp] & i_ap_hit_a[(ilp+1) % NUM_APS] & 
                                     avr_update(i_ap_control_r, ilp, i_brcc_p2b_p3_a);
                                                                 
         i_ap_hit_pair_a[(ilp+1) % NUM_APS] = i_ap_hit_a[ilp] & i_ap_hit_a[(ilp+1) % NUM_APS] & 
                                              avr_update(i_ap_control_r, (ilp+1) % NUM_APS, i_brcc_p2b_p3_a);
                                                                      

         end
      else
        begin
// Normal (non-paired) case
         i_ap_hit_qual_a[ilp] = i_ap_hit_a[ilp];   
         i_ap_hit_sing_a[ilp] = i_ap_hit_a[ilp] & avr_update(i_ap_control_r, ilp, i_brcc_p2b_p3_a);
         
       end
      end
   end

// Generate the vectors for two different actions depending on the
// contents of the ACTION bit
always @(i_ap_hit_qual_a or i_ap_hit_qual_r or i_ap_control_r or i_brcc_p2b_p3_a or p2iv)
   begin : hit_qual_PROC
   integer ilp; // Local loop variable
   for (ilp = 0; ilp <= NUM_APS - 1; ilp = ilp + 1)
      begin

      // for ld/st/sr/lr (stage 3) instructions that complete after or when the processor has halted
      i_ap_hit_qual_p3_a[ilp] = i_ap_hit_qual_a[ilp] &         
                               ~i_ap_control_r[(AP_AC_SIZE*ilp)+AP_AC_ACTION] &
                               
                               ((i_ap_control_r[(AP_AC_SIZE*ilp)+1] & ~i_ap_control_r[(AP_AC_SIZE*ilp)+2] & ~i_ap_control_r[(AP_AC_SIZE*ilp)+3]) |
                                (~i_ap_control_r[(AP_AC_SIZE*ilp)+1] & i_ap_control_r[(AP_AC_SIZE*ilp)+2] & ~i_ap_control_r[(AP_AC_SIZE*ilp)+3]));
                     
      // i_ap_hit_qual_brk_a is used to signify to the core that the triggering action-point should
      // halt the processor, covers all ap types except SWI. 
                       
      i_ap_hit_qual_brk_a[ilp] = i_ap_hit_qual_a[ilp] &
                                ~i_ap_control_r[(AP_AC_SIZE*ilp)+AP_AC_ACTION] & 
         
                                // if it's a general watch point we can trigger
                                (~(~i_ap_control_r[(AP_AC_SIZE*ilp)+1] & ~i_ap_control_r[(AP_AC_SIZE*ilp)+2] &
                                 ~i_ap_control_r[(AP_AC_SIZE*ilp)+3]) |
           
                                   // if it's a Opcode or PC and brcc ahead in the pipeline wait until it resolves
                                (~i_ap_control_r[(AP_AC_SIZE*ilp)+1] & ~i_ap_control_r[(AP_AC_SIZE*ilp)+2] &
                                 ~i_ap_control_r[(AP_AC_SIZE*ilp)+3] & ~i_brcc_p2b_p3_a)); 

      // i_ap_hit_qual_pc_brk_a is used to signify to the core that the triggering action-point should
      // cause the processor to halt like the BRK instruction. This only effects PC and Opcode type
      // action-points.
      
      i_ap_hit_qual_pc_brk_a[ilp] = (i_ap_hit_qual_a[ilp] | (i_ap_hit_qual_r[ilp] & p2iv)) &
                                    ~i_ap_control_r[(AP_AC_SIZE*ilp)+AP_AC_ACTION] & 
                                    ~i_ap_control_r[(AP_AC_SIZE*ilp)+1] & ~i_ap_control_r[(AP_AC_SIZE*ilp)+2] &
                                    ~i_ap_control_r[(AP_AC_SIZE*ilp)+3];                   
         
      // i_ap_hit_qual_swi_a is used to signify to the core that the triggering action-point should
      // create a software interupt (SWI).
               
      i_ap_hit_qual_swi_a[ilp] =  i_ap_hit_qual_a[ilp] &
                                  i_ap_control_r[(AP_AC_SIZE*ilp)+AP_AC_ACTION];  

            
      end
   end


// determine if a load/store/lr/sr triggers when the processor is about to be halted or is halted
assign i_ap_p3_qual_hit_a  = |i_ap_hit_qual_p3_a;

//  or together all the individual hit bits into a combined hit
assign i_ap_hit_comb_brk_a = |i_ap_hit_qual_brk_a;                  // for aux/ld/st watch-points

assign i_ap_hit_swi_a      = |i_ap_hit_qual_swi_a;                  // for SWI instrutions
assign i_ap_hit_comb_swi_a = i_ap_hit_swi_a & ~i_brcc_p2b_p3_a;

assign i_ap_pc_brk_a       = |i_ap_hit_qual_pc_brk_a;               // for PC/Opcode breakpoint
assign actionpt_pc_brk_a   = i_ap_pc_brk_a & ~i_brcc_p2b_p3_a;  

// generate a stall if action-point hit in stage 2 and brcc in stages 2b or 3
assign p2_ap_stall_a       = (i_ap_pc_brk_a | i_ap_hit_swi_a) & i_brcc_p2b_p3_a; 


// Connect up ports. This is done this way because although there
// are a variable number of actionpoints, there are a fixed number
// of outputs to the auxiliary register read logic so default
// values have to be assigned.
always @(i_ap_value_r or i_ap_control_r or i_ap_mask_r)
begin : pcon_PROC
    ap_ahv0 = {AP_AMV_SIZE{1'b0}};
    ap_ahv1 = {AP_AMV_SIZE{1'b0}};
    ap_ahv2 = {AP_AMV_SIZE{1'b0}};
    ap_ahv3 = {AP_AMV_SIZE{1'b0}};
    ap_ahv4 = {AP_AMV_SIZE{1'b0}};
    ap_ahv5 = {AP_AMV_SIZE{1'b0}};
    ap_ahv6 = {AP_AMV_SIZE{1'b0}};
    ap_ahv7 = {AP_AMV_SIZE{1'b0}};
    ap_ahc0 = {AP_AMV_SIZE{1'b0}};
    ap_ahc1 = {AP_AMV_SIZE{1'b0}};
    ap_ahc2 = {AP_AMV_SIZE{1'b0}};
    ap_ahc3 = {AP_AMV_SIZE{1'b0}};
    ap_ahc4 = {AP_AMV_SIZE{1'b0}};
    ap_ahc5 = {AP_AMV_SIZE{1'b0}};
    ap_ahc6 = {AP_AMV_SIZE{1'b0}};
    ap_ahc7 = {AP_AMV_SIZE{1'b0}};
    ap_ahm0 = {AP_AMV_SIZE{1'b0}};
    ap_ahm1 = {AP_AMV_SIZE{1'b0}};
    ap_ahm2 = {AP_AMV_SIZE{1'b0}};
    ap_ahm3 = {AP_AMV_SIZE{1'b0}};
    ap_ahm4 = {AP_AMV_SIZE{1'b0}};
    ap_ahm5 = {AP_AMV_SIZE{1'b0}};
    ap_ahm6 = {AP_AMV_SIZE{1'b0}};
    ap_ahm7 = {AP_AMV_SIZE{1'b0}};

// now assign the actual hit values from as many
// actionpoints as there are

    ap_ahv0 = i_ap_value_r[(AP_AMV_SIZE*(0+1))-1 : AP_AMV_SIZE*0];
    ap_ahc0 = i_ap_control_r[(AP_AC_SIZE*(0+1))-1 : AP_AC_SIZE*0];
    ap_ahm0 = i_ap_mask_r[(AP_AMV_SIZE*(0+1))-1 : AP_AMV_SIZE*0];
    ap_ahv1 = i_ap_value_r[(AP_AMV_SIZE*(1+1))-1 : AP_AMV_SIZE*1];
    ap_ahc1 = i_ap_control_r[(AP_AC_SIZE*(1+1))-1 : AP_AC_SIZE*1];
    ap_ahm1 = i_ap_mask_r[(AP_AMV_SIZE*(1+1))-1 : AP_AMV_SIZE*1];
end

assign actionpt_brk_a = i_ap_hit_comb_brk_a; 
assign actionpt_swi_a = i_ap_hit_comb_swi_a; 
assign actionpt_status_r = i_actionpt_status_r;

// Qualify the aux access bits so that host accesses are not seen
// aux_access indcates a host access but only when en is low
assign i_aux_read_core_a = aux_read & ~(aux_access & ~en);
assign i_aux_write_core_a = aux_write & ~(aux_access & ~en);

//  This inserts as many instances of ap_compare as there are actionpoints
ap_compare U_ap_compare0 (
   .clk_debug(clk_debug),
   .en_debug_r(i_en_debug_r),
   .rst_a(rst_a),
   .mc_addr(mc_addr), 
   .dwr(dwr), 
   .drd(drd), 
   .aux_addr(aux_addr), 
   .aux_dataw(aux_dataw), 
   .aux_datar(aux_datar), 
   .ap_param0(ap_param0), 
   .ap_param1(ap_param1), 
   .en(en),
   .p2_currentpc_r(i_p2_currentpc_r), 
   .kill_p2_a(kill_p2_a),
   .p2_iw_r(p2_iw_r),       
   .p2iv(p2iv), 
   .mload(mload), 
   .mstore(mstore), 
   .ldvalid(ldvalid), 
   .p2b_jmp_holdup_a(p2b_jmp_holdup_a), 
   .aux_read_core_a(i_aux_read_core_a), 
   .aux_write_core_a(i_aux_write_core_a), 
   .ap_param0_read(ap_param0_read), 
   .ap_param0_write(ap_param0_write), 
   .ap_param1_read(ap_param1_read), 
   .ap_param1_write(ap_param1_write), 
   .ap_control_r(i_ap_control_r[(AP_AC_SIZE*(0+1))-1 : AP_AC_SIZE*0]), 
   .ap_value_r(i_ap_value_r[(AP_AMV_SIZE*(0+1))-1 : AP_AMV_SIZE*0]), 
   .ap_mask_r(i_ap_mask_r[(AP_AMV_SIZE*(0+1))-1 : AP_AMV_SIZE*0]), 

   .ap_hit_a(i_ap_hit_a[0]), 
   .ap_hit_value_a(i_ap_hit_value_a[(AP_AMV_SIZE*(0+1))-1 : AP_AMV_SIZE*0])); 
ap_compare U_ap_compare1 (
   .clk_debug(clk_debug),
   .en_debug_r(i_en_debug_r),
   .rst_a(rst_a),
   .mc_addr(mc_addr), 
   .dwr(dwr), 
   .drd(drd), 
   .aux_addr(aux_addr), 
   .aux_dataw(aux_dataw), 
   .aux_datar(aux_datar), 
   .ap_param0(ap_param0), 
   .ap_param1(ap_param1), 
   .en(en),
   .p2_currentpc_r(i_p2_currentpc_r), 
   .kill_p2_a(kill_p2_a),
   .p2_iw_r(p2_iw_r),       
   .p2iv(p2iv), 
   .mload(mload), 
   .mstore(mstore), 
   .ldvalid(ldvalid), 
   .p2b_jmp_holdup_a(p2b_jmp_holdup_a), 
   .aux_read_core_a(i_aux_read_core_a), 
   .aux_write_core_a(i_aux_write_core_a), 
   .ap_param0_read(ap_param0_read), 
   .ap_param0_write(ap_param0_write), 
   .ap_param1_read(ap_param1_read), 
   .ap_param1_write(ap_param1_write), 
   .ap_control_r(i_ap_control_r[(AP_AC_SIZE*(1+1))-1 : AP_AC_SIZE*1]), 
   .ap_value_r(i_ap_value_r[(AP_AMV_SIZE*(1+1))-1 : AP_AMV_SIZE*1]), 
   .ap_mask_r(i_ap_mask_r[(AP_AMV_SIZE*(1+1))-1 : AP_AMV_SIZE*1]), 

   .ap_hit_a(i_ap_hit_a[1]), 
   .ap_hit_value_a(i_ap_hit_value_a[(AP_AMV_SIZE*(1+1))-1 : AP_AMV_SIZE*1])); 


endmodule // module actionpoints
