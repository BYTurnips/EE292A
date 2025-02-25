//  Constants for simulation models/testbenches.
//synopsys translate_off
//
// ------------------------ Clock Parameters ---------------------------
//
// System clock period multiplier. Specifies by how much the core clock
// period is multiplied to obtain the system clock period. For example
// if sys_clock_period_multiplier = 2, this means that the system clock
// period is twice the core clock period, i.e. the system clock is half
// the speed of the core clock.
// Possible values for sys_clock_period_multiplier are:
// 1 : system clock period [speed] = core clock period [speed]
// 2 : system clock period [speed] = 2 [1/2] * core clock [speed]
// 3 : system clock period [speed] = 3 [1/3] * core clock [speed]
// 4 : system clock period [speed] = 3 [1/4] * core clock [speed]
//
// If you need to change the clock ratio use this parameter rather than
// changing clock definitions elsewhere.
// 
// NOTE: If you change the sys_clock_period_multiplier, and therefore
// change the period for the system clock, REMEMBER to go and change the
// system clok period variable (arc_system_clock_period) in the RDF
// script option.tcl accordingly for the synthesys, sta etc. scripts to
// work properly.
//
parameter sys_clock_period_multiplier = 1;


// If you add/create new pieces of IP and/or new testbenches, use one of the
// following clocok parameters as appropriate (whether you need the system clock
// or the core clock speed) rather than using a different parameter or an
// explicit clock period number for your new clock.

// Core clock period. Defines the period for the clock inside the ARC cpu.
//
parameter clock_period_brd = 3.70;

parameter clock_period = 3.70;

// System clock period. Defines the clock period for the external system
// (i.e. memory subsystem). This is the same as the core clock period
// multiplied by the sys_clock_period_multiplier parameter (which is 1 by
// default, so that the two clock periods are the same).
// If you need a slower system clock, please change the multiplier
// and not the system clock period definition.
//
parameter sys_clock_period = clock_period * sys_clock_period_multiplier;
                          
// 
//  tpd          - Propagation time of a flip-flop. Used in testbenches as the
//                 period to wait before sampling signals after the clock edge.
// 
//  su_time      - Setup time of a flip-flop. Used in testbenches to allow 
//                 signals to be sampled just before the end of the clock period.
// 
//  lv_time      - Load valid time. Used by memory controller model (memcon2) as the
//                 time after which ldvalid becomes true.
// 
//
parameter tpd          = clock_period / 8.00;
parameter lv_time      = clock_period / 2.00;
parameter su_time      = clock_period / 4.00;

// Average clock insertion delay. This is always 0, except for
// backannotated gate-level simulations where a real clock tree
// is present. In this case this parameter has to be manually
// changed to reflet the average clock insertion delay for
// the ARC core. This is used to adjust the clock into testbench
// modules where no clock tree is present.
// Note: it seems that this needs to be changed only for AHB builds.
//
parameter avg_ck_insertion_delay = 0;

//synopsys translate_on
