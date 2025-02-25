// ARCconvert convert_off
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
// Pipeline display system.
//
module pdisp (
              );
`ifndef GATE_LEVEL_SIMULATION
`include "arcutil_pkg_defines.v" 
`include "arcutil.v" 
`include "extutil.v" 
`include "xdefs.v"

`ifdef TTVTOC

`else

`include "pdisp_pkg_defines.v" 
`include "asmutil.v" 

//synopsys translate_off

wire                     clk_ungated; //  ungated clock
wire                     rst_a;        //  system reset
wire                     en;         //  system go
wire    [3:0]            aluflags_r; 
wire    [PC_MSB:0]       currentpc_r; 
wire    [DATAWORD_MSB:0] p1iw_aligned_a; 
wire                     ivalid_aligned; 
wire    [4:0]            p2opcode;
wire    [4:0]            p2b_opcode;
wire    [4:0]            p3opcode;
wire                     p2iv; 
wire                     p2b_iv; 
wire                     p3iv; 
wire    [31:0]           wbdata; 
wire    [5:0]            wba; 
wire                     wben; 
wire                     ldvalid; 
wire    [5:0]            regadr; 
wire    [31:0]           drd; 
wire    [31:3]           irq; 
wire                     mem_err; 
wire                     en1; 
wire                     en2; 
wire                     en2b; 
wire                     en3;
wire                     p2_dopred;
wire                     p4_docmprel; 
wire                     p1int; 
wire                     p2int;
wire                     p2bint;
wire                     p3int; 
wire                     xholdup2; 
wire                     xholdup2b; 
wire                     xholdup3; 
wire                     p2limm; 
wire                     aux_read; 
wire                     aux_write; 
wire                     aux_access; 
wire    [31:0]           aux_datar; 
wire    [31:0]           aux_dataw;
wire    [31:0]           aux_addr; 
wire                     core_access; 
wire    [31:0]           dwr; 
wire                     e1flag_r; 
wire                     e2flag_r; 
wire    [5:0]            fs2a; 
wire    [31:0]           h_addr; 
wire    [31:0]           h_datar; 
wire    [31:0]           h_dataw; 
wire                     h_read; 
wire                     h_write; 
wire                     halt; 
wire                     hold_host; 
wire                     ifetch_aligned; 
wire    [PC_MSB:0]       int_vec; 
wire                     ivic; 
wire                     ldvalid_wb; 
wire    [PC_MSB:0]       loopend_r; 
wire    [PC_MSB:0]       loopstart_r;
wire                     lpending; 
wire    [31:0]           mc_addr; 
wire                     mload; 
wire                     mstore; 
wire                     mwait; 
wire    [PC_MSB:0]       next_pc; 
wire                     ic_busy; 
wire                     noaccess; 
wire                     nocache; 
wire                     p3lr; 
wire                     p3sr; 
wire                     pcen; 
wire                     p4iv; 
wire    [5:0]            s1a; 
wire    [5:0]            s2a; 
wire                     sex; 
wire    [1:0]            size; 
wire                     sr_xhold_host_a; 
wire                     x_idecode3;
wire                     x_multic_wben;
wire                     x_snglec_wben;
wire    [3:0]            xflags; 
wire                     xsetflags; 
wire                     xstep; 

reg     [1:(`STRING_LENGTH + 2) * 8] i_sREG1_f; 
reg     [1:(`STRING_LENGTH + 2) * 8] i_sREG2_f; 
reg     [1:(`STRING_LENGTH + 2) * 8] i_sREG2b_f; 
reg     [1:(`STRING_LENGTH + 2) * 8] i_sREG3_f; 
reg     [1:(`STRING_LENGTH + 2) * 8] i_sREG4_f; 
reg     [1:`STRING_LENGTH * 8]  i_sREG1; 
reg     [1:`STRING_LENGTH * 8]  i_sREG2; 
reg     [1:`STRING_LENGTH * 8]  i_sREG2b; 
reg     [1:`STRING_LENGTH * 8]  i_sREG3; 
reg     [1:`STRING_LENGTH * 8]  i_sREG4; 
reg     [31:0]              i_drd_r; 
reg     [5:0]               i_regadr_r; 
reg                         i_ldvalid_r; 
reg                         i_h_read_r; 
reg                         i_hold_host_r; 
reg                         i_ldv_r0r31_r; 

wire                        x_wben;
reg                         x_wben_tmp;
reg     [31:0]              wb_aux_addr;
reg     [31:0]              wb_aux_dataw;
reg                         wb_aux_write;
reg     [31:0]              wb_mc_addr;
reg     [31:0]              wb_dwr;
reg                         wb_st;

integer                     sim_FLAG2; 
integer                     sim_FLAG;
integer                     sim_iform; 
integer                     sim_init_done; 
integer                     sim_merged; 
integer                     sim_s2i; 
integer                     sim_si; 
integer                     sim_toggle; 
integer                     sim_wait_count; 
reg     [1:(`STRING_LENGTH + 2) * 8]  sim_REG1_f; 
reg     [1:(`STRING_LENGTH + 2) * 8]  sim_REG2_f; 
reg     [1:(`STRING_LENGTH + 2) * 8]  sim_REG3_f; 
reg     [1:(`STRING_LENGTH + 2) * 8]  sim_REG4_f; 
reg     [1:100 * 8 * 8 * 8] sim_s2; 
reg     [1:100 * 8 * 8 * 8] sim_s; 
reg     [1:100 * 8 * 8 * 8] sim_tmpstr; 
reg     [1:2 * 8]           sim_gtstr; 
reg     [1:2 * 8]           sim_ltstr; 
reg     [1:5 * 8]           sim_fstr; 
reg     [1:6]               sim_ftype [0:1];
reg     [1:`STRING_LENGTH * 8]  sim_REG1;
reg     [1:`STRING_LENGTH * 8]  sim_REG2;
reg     [1:`STRING_LENGTH * 8]  sim_REG2_limm;
reg     [1:`STRING_LENGTH * 8]  sim_REG2b;
reg     [1:(`STRING_LENGTH+2) * 8] sim_REG2b_f;
reg     [1:`STRING_LENGTH * 8]  sim_REG2b_limm; 
reg     [1:`STRING_LENGTH * 8]  sim_REG3; 
reg     [1:`STRING_LENGTH * 8]  sim_REG4; 
reg     [PC_MSB:0]          sim_ocurrentpc_r; 
reg     [PC_MSB:0]          sim_onext_pc; 
reg     [31:3]              sim_oirq; 
reg     [3:0]               sim_oaluflags_r; 
reg                         sim_WKf; 
reg                         sim_Wk; 
reg                         sim_ibase; 
reg                         sim_l; 
reg                         sim_oen1; 
reg                         sim_oen2; 
reg                         sim_oen2b; 
reg                         sim_oen3; 
reg                         sim_oen; 
reg                         sim_oifetch_aligned; 
reg                         sim_oivalid_aligned; 
reg                         sim_op1int; 
reg                         sim_op2int; 
reg                         sim_op2bint; 
reg                         sim_op2iv; 
reg                         sim_op2biv; 
reg                         sim_op3iv; 
reg                         sim_owben; 
reg                         sim_qffb; 
reg                         sim_qffe; 
reg                         sim_tmpf; 
reg                         sim_tmpi; 
reg                         sim_wks; 
reg     [191:0]             ld_op;
reg     [279*2:0]             nfp_wb_op;
reg     [279*2:0]             wb_op;
reg     [31:0]              disp_currentpc_r;
wire                        i_p2_jmp_a;
reg                         i_p2b_jmp_r;
wire                        i_p2b_jmp_a;
reg                         i_p3_jmp_r;
wire                        i_p3_jmp_a;
reg                         i_p4_jmp_r;
wire                        i_p4_jmp_a;
   
// file handle
integer                     file, ret;

//array to hold label
reg     [1:`MAX_LABEL_LEN*8] string_array[0:`NO_OF_LABELS];
reg     [1:`MAX_LABEL_LEN*8] current_str,dummy;
      
//array to hold pc values of above labels
reg     [31:0]              integer_array[0:`NO_OF_LABELS];
reg     [31:0]              current_int;

//Holds current label type
reg     [8:1]               current_type;
 
//array pointer
integer                     idx;

//used to keep track of the the total number of labels found
integer                      total_labels;
   
integer                      start_of_file;
   
integer                      pc_valid;
integer                      pdisp_asm_label_update;
         
   
reg     [1:`MAX_LABEL_LEN*8]  nearest_label;
reg     [31:0]               nearest_label_pc;
reg     [PC_MSB:0]           pc;
   
integer                      search_idx;
integer                      offset;
   
reg     [1:80]               sim_ck_time; 
reg                          signal_checkers_reset_has_been_applied;
reg                          signal_checkers_reset_has_been_removed;
   
time                         sim_pdisp_st_time; // 2500000 ns; -- 304500 ns;
   
  
  assign  clk_ungated = board.icore_chip.icore_sys.icpu_isle.ick_gen.clk_ungated;
  assign  rst_a = board.icore_chip.icore_sys.icpu_isle.iio_flops.rst_a;
  assign  irq = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.irq;
  assign  mem_err = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.memory_error;
  assign  int_vec = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.iint_unit.int_vec;
  assign  en = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iauxiliary.en;
  assign  aluflags_r =  board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iauxiliary.aluflags_r;
  assign  currentpc_r = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.currentpc_r;
  assign  p1iw_aligned_a = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iregisters.p1iw_aligned_a;
  assign  ivalid_aligned = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iregisters.ivalid_aligned;
  assign  p2opcode = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.p2opcode;
  assign  p2b_opcode = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.p2b_opcode;
  assign  p3opcode = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.p3opcode;
  assign  p2iv = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.p2iv;
  assign  p2b_iv = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.p2b_iv;
  assign  p3iv = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.p3iv;
  assign  wbdata = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.ialu.wbdata;
  assign  wba = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.wba;
  assign  wben = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.wben;
  assign  ldvalid = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.ldvalid;
  assign  regadr = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.regadr;
  assign  drd = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iregisters.drd;
  assign  en1 = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.en1;
  assign  en2 = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.en2;
  assign  en2b = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.en2b;
  assign  en3 = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.en3;
  assign  p2_dopred = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.p2_dopred;
  assign  p4_docmprel = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.p4_docmprel;
  assign  p1int = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.p1int;
  assign  p2int = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.p2int;
  assign  p2bint = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.p2bint;
  assign  p3int = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.p3int;
  assign  xholdup2 = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.ixrctl.xholdup2;
  assign  xholdup2b = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.ixrctl.xholdup2b;
  assign  xholdup3 = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.ixrctl.xholdup3;
  assign  p2limm = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.p2limm;
  assign  aux_read = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iauxiliary.aux_read;
  assign  aux_write = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iauxiliary.aux_write;
  assign  aux_access = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iauxiliary.aux_access;
  assign  aux_datar = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iauxiliary.aux_datar;
  assign  aux_dataw = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iauxiliary.aux_dataw;
  assign  aux_addr = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iauxiliary.aux_addr;
  assign  core_access = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iauxiliary.core_access;
  assign  dwr = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iregisters.dwr;
  assign  e1flag_r = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iauxiliary.e1flag_r;
  assign  e2flag_r = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iauxiliary.e2flag_r;
  assign  fs2a = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.fs2a;
  assign  h_addr = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iauxiliary.h_addr;
  assign  h_datar = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iauxiliary.h_datar;
  assign  h_dataw = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iauxiliary.h_dataw;
  assign  h_read = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iauxiliary.h_read;
  assign  h_write = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iauxiliary.h_write;
  assign  halt = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iauxiliary.halt;
  assign  hold_host = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iauxiliary.hold_host;
  assign  ifetch_aligned = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.ifetch_aligned;
  assign  ivic = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.ivic;
  assign  ldvalid_wb = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.ialu.ldvalid_wb;
  assign  loopend_r = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iregisters.loopend_r;
  assign  loopstart_r = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iregisters.loopstart_r;
  assign  lpending = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.lpending;
  assign  mc_addr = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.ialu.mc_addr;
  assign  mload = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.mload;
  assign  mstore = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.mstore;
  assign  mwait = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.mwait;
  assign  next_pc = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.next_pc;
  assign  ic_busy = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iregisters.ic_busy;
  assign  noaccess = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iauxiliary.noaccess;
  assign  nocache = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.nocache;
  assign  p3lr = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.p3lr;
  assign  p3sr = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.p3sr;
  assign  pcen = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.pcen;
  assign  p4iv = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.irctl.p4iv;
  assign  s1a = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.s1a;
  assign  s2a = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iauxiliary.s2a;
  assign  sex = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.sex;
  assign  size = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.size;
  assign  sr_xhold_host_a = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iregisters.sr_xhold_host_a;
  assign  x_idecode3 = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.x_idecode3;
  assign  x_multic_wben = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.x_multic_wben;
  assign  x_snglec_wben = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.x_snglec_wben;
  assign  xflags = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.ialu.xflags;
  assign  xsetflags = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.icontrol.ixrctl.xsetflags;
  assign  xstep = board.icore_chip.icore_sys.icpu_isle.iarc600.iquarc.iauxiliary.xstep;

   // ------------------------ Pipeline display process -------------------------
   // 
   //  Note host-access display process is in hostmod.v
   initial 
     begin
        sim_wait_count = 0;
        sim_init_done  = 0;
        sim_pdisp_st_time = 0 ;// 2500000 ; // 304500 ; 
     end
   
   //  Delay ldvalid for a cycle --
   //
   always @(posedge clk_ungated or posedge rst_a)
     begin : ldreg_PROC
        if (rst_a == 1'b 1)
          begin
             i_ldvalid_r   <= 1'b 0;  
             i_ldv_r0r31_r <= 1'b 0;    
             i_regadr_r    <= {6{1'b 0}};  
             i_drd_r       <= {32{1'b 0}};
             x_wben_tmp    <= 1'b 0;
             wb_aux_addr   <= {32{1'b 0}};
             wb_aux_dataw  <= {32{1'b 0}};
             wb_aux_write  <= 1'b 0;
             wb_dwr        <= {32{1'b 0}};
             wb_mc_addr    <= {32{1'b 0}};
             wb_st         <= 1'b 0;
          end
        else
          begin
             i_ldvalid_r   <= ldvalid;    
             i_ldv_r0r31_r <= ldvalid & ~regadr[5];
             i_regadr_r    <= regadr;  
             i_drd_r       <= drd;
             x_wben_tmp    <= x_multic_wben | x_snglec_wben;
             wb_st         <= mstore & en3 & p3iv;
             wb_aux_write  <= aux_write & en3 & p3iv;

             if (en3 == 1'b1 & p3iv == 1'b1)
               begin
                  wb_aux_addr   <= aux_addr;
                  wb_aux_dataw  <= aux_dataw;
                  wb_dwr        <= dwr;
                  wb_mc_addr    <= mc_addr;
               end // else: !if(en3 == 1'b1 & p3iv == 1'b1)
          
          end
     end // block: ldreg

   assign x_wben = x_wben_tmp & wben;

`ifndef IS_ARCv1_TB

   initial
      begin : symbol_file_reader
         
         if (`PDISP_USE == 1'b 1 && `PDISP_LABEL == 1'b 1)
            begin
               
               start_of_file          = 0;
               pdisp_asm_label_update = 1;
               
               file = $fopenr("init_mem.sym");
               if (file == 0)
                  begin
                     $display("***************************************************");
                     $display("* WARNING init_mem.sym or fileio pli not found!!! *");
                     $display("* PDisp assembler label update is disabled        *");
                     $display("***************************************************");
                     disable symbol_file_reader;
                     pdisp_asm_label_update = 0;
                     
                  end 
               
               string_array[0]  = "code_address_0";
               integer_array[0] = 0;
               idx              = 1;      // entry 0 is taken by default symbol "base"
               
               while (!$feof(file))
                  begin
                     
                     if (start_of_file == 0)
                        begin
                           //skip all the information strings at top of file
                           ret = $fscanf(file,"%s %s %s %s",dummy,dummy,dummy,dummy);
                           start_of_file = 1;
                        end                        

                      ret = $fscanf(file,"%h %c",current_int,current_type);
                      ret = $fgets(current_str,(`MAX_LABEL_LEN*8),file);
                      current_str = current_str[1:(`MAX_LABEL_LEN*8)-8]; // remove "\n"
                     
                     // Read it in if it's a local or global text symbol and is not " $t".
                     if (((current_type == "t") | (current_type == "T")) & 
                         (current_str[(`MAX_LABEL_LEN*8-16-7) : (`MAX_LABEL_LEN*8)] != 24'h202474))
                        begin
                           
                           string_array[idx]  = current_str;
                           integer_array[idx] = current_int;
                           idx          = idx + 1;
                           total_labels = idx;
                           
                        end                 
                  end // while (!$feof(file))
               ret = $fcloser(file);
            end // if (`PDISP_USE == 1'b 1 && `PDISP_LABEL == 1'b 1)
      end // block: symbol_file_reader

`endif
  
   always 
      begin : sim

        @ ( posedge clk_ungated ); 
        sim_ck_time = $time;
        
        //  Initialisation section
        // 
        if (sim_init_done == 0)
          begin
             sim_init_done = 1; 
             
          end // if (sim_init_done == 0)

        //  Pipeline flow display --
        // 
        //  This is the main part of pdisp, Pdisp is disabled if PDISP_USE is 0, if PDISP_CHGONLY is 1 then
        //  Pdisp does not update if there are no signal changes.
        //  PDisp Displays long immediates of instructions depending on the flag variable and the instruction 
        //  which has a long immediate in stage 2 is still valid.
        //  if (state has not changed) AND (only displays state changes) OR not using pdisp 
        // 
        if ((ivalid_aligned == sim_oivalid_aligned && 
             ifetch_aligned == sim_oifetch_aligned && 
             p2iv == sim_op2iv    && 
             p2b_iv == sim_op2biv && 
             p3iv == sim_op3iv    && 
             p1int == sim_op1int  && 
             p2int == sim_op2int  && 
             currentpc_r == sim_ocurrentpc_r && 
             next_pc == sim_onext_pc && 
             p2bint == sim_op2bint  &&
             irq == sim_oirq && 
             aluflags_r == sim_oaluflags_r && 
             en == sim_oen     && 
             en1 == sim_oen1   && 
             en2 == sim_oen2   &&
             en2b == sim_oen2b && 
             en3 == sim_oen3   && 
             wben == 1'b 0     &&
             i_ldvalid_r == 1'b 0 && 
             `PDISP_CHGONLY == 1'b 1) || 
             `PDISP_USE == 1'b 0 || 
             ($time < sim_pdisp_st_time))
           
          begin
             sim_wait_count = sim_wait_count + 1;   
             sim_toggle     = 1;    
          end
        else
          begin
             
             //  Save the current signal values for state change comparison 
             // 
             sim_oivalid_aligned = ivalid_aligned;  
             sim_oifetch_aligned = ifetch_aligned;  
             sim_op2iv = p2iv;  
             sim_op2biv = p2b_iv;
             sim_op3iv = p3iv;  
             sim_op1int = p1int;    
             sim_op2int = p2int; 
             sim_op2bint = p2bint;   
             sim_ocurrentpc_r = currentpc_r;    
             sim_onext_pc = next_pc;    
             sim_oirq = irq;    
             sim_oaluflags_r = aluflags_r;  
             sim_oen = en;  
             sim_oen1 = en1;    
             sim_oen2 = en2;
             sim_oen2b = en2b;    
             sim_oen3 = en3;    
             sim_owben = wben;
             
             //  If pdisp has been waiting for a state change and the state has just changed report the wait
             // 
             if (sim_toggle == 1)
               begin
                  sim_toggle = 0;   
                  $display ("*************** No State Change for %0d clock cycles ***************", sim_wait_count); 
                  sim_wait_count = 0;
               end // if (sim_toggle == 1)            

             if (`PDISP_LABEL == 1'b 1)
                begin
                  if( pdisp_asm_label_update == 1)
                   begin  
                      pc_valid = chk_vec_31_0(currentpc_r);
                      
                      if (pc_valid == `TRUE)
                      begin
                        pc         = currentpc_r;  
			search_idx = 0;            // search always starts from 0 in case of a branch
			    
			// find best match to current pc in symbol array                           
                        while ((search_idx < total_labels) && (integer_array[search_idx] <= pc))
                        begin
                          search_idx = search_idx + 1;
                        end
			    
			// copy best match and compute offset (which might be 0 for a symbol address)
                        nearest_label    = string_array [search_idx-1];
                        nearest_label_pc = integer_array[search_idx-1];
                        offset           = pc - nearest_label_pc;
                      end   // if (pc_valid == `TRUE)
                  end       // if ( pdisp_asm_label_update == 1)
                 else
                  begin
                        nearest_label    = 0;
                        nearest_label_pc = 0;
                        offset           = 0;
                  end       // else: !if( pdisp_asm_label_update == 1)
                end         // if (`PDISP_LABEL == 1'b 1)
             
             //  If instruction in stage 2 does not have a limm or if is invalid
             //  disassemble p1iw_aligned_a and return a string
             //
             if (p2limm == 1'b 0  & ivalid_aligned == 1'b 1)
               begin
                  disass(p1iw_aligned_a, sim_REG1, sim_FLAG); 
               end
             else
               begin
                  sim_REG1 = "limm         ";   
               end

             sim_REG1_f = pipeoperation(en, sim_REG1, ivalid_aligned, en1, p1int);  
             sim_REG2_f = pipeoperation(en, sim_REG2, p2iv, en2, p2int);   
             sim_REG2b_f = pipeoperation(en, sim_REG2b, p2b_iv, en2b, p2bint); 
             sim_REG3_f = pipeoperation(en, sim_REG3, p3iv, en3, p3int);    

        //  Display pipe line information
        //  Display time, flags , PC, Data Word, Interrupts,Instruction in
        //  Stage 1, Instruction in Stage 2, 
        //  Instruction in Stage 3 info, write back information, xholdup12,
        //  xholdup3
        //  Indicate if the ARC is stopped, stalled or empty
        //
        $timeformat (-9, 0, "ns", 12) ;
        
        if ($realtime != 0)
          begin
          
             // register writeback
             wb_op = wbop(wb_aux_write, wb_aux_addr, wb_aux_dataw, wb_st,
                          wb_mc_addr, wb_dwr, i_p4_jmp_a,x_wben,wben,wba,1'b0,
                          wbdata);

             // returning load
             ld_op = ldop(i_regadr_r,i_ldv_r0r31_r,i_drd_r);

             // for non 4 port register file
             nfp_wb_op = wbop(wb_aux_write,wb_aux_addr, wb_aux_dataw,wb_st,
                              wb_mc_addr,wb_dwr, i_p4_jmp_a,x_wben,wben,wba,
                              i_ldvalid_r,wbdata);

             disp_currentpc_r = currentpc_r;
          
             if (`PDISP_LABEL == 1'b 1)
               begin

                  if (RCTL_4P_REG_FILE)
                    begin
                       
                        $display ("# %t : %0s %H  %H %0s %0s %0s %0s %0s %0s %0s %0s %0s %0s %0s", 
                                       $realtime, 
                                       flagdisp(aluflags_r), 
                                       disp_currentpc_r, 
                                       p1iw_aligned_a, 
                                       xinfo(p1iw_aligned_a, ivalid_aligned, 
                                       irq[3], irq[4], irq[5], irq[6],
                                       irq[7], irq[8], irq[9], irq[10],
                                       irq[11], irq[12], irq[13], 
                                       irq[14], irq[15], irq[16], 
                                       irq[17], irq[18], irq[19], 
                                       irq[20], irq[21], irq[22], 
                                       irq[23], irq[24], irq[25],
                                       irq[26], irq[27], irq[28], 
                                       irq[29], irq[30], irq[31], 
                                       1'b0), 
                                       pipeoperation(en, sim_REG1, ivalid_aligned, en1, p1int), 
                                       pipeoperation(en, sim_REG2, p2iv, en2, p2int), 
                                       pipeoperation(en, sim_REG2b, p2b_iv, en2b, p2bint), 
                                       pipeoperation(en, sim_REG3, p3iv, en3, p3int),
                                       wb_op,
                                       ld_op,
                                       label_output(nearest_label,offset,en,en1,pc_valid,ivalid_aligned),
                                       dostr2(xholdup2),
                                       dostr2b(xholdup2b),
                                       dostr3(xholdup3));

                       //  if(wben && wb_st)
                       //  begin
                       //     $display("# %t : \n\t\t %0s %0s %0s %0s %0s %0s",
                       //              $realtime,
                       //              wbop(wb_aux_write, wb_aux_addr, wb_aux_dataw, wb_st, wb_mc_addr,
                       //                    wb_dwr, p4_docmprel, x_wben, 1'b0, wba, 1'b0, wbdata),
                       //              ld_op,
                       //              label_output(nearest_label,offset,en,en1,pc_valid,ivalid_aligned),
                       //              dostr2(xholdup2),
                       //              dostr2b(xholdup2b),
                       //              dostr3(xholdup3));
                       //  end
                       
                    end // if (RCTL_4P_REG_FILE)
                  else
                    begin

                        // time flags PC P1iw irq s1 s2 s2b s3                      
                        $display ("# %t : %0s %H  %H %0s %0s %0s %0s %0s %0s %0s %0s %0s %0s", 
                                      $realtime, 
                                      flagdisp(aluflags_r), 
                                      disp_currentpc_r, 
                                      p1iw_aligned_a,  
                                      xinfo(p1iw_aligned_a, ivalid_aligned, 
                                      irq[3], irq[4], irq[5], irq[6],
                                      irq[7], irq[8], irq[9], irq[10],
                                      irq[11], irq[12], irq[13], 
                                      irq[14], irq[15], irq[16], 
                                      irq[17], irq[18], irq[19], 
                                      irq[20], irq[21], irq[22], 
                                      irq[23], irq[24], irq[25],
                                      irq[26], irq[27], irq[28], 
                                      irq[29], irq[30], irq[31],
                                      1'b0), 
                                      pipeoperation(en, sim_REG1, ivalid_aligned, en1, p1int), 
                                      pipeoperation(en, sim_REG2, p2iv, en2, p2int), 
                                      pipeoperation(en, sim_REG2b, p2b_iv, en2b, p2bint), 
                                      pipeoperation(en, sim_REG3, p3iv, en3, p3int),
                                      nfp_wb_op, 
                                      label_output(nearest_label,offset,en,en1,pc_valid,ivalid_aligned),
                                      dostr2(xholdup2),
                                      dostr2b(xholdup2b),
                                      dostr3(xholdup3));

                         //if(wben && wb_st)
                         //begin
                         //   $display("# %t : \n\t\t %0s %0s %0s %0s %0s %0s",
                         //            $realtime,
                         //            wbop(wb_aux_write, wb_aux_addr, wb_aux_dataw, wb_st, wb_mc_addr,
                         //                  wb_dwr, p4_docmprel, x_wben, 1'b0, wba, 1'b0, wbdata),
                         //            ld_op,
                         //            label_output(nearest_label,offset,en,en1,pc_valid,ivalid_aligned),
                         //            dostr2(xholdup2),
                         //            dostr2b(xholdup2b),
                         //            dostr3(xholdup3));
                         //end
                      
                    end // else: !if(RCTL_4P_REG_FILE)
                  
               end // if (`PDISP_LABEL == 1'b 1)
             else
               begin
                  if (RCTL_4P_REG_FILE)
                    begin
                       
                             $display ("# %t : %0s %H  %H %0s %0s %0s %0s %0s %0s %0s %0s %0s %0s", 
                                       $realtime, 
                                       flagdisp(aluflags_r), 
                                       disp_currentpc_r, 
                                       p1iw_aligned_a, 
                                       xinfo(p1iw_aligned_a, ivalid_aligned, 
                                       irq[3], irq[4], irq[5], irq[6],
                                       irq[7], irq[8], irq[9], irq[10],
                                       irq[11], irq[12], irq[13], 
                                       irq[14], irq[15], irq[16], 
                                       irq[17], irq[18], irq[19], 
                                       irq[20], irq[21], irq[22], 
                                       irq[23], irq[24], irq[25],
                                       irq[26], irq[27], irq[28], 
                                       irq[29], irq[30], irq[31], 
                                       1'b0), 
                                       pipeoperation(en, sim_REG1, ivalid_aligned, en1, p1int), 
                                       pipeoperation(en, sim_REG2, p2iv, en2, p2int), 
                                       pipeoperation(en, sim_REG2b, p2b_iv, en2b, p2bint), 
                                       pipeoperation(en, sim_REG3, p3iv, en3, p3int),
                                       wb_op,
                                       ld_op,
                                       dostr2(xholdup2),
                                       dostr2b(xholdup2b),
                                       dostr3(xholdup3));

                         //if(wben && wb_st)
                         //begin
                         //   $display("# %t : \n\t\t %0s %0s %0s %0s %0s %0s",
                         //            $realtime,
                         //            wbop(wb_aux_write, wb_aux_addr, wb_aux_dataw, wb_st, wb_mc_addr,
                         //                  wb_dwr, p4_docmprel, x_wben, 1'b0, wba, 1'b0, wbdata),
                         //            ld_op,
                         //            label_output(nearest_label,offset,en,en1,pc_valid,ivalid_aligned),
                         //            dostr2(xholdup2),
                         //            dostr2b(xholdup2b),
                         //            dostr3(xholdup3));
                         //end
                       
                    end // if (RCTL_4P_REG_FILE)
                  else
                    begin
                        // time flags PC P1iw irq s1 s2 s2b s3                      
                        $display ("# %t : %0s %H  %H %0s %0s %0s %0s %0s %0s %0s %0s %0s", 
                                       $realtime, 
                                       flagdisp(aluflags_r), 
                                       disp_currentpc_r, 
                                       p1iw_aligned_a, 
                                       xinfo(p1iw_aligned_a, ivalid_aligned, 
                                       irq[3], irq[4], irq[5], irq[6],
                                       irq[7], irq[8], irq[9], irq[10],
                                       irq[11], irq[12], irq[13], 
                                       irq[14], irq[15], irq[16], 
                                       irq[17], irq[18], irq[19], 
                                       irq[20], irq[21], irq[22], 
                                       irq[23], irq[24], irq[25],
                                       irq[26], irq[27], irq[28], 
                                       irq[29], irq[30], irq[31],
                                       1'b0), 
                                       pipeoperation(en, sim_REG1, ivalid_aligned, en1, p1int), 
                                       pipeoperation(en, sim_REG2, p2iv, en2, p2int), 
                                       pipeoperation(en, sim_REG2b, p2b_iv, en2b, p2bint), 
                                       pipeoperation(en, sim_REG3, p3iv, en3, p3int),
                                       nfp_wb_op, 
                                       dostr2(xholdup2),
                                       dostr2b(xholdup2b),
                                       dostr3(xholdup3));

                         //if(wben && wb_st)
                         //begin
                         //   $display("# %t : \n\t\t %0s %0s %0s %0s %0s %0s",
                         //            $realtime,
                         //            wbop(wb_aux_write, wb_aux_addr, wb_aux_dataw, wb_st, wb_mc_addr,
                         //                  wb_dwr, p4_docmprel, x_wben, 1'b0, wba, 1'b0, wbdata),
                         //            ld_op,
                         //            label_output(nearest_label,offset,en,en1,pc_valid,ivalid_aligned),
                         //            dostr2(xholdup2),
                         //            dostr2b(xholdup2b),
                         //            dostr3(xholdup3));
                         //end

                    end // else: !if(RCTL_4P_REG_FILE)
            end // else: !if(`PDISP_LABEL == 1'b 1)
          
          end // if ($realtime != 0)
             
        end // else: !if((ivalid_aligned == sim_oivalid_aligned &...    
        
        //  Control of pdisp internal pipeline
        // 
        if (en3 == 1'b 1)
          begin
             sim_REG4 = sim_REG3;   
          end
        if (en2b == 1'b 1)
          begin
             sim_REG3 = sim_REG2b;   
          end

        if (en2 == 1'b 1)
          begin
             sim_REG2b = sim_REG2;   
          end
        if (en1 == 1'b 1 & p2limm == 1'b 0 )
          begin
             sim_REG2 = sim_REG1;   
          end
        if (p2limm == 1'b 1 & ivalid_aligned == 1'b 1)
          begin
             sim_REG2_limm = sim_REG1;  
          end

        //  Make signal copies of of the registers so they are accessible
        //  with in a simulation run for debuging
        //  

        i_sREG1    <= sim_REG1;    
        i_sREG2    <= sim_REG2;    
        i_sREG2b   <= sim_REG2b;    
        i_sREG3    <= sim_REG3;    
        i_sREG4    <= sim_REG4;    
        i_sREG1_f  <= sim_REG1_f;    
        i_sREG2_f  <= sim_REG2_f;    
        i_sREG2b_f <= sim_REG2b_f;    
        i_sREG3_f  <= sim_REG3_f;    
        i_sREG4_f  <= sim_REG4_f;
        
        end // block: sim

   
   always @(clk_ungated or rst_a)
     begin : signal_checkers_PROC
        
        if (rst_a == 1'b 1)
          begin
             signal_checkers_reset_has_been_applied = `true;    
          end

        if (signal_checkers_reset_has_been_applied & rst_a == 1'b 0)
          begin
             signal_checkers_reset_has_been_removed = `true;    
          end
        if (signal_checkers_reset_has_been_removed && `PDISP_XCHECK == 1'b 1)
          begin
             if (clk_ungated == 1'b 1)
               begin
                  
                  //  Check all ctrl signals for X values
                  // 
                  i_h_read_r <= h_read; 
                  i_hold_host_r <= hold_host;   
                  if (! ( chk_x(en)))
                    begin
                       $write("failure: ");
                       $write("XC: en = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  if (! ( chk_x(irq)))
                    begin
                       $write("failure: ");
                       $write("XC: irq = ");
                       $write("%b", irq);
                       $write(" at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end

                  //  Pipeline stage1 checking
                  // 
                  if (! ( chk_x(en1)))
                    begin
                       $write("failure: ");
                       $write("XC: en1 = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  if (! ( chk_x(ivalid_aligned)))
                    begin
                       $write("failure: ");
                       $write("XC: ivalid_aligned = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  if (! ( chk_x(p1int)))
                    begin
                       $write("failure: ");
                       $write("XC: p1int = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  Pipeline stage2 checking
                  // 
                  if (! ( chk_x(en2)))
                    begin
                       $write("failure: ");
                       $write("XC: en2 = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  if (! ( chk_x(p2iv)))
                    begin
                       $write("failure: ");
                       $write("XC: p2iv = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  if (! ( chk_x(p2int)))
                    begin
                       $write("failure: ");
                       $write("XC: p2int = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end

                  if (! ( chk_x(xholdup2)))
                    begin
                       $write("failure: ");
                       $write("XC: xholdup2 = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end

                  if (! ( chk_x(xholdup2b)))
                    begin
                       $write("failure: ");
                       $write("XC: xholdup2b = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end

                  //  Pipeline stage3 checking
                  // 
                  if (! ( chk_x(en3)))
                    begin
                       $write("failure: ");
                       $write("XC: en3 = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  if (! ( chk_x(p3iv)))
                    begin
                       $write("failure: ");
                       $write("XC: p3iv = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  if (! ( chk_x(p3int)))
                    begin
                       $write("failure: ");
                       $write("XC: p3int = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  if (! ( chk_x(wben)))
                    begin
                       $write("failure: ");
                       $write("XC: wben = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  if (! ( chk_x(xholdup3)))
                    begin
                       $write("failure: ");
                       $write("XC: xholdup3 = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  if (! ( chk_x(i_ldvalid_r)))
                    begin
                       $write("failure: ");
                       $write("XC: i_ldvalid_r = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  Check data signals for X values, but only when the data is
                  //  marked as valid by an control signal
                  // 
                  if (ivalid_aligned == 1'b 1)
                    begin
                       if (! ( chk_x(p1iw_aligned_a)))
                         begin
                            $write("failure: ");
                            $write("XC: p1iw_aligned_a  = ");
                            $write("%b", p1iw_aligned_a);
                            $write(" at simulation time");
                            $write("%t", $realtime);
                            $write("ns");
                            $display();
                            $display("Time: ", $time);
                         end
                    end
                  if (p2iv == 1'b 1)
                    begin
                       if (! ( chk_x(p2opcode)))
                         begin
                            $write("failure: ");
                            $write("XC: p2opcode = ");
                            $write("%b", p2opcode);
                            $write(" at simulation time");
                            $write("%t", $realtime);
                            $write("ns");
                            $display();
                            $display("Time: ", $time);
                         end
                    end
                  if (p3iv == 1'b 1)
                    begin
                       if (! ( chk_x(p3opcode)))
                         begin
                            $write("failure: ");
                            $write("XC: p3opcode = ");
                            $write("%b", p3opcode);
                            $write(" at simulation time");
                            $write("%t", $realtime);
                            $write("ns");
                            $display();
                            $display("Time: ", $time);
                         end
                    end
                  if (wben == 1'b 1)
                    begin
                       if (! ( chk_x(wba)))
                         begin
                            $write("failure: ");
                            $write("XC: wba = ");
                            $write("%b", wba);
                            $write(" at simulation time");
                            $write("%t", $realtime);
                            $write("ns");
                            $display();
                            $display("Time: ", $time);
                         end
                       if (! ( chk_x(wbdata)))
                         begin
                            $write("failure: ");
                            $write("XC: wbdata = ");
                            $write("%b", wbdata);
                            $write(" at simulation time");
                            $write("%t", $realtime);
                            $write("ns");
                            $display();
                            $display("Time: ", $time);
                         end
                    end
                  //  Checks for register file
                  //  
                  if (! ( chk_x(ldvalid)))
                    begin
                       $write("failure: ");
                       $write("XC: ldvalid = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  if (ldvalid == 1'b 1)
                    begin
                       if (! ( chk_x(regadr)))
                         begin
                            $write("failure: ");
                            $write("XC: regadr = ");
                            $write("%b", regadr);
                            $write(" at simulation time");
                            $write("%t", $realtime);
                            $write("ns");
                            $display();
                            $display("Time: ", $time);
                         end
                       if (! ( chk_x(drd)))
                         begin
                            $write("failure: ");
                            $write("XC: drd = ");
                            $write("%b", drd);
                            $write(" at simulation time");
                            $write("%t", $realtime);
                            $write("ns");
                            $display();
                            $display("Time: ", $time);
                         end
                    end
                  if (! ( chk_x(currentpc_r)))
                    begin
                       $write("failure: ");
                       $write("XC: currentpc_r = ");
                       $write("%b", currentpc_r);
                       $write(" at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  if (! ( chk_x(aluflags_r)))
                    begin
                       $write("failure: ");
                       $write("XC: aluflags_r = ");
                       $write("%b", aluflags_r);
                       $write(" at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  Additional auto-generated assert checks
                  // 
                  //  aux_access X-check
                  // 
                  if (! ( chk_x(aux_access)))
                    begin
                       $write("failure: ");
                       $write("XC: aux_access = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  aux_datar X-check
                  // 
                  if (p3lr == 1'b 1 & en3 == 1'b 1)
                    begin
                       if (! ( chk_x(aux_datar)))
                         begin
                            $write("failure: ");
                            $write("XC: aux_datar  = ");
                            $write("%b", aux_datar);
                            $write(" at simulation time");
                            $write("%t", $realtime);
                            $write("ns");
                            $display();
                            $display("Time: ", $time);
                         end
                    end
                  //  aux_dataw X-check
                  // 
                  if (aux_write == 1'b 1)
                    begin
                       if (! ( chk_x(aux_dataw)))
                         begin
                            $write("failure: ");
                            $write("XC: aux_dataw  = ");
                            $write("%b", aux_dataw);
                            $write(" at simulation time");
                            $write("%t", $realtime);
                            $write("ns");
                            $display();
                            $display("Time: ", $time);
                         end
                    end
                  //  core_access X-check
                  // 
                  if (! ( chk_x(core_access)))
                    begin
                       $write("failure: ");
                       $write("XC: core_access = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  dwr X-check
                  // 
                  if (mstore == 1'b 1)
                    begin
                       if (! ( chk_x(dwr)))
                         begin
                            $write("failure: ");
                            $write("XC: dwr  = ");
                            $write("%b", dwr);
                            $write(" at simulation time");
                            $write("%t", $realtime);
                            $write("ns");
                            $display();
                            $display("Time: ", $time);
                         end
                    end
                  //  e1flag_r X-check
                  // 
                  if (! ( chk_x(e1flag_r)))
                    begin
                       $write("failure: ");
                       $write("XC: e1flag_r = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  e2flag_r X-check
                  // 
                  if (! ( chk_x(e2flag_r)))
                    begin
                       $write("failure: ");
                       $write("XC: e2flag_r = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  fs2a X-check
                  // 
                  if (! ( chk_x(fs2a)))
                    begin
                       $write("failure: ");
                       $write("XC: fs2a  = ");
                       $write("%b", fs2a);
                       $write(" at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  h_addr X-check
                  // 
                  if (h_read == 1'b 1 | h_write == 1'b 1)
                    begin
                       if (! ( chk_x(h_addr)))
                         begin
                            $write("failure: ");
                            $write("XC: h_addr  = ");
                            $write("%b", h_addr);
                            $write(" at simulation time");
                            $write("%t", $realtime);
                            $write("ns");
                            $display();
                            $display("Time: ", $time);
                         end
                    end
                  //  h_datar X-check
                  // 
                  if (i_h_read_r == 1'b 1 & i_hold_host_r == 1'b 0)
                    begin
                       if (! ( chk_x(h_datar)))
                         begin
                            $write("failure: ");
                            $write("XC: h_datar  = ");
                            $write("%b", h_datar);
                            $write(" at simulation time");
                            $write("%t", $realtime);
                            $write("ns");
                            $display();
                            $display("Time: ", $time);
                         end
                    end
                  //  h_dataw X-check
                  // 
                  if (h_write == 1'b 1)
                    begin
                       if (! ( chk_x(h_dataw)))
                         begin
                            $write("failure: ");
                            $write("XC: h_dataw  = ");
                            $write("%b", h_dataw);
                            $write(" at simulation time");
                            $write("%t", $realtime);
                            $write("ns");
                            $display();
                            $display("Time: ", $time);
                         end
                    end
                  //  h_read X-check
                  // 
                  if (! ( chk_x(h_read)))
                    begin
                       $write("failure: ");
                       $write("XC: h_read = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  h_write X-check
                  // 
                  if (! ( chk_x(h_write)))
                    begin
                       $write("failure: ");
                       $write("XC: h_write = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  halt X-check
                  // 
                  if (! ( chk_x(halt)))
                    begin
                       $write("failure: ");
                       $write("XC: halt = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  hold_host X-check
                  // 
                  if (! ( chk_x(hold_host)))
                    begin
                       $write("failure: ");
                       $write("XC: hold_host = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  ifetch_aligned X-check
                  // 
                  if (! ( chk_x(ifetch_aligned)))
                    begin
                       $write("failure: ");
                       $write("XC: ifetch_aligned = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  int_vec X-check
                  // 
                  if (p2int == 1'b 1)
                    begin
                       if (! ( chk_x(int_vec)))
                         begin
                            $write("failure: ");
                            $write("XC: int_vec  = ");
                            $write("%b", int_vec);
                            $write(" at simulation time");
                            $write("%t", $realtime);
                            $write("ns");
                            $display();
                            $display("Time: ", $time);
                         end
                    end
                  //  ivic X-check
                  // 
                  if (! ( chk_x(ivic)))
                    begin
                       $write("failure: ");
                       $write("XC: ivic = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  ldvalid_wb X-check
                  // 
                  if (! ( chk_x(ldvalid_wb)))
                    begin
                       $write("failure: ");
                       $write("XC: ldvalid_wb = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  loopend_r X-check
                  // 
                  if (! ( chk_x(loopend_r)))
                    begin
                       $write("failure: ");
                       $write("XC: loopend_r  = ");
                       $write("%b", loopend_r);
                       $write(" at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  loopstart_r X-check
                  // 
                  if (! ( chk_x(loopstart_r)))
                    begin
                       $write("failure: ");
                       $write("XC: loopstart_r  = ");
                       $write("%b", loopstart_r);
                       $write(" at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  lpending X-check
                  // 
                  if (! ( chk_x(lpending)))
                    begin
                       $write("failure: ");
                       $write("XC: lpending = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  mc_addr X-check
                  // 
                  if (mload == 1'b 1 | mstore == 1'b 1)
                    begin
                       if (! ( chk_x(mc_addr)))
                         begin
                            $write("failure: ");
                            $write("XC: mc_addr  = ");
                            $write("%b", mc_addr);
                            $write(" at simulation time");
                            $write("%t", $realtime);
                            $write("ns");
                            $display();
                            $display("Time: ", $time);
                         end
                    end
                  //  mload X-check
                  // 
                  if (! ( chk_x(mload)))
                    begin
                       $write("failure: ");
                       $write("XC: mload = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  mstore X-check
                  // 
                  if (! ( chk_x(mstore)))
                    begin
                       $write("failure: ");
                       $write("XC: mstore = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  mwait X-check
                  // 
                  if (! ( chk_x(mwait)))
                    begin
                       $write("failure: ");
                       $write("XC: mwait = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  next_pc X-check
                  // 
                  if (ifetch_aligned == 1'b 1)
                    begin
                       if (! ( chk_x(next_pc)))
                         begin
                            $write("failure: ");
                            $write("XC: next_pc  = ");
                            $write("%b", next_pc);
                            $write(" at simulation time");
                            $write("%t", $realtime);
                            $write("ns");
                            $display();
                            $display("Time: ", $time);
                         end
                    end
                  //  ic_busy X-check
                  // 
                  if (! ( chk_x(ic_busy)))
                    begin
                       $write("failure: ");
                       $write("XC: ic_busy = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  noaccess X-check
                  // 
                  if (! ( chk_x(noaccess)))
                    begin
                       $write("failure: ");
                       $write("XC: noaccess = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  nocache X-check
                  // 
                  if (! ( chk_x(nocache)))
                    begin
                       $write("failure: ");
                       $write("XC: nocache = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  p3lr X-check
                  // 
                  if (! ( chk_x(p3lr)))
                    begin
                       $write("failure: ");
                       $write("XC: p3lr = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  p3sr X-check
                  // 
                  if (! ( chk_x(p3sr)))
                    begin
                       $write("failure: ");
                       $write("XC: p3sr = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  pcen X-check
                  // 
                  if (! ( chk_x(pcen)))
                    begin
                       $write("failure: ");
                       $write("XC: pcen = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  s1a X-check
                  // 
                  if (! ( chk_x(s1a)))
                    begin
                       $write("failure: ");
                       $write("XC: s1a  = ");
                       $write("%b", s1a);
                       $write(" at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  s2a X-check
                  // 
                  if (! ( chk_x(s2a)))
                    begin
                       $write("failure: ");
                       $write("XC: s2a  = ");
                       $write("%b", s2a);
                       $write(" at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  sex X-check
                  // 
                  if (mload == 1'b 1 | mstore == 1'b 1)
                    begin
                       if (! ( chk_x(sex)))
                         begin
                            $write("failure: ");
                            $write("XC: sex = X at simulation time");
                            $write("%t", $realtime);
                            $write("ns");
                            $display();
                            $display("Time: ", $time);
                         end
                       //  size X-check
                       // 
                       if (! ( chk_x(size)))
                         begin
                            $write("failure: ");
                            $write("XC: size  = ");
                            $write("%b", size);
                            $write(" at simulation time");
                            $write("%t", $realtime);
                            $write("ns");
                            $display();
                            $display("Time: ", $time);
                         end
                    end
                  //  x_idecode3 X-check
                  // 
                  if (! ( chk_x(x_idecode3)))
                    begin
                       $write("failure: ");
                       $write("XC: x_idecode3 = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  xflags X-check
                  // 
                  if (! ( chk_x(xsetflags)))
                    begin
                       $write("failure: ");
                       $write("XC: xsetflags = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
                  //  xstep X-check
                  // 
                  if (! ( chk_x(xstep)))
                    begin
                       $write("failure: ");
                       $write("XC: xstep = X at simulation time");
                       $write("%t", $realtime);
                       $write("ns");
                       $display();
                       $display("Time: ", $time);
                    end
               end // if (clk_ungated == 1'b 1)

          end // if (signal_checkers_reset_has_been_removed & `PDISP_XCHECK == 1'b 1)
        
     end // block: signal_checkers

   // Signals and Logic to determine BR is taken or not.
   //
   // Stage 2. Branches happen here.
   // Reverse BRcc are predicted true here and are corrected in stage 4.
   // Forward BRcc are not taken here but must be passed on for stage 4.
   // Instructions are qualified with p2iv.
   assign i_p2_jmp_a = p2iv & p2_dopred;

   // Pass from stage 2 to stage 2b.
   always @(posedge clk_ungated or posedge rst_a)
     begin : stage_2_to_2b_PROC
        if (rst_a == 1'b 1)
          begin
             i_p2b_jmp_r <=  1'b0;
          end
        else
     begin
             if (en2)
               begin
                  i_p2b_jmp_r <=  i_p2_jmp_a;
               end
          end
     end

   // Stage 2b. Conditional jumps happen here.
   assign i_p2b_jmp_a = p2b_iv & i_p2b_jmp_r;

   // Pass from stage 2b to stage 3.
   always @(posedge clk_ungated or posedge rst_a)
     begin : stage_2b_to_3_PROC
        if (rst_a == 1'b 1)
          begin
             i_p3_jmp_r <=  1'b0;
          end
        else
     begin
             if (en2b)
               begin
                  i_p3_jmp_r <=  i_p2b_jmp_a;
               end
          end
     end

   // Stage 3. Nothing new arrives in this stage, it just gets passed to
   // stage 4.
   assign i_p3_jmp_a = p3iv & i_p3_jmp_r;

   // Pass from stage 3 to stage 4.
   always @(posedge clk_ungated or posedge rst_a)
     begin : stage_3_to_4_PROC
        if (rst_a == 1'b 1)
          begin
             i_p4_jmp_r <=  1'b0;
          end
        else
     begin
             if (en3)
               begin
                  i_p4_jmp_r <=  i_p3_jmp_a;
               end
          end
     end

   // Mispredicted BRcc instructions are resolved here. When a mispredicted
   // branch is fixed up both p4_docomprel and i_p4_jmp_r are true so use
   // an XOR to ignore this case.
   assign i_p4_jmp_a = (p4_docmprel ^ (i_p4_jmp_r & p4iv));

   //synopsys translate_on

`endif
`endif

endmodule // module pdisp

