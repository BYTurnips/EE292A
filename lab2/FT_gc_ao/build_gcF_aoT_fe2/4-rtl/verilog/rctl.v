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
// This file generates all the pipeline enables, decodes etc, as
// well as containing the pipeline registers.
//
//======================= Global System Signal =======================--
//
// clk                System Clock
// 
// rst_a              System Reset (Active high)
//
// en                 System Enable
//
//======================= Inputs to this block =======================--
//
// actionhalt         From flags. This signal is set true when the
//                    actionpoint (if selected) has been triggered by
//                    a valid condition. The ARC pipeline is halted
//                    and flushed when this signal is '1'.
//
//                    Note: The pipeline is flushed of instructions
//                    when the breakpoint instruction is detected, and
//                    it is important to disable each stage explicity.
//                    A normal instruction in stage one will mean that
//                    instructions in stage two,two-B, three and four
//                    will be allowed to complete. However, for an
//                    instruction in stage one which is in the delay
//                    slot of a branch, loop or jump instruction means
//                    that stage two has to be stalled as well.
//                    Therefore, only stages two-B, three and four
//                    will be allowed to complete.
//
// actionpt_pc_brk_a  From Action-points module. Indicates that a opcode 
//                    or PC actionpoint has been triggered.
//
// p2_ap_stall_a      From Action-points module. Used to stall action-points 
//                    in stage 2 until any BRccs instructions ahead have resolved.
//
// aluflags_r [3:0]   From flags.  This bus represents the condition
//                    of architectual basecase flags.
//
// aux_addr [31:0]    From hostif. This is the auxiliary mapped data
//                    space address bus.
//
// br_flags_a [3:0]   From bigalu. This is the flags generated for
//                    compare & branch instructions.
//
// cr_hostw           From hostif  This indicates that the host will
//                    perform a write to the core registers on the
//                    next cycle, provided that a load writeback does
//                    not bounce it out of the way.
//                    This signal is of a lower priority than ldvalid,
//                    so when both are true, cr_hostw is ignored.
//
// do_inst_step_r     From flags. This signal is set when the single
//                    step flag (SS) and the instruction step flag
//                    (IS) in the debug register has been written to
//                    simultaneously through the host interface. It
//                    indicates that an instruction step is being
//                    performed. When the instruction step has
//                    finished this signal goes low.
//
// h_pcwr             From aux_regs. This signal is set true when the host is
//                    attempting to write to the pc/status register, and
//                    the machine is stopped. It is used to trigger an
//                    instruction fetch when the PC is written when the
//                    machine is stopped. This is necessary to ensure the
//                    correct instruction is executed when the machine is
//                    restarted. It is also used to latch the new PC
//                    value.
//
// h_pcwr32           From aux_regs. This signal is set true when the host
//                    is attempting to write to the 32-bit pc register,
//                    and the machine is stopped. It is used to trigger an
//                    instruction fetch when the PC is written when the
//                    machine is stopped. This is necessary to ensure the
//                    correct instruction is executed when the machine is
//                    restarted.
//
// h_regadr [5:0]     From aux_regs. The register number to be written to by
//                    host writes to the core registers. Used when cr_hostw
//                    is true.
//
// holdup2b           From lsu. Holds stage 2b . The scoreboard uses this when
//                    the scoreboard is full or there is a scoreboard and
//                    register address hit. It is produced from s1a, fs2a,
//                    dest, s1en, s2en, desten and the scoreboarding
//                    mechanism.
//
//   
// ivalid_aligned     From inst_align. This signal is true when the ivalid
//                    signal from the ifetch interface is true except when the
//                    aligner need to get the next longword to be able to
//                    reconstruct the current instruction.
//                            
// ivic               From xaux_regs.  Invalidate Instruction Cache.
//                    This indicates that all values in the cache are
//                    to be invalidated. (it stands for InValidate
//                    Instruction Cache). It is anticipated that this
//                    signal will be generated from a decode of an 
//                    store (SR) instruction.
//                    Note that due to the pipelined nature of the  
//                    machine, up to four instructions could be issued 
//                    following the SR which generates the ivic signal
//                    to the instruction cache. Cache invalidates must
//                    be supressed when a line is being loaded from
//                    memory.
//
// ldvalid            From LSU. This signal is set true by the LSU to
//                    indicate that a delayed load writeback WILL occur on
//                    the next cycle. If the instruction in stage 3 wishes
//                    to perform a writeback, then pipeline stage 1,
//                    2, 2b and 3 will be held. If the instruction is stage 3 is
//                    invalid, or does not want to write a value into the
//                    core register set for some reason, then the
//                    instructions in stages 1 and 2 will move into 2 and
//                    3 respectively, and the instruction that was in
//                    stage 3 will be replaced in stage 4 by the delayed
//                    load writeback.
//
//                    Note that delayed load writebacks WILL complete,
//                    even if the processor is halted (en=0). In this
//                    instance, the host may be held off for a cycle
//                    (hold_host) if it is attempting to access the core
//                    registers. 
//
// loop_int_holdoff_a From loopcnt. This signal indicates that the
//                    loop mechanism want to hold off any interrupts
//                    from entering stage1 (i.e. p1int from being
//                    set).
//
// loop_kill_p1_a     From loopcnt. This signal indicates that the
//                    loop mechanism wants to kill the instruction in
//                    stage 1.  This will occur if a loop over-run
//                    has occured when the machine is attempting to
//                    find the loopend conditions.
//
// loopend_hit_a      From loopcnt.  This signal indicates that the
//                    loopend hit conditions have been met.
//
// lpending           From lsu. This signal indicates that there are
//                    still outstanding loads.
//
// mwait              From MC. This signal is set true by the DMP in order
//                    to hold up stages 1, 2, and 3. It is used when the 
//                    memory controller cannot service a request for a
//                    memory access which is being made by the LSU. It
//                    will be produced from mload, mstore and logic
//                    internal to the memory controller.
//
// p1int              From int_unit. Indicates that an interrupt has been
//                    detected, and an interrupt-op will be inserted into
//                    stage 2 on the next cycle, (subject to pipeline
//                    enables) setting p2int true. This signal will have
//                    the effect of cancelling the instruction currently
//                    being fetched by stage 1 by causing p2iv to be set
//                    false at the end of the cycle when p1int is true.
//    
// p1iw_aligned_a [31:0]
//                    From inst_align. This bus contains the current
//                    instruction word and is qualified with
//                    ivalid_aligned.
//
// p2int              From int_unit. This signal indicates that an interrupt jump
//                    instruction (fantasy instruction) is currently in
//                    stage 2. This signal has a number of consequences
//                    throughout the system, causing the interrupt vector
//                    (int_vec) to be put into the PC, and causing the old
//                    PC to be placed into the pipeline in order to be
//                    stored into the appropriate interrupt link register.
//                    Note that p2int and p2iv are mutually exclusive.
//
// p2bint             From int_unit. This signal indicates that an interrupt jump
//                    instruction (fantasy instruction) is currently in
//                    stage 2b. This signal has a number of consequences
//                    throughout the system, causing the interrupt vector
//                    (int_vec) to be put into the PC, and causing the old
//                    PC to be placed into the pipeline in order to be
//                    stored into the appropriate interrupt link register.
//                    Note that p2bint and p2b_iv are mutually exclusive.
//
// p3int              From int_unit. This signal indicates that an interrupt jump
//                    instruction (fantasy instruction) is currently in
//                    stage 2. This signal has a number of consequences
//                    throughout the system, causing the interrupt vector
//                    (int_vec) to be put into the PC, and causing the old
//                    PC to be placed into the pipeline in order to be
//                    stored into the appropriate interrupt link register.
//                    Note that p3int and p3iv are mutually exclusive.
//
// pcounter_jmp_restart_r
//                    From pcounter. This signals that there is a
//                    pending control transfer.  When a control transfer
//                    instruction is resolved and the instruction cache cannot
//                    accept another fetch request then the machine will set
//                    this signal and wait until the I$ can accept the request.
//
// regadr [5:0]       From lsu. This bus carries the address of the
//                    register into which the delayed load will writeback
//                    when ldvalid is true. rctl will ensure that this
//                    value is latched onto wba[5:0] at the end of a cycle
//                    when ldvalid is true, even cycles when the processor
//                    is halted (en = 0).
//
// regadr_eq_src1     From lsu.  This signal is true when current
//                    address to be writen back to from the returning
//                    load matches source1 register address in stage
//                    2b.
//
// regadr_eq_src2     From lsu.  This signal is true when current
//                    address to be writen back to from the returning
//                    load matches source2 register address in stage
//                    2b.
//
// sleeping           From debug. This is the sleep mode flag ZZ in
//                    the debug register. It stalls the pipeline when
//                    true.
//
// sleeping_r2        This is the pipelined version of sleeping for use by
//                    clock gating. Sleep mode (zz) flag in the debug
//                    register (bit 23).
//
// x_idecode2         From xrctl. This signal will be true when the
//                    extension logic detects an extension instruction in
//                    stage 2 and is produced from p2opcode[4:0].
//                    It is used in conjunction with internal decode
//                    signals to produce illegal-instruction interrupts.
//
// x_idecode2b        From xrctl. This signal will be true when the
//                    extension logic detects an extension instruction in
//                    stage 2b and is produced from p2b_opcode[4:0]
//                    and the sub-opcodes.
//                    
// x_idecode3         From xrctl. This signal will be true when the
//                    extension logic detects an extension instruction in
//                    stage 3 and is produced from p3opcode[4:0] and the sub-opcode.
//                    
// x_idop_decode2     From xrctl. when this signal is asserted the extension
//                    instruction in stage 2 is dual operand type.
//
// x_isop_decode2     From xrctl. when this signal is asserted the extension
//                    instruction in stage 2 is single operand type.
//
// x_multic_busy      From xrctl. Multi-cycle extension is busy. This signal
//                    is true when the multicycle instruction that is currently
//                    being stepped is busy.  The signal will become false
//                    when the extension instruction is finished.
//
// x_multic_wba [5:0] From xrctl. Multi-cycle extension writeback address.
//                    This signal is the writeback address for the instruction
//                    asserting the x_multic_wben signal.
//
// x_multic_wben      From xrctl. Multi-cycle extension writeback enable. This signal
//                    is true when the multi-cycle instruction wants to
//                    write-back. It should have been qualified with p3iv,
//                    and p3condtrue and the extension  opcode. If any
//                    other instruction requires a write back at the same
//                    time this signal is true the ARCompact pipeline will
//                    stall and the multi-cycle extension will write back.
//
// x_p1_rev_src       From xrctl. when asserted causes the the source fields to be
//                    reversed.
//
// x_p2_bfield_wb_a   From xrctl. Extension instruction in stage 2 is
//                    using the B-field as destination address for
//                    writeback.  
//
// x_p2_jump_decode   From xrctl. This signal is asserted for extension jump
//                    instructions in stage2
//
// x_p2b_jump_decode  From xrctl. This signal is asserted for extension jump
//                    instructions in stage2b
//
// x_p2nosc1          From xrctl. Indicates that the register
//                    referenced by s1a[5:0] is not available for
//                    shortcutting. This signal should only be set true
//                    when the register in question is an extension core
//                    register. This signal is ignored unless constant
//                     XT_COREREG is set true.
//
// x_p2nosc2          From xrctl. Indicates that the register
//                    referenced by fs2a[5:0] is not available for
//                    shortcutting. This signal should only be set true
//                    when the register in question is an extension core
//                    register. This signal is ignored unless constant
//                    XT_COREREG is set true.
// 
// x_p2shimm_a        From xrctl. Indicates that a short immediate
//                    is used for instruction in stage 2.
// 
// x_snglec_wben      From xrctl. Single-cycle extension writeback enable. This signal
//                    is true when the multi-cycle instruction wants to
//                    write-back. It should have been qualified with p3iv,
//                    and p3condtrue and the extension  opcode. If any
//                    other instruction requires a write back at the same
//                    time this signal is true the ARCompact pipeline will
//                    stall and the multi-cycle extension will write back.
//
// xholdup2           From xrctl. Extension holdup stage 2 signal.
//                    When asserted the core stage 2 is stalled.
//
// xholdup2b          From xrctl. Extension holdup stage 2b signal.
//                    When asserted the core stage 2b is stalled.
//
// xholdup3           From xrctl. Extension holdup stage 3 signal.
//                    When asserted the core stage 3 is stalled.
//
// xnwb               From xrctl. Extension instructions utilise
//                    the normal writeback-control logic (instruction
//                    condition codes) dest=immediate, short immediate
//                    data etc), but in addition have extra functions.
//                    When the extension logic has 'claimed' an
//                    instruction in stage 3 by setting x_idecode3, it can
//                    also disable writeback for that instruction by 
//                    setting xnwb. When x_idecode3 is low, or if the
//                    instruction is 'claimed' by the machine, xnwb has no
//                    effect.
//
// xp2ccmatch         From xrctl. This signal is provided by an extension condition
//                    -code unit which takes the condition code field
//                    from the instruction (at stage 2), and the alu flags
//                    (from stage 3) performs some operation on them and
//                    produces this condition true signal. Another bit in
//                    the instruction word indicates to the machine whether it
//                    should use the internal condition-true signal or the
//                    one provided by the extension logic. This technique
//                    will allow extra ALU instruction conditions to be
//                    added which may be specific to different
//                    implementations of the machine.
//
// xp2bccmatch        From xrctl. This signal is provided by an extension condition
//                    -code unit which takes the condition code field
//                    from the instruction (at stage 2b), and the alu flags
//                    (from stage 3) performs some operation on them and
//                    produces this condition true signal. Another bit in
//                    the instruction word indicates to the machine whether it
//                    should use the internal condition-true signal or the
//                    one provided by the extension logic. This technique
//                    will allow extra ALU instruction conditions to be
//                    added which may be specific to different
//                    implementations of the machine.
//
// xp3ccmatch         From xrctl. This signal is provided by an extension condition
//                    -code unit which takes the condition code field
//                    from the instruction (at stage 3), and the alu flags
//                    (from stage 3) performs some operation on them and
//                    produces this condition true signal. Another bit in
//                    the instruction word indicates to the machine whether it
//                    should use the internal condition-true signal or the
//                    one provided by the extension logic. This technique
//                    will allow extra ALU instruction conditions to be
//                    added which may be specific to different
//                    implementations of the machine.
//
// xp2idest           From xrctl. This signal is used to indicate
//                    that the instruction in stage 2 will not actually
//                    write back to the register specifed in the A field.
//                    This is used with extension instructions which write
//                    to FifOs using the destination register to carry the
//                    co-pro register number. It has the effect of
//                    preventing the scoreboard unit from looking at the
//                    destination register by clearing the desten signal.
//                    It will only take effect when the top bit of the
//                    instruction opcode field is set, indicating that it
//                    is an extension instruction.
//
//========================== Stage 1 Output ==========================--
//
// awake_a            This signal allows the PC signal sent to the cache to be
//                    synchronized with the  internally stored PC when
//                    re-awakening from reset or a cache invalidate.
//
// en1                Stage 1 pipeline latch control. True when an
//                    instruction is being latched into pipeline stage 2.
//                    This signal will be low when ivalid_aligned = 0,
//                    preventing junk instructions from being clocked into
//                    the pipeline. Also means that interrupts do not
//                    enter the pipe until a valid instruction is
//                    available in stage 1.
//                            
//                    *** A feature of this signal is that it will allow
//                    an instruction be clocked into stage 2 even when
//                    stage 2b is halted, provided that stage 2b is waiting for
//                    a LIMM or delay slot instruction. this is called
//                    a 'catch-up'. ***
//
// ifetch_aligned     This signal, similar to pcen, indicates to the
//                    memory controller that a new instruction is
//                    required, and should be fetched from memory from the
//                    address which will be clocked into currentpc[31:0]
//                    at the end of the cycle. It is also true for one
//                    cycle when the processor has been started following
//                    a reset, in order to get the ball rolling.
//                    An instruction fetch will also be issued if the host
//                    changes the program counter when the ARC is halted,
//                    provided it is not directly after a reset.
//                    The ifetch_aligned signal will never be set true
//                    whilst the memory controller is in the process of
//                    doing an instruction fetch, so it may be used by the
//                    memory controller as an acknowledgement of
//                    instruction receipt.
//                             
// inst_stepping      This signal indicates that instruction stepping is
//                    in progress.
//                             
// instr_pending_r    This signal is true when an instruction fetch has
//                    been issued, and it has not yet completed. It is
//                    not true directly after a reset before the ARC has
//                    started, as no instruction fetch will have been
//                    issued. It is used to hold off host writes to the
//                    program counter when the ARC is halted, as these
//                    accesses will trigger an instruction fetch.
//                             
   
// pcen               Program counter enable. When this signal is true,
//                    the PC will change at the end of the cycle,
//                    indicating that the memory controller needs to do a
//                    fetch on the next cycle using the address which will
//                    appear on currentpc, which is supplied from
//                    aux_regs.
//                    This signal is affected by interrupt logic and all
//                    the other pipeline stage enables
//
// pcen_niv           Same as above but with the ivalid_aligned qualification
//
// brk_inst_a         To flags. This signals to the ARC that a breakpoint
//                    instruction has been detected in stage two of the
//                    pipeline. Hence, the halt bit in the flag register
//                    has to be updated in addition to the BH bit in the
//                    debug register. The pipeline is stalled when this
//                    signal is set to '1'.
//
//                    Note: The pipeline is flushed of instructions when
//                    breakpoint instruction is detected, and it is
//                    important to disable each stage explicity. A normal
//                    instruction in stage one will mean that instructions
//                    in stage two, three and four will be allowed to
//                    complete. However, for an instruction in stage one
//                    which is in the delay slot of a  branch, loop or
//                    jump instruction means that stage two  has to be
//                    stalled as well. Therefore, only stages three and
//                    four will be allowed to complete.
//    
// 
// dest [5:0]         Destination register address. This is the A field
//                    from the instruction word, send to the LSU for
//                    register scoreboarding of loads. It is qualified by
//                    the desten signal.
//
// desten             This signal is used to indicate to the LSU that the
//                    instruction in pipeline stage 2 will use the data
//                    from the register specified by dest[5:0]. If the
//                    signal is not true, the LSU will ignore dest[5:0]. 
//                    This signal includes p2iv as part of its decode.
//
// en2                Pipeline stage 2 enable. When this signal is
//                    true, the instruction in stage 2 can pass into
//                    stage 2b at the end of the cycle. When it is
//                    false, it will hold up stage 2 and stage 1
//                    (pcen).
//
// fs2a [5:0]         Source 2 register address. This is the C field from
//                    the instruction word, sent to the core registers 
//                    (via hostif) and the LSU. It is qualified for LSU
//                    use by s2en.
//
// p2_a_field_r [5:0] Stage 2 instruction word a field section.
//
// p2_abs_neg_a       Stage 2 abs and negs instruction decode
//
// p2_b_field_r [5:0] Stage 2 instruction word b field section.
//
// p2_brcc_instr_a    Stage 2 compare&branch instruction decode.
//
// p2_c_field_r [5:0] Stage 2 instruction word c field section.
//
// p2_dopred          Stage 2 changed PC to PC+branch offset due to
//                    compare&branch prediction.
//
// p2_dopred_ds       Same as above except on true when the
//                    compare&branch has a delay slot.
//
// p2_dopred_nds      Same as above except on true when the
//                    compare&branch has a no delay slot.
//
// p2_dorel           True when a relative branch (not jump) is going to
//                    happen. Relates to the instruction in p2. Includes
//                    p2iv.
//
// p2_iw_r [31:0]     Stage 2 instruction word. 
//
// p2_jblcc_a         True when stage 2 contains a valid jump&link or
//                    branch&link instruction
//
// p2_lp_instr        True when stage 2 has decoded a LP instruction.
//
// p2_not_a           True when stage 2 has decoded a NOT instruction.
// 
// p2_s1a [5:0]       Stage 2 source 1 register address field.
// 
// p2_s1en            Stage 2 source 1 register address field enable.
// 
// p2_s2a [5:0]       Stage 2 source 2 register address field.
//
// p2_shimm_data [12:0]
//                    Stage 2 short immediate data
// 
// p2_shimm_s1_a      Stage 2 Source 1 uses the short immediate data
// 
// p2_shimm_s2_a      Stage 2 source 2 uses the short immediate data
// 
// p2bch              Stage 2 decode for branch instructions
// 
// p2cc [3:0]         This bus contains the region of the instruction
//                    which  contains the four-bit condition code field.
//                    It is sent to the extension condition code test
//                    logic which provides in return a signal (xp2ccmatch)
//                    which indicates whether it considers the condition
//                    to be true. The ARC decides whether to use the
//                    internal condition-true signal or the signal
//                    provided by extensions depending on the fifth bit of
//                    the instruction. 
// 
// p2conditional      Stage 2 contains a conditional type instruction 
//
// p2condtrue         Stage 2 condition code evaluation.  This signal
//                    is set true when the stage 2 condition code and
//                    the architectual flags match. S
// 
// p2delay_slot       Stage 2 instruction has a delay slot. This
//                    signal is set true when the instruction in stage
//                    2 uses a delay slot.  This signal does not have
//                    an information about the delay slot instruction
//                    itself.
// 
// p2format [1:0]     Stage 2 instruction format field. This field
//                    can be used to decode the type of instruction
//                    in stage 2.  The valid formats are 
//                     1) "00" register-register, 
//                     2) "01" register-unsigned 6-bit,
//                     3) "10" register-signed 12-bit and
//                     4) "11" conditional register
// 
// p2iv               Stage 2 instruction valid. This signal is set
//                    True when the current instruction is valid,
//                    i.e. not killed and actual instruction data.
// 
// p2limm             Indicates that the instruction in stage 2 will use 
//                    long immediate data.
// 
// p2lr               This is true when p2opcode = oldo, and p2iw(13) = 
//                    '1', which indicates that the instruction is the
//                    auxiliary register load instruction LR, not a memory
//                    load LDO instruction. This signal is used by
//                    coreregs to switch the currentpc_r bus onto the
//                    source2 bus (which is then passed through the same
//                    logic as the interrupt link register) in order to
//                    get the correct value of PC when it is read by an LR
//                    instruction. Does not include p2iv.
// 
// p2minoropcode [5:0] Minor opcode word for single operand instructions.          
// 
// p2offset [targz:0] This is the 24-bit relative address from
//                    the instruction in stage 2. It is sign-extended and
//                    added to the stage 2 program counter when a branch is
//                    to take place.
// 
// p2opcode [4:0]     Opcode word. This bus contains the instruction word
//                    which is being executed by stage 2. It must be
//                    qualified by p2iv.
// 
// p2setflags         This is bit 8 from the instruction word at stage 2,
//                    ie the .F or setflags bit used in the jump
//                    instruction. It is used in flags to determine
//                    whether the flags should be loaded by a jump
//                    instruction. The stage 3  signal p3setflags is much
//                    more complicated, having to take into account the
//                    complications presented by short immediate data,
//                    amongst other things.
// 
// p2sleep_inst       This signal is set when a sleep instruction has been
//                    decoded in pipeline stage 2. It is used to set the
//                    sleep mode flag ZZ (bit 23) in the debug register.
// 
// p2st               This signal is used by coreregs. It is produced from
//                    a decode of p2opcode[4:0], p2subopcode[5:0] and does
//                    include p2iv.
// 
// p2subopcode [5:0]  Sub-opcode word (for 32-bit instruction).
// 
// p2subopcode1_r [1:0] Sub-opcode word (for 32-bit instruction).
// 
// p2subopcode2_r [4:0] Sub-opcode word (for 32-bit instruction).
// 
// p2subopcode3_r [2:0] Sub-opcode word (for 32-bit instruction).
//
// p2subopcode4_r     Sub-opcode word (for 32-bit instruction).
// 
// p2subopcode5_r [1:0] Sub-opcode word (for 32-bit instruction).
//
// p2subopcode6_r [2:0] Sub-opcode word (for 32-bit instruction).
//
// p2subopcode7_r [1:0] Sub-opcode word (for 32-bit instruction).
// 
// s1a [5:0]          Source 1 register address. This is the B field from
//                    the instruction word, sent to the core registers
//                    (via hostif) and the LSU. It is qualified for LSU
//                    use by s1en.
// 
// s1en               This signal is used to indicate that the
//                    instruction in pipeline stage 2 will use the data
//                    from the register specified by s1a[5:0]. 
//                    This signal includes p2iv as part of its decode.
//
// s2en               This signal is used to indicate that the
//                    instruction in pipeline stage 2 will use the data
//                    from the register specified by fs2a[5:0]. 
//                    This signal includes p2iv as part of its decode.
//
//========================== Stage 2b Input ==========================--
//
// en2b               Pipeline stage 2B enable. When this signal is
//                    true, the instruction in stage 2b can pass into
//                    stage 3 at the end of the cycle. When it is
//                    false, it will hold up stage 2b, stage 2 and
//                    stage 1 (pcen).
// 
// mload2b            This signal indicates to the LSU that there is a
//                    valid load instruction in stage 2b. It is produced
//                    from a decode of p2b_opcode[4:0], p2b_subopcode[5:0]
//                    and the p2b_iv signal.
//  
// mstore2b           This signal indicates to the actionpoint mechanism
//                    when selected there is a valid store instruction
//                    in stage 2b. It is produced from decode of p2b_opcode,
//                    p2b_subopcode and the p2b_iv signal.
//
// p2b_a_field_r [5:0]
//                    Instruction A field. This bus carries the region of 
//                    the instruction which contains the operand
//                    destination field in stage 2b.//
//
// p2b_abs_op         Indicates that the instruction in stage 2 is an ABS.
//
// p2b_alu_op [1:0]   Describes which ALU operation is to be performed.
//                    "00" ADD/AND, "01" ADC/OR, "10" SUB/BIC & "11"
//                    SBC/XOR
//
// p2b_arithiv        Indicates that the ALU operation in stage 2b will be
//                    an arithmetic operation (as opposed to logical, say)
//
// p2b_awb_field [1:0]
//                    This field describes the address writeback mode of
//                    the LD/ST instruction in stage 2b.
//
// p2b_b_field_r [5:0]
//                    This is the source B address field for 32-bit
//                    instructions.
//
// p2b_bch            Stage 2b decode for branch instructions
//
// p2b_blcc_a         True when stage 2 contains a valid branch&link instruction
//
// p2b_c_field_r [5:0]
//                    Stage 2b instruction word c field section.
//
// p2b_cc [3:0]       This bus contains the region of the instruction
//                    which  contains the four-bit condition code field.
//                    It is sent to the extension condition code test
//                    logic which provides in return a signal (xp2ccmatch)
//                    which indicates whether it considers the condition
//                    to be true. The ARC decides whether to use the
//                    internal condition-true signal or the signal
//                    provided by extensions depending on the fifth bit of
//                    the instruction. This is handled within rctl.
//
// p2b_conditional    Stage 2b contains a conditional type instruction
//
// p2b_condtrue       Stage 2 condition code evaluation.  This signal
//                    is set true when the stage 2 condition code and
//                    the architectual flags match.
//                    
// p2b_delay_slot     Stage 2b instruction has a delay slot. This
//                    signal is set true when the instruction in stage
//                    2b uses a delay slot.  This signal does not have
//                    an information about the delay slot instruction
//                    itself.
//
// p2b_dojcc          True when a jump is going to happen.
//                    Relates to the instruction in stage 2b. Includes
//                    p2b_iv.
//
// p2b_dopred_ds      Stage 2b contains a compare&branch that has
//                    been predicited taken. The branch also has a
//                    delay slot.
//
// p2b_format [1:0]   Stage 1 instruction format field. This field
//                    can be used to decode the type of instruction
//                    in stage 2.  The valid formats are 
//                      1) "00" register-register,
//                      2) "01" register-unsigned 6-bit,
//                      3) "10" register-signed 12-bit and
//                      4) "11" conditional register
//
// p2b_iv             Stage 2b instruction valid. This signal is set
//                    true when the current instruction is valid,
//                    i.e. not killed and actual instruction data
//                    
// p2b_jlcc_a         Stage 2b contains a jump&link or branch&link
//
// p2b_limm           Stage 2b contains an instruction that uses lon
//                    immediate data.
//
// p2b_lr             Stage 2b has a valid LR instruction in it.
//
// p2b_minoropcode [5:0]
//                    Minor opcode word for single operand instructions.
// 
// p2b_neg_op         Indicates that the instruction in stage 2 is an NEG.
//
// p2b_not_op         Indicates that the instruction in stage 2 is an NOT.
//
// p2b_opcode [4:0]   Opcode word. This bus contains the instruction word
//                    which is being executed by stage 2b. It must be
//                    qualified by p2b_iv.
//
// p2b_setflags       This is bit 8 from the instruction word at stage 2,
//                    ie the .F or setflags bit used in the jump
//                    instruction. It is used in flags to determine
//                    whether the flags should be loaded by a jump
//                    instruction. The stage 3  signal p3setflags is much
//                    more complicated, having to take into account the
//                    complications presented by short immediate data,
//                    amongst other things.
//
// p2b_shift_by_one_a Used by shifting arith instructions (e.g. ADD1) and
//                    by shifting LD/ST instructions (e.g. LD.AS).
//
// p2b_shift_by_two_a Used by shifting arith instructions (e.g. ADD1) and
//                    by shifting LD/ST instructions (e.g. LD.AS).
//
// p2b_shift_by_three_a
//                    Used by shifting arith instructions (e.g. ADD1) and
//                    by shifting LD/ST instructions (e.g. LD.AS).
//
// p2b_shift_by_zero_a
//                    Used by shifting arith instructions (e.g. ADD1) and
//                    by shifting LD/ST instructions (e.g. LD.AS).
//
// p2b_shimm_data [12:0]
//                    This bus carries the short immediate data encoded
//                    on the instruction word. It is used by coreregs
//                    when one of the source (s1a/fs2a) registers being
//                    referenced is one of the short immediate registers.
//                    It always provides the region of the instruction
//                    where the short immediate data would be found,
//                    regardless of whether short immediate data is being
//                    used.
//
// p2b_shimm_s1_a     Operand 1 requires the short immediate data
//                    carried in p2b_shimm_data
//
// p2b_shimm_s2_a     Operand 2 requires the short immediate data
//                    carried in p2b_shimm_data
//
// p2b_size [1:0]     This pair of signals are used to indicate to the LSU
//                    the size of the memory transaction which is being 
//                    requested by a LD or ST instruction. It is produced 
//                    during stage 2b and latched as the size information bits
//                    are encoded in different places on the LD and ST 
//                    instructions. It must be qualified by the mload/mstore
//                    signals as it does not include an opcode decode.
//
// p2b_st             Stage 2b ST instruction decode. Is not qualified
//                    with p2b_iv
//
// p2b_subopcode [5:0]          Sub-opcode word (for 16-bit instruction).
//
// p2b_subopcode1_r [1:0]       Sub-opcode word (for 16-bit instruction).
//
// p2b_subopcode2_r [4:0]       Sub-opcode word (for 16-bit instruction).
//
// p2b_subopcode3_r [2:0]       Sub-opcode word (for 16-bit instruction).
//
// p2b_subopcode4_r             Sub-opcode word (for 16-bit instruction).
//
// p2b_subopcode5_r [1:0]       Sub-opcode word (for 16-bit instruction).
//
// p2b_subopcode6_r [2:0]       Sub-opcode word (for 16-bit instruction).
//
// p2b_subopcode7_r [1:0]       Sub-opcode word (for 16-bit instruction).
//
// en3                Pipeline stage 3 enable. When this signal is
//                    true, the instruction in stage 3 can pass into
//                    stage 4 at the end of the cycle. When it is
//                    false, it will probably hold up stage 1, 2 and
//                    2b (pcen, en2), along with stage 3.
//
// en3_niv_a          Same as above except no ivalid_aligned or mwait
//                    included in expression.  This signal is used to
//                    validiate auxiliary writes.
//
// ldvalid_wb         This signal is used to control the switching of
//                    returning load data onto the writeback path for the
//                    register file. It is set true whenever returning
//                    load data must pass through the regular load
//                    writeback path - this will be loads to r32-r60 for a
//                    4port regfile system, or loads to r0-r60 for a 3port
//                    register file system.      
//
// mload              This signal indicates to the LSU that there is a valid
//                    load instruction in stage 3. It is produced from a
//                    decode of p3opcode, p3iw(13) (to exclude LR) and the
//
// mstore             This signal indicates to the LSU that there is a valid
//                    p3iv signal. store instruction in stage 3. It is
//                    produced from a decode of p3opcode, p3iw(25) (to
//                    exclude SR) and the p3iv signal.
//
// nocache            This signal is used to indicate to the LSU whether
//                    the load/store operation is required to bypass the
//                    cache. It comes from bit 5 of the ld/st control
//                    group which is found in different places in the
//                    ldo/ldr/st instructions.
//
// p3_alu_absiv       Indicates that an ABS instruction is in stage 3.
//
// p3_alu_arithiv     Indicates that an ALU instruction is in stage 3.
//
// p3_alu_flagiv      Indicates that a flag setting ALU instruction is in
//                    stage 3.
//
// p3_alu_logiciv     Indicates that a logic instruction is in stage 3.
//
// p3_alu_minmaxiv    Indicates that a MIN/MAX instruction is in stage 3.
//
// p3_alu_op [1:0]    Describes which ALU operation is in stage 3.
//
// p3_alu_snglopiv    Indicates that a single operand instruction is in
//                    stage 3.
//
// p3_bit_op_sel [1:0]Indicates to the ALU which operation to
//                    complete for the compare&branch operations       
//
// p3_brcc_instr_a    Indicates that the instruction in stage 3 is a
//                    compare&branch. includes p3iv.
//
// p3_flag_instr      Indicates that the instruction in stage 3 is a
//                    flag . includes p3iv.
//
// p3_sync_instr      Indicates that the instruction in stage 3 is a 
//                    sync (includes p3iv).
//
// p3_max_instr       Indicates that the instruction in stage 3 is a
//                    max.
//
// p3_min_instr       Indicates that the instruction in stage 3 is a
//                    min.
//
// p3_ni_wbrq         This signal is the same as i_p3_wb_req_a, except that
//                    it does not include an option for the interrupt unit
//                    to write back. It is used in certain extensions
//                    where an external register set is provided, which
//                    are not allowed to accept loads, or fifo-type 
//                    extension alu instructions.
//
// p3_shiftin_sel_r [1:0]       This bus controls the what is shifted into the
//                    msb/lsb when a single bit shift is performed by
//                    the basecase ALU.
//
// p3_sop_op_r [2:0]  Indicates which SOP instruction is present in
//                    stage 3 of the pipeline.
//
// p3_xmultic_nwb     Multi-cycle Extension write-back not allowed. When
//                    this signal is asserted no multi-cycle extension is
//                    allowed to write back. If this signal and
//                    x_multic_wben is true then the multi-cycle extension
//                    pipeline must stall.
//                 
// p3a_field_r [5:0]  Instruction A field. This bus carries the region of 
//                    the instruction which contains the operand
//                    destination field in stage 3.
//
// p3awb_field_r [1:0] Indicates the write-back mode of the LD/ST
//                    instruction in stage 3.
//
// p3b_field_r [5:0]  Instruction B field. This bus carries the region of 
//                    the instruction which contains the source operand
//                    one field in stage 3.
//
// p3c_field_r [5:0]  Instruction C field. This bus carries the region of 
//                    the instruction which contains the source operand
//                    two field in stage 3. 
//
// p3cc[3:0]          This bus contains the region of the instruction
//                    which contains the four-bit condition code field. It
//                    is sent with the alu flags to the extension 
//                    condition code test logic which provides in return
//                    a signal (xp3ccmatch) which indicates whether it
//                    considers the condition to be true. The ARC decides
//                    whether to use the internal condition-true signal or
//                    the signal provided by extensions depending on the
//                    fifth bit of the instruction. This is handled within 
//                    rctl.
//                             
// p3condtrue         This signal is produced from the result of the
//                    internal stage 3 condition code unit or from an
//                    extension condition code unit (if implemented). A
//                    bit (bit 5) in the instruction selects between the
//                    internal and extension condition code unit results.
//                    In addition, this signal is set true if the
//                    instruction is using short immediate data. As it is
//                    only used by flags in conjunction with the p3opcode=
//                    oflag, and with p3setflags, it does not include a 
//                    decode for instructions which do not have a
//                    condition code field (i.e. all load and store
//                    operations). Does not include p3iv.
//
// p3destlimm         Indicates that the instruction is using a null
//                    destination i.e. the instruction will not write-back
//
// p3_docmprel_a      A mispredicted BRcc of BBITx has been taken by the ARC
//                    processor in stage 3. The corrective action will be taken
//                    in stage 4 where the correct PC will be presented at the
//                    instruction fetch interface.
//
// p3dolink           This signal is true when a JLcc or BLcc instruction
//                    has been taken, indicating that the link register needs
//                    to be stored. It is used by alu to switch the
//                    program counter value which has been passed down the 
//                    pipeline onto the p3result bus. If this signal is to
//                    be used to give a fully qualified indication that a 
//                    J/BLcc is in stage 3, it must be qualified with p3iv
//                    to take account of pipeline tearing between stages 2b
//                    and 3 which could cause the instruction in stage
//                    three to be repeated.         
//
// p3format [1:0]     Instruction word format of instruction in stage 3.
//
// p3iv               Opcode valid. This signal is used to indicate
//                    that the opcode in pipeline stage 3 is a valid
//                    instruction. The instruction may not be valid if
//                    a junk instruction has been allowed to come into
//                    the pipeline in order to allow the pipeline to
//                    continue running when an instruction cannot be
//                    fetched by the memory controller, or when an
//                    instruction has been killed.
//
// p3lr               This signal is used by hostif. It is produced from
//                    a decode of p3opcode, p3iw(13) (check for LR) and 
//                    includes p3iv. Also used in extension logic for
//                    seperate decoding of auxiliary accesses from host
//                    and ARC.
//
// p3minoropcode      Minor opcode (sub-sub-opcode) of instruction in
//                    stage 3.
//                             
// p3opcode[4:0]      Opcode word. This bus contains the instruction word
//                    which is being executed by stage 3. It must be
//                    qualified by p3iv.
//                             
// p3q                Condition code of instruction in stage 3.
//                             
// p3setflags         This signal is used by regular alu-type instructions
//                    and the jump instruction to control whether the
//                    supplied flags get stored. It is produced from the
//                    set-flags bit in the instruction word, but if that
//                    field is not present in the instruction then it will
//                    come from the set-flag modes implied by the
//                    instruction itself, i.e. TST, RCMP or CMP.
//                    Does not include p3iv.
//                             
// p3sr               U This signal is used by hostif. It is produced from
//                    a decode of p3opcode, p3iw(25) (check for SR) and 
//                    includes p3iv. Also used in extension logic for
//                    seperate decoding of auxiliary accesses from host
//                    and ARC.
//                             
// p3subopcode        Sub-opcode word (for 32-bit instruction).
//                             
// p3subopcode1_r     Sub-opcode word (for 16-bit instruction).
//                             
// p3subopcode2_r     Sub-opcode word (for 16-bit instruction).
//                             
// p3subopcode3_r     Sub-opcode word (for 16-bit instruction).
//                             
// p3subopcode4_r     Sub-opcode word (for 16-bit instruction).
//                             
// p3subopcode5_r     Sub-opcode word (for 16-bit instruction).
//                             
// p3subopcode6_r     Sub-opcode word (for 16-bit instruction).
//                             
// p3subopcode7_r     Sub-opcode word (for 16-bit instruction).
//                             
// p3wb_en            Stage 4 pipeline latch control. Controls transition
//                    of the data on the p3result[31:0] bus, and the
//                    corresponding register address from stage 3 to
//                    stage 4. As these buses carry data not only from
//                    instructions but from delayed load writebacks and
//                    host writes, they must be controlled separately from
//                    the instruction in stage 3. This is because if the
//                    instruction in stage 3 does not need to write a
//                    value back into a register, and a delayed load
//                    writeback is about to happen, the instruction is
//                    allowed to complete (i.e. set flags) whilst the data
//                    from the load is clocked into stage 4. If however
//                    the instruction in stage 3 DOES need to writeback to
//                    the register file when a delayed load or multicycle
//                    writeback is about to happen, then the instruction in
//                    stage 3 must be held up and not allowed to change the
//                    processor state, whilst the data from the delayed
//                    load is clocked into stage 4 from stage 3.
//                    *** Note that p3wb_en can be true even when the
//                    processor is halted, as delayed load writebacks and
//                    host writes use this signal in order to access the
//                    core registers. ***
//                    
// p3wb_en_nld        Same as above excpet no load return.
//
// p3wba [5:0]        Register writeback address of the instruction in
//                    stage 3.
//
// p3wba_nld [5:0]    Same as above for except no load return address.
//
// sc_load1           This signal is set true when data from a returning
//                    load is required to be shortcut onto the stage 2b
//                    source 1 result bus. If the 4-port register file
//                    is implemented, the data used for the shortcut comes
//                    direct from the memory system, this requiring an
//                    additional input into the shortcut multiplexer.
//                    Extension core registers can have shortcutting
//                    banned if x_p2nosc1 is set true at the appropriate
//                    time. Includes both p2biv and p3iv.
//                             
// sc_load2           This signal is set true when data from a returning
//                    load is required to be shortcut onto the stage 2b
//                    source 2b result bus. If the 4-port register file
//                    is implemented, the data used for the shortcut comes
//                    direct from the memory system, this requiring an
//                    additional input into the shortcut muxer.
//                    Extension core registers can have shortcutting
//                    banned if x_p2nosc2 is set true at the appropriate
//                    time. Includes both p2biv and p3iv.
//                             
// sc_reg1            This signal is produced by the pipeline control
//                    unit rctl, and is set true when an instruction in
//                    stage 3 is going to generate a write to the register
//                    being read by source 1 of the instruction in stage
//                    2b. This is a source 1 shortcut. It is used by the
//                    core register module to switch the stage 3 result
//                    bus onto the stage 2b source 1 result. 
//                    Extension core registers can have shortcutting
//                    banned if x_p2nosc1 is set true at the appropriate
//                    time. Includes both p2biv and p3iv.
//                             
// sc_reg2            This signal is produced by the pipeline control
//                    unit rctl, and is set true when an instruction in
//                    stage 3 is going to generate a write to the register
//                    being read by source 2b of the instruction in stage
//                    2b. This is a source 1 shortcut. It is used by the
//                    core register module to switch the stage 3 result
//                    bus onto the stage 2b source 2 result.
//                    Extension core registers can have shortcutting
//                    banned if x_p2nosc2 is set true at the appropriate
//                    time. Includes both p2biv and p3iv.
//                             
// sex                This signal is used to indicate to the LSU whether
//                    a sign-extended load is required. It is produced
//                    during stage 2b and latched as the sign-extend bit in
//                    the two versions of the LD instruction (LDO/LDR) are
//                    in different places in the instruction word.
//                             
// size [1:0]         This pair of signals are used to indicate to the LSU
//                    the size of the memory transaction which is being 
//                    requested by a LD or ST instruction. It is produced 
//                    during stage 2b and latched as the size information bits
//                    are encoded in different places on the LD and ST 
//                    instructions. It must be qualified by the mload/mstore
//                    signals as it does not include an opcode decode.
//                             
// wben_nxt           Set true when a register writeback will occur on the 
//                    next cycle. Used for generating writes with
//                    Synchronous register files.
//    
// wba [5:0]          This bus carries the address of the register to
//                    which the data on wbdata[31:0] is to be written at
//                    the end of the cycle if wben is true. It is produced
//                    during stage 3 and takes account of delayed load
//                    register writeback (taking a value from the LSU),
//                    LD/ST address writeback  (address from the B or C 
//                    field), and normal ALU operation destination
//                    addresses (instruction A field).
//                          
// wben               This signal is the enable signal which determines
//                    whether the data on wbdata[31:0] is written into the 
//                    register file at stage 4. It is produced in stage 3
//                    and takes into account delayed load writebacks, 
//                    cancelled instructions, and instructions which are
//                    not to be executed due to the cc result being false,
//                    amongst other things.        
//
// p4_docmprel        Stage 4 control transfer is in progress during
//                    the cycle.
//                    
// loopcount_hit_a    Indicates that the intruction in stage 3 will
//                    write to the loop count register at the ened of the
//                    cycle
//
// p4_disable_r       This signal is set true when the entire
//                    pipeline has been flushed.
//
// p4iv               Stage 4 instruction valid.            
//
// flagu_block        Holds off interrupts because a flag setting
//                    instruction is in the pipe.
//
// instruction_error  Instruction Exception. This causes an instruction
//                    error interrupt. This signal will be set true when
//                    a valid instruction in pipeline stage 2 is not one
//                    of the standard opcode set, and the extension logic
//                    has not 'claimed' the instruction in stage 2 as one
//                    of its own.mpu_kill_stage2a_a
//
// interrupt_holdoff  This signal is used to indicate that the instruction
//                    at stage 2 requires that the next instruction be in
//                    stage 1 before it can move off.
//                    This may be either to ensure correct delay slot
//                    operation for a branch or to make sure that long
//                    immediate data is fetched, and then killed before it
//                    can be processed as an instruction. 
//
// kill_last          This signal indicates that the last entry added
//                    to the LSU has to be killed.  This is required
//                    when a BRcc is followed by a ld and the BRcc is
//                    taken.
//
// kill_p1_a          Kill Stage 1 instruction
//
// kill_p1_en_a       Kill Stage 1 instruction includes enables.
// 
// kill_p1_nlp_a      Kill stage 1 excludes loop count overrun kill.
//
// kill_p1_nlp_en_a   Kill stage 1 excludes loop count overrun kill
//                    includes enables.
//
// kill_p2_a          Kill Stage 2. This is asserted true when the
//                    instructin in stage 2 should be killed.
//
// kill_p2_en_a       Kill stage 2 with enables
//
// kill_p2b_a         Kill stage 2b.
//
// kill_p3_a          Kill Stage 3
//
// kill_tagged_p1     Kill the longword that will arrive from the cache.
//
// stop_step          This signal is set when the instruction step has
//                    finished.       
//
//====================================================================--
//
module rctl (clk,
             rst_a,
             en,
             aux_addr,
             actionhalt,
             actionpt_swi_a,
             actionpt_pc_brk_a,
             p2_ap_stall_a,
             aluflags_r,
             br_flags_a,
             cr_hostw,
             do_inst_step_r,
             h_pcwr,
             h_pcwr32,
             h_regadr,
             holdup2b,
             ivalid_aligned,
             ivic,
             ldvalid,
	 	     
             loop_kill_p1_a,
             loop_int_holdoff_a,
             loopend_hit_a,
             sync_queue_idle,
             lpending,
	     debug_if_r,
	     dmp_mload,
	     dmp_mstore,
	     is_local_ram,
             mwait,
             p1int,
             p1iw_aligned_a,
             p2ilev1,
             p2int,
             p2bint,
             p3int,
             pcounter_jmp_restart_r,
             regadr,
             regadr_eq_src1,
             regadr_eq_src2,
             sleeping,
             sleeping_r2,
             x_idecode2,
             x_idecode2b,
             x_idecode3,
             x_idop_decode2,
             x_isop_decode2,
             x_multic_busy,
             x_multic_wba,
             x_multic_wben,
             x_p1_rev_src,
             x_p2_bfield_wb_a,
             x_p2_jump_decode,
             x_p2b_jump_decode,
             x_p2nosc1,
             x_p2nosc2,
             x_p2shimm_a,
             x_snglec_wben,
             xholdup2,
             xholdup2b,
             xholdup3,
             xnwb,
             xp2bccmatch,
             xp2ccmatch,
             xp2idest,
             xp3ccmatch,
             awake_a,
             en1,
             ifetch_aligned,
             inst_stepping,
             instr_pending_r,
             pcen,
             pcen_niv,
             brk_inst_a,
             dest,
             desten,
             en2,
             fs2a,
             p2_a_field_r,
             p2_abs_neg_a,
             p2_b_field_r,
             p2_brcc_instr_a,
             p2_c_field_r,
             p2_dopred,
             p2_dopred_ds,
             p2_dopred_nds,
             p2_dorel,
             p2_iw_r,
             p2_jblcc_a,
             p2_lp_instr,
             p2_not_a,
             p2_s1a,
             p2_s1en,
             p2_s2a,
             p2_shimm_data,
             p2_shimm_s1_a,
             p2_shimm_s2_a,
             p2bch,
             p2cc,
             p2conditional,
             p2condtrue,
             p2delay_slot,
             p2format,
             p2iv,
             p2limm,
             p2lr,
             p2minoropcode,
             p2offset,
             p2opcode,
             p2setflags,
             p2sleep_inst,
             p2st,
             p2subopcode,
             p2subopcode1_r,
             p2subopcode2_r,
             p2subopcode3_r,
             p2subopcode4_r,
             p2subopcode5_r,
             p2subopcode6_r,
             p2subopcode7_r,
             s1a,
             s1en,
             s2en,
             en2b,
             mload2b,
             mstore2b,
             p2b_a_field_r,
             p2b_abs_op,
             p2b_alu_op,
             p2b_arithiv,
             p2b_awb_field,
             p2b_b_field_r,
             p2b_bch,
             p2b_blcc_a,
             p2b_c_field_r,
             p2b_cc,
             p2b_conditional,
             p2b_condtrue,
             p2b_delay_slot,
             p2b_dojcc,
             p2b_dopred_ds,
             p2b_format,
             p2b_iv,
             p2b_jlcc_a,
             p2b_limm,
             p2b_lr,
             p2b_minoropcode,
             p2b_neg_op,
             p2b_not_op,
             p2b_opcode,
             p2b_setflags,
             p2b_shift_by_one_a,
             p2b_shift_by_three_a,
             p2b_shift_by_two_a,
             p2b_shift_by_zero_a,
             p2b_shimm_data,
             p2b_shimm_s1_a,
             p2b_shimm_s2_a,
             p2b_size,
             p2b_st,
             p2b_subopcode,
             p2b_subopcode1_r,
             p2b_subopcode2_r,
             p2b_subopcode3_r,
             p2b_subopcode4_r,
             p2b_subopcode5_r,
             p2b_subopcode6_r,
             p2b_subopcode7_r,
             p2b_jmp_holdup_a,
             en3,
             en3_niv_a,
             ldvalid_wb,
             mload,
             mstore,
             nocache,
             p3_alu_absiv,
             p3_alu_arithiv,
             p3_alu_logiciv,
             p3_alu_op,
             p3_alu_snglopiv,
             p3_bit_op_sel,
             p3_brcc_instr_a,
             p3_docmprel_a,
             p3_flag_instr,
	     p3_sync_instr,
             p3_max_instr,
             p3_min_instr,
             p3_ni_wbrq,
             p3_shiftin_sel_r,
             p3_sop_op_r,
             p3_xmultic_nwb,
             p3a_field_r,
             p3awb_field_r,
             p3b_field_r,
             p3c_field_r,
             p3cc,
             p3condtrue,
             p3destlimm,
             p3dolink,
             p3format,
             p3iv,
             p3lr,
             p3minoropcode,
             p3opcode,
             p3q,
             p3setflags,
             p3sr,
             p3subopcode,
             p3subopcode1_r,
             p3subopcode2_r,
             p3subopcode3_r,
             p3subopcode4_r,
             p3subopcode5_r,
             p3subopcode6_r,
             p3subopcode7_r,
             p3wb_en,
             p3wb_en_nld,
             p3wba,
             p3wba_nld,
             sc_load1,
             sc_load2,
             sc_reg1,
             sc_reg2,
             sex,
             size,
             wben_nxt,
             wba,
             wben,
             p4_docmprel,
             loopcount_hit_a,
             p4_disable_r,
             p4iv,
             flagu_block,
             instruction_error,
             interrupt_holdoff,
             kill_last,
             kill_p1_a,
             kill_p1_en_a,
             kill_p1_nlp_a,
             kill_p1_nlp_en_a,
             kill_p2_a,
             kill_p2_en_a,
             kill_p2b_a,
             kill_p3_a,
             kill_tagged_p1,
             stop_step,
             hold_int_st2_a);

`include "arcutil_pkg_defines.v"
`include "arcutil.v"
`include "extutil.v"
   
   input                          clk;  //  system clock
   input                          rst_a; //  system reset
   input                          en;  //  system go
   input                          actionhalt;
   input                          actionpt_swi_a;
   input                          actionpt_pc_brk_a;
   input                          p2_ap_stall_a;
   input [31:0]                   aux_addr; 
   input [3:0]                    aluflags_r; 
   input [3:0]                    br_flags_a; 
   input                          cr_hostw; 
   input                          do_inst_step_r; 
   input                          h_pcwr; 
   input                          h_pcwr32; 
   input [5:0]                    h_regadr; 
   input                          holdup2b; 
   input                          ivalid_aligned; 
   input                          ivic; 
   input                          ldvalid; 
	   
   input                          loop_kill_p1_a; 
   input                          loop_int_holdoff_a;
   input                          loopend_hit_a;
 
   input                          sync_queue_idle; 
   input                          dmp_mload;
   input                          dmp_mstore;
   input                          is_local_ram;
   input                          lpending; 
   input                          debug_if_r;
   input                          mwait; 
   input                          p1int; 
   input [DATAWORD_MSB:0]         p1iw_aligned_a; 
   input                          p2ilev1; 
   input                          p2int; 
   input                          p2bint; 
   input                          p3int; 
   input                          pcounter_jmp_restart_r; 
   input [5:0]                    regadr; 
   input                          regadr_eq_src1; 
   input                          regadr_eq_src2; 
   input                          sleeping; 
   input                          sleeping_r2;
   input                          x_idecode2; 
   input                          x_idecode2b; 
   input                          x_idecode3; 
   input                          x_idop_decode2; 
   input                          x_isop_decode2; 
   input                          x_multic_busy; 
   input [5:0]                    x_multic_wba; 
   input                          x_multic_wben; 
   input                          x_p1_rev_src; 
   input                          x_p2_bfield_wb_a; 
   input                          x_p2_jump_decode; 
   input                          x_p2b_jump_decode; 
   input                          x_p2nosc1; 
   input                          x_p2nosc2; 
   input                          x_p2shimm_a; 
   input                          x_snglec_wben; 
   input                          xholdup2; 
   input                          xholdup2b; 
   input                          xholdup3; 
   input                          xnwb; 
   input                          xp2bccmatch; 
   input                          xp2ccmatch; 
   input                          xp2idest; 
   input                          xp3ccmatch;

   output                         awake_a; 
   output                         en1; 
   output                         ifetch_aligned; 
   output                         inst_stepping; 
   output                         instr_pending_r; 
   output                         pcen; 
   output                         pcen_niv; 
   output                         brk_inst_a; 
   output [5:0]                   dest; 
   output                         desten; 
   output                         en2; 
   output [5:0]                   fs2a; 
   output [5:0]                   p2_a_field_r; 
   output                         p2_abs_neg_a; 
   output [5:0]                   p2_b_field_r; 
   output                         p2_brcc_instr_a; 
   output [5:0]                   p2_c_field_r;
   output                         p2_dopred; 
   output                         p2_dopred_ds; 
   output                         p2_dopred_nds; 
   output                         p2_dorel; 
   output [INSTR_UBND:0]          p2_iw_r; 
   output                         p2_jblcc_a; 
   output                         p2_lp_instr; 
   output                         p2_not_a; 
   output [5:0]                   p2_s1a; 
   output                         p2_s1en; 
   output [5:0]                   p2_s2a; 
   output [12:0]                  p2_shimm_data; 
   output                         p2_shimm_s1_a; 
   output                         p2_shimm_s2_a; 
   output                         p2bch; 
   output [3:0]                   p2cc; 
   output                         p2conditional; 
   output                         p2condtrue; 
   output                         p2delay_slot; 
   output [1:0]                   p2format; 
   output                         p2iv; 
   output                         p2limm; 
   output                         p2lr; 
   output [5:0]                   p2minoropcode; 
   output [TARGSZ:0]              p2offset; 
   output [4:0]                   p2opcode; 
   output                         p2setflags; 
   output                         p2sleep_inst; 
   output                         p2st; 
   output [5:0]                   p2subopcode; 
   output [1:0]                   p2subopcode1_r; 
   output [4:0]                   p2subopcode2_r; 
   output [2:0]                   p2subopcode3_r; 
   output                         p2subopcode4_r; 
   output [1:0]                   p2subopcode5_r; 
   output [2:0]                   p2subopcode6_r; 
   output [1:0]                   p2subopcode7_r; 
   output [5:0]                   s1a; 
   output                         s1en; 
   output                         s2en; 
   output                         en2b; 
   output                         mload2b; 
   output                         mstore2b; 
   output [5:0]                   p2b_a_field_r; 
   output                         p2b_abs_op; 
   output [1:0]                   p2b_alu_op; 
   output                         p2b_arithiv; 
   output [1:0]                   p2b_awb_field; 
   output [5:0]                   p2b_b_field_r; 
   output                         p2b_bch; 
   output                         p2b_blcc_a; 
   output [5:0]                   p2b_c_field_r; 
   output [3:0]                   p2b_cc; 
   output                         p2b_conditional; 
   output                         p2b_condtrue; 
   output                         p2b_delay_slot; 
   output                         p2b_dojcc; 
   output                         p2b_dopred_ds; 
   output [1:0]                   p2b_format; 
   output                         p2b_iv; 
   output                         p2b_jlcc_a; 
   output                         p2b_limm; 
   output                         p2b_lr; 
   output [5:0]                   p2b_minoropcode; 
   output                         p2b_neg_op; 
   output                         p2b_not_op; 
   output [4:0]                   p2b_opcode; 
   output                         p2b_setflags; 
   output                         p2b_shift_by_one_a; 
   output                         p2b_shift_by_three_a; 
   output                         p2b_shift_by_two_a; 
   output                         p2b_shift_by_zero_a; 
   output [12:0]                  p2b_shimm_data; 
   output                         p2b_shimm_s1_a; 
   output                         p2b_shimm_s2_a; 
   output [1:0]                   p2b_size; 
   output                         p2b_st; 
   output [5:0]                   p2b_subopcode; 
   output [1:0]                   p2b_subopcode1_r; 
   output [4:0]                   p2b_subopcode2_r; 
   output [2:0]                   p2b_subopcode3_r; 
   output                         p2b_subopcode4_r; 
   output [1:0]                   p2b_subopcode5_r; 
   output [2:0]                   p2b_subopcode6_r; 
   output [1:0]                   p2b_subopcode7_r; 
   output                          p2b_jmp_holdup_a;
   output                         en3; 
   output                         en3_niv_a; 
   output                         ldvalid_wb; 
   output                         mload; 
   output                         mstore; 
   output                         nocache; 
   output                         p3_alu_absiv; 
   output                         p3_alu_arithiv; 
   output                         p3_alu_logiciv; 
   output [1:0]                   p3_alu_op; 
   output                         p3_alu_snglopiv; 
   output [1:0]                   p3_bit_op_sel; 
   output                         p3_brcc_instr_a; 
   output                         p3_docmprel_a;
   output                         p3_flag_instr; 
   output                         p3_sync_instr;
   output                         p3_max_instr; 
   output                         p3_min_instr; 
   output                         p3_ni_wbrq; 
   output [1:0]                   p3_shiftin_sel_r; 
   output [2:0]                   p3_sop_op_r; 
   output                         p3_xmultic_nwb; 
   output [5:0]                   p3a_field_r; 
   output [1:0]                   p3awb_field_r; 
   output [5:0]                   p3b_field_r; 
   output [5:0]                   p3c_field_r; 
   output [3:0]                   p3cc; 
   output                         p3condtrue; 
   output                         p3destlimm; 
   output                         p3dolink; 
   output [1:0]                   p3format; 
   output                         p3iv; 
   output                         p3lr; 
   output [5:0]                   p3minoropcode; 
   output [4:0]                   p3opcode; 
   output [4:0]                   p3q; 
   output                         p3setflags; 
   output                         p3sr; 
   output [5:0]                   p3subopcode; 
   output [1:0]                   p3subopcode1_r; 
   output [4:0]                   p3subopcode2_r; 
   output [2:0]                   p3subopcode3_r; 
   output                         p3subopcode4_r; 
   output [1:0]                   p3subopcode5_r; 
   output [2:0]                   p3subopcode6_r; 
   output [1:0]                   p3subopcode7_r; 
   output                         p3wb_en; 
   output                         p3wb_en_nld; 
   output [5:0]                   p3wba; 
   output [5:0]                   p3wba_nld; 
   output                         sc_load1; 
   output                         sc_load2; 
   output                         sc_reg1; 
   output                         sc_reg2; 
   output                         sex; 
   output [1:0]                   size; 
   output                         wben_nxt; 
   output [5:0]                   wba; 
   output                         wben; 
   output                         p4_docmprel; 
   output                         loopcount_hit_a; 
   output                         p4_disable_r; 
   output                         p4iv; 
   output                         flagu_block; 
   output                         instruction_error; 
   output                         interrupt_holdoff; 
   output                         kill_last; 
   output                         kill_p1_a; 
   output                         kill_p1_en_a; 
   output                         kill_p1_nlp_a; 
   output                         kill_p1_nlp_en_a; 
   output                         kill_p2_a; 
   output                         kill_p2_en_a; 
   output                         kill_p2b_a; 
   output                         kill_p3_a; 
   output                         kill_tagged_p1; 
   output                         stop_step;
   output                         hold_int_st2_a;

//------------------------------------------------------------------------------
// Stage 1
//------------------------------------------------------------------------------
   wire                           awake_a; 
   wire                           en1; 
   wire                           ifetch_aligned; 
   wire                           inst_stepping; 
   wire                           instr_pending_r; 
   wire                           pcen; 
   wire                           pcen_niv;

//------------------------------------------------------------------------------
// Stage 2
//------------------------------------------------------------------------------
   wire                           brk_inst_a; 
   wire [5:0]                     dest; 
   wire                           desten; 
   wire                           en2; 
   wire [5:0]                     fs2a; 
   wire [5:0]                     p2_a_field_r; 
   wire                           p2_abs_neg_a; 
   wire [5:0]                     p2_b_field_r; 
   wire                           p2_brcc_instr_a; 
   wire [5:0]                     p2_c_field_r; 
   wire                           p2_dopred; 
   wire                           p2_dopred_ds; 
   wire                           p2_dopred_nds; 
   wire                           p2_dorel; 
   wire [INSTR_UBND:0]            p2_iw_r; 
   wire                           p2_jblcc_a; 
   wire                           p2_lp_instr; 
   wire                           p2_not_a; 
   wire [5:0]                     p2_s1a; 
   wire                           p2_s1en; 
   wire [5:0]                     p2_s2a; 
   wire [12:0]                    p2_shimm_data; 
   wire                           p2_shimm_s1_a; 
   wire                           p2_shimm_s2_a; 
   wire                           p2bch; 
   wire [3:0]                     p2cc; 
   wire                           p2conditional; 
   wire                           p2condtrue; 
   wire                           p2delay_slot; 
   wire [1:0]                     p2format; 
   wire                           p2iv; 
   wire                           p2limm; 
   wire                           p2lr; 
   wire [5:0]                     p2minoropcode; 
   wire [TARGSZ:0]                p2offset; 
   wire [4:0]                     p2opcode; 
   wire                           p2setflags; 
   wire                           p2sleep_inst; 
   wire                           p2st; 
   wire [5:0]                     p2subopcode; 
   wire [1:0]                     p2subopcode1_r; 
   wire [4:0]                     p2subopcode2_r; 
   wire [2:0]                     p2subopcode3_r; 
   wire                           p2subopcode4_r; 
   wire [1:0]                     p2subopcode5_r; 
   wire [2:0]                     p2subopcode6_r; 
   wire [1:0]                     p2subopcode7_r; 
   wire [5:0]                     s1a; 
   wire                           s1en; 
   wire                           s2en;

//------------------------------------------------------------------------------
// Stage 2b
//------------------------------------------------------------------------------
   wire                           en2b; 
   wire                           en2b_niv_a; 
   wire                           mload2b; 
   wire                           mstore2b; 
   wire [5:0]                     p2b_a_field_r; 
   wire                           p2b_abs_op; 
   wire [1:0]                     p2b_alu_op; 
   wire                           p2b_arithiv; 
   wire [1:0]                     p2b_awb_field; 
   wire [5:0]                     p2b_b_field_r; 
   wire                           p2b_bch; 
   wire                           p2b_blcc_a; 
   wire [5:0]                     p2b_c_field_r; 
   wire [3:0]                     p2b_cc; 
   wire                           p2b_conditional; 
   wire                           p2b_condtrue; 
   wire                           p2b_delay_slot; 
   wire                           p2b_dojcc; 
   wire                           p2b_dopred_ds; 
   wire [1:0]                     p2b_format; 
   wire                           p2b_iv; 
   wire                           p2b_jlcc_a; 
   wire                           p2b_limm; 
   wire                           p2b_lr; 
   wire [5:0]                     p2b_minoropcode; 
   wire                           p2b_neg_op; 
   wire                           p2b_not_op; 
   wire [4:0]                     p2b_opcode; 
   wire                           p2b_setflags; 
   wire                           p2b_shift_by_one_a; 
   wire                           p2b_shift_by_three_a; 
   wire                           p2b_shift_by_two_a; 
   wire                           p2b_shift_by_zero_a; 
   wire [12:0]                    p2b_shimm_data; 
   wire                           p2b_shimm_s1_a; 
   wire                           p2b_shimm_s2_a; 
   wire                                  p2b_jmp_holdup_a;
   wire [1:0]                     p2b_size; 
   wire                           p2b_st; 
   wire [5:0]                     p2b_subopcode; 
   wire [1:0]                     p2b_subopcode1_r; 
   wire [4:0]                     p2b_subopcode2_r; 
   wire [2:0]                     p2b_subopcode3_r; 
   wire                           p2b_subopcode4_r; 
   wire [1:0]                     p2b_subopcode5_r; 
   wire [2:0]                     p2b_subopcode6_r; 
   wire [1:0]                     p2b_subopcode7_r;

//------------------------------------------------------------------------------
// Stage 3
//------------------------------------------------------------------------------
   wire                           en3; 
   wire                           en3_niv_a; 
   wire                           ldvalid_wb; 
   wire                           mload; 
   wire                           mstore; 
   wire                           nocache; 
   wire                           p3_alu_absiv; 
   wire                           p3_alu_arithiv; 
   wire                           p3_alu_logiciv; 
   wire [1:0]                     p3_alu_op; 
   wire                           p3_alu_snglopiv; 
   wire [1:0]                     p3_bit_op_sel; 
   wire                           p3_brcc_instr_a; 
   wire                           p3_docmprel_a;
   wire                           p3_flag_instr;
   wire                           p3_sync_instr; 
   wire                           p3_max_instr; 
   wire                           p3_min_instr; 
   wire                           p3_ni_wbrq; 
   wire [1:0]                     p3_shiftin_sel_r; 
   wire [2:0]                     p3_sop_op_r; 
   wire                           p3_xmultic_nwb; 
   wire [5:0]                     p3a_field_r; 
   wire [1:0]                     p3awb_field_r; 
   wire [5:0]                     p3b_field_r; 
   wire [5:0]                     p3c_field_r; 
   wire [3:0]                     p3cc; 
   wire                           p3condtrue; 
   wire                           p3destlimm; 
   wire                           p3dolink; 
   wire [1:0]                     p3format; 
   wire                           p3iv; 
   wire                           p3lr; 
   wire [5:0]                     p3minoropcode; 
   wire [4:0]                     p3opcode; 
   wire [4:0]                     p3q; 
   wire                           p3setflags; 
   wire                           p3sr; 
   wire [5:0]                     p3subopcode; 
   wire [1:0]                     p3subopcode1_r; 
   wire [4:0]                     p3subopcode2_r; 
   wire [2:0]                     p3subopcode3_r; 
   wire                           p3subopcode4_r; 
   wire [1:0]                     p3subopcode5_r; 
   wire [2:0]                     p3subopcode6_r; 
   wire [1:0]                     p3subopcode7_r; 
   wire                           p3wb_en; 
   wire                           p3wb_en_nld; 
   wire [5:0]                     p3wba; 
   wire [5:0]                     p3wba_nld; 
   wire                           sc_load1; 
   wire                           sc_load2; 
   wire                           sc_reg1; 
   wire                           sc_reg2; 
   wire                           sex; 
   wire [1:0]                     size; 
   wire                           wben_nxt;
  
//------------------------------------------------------------------------------
// Stage 4
//------------------------------------------------------------------------------
   wire [5:0]                     wba; 
   wire                           wben; 
   wire                           p4_docmprel; 
   wire                           loopcount_hit_a; 
   wire                           p4_disable_r;
   wire                           p4iv;
   

//------------------------------------------------------------------------------
// Interrupts
//------------------------------------------------------------------------------

   wire                           flagu_block; 
   wire                           instruction_error; 
   wire                           interrupt_holdoff;

//------------------------------------------------------------------------------
// Misc.
//------------------------------------------------------------------------------

   wire                           kill_last; 
   wire                           kill_p1_a; 
   wire                           kill_p1_en_a; 
   wire                           kill_p1_nlp_a; 
   wire                           kill_p1_nlp_en_a; 
   wire                           kill_p2_a; 
   wire                           kill_p2_en_a; 
   wire                           kill_p2b_a; 
   wire                           kill_p3_a; 
   wire                           kill_tagged_p1; 
   wire                           stop_step;
   wire                           hold_int_st2_a;
   wire                           i_hold_int_st2_a;
   wire                           i_no_pc_stall_a;
   

//------------------------------------------------------------------------------
// Internal signals
//------------------------------------------------------------------------------
   
//------------------------------------------------------------------------------
// Stage 1
//------------------------------------------------------------------------------
   reg                            i_go_r; 
   reg                            i_instr_pending_r; 
   reg                            i_p1p2step_r; 
   wire                           i_awake_a; 
   wire                           i_flagu_block_a; 
   wire                           i_go_a; 
   wire                           i_go_nxt; 
   wire                           i_hostload_non_iv_a; 
   wire                           i_ifetch_aligned_a; 
   wire                           i_inst_stepping_a; 
   wire                           i_interrupt_holdoff_a; 
   wire                           i_kill_p1_a; 
   wire                           i_kill_p1_en_a; 
   wire                           i_kill_p1_nlp_a; 
   wire                           i_kill_p1_nlp_en_a; 
   wire                           i_kill_p2_a; 
   wire                           i_kill_p2_en_a; 
   wire                           i_p1_zero_loop_stall_a;
   wire                           i_p1_ct_int_loop_stall_a;
   wire                           i_p1_enable_a; 
   wire                           i_p1_enable_niv_a; 
   wire                           i_p1_step_stall_a;
   wire                           i_p2_step_a; 
   wire                           i_pcen_a; 
   wire                           i_pcen_mwait_a; 
   wire                           i_pcen_non_iv_a; 
   wire                           i_pcen_p1_a; 
   wire                           i_pcen_p2_a; 
   wire                           i_pcen_p2b_a; 
   wire                           i_pcen_p3_a; 
   wire                           i_pcen_step_a; 
   wire                           i_start_step_a; 
   wire                           i_stop_step_a;
   reg                            i_tag_nxt_p1_killed_r; 
   wire                           i_tag_nxt_p1_killed_nxt;
   wire                           i_actionhalt_a;
   wire                           i_actionhalt_holdoff_a;
   
//------------------------------------------------------------------------------
// Stage 2
//------------------------------------------------------------------------------
   wire                           i_p2_instruction_error_a; 
   wire                           i_p2_no_arc_or_ext_instr_a; 
   wire  [CONDITION_CODE_MSB:0]   i_p2_16_q_a; 
   wire                           i_p2_16_sop_inst_a; 
   wire  [CONDITION_CODE_MSB:0]   i_p2_32_q_a; 
   wire                           i_p2_32_sop_inst_a; 
   wire  [OPERAND_MSB:0]          i_p2_a_field16_r; 
   wire                           i_p2_a_field_long_imm_a; 
   wire  [OPERAND_MSB:0]          i_p2_a_field_r; 
   wire                           i_p2_abs_neg_decode_a; 
   reg                            i_p2_arcop_a; 
   wire                           i_p2_b32_a; 
   wire  [OPERAND16_MSB:0]        i_p2_b_field16_r; 
   wire                           i_p2_b_field16_zop_j_a; 
   wire                           i_p2_b_field16_zop_jd_a; 
   wire                           i_p2_b_field16_zop_jeq_a; 
   wire                           i_p2_b_field16_zop_jne_a; 
   wire                           i_p2_b_field_long_imm_a; 
   wire  [OPERAND_MSB:0]          i_p2_b_field_r; 
   wire                           i_p2_b_field_zop_sleep_a; 
   wire                           i_p2_b_field_zop_swi_a; 
   wire  [TARGSZ:0]               i_p2_b_offset_a; 
   wire                           i_p2_bcc16_no_delay_a; 
   wire                           i_p2_bcc32_a; 
   wire                           i_p2_bl32_a; 
   wire                           i_p2_bl_blcc_32_a; 
   wire                           i_p2_bl_niv_a; 
   wire                           i_p2_jblcc_iv_a; 
   wire                           i_p2_jblcc_niv_a; 
   wire  [TARGSZ:0]               i_p2_bl_offset_a; 
   wire                           i_p2_blcc32_a; 
   wire                           i_p2_br16_no_delay_a; 
   wire                           i_p2_br32_u6_a; 
   wire  [TARGSZ:0]               i_p2_br_offset_a; 
   wire                           i_p2_br_or_bbit_a; 
   wire                           i_p2_br_or_bbit_iv_a; 
   wire                           i_p2_bra32_a; 
   wire                           i_p2_branch16_a; 
   wire                           i_p2_branch16_cc_a; 
   wire                           i_p2_branch32_a; 
   wire                           i_p2_branch32_cc_a; 
   wire                           i_p2_branch_iv_a; 
   wire                           i_p2_branch_cc_a; 
   wire                           i_p2_branch_holdup_a; 
   wire                           i_p2_brcc_pred_nds_a; 
   wire                           i_p2_brcc_pred_nds_en_a; 
   wire                           i_p2_brk_inst_a; 
   wire                           i_p2_brk_sleep_swi_a; 
   wire  [OPERAND_MSB:0]          i_p2_c_field16_2_r; 
   wire  [OPERAND16_MSB:0]        i_p2_c_field16_r; 
   wire                           i_p2_c_field16_sop_j_a; 
   wire                           i_p2_c_field16_sop_jd_a; 
   wire                           i_p2_c_field16_sop_jl_a; 
   wire                           i_p2_c_field16_sop_jld_a; 
   wire                           i_p2_c_field16_sop_sub_a; 
   wire                           i_p2_c_field16_zop_a; 
   wire                           i_p2_c_field_long_imm_a; 
   wire  [OPERAND_MSB:0]          i_p2_c_field_r; 
   reg                            i_p2_ccmatch16_a; 
   reg                            i_p2_ccmatch32_a; 
   wire                           i_p2_ccmatch_alu_ext_a; 
   wire                           i_p2_conditional_a; 
   wire                           i_p2_condtrue_a; 
   wire                           i_p2_condtrue_lp_a; 
   wire                           i_p2_condtrue_nlp_a; 
   wire                           i_p2_condtrue_sel0_a; 
   wire                           i_p2_condtrue_sel1_a; 
   wire                           i_p2_condtrue_sel2_a; 
   wire                           i_p2_dest_imm_a; 
   wire                           i_p2_dest_immediate_a; 
   wire                           i_p2_dest_sel0_a; 
   wire                           i_p2_dest_sel10_a; 
   wire                           i_p2_dest_sel1_a; 
   wire                           i_p2_dest_sel2_a; 
   wire                           i_p2_dest_sel3_a; 
   wire                           i_p2_dest_sel4_a; 
   wire                           i_p2_dest_sel5_a; 
   wire                           i_p2_dest_sel6_a; 
   wire                           i_p2_dest_sel7_a; 
   wire                           i_p2_dest_sel8_a; 
   wire                           i_p2_dest_sel9_a; 
   wire  [OPERAND_MSB:0]          i_p2_destination_a; 
   wire                           i_p2_destination_en_a; 
   wire                           i_p2_dolink_a; 
   wire                           i_p2_dorel_a; 
   wire                           i_p2_enable_a; 
   wire                           i_p2_en_no_pwr_save_a; 
   wire                           i_p2_flag_bit_a; 
   wire                           i_p2_flagu_block_a; 
   wire                           i_p2_fmt_cond_reg_a; 
   wire                           i_p2_fmt_cond_reg_dec_a; 
   wire                           i_p2_fmt_cond_reg_u6_a; 
   wire                           i_p2_fmt_reg_a; 
   wire                           i_p2_fmt_s12_a; 
   wire                           i_p2_fmt_u6_a; 
   wire  [FORMAT_MSB:0]           i_p2_format_r; 
   wire                           i_p2_has_dslot_a; 
   wire                           i_p2_hi_reg16_long_imm_a; 
   wire  [OPERAND_MSB:0]          i_p2_hi_reg16_r; 
   wire                           i_p2_holdup_stall_a; 
   wire                           i_p2_instr_err_stall_a;
   wire                           i_p2_is_dslot_nxt; 
   reg                            i_p2_is_dslot_r; 
   wire                           i_p2_is_limm_nxt; 
   reg                            i_p2_is_limm_r; 
   wire                           i_p2_iv_nxt; 
   reg                            i_p2_iv_r; 
   reg   [INSTR_UBND:0]           i_p2_iw_r; 
   wire                           i_p2_kill_p1_a; 
   wire                           i_p2_kill_p1_en_a; 
   wire                           i_p2_ldo16_a; 
   wire                           i_p2_long_immediate1_a; 
   wire                           i_p2_long_immediate2_a; 
   wire                           i_p2_long_immediate_a; 
   wire                           i_p2_limm_a; 
   wire                           i_p2_loop32_a; 
   wire                           i_p2_loop32_cc_a; 
   wire                           i_p2_loop32_ncc_a; 
   wire                           i_p2_ct_brcc_stall_a; 
   wire  [TARGSZ:0]               i_p2_lp_offset_a; 
   wire                           i_p2_lr_decode_iv_a; 
   wire                           i_p2_minor_op_abs_a; 
   wire  [SUBOPCODE_MSB:0]        i_p2_minoropcode_r; 
   wire                           i_p2_mov_hi_a; 
   wire                           i_p2_no_ld_a; 
   wire                           i_p2_no_ld_and_rev_a; 
   wire                           i_p2_nojump_a; 
   wire                           i_p2_not_decode_a; 
   wire  [TARGSZ:0]               i_p2_offset_a; 
   wire                           i_p2_opcode_16_addcmp_a; 
   wire                           i_p2_opcode_16_alu_a; 
   wire                           i_p2_opcode_16_arith_a; 
   wire                           i_p2_opcode_16_bcc_a; 
   wire                           i_p2_opcode_16_bcc_cc_a; 
   wire                           i_p2_opc_16_bcc_cc_s7_a; 
   wire                           i_p2_opcode_16_bl_a; 
   wire                           i_p2_opcode_16_brcc_a; 
   wire                           i_p2_opcode_16_gp_rel_a; 
   wire                           i_p2_opcode_16_ld_add_a; 
   wire                           i_p2_opcode_16_ld_pc_a; 
   wire                           i_p2_opcode_16_mov_a; 
   wire                           i_p2_opcode_16_mv_add_a; 
   wire                           i_p2_opcode_16_sp_rel_a; 
   wire                           i_p2_opcode_16_ushimm_shft_a; 
   wire                           i_p2_opcode_16_ssub_a; 
   wire                           i_p2_opcode_32_bcc_a; 
   wire                           i_p2_opcode_32_blcc_a; 
   wire                           i_p2_opcode_32_fmt1_a; 
   wire                           i_p2_opcode_32_ld_a; 
   wire                           i_p2_opcode_32_st_a; 
   wire  [OPCODE_MSB:0]           i_p2_opcode_a; 
   wire                           i_p2_p2b_jmp_iv_a; 
   wire                           i_p2_push_blink_a; 
   wire                           i_p2_push_decode_a; 
   wire                           i_p2_pop_decode_a; 
   wire                           i_p2_pwr_save_stall_a; 
   wire  [CONDITION_CODE_MSB:0]   i_p2_q_a; 
   wire                           i_p2_q_sel_16_a; 
   wire                           i_p2_rev_arith_a; 
   reg                            i_p2_s1_en_cfield_dec_a; 
   reg                            i_p2_s1_en_decode_a; 
   reg                            i_p2_s1_en_subop2_dec_a; 
   reg                            i_p2_s1_en_subop_dec_a;
   reg                            i_p2_s2_en_decode_a; 
   wire                           i_p2_shimm16_a; 
   wire  [SHIMM_MSB:0]            i_p2_shimm16_data_a; 
   wire                           i_p2_shimm16_data_sel0_a; 
   wire                           i_p2_shimm16_data_sel1_a; 
   wire                           i_p2_shimm16_data_sel2_a; 
   wire                           i_p2_shimm16_data_sel3_a; 
   wire                           i_p2_shimm16_data_sel4_a; 
   wire                           i_p2_shimm16_data_sel5_a; 
   wire                           i_p2_shimm16_data_sel6_a; 
   wire                           i_p2_shimm_a; 
   wire                           i_p2_shimm_s1_a; 
   wire                           i_p2_short_imm_sel0_a; 
   wire                           i_p2_short_imm_sel1_a; 
   wire                           i_p2_short_imm_sel2_a; 
   wire                           i_p2_short_imm_sel3_a; 
   wire  [SHIMM_MSB:0]            i_p2_short_immediate_a; 
   wire                           i_p2_sleep_inst_a; 
   wire                           i_p2_sleep_inst_niv_a; 
   wire  [OPERAND_MSB:0]          i_p2_source1_addr_a; 
   wire                           i_p2_source1_en_a; 
   wire  [OPERAND_MSB:0]          i_p2_source2_addr_a; 
   wire                           i_p2_source2_en_a; 
   wire                           i_p2_src1_addr_sel0_a; 
   wire                           i_p2_src1_addr_sel1_a; 
   wire                           i_p2_src2_addr_sel0_a; 
   wire                           i_p2_src2_addr_sel1_a; 
   wire                           i_p2_src2_b_field_a; 
   wire                           i_p2_src2_hi_a; 
   wire                           i_p2_src2_rblink_a; 
   wire                           i_p2_sshimm16_a; 
   wire                           i_p2_sshimm16_s1_a; 
   wire                           i_p2_sshimm32_a; 
   wire                           i_p2_sshimm32_s1_a; 
   wire                           i_p2_sshimm_a; 
   wire                           i_p2_sshimm_s1_a; 
   wire                           i_p2_sto16_a; 
   wire  [SUBOPCODE1_16_MSB:0]    i_p2_subopcode1_r; 
   wire  [SUBOPCODE2_16_MSB:0]    i_p2_subopcode2_r; 
   wire  [SUBOPCODE3_16_MSB:0]    i_p2_subopcode3_r; 
   wire                           i_p2_subopcode4_r; 
   wire  [SUBOPCODE1_16_MSB:0]    i_p2_subopcode5_r; 
   wire  [SUBOPCODE3_16_MSB:0]    i_p2_subopcode6_r; 
   wire  [SUBOPCODE1_16_MSB:0]    i_p2_subopcode7_r; 
   wire                           i_p2_subop_16_abs_a; 
   wire                           i_p2_subop_16_brk_a; 
   wire                           i_p2_subop_16_btst_u5_a; 
   wire                           i_p2_subop_16_ldb_gp_a; 
   wire                           i_p2_subop_16_ldw_gp_a; 
   wire                           i_p2_subop_16_mov_hi1_a; 
   wire                           i_p2_subop_16_mov_hi2_a; 
   wire                           i_p2_subop_16_neg_a; 
   wire                           i_p2_subop_16_not_a; 
   wire                           i_p2_subop_16_pop_u7_a; 
   wire                           i_p2_subop_16_push_u7_a; 
   wire                           i_p2_subop_16_sop_a; 
   wire                           i_p2_subopcode_flag_a; 
   wire                           i_p2_subopcode_j_a; 
   wire                           i_p2_subopcode_jd_a; 
   wire                           i_p2_subopcode_jl_a; 
   wire                           i_p2_subopcode_jld_a; 
   wire                           i_p2_subopcode_ld_a; 
   wire                           i_p2_subopcode_ldb_a; 
   wire                           i_p2_subopcode_ldb_x_a; 
   wire                           i_p2_subopcode_ldw_a; 
   wire                           i_p2_subopcode_ldw_x_a; 
   wire                           i_p2_subopcode_lr_a; 
   wire                           i_p2_subopcode_mov_a; 
   wire  [SUBOPCODE_MSB:0]        i_p2_subopcode_r; 
   wire                           i_p2_subopcode_rcmp_a; 
   wire                           i_p2_subopcode_rsub_a; 
   wire                           i_p2_subopcode_sop_a; 
   wire                           i_p2_swi_inst_a; 
   wire                           i_p2_swi_inst_niv_a; 
   wire                           i_p2_tag_nxt_p1_dslot_nxt; 
   reg                            i_p2_tag_nxt_p1_dslot_r; 
   wire                           i_p2_tag_nxt_p1_limm_nxt; 
   reg                            i_p2_tag_nxt_p1_limm_r; 
   wire                           i_p2_ushimm16_a; 
   wire                           i_p2_ushimm32_a; 
   wire                           i_p2_ushimm32_s1_a; 
   wire                           i_p2_ushimm_a; 
   wire                           i_p2_ushimm_s1_a; 
   wire                           i_p2_zop_decode_a;
   wire                           i_p2_sync_inst_niv_a; 
   wire                           i_p2_b_field_zop_sync_a;
   wire                           i_p2_sync_inst_a;
   reg                            i_p2_ccunit_32_fz_a; 
   reg                            i_p2_ccunit_32_fn_a; 
   reg                            i_p2_ccunit_32_fc_a; 
   reg                            i_p2_ccunit_32_fv_a; 
   reg                            i_p2_ccunit_32_nfz_a; 
   reg                            i_p2_ccunit_32_nfn_a; 
   reg                            i_p2_ccunit_32_nfc_a; 
   reg                            i_p2_ccunit_32_nfv_a; 
   reg                            i_p2_ccunit_16_fz_a; 
   reg                            i_p2_ccunit_16_fn_a; 
   reg                            i_p2_ccunit_16_fc_a; 
   reg                            i_p2_ccunit_16_fv_a; 
   reg                            i_p2_ccunit_16_nfz_a; 
   reg                            i_p2_ccunit_16_nfn_a; 
   reg                            i_p2_ccunit_16_nfc_a; 
   reg                            i_p2_ccunit_16_nfv_a;
   reg                            i_p2_loopend_hit_r;
   
//------------------------------------------------------------------------------
// Stage 2b
//------------------------------------------------------------------------------
   reg                                  i_p2b_jblcc_iv_r; 
   reg                                  i_p2b_branch_iv_r;
   wire                           i_p2b_br_or_bbit32_nxt; 
   wire                           i_p2b_brcc_instr_ds_nxt; 
   wire                           i_p2b_brcc_instr_nds_nxt; 
   wire                           i_p2b_brcc_pred_nxt; 
   wire                           i_p2b_brcc_pred_ds_nxt; 
   reg                            i_p2b_brcc_pred_ds_r; 
   reg                            i_p2b_brcc_pred_r; 
   wire                           i_p2b_16_bit_instr_a; 
   wire                           i_p2b_16_sop_inst_a; 
   wire  [OPERAND_MSB:0]          i_p2b_a_field16_r; 
   wire  [OPERAND_MSB:0]          i_p2b_a_field_r; 
   wire  [OPERAND_MSB:0]          i_p2b_a_field_a; 
   wire                           i_p2b_a_field_a_sel0_a; 
   wire                           i_p2b_a_field_a_sel1_a; 
   wire  [1:0]                    i_p2b_awb_field_a; 
   wire                           i_p2b_awb_field_sel0_a; 
   wire                           i_p2b_awb_field_sel1_a; 
   wire                           i_p2b_awb_field_sel2_a; 
   wire                           i_p2b_awb_field_sel3_a; 
   wire  [OPERAND16_MSB:0]        i_p2b_b_field16_r; 
   wire                           i_p2b_b_field16_zop_j_a; 
   wire                           i_p2b_b_field16_zop_jd_a; 
   wire                           i_p2b_b_field16_zop_jeq_a; 
   wire                           i_p2b_b_field16_zop_jne_a; 
   wire  [OPERAND_MSB:0]          i_p2b_b_field_r; 
   wire                           i_p2b_bch_flagset_a; 
   wire  [SUBOPCODE_MSB:0]        i_p2b_br_bl_subopcode_r; 
   reg                            i_p2b_br_or_bbit32_r; 
   wire                           i_p2b_br_or_bbit_iv_a; 
   reg                            i_p2b_br_or_bbit_r; 
   wire  [OPERAND_MSB:0]          i_p2b_c_field16_2_r; 
   wire  [OPERAND16_MSB:0]        i_p2b_c_field16_r; 
   wire                           i_p2b_c_field16_sop_j_a; 
   wire                           i_p2b_c_field16_sop_jd_a; 
   wire                           i_p2b_c_field16_sop_jl_a; 
   wire                           i_p2b_c_field16_sop_jld_a; 
   wire                           i_p2b_c_field16_sop_sub_a; 
   wire                           i_p2b_c_field16_zop_a; 
   wire  [OPERAND_MSB:0]          i_p2b_c_field_r; 
   reg                            i_p2b_ccmatch32_a; 
   wire                           i_p2b_ccmatch_alu_ext_a; 
   wire                           i_p2b_conditional_a; 
   wire                           i_p2b_condtrue_a; 
   wire                           i_p2b_condtrue_sel0_a; 
   wire                           i_p2b_condtrue_sel1_a; 
   wire                           i_p2b_condtrue_sel2_a; 
   wire                           i_p2b_condtrue_sel3_a; 
   reg                            i_p2b_dest_imm_r; 
   reg                            i_p2b_destination_en_r; 
   wire                           i_p2b_dest_en_iv_a; 
   reg   [OPERAND_MSB:0]          i_p2b_destination_r; 
   wire                           i_p2b_disable_nxt; 
   reg                            i_p2b_disable_r; 
   wire                           i_p2b_dojcc_a; 
   reg                            i_p2b_dolink_r; 
   wire                           i_p2b_dolink_iv_a; 
   wire                           i_p2b_enable_a; 
   wire                           i_p2b_en_nopwr_save_a; 
   wire                           i_p2b_flag_bit_r; 
   wire                           i_p2b_flagu_block_a; 
   wire                           i_p2b_fmt_cond_reg_a; 
   wire  [FORMAT_MSB:0]           i_p2b_format_r; 
   reg                            i_p2b_has_dslot_r; 
   wire                           i_p2b_has_dslot_nxt; 
   reg                            i_p2b_has_limm_r; 
   wire                           i_p2b_has_limm_nxt; 
   wire  [OPERAND_MSB:0]          i_p2b_hi_reg16_r; 
   wire                           i_p2b_holdup_stall_a; 
   wire                           i_p2b_iv_nxt; 
   reg                            i_p2b_iv_r; 
   reg   [INSTR_UBND:0]           i_p2b_iw_r; 
   wire                           i_p2b_jlcc_niv_nxt; 
   wire                           i_p2_jlcc_a; 
   reg                            i_p2b_jlcc_niv_r; 
   wire                           i_p2b_jlcc_iv_a; 
   wire                           i_p2b_jcc_sc_stall_a; 
   wire                           i_p2b_jmp16_niv_a; 
   wire                           i_p2b_jmp16_cc_a; 
   wire                           i_p2b_jmp16_delay_a; 
   wire                           i_p2b_jmp16_delay_sop_a; 
   wire                           i_p2b_jmp16_no_delay_a; 
   wire                           i_p2b_jmp16_no_dly_sop_a; 
   wire                           i_p2b_jmp32_niv_a; 
   wire                           i_p2b_jmp32_cc_a; 
   wire                           i_p2b_jmp32_delay_a; 
   wire                           i_p2b_jmp32_no_delay_a; 
   wire                           i_p2b_jmp_iv_a; 
   wire                           i_p2b_jmp_niv_a; 
   wire                           i_p2b_jmp_cc_a; 
   wire                           i_p2b_jump_holdup_a; 
   wire                           i_p2b_kill_p1_a; 
   wire                           i_p2b_kill_p1_en_a; 
   wire                           i_p2b_kill_p2_a; 
   wire                           i_p2b_kill_p2_en_a; 
   wire                           i_p2b_ld_decode_a; 
   wire                           i_p2b_ld_nsc1_a; 
   wire                           i_p2b_ld_nsc2_a; 
   wire                           i_p2b_ld_nsc_a; 
   wire                           i_p2b_ldo16_a; 
   wire  [MEMOP_ESZ:0]            i_p2b_ldr_e_a; 
   wire                           i_p2b_ldst_shift_a; 
   reg                            i_p2b_limm_dslot_stall_r; 
   wire                           i_p2b_limm_dslot_stall_nxt; 
   reg                            i_p2b_long_immediate_r; 
   wire                           i_p2b_lr_decode_a; 
   wire  [SUBOPCODE_MSB:0]        i_p2b_minoropcode_r; 
   wire  [MEMOP_ESZ:0]            i_p2b_mop_e_a; 
   wire                           i_p2b_nocache_a; 
   wire                           i_p2b_nojump_a; 
   wire                           i_p2b_opcode_16_addcmp_a; 
   wire                           i_p2b_opcode_16_alu_a; 
   wire                           i_p2b_opcode_16_arith_a; 
   wire                           i_p2b_opcode_16_gp_rel_a; 
   wire                           i_p2b_opcode_16_ld_add_a; 
   wire                           i_p2b_opcode_16_ld_pc_a; 
   wire                           i_p2b_opcode_16_ld_u7_a; 
   wire                           i_p2b_opcode_16_ldb_u5_a; 
   wire                           i_p2b_opcode_16_ldw_u6_a; 
   wire                           i_p2b_opc_16_ldwx_u6_a; 
   wire                           i_p2b_opcode_16_mov_a; 
   wire                           i_p2b_opcode_16_mv_add_a; 
   wire                           i_p2b_opcode_16_sp_rel_a; 
   wire                           i_p2b_opcode_16_ssub_a; 
   wire                           i_p2b_opcode_16_st_u7_a; 
   wire                           i_p2b_opcode_16_stb_u5_a; 
   wire                           i_p2b_opcode_16_stw_u6_a; 
   wire                           i_p2b_opcode_32_fmt1_a; 
   wire                           i_p2b_opcode_32_ld_a; 
   wire                           i_p2b_opcode_32_st_a; 
   wire  [OPCODE_MSB:0]           i_p2b_opcode_r; 
   wire                           i_p2b_pwr_save_stall_a; 
   reg   [CONDITION_CODE_MSB:0]   i_p2b_q_r; 
   wire                           i_p2b_sc_load1_a; 
   wire                           i_p2b_sc_load2_a; 
   wire                           i_p2b_sc_reg1_a; 
   wire                           i_p2b_sc_reg1_nwb_a; 
   wire                           i_p2b_sc_reg2_a; 
   wire                           i_p2b_sc_reg2_nwb_a; 
   wire                           i_p2b_setflags_nxt; 
   reg                            i_p2b_setflags_r; 
   wire                           i_p2b_sex_a; 
   wire                           i_p2b_shift_by_one_a; 
   wire                           i_p2b_shift_by_three_a; 
   wire                           i_p2b_shift_by_two_a; 
   wire                           i_p2b_shift_by_zero_a; 
   reg                            i_p2b_shimm_r; 
   reg                            i_p2b_shimm_s1_r; 
   reg   [SHIMM_MSB:0]            i_p2b_short_immediate_r; 
   wire  [1:0]                    i_p2b_size_a; 
   wire                           i_p2b_size_sel0_a; 
   wire                           i_p2b_size_sel1_a; 
   wire                           i_p2b_size_sel2_a; 
   wire                           i_p2b_size_sel3_a; 
   reg   [OPERAND_MSB:0]          i_p2b_source1_addr_r; 
   reg                            i_p2b_source1_en_r; 
   reg   [OPERAND_MSB:0]          i_p2b_source2_addr_r; 
   reg                            i_p2b_source2_en_r; 
   wire                           i_p2b_special_flagset_a; 
   wire                           i_p2b_sr_decode_a; 
   wire                           i_p2b_st_decode_a; 
   wire                           i_p2b_sto16_a; 
   wire  [SUBOPCODE1_16_MSB:0]    i_p2b_subopcode1_r; 
   wire  [SUBOPCODE2_16_MSB:0]    i_p2b_subopcode2_r; 
   wire  [SUBOPCODE3_16_MSB:0]    i_p2b_subopcode3_r; 
   wire                           i_p2b_subopcode4_r; 
   wire  [SUBOPCODE1_16_MSB:0]    i_p2b_subopcode5_r; 
   wire  [SUBOPCODE3_16_MSB:0]    i_p2b_subopcode6_r; 
   wire  [SUBOPCODE1_16_MSB:0]    i_p2b_subopcode7_r; 
   wire                           i_p2b_subop_16_brk_a; 
   wire                           i_p2b_subop_16_ld_a; 
   wire                           i_p2b_subop_16_ld_gp_a; 
   wire                           i_p2b_subop_16_ld_sp_a; 
   wire                           i_p2b_subop_16_ldb_a; 
   wire                           i_p2b_subop_16_ldb_gp_a; 
   wire                           i_p2b_subop_16_ldb_sp_a; 
   wire                           i_p2b_subop_16_ldw_a; 
   wire                           i_p2b_subop_16_ldw_gp_a; 
   wire                           i_p2b_subop_16_mov_hi2_a; 
   wire                           i_p2b_subop_16_pop_u7_a; 
   wire                           i_p2b_subop_16_push_u7_a; 
   wire                           i_p2b_subop_16_sop_a; 
   wire                           i_p2b_subop_16_st_sp_a; 
   wire                           i_p2b_subop_16_stb_sp_a; 
   wire                           i_p2b_subopcode_flag_a; 
   wire                           i_p2b_subopcode_j_a; 
   wire                           i_p2b_subopcode_jd_a; 
   wire                           i_p2b_subopcode_jl_a; 
   wire                           i_p2b_subopcode_jld_a; 
   wire                           i_p2b_subopcode_ld_a; 
   wire                           i_p2b_subopcode_ldb_a; 
   wire                           i_p2b_subopcode_ldb_x_a; 
   wire                           i_p2b_subopcode_ldw_a; 
   wire                           i_p2b_subopcode_ldw_x_a; 
   wire                           i_p2b_subopcode_lr_a; 
   reg   [SUBOPCODE_MSB:0]        i_p2b_subopcode_r; 
   wire                           i_p2b_subopcode_sr_a;
   reg                            i_p2b_ccunit_32_fz_a; 
   reg                            i_p2b_ccunit_32_fn_a; 
   reg                            i_p2b_ccunit_32_fc_a; 
   reg                            i_p2b_ccunit_32_fv_a; 
   reg                            i_p2b_ccunit_32_nfz_a; 
   reg                            i_p2b_ccunit_32_nfn_a; 
   reg                            i_p2b_ccunit_32_nfc_a; 
   reg                            i_p2b_ccunit_32_nfv_a;
   reg                            i_p2b_sync_inst_r;
   
//------------------------------------------------------------------------------
// Stage 3
//------------------------------------------------------------------------------
   reg   [OPERAND_MSB:0]          i_p3_a_field_r; 
   wire                           i_p3_alu16_condtrue_nxt; 
   reg                            i_p3_alu16_condtrue_r; 
   reg                            i_p3_alu_absiv_nxt; 
   reg                            i_p3_alu_absiv_r; 
   reg                            i_p3_alu_arithiv_nxt; 
   reg                            i_p3_alu_arithiv_r; 
   reg                            i_p3_alu_breq16_nxt; 
   reg                            i_p3_alu_breq16_r; 
   reg                            i_p3_alu_brne16_nxt; 
   reg                            i_p3_alu_brne16_r; 
   reg                            i_p3_alu_logiciv_nxt; 
   reg                            i_p3_alu_logiciv_r; 
   reg                            i_p3_alu_max_nxt; 
   reg                            i_p3_alu_max_r; 
   reg                            i_p3_alu_min_nxt; 
   reg                            i_p3_alu_min_r; 
   reg                            i_p3_alu_negiv_nxt; 
   reg                            i_p3_alu_notiv_nxt; 
   reg   [1:0]                    i_p3_alu_op_nxt; 
   reg  [1:0]                     i_p3_alu_op_r; 
   reg                            i_p3_alu_snglopiv_nxt; 
   reg                            i_p3_alu_snglopiv_r; 
   wire                           i_p3_ashift_right_nxt; 
   reg  [1:0]                     i_p3_awb_field_r; 
   wire                           i_p3_awb_pre_wb_nxt; 
   reg  [OPERAND_MSB:0]           i_p3_b_field_r; 
   wire                           i_p3_bch_flagset_a; 
   reg   [1:0]                    i_p3_bit_operand_sel_nxt; 
   reg  [1:0]                     i_p3_bit_operand_sel_r; 
   reg                            i_p3_br_or_bbit32_r; 
   wire                           i_p3_br_or_bbit_iv_a; 
   reg                            i_p3_br_or_bbit_r; 
   wire  [STD_COND_CODE_MSB:0]    i_p3_br_q_a; 
   reg                            i_p3_brcc_pred_r; 
   reg   [OPERAND_MSB:0]          i_p3_c_field_r; 
   wire                           i_p3_cc_xwb_wb_op_a; 
   reg                            i_p3_ccmatch_a; 
   wire                           i_p3_ccmatch_alu_ext_a; 
   wire                           i_p3_ccwbop_decode_iv_a; 
   reg                            i_p3_ccwbop_decode_nxt; 
   reg                            i_p3_ccwbop_decode_r; 
   wire                           i_p3_condtrue_a; 
   wire                           i_p3_condtrue_sel0_a; 
   wire                           i_p3_condtrue_sel1_a; 
   reg                            i_p3_dest_imm_r; 
   wire                           i_p3_destination_en_iv_a; 
   reg                            i_p3_destination_en_r; 
   wire                           i_p3_disable_nxt; 
   reg                            i_p3_disable_r; 
   wire                           i_p3_dolink_iv_a; 
   wire                           i_p3_dolink_nxt; 
   reg                            i_p3_dolink_r; 
   wire                           i_p3_enable_a; 
   wire                           i_p3_enable_nopwr_save_a; 
   wire                           i_p3_en_non_iv_mwait_a; 
   wire                           i_p3_flag_instr_iv_a; 
   wire                           i_p3_flag_instr_nxt; 
   reg                            i_p3_flag_instr_r; 
   wire                           i_p3_flagu_block_a; 
   reg                            i_p3_fmt_cond_reg_r; 
   reg  [FORMAT_MSB:0]            i_p3_format_r; 
   reg                            i_p3_has_dslot_r; 
   wire                           i_p3_holdup_stall_a; 
   wire [STD_COND_CODE_MSB:0]     i_p3_inv_br_q_16_a; 
   reg  [STD_COND_CODE_MSB:0]     i_p3_inv_br_q_32_a; 
   wire [STD_COND_CODE_MSB:0]     i_p3_inv_br_q_a; 
   wire                           i_p3_iv_nxt; 
   reg                            i_p3_iv_r; 
   wire                           i_p3_ld_decode_iv_a; 
   reg                            i_p3_ld_decode_r; 
   wire                           i_p3_ldst_awb_nxt; 
   wire                           i_p3_load_stall_a; 
   wire                           i_p3_lr_a; 
   wire                           i_p3_lr_decode_iv_a; 
   reg                            i_p3_lr_decode_r; 
   reg   [SUBOPCODE_MSB:0]        i_p3_minoropcode_r; 
   wire                           i_p3_mload_a;
   wire                           i_p3_loopcount_hit_a;  
   wire                           i_p3_mstore_a; 
   wire                           i_p3_multic_wben_stall_a; 
   wire                           i_p3_ni_wbrq_a; 
   wire                           i_p3_ni_wbrq_predec_iv_a; 
   reg                            i_p3_ni_wbrq_predec_r; 
   wire [STD_COND_CODE_MSB:0]     i_p3_no_inv_br_q_a; 
   reg  [STD_COND_CODE_MSB:0]     i_p3_no_inv_br_q_tmp; 
   reg                            i_p3_nocache_r; 
   reg                            i_p3_opcode_32_fmt1_r; 
   reg  [OPCODE_MSB:0]            i_p3_opcode_r; 
   wire                           i_p3_pwr_save_stall_a; 
   reg  [CONDITION_CODE_MSB:0]    i_p3_q_r; 
   wire [OPERAND_MSB:0]           i_p3_sc_dest_nxt; 
   wire                           i_p3_sc_dest_nxt_sel1_a; 
   wire                           i_p3_sc_dest_nxt_sel2_a; 
   wire                           i_p3_sc_dest_nxt_sel3_a; 
   reg   [OPERAND_MSB:0]          i_p3_sc_dest_r; 
   wire [OPERAND_MSB:0]           i_p3_sc_wba_a; 
   reg                            i_p3_setflags_r; 
   reg                            i_p3_sex_r; 
   wire [1:0]                     i_p3_shiftin_sel_nxt; 
   reg  [1:0]                     i_p3_shiftin_sel_r; 
   reg  [1:0]                     i_p3_size_r; 
   wire [SOPSIZE:0]               i_p3_sop_op_nxt; 
   wire                           i_p3_sop_op_nxt_sel0_a; 
   wire                           i_p3_sop_op_nxt_sel1_a; 
   wire                           i_p3_sop_op_nxt_sel2_a; 
   wire                           i_p3_sop_op_nxt_sel3_a; 
   wire                           i_p3_sop_op_nxt_sel4_a; 
   wire                           i_p3_sop_op_nxt_sel5_a; 
   wire                           i_p3_sop_op_nxt_sel6_a; 
   reg  [SOPSIZE:0]               i_p3_sop_op_r; 
   wire                           i_p3_sop_sub_nxt; 
   reg                            i_p3_sop_sub_r; 
   reg                            i_p3_special_flagset_r; 
   wire                           i_p3_sr_a; 
   wire                           i_p3_sr_decode_iv_a; 
   reg                            i_p3_sr_decode_r; 
   wire                           i_p3_st_decode_iv_a; 
   reg                            i_p3_st_decode_r; 
   wire                           i_p3_step_stall_a; 
   reg  [SUBOPCODE1_16_MSB:0]     i_p3_subopcode1_r; 
   reg  [SUBOPCODE2_16_MSB:0]     i_p3_subopcode2_r; 
   reg  [SUBOPCODE3_16_MSB:0]     i_p3_subopcode3_r; 
   reg                            i_p3_subopcode4_r; 
   reg  [SUBOPCODE1_16_MSB:0]     i_p3_subopcode5_r; 
   reg  [SUBOPCODE3_16_MSB:0]     i_p3_subopcode6_r; 
   reg  [SUBOPCODE1_16_MSB:0]     i_p3_subopcode7_r; 
   reg  [SUBOPCODE_MSB:0]         i_p3_subopcode_r; 
   wire                           i_p3_wb_instr_a; 
   wire                           i_p3_wb_req_a; 
   wire                           i_p3_wb_rsv_a; 
   wire                           i_p3_wb_stall_a; 
   wire [OPERAND_MSB:0]           i_p3_wback_addr_a; 
   wire [OPERAND_MSB:0]           i_p3_wback_addr_nld_a; 
   wire                           i_p3_wback_en_a; 
   wire                           i_p3_wback_en_nld_a; 
   wire                           i_p3_x_snglec_wben_iv_a; 
   wire                           i_p3_xmultic_nwb_a; 
   wire                           i_p3_xwb_op_a;
   wire                           i_p3_sync_stalls_pipe_a; 
   wire                           i_p3_sync_instr_iv_a; 
   wire                           i_ignore_debug_op_a;
   wire                           i_p3_sync_stalls_pipe;
   reg                            i_store_in_progress_r;
   reg                            i_ignore_debug_op_r;
   reg             i_p3_sync_inst_r;
   reg                            i_p3_sync_stalls_pipe_r;
   reg                            i_sync_local_ld_r; 
   reg                            i_lpending_prev_r;  
   reg                            i_p3_ccunit_fz_a; 
   reg                            i_p3_ccunit_fn_a; 
   reg                            i_p3_ccunit_fc_a; 
   reg                            i_p3_ccunit_fv_a; 
   reg                            i_p3_ccunit_nfz_a; 
   reg                            i_p3_ccunit_nfn_a; 
   reg                            i_p3_ccunit_nfc_a; 
   reg                            i_p3_ccunit_nfv_a;
   reg                            i_p3_br_ccunit_fz_a; 
   reg                            i_p3_br_ccunit_fn_a; 
   reg                            i_p3_br_ccunit_fc_a; 
   reg                            i_p3_br_ccunit_fv_a; 
   reg                            i_p3_br_ccunit_nfz_a; 
   reg                            i_p3_br_ccunit_nfn_a; 
   reg                            i_p3_br_ccunit_nfc_a; 
   reg                            i_p3_br_ccunit_nfv_a; 
  
//------------------------------------------------------------------------------
// Stage 4
//------------------------------------------------------------------------------
   wire                           i_p4_br_or_bbit_iv_a; 
   reg                            i_p4_br_or_bbit_r; 
   reg                            i_p4_ccmatch_br_a; 
   wire                           i_p4_ccmatch_br_nxt; 
   reg                            i_p4_ccmatch_br_r; 
   wire                           i_p4_disable_nxt; 
   reg                            i_p4_disable_r; 
   wire                           i_p4_docmprel_a; 
   reg                            i_p4_has_dslot_r; 
   wire                           i_p4_iv_nxt; 
   reg                            i_p4_iv_r; 
   wire                           i_p4_kill_p1_a; 
   wire                           i_p4_kill_p2_a; 
   wire                           i_p4_kill_p2b_a; 
   wire                           i_p4_kill_p3_a; 
   wire                           i_p4_no_kill_p3_a; 
   wire                           i_p4_ldvalid_wback_a; 
   reg [OPERAND_MSB:0]            i_p4_wba_r; 
   wire                           i_p4_wben_nld_nxt; 
   wire                           i_p4_wben_nxt; 
   reg                            i_p4_wben_r;   


   
//------------------------------------------------------------------------------
// Perform an instruction fetch
//------------------------------------------------------------------------------
//
//  This signal is used to tell the memory controller to do another
//  instruction fetch with the program counter value which will appear
//  at the end of the cycle. It is normally the same as pcen except for
//  when the processor is restarted after a reset, when an initial
//  instruction fetch request must be issued to start the ball rolling.
// 
//  In addition, ifetch_aligned will be set true when the host is allowed
//  to change the program counter when the ARC is halted. This will means
//  that the new program counter value will be passed out to the memory
//  controller correctly. The ifetch_aligned signal is not set true when
//  there is an instruction fetch still pending.
// 
//  Signal i_awake will be true for one cycle after the processor is
//  started after a reset.
// 
   assign i_awake_a = en & (~i_go_r);
   
   //  Signal i_hostload will be true when an new instruction fetch needs
   //  to be issued due to the host changing the program counter.
   // 
   //  This does not include ivalid_aligned - this is included later on
   //  i_ifetch_aligned.
   // 
   assign i_hostload_non_iv_a = (h_pcwr | h_pcwr32) & i_go_nxt;
   
   //  The ifetch_aligned signal comes from either pcen, kick-start after
   //  reset, or when a fetch is required as the host has changed the
   //  program counter.
   // 
   assign i_ifetch_aligned_a = (i_pcen_non_iv_a | i_hostload_non_iv_a) &
                                 ivalid_aligned | i_awake_a;
   
   //  The latch is set true after the processor is started after a
   //  reset, and will stay true until the next reset.
   // 
   //  The signal i_go_r is taken low when the instruction cache is 
   //  invalidated (ivic). This is in order to prevent a lockup
   //  situation.
   // 
   assign i_go_nxt = en | i_go_r;
   
   assign i_go_a = i_go_nxt & (~ivic);
   
   always @(posedge clk or posedge rst_a)
     begin : go_core_sync_PROC
        if (rst_a == 1'b 1)
          begin
             i_go_r <= 1'b 0;   
          end
        else
          begin
             i_go_r <= i_go_a;   
          end
     end

//------------------------------------------------------------------------------
// instr_pending_r : An instruction is being fetched
//------------------------------------------------------------------------------
// 
//  This signal is set true when an instruction fetched has been issued,
//  (i.e. not directly after reset) and the fetch has not yet completed,
//  signalled by ivalid_aligned = '0'.
//  It is used to prevent writes to the pc from the host from
//  generating an ifetch_aligned request when there is already an
//  instruction fetch pending. Host accesses are rejected with hold_host,
//  generated by the hostif block.
// 
// 
   always @(posedge clk or posedge rst_a)
     begin : ipend_sync_PROC
        if (rst_a == 1'b 1)
          begin
             i_instr_pending_r <= 1'b 0;   
          end
        else
          begin
             
             //  Entry state : when ARC is started onwards
             if (i_ifetch_aligned_a == 1'b 1)
               begin
                  i_instr_pending_r <= 1'b 1;   
               end
             else
               begin
               //  Exit state : i.e. when no more fetches are required 
               //  
               //  Or: An instruction cache invalidate puts us back into
               //      the immediately post-reset condition.
               // 
               if ((i_ifetch_aligned_a == 1'b 0) & (ivalid_aligned == 1'b 1) | 
                   (ivic == 1'b 1))
                 begin
                    i_instr_pending_r <= 1'b 0;   
                 end
               end
          end
     end 

//------------------------------------------------------------------------------
// Stage 1 stall signals 
//------------------------------------------------------------------------------
//
// Instruction step stall
//
// Stage 1 is only enabled whilst instruction stepping to allow a single
// instruction packet into the pipeline.
// The signal "i_p2_step_a" is true the cycle after an instruction step starts
// by which time the first potential instruction of a packet is in stage 2
// (decode) at this point the machine will have decoding all the information
// need to either block or allow the next instruction longword into the
// pipeline.  The next longword is allowed into the pipeline under following
// conditions:
// (1) The instruction has long immediate data.
// (2) The instruction has a delay slot.
// 
   assign i_p1_step_stall_a = ((i_p2_step_a == 1'b 1) &
                              
                               // If the instruction in stage 2 has a
                               // LIMM then don't stall stage 1.
                               (i_p2_long_immediate_a == 1'b 0) &
                               // or if the processor is waiting for
                               // the LIMM to arrive.
                               (i_p2_tag_nxt_p1_limm_r == 1'b 0) &
                               // the processor is not waiting for the
                               // delay slot or LIMM to arrive.
                               (i_p2_tag_nxt_p1_dslot_r == 1'b 0) & 
                               
                               (p2int == 1'b 0) &
                               
                               (i_p2_has_dslot_a == 1'b 0) & 
                               
                               (i_p2_kill_p1_a == 1'b 0)) ? 1'b 1 : 
                              1'b 0; 

   // Zero delay loop stalls
   //
   // Stage 1 is stalled if there is a hit to the loopend whilst there is an
   // instruction in stage 3 that is writing to either LP_COUNT, LP_END or
   // LP_START
   //
   assign i_p1_zero_loop_stall_a = (loopend_hit_a &
                                  (i_p3_loopcount_hit_a
                                   |
                                   ((auxdc(aux_addr,AX_LSTART_N) |
                                     auxdc(aux_addr,AX_LEND_N)) &
                                    i_p3_sr_a)));

   
   // Control transfer and interrupt/LP_END hit stalls
   //
   // When a control transfer instruction is in the pipeline any interrupts must
   // be held in stage 1 to prevent the ilink register from being written with
   // an incorrect PC.  The PC would be incorrect if the interrupt read the PC
   // before the control transfer has been resolved.  In addition to this any
   // hit to the end of Zero delay loop need to be stalled because the control
   // transfer may modify the PC.
   //
   assign i_p1_ct_int_loop_stall_a = ((p1int | loopend_hit_a)     &
                                      
                                      // Dont stall any delay slot instruction
                                      // It is not allowed for a interrupt to
                                      // split a delay slot from it's parent
                                      // instruction. A delay slot instruction
                                      // may not occupy the last instruction
                                      // slot in a loop. This, therefore means
                                      // that this should never get to be
                                      // stalled under the conditions that are
                                      // being be prevented.
                                      //
                                      (~i_p2_tag_nxt_p1_dslot_r) &
                                      
                                      // Don't stall bcc if it has a delay slot.
                                      //
                                      ((i_p2_branch_iv_a &
                                        (~i_p2_has_dslot_a))                 |
                                       
                                       // Dont stall the jcc if it has a lim or
                                       // delay slot.
                                       //
                                       (i_p2_p2b_jmp_iv_a &
                                        (~(i_p2_limm_a | i_p2_has_dslot_a))) |
                                       
                                       i_p2b_jmp_iv_a                      |

                                       // Don't stall bcc if it has a delay
                                       // slot.
                                       //
                                       (i_p2_br_or_bbit_iv_a &
                                        (~(i_p2_limm_a | i_p2_has_dslot_a))) |
                                       
                                       i_p2b_br_or_bbit_iv_a               | 
                                       i_p3_br_or_bbit_iv_a                | 
                                       i_p4_br_or_bbit_iv_a));

//------------------------------------------------------------------------------
//  Pipeline 1 -> 2 transition enable
//------------------------------------------------------------------------------
//
   // Stage 1 pipeline enable
   //
   // Stage 1 is only enabled if both the pipeline can accept another
   // instruction and the cache/aligner has a valid instruction available.
   //
   assign i_p1_enable_a = ((i_p1_enable_niv_a == 1'b 0) | 
                           (ivalid_aligned == 1'b 0)) ? 1'b 0 : 
          1'b 1;
   
   // Stage 1 partial pipeline enable.
   //
   // This signal is used in the main pipeline enable signal is will prevent
   // any instruction in stage 1 from moving onto stage 2.  The conditions
   // under which the instruction will not move are:
   //
   // (1) if the processor is halted.
   // (2) When instruction stepping and the instruction packet in stage 1 is not
   //     allowed to move on. See above for conditions
   // (3) When there is an interrupt in stage 1 or a lp_end hit and a control
   //     transfer instruction is in the pipeline.
   // (4) when a write to any of the LP_END,LP_START or LP_COUNT registers and
   //     there is a lp_end hit
   // (5) If the pipeline ahead is stalled, except when stage 2b is waiting for
   //     a LIMM or delay-slot. The machine can only squash these type of
   //     bubbles due to static timing reasons limiting the complexity on the
   //     enable signals.
   //
   assign i_p1_enable_niv_a = ((en                          == 1'b 0) | 
                               (i_p1_step_stall_a           == 1'b 1) | 
                               (i_p2_brk_sleep_swi_a        == 1'b 1) | 
                               (i_p1_ct_int_loop_stall_a    == 1'b 1) |
                               (i_p1_zero_loop_stall_a      == 1'b 1) |
                               ((i_p2_en_no_pwr_save_a      == 1'b 0) & 
                               (i_p2b_limm_dslot_stall_r   == 1'b 0))) ?
          1'b 0 : 
          1'b 1;

//------------------------------------------------------------------------------
// Stage 1 to stage 2 pipeline register
//------------------------------------------------------------------------------
//
   // The stage 1 instruction word is moved into stage 2 only when the stage 1
   // enable allows it.
   //  
   always @(posedge clk or posedge rst_a)
     begin : Stage_2_sync_PROC
        if (rst_a == 1'b 1)
          begin
             i_p2_iw_r <= {(INSTR_UBND + 1){1'b 0}}; 
          end
        else
          begin
             if (i_p1_enable_a == 1'b 1)
               begin
                  i_p2_iw_r <= p1iw_aligned_a;  
               end
          end
     end

   // Loopend detection for actionpoints in stage 1.
   //
   always @(posedge clk or posedge rst_a)
     begin : Stage_2_lpend_sync_PROC
        if (rst_a == 1'b 1)
          begin
             i_p2_loopend_hit_r <= 1'b0;               
          end
        else
          begin
             if (i_p1_enable_a == 1'b 1)
               begin
                  i_p2_loopend_hit_r <= loopend_hit_a;
               end
          end
     end

   //------------------------------------------------------------------------------
// Stage 2 instruction field extraction
//------------------------------------------------------------------------------
// 
//  The various component parts of the instruction set are extracted here
//  to internal signals.
// 
//  Stage 1 address field decode for the sync_regs module.
//    
   //  Opcode [31:27]
   // 
   assign i_p2_opcode_a = i_p2_iw_r[INSTR_UBND:INSTR_LBND]; 

   //  Minor opcode
   // 
   assign i_p2_minoropcode_r = i_p2_iw_r[AOP_UBND:AOP_LBND]; 

   //  Sub opcode
   // 
   assign i_p2_subopcode_r = i_p2_iw_r[MINOR_OP_UBND:MINOR_OP_LBND]; 

   //  Sub opcode1
   // 
   assign i_p2_subopcode1_r = i_p2_iw_r[MINOR16_OP1_UBND:MINOR16_OP1_LBND]; 

   //  Sub opcode2
   // 
   assign i_p2_subopcode2_r = i_p2_iw_r[MINOR16_OP2_UBND:MINOR16_OP2_LBND]; 

   //  Sub opcode3
   // 
   assign i_p2_subopcode3_r = i_p2_iw_r[MINOR16_OP3_UBND:MINOR16_OP3_LBND]; 

   //  Sub opcode4
   // 
   assign i_p2_subopcode4_r = i_p2_iw_r[SUBOPCODE_BIT]; 

   //  Sub opcode5
   // 
   assign i_p2_subopcode5_r = i_p2_iw_r[MINOR16_BR1_UBND:MINOR16_BR1_LBND]; 

   //  Sub opcode6
   // 
   assign i_p2_subopcode6_r = i_p2_iw_r[MINOR16_BR2_UBND:MINOR16_BR2_LBND]; 

   //  Sub opcode7
   // 
   assign i_p2_subopcode7_r = i_p2_iw_r[MINOR16_OP4_UBND:MINOR16_OP4_LBND]; 

   //  A field
   //
   assign i_p2_a_field_r = i_p2_iw_r[AOP_UBND:AOP_LBND]; 

   //  A field for 16-bit
   //
   assign i_p2_a_field16_r = {TWO_ZERO, i_p2_iw_r[AOP_UBND16], 
                              i_p2_iw_r[AOP_UBND16:AOP_LBND16]}; 

   //  C field for 16-bit
   //
   assign i_p2_c_field16_r = i_p2_iw_r[COP_UBND16:COP_LBND16]; 

   //  C field for 16-bit (extended to fit writeback address register
   //  field).
   // 
   assign i_p2_c_field16_2_r = {TWO_ZERO, i_p2_iw_r[COP_UBND16], 
                                i_p2_iw_r[COP_UBND16:COP_LBND16]}; 

   //  B field
   //
   assign i_p2_b_field_r = {i_p2_iw_r[BOP_MSB_UBND:BOP_MSB_LBND], 
                            i_p2_iw_r[BOP_LSB_UBND:BOP_LSB_LBND]}; 

   //  B field for 16-bit
   //
   assign i_p2_b_field16_r = i_p2_iw_r[BOP_LSB_UBND:BOP_LSB_LBND]; 

   //  High register field for 16-bit
   //
   assign i_p2_hi_reg16_r = {i_p2_iw_r[AOP_UBND16:AOP_LBND16], 
                             i_p2_iw_r[COP_UBND16:COP_LBND16]}; 

   //  C field for 32-bit
   //
   assign i_p2_c_field_r = i_p2_iw_r[COP_UBND:COP_LBND]; 

   //  Format for operands
   //
   assign i_p2_format_r = i_p2_iw_r[MINOR_OP_UBND + 2:MINOR_OP_UBND + 1]; 

//------------------------------------------------------------------------------
// Stage 2 instruction decode
//------------------------------------------------------------------------------

   // Register & signed 12-bit immediate
   //
   assign i_p2_fmt_s12_a = (i_p2_format_r == FMT_S12) ? 1'b 1 : 
          1'b 0; 

   // Register & unsigned 6-bit immediate
   //
   assign i_p2_fmt_u6_a = (i_p2_format_r == FMT_U6) ? 1'b 1 : 
          1'b 0; 

   // Conditional register
   //
   assign i_p2_fmt_cond_reg_dec_a = (i_p2_format_r == FMT_COND_REG) ? 1'b 1 : 
          1'b 0; 

   // Condtional register & register
   //
   assign i_p2_fmt_cond_reg_a = (i_p2_fmt_cond_reg_dec_a & 
                                 (~i_p2_iw_r[AOP_UBND])); 

   // Conditional register & unsigned 6-bit immediate
   //
   assign i_p2_fmt_cond_reg_u6_a = (i_p2_fmt_cond_reg_dec_a & 
                                    i_p2_iw_r[AOP_UBND]); 

   // Register & register
   //   
   assign i_p2_fmt_reg_a = (i_p2_format_r == FMT_REG) ? 1'b 1 : 
          1'b 0;

//------------------------------------------------------------------------------
// Opcode decodes
//------------------------------------------------------------------------------
// 
   //  Decode for 16-bit Single Operand instruction.
   // 
   assign i_p2_16_sop_inst_a = (i_p2_opcode_16_alu_a & 
                                i_p2_subop_16_sop_a); 

   //  Decode for 32-bit Single Operand instruction.
   // 
   assign i_p2_32_sop_inst_a = (i_p2_opcode_32_fmt1_a & 
                                i_p2_subopcode_sop_a); 

   //  Decode for 32-bit Basecase Instruction Opcode slot.
   // 
   assign i_p2_opcode_32_fmt1_a = (i_p2_opcode_a == OP_FMT1) ? 1'b 1 : 
          1'b 0; 

   //  Decode for 16-bit Basecase ALU Instruction Opcode slot.
   // 
   assign i_p2_opcode_16_alu_a = (i_p2_opcode_a == OP_16_ALU_GEN) ? 1'b 1 : 
          1'b 0;  

   //  Decode for 16-bit ADD/CMP instruction with unsigned 7-bit short
   //  immediate.
   // 
   assign i_p2_opcode_16_addcmp_a = (i_p2_opcode_a == OP_16_ADDCMP) ? 1'b 1 : 
        1'b 0;  

   //  Select appropriate address for 16-bit Global pointer instructions.
   //  
   assign i_p2_opcode_16_gp_rel_a = (i_p2_opcode_a == OP_16_GP_REL) ? 1'b 1 : 
          1'b 0;  

   //  Select appropriate address for 16-bit Stack pointer instructions.
   // 
   assign i_p2_opcode_16_sp_rel_a = (i_p2_opcode_a == OP_16_SP_REL) ? 1'b 1 : 
          1'b 0;  

   //  Decode for 16-bit ADD/SUB and shift register instructions.
   // 
   assign i_p2_opcode_16_arith_a = (i_p2_opcode_a == OP_16_ARITH) ? 1'b 1 : 
          1'b 0;  

   //  Decode for 16-bit MOV instruction.
   // 
   assign i_p2_opcode_16_mov_a = (i_p2_opcode_a == OP_16_MV) ? 1'b 1 : 
          1'b 0;  

   //  Select PC register for LD PC relative instructions.
   // 
   assign i_p2_opcode_16_ld_pc_a = (i_p2_opcode_a == OP_16_LD_PC) ? 1'b 1 : 
          1'b 0; 
   
   //Main decode for 16-bit conditional branch (b,beq & bne)
   //
   assign i_p2_opcode_16_bcc_a = (i_p2_opcode_a == OP_16_BCC) ? 1'b 1 : 
          1'b 0;  

   // Sub-decode for 16-bit conditional branch (bgt, bge, blt, ble, bhi, bhs,
   // blo & bls)
   //
   assign i_p2_opcode_16_bcc_cc_a = ((i_p2_opcode_16_bcc_a == 1'b 1) &
                                     (i_p2_subopcode5_r != 2'b 11)) ? 1'b 1 : 
          1'b 0;  

   // Sub-decode for 16-bit conditional branch  (b,beq & bne)
   //
   assign i_p2_opc_16_bcc_cc_s7_a = ((i_p2_opcode_16_bcc_a == 1'b 1) & 
                                        (i_p2_subopcode5_r == 2'b 11)) ? 1'b 1 : 
          1'b 0;  

   // Decode for 16-bit compare&branch
   //
   assign i_p2_opcode_16_brcc_a = (i_p2_opcode_a == OP_16_BRCC) ? 1'b 1 : 
          1'b 0;  

   // Decode for 16-bit unconditional branch&link
   //
   assign i_p2_opcode_16_bl_a = (i_p2_opcode_a == OP_16_BL) ? 1'b 1 : 
          1'b 0;  

   // Decode for 32-bit conditional branch
   //
   assign i_p2_opcode_32_bcc_a = (i_p2_opcode_a == OP_BCC) ? 1'b 1 : 
          1'b 0;  

   // Decode for 32-bit conditional branch&link
   //
   assign i_p2_opcode_32_blcc_a = (i_p2_opcode_a == OP_BLCC) ? 1'b 1 : 
          1'b 0;  

   // Decode for 16-bit mov, cmp, add with high registers
   //
   assign i_p2_opcode_16_mv_add_a = (i_p2_opcode_a == OP_16_MV_ADD) ? 1'b 1 : 
          1'b 0;  

   // Decode for 16-bit add, sub, shift with reg & u3 imm
   //
   assign i_p2_opcode_16_ssub_a = (i_p2_opcode_a == OP_16_SSUB) ?  1'b 1 : 
          1'b 0;  

   // Decode for 16-bit ld & add with reg - reg
   //
   assign i_p2_opcode_16_ld_add_a = (i_p2_opcode_a == OP_16_LD_ADD) ? 1'b 1 : 
          1'b 0;  

   // Decode for 32-bit ST with reg, reg, s9
   //  
   assign i_p2_opcode_32_st_a = (i_p2_opcode_a == OP_ST) ? 1'b 1 : 
          1'b 0; 
   
   // Decode for 32-bit LD with reg, reg, s9
   //
   assign i_p2_opcode_32_ld_a = (i_p2_opcode_a == OP_LD) ? 1'b 1 : 
          1'b 0;  

//------------------------------------------------------------------------------
// Subopcode decodes
//------------------------------------------------------------------------------

   // Sub-decode for 16-bit single operand instructions
   //
   assign i_p2_subop_16_sop_a = (i_p2_subopcode2_r == SO16_SOP) ? 1'b 1 : 
          1'b 0; 

   // Sub-decode for 32-bit single operand move 
   //
   assign i_p2_subopcode_mov_a = (i_p2_subopcode_r == SO_MOV) ? 1'b 1 : 
          1'b 0; 

   // Sub-decode for 32-bit single operand flag
   //
   assign i_p2_subopcode_flag_a = (i_p2_subopcode_r == SO_FLAG) ? 1'b 1 : 
          1'b 0; 

   // Sub-decode for 32-bit single operand instruction 
   //
   assign i_p2_subopcode_sop_a = (i_p2_subopcode_r) == SO_SOP ? 1'b 1 : 
          1'b 0; 

   // Sub-decode for 32-bit jump with delay slot 
   //
   assign i_p2_subopcode_lr_a = (i_p2_subopcode_r == SO_LR) ? 1'b 1 : 
          1'b 0; 

   // Sub-decode for 32-bit jump with delay slot 
   //
   assign i_p2_subopcode_jd_a = (i_p2_subopcode_r == SO_J_D) ? 1'b 1 : 
          1'b 0; 

   // Sub-decode for 32-bit jump&link with delay slot 
   //
   assign i_p2_subopcode_jld_a = (i_p2_subopcode_r == SO_JL_D) ? 1'b 1 : 
          1'b 0; 

   // Sub-decode for 32-bit jump 
   //
   assign i_p2_subopcode_j_a = (i_p2_subopcode_r == SO_J) ? 1'b 1 : 
          1'b 0; 

   // Sub-decode for 32-bit jump&link
   //
   assign i_p2_subopcode_jl_a = (i_p2_subopcode_r == SO_JL) ? 1'b 1 : 
          1'b 0; 

   // Sub-decode for 32-bit memory longword load 
   //
   assign i_p2_subopcode_ld_a = (i_p2_subopcode_r == SO_LD) ? 1'b 1 : 
          1'b 0; 

   // Sub-decode for 32-bit memory byte load
   //
   assign i_p2_subopcode_ldb_a = (i_p2_subopcode_r == SO_LDB) ? 1'b 1 : 
          1'b 0; 

   // Sub-decode for 32-bit memory byte load with sign extension 
   //
   assign i_p2_subopcode_ldb_x_a = (i_p2_subopcode_r == SO_LDB_X) ? 1'b 1 : 
          1'b 0; 

   // Sub-decode for 32-bit memory word load  
   //
   assign i_p2_subopcode_ldw_a = (i_p2_subopcode_r == SO_LDW) ? 1'b 1 : 
          1'b 0; 

   // Sub-decode for 32-bit memory word load with sign extension 
   //
   assign i_p2_subopcode_ldw_x_a = (i_p2_subopcode_r == SO_LDW_X) ? 1'b 1 : 
          1'b 0; 

   // Sub-decode for 16-bit global pointer relative byte load
   //
   assign i_p2_subop_16_ldb_gp_a = (i_p2_subopcode7_r == SO16_LDB_GP) ? 1'b 1 : 
          1'b 0; 

   // Sub-decode for 16-bit global pointer relative word load
   //  
   assign i_p2_subop_16_ldw_gp_a = (i_p2_subopcode7_r == SO16_LDW_GP) ? 1'b 1 : 
          1'b 0; 

   // Sub-decode for 16-bit move with hi register
   //
   assign i_p2_subop_16_mov_hi2_a = (i_p2_subopcode1_r == SO16_MOV_HI2) ? 1'b 1 :
          1'b 0; 

   // Sub-decode for 16-bit bit-test with 5-bit unsigned immediate 
   //
   assign i_p2_subop_16_btst_u5_a = (i_p2_subopcode3_r == SO16_BTST_U5) ? 1'b 1 :
          1'b 0; 

   // Sub-decode for 16-bit push with unsigned 7-bit immediate 
   //
   assign i_p2_subop_16_push_u7_a = (i_p2_subopcode3_r == SO16_PUSH_U7) ? 1'b 1 :
          1'b 0; 

   // Sub-decode for 16-bit pop with unsigned 7-bit immediate 
   //
   assign i_p2_subop_16_pop_u7_a = (i_p2_subopcode3_r == SO16_POP_U7) ? 1'b 1 :
          1'b 0; 

   // Sub-decode for 32-bit reverse subtract
   //
   assign i_p2_subopcode_rsub_a = (i_p2_subopcode_r == SO_RSUB) ? 1'b 1 : 
          1'b 0; 

   // Sub-decode for 32-bit reverse compare 
   //
   assign i_p2_subopcode_rcmp_a = (i_p2_subopcode_r == SO_RCMP) ? 1'b 1 : 
          1'b 0; 

   // Sub-decode for 16-bit move with hi register
   //
   assign i_p2_subop_16_mov_hi1_a = (i_p2_subopcode1_r == SO16_MOV_HI1) ? 1'b 1 :
          1'b 0; 

   // Sub-decode for 16-bit break 
   //
   assign i_p2_subop_16_brk_a = (i_p2_subopcode2_r == SO16_BRK) ? 1'b 1 : 
          1'b 0; 

   // Sub-decode for 16-bit negate 
   //
   assign i_p2_subop_16_neg_a = (i_p2_subopcode2_r == SO16_NEG) ? 1'b 1 : 
          1'b 0; 

   // Sub-decode for 16-bit absolute 
   //
   assign i_p2_subop_16_abs_a = (i_p2_subopcode2_r == SO16_ABS) ? 1'b 1 : 
          1'b 0; 

   // Sub-decode for 16-bit logical not 
   //
   assign i_p2_subop_16_not_a = (i_p2_subopcode2_r == SO16_NOT) ? 1'b 1 : 
          1'b 0; 

//------------------------------------------------------------------------------
//  C field decodes 
//------------------------------------------------------------------------------
//
   // The c field is used when the operation is a single operand instruction
   //
   // Sub-decode for 16-bit zero operand instruction 
   //
   assign i_p2_c_field16_zop_a = (i_p2_c_field16_r == SO16_SOP_ZOP) ? 1'b 1 : 
          1'b 0; 

   // Sub-decode for 16-bit single operand subtract
   //
   assign i_p2_c_field16_sop_sub_a = (i_p2_c_field16_r == SO16_SOP_SUB) ? 1'b 1 :
          1'b 0; 

   // Sub-decode for 16-bit single operand jump with delay slot 
   //
   assign i_p2_c_field16_sop_jd_a = (i_p2_c_field16_r == SO16_SOP_JD) ? 1'b 1 :
          1'b 0; 

   // Sub-decode for 16-bit single operand jump with delay slot 
   //
   assign i_p2_c_field16_sop_jld_a = (i_p2_c_field16_r == SO16_SOP_JLD) ? 1'b 1 :
          1'b 0; 

   // Sub-decode for 16-bit single operand jump 
   //
   assign i_p2_c_field16_sop_j_a = (i_p2_c_field16_r == SO16_SOP_J) ? 1'b 1 : 
          1'b 0; 

   // Sub-decode for 16-bit single operand jump&link 
   //
   assign i_p2_c_field16_sop_jl_a = (i_p2_c_field16_r == SO16_SOP_JL) ? 1'b 1 :
          1'b 0; 

//------------------------------------------------------------------------------
// B field decodes 
//------------------------------------------------------------------------------
//
// The B field is uses for decoding the zero operand instructions
//

   // Sub-decode for 16-bit zero operand jump on equal
   //
   assign i_p2_b_field16_zop_jeq_a = (i_p2_b_field16_r == SO16_ZOP_JEQ) ? 1'b 1 :
          1'b 0; 

   // Sub-decode for 16-bit zero operand jump on not equal 
   //
   assign i_p2_b_field16_zop_jne_a = (i_p2_b_field16_r == SO16_ZOP_JNE) ? 1'b 1 :
          1'b 0; 

   // Sub-decode for 16-bit zero operand jump with delay slot 
   //
   assign i_p2_b_field16_zop_jd_a = (i_p2_b_field16_r == SO16_ZOP_JD) ? 1'b 1 : 
          1'b 0; 

   // Sub-decode for 16-bit zero operand jump 
   //
   assign i_p2_b_field16_zop_j_a = (i_p2_b_field16_r == SO16_ZOP_J) ? 1'b 1 : 
          1'b 0; 

   // Sub-decode for 16-bit zero operand software interrupt 
   //
   assign i_p2_b_field_zop_swi_a = (i_p2_b_field_r == ZO_SWI) ? 1'b 1 : 
          1'b 0; 

   // Sub-decode for 16-bit zero operand sleep 
   //
   assign i_p2_b_field_zop_sleep_a = (i_p2_b_field_r == ZO_SLEEP) ? 1'b 1 : 
          1'b 0; 
          
   // Sub-decode for zero operand sync
   //
   assign i_p2_b_field_zop_sync_a = (i_p2_b_field_r == ZO_SYNC) ? 1'b 1 : 
          1'b 0;

//------------------------------------------------------------------------------
// Minor-opcode decodes
//------------------------------------------------------------------------------


   // Minor-opcode decode for zero operand instructions
   //
   assign i_p2_zop_decode_a = ((i_p2_minoropcode_r == MO_ZOP) & 
                               (i_p2_32_sop_inst_a == 1'b 1)) ? 1'b 1 :
          1'b 0; 
  
   // Minor-opcode decode for absoulute
   //
   assign i_p2_minor_op_abs_a = (i_p2_minoropcode_r == MO_ABS) ? 1'b 1 : 
          1'b 0; 

//------------------------------------------------------------------------------
//  Extended decodes
//------------------------------------------------------------------------------

   // Decode for 16-bit push operations
   //
   assign i_p2_push_decode_a = (i_p2_opcode_16_sp_rel_a & 
                                i_p2_subop_16_push_u7_a);
   
   // Decode for 16-bit pop operations
   //
   assign i_p2_pop_decode_a = (i_p2_opcode_16_sp_rel_a & 
                               i_p2_subop_16_pop_u7_a);
   
   // Decode for all 16-bit shift operations
   //
   assign i_p2_opcode_16_ushimm_shft_a = (((i_p2_opcode_16_ssub_a == 1'b 1) &
                                           ((i_p2_subopcode3_r == SO16_ASL_U5)  | 
                                            (i_p2_subopcode3_r == SO16_LSR_U5)  | 
                                            (i_p2_subopcode3_r == SO16_ASR_U5)))
                                            | 
                                            ((i_p2_opcode_16_arith_a == 1'b 1) & 
                                             ((i_p2_subopcode1_r == SO16_ASL) | 
                                              (i_p2_subopcode1_r == SO16_ASR)))) ?
          1'b 1 :
          1'b 0;
   
   // 16-bit LD register + offset instructions.
   // 
   assign i_p2_ldo16_a = ((i_p2_opcode_a == OP_16_LD_U7) | 
                    (i_p2_opcode_a == OP_16_LDB_U5) | 
                    (i_p2_opcode_a == OP_16_LDW_U6) | 
                    (i_p2_opcode_a == OP_16_LDWX_U6)) ? 1'b 1 :
          1'b 0; 

   // 16-bit ST register + offset instructions.
   // 
   assign i_p2_sto16_a = ((i_p2_opcode_a == OP_16_ST_U7) | 
                    (i_p2_opcode_a == OP_16_STB_U5) | 
                    (i_p2_opcode_a == OP_16_STW_U6)) ? 1'b 1 :
          1'b 0; 

   // Decode forPush [blink] 
   //
   assign i_p2_push_blink_a = ((i_p2_opcode_16_sp_rel_a     == 1'b 1) & 
                        (i_p2_subop_16_push_u7_a == 1'b 1) & 
                        (i_p2_iw_r[SP_MODE_1]        == 1'b 1) & 
                        (i_p2_iw_r[SP_MODE_2]        == 1'b 1)) ? 1'b 1 :
          1'b 0; 

   // Select appropriate field for 16-bit MOV with full addressing to
   // register file.
   // 
   assign i_p2_mov_hi_a = (i_p2_opcode_16_mv_add_a & 
                           i_p2_subop_16_mov_hi1_a);

   // Decode for 32-bit conditional branch
   //   
   assign i_p2_bcc32_a = (i_p2_opcode_32_bcc_a & 
                          (~i_p2_subopcode_r[SUBOPCODE_LSB])); 

   // Decode for 32-bit branch
   //
   assign i_p2_b32_a = (i_p2_opcode_32_bcc_a & 
                        i_p2_subopcode_r[SUBOPCODE_LSB]); 

   // Decode for 32-bit conditonal branch&link
   //
   assign i_p2_blcc32_a = (i_p2_opcode_32_blcc_a & 
                           (~i_p2_iw_r[SET_BLCC]) & 
                           (~i_p2_iw_r[BR_FMT])); 

   // Decode for 32-bit branch&link
   //
   assign i_p2_bl32_a = (i_p2_opcode_32_blcc_a & 
                         i_p2_iw_r[SET_BLCC] & 
                         (~i_p2_iw_r[BR_FMT])); 

   // Decode for 32-bit branch&link and conditional branch&link
   //
   assign i_p2_bl_blcc_32_a = (i_p2_opcode_32_blcc_a & 
                               (~i_p2_iw_r[BR_FMT])); 

   // Decode for 32-bit compare&branch with unsigned 6-bit immediate 
   //
   assign i_p2_br32_u6_a = (i_p2_opcode_32_blcc_a & 
                            i_p2_iw_r[BR_FMT] & 
                            i_p2_iw_r[QQ_UBND]); 

   // Decode for 32-bit all major opcode 4 except the loads
   //
   assign i_p2_no_ld_a = ((i_p2_opcode_32_fmt1_a  == 1'b 1) & 
                          (i_p2_subopcode_ld_a    == 1'b 0) & 
                          (i_p2_subopcode_ldb_a   == 1'b 0) & 
                          (i_p2_subopcode_ldb_x_a == 1'b 0) & 
                          (i_p2_subopcode_ldw_a   == 1'b 0) & 
                          (i_p2_subopcode_ldw_x_a == 1'b 0)) ?
          1'b 1 :
          1'b 0;

   // Decode for 32-bit all major opcode 4 except the loads and reverse
   // operations.
   //
   assign i_p2_no_ld_and_rev_a = ((i_p2_opcode_32_fmt1_a == 1'b 1) & 
                                  (i_p2_subopcode_rsub_a == 1'b 0) & 
                                  (i_p2_subopcode_rcmp_a == 1'b 0) & 
                                  (i_p2_no_ld_a          == 1'b 1)) ?
          1'b 1 :
          1'b 0; 

   // Auxiliary Load.
   // 
   assign i_p2_lr_decode_iv_a = (i_p2_opcode_32_fmt1_a & 
                                 i_p2_subopcode_lr_a & 
                                 i_p2_iv_r); 

   // Decode for all absolute or negate operations
   //
   assign i_p2_abs_neg_decode_a = (((i_p2_opcode_32_fmt1_a & 
                                     i_p2_32_sop_inst_a & 
                                     i_p2_minor_op_abs_a) 
                                    | 
                                    (i_p2_opcode_16_alu_a & 
                                     i_p2_16_sop_inst_a & 
                                     (i_p2_subop_16_abs_a | 
                                      i_p2_subop_16_neg_a))) & 
                                   i_p2_iv_r); 

   // Decode for logical not operations
   //
   assign i_p2_not_decode_a = (i_p2_opcode_16_alu_a    & 
                               i_p2_16_sop_inst_a      & 
                               i_p2_subop_16_not_a & 
                               i_p2_iv_r); 

   // 16-bit version of BRK. This signal is only asserted if the instruction is
   // not about to be killed by a control transfer. 
   //
   assign i_p2_brk_inst_a = (i_p2_opcode_16_alu_a    & 
                             i_p2_subop_16_brk_a     & 
                             i_p2_iv_r               & 
                             (~i_kill_p2_a)); 


   // The Software Interrupt (SWI) instruction is determined at stage 2
   // from:
   //
   //    [1] Decode of p2iw
   //    [2] Instruction at stage 2 is valid
   //    [3] An actionpoint wants to insert a SWI
   //
   assign i_p2_swi_inst_a = (i_p2_swi_inst_niv_a & i_p2_iv_r) & 
                             ~actionpt_pc_brk_a;

   assign i_p2_swi_inst_niv_a = i_p2_zop_decode_a & i_p2_b_field_zop_swi_a; 


   // 
   //  The sleep instruction is determined at stage 2 from:
   // 
   //     [1] Decode of p2iw,
   //     [2] Instruction at stage 2 is valid.
   // 
   assign i_p2_sleep_inst_a = i_p2_sleep_inst_niv_a & i_p2_iv_r & (~i_kill_p2_a);
 
   assign i_p2_sleep_inst_niv_a = i_p2_zop_decode_a & i_p2_b_field_zop_sleep_a; 
   
   
   // SYNC instruction is determined here.
   // 
   assign i_p2_sync_inst_a = i_p2_sync_inst_niv_a & i_p2_iv_r;
   
   assign i_p2_sync_inst_niv_a = i_p2_zop_decode_a & i_p2_b_field_zop_sync_a;

//------------------------------------------------------------------------------
// Long immediate detection
//------------------------------------------------------------------------------
//
// Long immediate detection is done as early as possible as the aligner uses the
// p2limm signal to control the next_pc generation, which is critical path
//
   assign i_p2_a_field_long_imm_a = (i_p2_a_field_r == RLIMM) ? 1'b 1 : 
          1'b 0;
   
   assign i_p2_c_field_long_imm_a = (i_p2_c_field_r == RLIMM) ? 1'b 1 : 
          1'b 0;
   
   assign i_p2_b_field_long_imm_a = (i_p2_b_field_r == RLIMM) ? 1'b 1 : 
          1'b 0;
   
   assign i_p2_hi_reg16_long_imm_a = (i_p2_hi_reg16_r == RLIMM) ? 1'b 1 :
          1'b 0; 


//------------------------------------------------------------------------------
// Source 1 register address selection
//------------------------------------------------------------------------------
//
// The source 1 address field selects the following:
//
// [1] C-field for 32-bit instructions, MOV, RSUB and RCMP,
// [2] High register field when 16-bit instruction access all 64
//     core registers,
// [3] Global pointer for 16-bit GP relative LD/STs,
// [4] Stack pointer for 16-bit SP relative LDs,
// [5] PC value for 16-bit PC relative LDs,
// [6] Otherwise it selects the B-field.
// 

   assign i_p2_src1_addr_sel0_a = x_p1_rev_src | i_p2_rev_arith_a;
   
   assign i_p2_src1_addr_sel1_a = (~(i_p2_src1_addr_sel0_a   | 
                                    i_p2_mov_hi_a           | 
                                    i_p2_opcode_16_gp_rel_a | 
                                    i_p2_opcode_16_sp_rel_a | 
                                    i_p2_opcode_16_ld_pc_a));
   
   // Select the correct source 1 register address
   //
   assign i_p2_source1_addr_a = (i_p2_c_field_r & 
                                 ({(OPERAND_WIDTH){i_p2_src1_addr_sel0_a}})   | 

                                 i_p2_hi_reg16_r & 
                                 ({(OPERAND_WIDTH){i_p2_mov_hi_a}})           | 
                         
                                 RGLOBALPTR & 
                                 ({(OPERAND_WIDTH){i_p2_opcode_16_gp_rel_a}}) | 
                         
                                 RSTACKPTR & 
                                 ({(OPERAND_WIDTH){i_p2_opcode_16_sp_rel_a}}) | 
                         
                                 RCURRENTPC & 
                                 ({(OPERAND_WIDTH){i_p2_opcode_16_ld_pc_a}})  | 
                                 i_p2_b_field_r & 
                                 ({(OPERAND_WIDTH){i_p2_src1_addr_sel1_a}}));

   // Source 1 long immediate detect selection.
   // 
   assign i_p2_long_immediate1_a = ((i_p2_c_field_long_imm_a &
                                     i_p2_src1_addr_sel0_a) 
                                    | 
                                    (i_p2_hi_reg16_long_imm_a &
                                     i_p2_mov_hi_a)
                                    | 
                                    (i_p2_b_field_long_imm_a &
                                     i_p2_src1_addr_sel1_a)); 
  
//------------------------------------------------------------------------------
// Source 2 register address selection
//------------------------------------------------------------------------------
//
// The B-field is selected for 32-bit instructions, MOV, RSUB and RCMP, or SP
// relative instructions or 16-bit MOV with high register as a source.
// 
   assign i_p2_src2_b_field_a = ((i_p2_opcode_32_fmt1_a == 1'b 1) & 
                         ((i_p2_subopcode_rcmp_a == 1'b 1) | 
                          (i_p2_subopcode_rsub_a == 1'b 1)) 
                         | 
                         ((i_p2_opcode_16_mv_add_a == 1'b 1) & 
                          (i_p2_subop_16_mov_hi2_a == 1'b 1) 
                          |
                          (i_p2_opcode_16_sp_rel_a == 1'b 1) & 
                          (i_p2_push_blink_a == 1'b 0) 
                          | 
                          (i_p2_16_sop_inst_a & 
                           (i_p2_c_field16_sop_sub_a | 
                           i_p2_c_field16_sop_jd_a |
                           i_p2_c_field16_sop_j_a |
                           i_p2_c_field16_sop_jl_a |
                           i_p2_c_field16_sop_jld_a)) == 1'b 1)) ? 1'b 1 : 
          1'b 0;
   
   //  Select appropriate field for 16-bit MOV with full addressing to
   //  register file.
   //  
   assign i_p2_src2_hi_a =((i_p2_opcode_16_mv_add_a == 1'b 1) & 
                     ((i_p2_subop_16_mov_hi1_a == 1'b 1) | 
                     (i_p2_subopcode1_r == SO16_ADD_HI) | 
                     (i_p2_subopcode1_r == SO16_CMP))) ? 1'b 1 :
        1'b 0; 

   //  Select BLINK register when 16-bit jump/link instructions are
   //  performed.
   //  
   assign i_p2_src2_rblink_a = (((i_p2_16_sop_inst_a == 1'b 1) & 
                         ((i_p2_c_field16_zop_a == 1'b 1) &
                          ((i_p2_b_field16_zop_jeq_a == 1'b 1) | 
                           (i_p2_b_field16_zop_jne_a == 1'b 1) | 
                           (i_p2_b_field16_zop_j_a == 1'b 1) | 
                           (i_p2_b_field16_zop_jd_a == 1'b 1))) | 
                         (i_p2_push_blink_a == 1'b 1))) ? 1'b 1 : 
          1'b 0; 


   // Select b field if directly decoded or requested by extention instruction
   //
   assign i_p2_src2_addr_sel0_a = (x_p1_rev_src | i_p2_src2_b_field_a);

   // Select c field as default
   //  
   assign i_p2_src2_addr_sel1_a = (~(i_p2_src2_addr_sel0_a | 
                                    i_p2_src2_hi_a        | 
                                    i_p2_src2_rblink_a)); 

   // Select the correct source 2 register address field
   //
   assign i_p2_source2_addr_a =
                        (i_p2_b_field_r & ({(OPERAND_WIDTH){i_p2_src2_addr_sel0_a}}) 
                         | 
                         i_p2_hi_reg16_r & ({(OPERAND_WIDTH){i_p2_src2_hi_a}}) 
                         |
                         RBLINK & ({(OPERAND_WIDTH){i_p2_src2_rblink_a}}) 
                         |
                         i_p2_c_field_r & ({(OPERAND_WIDTH){i_p2_src2_addr_sel1_a}})); 

   // Long immediate detection selection.
   //                
   assign i_p2_long_immediate2_a =
                      ((i_p2_b_field_long_imm_a & i_p2_src2_addr_sel0_a)
                           | 
                       (i_p2_hi_reg16_long_imm_a & i_p2_src2_hi_a)
                           | 
                       (i_p2_c_field_long_imm_a & i_p2_src2_addr_sel1_a)); 
  
//------------------------------------------------------------------------------
// Source 1 register field validation
//------------------------------------------------------------------------------
//
// The following logic is used to determine if the data in the source1 register
// address field is valid. 
// 
   always @(i_p2_subopcode_r or 
            i_p2_fmt_cond_reg_a or 
            i_p2_fmt_reg_a)
    begin : s1en_subop_async_PROC
      case (i_p2_subopcode_r) 
        SO_ADD,  SO_ADC,   SO_SUB,  SO_SBC,
        SO_AND,  SO_OR,    SO_BIC,  SO_XOR,
        SO_MAX,  SO_MIN,   SO_BSET, SO_BCLR,
        SO_BTST, SO_BMSK,  SO_BXOR, SO_LD, 
        SO_LDB,  SO_LDB_X, SO_LDW,  SO_LDW_X, 
        SO_SR,   SO_ADD1,  SO_ADD2, SO_ADD3, 
        SO_SUB1, SO_SUB2,  SO_SUB3, SO_TST, 
        SO_CMP: 
         i_p2_s1_en_subop_dec_a = 1'b 1;   
         
        SO_RCMP, SO_RSUB:
          if ((i_p2_fmt_cond_reg_a == 1'b 1) | 
            (i_p2_fmt_reg_a      == 1'b 1))
           i_p2_s1_en_subop_dec_a = 1'b 1;   
         else
           i_p2_s1_en_subop_dec_a = 1'b 0;   
        
        SO_MOV:
         begin
            if ((i_p2_fmt_cond_reg_a == 1'b 1) | 
               (i_p2_fmt_reg_a      == 1'b 1))
                i_p2_s1_en_subop_dec_a = 1'b 1;   
            else
             i_p2_s1_en_subop_dec_a = 1'b 0;   
         end
        
        default:
         i_p2_s1_en_subop_dec_a = 1'b 0;   
      
      endcase
    end
   

   always @(i_p2_subopcode2_r or i_p2_s1_en_cfield_dec_a)
    begin : s1en_subop2_async_PROC
      case (i_p2_subopcode2_r)
        SO16_SUB_REG, SO16_AND,  SO16_OR,
        SO16_BIC,     SO16_XOR,  SO16_TST,
        SO16_MUL64,   SO16_ADD1,  SO16_ADD2,
        SO16_ADD3,    SO16_ASL_M, SO16_LSR_M,
        SO16_ASR_M:
         i_p2_s1_en_subop2_dec_a = 1'b 1;  
          
        SO16_SOP:
            i_p2_s1_en_subop2_dec_a = i_p2_s1_en_cfield_dec_a;
          
        default:
            i_p2_s1_en_subop2_dec_a = 1'b 0;   
        
      endcase
    end 
   

   always @(i_p2_c_field16_r)
    begin : s1en_cfield_decode_PROC
      case (i_p2_c_field16_r) 
        SO16_SOP_SUB:
         i_p2_s1_en_cfield_dec_a = 1'b 1;   
        
        default:
         i_p2_s1_en_cfield_dec_a = 1'b 0;   
      
      endcase
    end 
   

   always @(i_p2_opcode_a or i_p2_subopcode_r or 
         i_p2_s1_en_subop_dec_a or i_p2_s1_en_subop2_dec_a)
    begin : s1en_decode_PROC
      case (i_p2_opcode_a) 
        OP_BLCC:
         begin
            if (i_p2_subopcode_r[0] == 1'b 1) //BRcc
             i_p2_s1_en_decode_a = 1'b 1;   
            else
             i_p2_s1_en_decode_a = 1'b 0;   
            
         end
        
        OP_LD, OP_ST:
         i_p2_s1_en_decode_a = 1'b 1;   
        
        OP_FMT1:
         i_p2_s1_en_decode_a = i_p2_s1_en_subop_dec_a;
         
        OP_16_LD_ADD, OP_16_LD_PC,   OP_16_ARITH, 
        OP_16_LD_U7,  OP_16_LDB_U5,  OP_16_LDW_U6, 
        OP_16_MV_ADD, OP_16_LDWX_U6, OP_16_ST_U7, 
        OP_16_STB_U5, OP_16_STW_U6,  OP_16_SSUB, 
        OP_16_SP_REL, OP_16_GP_REL,  OP_16_ADDCMP, 
        OP_16_BRCC:
         i_p2_s1_en_decode_a = 1'b 1;   
         
        OP_16_ALU_GEN:
         i_p2_s1_en_decode_a = i_p2_s1_en_subop2_dec_a;
        
        default:
         i_p2_s1_en_decode_a = 1'b 0;   
         
      endcase
    end 

   // Final source 1 address validation
   // 
   assign i_p2_source1_en_a = i_p2_iv_r           & 
                             (i_p2_s1_en_decode_a | 
                              XT_ALUOP            & 
                              x_idop_decode2);

//------------------------------------------------------------------------------
// Source 2 register address field validation
//------------------------------------------------------------------------------

   always @(i_p2_opcode_a or i_p2_subopcode_r or i_p2_subopcode2_r or 
            i_p2_subopcode3_r or i_p2_a_field_r or i_p2_b_field16_r or 
            i_p2_minoropcode_r or i_p2_c_field16_r or 
            i_p2_fmt_cond_reg_a or i_p2_fmt_reg_a)
    
    begin : s2en_decode_PROC
      
      case (i_p2_opcode_a)
        OP_BLCC:
         begin
            if ((i_p2_subopcode_r[0] == 1'b 1) & 
               (i_p2_a_field_r[SUBOPCODE_MSB_1] == 1'b 0))
               i_p2_s2_en_decode_a = 1'b 1;   
            else
               i_p2_s2_en_decode_a = 1'b 0;   

         end
        OP_LD: i_p2_s2_en_decode_a = 1'b 0;   
        
        OP_ST: i_p2_s2_en_decode_a = 1'b 1;   
         
        OP_FMT1:
         begin
            case (i_p2_subopcode_r) 
             SO_ADD,   SO_ADC,   SO_SUB,   SO_SBC,    
             SO_AND,   SO_OR,    SO_BIC,   SO_XOR,    
             SO_MAX,   SO_MIN,   SO_LR,    SO_SR,    
             SO_MOV,   SO_J,     SO_BSET,  SO_BCLR,    
             SO_BTST,  SO_BMSK,  SO_BXOR,  SO_J_D,    
             SO_JL,    SO_JL_D,  SO_ADD1,  SO_ADD2,    
             SO_ADD3,  SO_SUB2,  SO_SUB3,  SO_TST,    
             SO_CMP,   SO_SUB1,  SO_FLAG:
               begin
                 if ((i_p2_fmt_cond_reg_a == 1'b 1) | 
                    (i_p2_fmt_reg_a == 1'b 1))
                  begin
                     i_p2_s2_en_decode_a = 1'b 1;   
                  end
                 else
                  begin
                     i_p2_s2_en_decode_a = 1'b 0;   
                  end
               end
             SO_SOP:
               begin
                 if (i_p2_minoropcode_r == MO_ZOP)
                  begin
                     i_p2_s2_en_decode_a = 1'b 0;   
                  end
                 else
                  begin
                     if ((i_p2_fmt_cond_reg_a == 1'b 1) | 
                        (i_p2_fmt_reg_a == 1'b 1))
                      begin
                        i_p2_s2_en_decode_a = 1'b 1;   
                      end
                     else
                      begin
                        i_p2_s2_en_decode_a = 1'b 0;   
                      end
                  end
               end
             SO_LD,    SO_RCMP,  SO_RSUB,    
             SO_LDB,   SO_LDB_X, SO_LDW,    
             SO_LDW_X:
               begin
                 i_p2_s2_en_decode_a = 1'b 1;   
               end
             default:
               begin
                 i_p2_s2_en_decode_a = 1'b 0;   
               end
            endcase
         end
        OP_16_LD_ADD, 
        OP_16_MV_ADD:
         begin
            i_p2_s2_en_decode_a = 1'b 1;   
         end
        OP_16_ALU_GEN:
         begin
            case (i_p2_subopcode2_r) 
             SO16_SUB_REG, SO16_AND,   SO16_OR, 
             SO16_BIC,     SO16_XOR,   SO16_TST, 
             SO16_MUL64,   SO16_SEXB,  SO16_SEXW,
             SO16_EXTB,    SO16_EXTW,  SO16_ABS, 
             SO16_NOT,     SO16_NEG,   SO16_ADD1, 
             SO16_ADD2,    SO16_ADD3,  SO16_ASL_M, 
             SO16_LSR_M,   SO16_ASR_M, SO16_ASL_1, 
             SO16_ASR_1,   SO16_LSR_1:
               begin
                 i_p2_s2_en_decode_a = 1'b 1;   
               end
             SO16_SOP:
               begin
                 case (i_p2_c_field16_r) 
                  SO16_SOP_SUB, SO16_SOP_J, 
                  SO16_SOP_JD, SO16_SOP_JL, 
                  SO16_SOP_JLD:
                    begin
                      i_p2_s2_en_decode_a = 1'b 1;   
                    end
                  SO16_SOP_ZOP:
                    begin
                      case (i_p2_b_field16_r) 
                        SO16_ZOP_JEQ, SO16_ZOP_JNE, 
                        SO16_ZOP_J,   SO16_ZOP_JD:
                         begin
                           i_p2_s2_en_decode_a = 1'b 1;   
                         end
                        default:
                         begin
                           i_p2_s2_en_decode_a = 1'b 0;   
                         end
                      endcase
                    end
                  default:
                    begin
                      i_p2_s2_en_decode_a = 1'b 0;   
                    end
                 endcase
               end
             default:
               begin
                 i_p2_s2_en_decode_a = 1'b 0;   
               end
            endcase
         end
        OP_16_ST_U7, 
           OP_16_STB_U5, 
           OP_16_STW_U6:
            begin
               i_p2_s2_en_decode_a = 1'b 1;   
            end
        OP_16_SP_REL:
         begin
            case (i_p2_subopcode3_r) 
             SO16_ST_SP, SO16_STB_SP, SO16_PUSH_U7:
               begin
                 i_p2_s2_en_decode_a = 1'b 1;   
               end
             default:
               begin
                 i_p2_s2_en_decode_a = 1'b 0;   
               end
            endcase
         end
        default:
         begin
            i_p2_s2_en_decode_a = 1'b 0;   
         end
      endcase
    end // block: s2en_decode_PROC

   // Final source 2 address validation
   // 
   assign i_p2_source2_en_a = i_p2_iv_r           & 
                             (i_p2_s2_en_decode_a | 
                              (x_idop_decode2     | 
                               x_isop_decode2)    & 
                               (~x_p2shimm_a) & XT_ALUOP); 



//------------------------------------------------------------------------------
// Stage 2 Destination field
//------------------------------------------------------------------------------

   // [0] Blink Register
   //
   assign i_p2_dest_sel0_a = ((i_p2_iv_r == 1'b 1) & 
                              ((i_p2_opcode_16_sp_rel_a == 1'b 1) & 
                               (i_p2_subop_16_pop_u7_a == 1'b 1) & 
                               (i_p2_iw_r[SP_MODE_1] == 1'b 1) & 
                               (i_p2_iw_r[SP_MODE_2] == 1'b 1) | 
                               (i_p2_jblcc_niv_a == 1'b 1))) ? 1'b 1 : 
          1'b 0; 

  
   // [1] Ilink1 Register
   //
   assign i_p2_dest_sel1_a = p2int & p2ilev1; 

   //  [2]  Ilink2 Register
   // 
   assign i_p2_dest_sel2_a = p2int & ~p2ilev1; 

   //  [3] RLIMM Register : 16-bit NOP
   // 
   assign i_p2_dest_sel3_a = ((i_p2_iv_r == 1'b 1) & 
                              ((i_p2_16_sop_inst_a == 1'b 1) & 
                               (i_p2_c_field16_zop_a == 1'b 1) &
                               (i_p2_b_field16_r == SO16_ZOP_NOP))) ?   1'b 1 : 
          1'b 0; 

   //  [4] Rstackptr Register : 16-bit SP relative instructions, else
   //   
   assign i_p2_dest_sel4_a = ((i_p2_iv_r == 1'b 1) & 
                              ((i_p2_opcode_16_sp_rel_a == 1'b 1) & 
                               ((i_p2_subopcode3_r == SO16_SUB_SP) | 
                                (i_p2_subop_16_push_u7_a == 1'b 1)))) ?
          1'b 1 : 
          1'b 0; 

   //  [5] R0 Register : 16-bit GP relative opcode
   //                          
   assign i_p2_dest_sel5_a = ((i_p2_iv_r == 1'b 1) &
                              (i_p2_opcode_16_gp_rel_a == 1'b 1)) ? 1'b 1 : 
          1'b 0; 

   //  [6] B field   : LD/ST, MOV, and most 16-bit instructions
   // 
   assign i_p2_dest_sel6_a = ((i_p2_iv_r == 1'b 1) & 
                       ((x_p2_bfield_wb_a == 1'b 1) 
                        | 
                        (i_p2_opcode_32_st_a == 1'b 1) 
                        | 
                        ((i_p2_opcode_32_fmt1_a == 1'b 1) & 
                        ((i_p2_subopcode_mov_a == 1'b 1) | 
                         (i_p2_subopcode_sop_a == 1'b 1) | 
                         (i_p2_subopcode_lr_a == 1'b 1))) 
                        | 
                        ((i_p2_no_ld_a == 1'b 1) & 
                        (i_p2_jlcc_a == 1'b 0) & 
                        ((i_p2_fmt_s12_a == 1'b 1) | 
                         (i_p2_fmt_cond_reg_dec_a == 1'b 1)))
                        |
                        (((i_p2_opcode_16_mv_add_a == 1'b 1) & 
                         (i_p2_subop_16_mov_hi2_a == 1'b 0)) 
                        | 
                        (i_p2_opcode_16_alu_a == 1'b 1) 
                        | 
                        (i_p2_opcode_16_ld_pc_a == 1'b 1) 
                        | 
                        ((i_p2_opcode_16_ssub_a == 1'b 1) & 
                         (i_p2_subop_16_btst_u5_a == 1'b 0))
                        | 
                        (i_p2_opcode_16_mov_a == 1'b 1) 
                        | 
                        ((i_p2_opcode_16_addcmp_a == 1'b 1) & 
                         (i_p2_subopcode4_r == SO16_ADD_U7))
                        | 
                        (i_p2_opcode_16_sp_rel_a == 1'b 1) & 
                        ((i_p2_subopcode3_r == SO16_LD_SP) | 
                         (i_p2_subopcode3_r == SO16_LDB_SP) | 
                         (i_p2_subopcode3_r == SO16_ST_SP) | 
                         (i_p2_subopcode3_r == SO16_STB_SP) | 
                         (i_p2_subopcode3_r == SO16_ADD_SP) | 
                         ((i_p2_subop_16_pop_u7_a == 1'b 1) & 
                          (i_p2_iw_r[SP_MODE_2] == 1'b 0)) | 
                         ((i_p2_subop_16_push_u7_a == 1'b 1) & 
                          (i_p2_iw_r[SP_MODE_2] == 1'b 0)))))) ? 1'b 1 : 
          1'b 0; 

   //  [7] H field   : 16-bit MOV/ADD opcode
   // 
   assign i_p2_dest_sel7_a = ((i_p2_iv_r == 1'b 1) &
                       (i_p2_opcode_16_mv_add_a == 1'b 1) & 
                       (i_p2_subop_16_mov_hi2_a == 1'b 1)) ?  1'b 1 : 
          1'b 0; 

   //  [8] A field   : 16-bit LD/ADD opcode
   //          
   assign i_p2_dest_sel8_a = ((i_p2_iv_r == 1'b 1) & 
                       (i_p2_opcode_16_ld_add_a == 1'b 1)) ? 1'b 1 : 
          1'b 0; 

   //  [9] C field   : 16-bit ARITH opcode or 
   //                  16-bit LD/ST with offset instructions
   // 
   assign i_p2_dest_sel9_a = ((i_p2_iv_r == 1'b 1) &
                              ((i_p2_opcode_16_arith_a == 1'b 1) | 
                               (i_p2_ldo16_a == 1'b 1)           | 
                               (i_p2_sto16_a == 1'b 1))) ? 1'b 1 : 
          1'b 0; 

   //  [10] A field
   // 
   assign i_p2_dest_sel10_a = (~(i_p2_dest_sel0_a    |
                                i_p2_dest_sel1_a    | 
                                i_p2_dest_sel2_a    |
                                i_p2_dest_sel3_a    | 
                                i_p2_dest_sel4_a    |
                                i_p2_dest_sel5_a    | 
                                i_p2_dest_sel6_a    |
                                i_p2_dest_sel7_a    | 
                                i_p2_dest_sel8_a    |
                                i_p2_dest_sel9_a)); 


   // Select the correct destination address for the instruction.
   // The destination may be implied by the instruction or explicitly defined
   // within the instruction word.
   //
   assign i_p2_destination_a = (RBLINK & ({(OPERAND_WIDTH){i_p2_dest_sel0_a}}) |
                        
                      RILINK1 & ({(OPERAND_WIDTH){i_p2_dest_sel1_a}}) |
                        
                      RILINK2 & ({(OPERAND_WIDTH){i_p2_dest_sel2_a}}) |
                        
                      RLIMM & ({(OPERAND_WIDTH){i_p2_dest_sel3_a}}) |
                        
                      RSTACKPTR & ({(OPERAND_WIDTH){i_p2_dest_sel4_a}}) |
                        
                      r0 & ({(OPERAND_WIDTH){i_p2_dest_sel5_a}}) |
                        
                      i_p2_b_field_r & ({(OPERAND_WIDTH){i_p2_dest_sel6_a}}) |
                        
                      i_p2_hi_reg16_r & ({(OPERAND_WIDTH){i_p2_dest_sel7_a}}) |
                         
                      i_p2_a_field16_r & ({(OPERAND_WIDTH){i_p2_dest_sel8_a}}) |
                        
                      i_p2_c_field16_2_r & ({(OPERAND_WIDTH){i_p2_dest_sel9_a}}) |
                        
                      i_p2_a_field_r & ({(OPERAND_WIDTH){i_p2_dest_sel10_a}})); 
         
   // Null destination select
   //               
   assign i_p2_dest_immediate_a = ((i_p2_c_field_long_imm_a &
                                    i_p2_dest_sel9_a) 
                           | 
                           (i_p2_hi_reg16_long_imm_a & i_p2_dest_sel7_a) 
                           | 
                           (i_p2_b_field_long_imm_a & i_p2_dest_sel6_a) 
                           | 
                           (i_p2_a_field_long_imm_a & i_p2_dest_sel10_a)
                           | 
                           i_p2_dest_sel3_a); 

//------------------------------------------------------------------------------
// Stage 2 destination address field validation
//------------------------------------------------------------------------------
//
   // This signal is set true when the current instruction in stage 2 has a
   // destination. This implies that the destination address field is correct
   // and should be used to write back to if allowed.
   //
   assign i_p2_destination_en_a = ((i_p2_iv_r & 
                                   (f_desten(i_p2_opcode_a,
                                             i_p2_subopcode_r, 
                                             i_p2_subopcode2_r, 
                                             i_p2_subopcode3_r, 
                                             i_p2_iw_r[ST_AWB_UBND:
                                                       ST_AWB_LBND], 
                                             i_p2_a_field_r, 
                                             i_p2_c_field16_r) | 
                                    i_p2_dest_sel0_a 
                                    | 
                                    (x_idecode2 & 
                                     XT_ALUOP & 
                                     (~xp2idest)))) 
                                    | 
                                    i_p2_dest_sel1_a 
                                    | 
                                    i_p2_dest_sel2_a); 

//------------------------------------------------------------------------------
// Stage 2 Long Immediate Data
//------------------------------------------------------------------------------
//
// Generate signals for pipeline control and interrupt control units.
//
   // p2limm - this will be true when a valid instruction which uses long
   // immediate data is in stage 2. Note that this signal will include
   // p2iv as it includes s1en/s2en.
   //
   assign i_p2_long_immediate_a = ((i_p2_long_immediate1_a &
                                    i_p2_source1_en_a)
                                   | 
                                   (i_p2_long_immediate2_a &
                                    i_p2_source2_en_a));

   assign i_p2_limm_a = i_p2_long_immediate_a | i_p2_tag_nxt_p1_limm_r; 

   // The signal i_p2_dest_imm_a is true when the destination register
   // contains an immediate value.
   //
   assign i_p2_dest_imm_a = i_p2_dest_immediate_a & i_p2_destination_en_a; 

   // This signal is true when the instruction in stage 2 has a long immediate
   // and the instruction will move into stage 2b.  The signal is cleared when
   // instruction with the LIMM leaves stage 2b.  The instruction can leave
   // stage 2b either by normal instruction flow or by the instruction being
   // killed. This can This signal is registers to become i_p2b_has_limm_r.
   // 
   assign i_p2b_has_limm_nxt = ((i_p4_kill_p2b_a           == 1'b 1) | 
                                (i_p2b_has_limm_r          == 1'b 1) & 
                                (i_p2b_en_nopwr_save_a == 1'b 1)) ? 
          1'b 0 :
                               ((i_p2_long_immediate_a == 1'b 1) & 
                                (i_p2_enable_a         == 1'b 1) & 
                                (i_p2_iv_r             == 1'b 1) & 
                                (i_kill_p2_en_a        == 1'b 0)) ?
          1'b 1 : 
          i_p2b_has_limm_r; 
   
   // This signal is true when the instruction in stage 2 has decoded that it
   // has long immediate data, however the data has not yet arrived in stage 1.
   //  The signal denotes that the next longword to arrive from the cache will
   // be long immediate data.
   //
   assign i_p2_tag_nxt_p1_limm_nxt = ((i_p4_kill_p2b_a         == 1'b 1) |
                                      ((i_p2_tag_nxt_p1_limm_r == 1'b 1) &
                                       (i_p1_enable_a          == 1'b 1))) ?
          1'b 0 : 
                                     ((i_p2_long_immediate_a == 1'b 1) & 
                                      (i_p2_enable_a         == 1'b 1) & 
                                      (i_p2_iv_r             == 1'b 1) & 
                                      (i_kill_p2_en_a        == 1'b 0) & 
                                      (ivalid_aligned        == 1'b 0)) ?
          1'b 1 : 
          i_p2_tag_nxt_p1_limm_r; 

   // This signal indicates that the longword currently in stage 2 is long
   // immediate data. This signal includes the decoding for when an instruction
   // and its long immediate data is separated.
   //
   assign i_p2_is_limm_nxt = ((i_kill_p2_en_a            == 1'b 1) | 
                              (i_p2_is_limm_r            == 1'b 1) & 
                              (i_p2_en_no_pwr_save_a     == 1'b 1)) ? 
          1'b 0 : 
                             (((i_p2_tag_nxt_p1_limm_r    == 1'b 1) & 
                              (i_p1_enable_a             == 1'b 1))
                                | 
                             ((i_p2_long_immediate_a == 1'b 1) & 
                              (i_p2_enable_a         == 1'b 1) & 
                              (i_p2_iv_r             == 1'b 1) & 
                              (i_kill_p2_en_a        == 1'b 0) & 
                              (i_p1_enable_a         == 1'b 1))) ?
          1'b 1 : 
          i_p2_is_limm_r; 

  
   // This signal is used to tag the next longword to be returned from the cache
   // as one that should be killed. This is true under the following conditions:
   //
   // (1) If the instruction that has tagged the next longword out of the cache
   //     as long immediate data is killed by a compare&branch
   // (2) The instruction in stage 2 is to be killed that requires a LIMM,
   //     however it is not available in stage 1
   // (3) A branch or predicted compare&branch that has no delay slot is being
   //     taken and there is a fetch outstanding. The longword being fetched
   //     needs to be killed
   // (4) An interrupt has arrived in stage 2 and will do a delayed PC update.
   //     The longword that is currently being fetch requires killing.
   // (5) A jump is to be taken in stage 2b and either it has no delay slot or
   //     it's delay slot is in stage 2 and the current fetch has not completed.
   // (6) A compare&branch is to be taken in stage 4 and the current fetch has
   //     not completed
   //
   assign i_tag_nxt_p1_killed_nxt = (((i_p2_tag_nxt_p1_limm_r == 1'b 1) &
                               (i_p1_enable_a == 1'b 0) &
                               (i_p4_kill_p2b_a == 1'b 1))
                              | 
                              ((i_p2_long_immediate_a == 1'b 1) & 
                               (i_p2_enable_a == 1'b 1) & 
                               (i_p2_iv_r == 1'b 1) & 
                               (i_kill_p2_en_a == 1'b 1) & 
                               (ivalid_aligned == 1'b 0))
                              | 
                              ((i_p2_dorel_a | 
                                (i_p2b_brcc_pred_nxt) == 1'b 1) & 
                               (i_p2_enable_a == 1'b 1) & 
                               (i_p2_iv_r == 1'b 1) & 
                               (i_p2_has_dslot_a == 1'b 0) & 
                               (ivalid_aligned == 1'b 0)) 
                              | 
                              ((p2int == 1'b 1) & 
                               (i_p2_enable_a == 1'b 1) & 
                               (ivalid_aligned == 1'b 0))
                              | 
                               ((i_p2b_dojcc_a == 1'b 1) & 
                                (i_p2b_enable_a == 1'b 1) & 
                                (i_p2b_iv_r == 1'b 1) & 
                                ((i_p2b_has_dslot_r == 1'b 0) & 
                                 (ivalid_aligned == 1'b 0) | 
                                 (i_p2b_has_dslot_r == 1'b 1) & 
                                 (i_p2_iv_r == 1'b 1) & 
                                 (ivalid_aligned == 1'b 0)))
                              | 
                              ((i_p4_docmprel_a == 1'b 1) & 
                               (i_p4_has_dslot_r == 1'b 0) & 
                               (ivalid_aligned == 1'b 0))
                              | 
                              ((i_p4_docmprel_a == 1'b 1) & 
                               (i_p4_has_dslot_r == 1'b 1) & 
                               ((i_p3_iv_r == 1'b 1) | 
                                (i_p2b_iv_r == 1'b 1) | 
                                (i_p2_iv_r == 1'b 1)) & 
                               (ivalid_aligned == 1'b 0))) ? 
          1'b 1 : 
                              ((i_tag_nxt_p1_killed_r == 1'b 1) & 
                               (i_ifetch_aligned_a == 1'b 1)) ?
          1'b 0 : 
          i_tag_nxt_p1_killed_r; 

   // This signal is true when the instruction in stage 2 has decoded that it
   // has a delay slot, however the delay-slot instruction has not yet arrived
   // in stage 1. The signal denotes that the next longword to arrive from the
   // cache will be a delay slot instruction.
   //
   assign i_p2_tag_nxt_p1_dslot_nxt = ((i_p4_kill_p2b_a         == 1'b 1) | 
                                       (i_p2_tag_nxt_p1_dslot_r == 1'b 1) & 
                                       (i_p1_enable_a           == 1'b 1)) ?
          1'b 0 : 
                                      ((i_p2_has_dslot_a == 1'b 1) & 
                                       (i_p2_enable_a    == 1'b 1) & 
                                       (i_p2_iv_r        == 1'b 1) & 
                                       (i_kill_p2_en_a   == 1'b 0) & 
                                       (ivalid_aligned   == 1'b 0)) ?
          1'b 1 : 
          i_p2_tag_nxt_p1_dslot_r; 

   // This signal is set to true when the instruction in stage 2 has a delay
   // slot and the instruction will move to stage 2b.
   //
   assign i_p2b_has_dslot_nxt = ((i_p4_kill_p2b_a           == 1'b 1) | 
                                 (i_p2b_has_dslot_r         == 1'b 1) & 
                                 (i_p2b_en_nopwr_save_a == 1'b 1)) ? 
          1'b 0 : 
                                ((i_p2_has_dslot_a == 1'b 1) & 
                                 (i_p2_enable_a    == 1'b 1) & 
                                 (i_p2_iv_r        == 1'b 1) & 
                                 (i_kill_p2_en_a   == 1'b 0)) ?
          1'b 1 : 
          i_p2b_has_dslot_r; 

   // This signal is set to true when either:
   //
   // (1) The longword to arrive in stage 1 had been tagged as a delay slot, or
   // (2) The instruction in stage 2 has a delay slot and it will move to stage
   //     2b and the delays slot i in stage 1 and will move to stage 2.
   //
   assign i_p2_is_dslot_nxt =  (i_kill_p2_en_a == 1'b 1) 
                               | 
                               ((i_p2_is_dslot_r == 1'b 1) & 
                                (i_p2_enable_a   == 1'b 1)) ? 
          1'b 0 : 
                               ((i_p2_tag_nxt_p1_dslot_r == 1'b 1) & 
                                (i_p1_enable_a           == 1'b 1))
                               | 
                               ((i_p2_has_dslot_a == 1'b 1) & 
                                (i_p2_enable_a    == 1'b 1) & 
                                (i_p2_iv_r        == 1'b 1) & 
                                (i_kill_p2_en_a   == 1'b 0) & 
                                (i_p1_enable_a    == 1'b 1))  ?
          1'b 1 : 
          i_p2_is_dslot_r; 


//------------------------------------------------------------------------------
// Stall Due to Limm/Delay Slot
//------------------------------------------------------------------------------
//
   // This stall will stop any instruction that has a LIMM or delay slot from
   // moving past stage 2b until the child data has caught up with the parent
   // instruction.
   //
   assign i_p2b_limm_dslot_stall_nxt =  ((i_p2b_has_limm_nxt == 1'b 1) & 
                                         (i_p2b_iv_nxt       == 1'b 1) & 
                                         (i_p2_is_limm_nxt   == 1'b 0))
                                        | 
                                        ((i_p2b_has_dslot_nxt == 1'b 1) & 
                                         (i_p2b_iv_nxt        == 1'b 1) & 
                                         (i_p2_is_dslot_nxt   == 1'b 0))  ?
          1'b 1 : 
          1'b 0; 

   always @(posedge clk or posedge rst_a)
    begin : stall_p2_sync_PROC
      if (rst_a == 1'b 1)
        begin
          i_p2_is_dslot_r          <= 1'b 0;   
          i_p2_is_limm_r           <= 1'b 0;   
          i_p2_tag_nxt_p1_dslot_r  <= 1'b 0;   
          i_p2_tag_nxt_p1_limm_r   <= 1'b 0;   
          i_p2b_has_dslot_r        <= 1'b 0;   
          i_p2b_has_limm_r         <= 1'b 0;   
          i_tag_nxt_p1_killed_r    <= 1'b 0;   
          i_p2b_limm_dslot_stall_r <= 1'b 0;   
        end
      else
        begin
          i_p2_is_limm_r           <= i_p2_is_limm_nxt;   
          i_p2_tag_nxt_p1_limm_r   <= i_p2_tag_nxt_p1_limm_nxt;   
          i_p2b_has_limm_r         <= i_p2b_has_limm_nxt;   
          i_tag_nxt_p1_killed_r    <= i_tag_nxt_p1_killed_nxt;   
          i_p2_is_dslot_r          <= i_p2_is_dslot_nxt;   
          i_p2_tag_nxt_p1_dslot_r  <= i_p2_tag_nxt_p1_dslot_nxt;   
          i_p2b_has_dslot_r        <= i_p2b_has_dslot_nxt;   
          i_p2b_limm_dslot_stall_r <= i_p2b_limm_dslot_stall_nxt;   
        end
    end 
   
  
//------------------------------------------------------------------------------
// Offset selection for branches / compare & branches
//------------------------------------------------------------------------------
  

   // Branch offset
   //
   assign i_p2_b_offset_a = ((i_p2_iw_r[MINOR_OP_LBND] == 1'b 1) ? 
                      {i_p2_iw_r[TARG_BL_MSB_UBND:TARG_BL_MSB_LBND], 
                       i_p2_iw_r[TARG_BL_MID_UBND:TARG_BL_MID_LBND], 
                       i_p2_iw_r[TARG_BL_LSB_UBND:TARG_BL_LSB_LBND], 
                       i_p2_iw_r[TARG_B_LSB_POS]} : 
                      {{(FOUR){i_p2_iw_r[TARG_BL_MID_UBND]}}, 
                       i_p2_iw_r[TARG_BL_MID_UBND:TARG_BL_MID_LBND], 
                       i_p2_iw_r[TARG_BL_LSB_UBND:TARG_BL_LSB_LBND], 
                       i_p2_iw_r[TARG_B_LSB_POS]});


   // Branch and link offset
   //
   assign i_p2_bl_offset_a = ((i_p2_iw_r[MINOR_OP_LBND + 1] == 1'b 1) ? 
                       {i_p2_iw_r[TARG_BL_MSB_UBND:TARG_BL_MSB_LBND], 
                        i_p2_iw_r[TARG_BL_MID_UBND:TARG_BL_MID_LBND], 
                        i_p2_iw_r[TARG_BL_LSB_UBND:TARG_BL_LSB_LBND],
                        ONE_ZERO} :
                       {{(FOUR){i_p2_iw_r[TARG_BL_MID_UBND]}}, 
                        i_p2_iw_r[TARG_BL_MID_UBND:TARG_BL_MID_LBND], 
                        i_p2_iw_r[TARG_BL_LSB_UBND:TARG_BL_LSB_LBND],
                        ONE_ZERO});
   
   // Compare and branch offset
   //
   assign i_p2_br_offset_a = {{(SEVENTEEN){i_p2_iw_r[TARG_BR_MSB_POS]}}, 
                       i_p2_iw_r[TARG_BR_LSB_UBND:TARG_BR_LSB_LBND]}; 

   // Loop offset
   //
   assign i_p2_lp_offset_a = ((i_p2_fmt_s12_a == 1'b 1) ? 
                       {{(TWELVE){i_p2_iw_r[AOP_UBND]}}, 
                        i_p2_iw_r[AOP_UBND:AOP_LBND], 
                        i_p2_iw_r[COP_UBND:COP_LBND]} : 
                       {{(EIGHTEEN){1'b 0}}, i_p2_iw_r[COP_UBND:COP_LBND]});


   // Select the correct offset for the current instruction
   //
   assign i_p2_offset_a =
                  ((i_p2_b_offset_a & 
                    ({(TARGET_WIDTH){i_p2_opcode_32_bcc_a}}))       | 
                   (i_p2_br_offset_a &
                    ({(TARGET_WIDTH){i_p2b_br_or_bbit32_nxt}}))     | 
                   (i_p2_lp_offset_a &
                    ({(TARGET_WIDTH){i_p2_loop32_a}}))              | 
                   ({{(SEVENTEEN){i_p2_iw_r[SHIMM16_S8_UBND]}}, 
                    i_p2_iw_r[SHIMM16_S8_UBND:SHIMM16_S8_LBND]} &
                    ({(TARGET_WIDTH){i_p2_opcode_16_brcc_a}}))      | 
                   ({{(TWELVE){i_p2_iw_r[SHIMM16_S13_UBND]}}, 
                    i_p2_iw_r[SHIMM16_S13_UBND:SHIMM16_S13_LBND], 
                    ONE_ZERO} &
                    ({(TARGET_WIDTH){i_p2_opcode_16_bl_a}}))        |
                   ({{(FIFTEEN){i_p2_iw_r[SHIMM16_S10_UBND]}},
                    i_p2_iw_r[SHIMM16_S10_UBND:SHIMM16_S10_LBND]} &
                    ({(TARGET_WIDTH){i_p2_opcode_16_bcc_cc_a}}))    | 
                   ({{(EIGHTEEN){i_p2_iw_r[SHIMM16_S7_UBND]}},                   
                    i_p2_iw_r[SHIMM16_S7_UBND:SHIMM16_S7_LBND]} &
                    ({(TARGET_WIDTH){i_p2_opc_16_bcc_cc_s7_a}})) |
                   (i_p2_bl_offset_a &
                    ({(TARGET_WIDTH){i_p2_bl_blcc_32_a}})));

//------------------------------------------------------------------------------
// Short immediate (Shimm) field selction
//------------------------------------------------------------------------------
//
// The short immediate data for 16-bit instructions is defined as follows:
//
   // Unsigned 7-bit data
   //        
   assign i_p2_shimm16_data_sel0_a = ((i_p2_opcode_a == OP_16_LD_U7) 
                             | 
                             (i_p2_opcode_a == OP_16_ST_U7) 
                             | 
                             ((i_p2_opcode_16_sp_rel_a == 1'b 1) & 
                              (i_p2_subop_16_pop_u7_a == 1'b 0) & 
                              (i_p2_subop_16_push_u7_a == 1'b 0))) ?
          1'b 1 :
          1'b 0; 

   // Unsigned 5-bit data
   //
   assign i_p2_shimm16_data_sel1_a = ((i_p2_opcode_a == OP_16_LDB_U5) | 
                             (i_p2_opcode_a == OP_16_STB_U5)) ?  1'b 1 : 
          1'b 0; 

   // Unsigned 6-bit data
   //
   assign i_p2_shimm16_data_sel2_a = ((i_p2_opcode_a == OP_16_LDW_U6) | 
                             (i_p2_opcode_a == OP_16_LDWX_U6) | 
                             (i_p2_opcode_a == OP_16_STW_U6)) ? 1'b 1 : 
          1'b 0; 
 
   // Longword aligned Signed 9-bit data
   //
   assign i_p2_shimm16_data_sel3_a = ((i_p2_opcode_16_gp_rel_a == 1'b 1) & 
                             ((i_p2_subopcode7_r == SO16_LD_GP) | 
                              (i_p2_subopcode7_r == SO16_ADD_GP))) ?   1'b 1 : 
          1'b 0; 

   // Byte aligned signed 9-bit data
   //
   assign i_p2_shimm16_data_sel4_a = ((i_p2_opcode_16_gp_rel_a == 1'b 1) & 
                             (i_p2_subop_16_ldb_gp_a == 1'b 1)) ? 1'b 1 : 
          1'b 0; 

   // Word aligned signed 9-bit data
   //
   assign i_p2_shimm16_data_sel5_a = ((i_p2_opcode_16_gp_rel_a == 1'b 1) & 
                                      (i_p2_subop_16_ldw_gp_a == 1'b 1)) ?
          1'b 1 : 
          1'b 0; 

   // Long word aligned signed 13-bit data
   //
   assign i_p2_shimm16_data_sel6_a = (~(i_p2_opcode_16_arith_a   | 
                                       i_p2_opcode_16_ssub_a    | 
                                       i_p2_shimm16_data_sel0_a | 
                                       i_p2_push_decode_a       | 
                                       i_p2_pop_decode_a        | 
                                       i_p2_opcode_16_brcc_a    | 
                                       i_p2_shimm16_data_sel1_a | 
                                       i_p2_shimm16_data_sel2_a | 
                                       i_p2_shimm16_data_sel3_a | 
                                       i_p2_shimm16_data_sel4_a | 
                                       i_p2_opcode_16_ld_pc_a   | 
                                       i_p2_opcode_16_mov_a     | 
                                       i_p2_opcode_16_addcmp_a  | 
                                       i_p2_shimm16_data_sel5_a)); 

  
   // Select the correct short immediate data for 16-bit instructions
   //
   assign i_p2_shimm16_data_a = (({TEN_ZERO, 
                           i_p2_iw_r[SHIMM16_U3_UBND:
                                  SHIMM16_U3_LBND]} & 
                          ({SHIMM_WIDTH{i_p2_opcode_16_arith_a}}))
                         |  
                         ({EIGHT_ZERO,
                           i_p2_iw_r[SHIMM16_U5_UBND:
                                  SHIMM16_U5_LBND]} &
                          ({SHIMM_WIDTH{i_p2_opcode_16_ssub_a}}))
                         |
                           ({SIX_ZERO,
                           i_p2_iw_r[SHIMM16_U5_UBND:
                                  SHIMM16_U5_LBND],
                           TWO_ZERO} &
                          ({SHIMM_WIDTH{i_p2_shimm16_data_sel0_a}}))
                         |     
                         (PLUS_4 & 
                          ({SHIMM_WIDTH{i_p2_pop_decode_a}})) 
                         |                                            
                         (MINUS_4 &
                          ({SHIMM_WIDTH{i_p2_push_decode_a}}))
                         |                                            
                         (THIRTEEN_ZERO &
                          ({SHIMM_WIDTH{i_p2_opcode_16_brcc_a}})) 
                         |
                                 ({EIGHT_ZERO,
                           i_p2_iw_r[SHIMM16_U5_UBND:
                                  SHIMM16_U5_LBND]} &
                          ({SHIMM_WIDTH{i_p2_shimm16_data_sel1_a}}))
                         |
                                 ({SEVEN_ZERO,
                           i_p2_iw_r[SHIMM16_U5_UBND:
                                  SHIMM16_U5_LBND],ONE_ZERO} & 
                          ({SHIMM_WIDTH{i_p2_shimm16_data_sel2_a}}))
                         |
                                 ({{(TWO){i_p2_iw_r[SHIMM16_S9_UBND]}},                            
                           i_p2_iw_r[SHIMM16_S9_UBND:SHIMM16_S9_LBND], 
                           TWO_ZERO} & 
                          ({SHIMM_WIDTH{i_p2_shimm16_data_sel3_a}}))
                         |
                                 ({{(FOUR){i_p2_iw_r[SHIMM16_S9_UBND]}},
                           i_p2_iw_r[SHIMM16_S9_UBND: SHIMM16_S9_LBND]} &
                          ({SHIMM_WIDTH{i_p2_shimm16_data_sel4_a}}))
                         |
                                 ({THREE_ZERO,
                           i_p2_iw_r[SHIMM16_U10_UBND: 
                                  SHIMM16_U10_LBND],TWO_ZERO} &
                          ({SHIMM_WIDTH{i_p2_opcode_16_ld_pc_a}}))
                         |
                                 ({FIVE_ZERO,                            
                           i_p2_iw_r[SHIMM16_U10_UBND:
                                  SHIMM16_U10_LBND]} & 
                          ({SHIMM_WIDTH{i_p2_opcode_16_mov_a}}))
                         |
                                 ({SIX_ZERO,
                           i_p2_iw_r[SHIMM16_U7_UBND:
                                  SHIMM16_U7_LBND]} & 
                          ({SHIMM_WIDTH{i_p2_opcode_16_addcmp_a}}) )
                         |
                                 ({{(THREE){i_p2_iw_r[SHIMM16_S9_UBND]}},                           
                           i_p2_iw_r[SHIMM16_S9_UBND:
                                  SHIMM16_S9_LBND],
                           ONE_ZERO} & 
                          ({SHIMM_WIDTH{i_p2_shimm16_data_sel5_a}})) 
                         |
                                 ({i_p2_iw_r[SHIMM16_S13_UBND:
                                  SHIMM16_S13_LBND], 
                           TWO_ZERO} & 
                          ({SHIMM_WIDTH{i_p2_shimm16_data_sel6_a}}))); 
                     

   // 16-bit instruction short immmediate
   // 
   assign i_p2_short_imm_sel0_a = i_p2_shimm16_a; 

   // 32-bit ld/st instruction short immediate.
   //   
   assign i_p2_short_imm_sel1_a = (i_p2_opcode_32_st_a | i_p2_opcode_32_ld_a); 

   // 32-bit extension and compare&branch instruction short immediate
   //
   assign i_p2_short_imm_sel2_a =
                           ((((i_p2_opcode_32_fmt1_a == 1'b 1) | 
                              ((x_idecode2 == 1'b 1) & 
                               (i_p2_opcode_16_ushimm_shft_a == 1'b 0))) & 
                             ((i_p2_fmt_u6_a == 1'b 1)         | 
                              (i_p2_fmt_cond_reg_u6_a == 1'b 1))) | 
                            ((i_p2b_br_or_bbit32_nxt == 1'b 1) & 
                             (i_p2_iw_r[OPCODE_MSB] == BR_FMT_U6))) ?
          1'b 1 : 
          1'b 0; 


   // Signed 12-bit short immediate data.
   //
   assign i_p2_short_imm_sel3_a = (~(i_p2_short_imm_sel0_a | 
                                    i_p2_short_imm_sel1_a | 
                                    i_p2_short_imm_sel2_a)); 


   // Select the correct short immediate field for uses by the instruction
   // 
   assign i_p2_short_immediate_a = ((i_p2_shimm16_data_a &
                                     {SHIMM_WIDTH{i_p2_short_imm_sel0_a}})
                           |
                           ({{(FIVE){i_p2_iw_r[SHIMM32_S8_MSB_POS]}},
                             i_p2_iw_r[SHIMM32_S8_LSB_UBND:
                                    SHIMM32_S8_LSB_LBND]} &
                            ({SHIMM_WIDTH{i_p2_short_imm_sel1_a}})) 
                           |
                           ({SEVEN_ZERO,
                             i_p2_iw_r[SHIMM32_U6_UBND:
                                    SHIMM32_U6_LBND]} & 
                            ({SHIMM_WIDTH{i_p2_short_imm_sel2_a}}))
                           |      
                           ({i_p2_iw_r[SHIMM32_S12_MSB_UBND], 
                             i_p2_iw_r[SHIMM32_S12_MSB_UBND:
                                    SHIMM32_S12_MSB_LBND], 
                             i_p2_iw_r[SHIMM32_S12_LSB_UBND:
                                    SHIMM32_S12_LSB_LBND]} & 
                            ({SHIMM_WIDTH{i_p2_short_imm_sel3_a}}))); 


//------------------------------------------------------------------------------
// Stage 2 Short Immediate (32-bit)
//------------------------------------------------------------------------------
//
// Now produce signals which indicate whether a short-immediate field
// is present at the bottom of the instruction
//

   // Unsigned short immediate date for 32-bit instructions is set for
   // basecase ALU instructions (opcode = 0x4) and branch & link
   // instructions.
   //
   assign i_p2_ushimm32_a = ((i_p2_br32_u6_a          == 1'b 1) | 
                             (i_p2_no_ld_and_rev_a    == 1'b 1) & 
                             ((i_p2_fmt_cond_reg_u6_a == 1'b 1) | 
                              (i_p2_fmt_u6_a          == 1'b 1))) ?
          1'b 1 : 
          1'b 0;

   // Signed short immediate date for 32-bit instructions is set for
   // basecase ALU instructions (opcode = 0x4) not including reverse
   // arithmetic operations and LD/ST instructions (opcode = 0x2/0x3).
   //
   assign i_p2_sshimm32_a = ((i_p2_opcode_32_ld_a == 1'b 1) 
                            | 
                            (i_p2_opcode_32_st_a == 1'b 1) 
                            | 
                            ((i_p2_no_ld_and_rev_a == 1'b 1) & 
                             (i_p2_fmt_s12_a == 1'b 1))) ?
          1'b 1 : 
          1'b 0; 

   //  This signal is set to true when the instruction in stage two
   //  employs the source one operand with the short imeddiate data
   //  value.
   // 
   assign i_p2_rev_arith_a = (i_p2_opcode_32_fmt1_a & 
                              (i_p2_subopcode_mov_a | 
                               i_p2_subopcode_rsub_a | 
                               i_p2_subopcode_rcmp_a)); 

   //  Signed short immediate date for 32-bit instructions is set for
   //  basecase reverse arithmetic instructions (opcode = 0x4).
   // 
   assign i_p2_sshimm32_s1_a = i_p2_rev_arith_a & i_p2_fmt_s12_a; 

   assign i_p2_ushimm32_s1_a = i_p2_rev_arith_a & (i_p2_fmt_u6_a | 
                                                   i_p2_fmt_cond_reg_u6_a); 

//------------------------------------------------------------------------------
// Stage 2 Short Immediate (16-bit)
//------------------------------------------------------------------------------
//
   // Now produce signals which indicate whether a short-immediate field
   // is present at the bottom of the instruction, due to a 16-bit
   // instruction (i_p2_shimm16_a).
   //
   assign i_p2_shimm16_a = (i_p2_ushimm16_a | i_p2_sshimm16_a); 

   // This selects signed short immediates including branches that
   // are exclusively employed for generating target addresses in stage
   // two. This includes GP relative loads which use signed
   // short immediate data values.
   //
   assign i_p2_sshimm16_a = (i_p2_opcode_16_gp_rel_a | 
                      i_p2_bcc16_no_delay_a |
                      i_p2_br16_no_delay_a); 

   // Signed short immediate date for 32-bit instructions is set for
   // basecase reverse arithmetic instructions (opcode = 0x4).
   //
   assign i_p2_sshimm16_s1_a = i_p2_opcode_16_mov_a; 

   // This selects unsigned short immediates not including branches that
   // are exclusively employed for generating target addresses in stage
   // two so not necessary for stage three. This also does not include
   // GP relative loads which use signed short immediate data values.
   //
   assign i_p2_ushimm16_a = (i_p2_opcode_16_arith_a | 
                             i_p2_ldo16_a | 
                             i_p2_sto16_a | 
                             i_p2_opcode_16_ssub_a | 
                             i_p2_opcode_16_ld_pc_a | 
                             i_p2_opcode_16_sp_rel_a | 
                             i_p2_opcode_16_mov_a | 
                             i_p2_opcode_16_addcmp_a); 


//------------------------------------------------------------------------------
// All Stage 2 Short immediate combinations
//------------------------------------------------------------------------------
//
   assign i_p2_shimm_a = (i_p2_sshimm_a | i_p2_ushimm_a | x_p2shimm_a); 
   assign i_p2_shimm_s1_a = (i_p2_sshimm_s1_a | i_p2_ushimm_s1_a); 
   assign i_p2_sshimm_a = (i_p2_sshimm16_a | i_p2_sshimm32_a); 
   assign i_p2_sshimm_s1_a = (i_p2_sshimm16_s1_a | i_p2_sshimm32_s1_a); 
   assign i_p2_ushimm_a = (i_p2_ushimm16_a | i_p2_ushimm32_a); 
   assign i_p2_ushimm_s1_a = i_p2_ushimm32_s1_a; 

//------------------------------------------------------------------------------
// Stage 2 flag bit
//------------------------------------------------------------------------------
//
   assign i_p2_flag_bit_a = ((i_p2_swi_inst_niv_a == 1'b 1) | 
                             (i_p2_sleep_inst_niv_a == 1'b 1)) ? 1'b 0 : 
                             i_p2_iw_r[SETFLGPOS]; 

//------------------------------------------------------------------------------
// Stage 2 condition code field
//------------------------------------------------------------------------------
//  
   // Q field select for 16bit implied
   //
   assign i_p2_q_sel_16_a = (i_p2_16_sop_inst_a & 
                             i_p2_c_field16_sop_sub_a);

   // This signal is used by instructions in stage 2b,3 & 4.
   //
   assign i_p2_q_a = (({ONE_ZERO, CCNZ} &
                       ({CONDITION_CODE_WIDTH{i_p2_q_sel_16_a}}))
                      |
                      (i_p2_32_q_a &
                       ({CONDITION_CODE_WIDTH{~i_p2_q_sel_16_a}})));

   // Q field for 32-bit instructions.
   //
   assign i_p2_32_q_a = i_p2_iw_r[QQUBND:QQLBND];

   // Q field for 16-bit instructions.
   //
   assign i_p2_16_q_a = i_p2_iw_r[QQ16_UBND:QQ16_LBND]; 


//------------------------------------------------------------------------------
// Stage 2 Condition Codes evaluation
//------------------------------------------------------------------------------
//
// The condition is calculated either by the internal condition code
// unit, or by an external condition code unit whose presence is
// signaled by the extutil constant XT_JMPCC. Bit 4 of the instruction
// word condition code field is used to select between the internal and
// external condition code units. If an external condition code unit
// is not present, and the condition specified refers to an external
// condition, then p2condtrue will be false.
// The signal is only used for branch instructions, and does
// not include any logic to set the output to 0 or 1 when the
// instruction being executed in stage 2 is not a branch .
// p2condtrue must always be decoded along with a test for a branch
// instruction.
//
   always @(aluflags_r or i_p2_32_q_a)
    begin : p2_ccunit_32_PROC

      i_p2_ccunit_32_fz_a = aluflags_r[A_Z_N];   
      i_p2_ccunit_32_fn_a = aluflags_r[A_N_N];   
      i_p2_ccunit_32_fc_a = aluflags_r[A_C_N];   
      i_p2_ccunit_32_fv_a = aluflags_r[A_V_N];   
      i_p2_ccunit_32_nfz_a = ~aluflags_r[A_Z_N];   
      i_p2_ccunit_32_nfn_a = ~aluflags_r[A_N_N];   
      i_p2_ccunit_32_nfc_a = ~aluflags_r[A_C_N];   
      i_p2_ccunit_32_nfv_a = ~aluflags_r[A_V_N];   

      case (i_p2_32_q_a[CCUBND:0]) 
                     
        CCZ:i_p2_ccmatch32_a = i_p2_ccunit_32_fz_a;//   Z,  EQ

        CCNZ:i_p2_ccmatch32_a = i_p2_ccunit_32_nfz_a;//   NZ, NE

        CCPL:i_p2_ccmatch32_a = i_p2_ccunit_32_nfn_a;//   PL, P

        CCMI:i_p2_ccmatch32_a = i_p2_ccunit_32_fn_a;//   MI, N

        CCCS:i_p2_ccmatch32_a = i_p2_ccunit_32_fc_a;//   CS, C

        CCCC:i_p2_ccmatch32_a = i_p2_ccunit_32_nfc_a;//   CC, NC

        CCVS:i_p2_ccmatch32_a = i_p2_ccunit_32_fv_a;//   VS, V

        CCVC:i_p2_ccmatch32_a = i_p2_ccunit_32_nfv_a;//   VC, NV

        CCGT:i_p2_ccmatch32_a = i_p2_ccunit_32_fn_a & 
                           i_p2_ccunit_32_fv_a & 
                           i_p2_ccunit_32_nfz_a | 
                           i_p2_ccunit_32_nfn_a & 
                           i_p2_ccunit_32_nfv_a & 
                           i_p2_ccunit_32_nfz_a;//   GT

        CCGE:i_p2_ccmatch32_a = i_p2_ccunit_32_fn_a & 
                           i_p2_ccunit_32_fv_a | 
                           i_p2_ccunit_32_nfn_a & 
                           i_p2_ccunit_32_nfv_a;//   GE

        CCLT:i_p2_ccmatch32_a = i_p2_ccunit_32_fn_a & 
                           i_p2_ccunit_32_nfv_a | 
                           i_p2_ccunit_32_nfn_a & 
                           i_p2_ccunit_32_fv_a;//   LT

        CCLE:i_p2_ccmatch32_a = i_p2_ccunit_32_fz_a | 
                           i_p2_ccunit_32_fn_a & 
                           i_p2_ccunit_32_nfv_a | 
                           i_p2_ccunit_32_nfn_a & 
                           i_p2_ccunit_32_fv_a;//   LE

        CCHI:i_p2_ccmatch32_a = i_p2_ccunit_32_nfc_a & 
                           i_p2_ccunit_32_nfz_a;//   HI

        CCLS:i_p2_ccmatch32_a = i_p2_ccunit_32_fc_a | 
                           i_p2_ccunit_32_fz_a;//   LS

        CCPNZ:i_p2_ccmatch32_a = i_p2_ccunit_32_nfn_a & 
                           i_p2_ccunit_32_nfz_a;//   PNZ

        default:i_p2_ccmatch32_a = 1'b 1;//   AL

      endcase
    end 
   

   always @(aluflags_r or i_p2_16_q_a)
    begin : p2_ccunit_16_PROC

      i_p2_ccunit_16_fz_a = aluflags_r[A_Z_N];   
      i_p2_ccunit_16_fn_a = aluflags_r[A_N_N];   
      i_p2_ccunit_16_fc_a = aluflags_r[A_C_N];   
      i_p2_ccunit_16_fv_a = aluflags_r[A_V_N];   
      i_p2_ccunit_16_nfz_a = ~aluflags_r[A_Z_N];   
      i_p2_ccunit_16_nfn_a = ~aluflags_r[A_N_N];   
      i_p2_ccunit_16_nfc_a = ~aluflags_r[A_C_N];   
      i_p2_ccunit_16_nfv_a = ~aluflags_r[A_V_N];   

      case (i_p2_16_q_a[CONDITION_CODE_MSB:STD_COND_CODE_MSB]) 
        CCZ_16:
         begin
            i_p2_ccmatch16_a = i_p2_ccunit_16_fz_a;//   Z,  EQ
         end
        CCNZ_16:
         begin
            i_p2_ccmatch16_a = i_p2_ccunit_16_nfz_a;//   NZ, NE
         end
        CC_BCC_16:
         begin
            case (i_p2_16_q_a[STD_COND_CODE_MSB_1:0]) 
             CCGT_16:
               begin
                 i_p2_ccmatch16_a = i_p2_ccunit_16_fn_a & 
                                    i_p2_ccunit_16_fv_a & 
                                    i_p2_ccunit_16_nfz_a | 
                                    i_p2_ccunit_16_nfn_a & 
                                    i_p2_ccunit_16_nfv_a & 
                                    i_p2_ccunit_16_nfz_a;//   GT
               end
             CCGE_16:
               begin
                 i_p2_ccmatch16_a = i_p2_ccunit_16_fn_a & 
                                    i_p2_ccunit_16_fv_a | 
                                    i_p2_ccunit_16_nfn_a & 
                                    i_p2_ccunit_16_nfv_a;//   GE
               end
             CCLT_16:
               begin
                 i_p2_ccmatch16_a = i_p2_ccunit_16_fn_a & 
                                    i_p2_ccunit_16_nfv_a | 
                                    i_p2_ccunit_16_nfn_a & 
                                    i_p2_ccunit_16_fv_a;//   LT
               end
             CCLE_16:
               begin
                 i_p2_ccmatch16_a = i_p2_ccunit_16_fz_a | 
                                    i_p2_ccunit_16_fn_a & 
                                    i_p2_ccunit_16_nfv_a | 
                                    i_p2_ccunit_16_nfn_a & 
                                    i_p2_ccunit_16_fv_a;//   LE
               end
             CCHI_16:
               begin
                 i_p2_ccmatch16_a = i_p2_ccunit_16_nfc_a & 
                                    i_p2_ccunit_16_nfz_a;//   HI
               end
             CCHS_16:
               begin
                 i_p2_ccmatch16_a = i_p2_ccunit_16_nfc_a;//   HS
               end
             CCLO_16:
               begin
                 i_p2_ccmatch16_a = i_p2_ccunit_16_fc_a;//   LO
               end
             default:
               begin
                 i_p2_ccmatch16_a = i_p2_ccunit_16_fc_a | 
                                    i_p2_ccunit_16_fz_a;//   LS
               end
            endcase
         end
        default:
         begin
            i_p2_ccmatch16_a = 1'b 1;//   AL
         end
      endcase
    end 
   

   // 16-bit conditional branch
   //
   assign i_p2_condtrue_sel0_a = i_p2_opcode_16_bcc_a;

   // 32-bit unconditional branch and branch&link decodes
   // 
   assign i_p2_condtrue_sel1_a = ((i_p2_b32_a == 1'b 1) | 
                                  (i_p2_bl32_a == 1'b 1) | 
                                  (i_p2_opcode_16_bl_a == 1'b 1)) ?  1'b 1 : 
          1'b 0; 

   // 32-bit conditional branch, branch&link and extension branches decodes.
   //
   assign i_p2_condtrue_sel2_a = ((x_p2_jump_decode == 1'b 1) & 
                          (i_p2_fmt_cond_reg_dec_a == 1'b 1) | 
                          (i_p2_bcc32_a == 1'b 1) | 
                          (i_p2_blcc32_a == 1'b 1))?  1'b 1 : 
          1'b 0; 

   // Select the conditional evaluations for the different type branches, this
   // signal does not include the lp instruction evaluations.
   //                         
   assign i_p2_condtrue_nlp_a = ((i_p2_ccmatch16_a & i_p2_condtrue_sel0_a)
                                 | 
                                 (i_p2_condtrue_sel1_a) 
                                 | 
                                 (i_p2_ccmatch_alu_ext_a &
                                  i_p2_condtrue_sel2_a)); 

   // Indicates that the branching instruction in stage 2 has met the conditions
   // to do the branch.
   //
   assign i_p2_condtrue_a = (i_p2_condtrue_nlp_a | 
                             (i_p2_ccmatch_alu_ext_a & i_p2_loop32_cc_a) | 
                              i_p2_loop32_ncc_a); 

   // True when the lp instruction in stage 2 will not execute the zero delay
   // loop but will branch over the loop.
   //
   assign i_p2_condtrue_lp_a = (~i_p2_ccmatch_alu_ext_a) & i_p2_loop32_cc_a; 


   // This signal is true when an instruction in stage 2 that employs an
   // extension condition code has been set.
   //
   assign i_p2_ccmatch_alu_ext_a = (i_p2_iw_r[CCXBPOS] == 1'b 0 | 
                                       XT_JMPCC == 1'b 0) ?
          i_p2_ccmatch32_a : 
          xp2ccmatch;

   // Detection of conditional instructions at stage 2:
   // 
   // This signal is used to determine if the instruction in stage 2 is a
   // non-always conditional instruction.
   //
   assign i_p2_conditional_a = (((i_p2_32_q_a != FIVE_ZERO) & 
                         (i_p2_branch32_cc_a 
                          |
                          (x_idecode2 &
                                   i_p2_fmt_cond_reg_dec_a)
                          |
                          i_p2_loop32_cc_a) == 1'b 1)
                        | 
                        ((i_p2_opcode_16_bcc_a == 1'b 1) & 
                         (i_p2_subopcode5_r != TWO_ZERO))) ? i_p2_iv_r : 
          1'b 0; 


//------------------------------------------------------------------------------
// STAGE 2 Branch Decodes
//------------------------------------------------------------------------------

   // 32-bit B/BL decode
   //
   assign i_p2_bra32_a = i_p2_opcode_32_bcc_a | i_p2_bl_blcc_32_a; 

   // 32-bit LP decode
   //
   assign i_p2_loop32_a = ((i_p2_opcode_32_fmt1_a == 1'b 1) & 
                           (i_p2_subopcode_r == SO_LP)) ?  1'b 1 : 
          1'b 0; 

   // 32-bit LP with condition code
   //
   assign i_p2_loop32_cc_a = i_p2_loop32_a & i_p2_fmt_cond_reg_dec_a;

   // 32-bit LP decode without condition code
   //
   assign i_p2_loop32_ncc_a = i_p2_loop32_a & (~i_p2_fmt_cond_reg_dec_a); 

   // 16-bit conditional branch without delay slot
   //
   assign i_p2_bcc16_no_delay_a = i_p2_opcode_16_bcc_a | i_p2_opcode_16_bl_a; 

   // 32-bit always executing branch instruction
   //
   assign i_p2_branch32_a = i_p2_bra32_a | i_p2_loop32_a; 

   // 32-bit Conditionally executed branch instructions.
   //
   assign i_p2_branch32_cc_a = i_p2_bcc32_a | i_p2_blcc32_a; 

   // 16-bit conditional executed branch instructions
   //
   assign i_p2_branch16_cc_a = ((i_p2_opcode_16_bcc_a == 1'b 1) & 
                                (i_p2_subopcode5_r != SO16_B_S9)) ?
          1'b 1 : 
          1'b 0; 

   // All 16-bit branch instructions.
   //
   assign i_p2_branch16_a = i_p2_bcc16_no_delay_a; 

   // This includes both the 32-bit and 16-bit decodes for all non-conditional
   // branch and branch&link instructions.
   //
   assign i_p2_branch_iv_a = i_p2_iv_r & (i_p2_branch16_a | i_p2_branch32_a); 
   
   // This includes decodes for all conditional executed branch and branch &
   // link.
   //                  
   assign i_p2_branch_cc_a = i_p2_branch16_cc_a | i_p2_branch32_cc_a;
 
//------------------------------------------------------------------------------
// Delay slot mode
//------------------------------------------------------------------------------
// 
   // For 16-bit instructions the delay slot mode is intrinsic whereas for
   // 32-bit instructions it is explicit.
   // 
   assign i_p2_has_dslot_a = ((~i_p2_long_immediate_a) & 
                              i_p2_iv_r & 
                              (((i_p2_16_sop_inst_a & 
                                (i_p2_c_field16_sop_jd_a | 
                                 i_p2_c_field16_sop_jld_a | 
                                 (i_p2_c_field16_zop_a & 
                                  i_p2_b_field16_zop_jd_a)))) 
                              | 
                              (i_p2_opcode_32_fmt1_a & 
                               (i_p2_subopcode_jd_a | 
                                i_p2_subopcode_jld_a))
                                | 
                                (i_p2_iw_r[DEL_SLOT_MODE] & 
                                 (i_p2_branch32_cc_a | 
                                  i_p2_bra32_a       | 
                                  i_p2b_br_or_bbit32_nxt)))); 
   
//------------------------------------------------------------------------------
// Stage 2 Branch/Jump/Loop not taken
//------------------------------------------------------------------------------

   assign i_p2_nojump_a = (i_p2_iv_r & 
                           (((~i_p2_condtrue_nlp_a) & 
                              i_p2_branch_cc_a) 
                           | 
                            (i_p2_ccmatch_alu_ext_a & 
                             i_p2_loop32_cc_a))); 


//------------------------------------------------------------------------------
// Stage 2 Branch Taken
//------------------------------------------------------------------------------

   // Cause a relative branch for Bcc and BLcc (branch & link) when the branch
   // condition is true, and for LPcc (loop) when the condition is false. (but
   // only when the instruction in pipeline stage 2 is valid).
   //
   assign i_p2_dorel_a = i_p2_iv_r & (i_p2_condtrue_nlp_a | 
                                      i_p2_condtrue_lp_a); 

//------------------------------------------------------------------------------
// Delay slot instruction handling
//------------------------------------------------------------------------------
  
   assign i_p2_kill_p1_a = ((i_p2_dorel_a     == 1'b 1) & 
                            (i_p2_has_dslot_a == 1'b 0)) ?  1'b 1 : 
          1'b 0;
                     
   assign i_p2_kill_p1_en_a = i_p2_kill_p1_a & i_p2_enable_a; 

//------------------------------------------------------------------------------
// Branch prediction for BRcc
//------------------------------------------------------------------------------
//
// The machine uses static prediction for compare&branches due to the excessive
// number of cycles it takes to resolve the instruction.  The branches are
// predicted taken for backward branches and not taken for forward branches.
// The sign of the offset determines if the branch will be predicted or not.
// Upon a prediction the next pc is set to the branch target location and the
// location of the next instruction (when no delay slot) or the location of the
// instruction after the delay slot is then carried down the pipeline.  If when
// the compare&branch reaches it's resolution point (stage4) it determines that
// the prediction is incorrect then the next pc is set to the address that is
// being carried along the pipeline. 
//
   // This instruction decodes compare&branch instructions with delay-slots or
   // long immediate data.  This will cause the fall through address to be set
   // to 8 bytes after the branch address.
   //
   assign i_p2b_brcc_instr_ds_nxt = (i_p2_iv_r & 
                                     (i_p2b_br_or_bbit32_nxt & 
                                      (i_p2_iw_r[DEL_SLOT_MODE] |
                                       i_p2_limm_a)));

   // This decodes branches without a delay-slot or long immediate data.  The
   // fall through address is 4 bytes if the branch is a 32-bit or 2 bytes after
   // if the branch is 16-bits.
   // 
   assign i_p2b_brcc_instr_nds_nxt = (i_p2_iv_r & 
                                      (i_p2_br16_no_delay_a | 
                                       (i_p2b_br_or_bbit32_nxt   & 
                                       (~i_p2_iw_r[DEL_SLOT_MODE]) & 
                                       (~i_p2_limm_a)))); 


   // Compare & Branch Backward branch predict taken delay slot independent.
   //
   assign i_p2b_brcc_pred_nxt = (i_p2_offset_a[TARGSZ] & 
                                 (i_p2b_brcc_instr_nds_nxt |
                                  i_p2b_brcc_instr_ds_nxt));

   // Compare & Branch Backward branch predict taken with delay slot
   //
   assign i_p2b_brcc_pred_ds_nxt = (i_p2_offset_a[TARGSZ] & 
                                    i_p2b_brcc_instr_ds_nxt); 

   // Compare & Branch Backward branch predict taken without delay slot
   //                         
   assign i_p2_brcc_pred_nds_a = (i_p2_offset_a[TARGSZ] & 
                                  i_p2b_brcc_instr_nds_nxt);

   // Compare & Branch Backward branch predict taken without delay slot
   // including stage 2 enable signal
   // 
   assign i_p2_brcc_pred_nds_en_a = (i_p2_brcc_pred_nds_a & 
                                     i_p2_enable_a); 

//------------------------------------------------------------------------------
// Jump & link and Branch & link decodes
//------------------------------------------------------------------------------  
//
// Now some simple decodes from the opcode field are performed.
// These are for files which do their own decode of the p2opcode
// field.
//
   // Here are the 32/16-bit equivalent decodes for the jump/link, branch/link
   // instructions from the p2opcode and subopcode fields.
   //
   assign i_p2_bl_niv_a = ((i_p2_opcode_32_blcc_a & (~i_p2_iw_r[BR_FMT]))
                           | 
                           (i_p2_opcode_16_bl_a)); 
                     
   // Branch and link.
   //
   assign i_p2_jlcc_a = i_p2_opcode_32_fmt1_a & (i_p2_subopcode_jl_a | 
                                                 i_p2_subopcode_jld_a); 

   assign i_p2b_jlcc_niv_nxt = (i_p2_jlcc_a | 
                                (i_p2_16_sop_inst_a & 
                                 (i_p2_c_field16_sop_jl_a | 
                                  i_p2_c_field16_sop_jld_a))); 

   // Jump and link.
   //
   assign i_p2_jblcc_niv_a = i_p2b_jlcc_niv_nxt | i_p2_bl_niv_a;
 
   assign i_p2_jblcc_iv_a = i_p2_jblcc_niv_a & i_p2_iv_r; 

//------------------------------------------------------------------------------  
// Store link register for branch and link.
//------------------------------------------------------------------------------  
//
   // This signal is set true when a valid branch-and-link instruction
   // is in stage 2, and the condition is valid, meaning that the
   // register should be passed down the pipeline to go into the
   // register file. It is necessary to latch this signal into p3dolink
   // as the condition code may evaluate with a different result when
   // the instruction gets to stage 3.
   //
   assign i_p2_dolink_a = i_p2_bl_niv_a & i_p2_iv_r & i_p2_condtrue_nlp_a; 


//------------------------------------------------------------------------------
// Stage2 BRcc decode
//------------------------------------------------------------------------------

   // A 32-bit compare/branch (BRcc) instruction has entered stage two.
   //
   assign i_p2b_br_or_bbit32_nxt =
                                ((i_p2_opcode_32_blcc_a              == 1'b 1) & 
                                 (i_p2_iw_r[BR_FMT] == 1'b 1) & 
                                 ((i_p2_a_field_r[SUBOPCODE_MSB_2:0] == BR_CCEQ) |
                                  (i_p2_a_field_r[SUBOPCODE_MSB_2:0] == BR_CCNE) |
                                  (i_p2_a_field_r[SUBOPCODE_MSB_2:0] == BR_CCLT) |
                                  (i_p2_a_field_r[SUBOPCODE_MSB_2:0] == BR_CCGE) |
                                  (i_p2_a_field_r[SUBOPCODE_MSB_2:0] == BR_CCLO) |
                                  (i_p2_a_field_r[SUBOPCODE_MSB_2:0] == BR_CCHS) |
                                  (i_p2_a_field_r[SUBOPCODE_MSB_2:0] == BBIT0)   |
                                  (i_p2_a_field_r[SUBOPCODE_MSB_2:0] == BBIT1))) ?
          1'b 1 : 
          1'b 0; 

   // A 16-bit compare/branch (BRcc) instruction has entered stage two.
   //
   assign i_p2_br16_no_delay_a = i_p2_opcode_16_brcc_a; 

   // Combine 16 and 32 bit compare/branch (BRcc) instruction detection.
   //
   assign i_p2_br_or_bbit_a = i_p2b_br_or_bbit32_nxt | i_p2_br16_no_delay_a;


   // Combine 16 and 32 bit compare/branch (BRcc) instruction detection,
   // with 'instruction valid'
   //
   assign i_p2_br_or_bbit_iv_a = i_p2_br_or_bbit_a & i_p2_iv_r; 

//------------------------------------------------------------------------------
// Stage 2 decode of stage2b jumps
//------------------------------------------------------------------------------

   assign i_p2_p2b_jmp_iv_a = (i_p2_iv_r & 
                               (((i_p2_16_sop_inst_a & 
                                  (i_p2_c_field16_sop_jd_a  | 
                                   i_p2_c_field16_sop_j_a   |
                                   i_p2_c_field16_sop_jl_a  | 
                                   i_p2_c_field16_sop_jld_a | 
                                   (i_p2_c_field16_zop_a & 
                                    (i_p2_b_field16_zop_jeq_a | 
                                     i_p2_b_field16_zop_jd_a  | 
                                     i_p2_b_field16_zop_jne_a | 
                                     i_p2_b_field16_zop_j_a)))))
                              | 
                              (i_p2_opcode_32_fmt1_a & 
                               (i_p2_subopcode_jd_a | 
                                i_p2_subopcode_jld_a | 
                                i_p2_subopcode_j_a | 
                                i_p2_subopcode_jl_a)))); 
                     
//------------------------------------------------------------------------------
// Interrupt hold off
//------------------------------------------------------------------------------
//
// This signal is fed to the interrupt unit to hold off any interrupt from
// entering the pipeline under certain conditions, those conditions are:
//
// (1) The instruction in stage 2 has decoded a long immediate using
//     instruction. The interrupt can overwrite the LIMM as the parent
//     instruction would not execute correctly.
// (2) The instruction in stage 2 has decoded that it requires has a delay slot
//     instruction.  An interrupt cannot separate a instruction from its delay
//     slot because the stall logic would cause a hold up.
// (3) A zero delay loop overrun has occured and the ZD loop logic requires a
//     cycle to correct the overrun.
// (4) A delayed branch or jump is waiting to happened.  This is need to prevent
//     the interrupt from obtaining the wrong address to write to the ilink
//     register.
// (5) A swi is draining the pipeline. This is to prevent a lower priority
//     interrupt from entering the pipeline before the swi is serviced.
//
   assign i_interrupt_holdoff_a = (i_p2_long_immediate_a | 
                                   i_p2_has_dslot_a | 
                                   i_p2_tag_nxt_p1_limm_r | 
                                   i_p2_tag_nxt_p1_dslot_r |
                                   loop_int_holdoff_a |
                                   pcounter_jmp_restart_r |
                                   (i_p2_swi_inst_niv_a & i_p2_iv_r & ~i_p4_disable_r));

//------------------------------------------------------------------------------
// Actionpoint halt holdoff
//------------------------------------------------------------------------------
//
//  An (watch-point) actionpoint should be delayed if:
//  
//  1. The last instruction of a zero delay loop
//  2. A 64-bit instruction with it's opcode in stage 2 and LIMM in stage 1
//  3. Any unresolved branches/jumps currently in the pipeline
//  4. An interupt currently being serviced  

assign i_actionhalt_holdoff_a =  (i_p2_loopend_hit_r & i_p2_iv_r)
                                  |
                                 (p1int | p2int | p3int)      
                                  |
                                  x_multic_busy
                                  |
                                 // wait until 64-bit instruction moved out of pipeline
                                 (i_p2b_long_immediate_r & i_p2b_iv_r & (~i_p2b_enable_a)) | i_p2_long_immediate_a
                                    |
                                    // wait until branches/jumps move out of the pipeline
                                    i_p2_branch_iv_a  | (i_p2_branch_cc_a & i_p2_iv_r) |
                                    i_p2_p2b_jmp_iv_a | ((i_p2b_jmp_niv_a | i_p2b_jmp_cc_a) & i_p2b_iv_r) |
                                 (i_p2b_branch_iv_r & i_p2b_iv_r) | (i_p2_jblcc_iv_a & i_p2_iv_r)  |
                                 (i_p2b_jblcc_iv_r & i_p2b_iv_r) 
                                    | 
                                    // wait until any outstanding kills on stage 1 are done
                                    i_tag_nxt_p1_killed_r | i_p4_docmprel_a
                                  |
                                  // BRcc instructions in stages 2, 2b, 3
                                   (i_p2_br_or_bbit_iv_a & i_p2_iv_r)
                                    |
                                   (i_p2b_br_or_bbit_iv_a & i_p2b_iv_r)
                                    |
                                   (i_p3_br_or_bbit_iv_a & i_p3_iv_r);

assign i_actionhalt_a =         actionhalt & ((~i_actionhalt_holdoff_a) | actionpt_pc_brk_a);


//------------------------------------------------------------------------------
// Is the current instruction in stage part of the instruction set
//------------------------------------------------------------------------------
//
   // The following logic decodes the entire ISA if the longword in stage 2 is
   // decoded to one of the instruction in the set then the i_p2_arcop_a signal
   // is set otherwise it is not.
   //
   always @(i_p2_opcode_a or i_p2_subopcode_r or i_p2_subopcode2_r or 
            i_p2_a_field_r or i_p2_b_field_r or i_p2_b_field16_r or 
            i_p2_subopcode3_r or i_p2_subopcode1_r or
            i_p2_c_field16_r or i_p2_format_r)
    begin : arcop_PROC
      case (i_p2_opcode_a) 
        OP_BCC, OP_LD, OP_ST:
         begin
            i_p2_arcop_a = 1'b 1;   
         end
        OP_BLCC:
         begin
            if (i_p2_subopcode_r[0] == 1'b 1)
             begin
               case (i_p2_a_field_r[SUBOPCODE_MSB_2:0])
                 BR_CCEQ, BR_CCNE, BR_CCLT, 
                 BR_CCGE, BR_CCLO, BR_CCHS, 
                 BBIT0, BBIT1:
                  begin
                     i_p2_arcop_a = 1'b 1;   
                  end
                 default:
                  begin
                     i_p2_arcop_a = 1'b 0;   
                  end
               endcase
             end
            else
             begin
               i_p2_arcop_a = 1'b 1;   
             end
         end
        OP_FMT1:
         begin
            case (i_p2_subopcode_r) 
             SO_SOP:
               begin
                 case (i_p2_a_field_r) 
                  MO_ASL,  MO_ASR,  MO_LSR, 
                  MO_ROR,  MO_RRC,  MO_SEXB, 
                  MO_SEXW, MO_EXTB, MO_EXTW, 
                  MO_ABS,  MO_NOT,  MO_RLC:
                    begin
                      if (i_p2_format_r == FMT_REG | 
                         i_p2_format_r == FMT_U6)
                        begin
                          i_p2_arcop_a = 1'b 1;   
                        end
                      else
                        begin
                          i_p2_arcop_a = 1'b 0;   
                        end
                    end
                  MO_ZOP:
                    begin
                      case (i_p2_b_field_r) 
                        ZO_SLEEP, ZO_SWI, ZO_SYNC:
                         begin
                           if ((i_p2_format_r == FMT_REG) | 
                              (i_p2_format_r == FMT_U6))
                             begin
                               i_p2_arcop_a = 1'b 1;   
                             end
                           else
                             begin
                               i_p2_arcop_a = 1'b 0;   
                             end
                         end
                        default:
                         begin
                           i_p2_arcop_a = 1'b 0;   
                         end
                      endcase
                    end
                  default:
                    begin
                      i_p2_arcop_a = 1'b 0;   
                    end
                 endcase
               end
             SO_ADD, SO_ADC, SO_SUB, SO_SBC, 
                SO_AND, SO_OR, SO_BIC, SO_XOR, 
                SO_MAX, SO_MIN, SO_J, SO_J_D, 
                SO_JL, SO_JL_D, SO_LP, SO_LR, 
                SO_SR, SO_FLAG, SO_LD, SO_LDB, 
                SO_LDB_X, SO_LDW, SO_LDW_X, 
                SO_MOV, SO_BSET, SO_BCLR, 
                SO_BTST, SO_BMSK, SO_BXOR, SO_ADD1,
                SO_ADD2, SO_ADD3, SO_SUB1, SO_SUB2, 
                SO_SUB3, SO_TST, SO_CMP, SO_RCMP, 
                SO_RSUB:
                  begin
                 i_p2_arcop_a = 1'b 1;   
               end
             default:
               begin
                 i_p2_arcop_a = 1'b 0;   
               end
            endcase
         end
        OP_16_LD_ADD, OP_16_MV_ADD, 
           OP_16_LD_U7, OP_16_LDB_U5, OP_16_LDW_U6, 
           OP_16_LDWX_U6, OP_16_ST_U7, OP_16_STB_U5, 
           OP_16_STW_U6, OP_16_SP_REL, 
           OP_16_GP_REL, OP_16_LD_PC, OP_16_MV, 
           OP_16_ADDCMP, OP_16_BRCC, OP_16_BCC, 
           OP_16_BL:
         begin
            i_p2_arcop_a = 1'b 1;   
         end
	OP_16_ARITH:
         begin
	    case (i_p2_subopcode1_r)
              SO16_ASL: i_p2_arcop_a = 1'b 0;
              SO16_ASR: i_p2_arcop_a = 1'b 0;
	      default: i_p2_arcop_a = 1'b 1;
            endcase
         end
	OP_16_SSUB:
	  begin
            case (i_p2_subopcode3_r)
	      SO16_LSR_U5, SO16_ASR_U5, SO16_ASL_U5: i_p2_arcop_a = 1'b 0;
	      default: i_p2_arcop_a = 1'b 1;
	    endcase
	  end
        OP_16_ALU_GEN:
         begin
            case (i_p2_subopcode2_r) 
             SO16_SOP:
               begin
                 case (i_p2_c_field16_r) 
                  SO16_SOP_J, SO16_SOP_JD, SO16_SOP_JL,
                  SO16_SOP_JLD, SO16_SOP_SUB:
                    begin
                      i_p2_arcop_a = 1'b 1;   
                    end
                  SO16_SOP_ZOP:
                    begin
                      case (i_p2_b_field16_r) 
                        SO16_ZOP_NOP, SO16_ZOP_JEQ, SO16_ZOP_JNE, 
                        SO16_ZOP_J, SO16_ZOP_JD:
                         begin
                           i_p2_arcop_a = 1'b 1;   
                         end
                        default:
                         begin
                           i_p2_arcop_a = 1'b 0;   
                         end
                      endcase
                    end
                  default:
                    begin
                      i_p2_arcop_a = 1'b 0;   
                    end
                 endcase
               end
             SO16_SUB_REG, SO16_AND, SO16_BRK, 
                SO16_OR, SO16_BIC, SO16_XOR, 
                SO16_TST, SO16_MUL64, SO16_SEXB, 
                SO16_SEXW, SO16_EXTB, SO16_EXTW, 
                SO16_ABS, SO16_NOT, SO16_NEG, 
                SO16_ADD1, SO16_ADD2, SO16_ADD3, 
                SO16_ASL_1, SO16_ASR_1, SO16_LSR_1:
               begin
                 i_p2_arcop_a = 1'b 1;   
               end
             default:
               begin
                 i_p2_arcop_a = 1'b 0;   
               end
            endcase
         end
        default:
         begin
            i_p2_arcop_a = 1'b 0;   
         end
      endcase
    end 
   

//------------------------------------------------------------------------------
// Generate an Instruction Error
//------------------------------------------------------------------------------
//
// This will occur when a valid instruction in stage 2 is not one of the
// standard opcode set, and the extension logic has not 'claimed' 
// the instruction in stage 2 as one of its own.
//
   // An instruction error is generated when a SWI instruction is detected in
   // stage 2. This is identical to an unknown-instruction interrupt, but we
   // have assigned a specific encoding to reliably generate this interrupt
   // under program control.
   //
   assign i_p2_no_arc_or_ext_instr_a = ((i_p2_arcop_a == 1'b 0) &
                                        ((x_idecode2 & XT_ALUOP) == 1'b 0) &
                                        (i_p2_iv_r == 1'b 1)) ? 1'b 1 : 
          1'b 0;

   // The instruction error interrupt generated by a swi does not actually get
   // triggered until the pipeline has been drained. This is to allow any
   // control transfer instructions to leave the pipe and the prevent an BRK
   // instruction from halting the pipe if they are not on the correct
   // instruction path.
   //
   // This interrupt is also used by the actionpoint SWI mechanism.
   //
   assign i_p2_instruction_error_a = (i_p2_enable_a                  &
                                      i_p2_no_arc_or_ext_instr_a)        | 
                                     (i_p2_swi_inst_a                &
                                      i_p4_disable_r)                    |
                                     actionpt_swi_a; 

//------------------------------------------------------------------------------
// Branch Protection system
//------------------------------------------------------------------------------
//
// In order to generate the stall, we also need to detect a valid
// branch instruction present in stage 2 (i_p2_branch_cc_a).
//
// We generate a stall when the two conditions are present together:
//
//  a. An instruction in stage 3 or stage 2b is attempting to set the flags
//  b. A branch instruction at stage 2 needs to use these new flags
//
// Note that it would be possible to detect the following conditions
// to give theoretical improvements in performance. These are very
// marginal, and have been left out here for the sake of simplicity,
// and the fact it would be difficult for the compiler to take
// advantage of these optimisations. Both cases remove the link
// between setting the flags and the following branch, either because
// the flags don't get set, or because the branch doesn't check the
// flags.
//
//  i. Conditional flag set instruction at stage 3 does not set flags
//      e.g.  add.cc.f r0,r0,r0, resulting in C=1
//
// ii. Branch at stage 2 uses the AL (always) condition code.
//
   assign i_p2_branch_holdup_a = ( //Stage 3 setting flags
                                  (i_p3_bch_flagset_a | 
                                   //  p2b setting flags 
                                   i_p2b_bch_flagset_a) & 
                                   //  branch or loop in p2
                                   (i_p2_branch_cc_a | 
                                    i_p2_loop32_cc_a)); 

//------------------------------------------------------------------------------
// Decode Stage 2 instruction valid
//------------------------------------------------------------------------------
//
// This signal is used to determine if the long word in stage 2 is a valid
// instruction that should be treated as such, when true the instruction is
// valid.  When false the instruction is not valid and should be ignored. The
// condition under which the instruction is not valid are:
//
// (1) The current longword is either garbage or is long immediate data.
// (2) The current longword is tagged to be killed when it arrives from the
//     cache.
// (3) There is a brk instruction in stage 2. When an IVIC occurs the brk must
//     be removed.
// (4) The instruction cannot move from stage 1 into stage 2 following the
//     instruction already in stage 2, i.e. the two instruction have been
//     separated.
// (5) Stage 1 is being killed.  The instruction is being killed as it leaves
//    stage 1.
// (6) Stage 2 is being killed whilst the stage is stalled.
// (7) The data about to enter stage 2 is long immediate data.
// (8) There is an interrupt about to move into stage 2
// (9) The fetch as the interrupt moves from stage 1 to stage 2 is not needed
//     and the data is killed.
//
   assign i_p2_iv_nxt = (((i_p2_tag_nxt_p1_limm_r == 1'b 1) &
                          (i_p1_enable_a == 1'b 1)) 
                         | 
                         ((i_tag_nxt_p1_killed_r == 1'b 1) & (i_p1_enable_a == 1'b 1))
                         | 
                         ((ivic == 1'b 1) & (actionpt_pc_brk_a == 1'b 1))                          
                         | 
                         ((ivic == 1'b 1) & (i_p2_brk_inst_a == 1'b 1)) 
                         | 
                         ((i_p2_enable_a == 1'b 1) & (i_p1_enable_a == 1'b 0))
                         | 
                         ((i_p1_enable_a == 1'b 1) & (i_kill_p1_en_a == 1'b 1))
                         | 
                         ((i_p2_enable_a == 1'b 0) & (i_kill_p2_en_a == 1'b 1))
                         | 
                         ((i_p2_long_immediate_a == 1'b 1) & (i_p2_enable_a == 1'b 1))
                         | 
                         ((p1int == 1'b 1) & (i_p1_enable_a == 1'b 1))
                         | 
                         (p2int == 1'b 1)) ?
          1'b 0 :
 
                        ((i_p2_enable_a == 1'b 0) & (i_p2_iv_r == 1'b 1)) ?
          1'b 1 : 
          
                        ((i_p2_enable_a == 1'b 0) & (i_p1_enable_a == 1'b 0)) ?
          i_p2_iv_r : 
          ivalid_aligned; 

   always @(posedge clk or posedge rst_a)
    begin : p2_iv_sync_PROC
      if (rst_a == 1'b 1)
        begin
          i_p2_iv_r <= 1'b 0;   
        end
      else
        begin
          i_p2_iv_r <= i_p2_iv_nxt;   
        end
    end

//------------------------------------------------------------------------------
// Pipeline 2 -> 2b transition enable
//------------------------------------------------------------------------------
//
// This signal is true when the processor is running, and the instruction in
// stage 2 can be allowed to move on into stage 2b. It may be held up for a
// number of reasons:    
//

   // The following stall signal is used to prevent any of the following
   // signals:
   //
   // [1] Zero delay loops                        OR
   // [2] SWI instruction is detected in stage 2  OR
   // [3] Interrupt                               OR
   // [4] SLEEP                                   OR
   //
   // from being allowed to progress down the pipeline if they are in the
   // shadow of control transfer instruction.  The ZD loop or interrupt or SLEEP
   // may be on a mispredicted path and will be killed.
   //
   assign i_p2_ct_brcc_stall_a = (i_p2_loop32_a              | 
                                  i_p2_no_arc_or_ext_instr_a | 
                                  i_p2_swi_inst_a            |
                                  i_p2_sleep_inst_a)        & 
                                  (i_p2b_jmp_iv_a            | 
                                   i_p2b_br_or_bbit_iv_a     | 
                                   i_p3_br_or_bbit_iv_a      | 
                                   i_p4_br_or_bbit_iv_a); 
  
   // This stall prevents a branch from moving on if it is conditional and there
   // is a flag setting instruction in the pipeline.  The xholdup2 term is used
   // by extension instructions that require stage 2 being held up.
   // SWI instructions must be held in stage two and prevented from initiating
   // an interrupt if there are still instructions in the pipeline.  This is to
   // prevent a brk after a swi from halting the processor before the interrupt
   // has been serviced.
   //
   assign i_p2_holdup_stall_a = ((xholdup2 & XT_ALUOP)
                                 |
                                 p2_ap_stall_a
                                 |
                                 (i_p2_branch_holdup_a & i_p2_iv_r)
                                 |
                                 (i_p2_swi_inst_a & (~i_p4_disable_r))); 

   // This stall is used to prevent garbage for traveling down the pipeline.
   //
   assign i_p2_pwr_save_stall_a = (~i_p2_iv_r) & (~p2int); 

   // There is a stall in stage 2 to stop illegal instruction errors from being
   // lost:
   //
   // [1] An instruction error is happening in stage 2.
   //
   // [2] There is a flag setting instruction in stages 2B, 3 so stall the
   //     processor until this has been completed
   //
  assign i_p2_instr_err_stall_a = (i_p2b_flagu_block_a |
                                   i_p3_flagu_block_a) &
                                  i_p2_no_arc_or_ext_instr_a;

   // The power saving stalls are not stalls that need to propagate down
   // pipeline
   //
   assign i_p2_en_no_pwr_save_a = ((en                        == 1'b 0) | 
                                       (i_p2b_en_nopwr_save_a == 1'b 0) | 
                                       (i_p2_holdup_stall_a       == 1'b 1) |
     (actionpt_pc_brk_a         == 1'b 1) |                                       
                                       (i_p2_ct_brcc_stall_a      == 1'b 1) | 
                                       (i_p2_brk_inst_a           == 1'b 1) |
                                       (i_p2_instr_err_stall_a    == 1'b 1)) ?
          1'b 0 :
          1'b 1; 

   assign i_p2_enable_a = ((i_p2_en_no_pwr_save_a == 1'b 0) 
                           | 
                           (i_p2_pwr_save_stall_a == 1'b 1)) ? 1'b 0 : 
          1'b 1; 


//------------------------------------------------------------------------------
// End of Stage registers
//------------------------------------------------------------------------------

   always @(posedge clk or posedge rst_a)
    begin : Stage_2b_sync_PROC
      if (rst_a == 1'b 1)
        begin
          i_p2b_br_or_bbit32_r    <= 1'b 0;   
          i_p2b_br_or_bbit_r      <= 1'b 0;   
          i_p2b_brcc_pred_r       <= 1'b 0;   
          i_p2b_brcc_pred_ds_r    <= 1'b 0; 
          i_p2b_dest_imm_r        <= 1'b 0;   
          i_p2b_destination_en_r  <= 1'b 0;   
          i_p2b_destination_r     <= {(OPERAND_MSB + 1){1'b 0}};   
          i_p2b_dolink_r          <= 1'b 0;   
          i_p2b_iw_r              <= {(INSTR_UBND + 1){1'b 0}};   
          i_p2b_jlcc_niv_r        <= 1'b 0;   
          i_p2b_long_immediate_r  <= 1'b 0;   
          i_p2b_q_r               <= {CONDITION_CODE_WIDTH{1'b 0}};   
          i_p2b_setflags_r        <= 1'b 0;   
          i_p2b_shimm_r           <= 1'b 0;   
          i_p2b_shimm_s1_r        <= 1'b 0;   
          i_p2b_short_immediate_r <= {(SHIMM_MSB + 1){1'b 0}};   
          i_p2b_source1_addr_r    <= {(OPERAND_MSB + 1){1'b 0}};   
          i_p2b_source1_en_r      <= 1'b 0;   
          i_p2b_source2_addr_r    <= {(OPERAND_MSB + 1){1'b 0}};   
          i_p2b_source2_en_r      <= 1'b 0;   
          i_p2b_subopcode_r       <= {(SUBOPCODE_MSB + 1){1'b 0}};
          i_p2b_sync_inst_r       <= 1'b 0;             
          i_p2b_jblcc_iv_r        <= 1'b 0; 
        i_p2b_branch_iv_r       <= 1'b 0;  
        end
      else
        begin
          if (i_p2_enable_a == 1'b 1)
            begin
              i_p2b_br_or_bbit32_r    <= i_p2b_br_or_bbit32_nxt;   
              i_p2b_br_or_bbit_r      <= i_p2_br_or_bbit_iv_a;   
              i_p2b_brcc_pred_r       <= i_p2b_brcc_pred_nxt;   
              i_p2b_brcc_pred_ds_r    <= i_p2b_brcc_pred_ds_nxt; 
              i_p2b_dest_imm_r        <= i_p2_dest_imm_a;   
              i_p2b_destination_en_r  <= i_p2_destination_en_a;   
              i_p2b_destination_r     <= i_p2_destination_a;   
              i_p2b_dolink_r          <= i_p2_dolink_a;   
              i_p2b_iw_r              <= i_p2_iw_r;   
              i_p2b_jlcc_niv_r        <= i_p2b_jlcc_niv_nxt;   
              i_p2b_long_immediate_r  <= i_p2_long_immediate_a;   
              i_p2b_q_r               <= i_p2_q_a;   
              i_p2b_setflags_r        <= i_p2b_setflags_nxt;   
              i_p2b_shimm_r           <= i_p2_shimm_a;   
              i_p2b_shimm_s1_r        <= i_p2_shimm_s1_a;   
              i_p2b_short_immediate_r <= i_p2_short_immediate_a;   
              i_p2b_source1_addr_r    <= i_p2_source1_addr_a;   
              i_p2b_source1_en_r      <= i_p2_source1_en_a;   
              i_p2b_source2_addr_r    <= i_p2_source2_addr_a;   
              i_p2b_source2_en_r      <= i_p2_source2_en_a;   
              i_p2b_subopcode_r       <= i_p2_subopcode_r; 
              i_p2b_sync_inst_r       <= i_p2_sync_inst_a;  
              i_p2b_jblcc_iv_r        <= i_p2_jblcc_iv_a; 
              i_p2b_branch_iv_r       <= i_p2_branch_iv_a | (i_p2_branch_cc_a & i_p2_iv_r);                
            end
        end
    end
   
   // Combine signals with the stage 2b instruction valid signal
   //
   assign i_p2b_br_or_bbit_iv_a = i_p2b_br_or_bbit_r & i_p2b_iv_r; 
   assign i_p2b_dolink_iv_a = i_p2b_dolink_r & i_p2b_iv_r; 
   assign i_p2b_jlcc_iv_a = i_p2b_jlcc_niv_r & i_p2b_iv_r; 
   assign i_p2b_dest_en_iv_a = i_p2b_destination_en_r & i_p2b_iv_r;

//------------------------------------------------------------------------------
// RF Stage Instruction Fields
//------------------------------------------------------------------------------
//
// The various component parts of the instruction set are extracted here
// to internal signals.
//
   // Major opcode
   //
   assign i_p2b_opcode_r = i_p2b_iw_r[INSTR_UBND:INSTR_LBND]; 

   // Branch and branch&link opcodes
   //
   assign i_p2b_br_bl_subopcode_r = ({i_p2b_iw_r[MINOR_OP_LBND], 1'b 0, 
                                      i_p2b_iw_r[MINOR_BR_UBND:
                                                 MINOR_BR_LBND]}); 
   // B field
   //
   assign i_p2b_b_field_r = {i_p2b_iw_r[BOP_MSB_UBND:BOP_MSB_LBND], 
                             i_p2b_iw_r[BOP_LSB_UBND:BOP_LSB_LBND]}; 

   // C field for 32-bit
   //
   assign i_p2b_c_field_r = i_p2b_iw_r[COP_UBND:COP_LBND]; 

   // Minor opcode
   //
   assign i_p2b_minoropcode_r = i_p2b_iw_r[AOP_UBND:AOP_LBND]; 

   // Format for operands
   //
   assign i_p2b_format_r = i_p2b_iw_r[MINOR_OP_UBND + 2:MINOR_OP_UBND + 1]; 

   // A field
   //
   assign i_p2b_a_field_r = i_p2b_iw_r[AOP_UBND:AOP_LBND]; 

   // The various component parts of the 16-bit instruction set are
   // extracted here to internal signals.
   //
   // Sub Opcodes 1 
   //
   assign i_p2b_subopcode1_r = i_p2b_subopcode_r[SUBOPCODE2_16_MSB:
                                                 SUBOPCODE_MSB_2];

   // Sub Opcodes 2 
   //
   assign i_p2b_subopcode2_r = i_p2b_subopcode_r[SUBOPCODE2_16_MSB:0];

   // Sub Opcodes 3 
   //
   assign i_p2b_subopcode3_r = i_p2b_iw_r[MINOR16_OP3_UBND:MINOR16_OP3_LBND];

   // Sub Opcodes 4 
   //
   assign i_p2b_subopcode4_r = i_p2b_iw_r[SUBOPCODE_BIT];

   // Sub Opcodes 5 
   //
   assign i_p2b_subopcode5_r = i_p2b_iw_r[MINOR16_BR1_UBND:MINOR16_BR1_LBND];

   // Sub Opcodes 6 
   //
   assign i_p2b_subopcode6_r = i_p2b_iw_r[MINOR16_BR2_UBND:MINOR16_BR2_LBND];

   // Sub Opcodes 7 
   //
   assign i_p2b_subopcode7_r = i_p2b_iw_r[MINOR16_OP4_UBND:MINOR16_OP4_LBND]; 


   // A field for 16-bit
   //
   assign i_p2b_a_field16_r = {TWO_ZERO, i_p2b_iw_r[AOP_UBND16], 
                               i_p2b_iw_r[AOP_UBND16:AOP_LBND16]};

   // B field for 16-bit
   //
   assign i_p2b_b_field16_r = i_p2b_b_field_r[OPERAND16_MSB:0]; 

   // C field for 16-bit
   //
   assign i_p2b_c_field16_r = i_p2b_iw_r[COP_UBND16:COP_LBND16]; 

   // C field for 16-bit (extended to fit write-back address register
   // field).
   //
   assign i_p2b_c_field16_2_r = {TWO_ZERO, i_p2b_iw_r[COP_UBND16], 
                                 i_p2b_iw_r[COP_UBND16:COP_LBND16]}; 

   // High register field for 16-bit
   //
   assign i_p2b_hi_reg16_r = {i_p2b_iw_r[AOP_UBND16:AOP_LBND16], 
                              i_p2b_iw_r[COP_UBND16:COP_LBND16]}; 


//------------------------------------------------------------------------------
// Format decodes
//------------------------------------------------------------------------------

   // Conditional register + register
   //
   assign i_p2b_fmt_cond_reg_a = i_p2b_format_r == FMT_COND_REG ? 1'b 1 : 
          1'b 0; 

//------------------------------------------------------------------------------
// Opcode decodes
//------------------------------------------------------------------------------

   // Decode for 16-bit Single Operand instruction.
   //
   assign i_p2b_16_sop_inst_a = (i_p2b_opcode_16_alu_a & 
                                 i_p2b_subop_16_sop_a);

   // Decode for 16-bit instruction
   // 
   assign i_p2b_16_bit_instr_a = (i_p2b_opcode_r[OPCODE_MSB] | 
                                  i_p2b_opcode_r[OPCODE_MSB_1]); 

   // Decode for 32-bit Basecase Instruction Opcode slot.
   //
   assign i_p2b_opcode_32_fmt1_a = (i_p2b_opcode_r == OP_FMT1) ? 1'b 1 : 
          1'b 0; 

   // Decode for 16-bit Basecase ALU Instruction Opcode slot.
   //
   assign i_p2b_opcode_16_alu_a = (i_p2b_opcode_r == OP_16_ALU_GEN) ? 1'b 1 : 
          1'b 0; 

   // Select appropriate address for 16-bit Global pointer instructions.
   //
   assign i_p2b_opcode_16_gp_rel_a = (i_p2b_opcode_r == OP_16_GP_REL) ? 1'b 1 : 
          1'b 0; 

   // Select appropriate address for 16-bit Stack pointer instructions.
   //
   assign i_p2b_opcode_16_sp_rel_a = (i_p2b_opcode_r == OP_16_SP_REL) ? 1'b 1 : 
          1'b 0; 

   // Decode for 16-bit MOV instruction.
   //
   assign i_p2b_opcode_16_mov_a = (i_p2b_opcode_r == OP_16_MV) ? 1'b 1 : 
          1'b 0; 

   // Select PC register for LD PC relative instructions.
   //
   assign i_p2b_opcode_16_ld_pc_a = (i_p2b_opcode_r == OP_16_LD_PC) ? 1'b 1 : 
          1'b 0; 
      
    
   // Decode for 16-bit mov,add & cmp major opcodes
   //
   assign i_p2b_opcode_16_mv_add_a = (i_p2b_opcode_r == OP_16_MV_ADD) ? 1'b 1 : 
          1'b 0; 
  
   // Decode for 16-bit shift & sub major opcodes
   //
   assign i_p2b_opcode_16_ssub_a = (i_p2b_opcode_r == OP_16_SSUB) ? 1'b 1 : 
          1'b 0; 
  
   // Decode for 16-bit load & add major opcodes
   //
   assign i_p2b_opcode_16_ld_add_a = (i_p2b_opcode_r == OP_16_LD_ADD) ? 1'b 1 : 
          1'b 0; 

   // Decode for 16-bit load & add major opcodes
   //
   assign i_p2b_opcode_16_ld_u7_a = (i_p2b_opcode_r == OP_16_LD_U7) ? 1'b 1 : 
          1'b 0; 

   // Decode for 16-bit byte ld with unsigned 5-bit immediate data
   //
   assign i_p2b_opcode_16_ldb_u5_a = (i_p2b_opcode_r == OP_16_LDB_U5) ? 1'b 1 : 
          1'b 0; 
  
   // Decode for 16-bit word ld with unsigned 6-bit immediate data
   //
   assign i_p2b_opcode_16_ldw_u6_a = (i_p2b_opcode_r == OP_16_LDW_U6) ? 1'b 1 : 
          1'b 0; 
  
   // Decode for 16-bit word ld with unsigned 6-bit immediate data and sign
   // extension
   //
   assign i_p2b_opc_16_ldwx_u6_a = (i_p2b_opcode_r == OP_16_LDWX_U6) ? 1'b 1 : 
          1'b 0; 
  
   // Decode for 16-bit st with unsigned 7-bit data
   //
   assign i_p2b_opcode_16_st_u7_a = (i_p2b_opcode_r == OP_16_ST_U7) ? 1'b 1 : 
          1'b 0; 
  
   // Decode for 16-bit byte st with unsigned 5-bit data
   //
   assign i_p2b_opcode_16_stb_u5_a = (i_p2b_opcode_r == OP_16_STB_U5) ? 1'b 1 : 
          1'b 0; 
  
   // Decode for 16-bit word st with unsigned 6-bit data
   //
   assign i_p2b_opcode_16_stw_u6_a = (i_p2b_opcode_r == OP_16_STW_U6) ? 1'b 1 : 
          1'b 0; 
  
   // Decode for 16-bit add & cmp major opcodes
   //
   assign i_p2b_opcode_16_addcmp_a = (i_p2b_opcode_r == OP_16_ADDCMP) ? 1'b 1 : 
          1'b 0; 

   // Decode for 16-bit arithmetic instructions
   //
   assign i_p2b_opcode_16_arith_a = (i_p2b_opcode_r == OP_16_ARITH) ? 1'b 1 : 
          1'b 0; 

   // Decode for 32-bit Load register + offset.
   //
   assign i_p2b_opcode_32_ld_a = (i_p2b_opcode_r == OP_LD) ? 1'b 1 : 
          1'b 0; 

   // Decode 32-bit St with signed 9-bit offset.
   //
   assign i_p2b_opcode_32_st_a = (i_p2b_opcode_r == OP_ST) ? 1'b 1 : 
          1'b 0; 

//------------------------------------------------------------------------------
// Subopcode decodes
//------------------------------------------------------------------------------
    
   // Decode for 32-bit single operand flag instruction
   //
   assign i_p2b_subopcode_flag_a = (i_p2b_subopcode_r == SO_FLAG) ? 1'b 1 : 
          1'b 0;
  
   // Decode for 32-bit auxiliary load
   //
   assign i_p2b_subopcode_lr_a = (i_p2b_subopcode_r == SO_LR) ? 1'b 1 : 
          1'b 0;
  
   // Decode for 32-bit auxiliary load
   //
   assign i_p2b_subopcode_sr_a = (i_p2b_subopcode_r == SO_SR) ? 1'b 1 : 
          1'b 0;
  
   // Decode for 32-bit jump with delay slot
   //
   assign i_p2b_subopcode_jd_a = (i_p2b_subopcode_r == SO_J_D) ? 1'b 1 : 
          1'b 0;

   // Decode for 32-bit jump&link with delay slot
   //
   assign i_p2b_subopcode_jld_a = (i_p2b_subopcode_r == SO_JL_D) ? 1'b 1 : 
          1'b 0;
  
   // Decode for 32-bit jump
   //
   assign i_p2b_subopcode_j_a = (i_p2b_subopcode_r == SO_J) ? 1'b 1 : 
          1'b 0;
  
   // Decode for 32-bit jump&link
   //
   assign i_p2b_subopcode_jl_a = (i_p2b_subopcode_r == SO_JL) ? 1'b 1 : 
          1'b 0;
 
   // Decode for 32-bit load
   //
   assign i_p2b_subopcode_ld_a = (i_p2b_subopcode_r == SO_LD) ? 1'b 1 : 
          1'b 0;
 
   // Decode for 32-bit load
   //
   assign i_p2b_subopcode_ldb_a = (i_p2b_subopcode_r == SO_LDB) ? 1'b 1 : 
          1'b 0;
   
   // Decode for 32-bit byte load with sign extension
   //
   assign i_p2b_subopcode_ldb_x_a = (i_p2b_subopcode_r == SO_LDB_X) ? 1'b 1 : 
          1'b 0;
  
   // Decode for 32-bit word load
   //
   assign i_p2b_subopcode_ldw_a = (i_p2b_subopcode_r == SO_LDW) ? 1'b 1 : 
          1'b 0;
   
   // Decode for 32-bit word load with sign extension
   //
   assign i_p2b_subopcode_ldw_x_a = (i_p2b_subopcode_r == SO_LDW_X) ? 1'b 1 : 
          1'b 0;
    
   // Decode for 16-bit single operand instructions
   //
   assign i_p2b_subop_16_sop_a = (i_p2b_subopcode2_r == SO16_SOP) ? 1'b 1 : 
          1'b 0;
  
   assign i_p2b_subop_16_mov_hi2_a = (i_p2b_subopcode1_r == SO16_MOV_HI2) ?
          1'b 1 : 
          1'b 0; 
     
     
   assign i_p2b_subop_16_push_u7_a = (i_p2b_subopcode3_r == SO16_PUSH_U7) ?
          1'b 1 : 
          1'b 0; 
     
   assign i_p2b_subop_16_pop_u7_a = (i_p2b_subopcode3_r == SO16_POP_U7) ?
          1'b 1 : 
          1'b 0; 

   assign i_p2b_subop_16_ld_a = (i_p2b_subopcode1_r == SO16_LD) ? 1'b 1 : 
        1'b 0; 
     
   assign i_p2b_subop_16_ldb_a = (i_p2b_subopcode1_r == SO16_LDB) ? 1'b 1 : 
          1'b 0; 
     
   assign i_p2b_subop_16_ldw_a = (i_p2b_subopcode1_r == SO16_LDW) ? 1'b 1 : 
          1'b 0; 
     
   assign i_p2b_subop_16_brk_a = (i_p2b_subopcode2_r == SO16_BRK) ? 1'b 1 : 
          1'b 0; 
     
   assign i_p2b_subop_16_st_sp_a = (i_p2b_subopcode3_r == SO16_ST_SP) ? 1'b 1 : 
          1'b 0; 
     
   assign i_p2b_subop_16_stb_sp_a = (i_p2b_subopcode3_r == SO16_STB_SP) ? 1'b 1 : 
          1'b 0; 
     
   assign i_p2b_subop_16_ld_sp_a = (i_p2b_subopcode3_r == SO16_LD_SP) ? 1'b 1 : 
          1'b 0; 
     
   assign i_p2b_subop_16_ldb_sp_a = (i_p2b_subopcode3_r == SO16_LDB_SP) ? 1'b 1 : 
          1'b 0; 
     
   assign i_p2b_subop_16_ld_gp_a = (i_p2b_subopcode7_r == SO16_LD_GP) ? 1'b 1 : 
          1'b 0; 
     
   assign i_p2b_subop_16_ldb_gp_a = (i_p2b_subopcode7_r == SO16_LDB_GP) ? 1'b 1 : 
          1'b 0; 
     
   assign i_p2b_subop_16_ldw_gp_a = (i_p2b_subopcode7_r == SO16_LDW_GP) ? 1'b 1 : 
          1'b 0; 
     
   assign i_p2b_c_field16_zop_a = (i_p2b_c_field16_r == SO16_SOP_ZOP) ? 1'b 1 : 
          1'b 0; 
     
   assign i_p2b_c_field16_sop_sub_a = (i_p2b_c_field16_r == SO16_SOP_SUB) ? 1'b 1 : 
          1'b 0; 
     
   assign i_p2b_c_field16_sop_jd_a = (i_p2b_c_field16_r == SO16_SOP_JD) ? 1'b 1 : 
          1'b 0; 
     
   assign i_p2b_c_field16_sop_jld_a = (i_p2b_c_field16_r == SO16_SOP_JLD) ? 1'b 1 : 
          1'b 0; 
     
   assign i_p2b_c_field16_sop_j_a = (i_p2b_c_field16_r == SO16_SOP_J) ? 1'b 1 : 
          1'b 0; 

   assign i_p2b_c_field16_sop_jl_a = (i_p2b_c_field16_r == SO16_SOP_JL) ? 1'b 1 : 
          1'b 0; 
     
   assign i_p2b_b_field16_zop_jeq_a = (i_p2b_b_field16_r == SO16_ZOP_JEQ) ? 1'b 1 : 
          1'b 0; 
     
   assign i_p2b_b_field16_zop_jne_a = (i_p2b_b_field16_r == SO16_ZOP_JNE) ? 1'b 1 : 
          1'b 0; 
     
   assign i_p2b_b_field16_zop_jd_a = (i_p2b_b_field16_r == SO16_ZOP_JD) ? 1'b 1 : 
          1'b 0; 
     
   assign i_p2b_b_field16_zop_j_a = (i_p2b_b_field16_r == SO16_ZOP_J) ? 1'b 1 : 
          1'b 0; 

   // Decode for 16-bit single operand subtract
   //
   assign i_p3_sop_sub_nxt = (i_p2b_opcode_16_alu_a & 
                              i_p2b_subop_16_sop_a & 
                              i_p2b_c_field16_sop_sub_a); 

   //  Auxiliary Load.
   // 
   assign i_p2b_lr_decode_a = (i_p2b_opcode_32_fmt1_a & 
                               i_p2b_subopcode_lr_a); 

   //  Auxiliary Store.
   // 
   assign i_p2b_sr_decode_a = (i_p2b_opcode_32_fmt1_a & i_p2b_subopcode_sr_a); 


   // Data cache bypass set when ".di" is spicified in the instruction word..
   //
   assign i_p2b_nocache_a = i_p2b_mop_e_a[DC_BYPASS]; 
   
   // Detect JMPs in stage 2b. Used for delaying actionpoint trigger until jmps resolve 
   assign p2b_jmp_holdup_a = i_p2b_holdup_stall_a & i_p2b_jmp_cc_a & i_p2b_iv_r; 

//------------------------------------------------------------------------------
// Ld/St information
//------------------------------------------------------------------------------
//
// The load instruction has two opcodes ldr (0x02) and OP_FMT1 (0x04). The
// auxiliary LR instruction is encoded on the OP_FMT1 instruction slot, so must
// be excluded when producing a signal which indicates that a load instruction
// is in stage 2.
//
   // The 32-bit Loads employ 2 opcode slots :
   //
   // [1] LD reg + 9-bit signed offset,
   // [2] LD reg + reg.
   //
   // The 16-bit Loads employ 7 opcode slots :
   //
   // [1] LD reg + reg, LDB reg + reg, LDW reg + reg,
   // [2] LD reg + unsigned 7-bit
   // [3] LDB reg + unsigned 5-bit
   // [4] LDW reg + unsigned 6-bit
   // [5] LDW.X reg + unsigned 6-bit
   // [6] LD  PC
   // [7] LD SP + unsigned 7-bit, LDB SP + unsigned 7-bit, PUSH
   // [8] LD GP + signed 9-bit.
   //
   assign i_p2b_ld_decode_a = (i_p2b_opcode_32_ld_a 
                        | 
                        i_p2b_opcode_32_fmt1_a & 
                        (i_p2b_subopcode_ld_a | 
                        i_p2b_subopcode_ldb_a | 
                        i_p2b_subopcode_ldb_x_a | 
                        i_p2b_subopcode_ldw_a | 
                        i_p2b_subopcode_ldw_x_a) 
                        | 
                        ((i_p2b_opcode_16_ld_add_a & 
                         (i_p2b_subop_16_ld_a | 
                          i_p2b_subop_16_ldb_a | 
                          i_p2b_subop_16_ldw_a) 
                         | 
                         i_p2b_ldo16_a 
                         | 
                         i_p2b_opcode_16_ld_pc_a 
                         | 
                         (i_p2b_opcode_16_sp_rel_a & 
                          (i_p2b_subop_16_ld_sp_a | 
                           i_p2b_subop_16_ldb_sp_a | 
                           i_p2b_subop_16_pop_u7_a))
                         | 
                         i_p2b_opcode_16_gp_rel_a & 
                         (i_p2b_subop_16_ld_gp_a | 
                          i_p2b_subop_16_ldb_gp_a | 
                          i_p2b_subop_16_ldw_gp_a)))); 

   //  The 16-bit Stores employ 4 opcode slots :
   // 
   //  [1] ST reg + unsigned 7-bit
   //  [2] STB reg + unsigned 5-bit
   //  [3] STW reg + unsigned 6-bit
   //  [4] ST SP + unsigned 7-bit, STB SP + unsigned 7-bit, POP
   // 
   assign i_p2b_st_decode_a = (i_p2b_opcode_32_st_a | 
                               (i_p2b_sto16_a       | 
                                i_p2b_opcode_16_sp_rel_a & 
                                (i_p2b_subop_16_st_sp_a | 
                                 i_p2b_subop_16_stb_sp_a | 
                                 i_p2b_subop_16_push_u7_a))); 

   //  16-bit LD register + offset instructions.
   // 
   assign i_p2b_ldo16_a = (i_p2b_opcode_16_ld_u7_a  | 
                           i_p2b_opcode_16_ldb_u5_a | 
                           i_p2b_opcode_16_ldw_u6_a | 
                           i_p2b_opc_16_ldwx_u6_a); 

   //  16-bit ST register + offset instructions.
   // 
   assign i_p2b_sto16_a = (i_p2b_opcode_r == OP_16_ST_U7 | 
                           i_p2b_opcode_r == OP_16_STB_U5 | 
                           i_p2b_opcode_r == OP_16_STW_U6) ?
          1'b 1 : 
          1'b 0; 

   //  Now extract the extra encoding information used for loads and
   //  stores. The signals are extracted and latched at the end of stage
   //  2.
   // 
   //  ** Note that the signals used, i_p2b_ldo and i_p2b_st, include the
   //  checks that exclude LR and SR. This is correct as LR and SR do not
   //  use the encoding information which is extracted here. **
   // 
   assign i_p2b_ldr_e_a = {i_p2b_iw_r[LDR_DC_BYPASS], 
                           i_p2b_iw_r[LDR_ADDR_WB_UBND:LDR_ADDR_WB_LBND], 
                           i_p2b_iw_r[LDR_SIZE_UBND:LDR_SIZE_LBND], 
                           i_p2b_iw_r[LDR_SIGN_EXT]}; 

   // This signal contains information used for the LD/ST operations. The
   // information contains bypass mode, address update, operation size and
   // sign-extension
   //
   assign i_p2b_mop_e_a = ((i_p2b_iw_r[LDO_EUBND:LDO_ELBND] & 
                     ({(MEMOP_ESZ+1){i_p2b_opcode_32_ld_a}})) 
                     |
                       (i_p2b_iw_r[ST_EUBND:ST_ELBND] & 
                     ({(MEMOP_ESZ+1){i_p2b_opcode_32_st_a}}))
                     |                     
                     (i_p2b_ldr_e_a & 
                     ({(MEMOP_ESZ+1){~(i_p2b_opcode_32_st_a | 
                                  i_p2b_opcode_32_ld_a)}}))); 

//------------------------------------------------------------------------------
// Ld/St size of memory operation
//------------------------------------------------------------------------------
//
   // Decode for implicitly implied longword ld/st
   //
   assign i_p2b_size_sel0_a = ((i_p2b_opcode_16_st_u7_a == 1'b 1) 
                        | 
                        (i_p2b_opcode_16_ld_u7_a == 1'b 1) 
                        | 
                        (i_p2b_opcode_16_ld_pc_a == 1'b 1) 
                        | 
                        ((i_p2b_opcode_16_ld_add_a == 1'b 1) & 
                        (i_p2b_subop_16_ld_a == 1'b 1)) 
                        | 
                        ((i_p2b_opcode_16_sp_rel_a == 1'b 1) & 
                        ((i_p2b_subop_16_st_sp_a == 1'b 1) | 
                         (i_p2b_subop_16_push_u7_a == 1'b 1) | 
                         (i_p2b_subop_16_ld_sp_a == 1'b 1) | 
                         (i_p2b_subop_16_pop_u7_a == 1'b 1))) 
                        | 
                        ((i_p2b_opcode_16_gp_rel_a == 1'b 1) & 
                        (i_p2b_subop_16_ld_gp_a == 1'b 1))) ? 1'b 1 : 
        1'b 0; 

   // Decode for implicitly implied byte ld/st
   //
   assign i_p2b_size_sel1_a = ((i_p2b_opcode_16_stb_u5_a == 1'b 1) 
                        | 
                        (i_p2b_opcode_16_ldb_u5_a == 1'b 1) 
                        | 
                        ((i_p2b_opcode_16_ld_add_a == 1'b 1) & 
                        (i_p2b_subop_16_ldb_a == 1'b 1)) 
                        | 
                        ((i_p2b_opcode_16_sp_rel_a == 1'b 1) & 
                        ((i_p2b_subop_16_stb_sp_a == 1'b 1) | 
                         (i_p2b_subopcode3_r == SO16_LDB_SP)))
                        | 
                        ((i_p2b_opcode_16_gp_rel_a == 1'b 1) & 
                        (i_p2b_subopcode7_r == SO16_LDB_GP))) ? 1'b 1 : 
        1'b 0; 

   // Decode for implicitly implied word ld/st
   //
   assign i_p2b_size_sel2_a = ((i_p2b_opcode_16_stw_u6_a == 1'b 1) 
                        | 
                        (i_p2b_opcode_16_ldw_u6_a == 1'b 1) 
                        | 
                        (i_p2b_opc_16_ldwx_u6_a == 1'b 1) 
                        | 
                        ((i_p2b_opcode_16_ld_add_a == 1'b 1) & 
                        (i_p2b_subop_16_ldw_a == 1'b 1))
                        | 
                        ((i_p2b_opcode_16_gp_rel_a == 1'b 1) & 
                        (i_p2b_subop_16_ldw_gp_a == 1'b 1))) ? 1'b 1 : 
        1'b 0; 

   // Decode for implicitly implied word ld/st
   //
   assign i_p2b_size_sel3_a = (~(i_p2b_size_sel0_a | 
                        i_p2b_size_sel1_a | 
                        i_p2b_size_sel2_a)); 


   // Select the correct size for the memory operation
   //
   assign i_p2b_size_a = (LDST_LWORD & {(TWO){i_p2b_size_sel0_a}} 
                          |
                          LDST_BYTE & {(TWO){i_p2b_size_sel1_a}} 
                          |
                          LDST_WORD & {(TWO){i_p2b_size_sel2_a}} 
                          |
                          i_p2b_mop_e_a[LDST_SIZE_UBND:LDST_SIZE_LBND] &
                          {(TWO){i_p2b_size_sel3_a}}); 

//------------------------------------------------------------------------------
// Sign-extension bit for ld/st
//------------------------------------------------------------------------------
//
// Decode for sign extension first two terms are used for the implicitly implied
// instructions and the last term is for the explicitly implied instructions.
//
   assign i_p2b_sex_a = (i_p2b_opc_16_ldwx_u6_a == 1'b 1) ? 
          1'b 1 : 
                        ((i_p2b_opcode_16_ld_add_a == 1'b 1) | 
                         (i_p2b_opcode_16_ld_u7_a  == 1'b 1) | 
                         (i_p2b_opcode_16_ld_pc_a  == 1'b 1) | 
                         (i_p2b_opcode_16_ldb_u5_a == 1'b 1) | 
                         (i_p2b_opcode_16_ldw_u6_a == 1'b 1) | 
                         (i_p2b_opcode_16_sp_rel_a == 1'b 1) | 
                         (i_p2b_opcode_16_gp_rel_a == 1'b 1)) ? 
          1'b 0 : 
          i_p2b_mop_e_a[LDST_SIGN_EXT]; 

//------------------------------------------------------------------------------
// Address write-back mode for ld/st
//------------------------------------------------------------------------------
//
   // 16-bit pre address update addressing mode.  Address = src1 and
   // writeback = (src1 + src2)
   // 
   assign i_p2b_awb_field_sel0_a = (i_p2b_opcode_16_sp_rel_a & 
                                    i_p2b_subop_16_pop_u7_a); 

   // 16-bit post address update addressing mode.  Address = (src1 + src2) and
   // writeback = (src1 + src2)
   // 
   assign i_p2b_awb_field_sel1_a = (i_p2b_opcode_16_sp_rel_a & 
                                    i_p2b_subop_16_push_u7_a); 

   // 16-bit NO address update addressing mode. Address = (src1 + src2)
   // 
   assign i_p2b_awb_field_sel2_a = ((i_p2b_opcode_16_ld_add_a |
                                     i_p2b_ldo16_a            |
                                     i_p2b_opcode_16_ld_pc_a  |
                                     i_p2b_sto16_a            |
                                     i_p2b_opcode_16_gp_rel_a | 
                                     (i_p2b_opcode_16_sp_rel_a & 
                                     (i_p2b_subop_16_stb_sp_a | 
                                      i_p2b_subop_16_st_sp_a  | 
                                      i_p2b_subop_16_ld_sp_a  | 
                                      i_p2b_subop_16_ldb_sp_a)))); 

   // Explictly implied update mode
   //
   assign i_p2b_awb_field_sel3_a = (~(i_p2b_awb_field_sel0_a | 
                                     i_p2b_awb_field_sel1_a | 
                                     i_p2b_awb_field_sel2_a)); 

   // Stage 3 pre decode for pre-update addressing.
   //
   assign i_p3_awb_pre_wb_nxt = ((i_p2b_awb_field_sel0_a == 1'b 1) | 
                         (i_p2b_mop_e_a[LDST_ADDR_WB_UBND:
                                    LDST_ADDR_WB_LBND] == LDST_PRE_WB) & 
                         (i_p2b_awb_field_sel3_a == 1'b 1)) ? 1'b 1 : 
        1'b 0; 


   // This is true when a memory operation (ld/ldo/st) requires an
   // address writeback. Note that p3iv is not explicitly included
   // here, as it is part of mload3 and mstore3.
   //
   assign i_p3_ldst_awb_nxt = (((i_p2b_st_decode_a == 1'b 1) | 
                               (i_p2b_ld_decode_a == 1'b 1)) & 
                        ((i_p3_awb_pre_wb_nxt == 1'b 1) | 
                         ((i_p2b_awb_field_sel1_a == 1'b 1) | 
                          (i_p2b_mop_e_a[LDST_ADDR_WB_UBND:
                                    LDST_ADDR_WB_LBND] == LDST_POST_WB) & 
                          (i_p2b_awb_field_sel3_a == 1'b 1)))) ? 1'b 1 : 
        1'b 0; 


   // Select the correct address mode for the current instruction.
   //
   assign i_p2b_awb_field_a = (LDST_PRE_WB &
                               ({(LDST_AWB_WIDTH){i_p2b_awb_field_sel0_a}}) 
                               |
                               LDST_POST_WB &
                               ({(LDST_AWB_WIDTH){i_p2b_awb_field_sel1_a}}) 
                               | 
                               LDST_NO_WB &
                               ({(LDST_AWB_WIDTH){i_p2b_awb_field_sel2_a}}) 
                               | 
                               i_p2b_mop_e_a[LDST_ADDR_WB_UBND:
                                             LDST_ADDR_WB_LBND] &
                               ({(LDST_AWB_WIDTH){i_p2b_awb_field_sel3_a}})); 

//------------------------------------------------------------------------------
// Destination address register field.
//------------------------------------------------------------------------------
//
// Here the destination field for writeback to the register is
// derived from the A-field or C-field when:
//
// [1] From the 16-bit instruction C-field when the instruction type
//     adds, subtracts, asl and asr with result writeback and opcode
//     is 0x0D.
//
// [2] From the 16-bit instruction Hi register-field (i_p2b_hi_reg16_r)
//     when the opcode is equal to 0x0E and the destination register
//     is between r0 - r63.
//
// [3] From the 16-bit instruction A-field (i_p2b_a_field16_r) when
//     the opcode is greater than 0x07.
//
// [4] Or from the 32-bit instruction (i_p2b_a_field_r).
//

   assign i_p2b_a_field_a_sel0_a = (i_p2b_opcode_16_mv_add_a & 
                                    i_p2b_subop_16_mov_hi2_a); 

   assign i_p2b_a_field_a_sel1_a = (~(i_p2b_opcode_16_arith_a | 
                                     i_p2b_a_field_a_sel0_a | 
                                     i_p2b_16_bit_instr_a)); 

   // Select the A field register.
   //
   assign i_p2b_a_field_a = (i_p2b_c_field16_2_r &
                             ({(OPERAND_WIDTH){i_p2b_opcode_16_arith_a}}) 
                             |
                             i_p2b_hi_reg16_r &
                             ({(OPERAND_WIDTH){i_p2b_a_field_a_sel0_a}}) 
                             |
                             i_p2b_a_field16_r &
                             ({(OPERAND_WIDTH){i_p2b_16_bit_instr_a}})
                             |
                             i_p2b_a_field_r &
                             ({(OPERAND_WIDTH){i_p2b_a_field_a_sel1_a}}));

//------------------------------------------------------------------------------
// Stage 3 pre-decode for destination address field.
//------------------------------------------------------------------------------
//
   // Select b field for ld instructions.
   //
  assign i_p3_sc_dest_nxt_sel1_a = (i_p2b_iv_r        & 
                                    i_p2b_ld_decode_a & 
                                    (~i_p3_sc_dest_nxt_sel2_a)); 

   // Select the stack pointer register for push/pop operations as they will
   // update the stack pointer.
   //
   assign i_p3_sc_dest_nxt_sel2_a = (i_p2b_iv_r & 
                                     i_p2b_opcode_16_sp_rel_a & 
                                     (i_p2b_subop_16_push_u7_a | 
                                      i_p2b_subop_16_pop_u7_a)); 

   // Select destination from stage 2b.
   //
   assign i_p3_sc_dest_nxt_sel3_a = (~(i_p3_sc_dest_nxt_sel1_a | 
                                      i_p3_sc_dest_nxt_sel2_a)); 


   assign i_p3_sc_dest_nxt = (i_p2b_b_field_r &
                              ({(OPERAND_WIDTH){i_p3_sc_dest_nxt_sel1_a}}) 
                              | 
                              RSTACKPTR &
                              ({(OPERAND_WIDTH){i_p3_sc_dest_nxt_sel2_a}}) 
                              | 
                              i_p2b_destination_r &
                              ({(OPERAND_WIDTH){i_p3_sc_dest_nxt_sel3_a}})); 



//------------------------------------------------------------------------------
// Jump condition code evaluation 
//------------------------------------------------------------------------------
//
   always @(aluflags_r or i_p2b_q_r)
    begin : p2b_ccunit_32_PROC

      i_p2b_ccunit_32_fz_a = aluflags_r[A_Z_N];   
      i_p2b_ccunit_32_fn_a = aluflags_r[A_N_N];   
      i_p2b_ccunit_32_fc_a = aluflags_r[A_C_N];   
      i_p2b_ccunit_32_fv_a = aluflags_r[A_V_N];   
      i_p2b_ccunit_32_nfz_a = ~aluflags_r[A_Z_N];   
      i_p2b_ccunit_32_nfn_a = ~aluflags_r[A_N_N];   
      i_p2b_ccunit_32_nfc_a = ~aluflags_r[A_C_N];   
      i_p2b_ccunit_32_nfv_a = ~aluflags_r[A_V_N];   

      case (i_p2b_q_r[CCUBND:0]) 
        CCZ:
         begin
            i_p2b_ccmatch32_a = i_p2b_ccunit_32_fz_a; //   Z,  EQ
         end
        CCNZ:
         begin
            i_p2b_ccmatch32_a = i_p2b_ccunit_32_nfz_a;//   NZ, NE
         end
        CCPL:
         begin
            i_p2b_ccmatch32_a = i_p2b_ccunit_32_nfn_a;//   PL, P
         end
        CCMI:
         begin
            i_p2b_ccmatch32_a = i_p2b_ccunit_32_fn_a; //   MI, N
         end
        CCCS:
         begin
            i_p2b_ccmatch32_a = i_p2b_ccunit_32_fc_a; //   CS, C
         end
        CCCC:
         begin
            i_p2b_ccmatch32_a = i_p2b_ccunit_32_nfc_a;//   CC, NC
         end
        CCVS:
         begin
            i_p2b_ccmatch32_a = i_p2b_ccunit_32_fv_a; //   VS, V
         end
        CCVC:
         begin
            i_p2b_ccmatch32_a = i_p2b_ccunit_32_nfv_a;//   VC, NV
         end
        CCGT:
         begin
            i_p2b_ccmatch32_a = ((i_p2b_ccunit_32_fn_a & 
                               i_p2b_ccunit_32_fv_a & 
                             i_p2b_ccunit_32_nfz_a)
                            | 
                            (i_p2b_ccunit_32_nfn_a & 
                             i_p2b_ccunit_32_nfv_a & 
                             i_p2b_ccunit_32_nfz_a));//   GT
         end
        CCGE:
         begin
            i_p2b_ccmatch32_a = ((i_p2b_ccunit_32_fn_a & i_p2b_ccunit_32_fv_a)
                            | 
                            (i_p2b_ccunit_32_nfn_a & 
                             i_p2b_ccunit_32_nfv_a)); //   GE
         end
        CCLT:
         begin
            i_p2b_ccmatch32_a = ((i_p2b_ccunit_32_fn_a & 
                             i_p2b_ccunit_32_nfv_a)
                            | 
                            (i_p2b_ccunit_32_nfn_a & 
                             i_p2b_ccunit_32_fv_a));  //   LT
         end
        CCLE:
         begin
            i_p2b_ccmatch32_a = i_p2b_ccunit_32_fz_a |
                                i_p2b_ccunit_32_fn_a & 
                                i_p2b_ccunit_32_nfv_a | 
                                i_p2b_ccunit_32_nfn_a & 
                                i_p2b_ccunit_32_fv_a; //   LE
         end
        CCHI:
         begin
            i_p2b_ccmatch32_a = i_p2b_ccunit_32_nfc_a & 
                                i_p2b_ccunit_32_nfz_a;//   HI
         end
        CCLS:
         begin
            i_p2b_ccmatch32_a = i_p2b_ccunit_32_fc_a | 
                                i_p2b_ccunit_32_fz_a; //   LS
         end
        CCPNZ:
         begin
            i_p2b_ccmatch32_a = i_p2b_ccunit_32_nfn_a & 
                                i_p2b_ccunit_32_nfz_a;//   PNZ
         end
        default:
         begin
            i_p2b_ccmatch32_a = 1'b 1;//   AL
         end
      endcase
    end 
   

   // Select the z flag for implicitly implied equal to zero condition code.
   //
   assign i_p2b_condtrue_sel0_a = ((i_p2b_opcode_16_alu_a     == 1'b 1) & 
                                   (i_p2b_subop_16_sop_a      == 1'b 1) & 
                                   (i_p2b_c_field16_zop_a     == 1'b 1) & 
                                   (i_p2b_b_field16_zop_jeq_a == 1'b 1)) ?
          1'b 1 : 
          1'b 0;

   // Select the z flag for implicitly implied not equal to zero condition code.
   //
   assign i_p2b_condtrue_sel1_a = ((i_p2b_opcode_16_alu_a     == 1'b 1) & 
                                   (i_p2b_subop_16_sop_a      == 1'b 1) & 
                                   (i_p2b_c_field16_zop_a     == 1'b 1) & 
                                   (i_p2b_b_field16_zop_jne_a == 1'b 1)) ?
          1'b 1 : 
          1'b 0; 


   // Set condition true for always execute control transfers.
   //
   assign i_p2b_condtrue_sel2_a = (((i_p2b_opcode_32_fmt1_a    == 1'b 1) & 
                                    (i_p2b_fmt_cond_reg_a      == 1'b 0))
                                   | 
                                   ((((i_p2b_16_sop_inst_a     == 1'b 1) &
                                      (i_p2b_c_field16_zop_a   == 1'b 1) &
                                      (i_p2b_b_field16_zop_j_a == 1'b 1))
                                     | 
                                     (i_p2b_jmp16_no_dly_sop_a | 
                                      (i_p2b_jmp16_delay_a)    == 1'b 1)))) ?
          1'b 1 : 
          1'b 0; 

   // Use condition code checking signal for all other types of instructions.
   //
   assign i_p2b_condtrue_sel3_a = ((i_p2b_opcode_32_fmt1_a == 1'b 1) | 
                                   (x_p2b_jump_decode == 1'b 1)) & 
                                   (i_p2b_fmt_cond_reg_a == 1'b 1) ?
          1'b 1 : 
          1'b 0; 

   // AND-ORcd Mux
   //
   assign i_p2b_condtrue_a = (aluflags_r[A_Z_N] & i_p2b_condtrue_sel0_a 
                       | 
                       (~aluflags_r[A_Z_N]) & i_p2b_condtrue_sel1_a
                       | 
                       i_p2b_condtrue_sel2_a 
                       | 
                       i_p2b_ccmatch_alu_ext_a & i_p2b_condtrue_sel3_a); 


   // This signal is true when an instruction in stage 2 that employs
   // an extension condition code has been set.
   //
   assign i_p2b_ccmatch_alu_ext_a = ((i_p2b_iw_r[CCXBPOS] == 1'b 0) | 
                                        (XT_JMPCC == 1'b 0)) ? 
          i_p2b_ccmatch32_a : 
          xp2bccmatch;

//------------------------------------------------------------------------------
// Stage 2b conditional instruction. 
//------------------------------------------------------------------------------
//
// This signal is true when the instruction in stage 2 is conditional and does
// not have an "always" condition.
//
   assign i_p2b_conditional_a = (((i_p2b_q_r != FIVE_ZERO) & 
                          (i_p2b_fmt_cond_reg_a == 1'b 1) & 
                          ((i_p2b_opcode_32_fmt1_a == 1'b 1) 
                           | 
                           (x_idecode2b == 1'b 1) 
                           | 
                           (x_p2b_jump_decode == 1'b 1)))
                         | 
                         (i_p2b_jmp16_cc_a | 
                          i_p3_sop_sub_nxt) == 1'b 1) ? i_p2b_iv_r : 
        1'b 0; 

//------------------------------------------------------------------------------
// STAGE 2B Jump Decodes
//------------------------------------------------------------------------------

   // Delay slot TRUE for J/JL
   //
   assign i_p2b_jmp32_delay_a = (i_p2b_opcode_32_fmt1_a & 
                                 (i_p2b_subopcode_jd_a |
                                  i_p2b_subopcode_jld_a)); 

   //  Delay slot FALSE for 32-bit J/JL
   // 
   assign i_p2b_jmp32_no_delay_a = (i_p2b_opcode_32_fmt1_a & 
                                    (i_p2b_subopcode_j_a | 
                                     i_p2b_subopcode_jl_a)); 

   //  Delay slot FALSE for SOP 16-bit J/JL
   // 
   assign i_p2b_jmp16_no_dly_sop_a = (i_p2b_16_sop_inst_a & 
                                        (i_p2b_c_field16_sop_j_a | 
                                         i_p2b_c_field16_sop_jl_a)); 

   //  Delay slot FALSE for 16-bit J/JL
   // 
   assign i_p2b_jmp16_no_delay_a = (i_p2b_jmp16_no_dly_sop_a | 
                                    i_p2b_16_sop_inst_a   & 
                                    i_p2b_c_field16_zop_a & 
                                    (i_p2b_b_field16_zop_jeq_a | 
                                     i_p2b_b_field16_zop_jne_a | 
                                     i_p2b_b_field16_zop_j_a)); 

   //  Delay slot TRUE for SOP 16-bit J/JL
   // 
   assign i_p2b_jmp16_delay_sop_a = (i_p2b_16_sop_inst_a & 
                                     (i_p2b_c_field16_sop_jd_a | 
                                      i_p2b_c_field16_sop_jld_a)); 

   //  Delay slot TRUE for 16-bit J/JL
   // 
   assign i_p2b_jmp16_delay_a = (i_p2b_jmp16_delay_sop_a 
                         | 
                         (i_p2b_16_sop_inst_a & 
                          i_p2b_c_field16_zop_a & 
                          i_p2b_b_field16_zop_jd_a)); 

   assign i_p2b_jmp32_niv_a = i_p2b_jmp32_delay_a | i_p2b_jmp32_no_delay_a; 

   //  Conditionally executed jump instructions.
   // 
   assign i_p2b_jmp32_cc_a = (i_p2b_opcode_32_fmt1_a & 
                              i_p2b_fmt_cond_reg_a & 
                              (i_p2b_jmp32_delay_a | 
                               i_p2b_jmp32_no_delay_a)); 

   assign i_p2b_jmp16_cc_a = (i_p2b_opcode_16_alu_a & 
                              i_p2b_subop_16_sop_a  & 
                              i_p2b_c_field16_zop_a & 
                              (i_p2b_b_field16_zop_jeq_a | 
                               i_p2b_b_field16_zop_jne_a)); 

   assign i_p2b_jmp16_niv_a = (i_p2b_jmp16_delay_a | 
                               i_p2b_jmp16_no_delay_a); 

   //  This includes both the 32-bit and 16-bit decodes for all branch
   //  and branch & link instructions.
   // 
   assign i_p2b_jmp_iv_a = i_p2b_jmp_niv_a & i_p2b_iv_r; 
   assign i_p2b_jmp_niv_a = i_p2b_jmp16_niv_a | i_p2b_jmp32_niv_a; 
   assign i_p2b_jmp_cc_a = i_p2b_jmp16_cc_a | i_p2b_jmp32_cc_a; 


//------------------------------------------------------------------------------
// Stage 2 Jump Not Taken
//------------------------------------------------------------------------------
//
   assign i_p2b_nojump_a = i_p2b_iv_r & (~i_p2b_condtrue_a) & i_p2b_jmp_cc_a; 

//------------------------------------------------------------------------------
// Stage 2 Jump Taken
//------------------------------------------------------------------------------
//
   // Do a jump indirect (but only when the instruction in pipeline stage 2 is
   // valid). Combine 32 and 16-bit relative jumps. Don't set this signal if the
   // machine is waiting for a LIMM or dslot or the PC will not be correct.
   // Without this signal the jump would place rubbish onto next_pc because it
   // has a higher priority then linear PC updates.
   //  
   assign i_p2b_dojcc_a = (~i_p2b_limm_dslot_stall_r) & (i_p2b_iv_r       & 
                                                       i_p2b_condtrue_a &
                                                       i_p2b_jmp_niv_a); 

//------------------------------------------------------------------------------
// Delay slot cancelling
//------------------------------------------------------------------------------
//
   // Jump instructions may kill the following instructions depending on the
   // delay slot mode and whether the instruction's condition is true.
   //  
   assign i_p2b_kill_p1_a = i_p2b_dojcc_a; 

   assign i_p2b_kill_p1_en_a = i_p2b_dojcc_a & i_p2b_enable_a;
 
   assign i_p2b_kill_p2_a = ((i_p2b_has_dslot_r == 1'b 0) &
                             (i_p2b_dojcc_a == 1'b 1)) ? 1'b 1 : 
          1'b 0; 

   assign i_p2b_kill_p2_en_a = i_p2b_kill_p2_a & i_p2b_enable_a; 


//------------------------------------------------------------------------------
// Store link register for branch and link.
//------------------------------------------------------------------------------
//
   // This signal is set true when a valid branch-and-link instruction is in
   // stage 2b, and the condition is valid, meaning that the register should be
   // passed down the pipeline to go into the register file. It is necessary to
   // latch this signal into p3dolink as the condition code may evaluate with a
   // different result when the instruction gets to stage 3.
   //
   assign i_p3_dolink_nxt = ((i_p2b_jlcc_iv_a & i_p2b_condtrue_a) | 
                             // There was a link instruction taken the cycle 
                             // before.
                             //.
                             i_p2b_dolink_iv_a);
   
  
//------------------------------------------------------------------------------
// Stage 2b Flag Setting
//------------------------------------------------------------------------------
//
// Stage 2b calculation to decide whether to set the flags.
//
// This uses either the .f bit of the instruction, the value implied by the
// short immediate data register number, or is set false if the instruction
// cannot set the flags (load/store, branches/jump).
//
// Special case flag-setters Jcc.F and FLAG are handled separately in flags.
// This signal does not include p3iv. For 16-bit instructions the flag
// setting capability is implied by the instruction type, i.e. CMP, BTST.
//
   // If a 3-operand extension instruction is being used, the flags are not
   // set.
   //
   assign i_p2b_setflags_nxt = (f_no_fset(i_p2_opcode_a, 
                               i_p2_subopcode_r, 
                               i_p2_subopcode3_r, 
                               i_p2_c_field_r, 
                               i_p2_format_r)               == 1'b 1) ? 
          1'b 0 : 
                               ((i_p2_opcode_16_mv_add_a     == 1'b 1) & 
                                (i_p2_subopcode1_r           == SO16_CMP))
                               | 
                               ((i_p2_opcode_16_alu_a        == 1'b 1) & 
                                (i_p2_subopcode2_r           == SO16_TST))
                               | 
                               ((i_p2_opcode_16_ssub_a       == 1'b 1) & 
                                (i_p2_subop_16_btst_u5_a == 1'b 1))
                               | 
                               ((i_p2_opcode_16_addcmp_a     == 1'b 1) & 
                                (i_p2_subopcode4_r           == SO16_CMP_U7)) ?
          1'b 1 : 
          i_p2_flag_bit_a;
  
//------------------------------------------------------------------------------
// Shifting Logic for ADD1/ADD2/ADD
//------------------------------------------------------------------------------
//
   // This signal is common to LD/STs where a shift of one/two place is
   // required left. This is needed to keep logic usage down.
   //
   assign i_p2b_ldst_shift_a = ((i_p2b_opcode_32_ld_a == 1'b 1) 
                        | 
                        ((i_p2b_opcode_32_fmt1_a == 1'b 1) & 
                         (i_p2b_subopcode_r[SUBOPCODE_MSB:
                                       SUBOPCODE_MSB_2] == SO16_SOP_SUB))
                        | 
                        (i_p2b_opcode_32_st_a == 1'b 1)) & 
                         (i_p2b_awb_field_a == LDST_SC_NO_WB) ? 1'b 1 : 
          1'b 0; 

   // Here the value for the source 2 operand is shifted by one place left
   // for LD/ST operation which accesses words, and when performing ADD1/
   // SUB1 arithmetic.
   //
   assign i_p2b_shift_by_one_a = (((i_p2b_ldst_shift_a == 1'b 1) & 
                           (i_p2b_size_a == LDST_WORD)) 
                          | 
                          ((i_p2b_opcode_32_fmt1_a == 1'b 1) & 
                           ((i_p2b_subopcode_r == SO_ADD1) | 
                           (i_p2b_subopcode_r == SO_SUB1)))
                          | 
                          ((i_p2b_opcode_16_alu_a == 1'b 1) & 
                           (i_p2b_subopcode_r[SUBOPCODE2_16_MSB:
                                        0] == SO16_ADD1))) ? 1'b 1 : 
          1'b 0; 

   // Here the value for the source 2 operand is shifted by two places left
   // for LD/ST operation which accesses longwords, and when performing
   // ADD2/SUB2 arithmetic.
   // 
   assign i_p2b_shift_by_two_a = (((i_p2b_ldst_shift_a == 1'b 1) & 
                           (i_p2b_size_a == LDST_LWORD))
                          | 
                          ((i_p2b_opcode_32_fmt1_a == 1'b 1) & 
                           ((i_p2b_subopcode_r == SO_ADD2) | 
                           (i_p2b_subopcode_r == SO_SUB2)))
                          | 
                          ((i_p2b_opcode_16_alu_a == 1'b 1) & 
                           (i_p2b_subopcode_r[SUBOPCODE2_16_MSB:
                                        0] == SO16_ADD2))) ? 1'b 1 : 
          1'b 0; 

   // Here the value for the source 2 operand is shifted by three places
   // left when performing ADD3/SUB3 arithmetic.
   // 
   assign i_p2b_shift_by_three_a = (((i_p2b_opcode_32_fmt1_a == 1'b 1) & 
                            ((i_p2b_subopcode_r == SO_ADD3) | 
                             (i_p2b_subopcode_r == SO_SUB3)))
                           | 
                           ((i_p2b_opcode_16_alu_a == 1'b 1) & 
                            (i_p2b_subopcode_r[SUBOPCODE2_16_MSB:
                                          0] == SO16_ADD3))) ? 1'b 1 : 
          1'b 0;    
  
   // No shift is required. Required for the sum-of-product multiplexer.
   //
   assign i_p2b_shift_by_zero_a = ((i_p2b_shift_by_one_a   == 1'b 0) & 
                                   (i_p2b_shift_by_two_a   == 1'b 0) & 
                                   (i_p2b_shift_by_three_a == 1'b 0)) ?
          1'b 1 : 
          1'b 0; 

//------------------------------------------------------------------------------
// Shortcut Control
//------------------------------------------------------------------------------
//
// The shortcut allows the 32-bit result of stage 3 calculations,
// including load, link stores etc, to be available to the instruction
// at stage 2b before the end of the cycle.
// The source registers of the instruction in stage 2b are compared with
// the destination register a register writeback in stage 3, and if
// they match, the appropriate shortcut-enable signals are set true,
// i.e. f_shcut(i_p2_b_field_r)
//
// Shortcutting is not allowed for the loop-count register as this does
// not have write-through, which means that the value written is not
// available to be read for two cycles following a write. If
// shortcutting was enabled, the new value would be available the cycle
// following the write, then on the cycle after that, the old value
// would be read, then on the third cycle following the write, the new
// value would be available direct from the loop count register.
//
// The immediate data registers are excluded from shortcutting here,
// but this is not strictly necessary as immediate data overrides a
// shortcut in coreregs. It will make the decode here easier however as
// loopcount, and the immediate data registers are in a nice 4-register
// block, on a 4-register boundary.
//
// ** Note that the check for registers on which shortcutting is not
// allowed (i.e. loop count, immediates) is done on each of the source
// registers rather than just on the destination register, as the source
// register number is available direct from a latch, so checking these
// values does not extend the critical path, as would a check on the
// destination register. This may of course not be the case, but we may
// as well be safe. **
//
// Extension logic can prevent registers from being shortcut by using
// the signals x_p2nosc1 and x_p2nosc2. This will allow core registers
// to be added which do not behave exactly as 3-port RAM, for example, a
// register which transfers data values to and from a circular buffer in
// a FIR filter system.
//
// Note that when returning loads always cause stalls, then shortcutting
// can never be performed from a returning load, hence no references to
// ldvalid are required. (p3_wb_req does not include ldvalid)
//
// Note that i_p2b_sc_reg1 includes en in order that host-interface reads
// from registers are not affected by instructions in p2 and p3 which
// would otherwise enable a shortcut.
//

   // Shortcut to source 1.
   //
   assign i_p2b_sc_reg1_nwb_a = ((i_p3_sc_wba_a == i_p2b_source1_addr_r) & 
                         (f_shcut(i_p2b_source1_addr_r) == 1'b 1) & 
                         (i_p2b_source1_en_r == 1'b 1) & 
                         ((x_p2nosc1 & XT_COREREG) == 1'b 0) & 
                         (en == 1'b 1)) ? 1'b 1 : 
          1'b 0; 

   //  Shortcut to source 2.
   // 
   assign i_p2b_sc_reg2_nwb_a = ((i_p3_sc_wba_a == i_p2b_source2_addr_r) & 
                                         (f_shcut(i_p2b_source2_addr_r) == 1'b 1) & 
                                 (i_p2b_source2_en_r == 1'b 1) & 
                                 ((x_p2nosc2 & XT_COREREG) == 1'b 0) & 
                                  (en == 1'b 1)) ? 1'b 1 : 
          1'b 0;

   assign i_p2b_sc_reg1_a = (i_p2b_sc_reg1_nwb_a & 
                             ((i_p3_wb_req_a & 
                               i_p3_destination_en_iv_a) 
                              | 
                              (x_multic_wben & 
                               XT_MULTIC_OP))); 

   assign i_p2b_sc_reg2_a = (i_p2b_sc_reg2_nwb_a & 
                             ((i_p3_wb_req_a & 
                               i_p3_destination_en_iv_a)
                              | 
                              (x_multic_wben & 
                               XT_MULTIC_OP))); 

 
// Detect a returning load causing a shortcut.
//
// A returning load will require a shortcut if:
//
//  a. The load target register matches a valid register in stage 2B.
//
//  b. The register is allowed to shortcut.
//
//  c. An extension core register with shortcutting disabled is not
//     being accessed.
//
//  d. The machine is running.
//
// A returning load cannot coincide with a register shortcut on the
// same source register since the load/store unit would stall the
// writing instruction at stage 2b, since a load would be pending on
// the register.
//
// !4p! Systems using a 4p register file use exactly the same logic as
// !4p! 3p regfile systems here. This is because the returning load
// !4p! will be stalling the pipeline, so must be shortcut through to
// !4p! stage 2b. The data will be written into the register file using
// !4p! the path appropriate for a 3p/4p register file system.
//

   assign i_p2b_sc_load1_a = regadr_eq_src1 
                             & (~(x_p2nosc1 & XT_COREREG))
                             ;
   assign i_p2b_sc_load2_a = regadr_eq_src2 
                             & (~(x_p2nosc2 & XT_COREREG))
                             ;

// Detect a returning load to a non-shortcuttable register, which
// would otherwise cause a shortcut. We want to stall stage 2b under
// this condition.
//
// This would be the case when:
//
//  a. The target register matches a valid register being used in
//     stage 2b.
//
//  b. The target register is not shortcuttable - either from
//     f_shcut() or from x_p2nosc1/2
//
//  c. A load is returning, and load-shortcutting is enabled.
//
// !4p! In the case of a 4-port register file, all r0-r31 writes are
// !4p! shortcuttable registers, so will always use the normal
// !4p! writeback path, rather than the direct path. Hence we do not
// !4p! need to alter this logic.
//
   // Returning load no-shortcut onto source 1.
   //
   assign i_p2b_ld_nsc1_a = regadr_eq_src1 & x_p2nosc1; 

   //  Returning load no-shortcut onto source 2.
   // 
   assign i_p2b_ld_nsc2_a = regadr_eq_src2 & x_p2nosc2; 

   //  Combine source 1 and source 2 stall signals.
   // 
   assign i_p2b_ld_nsc_a = (i_p2b_ld_nsc1_a | i_p2b_ld_nsc2_a) &  XT_COREREG; 
  
//------------------------------------------------------------------------------
//  Stall Shortcut to Jcc [Rn]
//------------------------------------------------------------------------------
//
// A common critical path in builds ends at the program counter.
// When there are long extension instruction paths present, the p3result
// signal can arrive very late. It is therefore not helpful to have a
// shortcut path to the program counter which is dependent on the ALU
// result.
//
// Here the ALU and Program counter logic have been adjusted such that
// they do not have a shortcut path from extension ALU results to the
// program counter.
//
// We must therefore generate a stage 2b stall when:
//
//   i. There is a Jump or Jump-and-link in stage 2b
//  ii. A stage 3->2b register shortcut has been detected
// iii. There is an operation in stage 3
//
// Currently, the stall will not occur if either the instruction in
// stage 3 will not write back, or if the jump in stage 2b will not be
// taken. This is clearly the best case, but we may have to extend the
// stall to more conditions if we want to reduce the logic depth.
//
   assign i_p2b_jcc_sc_stall_a = (i_p2b_jmp_niv_a            & 
                                  ((i_p2b_sc_reg2_nwb_a      &
                                    i_p3_destination_en_iv_a &
                                    i_p3_wb_instr_a)        | 
                                    i_p2b_sc_load2_a)); 
                          
//------------------------------------------------------------------------------
// Stage 2b flag setting calculation
//------------------------------------------------------------------------------  
//
   // p2bsetflags just comes from bit 16 of the instruction word. 
   //
   assign i_p2b_flag_bit_r = i_p2b_iw_r[SETFLGPOS]; 

//------------------------------------------------------------------------------  
// Branch Protection System
//------------------------------------------------------------------------------  
// 
//  In order to generate the stall, we also need to detect a valid
//  branch instruction present in stage 2 (i_p2_branch_cc_a).
// 
//  We generate a stall when the two conditions are present together:
// 
//   a. An instruction in stage 3 is attempting to set the flags
//   b. A branch instruction at stage 2 needs to use these new flags
// 
//  Note that it would be possible to detect the following conditions
//  to give theoretical improvements in performance. These are very
//  marginal, and have been left out here for the sake of simplicity,
//  and the fact it would be difficult for the compiler to take
//  advantage of these optimisations. Both cases remove the link
//  between setting the flags and the following branch, either because
//  the flags don't get set, or because the branch doesn't check the
//  flags.
// 
//   i. Conditional flag set instruction at stage 3 does not set flags
//       e.g.  add.cc.f r0,r0,r0, resulting in C=1
// 
//  ii. Branch at stage 2 uses the AL (always) condition code.
// 
   assign i_p2b_jump_holdup_a = (//  p3 setting flags
                                 i_p3_bch_flagset_a & 
                                 //  branch in p2
                                 i_p2b_jmp_cc_a); 

//------------------------------------------------------------------------------
// Stage 2b Instruction Valid
//------------------------------------------------------------------------------
//
// This signal is only true when the data held on p2iw is a valid instruction
// and should be treated as such.  The instruction may not be valid for a
// number of reasons which are stated below:
//
// (1) There is no instruction in the stage due to separation of instructions
//     caused by the stage earlier being held up whilst stage 2b is allowed to
//     continue.
// (2) The instruction that has just entered the stage is not part of the ISA
//     or an extension.
// (3) Stage 2 instruction is to be killed by control transfer instruction.
// (4) The branch in stage 2 did not take the branch.
// (5) Stage 2b is being killed by a control transfer (brcc) and the stage is
//     stalled.
//                          
   assign i_p2b_iv_nxt = (((i_p2b_enable_a == 1'b 1) & (i_p2_enable_a == 1'b 0))
                          | 
                          ((i_p2_no_arc_or_ext_instr_a == 1'b 1) &
                           (i_p2_enable_a == 1'b 1)) 
                          | 
                          ((i_kill_p2_en_a == 1'b 1) & (i_p2_enable_a == 1'b 1)) 
                          | 
                          ((i_p2_nojump_a == 1'b 1) & (i_p2_enable_a == 1'b 1)) 
                          | 
                          ((i_p4_kill_p2b_a == 1'b 1) &
                           (i_p2b_enable_a == 1'b 0))) ? 
          1'b 0 : 
                         ((i_p2b_enable_a == 1'b 0) & (i_p2b_iv_r == 1'b 1)) ? 
          1'b 1 : 
                         ((i_p2b_enable_a == 1'b 0) &
                          (i_p2_enable_a == 1'b 0)) ? 
          i_p2b_iv_r : 
          i_p2_iv_r; 

   always @(posedge clk or posedge rst_a)
   begin : p2b_iv_sync_PROC
      if (rst_a == 1'b 1)
      begin
        i_p2b_iv_r <= 1'b 0;   
      end
      else
      begin
        i_p2b_iv_r <= i_p2b_iv_nxt;   
      end
   end

//------------------------------------------------------------------------------
// Stage 2b Pipeline Stalls
//------------------------------------------------------------------------------
//
   // Hold up stalls are enforced when:
   //
   // (1) An extension instruction wants to hold up the pipeline.
   // (2) The Load Scoreboard Unit (lsu) is holding the stage due to a register
   //     interlock on an outstanding load destination.
   // (3) A flag setting instruction is stage 3 and a conditional jump is in
   //     stage 2b.
   // (4) There is a returning load to a non-shortcuttable register occurring
   // (5) Jumps through registers are not shortcuttable so a stall is enforced
   //     upon detection of the condition.
   //
   assign i_p2b_holdup_stall_a = ((xholdup2b & XT_ALUOP) | 
                                  holdup2b               | 
                                  (i_p2b_jump_holdup_a   | 
                                   i_p2b_ld_nsc_a        | 
                                   i_p2b_jcc_sc_stall_a) & 
                                  i_p2b_iv_r); 

   assign i_p2b_pwr_save_stall_a = (~i_p2b_iv_r) & (~p2bint); 

   assign i_p2b_enable_a = ((i_p2b_en_nopwr_save_a == 1'b 0) | 
                            (i_p2b_pwr_save_stall_a    == 1'b 1)) ?
          1'b 0 : 
          1'b 1; 

   assign i_p2b_en_nopwr_save_a = ((en                       == 1'b 0) | 
                                       (i_p3_enable_nopwr_save_a == 1'b 0) | 
                                       (i_p2b_limm_dslot_stall_r == 1'b 1) | 
                                       (i_p2b_holdup_stall_a     == 1'b 1)) ?
          1'b 0 : 
          1'b 1; 



//------------------------------------------------------------------------------
// Program Counter Enable
//------------------------------------------------------------------------------
//
// The program counter enable is set true when there is an instruction moving
// from stage1 to stage 2b or if there is a control transfer occurring.  For
// static timing reasons a simple expression including the above statements
// could not be used.    
//
   // Program counter enable with late arriving ivalid_aligned signal included.
   // This signal should not be used for timing critical expressions.
   //
   assign i_pcen_a = i_pcen_non_iv_a & ivalid_aligned; 


   // This signal contains part of stage 1 stalls that will prevent the PC from
   // being updated.
   // 
   assign i_pcen_p1_a = ((i_p1_ct_int_loop_stall_a |
                          i_p1_zero_loop_stall_a) &  
                         i_no_pc_stall_a);

   assign i_no_pc_stall_a = 
                         // Dont disable the PC due to a stage 1 stall if
                         // a control transfer wants to change the PC.
                         //
                         (~(i_p2_dorel_a             | 
                           i_p2b_brcc_pred_nxt      | 
                           i_p2b_dojcc_a            | 
                           i_p4_docmprel_a          | 
                           i_p2b_limm_dslot_stall_r | 
                           pcounter_jmp_restart_r)); 

   // Holds the interrupt in stage 2 when there is a hit to the loopend 
   // whilst there is an instruction in stage 3 that is writing to either 
   // LP_COUNT, LP_END or LP_START.
   // This ensures the PC gets updated correctly with the interrupt vector
   // address.
   //  
   assign i_hold_int_st2_a = i_p1_zero_loop_stall_a & i_no_pc_stall_a;
 
   // This signal contains part of stage 2 stalls that will prevent the PC from
   // being updated.
   //                    
   assign i_pcen_p2_a = (i_p2_holdup_stall_a         | 
                         i_p2_ct_brcc_stall_a        | 
                         i_p2_brk_sleep_swi_a |
                         i_p2_instr_err_stall_a) &               

                        // This is needed to prevent the pcen signal from
                        // being disabled when there is a flag setting jump in
                        // stage 2b and a conditional branch in stage 2 LIMM
                        // and delay slot stalls do not disable the PC as the
                        // data that is being waited for needs to be able to
                        // update the PC correctly.
                        //
                        (~(i_p2b_dojcc_a | 
                          i_p4_docmprel_a | 
                          i_p2b_limm_dslot_stall_r |
                          pcounter_jmp_restart_r)); 

   // Limm and dslot stalls do not disable the PC as the data that is being
   // waited for needs to be able to update the PC correctly.
   //
   assign i_pcen_p2b_a = (i_p2b_holdup_stall_a &

                          // Don't disable the PC when there is a stall in stage
                          // 2, 2b or 3 and a BRcc or a bubble squash will 
                          // update the PC.
                          //
                          (~(i_p4_docmprel_a          | 
                            i_p2b_limm_dslot_stall_r |
                            pcounter_jmp_restart_r))); 

   // Don't disable the PC when there is a stall in stage
   // 2, 2b or 3 and a brcc or a bubble squash will update the PC
   //
   assign i_pcen_p3_a = (i_p3_multic_wben_stall_a | 
                         i_p3_load_stall_a        | 
			 i_p3_sync_stalls_pipe_a  |
                         i_p3_holdup_stall_a) & 

                        // Don't disable the PC when there is a stall in stage
                        // 2, 2b or 3 and a brcc or a bubble squash will update
                        // the PC.
                        //
                        (~(i_p4_docmprel_a | 
                          i_p2b_limm_dslot_stall_r |
                          pcounter_jmp_restart_r)); 

   // As mwait is late arriving. The logic is designed to cause mwait to be used
   // as late as possible.
   //
   assign i_pcen_mwait_a = (mwait & 
                            (~(i_p4_docmprel_a          | 
                              i_p2b_limm_dslot_stall_r | 
                              pcounter_jmp_restart_r))); 

   // Combine all the stall signals from all the stages including the
   // instruction stepping PC disable.
   //
   assign i_pcen_non_iv_a = ((i_pcen_mwait_a    == 1'b 1) | 
                             (i_pcen_p1_a       == 1'b 1) | 
                             (i_pcen_p2_a       == 1'b 1) | 
                             (i_pcen_p2b_a      == 1'b 1) | 
                             (i_pcen_p3_a       == 1'b 1) | 
                             (i_inst_stepping_a == 1'b 1) | 
                             (en                == 1'b 0) ) ? 1'b 0 : 
          1'b 1; 

 
//------------------------------------------------------------------------------
// PC Disable for Single Instruction Step
//------------------------------------------------------------------------------
//
   // Instruction Stepping
   //
   // The signal i_inst_stepping prevents the PC from being updated, by
   // disabling the PC enable signal (pcen). The signal is set when a
   // single instruction step is being performed and the PC does not
   // need to be updated (i_pcen_step = '0').
   //
   assign i_inst_stepping_a = do_inst_step_r & (~i_pcen_step_a); 


   // The signal i_pcen_step is set when a single instruction step is
   // being executed if the PC needs to be updated. This happens in the
   // following cases:
   //
   // (1) A valid instruction in stage one is allowed to pass into stage 2.
   // (2) An interrupt has been detected and is now in stage 2.
   // (3) The instruction in the pipeline requires a:
   //    (i) Delay-slot
   //   (ii) Long immediate data
   // (4) The branch in stage 2 is updating the PC.
   // (5) The compare&branch is predicting in stage 2 and is updating the PC
   // (6) The jump in stage 2b is updating the PC
   // (7) The compare&branch in stage 4 is updating the PC
   // (8) There is a delayed control-transfer underway
   //
   assign i_pcen_step_a = ((do_inst_step_r == 1'b 1) &
                           (i_p2_step_a    == 1'b 0) | 
                           (p2int          == 1'b 1) | 
                           (i_p2_step_a    == 1'b 1) & 
                           ((i_p2_has_dslot_a        == 1'b 1) | 
                            (i_p2_long_immediate_a   == 1'b 1) | 
                            (i_p2_tag_nxt_p1_limm_r  == 1'b 1) | 
                            (i_p2_tag_nxt_p1_dslot_r == 1'b 1) | 
                            (i_p2_dorel_a            == 1'b 1) | 
                            (i_p2b_brcc_pred_nxt     == 1'b 1) | 
                            (i_p2b_dojcc_a           == 1'b 1) | 
                            (i_p4_docmprel_a         == 1'b 1) | 
                            (pcounter_jmp_restart_r  == 1'b 1))) ? 
          1'b 1 : 
          1'b 0; 
          
//------------------------------------------------------------------------------
// Stage 3 pre-latch decode
//------------------------------------------------------------------------------
//
   // This signal is set true for operations that require a writeback to the
   // register file and are conditional.
   //
   always @(i_p2b_opcode_r or i_p2b_subopcode_r or i_p2b_subopcode2_r or 
         i_p2b_subopcode3_r or i_p2b_subopcode7_r or i_p2b_a_field_r)
    begin : ccwbop_PROC

      case (i_p2b_opcode_r) 
        OP_FMT1:
         begin
            case (i_p2b_subopcode_r) 
             SO_ADD,  SO_ADC,  SO_SUB,  SO_SBC, 
             SO_AND,  SO_OR,   SO_BIC,  SO_XOR, 
             SO_MAX,  SO_MIN,  SO_MOV,  SO_BSET, 
                 SO_BCLR, SO_BMSK, SO_BXOR, SO_ADD1,
                 SO_ADD2, SO_ADD3, SO_SUB1, SO_SUB2, 
                 SO_SUB3, SO_RSUB:
               begin
                 i_p3_ccwbop_decode_nxt = 1'b 1;   
               end
             SO_SOP:
               begin
                 if (i_p2b_a_field_r == MO_ZOP)
                  begin
                     i_p3_ccwbop_decode_nxt = 1'b 0;   
                  end
                 else
                  begin
                     i_p3_ccwbop_decode_nxt = 1'b 1;   
                  end
               end
             default:
               begin
                 i_p3_ccwbop_decode_nxt = 1'b 0;   
               end
            endcase
         end
        OP_16_LD_ADD:
         begin
            case (i_p2b_subopcode2_r[SUBOPCODE_MSB_1:SUBOPCODE_MSB_2])
             SO16_ADD:
               begin
                 i_p3_ccwbop_decode_nxt = 1'b 1;   
               end
             default:
               begin
                 i_p3_ccwbop_decode_nxt = 1'b 0;   
               end
            endcase
         end
        OP_16_MV_ADD:
         begin
            if (i_p2b_subopcode_r[SUBOPCODE_MSB_1:SUBOPCODE_MSB_2] == SO16_CMP)
             begin
               i_p3_ccwbop_decode_nxt = 1'b 0;   
             end
            else
             begin
               i_p3_ccwbop_decode_nxt = 1'b 1;   
             end
         end
        OP_16_ARITH, OP_16_MV:
         begin
            i_p3_ccwbop_decode_nxt = 1'b 1;   
         end
        OP_16_ALU_GEN:
         begin
            case (i_p2b_subopcode2_r) 
             SO16_SUB_REG, SO16_AND,   SO16_OR, 
             SO16_BIC,     SO16_XOR,   SO16_SEXB, 
                 SO16_SEXW,    SO16_EXTB,  SO16_EXTW, 
                 SO16_ABS,     SO16_NOT,   SO16_NEG, 
                 SO16_ADD1,    SO16_ADD2,  SO16_ADD3,
                 SO16_ASL_M,   SO16_LSR_M, SO16_ASR_M, 
                 SO16_ASL_1,   SO16_ASR_1, SO16_LSR_1:
               begin
                 i_p3_ccwbop_decode_nxt = 1'b 1;   
               end
             SO16_SOP:
               begin
                 if (i_p2b_subopcode3_r == SO16_SOP_SUB)
                  begin
                     i_p3_ccwbop_decode_nxt = 1'b 1;   
                  end
                 else
                  begin
                     i_p3_ccwbop_decode_nxt = 1'b 0;   
                  end
               end
             default:
               begin
                 i_p3_ccwbop_decode_nxt = 1'b 0;   
               end
            endcase
         end
        OP_16_SSUB:
         begin
            if (i_p2b_subopcode3_r == SO16_BTST_U5)
             begin
               i_p3_ccwbop_decode_nxt = 1'b 0;   
             end
            else
             begin
               i_p3_ccwbop_decode_nxt = 1'b 1;   
             end
         end
        OP_16_SP_REL:
         begin
            case (i_p2b_subopcode3_r) 
             SO16_ADD_SP, SO16_SUB_SP, SO16_POP_U7, SO16_PUSH_U7:
               begin
                 i_p3_ccwbop_decode_nxt = 1'b 1;   
               end
             default:
               begin
                 i_p3_ccwbop_decode_nxt = 1'b 0;   
               end
            endcase
         end
        OP_16_GP_REL:
         begin
            if (i_p2b_subopcode7_r == SO16_ADD_GP)
             begin
               i_p3_ccwbop_decode_nxt = 1'b 1;   
             end
            else
             begin
               i_p3_ccwbop_decode_nxt = 1'b 0;   
             end
         end
        OP_16_ADDCMP:
         begin
            if (i_p2b_subopcode3_r[SUBOPCODE3_16_MSB] == SO16_ADD_U7)
             begin
               i_p3_ccwbop_decode_nxt = 1'b 1;   
             end
            else
             begin
               i_p3_ccwbop_decode_nxt = 1'b 0;   
             end
         end
        default:
         begin
            i_p3_ccwbop_decode_nxt = 1'b 0;   
         end
      endcase
    end    

//  Used in the EX stage for condition checking
//  
   assign i_p3_alu16_condtrue_nxt = (i_p2b_opcode_16_ld_add_a | 
                                     i_p2b_opcode_16_mov_a    | 
                                      i_p2b_opcode_16_arith_a  | 
                                      i_p2b_opcode_16_mv_add_a | 
                                      i_p2b_opcode_16_ld_u7_a  | 
                                      i_p2b_opcode_16_ldb_u5_a | 
                                      i_p2b_opcode_16_ldw_u6_a | 
                                      i_p2b_opc_16_ldwx_u6_a | 
                                      i_p2b_opcode_16_st_u7_a  | 
                                      i_p2b_opcode_16_stb_u5_a | 
                                      i_p2b_opcode_16_stw_u6_a | 
                                      i_p2b_opcode_16_ssub_a   | 
                                      i_p2b_opcode_16_sp_rel_a | 
                                      i_p2b_opcode_16_gp_rel_a | 
                                      i_p2b_opcode_16_ld_pc_a  | 
                                      i_p2b_opcode_16_addcmp_a | 
                                      i_p2b_opcode_16_alu_a   & 
                                      ((~i_p2b_subop_16_brk_a)  & 
                                       (~i_p2b_subop_16_sop_a))); 
  
   // Decode for type of operation that is entering the basecase ALU. This
   // signal partially controls the ALU to generate the correct result.
   //
   always @(i_p2b_minoropcode_r or i_p2b_opcode_r or 
            i_p2b_br_bl_subopcode_r or i_p2b_subopcode1_r or 
            i_p2b_subopcode2_r or i_p2b_subopcode3_r or 
            i_p2b_subopcode4_r or p2bint or i_p2b_subopcode_r or 
            i_p2b_b_field16_r)

    begin : op_decode_async_PROC

      i_p3_alu_arithiv_nxt  = 1'b 1;   
      i_p3_alu_logiciv_nxt  = 1'b 0;   
      i_p3_alu_snglopiv_nxt = 1'b 0;   
      i_p3_alu_absiv_nxt    = 1'b 0;   
      i_p3_alu_negiv_nxt    = 1'b 0;   
      i_p3_alu_notiv_nxt    = 1'b 0;   
      i_p3_alu_op_nxt       = SUBOP_SBC;   
      i_p3_alu_brne16_nxt   = 1'b 0;   
      i_p3_alu_breq16_nxt   = 1'b 0;   
      i_p3_alu_min_nxt      = 1'b 0;   
      i_p3_alu_max_nxt      = 1'b 0;   

      case (i_p2b_opcode_r) 
        OP_BLCC:
         begin
            case (i_p2b_br_bl_subopcode_r)
             SO_BCC_BBIT0, SO_BCC_BBIT1:
               begin
                 i_p3_alu_op_nxt = SUBOP_ADD;   
                 i_p3_alu_arithiv_nxt = 1'b 0;   
                 i_p3_alu_logiciv_nxt = 1'b 1;   
               end
             default:
               begin
                 i_p3_alu_op_nxt = SUBOP_SUB;   
                 i_p3_alu_arithiv_nxt = 1'b 1;   
               end
            endcase
         end
        OP_LD, OP_ST, OP_16_LD_U7, OP_16_LDB_U5, 
        OP_16_LDW_U6, OP_16_LDWX_U6, OP_16_ST_U7,
        OP_16_STB_U5, OP_16_STW_U6, OP_16_LD_ADD, 
        OP_16_GP_REL, OP_16_LD_PC, OP_16_BCC:
         begin
            i_p3_alu_op_nxt = SUBOP_ADD;   
         end
        OP_16_ARITH:
         begin
            case (i_p2b_subopcode1_r) 
             SO16_SUB_U3:
               begin
                 i_p3_alu_op_nxt = SUBOP_SUB;   
               end
             SO16_ADD_U3:
               begin
                 i_p3_alu_op_nxt = SUBOP_ADD;   
               end
             default:
               begin
                 i_p3_alu_op_nxt = SUBOP_SUB;   
                 i_p3_alu_arithiv_nxt = 1'b 0;   
                 i_p3_alu_snglopiv_nxt = 1'b 1;   
               end
            endcase
         end
        OP_16_MV_ADD:
         begin
            case (i_p2b_subopcode1_r) 
             SO16_CMP:
               begin
                 i_p3_alu_op_nxt = SUBOP_SUB;   
               end
             SO16_ADD_HI:
               begin
                 i_p3_alu_op_nxt = SUBOP_ADD;   
               end
             default:
               begin
                 i_p3_alu_op_nxt = OP_AND;   
                 i_p3_alu_arithiv_nxt = 1'b 0;   
                 i_p3_alu_logiciv_nxt = 1'b 1;   
               end
            endcase
         end
        OP_FMT1:
         begin
            case (i_p2b_subopcode_r)  
             SO_J, SO_J_D, SO_JL, SO_JL_D:
               begin
                 i_p3_alu_arithiv_nxt = 1'b 0;   
                 i_p3_alu_logiciv_nxt = 1'b 0;   
               end
             SO_AND, SO_MOV, SO_BTST, SO_BMSK, SO_TST:
               begin
                 i_p3_alu_op_nxt = SUBOP_ADD;   
                 i_p3_alu_arithiv_nxt = 1'b 0;   
                 i_p3_alu_logiciv_nxt = 1'b 1;   
               end
             SO_ADD, SO_ADD1, SO_ADD2,  SO_ADD3, 
             SO_LD,  SO_LDB,  SO_LDB_X, SO_LDW, 
             SO_LDW_X:
               begin
                 i_p3_alu_op_nxt = SUBOP_ADD;   
               end
             SO_ADC:
               begin
                 i_p3_alu_op_nxt = SUBOP_ADC;   
               end
             SO_OR, SO_BSET:
               begin
                 i_p3_alu_op_nxt = SUBOP_ADC;   
                 i_p3_alu_arithiv_nxt = 1'b 0;   
                 i_p3_alu_logiciv_nxt = 1'b 1;   
               end
             SO_SUB, SO_SUB1, SO_SUB2, SO_SUB3, 
             SO_CMP, SO_RSUB, SO_RCMP:
               begin
                 i_p3_alu_op_nxt = SUBOP_SUB;   
               end
             SO_BIC, SO_BCLR:
               begin
                 i_p3_alu_op_nxt = SUBOP_SUB;   
                 i_p3_alu_arithiv_nxt = 1'b 0;   
                 i_p3_alu_logiciv_nxt = 1'b 1;   
               end
             SO_MIN:
               begin
                 i_p3_alu_op_nxt = SUBOP_SUB;   
                 i_p3_alu_arithiv_nxt = 1'b 1;   
                 i_p3_alu_min_nxt = 1'b 1;   
                 i_p3_alu_max_nxt = 1'b 0;   
               end
             SO_MAX:
               begin
                 i_p3_alu_op_nxt = SUBOP_SUB;   
                 i_p3_alu_arithiv_nxt = 1'b 1;   
                 i_p3_alu_min_nxt = 1'b 0;   
                 i_p3_alu_max_nxt = 1'b 1;   
               end
             SO_SBC:
               begin
                 i_p3_alu_op_nxt = SUBOP_SBC;   
               end
             SO_SOP:
               begin
                 i_p3_alu_arithiv_nxt = 1'b 0;   
                 case (i_p2b_minoropcode_r)  
                  MO_ABS:
                    begin
                      i_p3_alu_op_nxt = SUBOP_ADD;   
                      i_p3_alu_absiv_nxt = 1'b 1;   
                      i_p3_alu_arithiv_nxt = 1'b 1;   
                      i_p3_alu_snglopiv_nxt = 1'b 0;   
                    end
                  MO_ASL, MO_ASR:
                    begin
                      i_p3_alu_op_nxt = SUBOP_SUB;   
                      i_p3_alu_snglopiv_nxt = 1'b 1;   
                    end
                  MO_RLC:
                    begin
                      i_p3_alu_op_nxt = SUBOP_ADC;   
                      i_p3_alu_snglopiv_nxt = 1'b 1;   
                    end
                  MO_RRC, MO_SEXB, MO_SEXW, MO_EXTB, MO_EXTW:
                    begin
                      i_p3_alu_op_nxt = SUBOP_ADC;   
                      i_p3_alu_snglopiv_nxt = 1'b 1;   
                    end
                  MO_NOT:
                    begin
                      i_p3_alu_op_nxt = SUBOP_SBC;   
                      i_p3_alu_notiv_nxt = 1'b 1;   
                      i_p3_alu_snglopiv_nxt = 1'b 1;   
                    end
                  MO_LSR, MO_ROR:
                    begin
                      i_p3_alu_snglopiv_nxt = 1'b 1;   
                    end
                  default:
                    begin
                      i_p3_alu_op_nxt = SUBOP_SUB;   
                      i_p3_alu_arithiv_nxt = 1'b 0;   
                    end
                 endcase
               end
             SO_LR:
               begin
                 i_p3_alu_arithiv_nxt = 1'b 0;   
               end
             default:
               begin
                 //  xor
                 i_p3_alu_op_nxt = SUBOP_SBC;   
                 i_p3_alu_arithiv_nxt = 1'b 0;   
                 i_p3_alu_logiciv_nxt = 1'b 1;   
               end
            endcase
         end
        OP_16_ALU_GEN:
         begin
            case (i_p2b_subopcode2_r) 
             SO16_SOP:
               begin
                 if (i_p2b_subopcode3_r == SO16_SOP_SUB)
                  begin
                     i_p3_alu_op_nxt = SUBOP_SUB;   
                  end
                 else
                  begin
                     i_p3_alu_arithiv_nxt = 1'b 0;   
                  end
               end
             SO16_SUB_REG:
               begin
                 i_p3_alu_op_nxt = SUBOP_SUB;   
               end
             SO16_NEG:
               begin
                 i_p3_alu_op_nxt = SUBOP_SUB;   
                 i_p3_alu_negiv_nxt = 1'b 1;   
               end
             SO16_ABS:
               begin
                 i_p3_alu_op_nxt = SUBOP_ADD;   
                 i_p3_alu_absiv_nxt = 1'b 1;   
               end
             SO16_BIC:
               begin
                 i_p3_alu_op_nxt = SUBOP_SUB;   
                 i_p3_alu_arithiv_nxt = 1'b 0;   
                 i_p3_alu_logiciv_nxt = 1'b 1;   
               end
             SO16_AND, SO16_TST:
               begin
                 i_p3_alu_op_nxt = SUBOP_ADD;   
                 i_p3_alu_arithiv_nxt = 1'b 0;   
                 i_p3_alu_logiciv_nxt = 1'b 1;   
               end
             SO16_ADD1, SO16_ADD2, SO16_ADD3:
               begin
                 i_p3_alu_op_nxt = SUBOP_ADD;   
               end
             SO16_OR:
               begin
                 i_p3_alu_op_nxt = SUBOP_ADC;   
                 i_p3_alu_arithiv_nxt = 1'b 0;   
                 i_p3_alu_logiciv_nxt = 1'b 1;   
               end
             SO16_SEXB, SO16_SEXW, SO16_EXTB, SO16_EXTW:
               begin
                 i_p3_alu_op_nxt = SUBOP_ADC;   
                 i_p3_alu_arithiv_nxt = 1'b 0;   
                 i_p3_alu_snglopiv_nxt = 1'b 1;   
               end
             SO16_XOR:
               begin
                 i_p3_alu_op_nxt = SUBOP_SBC;   
                 i_p3_alu_arithiv_nxt = 1'b 0;   
                 i_p3_alu_logiciv_nxt = 1'b 1;   
               end
             default:
               begin
                 i_p3_alu_op_nxt = SUBOP_SBC;   
                 i_p3_alu_arithiv_nxt = 1'b 0;   
                 i_p3_alu_snglopiv_nxt = 1'b 1;   
               end
            endcase
         end
        OP_16_SSUB:
         begin
            case (i_p2b_subopcode3_r) 
             SO16_SUB_U5:
               begin
                 i_p3_alu_op_nxt = SUBOP_SUB;   
               end
             SO16_BCLR_U5:
               begin
                 i_p3_alu_op_nxt = SUBOP_SUB;   
                 i_p3_alu_arithiv_nxt = 1'b 0;   
                 i_p3_alu_logiciv_nxt = 1'b 1;   
               end
             SO16_BSET_U5:
               begin
                 i_p3_alu_op_nxt = SUBOP_ADC;   
                 i_p3_alu_arithiv_nxt = 1'b 0;   
                 i_p3_alu_logiciv_nxt = 1'b 1;   
               end
             default:
               begin
                 i_p3_alu_op_nxt = SUBOP_ADD;   
                 i_p3_alu_arithiv_nxt = 1'b 0;   
                 i_p3_alu_logiciv_nxt = 1'b 1;   
               end
            endcase
         end
        OP_16_SP_REL:
         begin
            case (i_p2b_subopcode3_r) 
             SO16_LD_SP, SO16_LDB_SP, SO16_ST_SP, 
             SO16_STB_SP, SO16_ADD_SP, SO16_POP_U7, 
             SO16_PUSH_U7:
               begin
                 i_p3_alu_op_nxt = SUBOP_ADD;   
               end
             SO16_SUB_SP:
               begin
                 case (i_p2b_b_field16_r) 
                  THREE_ZERO:
                    begin
                      i_p3_alu_op_nxt = SUBOP_ADD;   
                    end
                  default:
                    begin
                      i_p3_alu_op_nxt = SUBOP_SUB;   
                    end
                 endcase
               end
             default:
               begin
                 i_p3_alu_op_nxt = SUBOP_SUB;   
               end
            endcase
         end
        OP_16_BRCC:
         begin
            i_p3_alu_op_nxt = SUBOP_SUB;   
            if (i_p2b_subopcode4_r == SO16_BREQ_S8)
             begin
               i_p3_alu_brne16_nxt = 1'b 0;   
               i_p3_alu_breq16_nxt = 1'b 1;   
             end
            if (i_p2b_subopcode4_r == SO16_BRNE_S8)
             begin
               i_p3_alu_brne16_nxt = 1'b 1;   
               i_p3_alu_breq16_nxt = 1'b 0;   
             end
         end
        OP_16_MV:
         begin
            i_p3_alu_op_nxt = SUBOP_ADD;   
            i_p3_alu_arithiv_nxt = 1'b 0;   
            i_p3_alu_logiciv_nxt = 1'b 1;   
         end
        OP_16_ADDCMP:
         begin
            case (i_p2b_subopcode4_r) 
             SO16_ADD_U7:
               begin
                 i_p3_alu_op_nxt = SUBOP_ADD;   
               end
             default:
               begin
                 i_p3_alu_op_nxt = SUBOP_SUB;   
               end
            endcase
         end
        default:
         begin
            i_p3_alu_op_nxt = SUBOP_SBC;   
            i_p3_alu_arithiv_nxt = 1'b 0;   
         end
      endcase

      if (p2bint == 1'b 1)
        begin
          i_p3_alu_arithiv_nxt  = 1'b 0;   
          i_p3_alu_logiciv_nxt  = 1'b 0;   
          i_p3_alu_snglopiv_nxt = 1'b 0;   
          i_p3_alu_absiv_nxt    = 1'b 0;   
          i_p3_alu_negiv_nxt    = 1'b 0;   
          i_p3_alu_notiv_nxt    = 1'b 0;   
          i_p3_alu_op_nxt       = SUBOP_SBC;   
          i_p3_alu_brne16_nxt   = 1'b 0;   
          i_p3_alu_breq16_nxt   = 1'b 0;   
          i_p3_alu_min_nxt      = 1'b 0;   
          i_p3_alu_max_nxt      = 1'b 0;   
        end

    end
   
   assign i_p3_ashift_right_nxt = ((i_p2b_opcode_32_fmt1_a == 1'b 1) & 
                           (i_p2b_minoropcode_r == MO_ASR) | 
                           (i_p2b_opcode_16_alu_a == 1'b 1) & 
                           (i_p2b_subopcode2_r == SO16_ASR_1)) ? 1'b 1 : 
        1'b 0; 

   assign i_p3_sop_op_nxt_sel0_a = (((i_p2b_opcode_32_fmt1_a == 1'b 1) & 
                            ((i_p2b_minoropcode_r == MO_LSR) | 
                             (i_p2b_minoropcode_r == MO_ROR) | 
                             (i_p2b_minoropcode_r == MO_RRC))) 
                           | 
                           ((i_p2b_opcode_16_alu_a == 1'b 1) & 
                            (i_p2b_subopcode2_r == SO16_LSR_1)) 
                           | 
                           ((i_p3_ashift_right_nxt == 1'b 1))) ? 1'b 1 : 
        1'b 0; 

   assign i_p3_sop_op_nxt_sel1_a = (((i_p2b_opcode_32_fmt1_a == 1'b 1) & 
                            ((i_p2b_minoropcode_r == MO_ASL) | 
                             (i_p2b_minoropcode_r == MO_RLC))) 
                           | 
                           ((i_p2b_opcode_16_arith_a == 1'b 1) & 
                            (i_p2b_subopcode1_r == SO16_ASL))
                           |
                           ((i_p2b_opcode_16_alu_a == 1'b 1) & 
                            (i_p2b_subopcode2_r == SO16_ASL_M))
                           |
                           ((i_p2b_opcode_16_alu_a == 1'b 1) & 
                            (i_p2b_subopcode2_r == SO16_ASL_1))) ? 1'b 1 : 
        1'b 0; 

   assign i_p3_sop_op_nxt_sel2_a = (((i_p2b_opcode_32_fmt1_a == 1'b 1) & 
                            (i_p2b_minoropcode_r == MO_SEXB))
                           | 
                           ((i_p2b_opcode_16_alu_a == 1'b 1) & 
                            (i_p2b_subopcode2_r == SO16_SEXB))) ? 1'b 1 : 
        1'b 0; 

   assign i_p3_sop_op_nxt_sel3_a = (((i_p2b_opcode_32_fmt1_a == 1'b 1) & 
                            (i_p2b_minoropcode_r == MO_SEXW))
                           | 
                           ((i_p2b_opcode_16_alu_a == 1'b 1) & 
                            (i_p2b_subopcode2_r == SO16_SEXW))) ?  1'b 1 : 
        1'b 0; 

   assign i_p3_sop_op_nxt_sel4_a = (((i_p2b_opcode_32_fmt1_a == 1'b 1) & 
                            (i_p2b_minoropcode_r == MO_EXTB))
                           | 
                           ((i_p2b_opcode_16_alu_a == 1'b 1) & 
                            (i_p2b_subopcode2_r == SO16_EXTB))) ? 1'b 1 : 
        1'b 0; 

   assign i_p3_sop_op_nxt_sel5_a = (((i_p2b_opcode_32_fmt1_a == 1'b 1) & 
                            (i_p2b_minoropcode_r == MO_EXTW))
                           | 
                           ((i_p2b_opcode_16_alu_a == 1'b 1) & 
                            (i_p2b_subopcode2_r == SO16_EXTW))) ?  1'b 1 : 
        1'b 0; 

   assign i_p3_sop_op_nxt_sel6_a = (~(i_p3_sop_op_nxt_sel0_a | 
                            i_p3_sop_op_nxt_sel1_a | 
                            i_p3_sop_op_nxt_sel2_a | 
                            i_p3_sop_op_nxt_sel3_a | 
                            i_p3_sop_op_nxt_sel4_a |
                            i_p3_sop_op_nxt_sel5_a)); 

   // AND-OR Mux
   assign i_p3_sop_op_nxt = (OP_RIGHT_SHIFT & ({(SOPSIZE+1){i_p3_sop_op_nxt_sel0_a}}) 
                      | 
                      OP_LEFT_SHIFT &  ({(SOPSIZE+1){i_p3_sop_op_nxt_sel1_a}}) 
                      | 
                      OP_SEXB &        ({(SOPSIZE+1){i_p3_sop_op_nxt_sel2_a}}) 
                      | 
                      OP_SEXW &        ({(SOPSIZE+1){i_p3_sop_op_nxt_sel3_a}}) 
                      | 
                      OP_EXTB &        ({(SOPSIZE+1){i_p3_sop_op_nxt_sel4_a}}) 
                      | 
                      OP_EXTW &        ({(SOPSIZE+1){i_p3_sop_op_nxt_sel5_a}}) 
                      | 
                      OP_NOT &         ({(SOPSIZE+1){i_p3_sop_op_nxt_sel6_a}})); 

   always @(i_p2b_br_bl_subopcode_r or i_p2b_opcode_r or 
         i_p2b_subopcode_r or i_p2b_subopcode3_r)
    begin : bit_operand_async_PROC

      case (i_p2b_opcode_r) 
        OP_BLCC:
         begin
            case (i_p2b_br_bl_subopcode_r) 
             SO_BCC_BBIT0, SO_BCC_BBIT1:
               begin
                 i_p3_bit_operand_sel_nxt = 2'b 01;   
               end
             default:
               begin
                 i_p3_bit_operand_sel_nxt = 2'b 00;   
               end
            endcase
         end
        OP_FMT1:
         begin
            case (i_p2b_subopcode_r) 
             SO_BSET, SO_BCLR, SO_BTST, SO_BXOR:
               begin
                 i_p3_bit_operand_sel_nxt = 2'b01;   
               end
             SO_BMSK:
               begin
                 i_p3_bit_operand_sel_nxt = 2'b10;   
               end
             default:
               begin
                 i_p3_bit_operand_sel_nxt = 2'b00;   
               end
            endcase
         end
        OP_16_SSUB:
         begin
            case (i_p2b_subopcode3_r[SUBOPCODE3_16_MSB:0]) 
             SO16_BSET_U5, SO16_BCLR_U5, SO16_BTST_U5:
               begin
                 i_p3_bit_operand_sel_nxt = 2'b 01;   
               end
             SO16_BMSK_U5:
               begin
                 i_p3_bit_operand_sel_nxt = 2'b 10;   
               end
             default:
               begin
                 i_p3_bit_operand_sel_nxt = 2'b 00;   
               end
            endcase
         end
        default:
         begin
            i_p3_bit_operand_sel_nxt = 2'b 00;   
         end
      endcase
    end 
   

   assign i_p3_flag_instr_nxt = i_p2b_opcode_32_fmt1_a & 
                                i_p2b_subopcode_flag_a; 

   assign i_p3_shiftin_sel_nxt = (i_p3_ashift_right_nxt == 1'b 1) ?     
          2'b 01 : 
                                 ((i_p2b_opcode_32_fmt1_a == 1'b 1) & 
                                  (i_p2b_minoropcode_r == MO_ROR)) ? 
          2'b 10 : 
                                 ((i_p2b_opcode_32_fmt1_a == 1'b 1) & 
                                 ((i_p2b_minoropcode_r == MO_RLC) | 
                                  (i_p2b_minoropcode_r == MO_RRC))) ? 
          2'b 11 : 
          2'b 00; 
 
//------------------------------------------------------------------------------
// Stage 2b - Stage 3 registers
//------------------------------------------------------------------------------
//
   // The data to be used for input to stage 3 is latched here.
   //
   // Clock in the instruction from stage 2 when the i_enable2_a signal is
   // valid. Note that in stage 3, the instruction is latched in sections,
   // thus ignoring the two reserved bits left in non-short immediate ALU
   // instructions.
   //
   always @(posedge clk or posedge rst_a)
    begin : stage_3_sync_PROC
      if (rst_a == 1'b 1)
        begin
             i_p3_a_field_r              <= {(OPERAND_MSB + 1){1'b 0}};
             i_p3_alu16_condtrue_r       <= 1'b 0;
             i_p3_alu_absiv_r            <= 1'b 0;
             i_p3_alu_arithiv_r          <= 1'b 0;
             i_p3_alu_breq16_r           <= 1'b 0;
             i_p3_alu_brne16_r           <= 1'b 0;
             i_p3_alu_logiciv_r          <= 1'b 0;
             i_p3_alu_max_r              <= 1'b 0;
             i_p3_alu_min_r              <= 1'b 0;
             i_p3_alu_op_r               <= {(TWO){1'b 0}};
             i_p3_alu_snglopiv_r         <= 1'b 0;
             i_p3_awb_field_r            <= {(TWO){1'b 0}};
             i_p3_b_field_r              <= {(OPERAND_MSB + 1){1'b 0}};
             i_p3_bit_operand_sel_r      <= {(TWO){1'b 0}};
             i_p3_br_or_bbit32_r         <= 1'b 0;
             i_p3_br_or_bbit_r           <= 1'b 0;
             i_p3_c_field_r              <= {(OPERAND_MSB + 1){1'b 0}};
             i_p3_ccwbop_decode_r        <= 1'b 0;
             i_p3_dest_imm_r             <= 1'b 0;
             i_p3_dolink_r               <= 1'b 0;
             i_p3_flag_instr_r           <= 1'b 0;
             i_p3_fmt_cond_reg_r         <= 1'b 0;
             i_p3_format_r               <= {(FORMAT_MSB + 1){1'b 0}};
             i_p3_has_dslot_r            <= 1'b 0;
             i_p3_ld_decode_r            <= 1'b 0;
             i_p3_lr_decode_r            <= 1'b 0;
             i_p3_minoropcode_r          <= {(SUBOPCODE_MSB + 1){1'b 0}};
             i_p3_ni_wbrq_predec_r       <= 1'b 0;
             i_p3_nocache_r              <= 1'b 0;
             i_p3_opcode_32_fmt1_r       <= 1'b 0;
             i_p3_opcode_r               <= {(OPCODE_MSB + 1){1'b 0}};
             i_p3_q_r                    <= {(CONDITION_CODE_MSB + 1){1'b 0}};
             i_p3_sc_dest_r              <= {(OPERAND_MSB + 1){1'b 0}};
             i_p3_setflags_r             <= 1'b 0;
             i_p3_sex_r                  <= 1'b 0;
             i_p3_shiftin_sel_r          <= {(TWO){1'b 0}};
             i_p3_size_r                 <= {(TWO){1'b 0}};
             i_p3_sop_op_r               <= {(SOPSIZE + 1){1'b 0}};
             i_p3_sop_sub_r              <= 1'b 0;
             i_p3_special_flagset_r      <= 1'b 0;
             i_p3_sr_decode_r            <= 1'b 0;
             i_p3_st_decode_r            <= 1'b 0;
             i_p3_subopcode1_r           <= {(SUBOPCODE1_16_MSB + 1){1'b 0}};
             i_p3_subopcode2_r           <= {(SUBOPCODE2_16_MSB + 1){1'b 0}};
             i_p3_subopcode3_r           <= {(SUBOPCODE3_16_MSB + 1){1'b 0}};
             i_p3_subopcode4_r           <= 1'b 0;
             i_p3_subopcode5_r           <= {(SUBOPCODE1_16_MSB + 1){1'b 0}};
             i_p3_subopcode6_r           <= {(SUBOPCODE3_16_MSB + 1){1'b 0}};
             i_p3_subopcode7_r           <= {(SUBOPCODE1_16_MSB + 1){1'b 0}};
             i_p3_subopcode_r            <= {(SUBOPCODE_MSB + 1){1'b 0}};
             i_p3_destination_en_r       <= 1'b 0;
             i_p3_brcc_pred_r            <= 1'b 0;
             i_p3_sync_inst_r            <= 1'b 0;
        end
      else
        begin
          if (i_p2b_enable_a == 1'b 1)
            begin
              i_p3_a_field_r              <= i_p2b_a_field_a;   
              i_p3_alu16_condtrue_r       <= i_p3_alu16_condtrue_nxt;   
              i_p3_alu_absiv_r            <= i_p3_alu_absiv_nxt;   
              i_p3_alu_arithiv_r          <= i_p3_alu_arithiv_nxt;   
              i_p3_alu_breq16_r           <= i_p3_alu_breq16_nxt;   
              i_p3_alu_brne16_r           <= i_p3_alu_brne16_nxt;   
              i_p3_alu_logiciv_r          <= i_p3_alu_logiciv_nxt;   
              i_p3_alu_max_r              <= i_p3_alu_max_nxt;   
              i_p3_alu_min_r              <= i_p3_alu_min_nxt;   
              i_p3_alu_op_r               <= i_p3_alu_op_nxt;   
              i_p3_alu_snglopiv_r         <= i_p3_alu_snglopiv_nxt;   
              i_p3_awb_field_r            <= i_p2b_awb_field_a;   
              i_p3_b_field_r              <= i_p2b_b_field_r;   
              i_p3_bit_operand_sel_r      <= i_p3_bit_operand_sel_nxt;   
              i_p3_br_or_bbit32_r         <= i_p2b_br_or_bbit32_r;   
              i_p3_br_or_bbit_r           <= i_p2b_br_or_bbit_r;   
              i_p3_brcc_pred_r            <= i_p2b_brcc_pred_r;   
              i_p3_c_field_r              <= i_p2b_c_field_r;   
              i_p3_ccwbop_decode_r        <= (i_p3_ccwbop_decode_nxt &
                                              ~i_p2b_dest_imm_r);
              i_p3_dest_imm_r             <= i_p2b_dest_imm_r;   
              i_p3_destination_en_r       <= i_p2b_dest_en_iv_a;   
              i_p3_dolink_r               <= i_p3_dolink_nxt;   
              i_p3_flag_instr_r           <= i_p3_flag_instr_nxt;   
              i_p3_fmt_cond_reg_r         <= i_p2b_fmt_cond_reg_a;   
              i_p3_format_r               <= i_p2b_format_r;   
              i_p3_has_dslot_r            <= i_p2b_has_dslot_r;   
              i_p3_ld_decode_r            <= i_p2b_ld_decode_a;   
              i_p3_lr_decode_r            <= i_p2b_lr_decode_a;   
              i_p3_minoropcode_r          <= i_p2b_minoropcode_r;   
              i_p3_ni_wbrq_predec_r       <= (i_p3_ldst_awb_nxt |
                                              i_p3_dolink_nxt |
                                              i_p2b_lr_decode_a);   
              i_p3_nocache_r              <= i_p2b_nocache_a;   
              i_p3_opcode_32_fmt1_r       <= i_p2b_opcode_32_fmt1_a;
              i_p3_opcode_r               <= i_p2b_opcode_r;   
              i_p3_q_r                    <= i_p2b_q_r;   
              i_p3_sc_dest_r              <= i_p3_sc_dest_nxt;   
              i_p3_setflags_r             <= i_p2b_setflags_r;   
              i_p3_sex_r                  <= i_p2b_sex_a;   
              i_p3_shiftin_sel_r          <= i_p3_shiftin_sel_nxt;   
              i_p3_size_r                 <= i_p2b_size_a;   
              i_p3_sop_op_r               <= i_p3_sop_op_nxt;   
              i_p3_sop_sub_r              <= i_p3_sop_sub_nxt;   
              i_p3_special_flagset_r      <= i_p2b_special_flagset_a;
              i_p3_sr_decode_r            <= i_p2b_sr_decode_a;   
              i_p3_st_decode_r            <= i_p2b_st_decode_a;   
              i_p3_subopcode1_r           <= i_p2b_subopcode1_r;   
              i_p3_subopcode2_r           <= i_p2b_subopcode2_r;   
              i_p3_subopcode3_r           <= i_p2b_subopcode3_r;   
              i_p3_subopcode4_r           <= i_p2b_subopcode4_r;   
              i_p3_subopcode5_r           <= i_p2b_subopcode5_r;   
              i_p3_subopcode6_r           <= i_p2b_subopcode6_r;   
              i_p3_subopcode7_r           <= i_p2b_subopcode7_r;   
              i_p3_subopcode_r            <= i_p2b_subopcode_r; 
              i_p3_sync_inst_r            <= i_p2b_sync_inst_r;  
            end
        end
    end 

   assign i_p3_br_or_bbit_iv_a = i_p3_br_or_bbit_r & i_p3_iv_r; 
   assign i_p3_ccwbop_decode_iv_a = i_p3_ccwbop_decode_r & i_p3_iv_r; 
   assign i_p3_dolink_iv_a = i_p3_dolink_r & i_p3_iv_r; 
   assign i_p3_flag_instr_iv_a = i_p3_flag_instr_r & i_p3_iv_r; 
   assign i_p3_sync_instr_iv_a = i_p3_sync_inst_r & i_p3_iv_r;
   assign i_p3_ld_decode_iv_a = i_p3_ld_decode_r & i_p3_iv_r; 
   assign i_p3_lr_decode_iv_a = i_p3_lr_decode_r & i_p3_iv_r; 
   assign i_p3_ni_wbrq_predec_iv_a = i_p3_ni_wbrq_predec_r & i_p3_iv_r; 
   assign i_p3_sr_decode_iv_a = i_p3_sr_decode_r & i_p3_iv_r; 
   assign i_p3_st_decode_iv_a = i_p3_st_decode_r & i_p3_iv_r; 
   assign i_p3_destination_en_iv_a = i_p3_destination_en_r & i_p3_iv_r; 

//------------------------------------------------------------------------------
// Pipeline Stage 3 Instruction Valid
//------------------------------------------------------------------------------
//
   // This signal indicates that stage 3 contains a valid instruction. The
   // instruction in stage 3 may not be valid for a number of reasons:
   // (1) Stage 2b is stalled and stage 3 is not.  This will leave a hole in the
   //     pipeline.
   // (2) Stage 3 is being killed whilst it is stalled.
   // (3) Stage 2b is being killed as it enters stage 3
   // (4) The jump in stage 2b does not take the jump as it leaves stage 2b so
   //     kill it.
   //
   assign i_p3_iv_nxt = (((i_p3_enable_a == 1'b 1) & (i_p2b_enable_a == 1'b 0)) 
                   | 
                         ((i_p3_enable_a == 1'b 0) & (i_p4_kill_p3_a == 1'b 1)) 
                   | 
                         ((i_p2b_enable_a == 1'b 1) & (i_p4_kill_p2b_a == 1'b 1)) 
                   | 
                         ((i_p2b_nojump_a == 1'b 1) & (i_p2b_enable_a == 1'b 1))) ? 
          1'b 0 : 
                        ((i_p3_enable_a == 1'b 0) & (i_p3_iv_r == 1'b 1)) ? 
          1'b 1 : 
                        ((i_p3_enable_a == 1'b 0) & (i_p2b_enable_a == 1'b 0)) ? 
          i_p3_iv_r : 
          i_p2b_iv_r; 

   always @(posedge clk or posedge rst_a)
    begin : p3_iv_sync_PROC
      if (rst_a == 1'b 1)
        begin
          i_p3_iv_r <= 1'b 0;   
        end
      else
        begin
          i_p3_iv_r <= i_p3_iv_nxt;   
        end
    end


//------------------------------------------------------------------------------
// Stage 3 LR/SRs
//------------------------------------------------------------------------------
//
   // The signals for p3lr and p3sr are used by hostif to handle
   // auxiliary register accesses. Note that they include p3iv and kill signals
   // in their decodes.
   //
   assign i_p3_lr_a = i_p3_lr_decode_iv_a & i_p4_no_kill_p3_a; 
   assign i_p3_sr_a = i_p3_sr_decode_iv_a & i_p4_no_kill_p3_a;


//------------------------------------------------------------------------------
// Stage 3 LD/ST
//------------------------------------------------------------------------------
//
   // The signals for mload and mstore are used by hostif to handle
   // auxiliary register accesses. Note that they include p3iv and kill signals
   // in their decodes.
   //
   assign i_p3_mload_a = i_p3_ld_decode_iv_a & i_p4_no_kill_p3_a; 
   assign i_p3_mstore_a = i_p3_st_decode_iv_a & i_p4_no_kill_p3_a; 

//------------------------------------------------------------------------------
// Stage 3 Condition Codes evaluation
//------------------------------------------------------------------------------
//
   // Evalulate the flags against the current condition code.
   //
   always @(aluflags_r or i_p3_q_r)
    begin : i_p3_ccunit_PROC

      i_p3_ccunit_fz_a = aluflags_r[A_Z_N];   
      i_p3_ccunit_fn_a = aluflags_r[A_N_N];   
      i_p3_ccunit_fc_a = aluflags_r[A_C_N];   
      i_p3_ccunit_fv_a = aluflags_r[A_V_N];   
      i_p3_ccunit_nfz_a = ~aluflags_r[A_Z_N];   
      i_p3_ccunit_nfn_a = ~aluflags_r[A_N_N];   
      i_p3_ccunit_nfc_a = ~aluflags_r[A_C_N];   
      i_p3_ccunit_nfv_a = ~aluflags_r[A_V_N];   

      case (i_p3_q_r[CCUBND:0]) 
        CCZ:
         begin
            i_p3_ccmatch_a = i_p3_ccunit_fz_a;//   Z,  EQ
         end
        CCNZ:
         begin
            i_p3_ccmatch_a = i_p3_ccunit_nfz_a;//   NZ, NE
         end
        CCPL:
         begin
            i_p3_ccmatch_a = i_p3_ccunit_nfn_a;//   PL, P
         end
        CCMI:
         begin
            i_p3_ccmatch_a = i_p3_ccunit_fn_a;//   MI, N
         end
        CCCS:
         begin
            i_p3_ccmatch_a = i_p3_ccunit_fc_a;//   CS, C
         end
        CCCC:
         begin
            i_p3_ccmatch_a = i_p3_ccunit_nfc_a;//   CC, NC
         end
        CCVS:
         begin
            i_p3_ccmatch_a = i_p3_ccunit_fv_a;//   VS, V
         end
        CCVC:
         begin
            i_p3_ccmatch_a = i_p3_ccunit_nfv_a;//   VC, NV
         end
        CCGT:
         begin
            i_p3_ccmatch_a = i_p3_ccunit_fn_a & i_p3_ccunit_fv_a & 
                         i_p3_ccunit_nfz_a | i_p3_ccunit_nfn_a & 
                         i_p3_ccunit_nfv_a & 
                         i_p3_ccunit_nfz_a;//   GT
         end
        CCGE:
         begin
            i_p3_ccmatch_a = i_p3_ccunit_fn_a & i_p3_ccunit_fv_a | 
                         i_p3_ccunit_nfn_a & 
                         i_p3_ccunit_nfv_a;//   GE
         end
        CCLT:
         begin
            i_p3_ccmatch_a = i_p3_ccunit_fn_a & i_p3_ccunit_nfv_a | 
                         i_p3_ccunit_nfn_a & 
                         i_p3_ccunit_fv_a;//   LT
         end
        CCLE:
         begin
            i_p3_ccmatch_a = i_p3_ccunit_fz_a | i_p3_ccunit_fn_a & 
                         i_p3_ccunit_nfv_a | i_p3_ccunit_nfn_a & 
                         i_p3_ccunit_fv_a;//   LE
         end
        CCHI:
         begin
            i_p3_ccmatch_a = i_p3_ccunit_nfc_a & 
                         i_p3_ccunit_nfz_a;  //   HI
         end
        CCLS:
         begin
            i_p3_ccmatch_a = i_p3_ccunit_fc_a | 
                         i_p3_ccunit_fz_a;//   LS
         end
        CCPNZ:
         begin
            i_p3_ccmatch_a = i_p3_ccunit_nfn_a & 
                         i_p3_ccunit_nfz_a;  //   PNZ
         end
        default:
         begin
            i_p3_ccmatch_a = 1'b 1;//   AL
         end
      endcase
    end // block: i_p3_ccunit_PROC
   

   // Combine the signals for flagging the execution of an instruction when
   // condition is true for both 32-bit and 16-bit, i.e conditionally
   // executed instructions.
   //
   assign i_p3_condtrue_sel0_a = (i_p3_opcode_32_fmt1_r | 
                                  x_idecode3) & 
                                  (~i_p3_fmt_cond_reg_r)  | 
                                  i_p3_alu16_condtrue_r; 

   assign i_p3_condtrue_sel1_a = (i_p3_opcode_32_fmt1_r | 
                                  x_idecode3            | 
                                  i_p3_sop_sub_r); 

   assign i_p3_condtrue_a = (i_p3_condtrue_sel0_a      | 
                             (i_p3_condtrue_sel1_a        & 
                              i_p3_ccmatch_alu_ext_a)) & 
                              i_p4_no_kill_p3_a; 

   //  This signal is true when an ALU instruction in stage 3 that employs an
   //  extension conditon code has been set.
   // 
   assign i_p3_ccmatch_alu_ext_a = ((i_p3_q_r[CCXBPOS] == 1'b 0) | 
                                       (XT_INSCC == 1'b 0)) ? 
                                       i_p3_ccmatch_a : 
                                       xp3ccmatch; 


//------------------------------------------------------------------------------
// The loop count register hit
//------------------------------------------------------------------------------
//
   // We need to generate a load signal for the loop count logic. This
   // is true when wben indicates a load is to take place, and wba[]
   // points to the loop count register.
   //
   // Note that this signal may be true when the processor is halted,
   // as delayed load writebacks and host writes must still be able to
   // take place.
   //
   assign i_p3_loopcount_hit_a = ((i_p4_wben_nld_nxt == 1'b 1) & 
                                  (i_p3_wback_addr_nld_a == RLCNT)) ?
          1'b 1 : 
          1'b 0; 


//------------------------------------------------------------------------------
//  Request for a Writeback in Stage 4
//------------------------------------------------------------------------------
//
   // Generate signals which are used in the register writeback request
   // calculation.
   //
   assign i_p3_x_snglec_wben_iv_a = x_snglec_wben & i_p3_iv_r & XT_ALUOP; 

   //  This is true when an extension instruction wants to writeback.
   //  Fifo-type instructions suppress writeback by setting xnwb.
   // 
   assign i_p3_xwb_op_a = (i_p3_x_snglec_wben_iv_a & 
                           (~xnwb) & 
                           (~i_p3_dest_imm_r)); 


   // This is true when regular ARC instruction, which is conditional
   // and can writeback to the register file, wants to write back. This
   // will be the case when the stage 3 condition is true, and the
   // operation does not have an immediate register as its destination.
   //
   assign i_p3_cc_xwb_wb_op_a = (i_p3_ccwbop_decode_iv_a | i_p3_xwb_op_a) &
                                 i_p3_condtrue_a; 

   // Note that p3dolink is qualified with p3iv here, even though it 
   // was qualified with p2iv at stage 2. This is to take account of
   // killed instructions, and pipeline tearing where stage 2 is held
   // and stage 3 continues.
   // Also note that all the signals which are not explicity qualified
   // with p3iv have already included it.  This does not apply to p3int
   // as p3int is mutually exclusive with p3iv.
   //
   // A writeback will be requested under the following conditions:
   //
   //  a. BLcc link register writeback,
   //  b. Load/Store instruction address writeback (PUSH/POP etc),
   //  c. Extension instruction register writeback,
   //  d. LR fetch from auxiliary registers,
   //  e. Regular conditional ARC instruction register writeback,
   //  f. Interrupt link register writeback.
   //
   assign i_p3_wb_req_a = i_p3_ni_wbrq_a | p3int; 

   // This signal is the same as i_p3_wb_req_a, except that it does not
   // include an option for the interrupt unit to write back. It is used 
   // in certain extensions where an external register set is provided,
   // which are not allowed to accept loads, or fifo-type extension ALU
   // instructions.
   //
   // A writeback will be requested under the following conditions:
   //
   //  a. BLcc link register writeback,
   //  b. Load/Store instruction address writeback (PUSH/POP etc),
   //  c. Extension instruction register writeback,
   //  d. LR fetch from auxiliary registers,
   //  e. Regular conditional ARC instruction register writeback.
   //
   assign i_p3_ni_wbrq_a = (i_p3_ni_wbrq_predec_iv_a | 
                            i_p3_cc_xwb_wb_op_a); 

   // Generate request to reserve stage 4 for the instruction currently
   // in stage 3.
   //
   // This signal is set true when the instruction at stage 3 wants to
   // reserve the writeback stage for itself. This is required when a
   // FifO-type instruction wants to suppress writeback to the register
   // file, but needs the data and register address to be present in the
   // writeback stage so that it can be picked off and sent into the
   // FifO buffer. 
   //
   assign i_p3_wb_rsv_a = (i_p3_x_snglec_wben_iv_a & 
                           i_p3_condtrue_a & 
                           xnwb); 

   assign i_p4_ldvalid_wback_a =
                                 ldvalid; 

//------------------------------------------------------------------------------
//  Generate writeback register address
//------------------------------------------------------------------------------
//
// A register writeback will be derived in the following order:
//
//  a. The regadr[] from the Load sorebaord unit (lsu), for delayed load
//     writeback,
//  b. The h_regadr from host interface (hostif), for host writes to core
//     registers,
//  c. All other sources for witeback which include:
//      [i]  Multi-cycle extensions x_multic_wba for writing back results from
//           the XMAC,
//      [ii] Other conditions that have already been combined into
//           i_p3_sc_dest_r.
//
// Note that delayed load register writebacks override host writes, and
// the host is held off for a cycle using the hold_host signal,
// generated by hostif.
//
// Note also that the code below generates two writeback addresses, one
// which is used as the final writeback address (i_p3_wback_addr_a), and
// one which can be generated very near to the start of the cycle
// (i_p3_sc_wba_a). This signal is used to generate the shortcut enable
// signals, and is combined with test of regadr which is not dependent
// on ldvalid being true, which would be the case if i_p3_wback_addr was
// used.
//
// !4p! Note that we only put regadr onto the writeback path bus if
// !4p! we're going to do a load return via the writeback path (4-port
// !4p! register file load returns go direct to the port on the register
// !4p! file).
//
   assign i_p3_wback_addr_a = (i_p4_ldvalid_wback_a == 1'b 1) ? 
          regadr : 
                              (cr_hostw == 1'b 1) ? 
          h_regadr : 
          i_p3_sc_wba_a; 


// A register writeback for the early arriving logic is specified in the
// conditions below:
//
//  a. Multi-cycle extensions x_multic_wba for writing back results from
//     the XMAC,
//  b. Other conditions that have already been combined into
//     i_p3_sc_dest_r.
//
//     [1] Select 'B' field for LD instructions, i_p2b_b_field_r.
//     [2] Select the stack pointer register for push/pop operations as they
//         will update the stack pointer, RSTACKPTR.
//     [3] Select destination from stage 2b, i_p2b_destination_r.
//
   assign i_p3_sc_wba_a = ((x_multic_wben & XT_MULTIC_OP) == 1'b 1) ? 
          x_multic_wba : 
          i_p3_sc_dest_r; 

   // The signal is purely for used by the XY Memory when it is included 
   // into an design. The signal is almost identical to i_p3_wback_addr_a
   // except that the regadr input term has been omitted. This is because
   // the XY Memory cannot accept pointer as destination of loads. This
   // modification also removes long time path that eliminates from the 
   // arbiter. When XY Memory is not included, this output is removed via 
   // the boundary_optimation mode in Design Compiler.
   //
   assign i_p3_wback_addr_nld_a = (cr_hostw == 1'b 1) ? 
          h_regadr : 
          i_p3_sc_wba_a; 


//------------------------------------------------------------------------------
// Pipeline Stage 3 Multi-cycle writeback stall
//------------------------------------------------------------------------------
// 
   // The multi-cycle pipeline writeback will be stalled if a returning load or
   // a host write to a core register is performed on the next cycle.
   //
   assign i_p3_xmultic_nwb_a = (cr_hostw | i_p4_ldvalid_wback_a); 
  
   // Stall the ARC when instruction in stage 3 is :
   //
   // [1] Requesting a writeback                    OR
   // [2] Reserving the stage 4 writeback registers OR
   // [3] An interrupt (writes to ILINK)            OR
   // [4] A single cycle extension instruction wants to writeback
   //
   assign i_p3_wb_instr_a = (i_p3_wb_req_a |
                             i_p3_wb_rsv_a |
                             p3int         |
                             i_p3_x_snglec_wben_iv_a);
 
 
//------------------------------------------------------------------------------
//  Branch protection system
//------------------------------------------------------------------------------
//
// In order to reduce code size, we want to remove the need to have a
// NOP between setting the flags and taking the associated branch.
//
// e.g.         sub.f       0,r0,23         ; is r0=23?
//              nop                         ; padding instruction. <//
//              bz          r0_is_23        ;
//
// In order that the compiler does not have to generate these
// instructions, we can generate a stage 2 stall if an instruction in
// stage 3 is attempting to set the flags. Once this instruction has
// completed, and has passed out of stage 3, then stage 2 will continue.
//
// We need to detect the following types of valid instruction at stage
// three:
//
//   i. Any ALU instruction which sets the flags (p3setflags) 
//  ii. Jcc.F
// iii. A FLAG instruction.
//
   assign i_p2b_special_flagset_a = ((i_p2b_opcode_32_fmt1_a & 
                                 i_p2b_flag_bit_r & 
                                 (i_p2b_subopcode_j_a | 
                                 i_p2b_subopcode_jd_a)) 
                                 |
                                 //  FLAG
                                 (i_p2b_opcode_32_fmt1_a & 
                                 i_p2b_subopcode_flag_a)); 
                                 
   assign i_p2b_bch_flagset_a = i_p2b_iv_r & (i_p2b_setflags_r | 
                                i_p2b_special_flagset_a); 

   assign i_p3_bch_flagset_a = i_p3_iv_r & (i_p3_setflags_r | 
                               i_p3_special_flagset_r);
                                    
//------------------------------------------------------------------------------
// Compare & branch CC checking
//------------------------------------------------------------------------------
//
   // If the instruction entering stage 3 is a predicted BRcc then invert the
   // CC. This is carried out in this stage for static timing reasons
   //
   always @(i_p3_q_r)
    begin : p3_BRcc_q_async_PROC

      case (i_p3_q_r[STD_COND_CODE_MSB:0])
        BR_CCNE, BBIT1:
         begin
            i_p3_inv_br_q_32_a = BR_CCEQ;   
         end
        BR_CCLT:
         begin
            i_p3_inv_br_q_32_a = BR_CCGE;   
         end
        BR_CCGE:
         begin
            i_p3_inv_br_q_32_a = BR_CCLT;   
         end
        BR_CCLO:
         begin
            i_p3_inv_br_q_32_a = BR_CCHS;   
         end
        BR_CCHS:
         begin
            i_p3_inv_br_q_32_a = BR_CCLO;   
         end
        default:
         begin
            i_p3_inv_br_q_32_a = BR_CCNE;   
         end
      endcase

      // Transform BBIT1 into ccne and BBIT0 into cceq
      //
      case (i_p3_q_r[STD_COND_CODE_MSB:0])
        BR_CCNE, BBIT1:
         begin
            i_p3_no_inv_br_q_tmp = BR_CCNE;
         end
        BR_CCEQ, BBIT0:
         begin
            i_p3_no_inv_br_q_tmp = BR_CCEQ;   
         end
        default:
         begin
            i_p3_no_inv_br_q_tmp = i_p3_q_r[STD_COND_CODE_MSB:0];   
         end
      endcase
    end 
   
   // Select the correct inverted condition code for the 16-bit BRcc
   // instructions.
   //
   assign i_p3_inv_br_q_16_a = (BR_CCEQ &
                                {(CONDITION_CODE_MSB){i_p3_alu_brne16_r}} 
                                | 
                                BR_CCNE &
                                {(CONDITION_CODE_MSB){i_p3_alu_breq16_r}});

   // Select between the 32-bit and 16-bit inverted condition codes
   //
   assign i_p3_inv_br_q_a = (i_p3_br_or_bbit32_r == 1'b 1) ? 
          i_p3_inv_br_q_32_a : 
          i_p3_inv_br_q_16_a; 


   // Select between the non-inverted condition code
   //
   assign i_p3_no_inv_br_q_a = (BR_CCNE &
                                {(CONDITION_CODE_MSB){i_p3_alu_brne16_r}}
                                | 
                                BR_CCEQ &
                                {(CONDITION_CODE_MSB){i_p3_alu_breq16_r}} 
                                | 
                                i_p3_no_inv_br_q_tmp &
                                {(CONDITION_CODE_MSB){i_p3_br_or_bbit32_r}});

   // If the compare & branch has been predicted then the condtion code must be
   // inverted.
   //
   assign i_p3_br_q_a = (i_p3_brcc_pred_r == 1'b 0) ?
          i_p3_no_inv_br_q_a :
          i_p3_inv_br_q_a;

   // Do the condtion code / flag evaluation at the end of stage 3, ready to be
   // latched into stage 4.
   //
   always @(br_flags_a or i_p3_br_q_a)
    begin : br_ccunit_PROC

      i_p3_br_ccunit_fz_a = br_flags_a[A_Z_N];   
      i_p3_br_ccunit_fn_a = br_flags_a[A_N_N];   
      i_p3_br_ccunit_fc_a = br_flags_a[A_C_N];   
      i_p3_br_ccunit_fv_a = br_flags_a[A_V_N];   
      i_p3_br_ccunit_nfz_a = ~br_flags_a[A_Z_N];   
      i_p3_br_ccunit_nfn_a = ~br_flags_a[A_N_N];   
      i_p3_br_ccunit_nfc_a = ~br_flags_a[A_C_N];   
      i_p3_br_ccunit_nfv_a = ~br_flags_a[A_V_N];   

      case (i_p3_br_q_a) 
        BR_CCNE:
         begin
            i_p4_ccmatch_br_a = i_p3_br_ccunit_nfz_a;
                                                          //   NE/NZ
         end
        BR_CCLT:
         begin
            i_p4_ccmatch_br_a = i_p3_br_ccunit_fn_a  &
                                  i_p3_br_ccunit_nfv_a | 
                                  i_p3_br_ccunit_nfn_a &
                                  i_p3_br_ccunit_fv_a;
                                                          //   LT
         end
        BR_CCGE:
         begin
            i_p4_ccmatch_br_a = i_p3_br_ccunit_fn_a  &
                                  i_p3_br_ccunit_fv_a  | 
                                  i_p3_br_ccunit_nfn_a &
                                  i_p3_br_ccunit_nfv_a;
                                                          //   GE
         end
        BR_CCLO:
         begin
            i_p4_ccmatch_br_a = i_p3_br_ccunit_nfc_a;  //   LO
         end
        BR_CCHS:
         begin
            i_p4_ccmatch_br_a = i_p3_br_ccunit_fc_a &
                                i_p3_br_ccunit_nfz_a | 
                                i_p3_br_ccunit_fz_a;      //   HI
         end
        default:
         begin
            i_p4_ccmatch_br_a = i_p3_br_ccunit_fz_a;   //   EQ/Z           
         end
      endcase
   end // block: br_ccunit_PROC
   
//------------------------------------------------------------------------------
// Sync instruction present
//------------------------------------------------------------------------------

   // This signal stalls the pipe when a sync instruction is present and
   // keeps it stalled until all memory operations have finished.
   // If it is in the delay slot of a brcc then it can be canceled if
   // the delay slot is not taken (i_p4_no_kill_p3_a).
   //
   assign i_p3_sync_stalls_pipe = (i_p3_sync_instr_iv_a & 
                                   i_p4_no_kill_p3_a &
                                   ((lpending & ~i_sync_local_ld_r) 
	 
                                    | (~sync_queue_idle & ~i_ignore_debug_op_r)
                                    )) ? 1'b1 : 1'b0;
				      
   // actual stall signal, debug accesses will not stall the pipe.
   //				      
   assign i_p3_sync_stalls_pipe_a = i_p3_sync_stalls_pipe & i_ignore_debug_op_a;
				   
   always @(posedge clk or posedge rst_a)
    begin : sync_PROC
      if (rst_a == 1'b 1)
        begin
          i_sync_local_ld_r       <= 1'b 0;
	  i_p3_sync_stalls_pipe_r <= 1'b 0;
	  i_lpending_prev_r       <= 1'b 0;
	  i_ignore_debug_op_r     <= 1'b 0; 
	  i_store_in_progress_r   <= 1'b 0;
  
        end
      else
        begin
	  // Is a load in progress
	  //
	  i_lpending_prev_r <= lpending;
	  
	  // load is to local memory
	  //
          i_sync_local_ld_r <= (dmp_mload & is_local_ram & ~i_lpending_prev_r); 
	  
	  // Register the stall signal.
	  //
	  i_p3_sync_stalls_pipe_r <= i_p3_sync_stalls_pipe_a; 
	  
	  // We need to be aware of any non-debug stores that are
	  // in progress - we need to stall the pipe if a sync
	  // instruction later comes into stage 3 while they are in
	  // progress.
	  // 
	  if (dmp_mstore && ~debug_if_r)
	    i_store_in_progress_r <= 1'b1;
	  if (sync_queue_idle)
	    i_store_in_progress_r <= 1'b0;
	  
	  // Stores are issued by the debug port but debug_if_r
	  // can go low before they complete so we need to track
	  // them. 
	  // If a non-debug store is in progress or a debug store
	  // is in progress and a non-debug store comes along then 
	  // sync will need to stall the pipe.
	  //
	  if ((i_p3_sync_stalls_pipe_a == 1'b0 && i_store_in_progress_r == 1'b0)
	      && dmp_mstore && debug_if_r)
	    i_ignore_debug_op_r <= 1'b1;
	  if (sync_queue_idle || (dmp_mstore && ~debug_if_r && ~is_local_ram))
	    i_ignore_debug_op_r <= 1'b0;   
	       
        end
    end
    
    // Debug ops should be ignored if a pipe stall is under way.
    //
    assign i_ignore_debug_op_a = debug_if_r ?
                                   ( 
                                    i_p3_sync_stalls_pipe_r 
				    | i_store_in_progress_r
				   )
				   : 1'b1;

//------------------------------------------------------------------------------
// Stage 3 Instruction Completion Control
//------------------------------------------------------------------------------
//
// This signal is true when the processor is running, and the instruction in
// stage 3 can be allowed complete and set the flags if appropriate.
//
//  ** Note: Control of data from stage 3 to stage 4 is controlled by 
//           p3wb_en. **
//
//  Stage 3 may be prevented from completing for a number of reasons:
//
//  a. An extension multi-cycle ALU operation has requested extra time
//     to complete the operation (xholdop3). Note that this can only
//     be the case when extension alu operations are enabled with the
//     XT_ALUOP constant in extutil.
//
//  c. The ARC600 and an extension multicycle instruction  want to
//     write back during the same cycle (i_p3_multic_wben_stall_a).
//
//  d. The memory controller is busy and cannot accept any more load or
//     store operations. (mwait)
//
// Load return (no-stall returns enabled)
//
//  e. A delayed load writeback will happen on the next cycle and the 
//     instruction in stage 3 wants to write back to the register file.
//     (ldvalid = '1' and p3_wb_req = '1').
//
//  f. A delayed load writeback will happen on the next cycle and the 
//     instruction in stage 3 is suppressing writeback to the register
//     file, and wants the data & register address values from the
//     writeback stage. For this reason, the instruction must be stalled
//     to prevent the data/address from being overwritten by a returning
//     delayed load.
//     (i_ldvalid_wback = '1' and p3_wb_rsv = '1').
//
// Load return (loads always stall)
//
//  g. Delayed loads always cause stalls.
//
//  h. The actionpoint debug mechanism or the breakpoint instruction (in
//     debug_exts) is triggered and thus disables the instructions from
//     going into stage 4 since pipeline has been flushed.
//
//  i. There is a compare/branch in stage 3 and the instruction in stage
//     one is not valid.
//
   // Returning Load Stall
   //
   // A stage 3 instruction stall be generated under the following conditions:
   // (1) A delayed load writeback will happen on the next cycle and the 
   // instruction in stage 3 also may want to writeback.
   //
   assign i_p3_load_stall_a = i_p4_ldvalid_wback_a & i_p3_wb_instr_a; 

   // Multicycle instruction writeback stall
   //
   // A stage 3 instruction in stage 3 of the basecase pipeline may want to
   // write back at the end of the cycle, however a multicycle instruction also
   // wants to writeback.  The basecase pipeline is stalled to allow the
   // multicycle to complete first.
   //
   assign i_p3_multic_wben_stall_a = (x_multic_wben & 
                                      XT_MULTIC_OP &
                                      i_p3_wb_instr_a);

   // Extension holdup stall
   //
   // A stall can happen in stage 3 when:
   //
   // [1] An extension can stall stage 3 by asserting the xholdup3 signal.
   //
   assign i_p3_holdup_stall_a = (xholdup3 & XT_ALUOP)           |
                                1'b 0; 

   // Instruction step stall
   //
   // When instruction stepping a control transfer it will be possible for the
   // control transfer to complete without the PC from being updated, this
   // causes problems for instruction stepping logic.  This stall will stall any
   // control transfer in stage 3 if it has not completed fully.
   //
   assign i_p3_step_stall_a = pcounter_jmp_restart_r & do_inst_step_r;

   // The power saving stall prevents garbage data from moving down the pipeline
   // and causing spurious switching.
   //
   assign i_p3_pwr_save_stall_a = ~i_p3_iv_r & ~p3int; 

   assign i_p3_enable_a = ~((~en)                       |
                            (~i_p3_enable_nopwr_save_a) |
                            i_p3_pwr_save_stall_a);

   assign i_p3_enable_nopwr_save_a = ((mwait                    == 1'b 1) | 
                                      (i_p3_step_stall_a        == 1'b 1) | 
                                      (i_p3_multic_wben_stall_a == 1'b 1) | 
                                      (i_p3_load_stall_a        == 1'b 1) |
                                      (i_p3_sync_stalls_pipe_a  == 1'b 1) | 
                                      (i_p3_holdup_stall_a      == 1'b 1)) ?
          1'b 0 : 
          1'b 1; 

   assign i_p3_en_non_iv_mwait_a = ((en                       == 1'b 0) | 
                                        (i_p3_pwr_save_stall_a    == 1'b 1) | 
                                        (i_p3_multic_wben_stall_a == 1'b 1) |
                                        (i_p3_load_stall_a        == 1'b 1) | 
                                        (i_p3_step_stall_a        == 1'b 1) | 
                                        (i_p3_holdup_stall_a      == 1'b 1)) ?
          1'b 0 : 
          1'b 1; 


//------------------------------------------------------------------------------
// Stage 3 write-back enable
//------------------------------------------------------------------------------
//
// This signal is true when the processor is running, and a valid
// instruction stage 3 can be allowed to move on into stage 4. It is
// also true when a delayed load completes or a host write is taking
// place (these do not require the processor to be running).
//
// FIFO instructions which set i_p3_wb_rsv_a to reserve the writeback
// slot cause p3wb_en to be set true to allow the address and data
// values to flow into stage 4, although this type of instruction does 
// *NOT* set wben to enable writeback to the register file on the
// following instruction.
//
// Stage 3 instructions may be held up for a number of reasons:
// (same reasons as for en3)
//
//  a. The processor is halted.
//
//  b. A branch in stage 2 is held, and stage 3 must also be held to 
//     protect the flags used by the branch condition code unit.
//
//  c. An extension multi-cycle ALU operation has requested extra time
//     to complete the operation (xholdop123). Note that this can only
//     be the case when extension alu operations are enabled with the
//     XT_ALUOP constant in extutil.
//
//
//  d. The memory controller is busy and cannot accept any more load or
//     store operations. (mwait)
//
   // The i_p4_wben_nxt signal is set true when a register writeback will 
   // occur on the next cycle.
   //
   assign i_p4_wben_nxt = i_p4_wben_nld_nxt | i_p4_ldvalid_wback_a; 

   assign i_p3_wb_stall_a = ((en                    == 1'b 0) | 
                             (mwait                 == 1'b 1) | 
                             (i_p3_step_stall_a     == 1'b 1) | 
                             (i_p3_pwr_save_stall_a == 1'b 1) | 
                             (i_p3_holdup_stall_a   == 1'b 1)) ?
          1'b 1 : 
          1'b 0; 

   assign i_p4_wben_nld_nxt = ((cr_hostw == 1'b 1) | 
                              ((x_multic_wben & XT_MULTIC_OP) == 1'b 1)) ?
          1'b 1 : 
                              ((i_p3_wb_stall_a == 1'b 1) |
                               (i_p3_wb_req_a   == 1'b 0) | 
                               (i_p4_kill_p3_a  == 1'b 1)) ?
          1'b 0 : 
          1'b 1; 

   // The i_p3_wback_en signal is set true when a real register writeback will
   // happen, but also when the writeback slot is reserved for a FIFO
   // instruction.
   //
   assign i_p3_wback_en_a = i_p4_wben_nxt | i_p3_wb_rsv_a; 

   assign i_p3_wback_en_nld_a = i_p4_wben_nld_nxt | i_p3_wb_rsv_a; 

//------------------------------------------------------------------------------
// Stage 4 pipeline registers
//------------------------------------------------------------------------------
  
   // The stage 4 writeback control signal is latched from p3wb_en, and is true
   // whenever stage 4 contains a data value which is to be written into the
   // register address provided.
   //
   always @(posedge clk or posedge rst_a)
    begin : Stage_4_PROC
      if (rst_a == 1'b 1)
        begin
          i_p4_wben_r       <= 1'b 0;   
          i_p4_br_or_bbit_r <= 1'b 0;   
          i_p4_has_dslot_r  <= 1'b 0;   
          i_p4_ccmatch_br_r <= 1'b 0;   
          i_p4_wba_r        <= {(OPERAND_MSB + 1){1'b 0}};   
        end
      else
        begin
     
          i_p4_wben_r <= i_p4_wben_nxt;

//------------------------------------------------------------------------------
// Stage 4 Write-back address
//------------------------------------------------------------------------------
// The data to be used for input to stage 4 is latched in the ALU block.
//
// We only clock the register number for writeback, along with the
// actual data that is to be written back.
//
//  Note that the register address is produced from a number of sources,
//  and is not simply the A field from the instruction.
//    
//
          if (i_p3_wback_en_a == 1'b 1)
            begin                         
              i_p4_wba_r  <= i_p3_wback_addr_a;
            end
                        

          if (i_p3_enable_a == 1'b 1)
            begin
              i_p4_ccmatch_br_r <= i_p4_ccmatch_br_nxt;   
              i_p4_br_or_bbit_r <= i_p3_br_or_bbit_iv_a;   
              i_p4_has_dslot_r  <= i_p3_has_dslot_r;   
            end
        end
    end 
   
   assign i_p4_br_or_bbit_iv_a = i_p4_br_or_bbit_r & i_p4_iv_r; 
   assign i_p4_ccmatch_br_nxt =  i_p4_ccmatch_br_a & 
                                 i_p3_br_or_bbit_iv_a;

//------------------------------------------------------------------------------
// Stage 4 instruction valid 
//------------------------------------------------------------------------------
 
   assign i_p4_iv_nxt = ((i_p3_enable_a        == 1'b 0) | 
                         (i_p4_kill_p3_a       == 1'b 1) |
                         (i_p3_br_or_bbit_iv_a == 1'b 0)) ?
        1'b 0 : 
        i_p3_iv_r; 

   always @(posedge clk or posedge rst_a)
    begin : p4_iv_sync_PROC
      if (rst_a == 1'b 1)
        begin
          i_p4_iv_r <= 1'b 0;   
        end
      else
        begin
          i_p4_iv_r <= i_p4_iv_nxt;   
        end
    end


//------------------------------------------------------------------------------
// STAGE4  Branch Taken
//------------------------------------------------------------------------------
//
   // This signal is employed for operations that are conditionally
   // executed (32/16-bit).
   //
   assign i_p4_docmprel_a = i_p4_ccmatch_br_r & i_p4_iv_r; 

//------------------------------------------------------------------------------
// Delay Slot Cancelling
//------------------------------------------------------------------------------
//
// Compare & branch instructions may kill the following instructions depending
// on the delay slot mode and whether the instruction's condition is true.
//
   assign i_p4_kill_p1_a = i_p4_docmprel_a; 

   assign i_p4_kill_p2_a = (i_p4_docmprel_a & 
                            (~(i_p4_has_dslot_r & 
                              (~i_p2b_iv_r) & 
                              (~i_p3_iv_r)))); 

   assign i_p4_kill_p2b_a = (i_p4_docmprel_a & 
                             (~(i_p4_has_dslot_r & 
                               (~i_p3_iv_r)))); 

   // Only kill stage 3 instruction if there is no delay slot.
   //
   assign i_p4_kill_p3_a = (i_p4_docmprel_a & 
                            (~i_p4_has_dslot_r)); 

   // When true stage 4 will not kill stage 3.
   //
   assign i_p4_no_kill_p3_a = ((~i_p4_docmprel_a) | 
                               i_p4_has_dslot_r);
 
   assign kill_last = (i_p4_kill_p3_a & 
                       i_p3_ld_decode_iv_a); 


//------------------------------------------------------------------------------
// Interrupt Blockout logic
//------------------------------------------------------------------------------
//
// This logic holds off interrupts when there is a FLAG, Jcc.F in the
// pipeline.
//
// This is necessary in order to ensure that code which disables
// interrupts behaves intuitively. It was possible for the fact that the
// e1 and e2 flags are updated at stage 3 meant that two instructions
// could be fetched before interrupts were disabled.
//
// One of these two instructions would be killed by an incoming
// interrupt, but this still meant that it was possible for an interrupt
// to occur in two un-helpful places:
//
//  i. Immediately after the FLAG instruction
//
//     In this case the interrupts are disabled on entry to the ISR.
//     Whilst this should be fine in most circumstances, it appears that
//     some RTOS systems have options to reset the interrupt enable
//     level to a standard value on exit of the ISR. Clearly if this
//     were done, it would mean that interrupt would be re-enabeld on
//     returning to the code where the programmer expected that they be
//     disabled. 
//
//     This case requires us to block interrupts if there is any
//     instruction present in stage 2 which could set the e1 and e2
//     flags. This means either the FLAG instruction, Jcc.F
//
// ii. After the instruction following the FLAG instruction.
//
//     This is the case most likely to cause a problem if the programmer 
//     is not aware FLAG instruction's behaviour.
//      
//     The programmer might expect that no interrupts would be possible 
//     after the instruction which disabled interrupts. As such, the
//     first instruction could be part of the code which the programmer
//     intends to be an atomic sequence of instructions. Since an 
//     interrupt could be taken after this first instruction, it is
//     possible for bad things to happen.
//
//     This case requires us to block interrupts if there is any
//     instruction present in stage 3 which could set the e1 and e2
//     flags. This means either the FLAG instruction, Jcc.F.
//     Conceivably we could also test to see if the instruction was
//     attempting to disable the interrupts here, and check whether the
//     instruction was going to be executed. For simplicity and
//     consistency of the logic, we do not perform these tests.
//
   assign i_p2_flagu_block_a = (i_p2_iv_r              & 
                                (i_p2_opcode_32_fmt1_a & 
                                 i_p2_subopcode_flag_a |
                                 i_p2_opcode_32_fmt1_a & 
                                 i_p2_flag_bit_a & 
                                 (i_p2_subopcode_j_a | 
                                  i_p2_subopcode_jd_a)));

   assign i_p2b_flagu_block_a = (i_p2b_iv_r & i_p2b_special_flagset_a); 

   assign i_p3_flagu_block_a = (i_p3_iv_r & i_p3_special_flagset_r); 

   assign i_flagu_block_a = (i_p2_flagu_block_a | 
                             i_p2b_flagu_block_a | 
                             i_p3_flagu_block_a); 


//------------------------------------------------------------------------------
// Halt Single Instruction Step
//------------------------------------------------------------------------------
//
   // The stop_step signal halts the single instruction when it is completed.
   //
   assign i_stop_step_a = (((i_p2_step_a == 1'b 1) &
                     
                     // there is no instruction in normal pipeline
                     (i_p2_iv_r == 1'b 0) & 
                     (i_p2b_iv_r == 1'b 0) & 
                     (i_p3_iv_r == 1'b 0) & 
                     (i_p4_iv_r == 1'b 0) & 
                     
                     // there are no interrupts in pipeline
                     (p2int == 1'b 0) & 
                     (p2bint == 1'b 0) & 
                     (p3int == 1'b 0) & 
                     
                     // the pipeline is not waiting for a part of an
                     // intruction packet to arrive
                     (i_p2_tag_nxt_p1_limm_r == 1'b 0) & 
                     (i_p2_tag_nxt_p1_dslot_r == 1'b 0) & 
                     (pcounter_jmp_restart_r == 1'b 0) & 
                     
                     // there are no outstanding loads
                     (lpending == 1'b 0) & 
                     
                     // there are no multicycle instruction still
                     //  outstanding
                     (x_multic_busy == 1'b 0))
                     | 
                     ((i_p2_step_a == 1'b 1) & 

                     // if a BRK has arrived in stage 2 stop the
                     //  instrucution step
                     (i_p2_brk_inst_a == 1'b 1))) ? 1'b 1 : 
        1'b 0; 

//------------------------------------------------------------------------------
// Track Single Instruction Step
//------------------------------------------------------------------------------
//
// The step_tracker process keeps track on where in the pipeline the
// instruction is during single instruction step. It generates three
// tracking signals: i_p1_p2step, i_p2_step and i_p3_step_r. The signal
// i_p2_step is high when the instruction is in pipestage 2 and
// i_p3_step_r is high when the instruction is in pipestage3. As you see
// in the timing diagram below i_p2_step and i_p3_step_r stays high after
// being set until the cycle after the stop signal stop_step is issued,
// which means that the instruction has completed.
//
// Here is an example how the step tracker process works for an
// instruction with writeback and no long immediate. The pipeline
// is clean before the step starts.
//
//                   __    __    __    __    __
//   clk            /  \__/  \__/  \__/  \__/  \
//                   ____________________
//   do_inst_step_r /                    \______
//                   _____          
//   i_enable1      /      \____________________
//                   ___________________________
//   ivalid_aligned /                           
//                        _____________
//   i_p1p2step     _____/             \________
//                        
//                                  _____
//   stop_step      _______________/     \______
//
// The signal i_p1_p2step is set when a valid instruction has moved
// from stage 1 to stage2. This signal sets i_p2_step. But i_p2_step
// is not only set by i_p1_p2step but also if there is already an
// instruction in stage 2 that uses long immediate or has a killed
// delay slot or if an interrupt is in stage 2 (p2int is set). This
// can happen if the ARC was just halted after running in free
// -running. The pipeline can then be filled with anything in this
// situation. This can only happen on the first instruction step
// after free-running mode. On the second consecutive instruction
// step the pipeline will be clean.
//   
   assign i_p2_step_a = (i_p1p2step_r | 
                         do_inst_step_r & 
                         (i_p2_long_immediate_a | 
                          i_p2_kill_p1_a | 
                          p2int)); 

   assign i_start_step_a = (i_p1_enable_a & 
                            (ivalid_aligned | 
                             p1int) |
                            pcounter_jmp_restart_r); 

   always @(posedge clk or posedge rst_a)
    begin : step_tracker_PROC
      if (rst_a == 1'b 1)
        begin
          i_p1p2step_r <= 1'b 0;   
        end
      else
        begin
          if (i_stop_step_a == 1'b 1)
            begin
              i_p1p2step_r <= 1'b 0;   
            end
          else if (i_start_step_a == 1'b 1 )
            begin
              i_p1p2step_r <= do_inst_step_r;   
            end
        end
    end
   
//------------------------------------------------------------------------------
// Pipeline Flushing & Stalling Logic
//------------------------------------------------------------------------------
//
// The pipeline flushing mechanism has been introduced to support the
// breakpoint instruction, software interrupt and actionpoint hardware. Each
// stage of the pipeline is stalled explicitly, and once all stages 1, 2, 2b and
// 3 have been stalled the ARC600 is stalled via en bit (in flags).
//
   // The stalling signal for stalling en1 is defined by
   // i_p2_brk_sleep_swi_a, and this is set to '1' on the following conditions:
   //
   //  a. The breakpoint instruction has been detected at stage
   //     two, i.e. i_p2_brk_inst_a = '1' or an actionpoint has been
   //     triggered by a valid signal from the OR-plane, from
   //     debug_exts.
   //
   //  b. The instruction in stage one of the pipeline is to be
   //     executed, and not killed.
   //
   //  c. The sleep instruction has been detected in stage 2.
   //
   //  d. The ARC is sleeping already (sleeping = '1') due to a sleep
   //     instruction that was encountered earlier.
   //
   //  e. A swi instruction has entered stage 2. a SWI instruction will flush
   //     the pipeline to allow all instruction ahead to finish before it
   //     generates the interrupt. This is need to prevent a BRK from halting
   //     the processor before the interrupt has been serviced.
   //
   assign i_p2_brk_sleep_swi_a = (i_p2_sleep_inst_a | 
                                  i_p2_brk_inst_a   |
                                  i_p2_swi_inst_a   |
                                   actionpt_pc_brk_a |                                                                    
                                  sleeping_r2       |
                                  sleeping          |
                                  i_actionhalt_a); 

   // As the pipeline is flushed of instructions when the breakpoint
   // or swi instructions or a valid actionpoint is detected it is important to
   // disable each stage explicitly. These signals have to follow the
   // last instruction which is being allowed to complete. A normal
   // instruction in stage one will mean that instructions in stage two,two b
   // three and four will be allowed to complete. However, for an
   // instruction in stage one which is in the delay slot of a branch,
   // loop or jump instruction means that stage two has to be stalled as
   // well. Therefore, only stages three and four will be allowed to
   // complete.
   //
   // The qualifying valid signal for stage two is defined by
   // i_p2_disable_nxt, and this is set to '1' on the following
   // conditions:
   //
   //  a. There is an instruction in stage two which has a dependency in
   //     stage one, i.e. i_break_stage2 = '1'.
   //
   //  b. The breakpoint instruction or actionpoint has been detected,
   //     i.e. i_p2_brk_sleep_swi_a1 = '1' and the instruction in stage
   //     two is enabled, i_enable2 = '1', and the instruction is allowed to
   //     move on.
   //
   //  c. The breakpoint instruction or actionpoint has been detected,
   //     i.e. i_p2_brk_sleep_swi_a = '1' and the instruction in stage
   //     two is invalid, i_p2_iv_r = '0'.
   //
   assign i_p2b_disable_nxt = (i_p4_kill_p2b_a == 1'b 1) ? 
          1'b 0:
                              ((i_p2_brk_sleep_swi_a == 1'b 1) &
                               (((i_p2b_enable_a == 1'b 1) & 
                                 (i_p2b_iv_r == 1'b 1))    | 
                                (i_p2b_iv_r == 1'b 0))) ?
          1'b 1 : 
          1'b 0; 

   // The qualifying valid signal for stage three is defined by
   // i_p3_disable_nxt, and this is set to '1' on the following
   // conditions:
   //
   //  a. The instruction in stage two is invalid, i_p2bdisable_r = '1'.
   //     Also the instruction in stage three is enabled, en3 = '1', and 
   //     the instruction is allowed to move on, and there is no multicycle
   //     instruction in progress.
   //
   //  b. The instruction in stage two is invalid, i_p2bdisable_r = '1'.
   //     Also the instruction in stage three is invalid, i_p3_iv_r =
   //     '0' and there is no multicycle instruction in progress.
   //
   assign i_p3_disable_nxt = (i_p2_brk_sleep_swi_a == 1'b 0) ? 
          1'b 0 : 
                             ((i_p2b_disable_r == 1'b 1)  & 
                              (((i_p3_enable_a == 1'b 1)  & 
                                (i_p3_iv_r     == 1'b 1)  & 
                                (x_multic_busy == 1'b 0)) | 
                               ((x_multic_busy == 1'b 0) & 
                                (i_p3_iv_r     == 1'b 0)))) ?
          1'b 1 : 
          1'b 0; 

   assign i_p4_disable_nxt = (i_p2_brk_sleep_swi_a == 1'b 0) ?  
          1'b 0 : 
                             ((i_p3_disable_r == 1'b 1) & 
                              (i_p4_iv_r == 1'b 0)) ? 
          1'b 1 : 
          1'b 0; 

   always @(posedge clk or posedge rst_a)
    begin : pipe_disable_PROC
      if (rst_a == 1'b 1)
        begin
          i_p2b_disable_r <= 1'b 0;   
          i_p3_disable_r <= 1'b 0;   
          i_p4_disable_r <= 1'b 0;   
        end
      else
        begin
          i_p2b_disable_r <= i_p2b_disable_nxt;   
          i_p3_disable_r <= i_p3_disable_nxt;   
          i_p4_disable_r <= i_p4_disable_nxt;   
        end
    end 
   
//------------------------------------------------------------------------------
//  Kill signals
//------------------------------------------------------------------------------
//
   assign i_kill_p2_en_a = i_p4_kill_p2_a
                           | i_p2b_kill_p2_en_a
                     ;
                     
   assign i_kill_p2_a = i_p4_kill_p2_a
                        | i_p2b_kill_p2_a
                     ;
                     
   assign i_kill_p1_a = i_kill_p1_nlp_a
                        | loop_kill_p1_a
                  ;
                     
   assign i_kill_p1_en_a = i_kill_p1_nlp_en_a
                           | loop_kill_p1_a
                     ;
                     
   assign i_kill_p1_nlp_en_a = i_p4_kill_p1_a     | 
                               i_p2b_kill_p1_en_a | 
                               i_p2_kill_p1_en_a  | 
                               i_p2_brcc_pred_nds_en_a; 

   assign i_kill_p1_nlp_a = i_p4_kill_p1_a  | 
                            i_p2b_kill_p1_a | 
                            i_p2_kill_p1_a  | 
                            i_p2_brcc_pred_nds_a; 

//------------------------------------------------------------------------------
//  Stage 1 Output Drives
//------------------------------------------------------------------------------
//
   assign awake_a         = i_awake_a; 
   assign en1             = i_p1_enable_a; 
   assign ifetch_aligned  = i_ifetch_aligned_a; 
   assign instr_pending_r = i_instr_pending_r;
   assign inst_stepping   = i_inst_stepping_a; 
   assign pcen            = i_pcen_a; 
   assign pcen_niv        = i_pcen_non_iv_a; 
//------------------------------------------------------------------------------
// Stage 2 Output Drives
//------------------------------------------------------------------------------
// 
   assign en2 = i_p2_enable_a; 
   assign p2_a_field_r = i_p2_a_field_r; 
   assign p2_abs_neg_a = i_p2_abs_neg_decode_a; 
   assign p2_b_field_r = i_p2_b_field_r; 
   assign p2_brcc_instr_a = i_p2_br_or_bbit_iv_a; 
   assign p2_c_field_r = i_p2_c_field_r; 
   assign p2_dopred = i_p2b_brcc_pred_nxt; 
   assign p2_dopred_ds = i_p2b_brcc_pred_ds_nxt; 
   assign p2_dopred_nds = i_p2_brcc_pred_nds_a; 
   assign p2_dorel = i_p2_dorel_a; 
   assign p2_iw_r = i_p2_iw_r; 
   assign p2_jblcc_a = i_p2_jblcc_iv_a; 
   assign p2_lp_instr = i_p2_loop32_a; 
   assign p2_not_a = i_p2_not_decode_a; 
   assign p2_s1a = i_p2_source1_addr_a; 
   assign p2_s1en = i_p2_source1_en_a; 
   assign p2_s2a = i_p2_source2_addr_a; 
   assign p2_shimm_data = i_p2_short_immediate_a; 
   assign p2_shimm_s1_a = i_p2_shimm_s1_a & i_p2_iv_r; 
   assign p2_shimm_s2_a = i_p2_shimm_a & i_p2_iv_r; 
   assign p2bch = i_p2_branch_iv_a; 
   assign p2cc = i_p2_iw_r[CCUBND:CCLBND]; 
   assign p2conditional = i_p2_conditional_a; 
   assign p2condtrue = i_p2_condtrue_a; 
   assign p2delay_slot = i_p2_has_dslot_a; 
   assign p2format = i_p2_format_r; 
   assign p2iv = i_p2_iv_r; 
   assign p2limm = i_p2_limm_a; 
   assign p2lr = i_p2_lr_decode_iv_a; 
   assign p2minoropcode = i_p2_minoropcode_r; 
   assign p2offset = i_p2_offset_a; 
   assign p2opcode = i_p2_opcode_a; 
   assign p2setflags = i_p2_flag_bit_a; 
   assign p2sleep_inst = i_p2_sleep_inst_a; 
   assign p2st = i_p2_opcode_32_st_a & i_p2_iv_r; 
   assign p2subopcode = i_p2_subopcode_r; 
   assign p2subopcode1_r = i_p2_subopcode1_r; 
   assign p2subopcode2_r = i_p2_subopcode2_r; 
   assign p2subopcode3_r = i_p2_subopcode3_r; 
   assign p2subopcode4_r = i_p2_subopcode4_r; 
   assign p2subopcode5_r = i_p2_subopcode5_r; 
   assign p2subopcode6_r = i_p2_subopcode6_r; 
   assign p2subopcode7_r = i_p2_subopcode7_r; 

//------------------------------------------------------------------------------
// Stage 2b Output Drives 
//------------------------------------------------------------------------------

   assign dest = i_p2b_destination_r; 
   assign desten = i_p2b_dest_en_iv_a; 
   assign en2b = i_p2b_enable_a; 
   assign en2b_niv_a = i_p2b_en_nopwr_save_a; 
   assign fs2a = i_p2b_source2_addr_r; 
   assign mload2b = i_p2b_ld_decode_a & i_p2b_iv_r & ~i_p4_kill_p2b_a; 
   assign mstore2b = i_p2b_st_decode_a & i_p2b_iv_r & ~i_p4_kill_p2b_a; 
   assign p2b_a_field_r = i_p2b_a_field_r; 
   assign p2b_abs_op = i_p3_alu_absiv_nxt; 
   assign p2b_alu_op = i_p3_alu_op_nxt; 
   assign p2b_arithiv = i_p3_alu_arithiv_nxt; 
   assign p2b_awb_field = i_p2b_awb_field_a; 
   assign p2b_b_field_r = i_p2b_b_field_r; 
   assign p2b_bch = i_p2b_jmp_iv_a; 
   assign p2b_c_field_r = i_p2b_c_field_r; 
   assign p2b_cc = i_p2b_iw_r[CCUBND:CCLBND]; 
   assign p2b_conditional = i_p2b_conditional_a; 
   assign p2b_condtrue = i_p2b_condtrue_a; 
   assign p2b_delay_slot = i_p2b_has_dslot_r; 
   assign p2b_dojcc = i_p2b_dojcc_a; 
   assign p2b_format = i_p2b_format_r; 
   assign p2b_iv = i_p2b_iv_r; 
   assign p2b_jlcc_a = i_p2b_jlcc_iv_a; 
   assign p2b_blcc_a = i_p2b_dolink_iv_a; 
   assign p2b_dopred_ds = i_p2b_brcc_pred_ds_r; 
   assign p2b_limm = i_p2b_long_immediate_r & i_p2b_iv_r; 
   assign p2b_lr = i_p2b_lr_decode_a; 
   assign p2b_minoropcode = i_p2b_minoropcode_r; 
   assign p2b_neg_op = i_p3_alu_negiv_nxt; 
   assign p2b_not_op = i_p3_alu_notiv_nxt; 
   assign p2b_opcode = i_p2b_opcode_r; 
   assign p2b_setflags = i_p2b_flag_bit_r; 
   assign p2b_shift_by_one_a = i_p2b_shift_by_one_a; 
   assign p2b_shift_by_three_a = i_p2b_shift_by_three_a; 
   assign p2b_shift_by_two_a = i_p2b_shift_by_two_a; 
   assign p2b_shift_by_zero_a = i_p2b_shift_by_zero_a; 
   assign p2b_shimm_data = i_p2b_short_immediate_r; 
   assign p2b_shimm_s1_a = i_p2b_shimm_s1_r & i_p2b_iv_r; 
   assign p2b_shimm_s2_a = i_p2b_shimm_r & i_p2b_iv_r; 
   assign p2b_size = i_p2b_size_a; 
   assign p2b_st = i_p2b_opcode_32_st_a; 
   assign p2b_subopcode = i_p2b_subopcode_r; 
   assign p2b_subopcode1_r = i_p2b_subopcode1_r; 
   assign p2b_subopcode2_r = i_p2b_subopcode2_r; 
   assign p2b_subopcode3_r = i_p2b_subopcode3_r; 
   assign p2b_subopcode4_r = i_p2b_subopcode4_r; 
   assign p2b_subopcode5_r = i_p2b_subopcode5_r; 
   assign p2b_subopcode6_r = i_p2b_subopcode6_r; 
   assign p2b_subopcode7_r = i_p2b_subopcode7_r; 
   assign s1a = i_p2b_source1_addr_r; 
   assign s1en = i_p2b_source1_en_r & i_p2b_iv_r; 
   assign s2en = i_p2b_source2_en_r & i_p2b_iv_r; 

//------------------------------------------------------------------------------
// Stage 3 Output Drives
//------------------------------------------------------------------------------

   assign brk_inst_a = i_p2_brk_inst_a; 
   assign en3 = i_p3_enable_a; 
   assign en3_niv_a = i_p3_en_non_iv_mwait_a;
   assign loopcount_hit_a = i_p3_loopcount_hit_a;  
   assign mload = i_p3_mload_a; 
   assign mstore = i_p3_mstore_a; 
   assign nocache = i_p3_nocache_r; 
   assign p3_alu_absiv = i_p3_alu_absiv_r; 
   assign p3_alu_arithiv = i_p3_alu_arithiv_r; 
   assign p3_alu_logiciv = i_p3_alu_logiciv_r; 
   assign p3_alu_op = i_p3_alu_op_r; 
   assign p3_alu_snglopiv = i_p3_alu_snglopiv_r; 
   assign p3_bit_op_sel = i_p3_bit_operand_sel_r; 
   assign p3_brcc_instr_a = i_p3_br_or_bbit_iv_a; 
   assign p3_docmprel_a = i_p4_ccmatch_br_nxt;
   assign p3_flag_instr = i_p3_flag_instr_iv_a; 
   assign p3_sync_instr = i_p3_sync_instr_iv_a;
   assign p3_max_instr = i_p3_alu_max_r; 
   assign p3_min_instr = i_p3_alu_min_r; 
   assign p3_ni_wbrq = i_p3_ni_wbrq_a; 
   assign p3_shiftin_sel_r = i_p3_shiftin_sel_r; 
   assign p3_sop_op_r = i_p3_sop_op_r; 
   assign p3_xmultic_nwb = i_p3_xmultic_nwb_a; 
   assign p3a_field_r = i_p3_a_field_r; 
   assign p3awb_field_r = i_p3_awb_field_r; 
   assign p3b_field_r = i_p3_b_field_r; 
   assign p3c_field_r = i_p3_c_field_r; 
   assign p3cc = i_p3_q_r[CCUBND:0]; 
   assign p3condtrue = i_p3_condtrue_a; 
   assign p3destlimm = i_p3_dest_imm_r; 
   assign p3dolink = i_p3_dolink_iv_a; 
   assign p3format = i_p3_format_r; 
   assign p3iv = i_p3_iv_r; 
   assign p3lr = i_p3_lr_a; 
   assign p3minoropcode = i_p3_minoropcode_r; 
   assign p3opcode = i_p3_opcode_r; 
   assign p3q = i_p3_q_r; 
   assign p3setflags = i_p3_setflags_r; 
   assign p3sr = i_p3_sr_a; 
   assign p3subopcode = i_p3_subopcode_r; 
   assign p3subopcode1_r = i_p3_subopcode1_r; 
   assign p3subopcode2_r = i_p3_subopcode2_r; 
   assign p3subopcode3_r = i_p3_subopcode3_r; 
   assign p3subopcode4_r = i_p3_subopcode4_r; 
   assign p3subopcode5_r = i_p3_subopcode5_r; 
   assign p3subopcode6_r = i_p3_subopcode6_r; 
   assign p3subopcode7_r = i_p3_subopcode7_r; 
   assign p3wb_en = i_p3_wback_en_a; 
   assign p3wb_en_nld = i_p3_wback_en_nld_a; 
   assign p3wba = i_p3_wback_addr_a; 
   assign p3wba_nld = i_p3_wback_addr_nld_a; 
   assign sc_load1 = i_p2b_sc_load1_a; 
   assign sc_load2 = i_p2b_sc_load2_a; 
   assign sc_reg1 = i_p2b_sc_reg1_a; 
   assign sc_reg2 = i_p2b_sc_reg2_a; 
   assign sex = i_p3_sex_r; 
   assign size = i_p3_size_r; 

//------------------------------------------------------------------------------
// Stage 4 Output Drives
//------------------------------------------------------------------------------
//    
   assign wba = i_p4_wba_r; 
   assign wben = i_p4_wben_r; 
   assign wben_nxt = i_p4_wben_nxt; 
   assign p4_disable_r = i_p4_disable_r; 
   assign p4_docmprel = i_p4_docmprel_a;
   assign p4iv = i_p4_iv_r;
   assign ldvalid_wb = i_p4_ldvalid_wback_a;  
   
//------------------------------------------------------------------------------
// Interrupts
//------------------------------------------------------------------------------

   assign interrupt_holdoff = i_interrupt_holdoff_a; 
   assign flagu_block = i_flagu_block_a; 
   assign instruction_error = i_p2_instruction_error_a; 

//------------------------------------------------------------------------------
// Misc
//------------------------------------------------------------------------------

   assign kill_p1_a        = i_kill_p1_a; 
   assign kill_p1_en_a     = i_kill_p1_en_a; 
   assign kill_p1_nlp_a    = i_kill_p1_nlp_a; 
   assign kill_p1_nlp_en_a = i_kill_p1_nlp_en_a; 
   assign kill_p2_a        = i_kill_p2_a; 
   assign kill_p2_en_a     = i_kill_p2_en_a; 
   assign kill_p2b_a       = i_p4_kill_p2b_a; 
   assign kill_p3_a        = i_p4_kill_p3_a; 
   assign kill_tagged_p1   = i_tag_nxt_p1_killed_r; 
   assign stop_step        = i_stop_step_a;
   assign hold_int_st2_a   = i_hold_int_st2_a; 

endmodule // module rctl
